@istest
public class RevokeChargentLicenseBatchTest {

    
    static testMethod void testRevokeChargentLicenseBatch() {
        //BEGIN: some setup items
        Profile commProfile = [SELECT Id FROM Profile WHERE Name = 'Community Registrations User' LIMIT 1];
        
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
               
        //system.debug('##### A: ' + a);
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(contactId = acc.PersonContactId, Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = commProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        system.debug('##### u: ' + u);
        insert u;
        
        
        List<User> newUsers = [SELECT Id FROM User WHERE Id=: u.Id AND ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        //END: some setup items
        //validate the initial contact information
        newUsers[0].Street = 'aaaaa\nbbbbb';
        
        License_Registration__c lr = new License_Registration__c();
        lr.Account__c = a.id;
        lr.Applicant__c = acc.PersonContactId;
        lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        lr.Account_Email__c = 'standarduser@testorg.com';
        lr.Amount_Due__c = 100;
        lr.Amount_Paid_Manually__c = 0;
        lr.Amount_Paid_Online__c  = 0;
        
        
        insert lr;
        
        lr.Ready_to_Submit__c = 'Yes';
        update lr;
        
        Test.startTest();
        System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
        
            // CommunitiesLandingController controller = new CommunitiesLandingController();
           //  PageReference pageRef = controller.forwardToStartPage();
            CommunityLoginController controller = new CommunityLoginController();
           controller.username = 'test@tesrtest.com';
           controller.login();
           controller.SignIn();
           controller.forwardToCustomAuthPage();   
        
            RevokeChargentLicenseBatch obj = new RevokeChargentLicenseBatch();
            obj.selectedTime = system.now();
            DataBase.executeBatch(obj,2000);

            RevokeChargentLicenseScheduler obj2 = new RevokeChargentLicenseScheduler();
            String sch = '0 0 2 * * ?';
            system.schedule('Test purgeChargentOrderScheduler', sch, obj2);   
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
    // static testMethod void testRevokeChargentLicenseBatch1() {
    //     //BEGIN: some setup items
    //     Profile commProfile = [SELECT Id FROM Profile WHERE Name = 'Community Registrations User' LIMIT 1];
        
    //     Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       
    //     account a = new Account(
    //       RecordTypeID=personAccountRTId,
    //       FirstName='Test FName',
    //       LastName='Test LName',
    //       PersonMailingStreet='test@yahoo.com',
    //       PersonMailingPostalCode='12345',
    //       PersonMailingCity='SFO',
    //       PersonEmail='test@yahoo.com',
    //       PersonHomePhone='1234567',
    //       PersonMobilePhone='12345678' 
    //     );
    //     insert a;
               
    //     //system.debug('##### A: ' + a);
    //     Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
    //     User u = new User(contactId = acc.PersonContactId, Alias = 'standt', Email='standarduser@testorg.com', 
    //         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    //         LocaleSidKey='en_US', ProfileId = commProfile.Id, 
    //         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
    //     system.debug('##### u: ' + u);
    //     insert u;
        
        
    //     List<User> newUsers = [SELECT Id FROM User WHERE Id=: u.Id AND ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
    //     //END: some setup items
    //     //validate the initial contact information
    //     newUsers[0].Street = 'aaaaa\nbbbbb';
        
    //     License_Registration__c lr = new License_Registration__c();
    //     lr.Account__c = a.id;
    //     lr.Applicant__c = acc.PersonContactId;
    //     lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
    //     lr.Account_Email__c = 'standarduser@testorg.com';
    //     lr.Amount_Due__c = 100;
    //     lr.Amount_Paid_Manually__c = 0;
    //     lr.Amount_Paid_Online__c  = 0;
        
        
    //     insert lr;
        
    //     lr.Ready_to_Submit__c = 'Yes';
    //     update lr;
        
    //     Test.startTest();
    //     System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
        
          
    //       CommunityLoginController controller = new CommunityLoginController();
    //       controller.username = 'test@tesrtest.com';
    //       controller.login();
    //       controller.SignIn();
    //       controller.forwardToCustomAuthPage();   
        
    //         RevokeChargentLicenseScheduler obj = new RevokeChargentLicenseScheduler();
    //         String sch = '0 0 2 * * ?';
    //         system.schedule('Test purgeChargentOrderScheduler', sch, obj);        
    //     }
    //     Test.stopTest();
    //     //validate that it worked as intended
        
    // }
}