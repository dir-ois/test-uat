public class createAccountForPublicWorksBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT Legal_Entity_Name__c,' +
                        'Company_Type__c,' +
                        'Physical_Business_Address_Line_1__c,' +
                        'Physical_Business_Address_Line_2__c,' +
                        'Physical_Business_City__c,' +
                        'Physical_Business_State__c,' +
                        'Physical_Business_Postal_Code__c,' +
                        'Physical_Business_County__c' + ' ' +
                'FROM License_Registration__c' + ' ' +
                'WHERE accAlreadyCreated__c = FALSE' + ' ' +
                'AND RecordType.DeveloperName = \'Public_Works\'' + ' ' +
                'AND Legal_Entity_Name__c != NULL' + ' ' +
                'AND Status__c IN (\'Pending Payment\', \'Active\')'
        );
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<License_Registration__c> registrations = (List<License_Registration__c>)scope;
        Id bussAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        List<Account> accToInsert = new List<Account>();
        List<License_Registration__c> regToUpdate = new List<License_Registration__c>();
        Map<Id, Account> accountsByIds = new Map<Id, Account>();
        List<User> integrationUsers = [
                SELECT Id
                FROM User
                WHERE Name = 'Integration User'
                LIMIT 1
        ];

        for (License_Registration__c reg : registrations) {
            Account acc = new Account();
            if (!integrationUsers.isEmpty()) acc.OwnerId = integrationUsers.get(0).Id;
            acc.RecordTypeId = bussAccId;
            acc.Name = reg.Legal_Entity_Name__c;
            acc.Entity_Type__c = reg.Company_Type__c;

            acc.ShippingStreet = reg.Physical_Business_Address_Line_1__c + ' ' + reg.Physical_Business_Address_Line_2__c;
            acc.ShippingCity = reg.Physical_Business_City__c;
            acc.ShippingState = reg.Physical_Business_State__c;
            acc.ShippingPostalCode = reg.Physical_Business_Postal_Code__c;
            acc.County__c = reg.Physical_Business_County__c;

            accountsByIds.put(reg.Id, acc);

            accToInsert.add(acc);
        }

        insert accToInsert;

        for (License_Registration__c reg : registrations) {
            reg.accAlreadyCreated__c = true;
            reg.Account__c = accountsByIds.get(reg.Id).Id;
            regToUpdate.add(reg);
        }

        update regToUpdate;
    }

    public void finish(Database.BatchableContext bc) {

    }
}