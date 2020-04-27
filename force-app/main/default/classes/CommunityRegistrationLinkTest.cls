@istest
public class CommunityRegistrationLinkTest {

    public static testMethod void testCommunityRegistrationLink1(){
        
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
        Account acc = new Account(
            Name = 'test acct 123',
            Legal_Entity_Name__c = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
       
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Email='testdirlnr.test@dirlnr.com');
        insert con;  
                  
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c .getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.RecordTypeId = RecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        insert newLR;

        test.startTest();
            CommunityRegistrationLink CRL = new CommunityRegistrationLink();  
            CRL.currentRecordType = RecordTypeId;
            CRL.currentRegistration.License_Registration_Number__c = 'test';
            CRL.currentRegistration.Mailing_City__c = 'test';
            CRL.SearchRegistration();
            CRL.LinkRegistration();
            CRL.CancelBack();
            
            List<SelectOption> selOpt = CRL.getRegistrationRecordTypes();
        test.stopTest();
    }
    
/////////////////////////////////////////
    public static testMethod void testCommunityRegistrationLink2(){
    
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
        Account acc = new Account(
            Name = 'test acct 123',
            Legal_Entity_Name__c = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
       
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Email='testdirlnr.test@dirlnr.com');
        insert con;  
                  
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c .getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.RecordTypeId = RecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Public Works';
        newLR.Status__c = 'Active'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        newLR.Mailing_City__c = 'Denver';
        newLR.regLinked__c = false;
        
        insert newLR;

       
        test.startTest();
            License_Registration__c ereg = [SELECT Id, License_Registration_Number__c, Assigned_Deputy__c, Mailing_City__c FROM License_Registration__c WHERE Id =: newLR.Id];
            
            CommunityRegistrationLink CRL = new CommunityRegistrationLink();  
            CRL.currentRecordType = RecordTypeId;
            CRL.currentRegistration.License_Registration_Number__c = ereg.License_Registration_Number__c;
            CRL.currentRegistration.Mailing_City__c = ereg.Mailing_City__c;
            CRL.SearchRegistration();
            CRL.LinkRegistration();
            
            CRL.currentRecordType = 'Select';
            CRL.SearchRegistration();
            
            newLR.regLinked__c = true;
            CRL.SearchRegistration();
            CRL.LinkRegistration();            
        test.stopTest();
    }
/////////////////////////////////////////    
        public static testMethod void testCommunityRegistrationLink3(){

        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
        Account acc = new Account(
            Name = 'test acct 123',
            Legal_Entity_Name__c = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
       
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Email='testdirlnr.test@dirlnr.com');
        insert con;  
                  
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c .getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.RecordTypeId = RecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Entertainment Work';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        insert newLR;

        test.startTest();
            CommunityRegistrationLink CRL = new CommunityRegistrationLink();  
            CRL.currentRecordType = RecordTypeId;
            CRL.currentRegistration.License_Registration_Number__c = 'test';
            CRL.currentRegistration.Mailing_City__c = 'test';
            CRL.SearchRegistration();
            CRL.LinkRegistration();
            CRL.CancelBack();
            
            List<SelectOption> selOpt = CRL.getRegistrationRecordTypes();
        test.stopTest();
    }
}