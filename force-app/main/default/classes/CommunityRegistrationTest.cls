@istest (SeeAllData=true)
public class CommunityRegistrationTest {

    public static testMethod void testCommunityRegistration(){
        
        
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
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();

        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = communityUser[0].Contact.AccountId;
        newLR.RecordTypeId = RecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = communityUser[0].ContactId;
        newLR.Submission_Type__c = 'Paper';
        //newLR.VIP_Template_Status__c = 'Incomplete';
        
        insert newLR;
        system.debug('##### newLR: ' + newLR);
 
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = personRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
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
        
        DBA__c rdba1 = new DBA__c();
        rdba1.Registration__c = newLR.Id;
        rdba1.Name ='DBA Name';
        rdba1.Active__c = 'Yes';
        insert rdba1;
        
        DBA__c rdba2 = new DBA__c();
        rdba2.Registration__c = newLR.Id;
        rdba2.Name ='DBA Inactive';
        rdba2.Active__c = 'No';
        insert rdba2;

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
//        insert rloc;
        system.debug('##### rloc: ' + rloc);
 
        system.runAs(communityUser[0]) {
            test.startTest();
                Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
                System.currentPageReference().getParameters().put('renewId', newLR.Id);
                System.currentPageReference().getParameters().put('recId', newLR.Id);
                System.currentPageReference().getParameters().put('printId', newLR.Id);

                CommunityRegistration CR = new CommunityRegistration();
                CR.currentRecordType = RecordTypeId;
                CR.getAllRegistrations();
                CR.getRegistrationRecordTypes();
                CR.LinkRegistration();
                CR.AddRegistration();
                CR.SubmitPayment();
                CR.RenewRegistration();
                CR.closePopup();
                CR.PrintApplication();
                CR.CheckActiveRegistration();

            test.stopTest();
        }
    }
    
    public static testMethod void testCommunityRegistrationPWC(){
        
        
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
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();


        License_Registration__c  newLR2 = new License_Registration__c();
        newLR2.Account__c = communityUser[0].Contact.AccountId;
        newLR2.RecordTypeId = publicWorksRecordTypeId;
        newLR2.License_Registration_Number__c = '222';
        newLR2.License_Registration_Type__c = 'Public Works';
        newLR2.Status__c = 'Active'; 
        newLR2.Expiration_Date__c = Date.today() - 365; 
        newLR2.Amount_Paid__c = 100; 
        newLR2.Applicant__c = communityUser[0].ContactId;
        newLR2.License_Registration_Type__c = 'Public Works';
        insert newLR2;
        system.debug('##### newLR2: ' + newLR2); 
        System.assertEquals(newLR2.displayRenewalButton__c, False);
 
        Access_Approval__c aa = new Access_Approval__c();
        aa.Approved__c = 'Yes';
        aa.Requestor__c =  communityUser[0].Contact.Id;
        aa.Registration__c = newLR2.Id;
        
        insert aa;
        
        system.runAs(communityUser[0]) {
            test.startTest();
                Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
                System.currentPageReference().getParameters().put('renewId', newLR2.Id);
                System.currentPageReference().getParameters().put('recId', newLR2.Id);
                System.currentPageReference().getParameters().put('printId', newLR2.Id);

                CommunityRegistration CR = new CommunityRegistration();
                CR.currentRecordType = RecordTypeId;
                CR.getAllRegistrations();
                CR.getRegistrationRecordTypes();
                CR.LinkRegistration();
                CR.AddRegistration();
                CR.SubmitPayment();
                CR.RenewRegistration();
                CR.closePopup();
                CR.PrintApplication();
                CR.CheckActiveRegistration();
            

            test.stopTest();
        }
    }    
        public static testMethod void testCommunityRegistrationCPS(){
        
        
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
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();


        License_Registration__c  newLR1 = new License_Registration__c();
        newLR1.Account__c = communityUser[0].Contact.AccountId;
        newLR1.RecordTypeId = cPSRecordTypeId;
        newLR1.License_Registration_Number__c = '222';
        newLR1.License_Registration_Type__c = 'Child Performer Services';
        newLR1.Status__c = 'Incomplete'; 
        newLR1.Expiration_Date__c = Date.today() + 10; 
        newLR1.Amount_Paid__c = 100; 
        newLR1.Applicant__c = communityUser[0].ContactId;
        newLR1.Submission_Type__c = 'Online';
        //newLR1.VIP_Template_Status__c = 'Completed';
        insert newLR1;

        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = indivRecordTypeId;
        racc2.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc2.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc2.First_Name__c = 'FirstName';
        racc2.Middle_Name__c = 'NMN';
        racc2.Last_Name__c = 'LastName';
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Legal_Entity_Name__c = 'Legal Entity Name';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_Street__c = 'Street ';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        racc2.Registration__c = newLR1.Id;
        insert racc2;
        System.debug('##### RA2: ' + racc2);

                   
        List<Live_Scan__c> newLiveScanList = new List<Live_Scan__c>();
        Live_Scan__c ls = new Live_Scan__c();
        ls.ATI_Number__c = 'asdf';
        ls.LSID_Number__c = '123';
        ls.Registration__c = newLR1.Id;
        
        Live_Scan__c ls2 = ls.clone(false, true, false, false);
        ls2.ATI_Number__c = 'asdf';
        ls2.LSID_Number__c = '123';
        ls2.Registration__c = newLR1.Id;
        
        newLiveScanList.add(ls);
        newLiveScanList.add(ls2);
        
        insert newLiveScanList;
        
        system.runAs(communityUser[0]) {
            test.startTest();
                Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
                System.currentPageReference().getParameters().put('renewId', newLR1.Id);
                System.currentPageReference().getParameters().put('recId', newLR1.Id);
                System.currentPageReference().getParameters().put('printId', newLR1.Id);

                CommunityRegistration CR = new CommunityRegistration();
                CR.currentRecordType = RecordTypeId;
                CR.getAllRegistrations();
                CR.getRegistrationRecordTypes();
                CR.LinkRegistration();
                CR.AddRegistration();
                CR.SubmitPayment();
                CR.RenewRegistration();
                CR.closePopup();
                CR.PrintApplication();
                CR.CheckActiveRegistration();

            test.stopTest();
        }
    }
    
    public static testMethod void testCommunityRegistrationEWP(){
        
        
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
        
        Id EWPRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        Id iPRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        //Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
        //Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        //Id cPSRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();
        
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = communityUser[0].Contact.AccountId;
        newLR.RecordTypeId = EWPRecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Entertainment Work';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = communityUser[0].ContactId;
        newLR.Registration_Duration__c = '6 Months - Permit';
        //newLR.VIP_Template_Status__c = 'Incomplete';
        newLR.Submission_Type__c = 'Paper';
        insert newLR;
        system.debug('##### newLR: ' + newLR);
        
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = iPRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = newLR.Id;
        racc1.Birth_Date__c = Date.today() - 60;
        insert racc1;
        System.debug('##### RA1: ' + racc1);
  
            test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CommunityRegistration')); 
            System.currentPageReference().getParameters().put('renewId', newLR.Id);
            System.currentPageReference().getParameters().put('recId', newLR.Id);
            System.currentPageReference().getParameters().put('printId', newLR.Id);
            
            CommunityRegistration CR = new CommunityRegistration();
            CR.currentRecordType = EWPRecordTypeId;
            CR.getAllRegistrations();
            CR.getRegistrationRecordTypes();
            CR.LinkRegistration();
            CR.AddRegistration();
            CR.SubmitPayment();
            CR.RenewRegistration();
            CR.closePopup();
            CR.PrintApplication();
            CR.CheckActiveRegistration();
            
        test.stopTest();
        }
    //}
}