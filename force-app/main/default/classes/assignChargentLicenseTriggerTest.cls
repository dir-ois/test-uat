@istest
public class assignChargentLicenseTriggerTest {

    public static testmethod void assignChargentLicenseTriggerTest(){
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
        
        AssignChargentLicense__e cl = new AssignChargentLicense__e(UserID__c = u.Id);
        
        test.startTest();
        database.SaveResult sr = EventBus.publish(cl);
        test.stopTest();
        
        system.assertEquals(true, sr.isSuccess());
        
    }
    
    
    
}