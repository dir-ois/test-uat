@isTest
public class ReceiptCasesDialogControllerTest {
    static testmethod void testSearchCases(){
        String KeySearch = '';

        List<DIR_Case__c> emptyKeyList = [Select Id, Case_Number__c, Assigned_Deputy__c,Total_Amount_Paid__c, Assigned_Deputy__r.Name, Employer__c, Employer__r.Name, RecordType.Name
                                    from DIR_Case__c where Case_Number__c != null and Assigned_Deputy__r.Name != null order By Case_Number__c Limit 5];
        List<DIR_Case__c> searchList = ReceiptCasesDialogController.searchCases(keySearch);

        KeySearch = '%966%';

        List<DIR_Case__c> keyList = [Select Id, Case_Number__c, Assigned_Deputy__c,Total_Amount_Paid__c, Assigned_Deputy__r.Name, Employer__c, Employer__r.Name, RecordType.Name
                                                     from DIR_Case__c where (Case_Number__c like :KeySearch or Employer__r.Name like :KeySearch )
                                                     and Assigned_Deputy__r.Name != null order By Case_Number__c Limit 5];
        KeySearch = '966';
        List<DIR_Case__c> searchList2 = ReceiptCasesDialogController.searchCases(keySearch);


        System.assertEquals(null, searchList);
        System.assertEquals(keyList, searchList2);
    }
    
    static testmethod void testGetGrid(){

        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1 ];
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id
        );
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id,
            Manager__c = mgr.Id
        );
        insert de;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        acc.Bankruptcy_Status_Date__c = Date.today();
        insert acc;

        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.Id;
        insert c;

        List<DIR_Case__c> l2 = [Select Id, Case_Number__c, Assigned_Deputy__c,Total_Amount_Paid__c, Assigned_Deputy__r.Name, Employer__c, Employer__r.Name, RecordType.Name from DIR_Case__c where Case_Number__c != null and Assigned_Deputy__r.Name != null order By Case_Number__c Limit 5];


        ReceiptCasesDialogController.getgridCases(String.valueOf(c.Id));
    }


}