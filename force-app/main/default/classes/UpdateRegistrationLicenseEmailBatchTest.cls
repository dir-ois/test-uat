@istest (SeeAllData=true)
public class UpdateRegistrationLicenseEmailBatchTest{

    public static testMethod void UpdateRegistrationLicenseEmailBatch(){
        
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       
        account a = new Account(
          RecordTypeID=personAccountRTId,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
        insert a;
               
        system.debug('##### A: ' + a);
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(contactId = acc.PersonContactId, Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p, isActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert u;
        system.debug('##### u: ' + u);
        
        List<User> communityUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ProfileId =: p AND isActive = true LIMIT 1];
        system.debug('##### CommunityUser: ' + communityUser);
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        Id personRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
            
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = communityUser[0].Contact.AccountId;
        newLR.RecordTypeId = RecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Account_Email__c = 'test_email_licenseregistration=test.com@example.com';
        newLR.Applicant__c = communityUser[0].ContactId;
        insert newLR;
        system.debug('##### newLR: ' + newLR);
        
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = personRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test_email_registrationaccount1=test.com@example.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = newLR.Id;
        insert racc1;
        System.debug('##### RA1: ' + racc1);

        
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = businessRecordTypeId;
        racc2.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc2.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc2.First_Name__c = 'FirstName';
        racc2.Last_Name__c = 'LastName';
        racc2.Email_Address__c = 'test_email_registrationaccount2=test.com@example.com';
        racc2.Legal_Entity_Name__c = 'Legal Entity Name';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_Street__c = 'Street ';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        racc2.Registration__c = newLR.Id;
        insert racc2;
        System.debug('##### RA2: ' + racc2);

        
        Registration_Location__c rloc = new Registration_Location__c();
        rloc.Address__c = 'address';
        rloc.City__c = 'San Francisco';
        rloc.DBA_Name__c = 'DBA Name';
        rloc.FBNS__c = 'FBNS';
        rloc.Foreign_Address__c = 'Foreign Address';
        rloc.Mobile_Business__c = true;
        rloc.Phone__c = '4445553434';
        rloc.Registration__c = newLR.Id;
        rloc.Account__c = communityUser[0].Contact.AccountId;
        rloc.Zip_Code__c = '12343';
        rloc.Business_Regulatory_Compliance__c = 'No';
        insert rloc;
        system.debug('##### rloc: ' + rloc);
        
        system.runAs(communityUser[0]) {
            test.startTest();
                Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
                System.currentPageReference().getParameters().put('renewId', newLR.Id);
                System.currentPageReference().getParameters().put('recId', newLR.Id);
                CommunityRegistration CR = new CommunityRegistration();  
                CR.currentRecordType = RecordTypeId;
                CR.getAllRegistrations();
                CR.getRegistrationRecordTypes();
                CR.LinkRegistration();
                CR.AddRegistration();
                CR.SubmitPayment();
                CR.RenewRegistration();
                //CR.DeleteRegistration();
                
                if (Test.isRunningTest())
                {
                    Id tb = Database.executeBatch(new UpdateRegistrationLicenseEmailBatch(), 1);
                } else 
                {
                    Id tb = Database.executeBatch(new UpdateRegistrationLicenseEmailBatch());
                }
                
            test.stopTest();    
            
            License_Registration__c acct1 = [SELECT id, name, Account_Email__c from License_Registration__c where id = :newLR.Id];
            System.assertEquals('test_email_licenseregistration=test.com@example.com', acct1.Account_Email__c);
                
        }                
    }
}