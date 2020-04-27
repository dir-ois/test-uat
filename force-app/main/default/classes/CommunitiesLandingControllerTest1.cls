@istest
public class CommunitiesLandingControllerTest1{

    
    static testMethod void testCommunitiesLandingController() {
        //BEGIN: some setup items
        /*Profile commProfile = [SELECT Id FROM Profile WHERE Name = 'Community Registrations User' LIMIT 1];
        
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
        
        
        List<User> newUsers = [SELECT Id,contactId  FROM User WHERE Id=: u.Id AND ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        //END: some setup items
        //validate the initial contact information
        newUsers[0].Street = 'aaaaa\nbbbbb';
        
        License_Registration__c lr = new License_Registration__c();
        lr.Account__c = a.id;
        lr.Applicant__c = acc.PersonContactId;
        lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        lr.Account_Email__c = 'standarduser@testorg.com';
        lr.Amount_Due__c = 100;
        lr.Amount_Paid_Manually__c = 10;
        lr.Amount_Paid_Online__c  = 12;
        
        
        insert lr;
        
        lr.Ready_to_Submit__c = 'Yes';
        update lr;
        system.debug('newUsers***'+newUsers );
        system.debug('contact here***'+[select Id, Balance__c,Amount_Due__c ,Amount_Paid_Manually__c , Amount_Paid_Online__c  ,Applicant__c  from License_Registration__c where id=:lr.id ]);
        */
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
        
        List<User> newUsers = [SELECT Id,contactId  FROM User WHERE Id=: u.Id AND ProfileId =: commProfile.Id AND isActive = true LIMIT 1];

        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();
        
        /*DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        */
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 10; 
        newLR.Applicant__c = acc.PersonContactId ;
        newLR.recordTypeID = lrRecordTypeID;
        insert newLR;
        
        newLR.Ready_to_Submit__c = 'Yes';
        update newLR;
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = newLR.Id;
        feeSummary.Fees_Due__c = 200;
        feeSummary.Status__c = 'Not Paid';
        feeSummary.Active__c = true; 
        insert feeSummary;
        
        /*Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = newLR.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c();
        newChargentOrder.ChargentOrders__Payment_Method__c = 'Check';
        newChargentOrder.Registration__c  = newLR.Id;
        newChargentOrder.Fee_Summary__c = feeSummary.Id;
        newChargentOrder.ChargentOrders__Billing_Email__c = newLR.Applicant__r.Email;
        newChargentOrder.ChargentOrders__Subtotal__c = 0;
        insert newChargentOrder;
        */
       
        system.debug('newUsers***'+newUsers );
        system.debug('feeSummary***'+feeSummary);
        system.debug('contact here***'+[select Id, Balance__c,Amount_Due__c ,Amount_Paid_Manually__c , Amount_Paid_Online__c  ,Applicant__c  from License_Registration__c where id=:newLR.id ]);
       
        Test.startTest();
        System.runAs  ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
             CommunitiesLandingController controller = new CommunitiesLandingController();
            PageReference pageRef = controller.forwardToStartPage();         
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
}