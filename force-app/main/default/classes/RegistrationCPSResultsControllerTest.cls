@istest
public class RegistrationCPSResultsControllerTest {

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
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();
        
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
        RegistrationCPSResultsController RegistrationCPSResults = new RegistrationCPSResultsController();
        
        System.currentPageReference().getParameters().put('registrationNumberStr', '80212');
        
        System.currentPageReference().getParameters().put('legalEntityStr', '80212');
        System.currentPageReference().getParameters().put('effectiveDate', String.valueOf(Date.today()-10));
        System.currentPageReference().getParameters().put('expirationDate', String.valueOf(Date.today()+10));
        System.currentPageReference().getParameters().put('dbaNameStr', '80212');
        System.currentPageReference().getParameters().put('locationAddressStr', '80212');
        System.currentPageReference().getParameters().put('locationCityStr', '80212');
        System.currentPageReference().getParameters().put('locationStateStr', '80212');
        System.currentPageReference().getParameters().put('locationZipStr', '80212');
        
        String firstNameStr = 'testfn';
        String middleNameStr = 'testmiddlename';
        String lastNameStr = 'testln';
        String registrationNumberStr = '80212';
        String effectiveDateStart = String.valueOf(Date.today()-30);
        String effectiveDateEnd = String.valueOf(Date.today()+30);
        String expirationDateStart = String.valueOf(Date.today()-30);
        String expirationDateEnd = String.valueOf(Date.today()+30);
        String locationAddressStr = 'Denver';
        String locationCityStr = 'Denver';
        String locationStateStr = 'aaaa';
        String locationZipStr = '12343';
        
        String selectedRecordType = 'Child Performer Services';
        String selectedStatus = 'Approved';
        RegistrationCPSResultsController.getAllRegistrations(registrationNumberStr, selectedRecordType, selectedStatus, firstNameStr,
                                                          middleNameStr, lastNameStr, locationCityStr, locationStateStr, 
                                                          locationZipStr, effectiveDateStart, effectiveDateEnd,
                                                          expirationDateStart, expirationDateEnd);
            
        RegistrationCPSResults.BackToSearch();
        
        
        
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
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Child Performer Services').getRecordTypeId();
        
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
        RegistrationCPSResultsController RegistrationCPSResults = new RegistrationCPSResultsController();
        
        System.currentPageReference().getParameters().put('registrationNumberStr', '80212');
        System.currentPageReference().getParameters().put('effectiveDate', String.valueOf(Date.today()-10));
        //System.currentPageReference().getParameters().put('expirationDate', String.valueOf(Date.today()+10));
        System.currentPageReference().getParameters().put('dbaNameStr', '80212');
        System.currentPageReference().getParameters().put('locationAddressStr', '80212');
        //System.currentPageReference().getParameters().put('locationCityStr', '80212');
        System.currentPageReference().getParameters().put('locationStateStr', '80212');
        System.currentPageReference().getParameters().put('locationZipStr', '80212');

        String firstNameStr = 'testfn';
        String middleNameStr = 'testmiddlename';
        String lastNameStr = 'testln';
        String registrationNumberStr = '80212';
        String effectiveDateStart = String.valueOf(Date.today()-30);
        String effectiveDateEnd = null;
        String expirationDateStart = String.valueOf(Date.today()-30);
        String expirationDateEnd = null;
        String locationAddressStr = 'Denver';
        String locationCityStr = 'Denver';
        String locationStateStr = 'aaaa';
        String locationZipStr = '12343';

        String selectedRecordType = 'Child Performer Services';
        String selectedStatus = 'Approved';
        RegistrationCPSResultsController.getAllRegistrations(registrationNumberStr, selectedRecordType, selectedStatus, firstNameStr,
                                                          middleNameStr, lastNameStr, locationCityStr, locationStateStr, 
                                                          locationZipStr, effectiveDateStart, effectiveDateEnd,
                                                          expirationDateStart, expirationDateEnd);
        
        RegistrationCPSResults.BackToSearch();
        
        
        
        test.stopTest();
    }

    
}