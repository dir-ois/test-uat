@istest(seealldata=true)
public class RegistrationSearchNewControllerTest {

    public static void testRegistrationSearchNewController(){

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
        newLR2.Status__c = 'Active'; 
        newLR2.Expiration_Date__c = Date.today() - 365; 
        newLR2.Amount_Paid__c = 100; 
        newLR2.Applicant__c = communityUser[0].ContactId;
        newLR2.License_Registration_Type__c = 'Public Works';
        newLR2.Legal_Entity_Name__c = 'test';
        newLR2.Mailing_City__c = 'test';
        newLR2.Physical_Business_County__c = 'Alameda';
        newLR2.Field_Surveyor__c = true;
        
        system.debug('##### newLR2: ' + newLR2);  
        insert newLR2;
        system.debug('##### newLR2: ' + newLR2);  
        
        
        DBA__c dba = new DBA__c();
        dba.Name = 'test';
        dba.Registration__c = newLR2.id;
        insert dba;
        
        //apexpages.currentpage().getparameters().put('myList',newLR2.id);
        //printRegDetailsController reg =  new printRegDetailsController();

    }
    
    public static testMethod void testRegistrationSearchNewController1(){
        
        String inputDate = Datetime.now().format('yyyy-MM-dd');
        RegistrationSearchNewController.convertToDate(inputDate);
    }
    
    public static testMethod void testRegistrationSearchNewController2(){
        RegistrationSearchNewController reg = new RegistrationSearchNewController();
        
        testRegistrationSearchNewController();
        List<String> Filters = new List<String>();
        Filters.add('Field Surveyor');
        List<Object> testObj = RegistrationSearchNewController.getKeys('test','','','Alameda','test',Filters);
    }    
}