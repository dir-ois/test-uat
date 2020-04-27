@istest
public class RegistrationResultsControllerTest {

    public static testMethod void testRegistrationResults1(){
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
            RegistrationResultsController RegistrationResults = new RegistrationResultsController();
            
            System.currentPageReference().getParameters().put('registrationNumberStr', '80212');

            System.currentPageReference().getParameters().put('legalEntityStr', '80212');
            System.currentPageReference().getParameters().put('effectiveDate', String.valueOf(Date.today()-10));
            System.currentPageReference().getParameters().put('expirationDate', String.valueOf(Date.today()+10));
            System.currentPageReference().getParameters().put('dbaNameStr', '80212');
            System.currentPageReference().getParameters().put('locationAddressStr', '80212');
            System.currentPageReference().getParameters().put('locationCityStr', '80212');
            System.currentPageReference().getParameters().put('locationStateStr', '80212');
            System.currentPageReference().getParameters().put('locationZipStr', '80212');
            System.currentPageReference().getParameters().put('workersCompTypeStr', '80212');
            System.currentPageReference().getParameters().put('workersCompInsurerStr', '80212');
            System.currentPageReference().getParameters().put('bondIssuerStr', '80212');
            System.currentPageReference().getParameters().put('bondEffectiveStart', String.valueOf(Date.today()-30));
            System.currentPageReference().getParameters().put('bondEffectiveEnd', String.valueOf(Date.today()+30));
           
            String registrationNumberStr = '80212';
            String legalEntityStr = '80212';
            String effectiveDateStart = String.valueOf(Date.today()-30);
            String effectiveDateEnd = String.valueOf(Date.today()+30);
            String expirationDateStart = String.valueOf(Date.today()-30);
            String expirationDateEnd = String.valueOf(Date.today()+30);
            String dbaNameStr = 'aaa';
            String locationAddressStr = 'Denver';
            String locationCityStr = 'Denver';
            String locationStateStr = 'aaaa';
            String locationZipStr = '12343';
            String workersCompTypeStr = 'aaaaa';
            String workersCompInsurerStr = 'aaaaa';
            String bondIssuerStr = 'aaaaa';
            String bondEffectiveStart = String.valueOf(Date.today()-30);
            String bondEffectiveEnd = String.valueOf(Date.today()+30);
        	String selectedRecordType = 'Car Wash';
        	String selectedStatus = 'Approved';
        
            RegistrationResultsController.getAllRegistrations(registrationNumberStr, selectedRecordType, selectedStatus, legalEntityStr, effectiveDateStart, effectiveDateEnd, expirationDateStart, expirationDateEnd,
            dbaNameStr, locationAddressStr, locationCityStr, locationStateStr, locationZipStr, workersCompTypeStr, workersCompInsurerStr,
            bondIssuerStr, bondEffectiveStart, bondEffectiveEnd);
            
            RegistrationResults.BackToSearch();

            
            
        test.stopTest();
    }
    
    public static testMethod void testRegistrationResults2(){
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
            RegistrationResultsController RegistrationResults = new RegistrationResultsController();
            
            System.currentPageReference().getParameters().put('registrationNumberStr', '80212');

            System.currentPageReference().getParameters().put('legalEntityStr', '80212');
            System.currentPageReference().getParameters().put('effectiveDate', String.valueOf(Date.today()-10));
            //System.currentPageReference().getParameters().put('expirationDate', String.valueOf(Date.today()+10));
            System.currentPageReference().getParameters().put('dbaNameStr', '80212');
            System.currentPageReference().getParameters().put('locationAddressStr', '80212');
            System.currentPageReference().getParameters().put('locationCityStr', '80212');
            System.currentPageReference().getParameters().put('locationStateStr', '80212');
            System.currentPageReference().getParameters().put('locationZipStr', '80212');
            System.currentPageReference().getParameters().put('workersCompTypeStr', '80212');
            System.currentPageReference().getParameters().put('workersCompInsurerStr', '80212');
            System.currentPageReference().getParameters().put('bondIssuerStr', '80212');
            System.currentPageReference().getParameters().put('bondEffectiveStart', String.valueOf(Date.today()-30));
            //System.currentPageReference().getParameters().put('bondEffectiveEnd', String.valueOf(Date.today()+30));
            String registrationNumberStr = '80212';
            String legalEntityStr = '80212';
            String effectiveDateStart = String.valueOf(Date.today()-30);
            String effectiveDateEnd = null;
            String expirationDateStart = String.valueOf(Date.today()-30);
            String expirationDateEnd = null;
            String dbaNameStr = 'aaa';
            String locationAddressStr = 'Denver';
            String locationCityStr = 'Denver';
            String locationStateStr = 'aaaa';
            String locationZipStr = '12343';
            String workersCompTypeStr = 'aaaaa';
            String workersCompInsurerStr = 'aaaaa';
            String bondIssuerStr = 'aaaaa';
            String bondEffectiveStart = String.valueOf(Date.today()-30);
            String bondEffectiveEnd = null;
        	String selectedRecordType = 'Car Wash';
        	String selectedStatus = 'Approved';
            RegistrationResultsController.getAllRegistrations(registrationNumberStr, selectedRecordType, selectedStatus, legalEntityStr, effectiveDateStart, effectiveDateEnd, expirationDateStart, expirationDateEnd,
            dbaNameStr, locationAddressStr, locationCityStr, locationStateStr, locationZipStr, workersCompTypeStr, workersCompInsurerStr,
            bondIssuerStr, bondEffectiveStart, bondEffectiveEnd);
            
            RegistrationResults.BackToSearch();

            
            
        test.stopTest();
    }
    
    
    public static testMethod void testRegistrationResults3(){
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
            RegistrationResultsController RegistrationResults = new RegistrationResultsController();
            
            System.currentPageReference().getParameters().put('registrationNumberStr', '80212');

            System.currentPageReference().getParameters().put('legalEntityStr', '80212');
            //System.currentPageReference().getParameters().put('effectiveDate', String.valueOf(Date.today()-10));
            System.currentPageReference().getParameters().put('expirationDate', String.valueOf(Date.today()+10));
            System.currentPageReference().getParameters().put('dbaNameStr', '80212');
            System.currentPageReference().getParameters().put('locationAddressStr', '80212');
            System.currentPageReference().getParameters().put('locationCityStr', '80212');
            System.currentPageReference().getParameters().put('locationStateStr', '80212');
            System.currentPageReference().getParameters().put('locationZipStr', '80212');
            System.currentPageReference().getParameters().put('workersCompTypeStr', '80212');
            System.currentPageReference().getParameters().put('workersCompInsurerStr', '80212');
            System.currentPageReference().getParameters().put('bondIssuerStr', '80212');
            //System.currentPageReference().getParameters().put('bondEffectiveStart', String.valueOf(Date.today()-30));
            System.currentPageReference().getParameters().put('bondEffectiveEnd', String.valueOf(Date.today()+30));
            String registrationNumberStr = '80212';
            String legalEntityStr = '80212';
            String effectiveDateStart = null;
            String effectiveDateEnd = String.valueOf(Date.today()+10);
            String expirationDateStart = null;
            String expirationDateEnd = String.valueOf(Date.today()+30);
            String dbaNameStr = 'aaa';
            String locationAddressStr = 'Denver';
            String locationCityStr = 'Denver';
            String locationStateStr = 'aaaa';
            String locationZipStr = '12343';
            String workersCompTypeStr = 'aaaaa';
            String workersCompInsurerStr = 'aaaaa';
            String bondIssuerStr = 'aaaaa';
            String bondEffectiveStart = null;
            String bondEffectiveEnd = String.valueOf(Date.today()+30);
        	String selectedRecordType = 'Car Wash';
        	String selectedStatus = 'Approved';
            RegistrationResultsController.getAllRegistrations(registrationNumberStr, selectedRecordType, selectedStatus, legalEntityStr, effectiveDateStart, effectiveDateEnd, expirationDateStart, expirationDateEnd,
            dbaNameStr, locationAddressStr, locationCityStr, locationStateStr, locationZipStr, workersCompTypeStr, workersCompInsurerStr,
            bondIssuerStr, bondEffectiveStart, bondEffectiveEnd);
            
            RegistrationResults.BackToSearch();

            
            
        test.stopTest();
    }
    
}