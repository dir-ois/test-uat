@istest
public class RegistrationDocDownloadControllerTest {
    
    public static testMethod void testRegDocDLController(){
        
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account(
            FirstName = 'test',
            LastName = 'acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            PersonEmail = 'lralltestusers@test.com',
            RecordTypeId = personAccountRTId
        );
        insert acc;
        
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Email = 'first.last@gmail.com';
        insert c;
        
        Id EWPRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        Id iPRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
 
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.Applicant__c = c.Id;
        newLR.RecordTypeId = EWPRecordTypeId;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Entertainment Work';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Registration_Duration__c = '6 Months - Permit';
        newLR.VIP_Template_Status__c = 'Incomplete';
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
        Test.setCurrentPageReference(new PageReference('Page.RegistrationDocDownload')); 
        
        RegistrationDocDownloadController regDownload = new RegistrationDocDownloadController();
        
        regDownload.openMedicalInfoToPdf();
        regDownload.openSchoolInfoToPdf();
        
        test.stopTest();
    }
    //}
}