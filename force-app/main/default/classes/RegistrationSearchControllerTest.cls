@istest
public class RegistrationSearchControllerTest {

    public static testMethod void testRegistrationSearch1(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Email = 'first.last@gmail.com';
        insert c;
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        
        License_Registration__c lReg1 = new License_Registration__c ();
        lReg1.Account__c = acc.Id;
        lReg1.RecordTypeId = RecordTypeId;
        lReg1.License_Registration_Number__c = acc.Id;
        lReg1.License_Registration_Type__c = '3333';
        lReg1.Submitted_Date__c = Date.today() - 3;
        lReg1.Mailing_City__c = 'Denver';
        lReg1.Applicant__c = c.Id;
        insert lReg1;
        
        
        test.startTest();
            RegistrationSearchController RegistrationSearch = new RegistrationSearchController();
            
            RegistrationSearch.searchString = 'searchString';
            RegistrationSearch.searchClassObj.legalEntityStr = '80212';
            RegistrationSearch.searchClassObj.effectiveDate = Date.today()-10;
            RegistrationSearch.searchClassObj.expirationDate = Date.today()+10;
            RegistrationSearch.searchClassObj.dbaNameStr = 'aaa';
            RegistrationSearch.searchClassObj.locationAddressStr = 'Denver';
            RegistrationSearch.searchClassObj.locationCityStr = 'Denver';
            RegistrationSearch.searchClassObj.locationStateStr = 'aaaa';
            RegistrationSearch.searchClassObj.locationZipStr = '12343';
            RegistrationSearch.searchClassObj.workersCompTypeStr = 'aaaaa';
            RegistrationSearch.searchClassObj.workersCompInsurerStr = 'aaaaa';
            RegistrationSearch.searchClassObj.bondIssuerStr = 'aaaaa';
            RegistrationSearch.searchClassObj.bondEffectiveStart = Date.today()-10;
            RegistrationSearch.searchClassObj.bondEffectiveStart = Date.today()+10;
            RegistrationSearch.SearchRegistration();
            RegistrationSearch.ClearFields();
            
            RegistrationSearch.getcompType();
        test.stopTest();
    }
    
   
}