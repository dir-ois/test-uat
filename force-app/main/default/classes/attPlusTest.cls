@istest
public class attPlusTest {

    public static testMethod void testPAGAResults1(){
        
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
        
        Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        
        License_Registration__c  newLR2 = new License_Registration__c();
        newLR2.Account__c = communityUser[0].Contact.AccountId;
        newLR2.RecordTypeId = publicWorksRecordTypeId;
        newLR2.License_Registration_Number__c = '222';
        newLR2.License_Registration_Type__c = 'Public Works';
        newLR2.Status__c = 'Incomplete'; 
        newLR2.Expiration_Date__c = Date.today() - 365; 
        newLR2.Amount_Paid__c = 100; 
        newLR2.Applicant__c = communityUser[0].ContactId;
        newLR2.License_Registration_Type__c = 'Public Works';
        insert newLR2;
        system.debug('##### newLR2: ' + newLR2);
        
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Federal Courts';
        dirCase1.Court_Name__c = 'U.S. Supreme';
        //dirCase1.Violation_Type__c = 'Child Labor';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        List<Attachments_Plus__c> attToInsert = new List<Attachments_Plus__c>();

        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        //temp.VIPForm__Form_Style__c = 'Vertical Navigation';
        insert temp;
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'Company Finances';
        section.Name = 'WCI Documentation - External';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        Attachments_Plus__c attPlus = new Attachments_Plus__c();
        attPlus.Attachment_Name__c = 'Test PAGA Attachment';
        attPlus.Case_Management__c = dirCase1.Id;
        attPlus.Type__c = 'Audit';
        attPlus.Confidential__c = true;
        attPlus.Attorney_Client_Privilege__c = true;
        attPlus.Not_Subject_to_PRA__c = true;
        attPlus.IFP_Claimed__c = true;
        attPlus.Registration__c = newLR2.id;
        attPlus.VIP_Form_Section__c = section.id;
        attToInsert.add(attPlus);
        
        Attachments_Plus__c attPlus1 = new Attachments_Plus__c();
        attPlus1.Attachment_Name__c = 'Test PAGA Attachment 2';
        attPlus1.Case_Management__c = dirCase1.Id;
        attPlus1.Type__c = 'Payment';
        attPlus1.Registration__c = newLR2.id;
        attPlus1.VIP_Form_Section__c = section.id;
        attToInsert.add(attPlus1);
        test.startTest();
            
            insert attToInsert;
            List<Attachments_Plus__c> attToUpdate = [SELECT Id,Registration__c,VIP_Form_Section_Name_Display__c FROM Attachments_Plus__c];
            update attToUpdate;
            delete attToUpdate;
            
        test.stopTest();
    }
    
    
    
   
}