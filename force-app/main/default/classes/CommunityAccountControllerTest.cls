@isTest (SeeAllData=true)
private class CommunityAccountControllerTest {
    
    static testMethod void CommunityAccount() {
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
        
        
        List<User> newUsers = [SELECT Id FROM User WHERE ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        //END: some setup items
        //validate the initial contact information
        newUsers[0].Street = 'aaaaa\nbbbbb';
        Test.startTest();
        System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
            CommunityAccountController CA = new CommunityAccountController();
             
            List<User> userUpdates = new List<User>();
            userUpdates.add(new User(City = 'San Francisco', Country = 'US', FirstName = 'Tess', Id = newUsers[0].Id, LastName = 'Hacic', PostalCode = '94105', State = 'CA', Street = 'One Market Street', Title = 'CEO'));
            CA.existingUser = userUpdates[0];
            
            CA.updateAccount();
            CA.backToRegistration();
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
    
    static testMethod void CommunityAccount1() {
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
        insert u;
        
        List<User> newUsers = [SELECT Id FROM User WHERE ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        newUsers[0].Street = 'aaa\nbbbb';
        //END: some setup items
        //validate the initial contact information
        
        Test.startTest();
        System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
            CommunityAccountController CA = new CommunityAccountController();
             
            List<User> userUpdates = new List<User>();
            userUpdates.add(new User(City = 'San Francisco', Country = 'US', FirstName = 'Tess', Id = newUsers[0].Id, LastName = 'Hacic', PostalCode = '94105', State = 'CA', Street = 'One Market Street', Title = 'CEO'));
            CA.address1 = 'aaa';
            CA.existingUser = userUpdates[0];
            CA.updateAccount();
            CA.backToRegistration();
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
    
    static testMethod void CommunityAccount2() {
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
        insert u;
        
        List<User> newUsers = [SELECT Id FROM User WHERE ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        newUsers[0].Street = 'aaa\nbbbb';
        //END: some setup items
        //validate the initial contact information
        
        Test.startTest();
        System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
            CommunityAccountController CA = new CommunityAccountController();
             
            List<User> userUpdates = new List<User>();
            userUpdates.add(new User(City = 'San Francisco', Country = 'US', Id = newUsers[0].Id, LastName = 'Hacic', PostalCode = '94105', State = 'CA', Street = 'One Market Street', Title = 'CEO'));
            CA.address1 = 'aaa';
            CA.existingUser = userUpdates[0];
            CA.existingUser.FirstName = '12345678901234567890123456789012345678901';
            CA.updateAccount();
            CA.backToRegistration();
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
    
    static testMethod void CommunityAccount3() {
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
        insert u;
        
        List<User> newUsers = [SELECT Id FROM User WHERE ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        newUsers[0].Street = 'aaa\nbbbb';
        //END: some setup items
        //validate the initial contact information
        
        Test.startTest();
        System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
            CommunityAccountController CA = new CommunityAccountController();
             
            List<User> userUpdates = new List<User>();
            userUpdates.add(new User(City = 'San Francisco', Country = 'US', FirstName = 'Tess', Id = newUsers[0].Id, LastName = 'Hacic', PostalCode = '94105', State = 'CA', Street = 'One Market Street', Title = 'CEO'));
            //CA.address1 = 'aaa';
            //CA.existingUser = userUpdates[0];
            //CA.updateAccount();
            //CA.backToRegistration();
            CA.RedirectToPassword();
            CA.newPwd = 'ABC123true#';
            CA.confirmPwd = 'ABC123false#';
            CA.changePassword();
            CA.cancelPassword();
            
            CA.RedirectToPassword();
            CA.newPwd = 'ABC123true#';
            CA.confirmPwd = 'ABC123true#';
            CA.changePassword();
            
            
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
    

}