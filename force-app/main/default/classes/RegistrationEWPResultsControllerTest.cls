@istest
public class RegistrationEWPResultsControllerTest {
    
    RegistrationEWPResultsControllerTest(){
        
    }
    
    public static testMethod void testRegistrationResults3(){
         Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id parentRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Parent Guardian').getRecordTypeId();
        //Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();

        
        Account acc2 = new Account(
            FirstName = 'ewp',
            LastName = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            PersonEmail = 'lralltestusers@test.com',
            RecordTypeId = personRecordTypeId
        );
        insert acc2;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test';
        con2.LastName = 'Test';
        con2.Email = 'testLNRDEV@testdir.com';
        insert con2;
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = RecordTypeId;
        lreg.Account__c = acc2.Id;
        lreg.Applicant__c = con2.Id;
        lreg.License_Registration_Number__c = 'xxxxx';
        lreg.Status__c = 'Renewed';
        //lreg.Assigned_Deputy__c = deputy.Id;
        lreg.Legal_Entity_Name__c = 'name';
        lreg.Registration_Duration__c  = '10 Days - Temporary Permit';
        //lreg.Registration_Duration__c  = '6 Months - Permit';
        lreg.Submission_Type__c = 'Online';
        //lreg.Status_of_Payment__c = 'Paid / No Balance Due';
        //lreg.Balance__c = 0;
        lreg.Amount_Due__c = 50;
        lreg.Amount_Paid_Online__c  = 50;
        lreg.Amount_Paid_Manually__c = 0;
        lreg.Status__c = 'Pending Payment';
        lreg.Effective_Date__c = Date.today() - 5;
        lreg.Expiration_Date__c = Date.today() + 90;
        insert lreg; 
        
        License_Registration__c lreg2 = new License_Registration__c();
        lreg2.RecordTypeId = RecordTypeId;
        lreg2.Account__c = acc2.Id;
        lreg2.Applicant__c = con2.Id;
        lreg2.License_Registration_Number__c = 'xxxxx';
        lreg2.Status__c = 'Incomplete';
        //lreg.Assigned_Deputy__c = deputy.Id;
        lreg2.Legal_Entity_Name__c = 'name';
        //lreg.Registration_Duration__c  = '10 Days - Temporary Permit';
        lreg2.Registration_Duration__c  = '6 Months - Permit';
        lreg2.Submission_Type__c = 'Online';
        //lreg.Status_of_Payment__c = 'Paid / No Balance Due';
        //lreg.Balance__c = 0;
        //lreg2.Amount_Due__c = 50;
        //lreg2.Amount_Paid_Online__c  = 50;
        //lreg2.Amount_Paid_Manually__c = 0;
        lreg2.Status__c = 'Incomplete';
        lreg2.Effective_Date__c = Date.today() - 5;
        lreg.Expiration_Date__c = Date.today() + 90;
        insert lreg2; 
        
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = indivRecordTypeId;
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Residential_Street__c = 'test street';
        racc1.Residential_City__c = 'oak';
        racc1.Residential_State__c = 'ca';
        racc1.Residential_Zip_Code__c = '94612';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '94612';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Birth_Date__c = Date.today() - 40;
        racc1.Registration__c = lreg.Id;
        insert racc1;
        
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = parentRecordTypeId;
        racc2.First_Name__c = 'FirstName';
        racc2.Last_Name__c = 'LastName';
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_Street__c = 'Street ';
        racc2.Mailing_Zip_Code__c = '94612';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        racc2.Birth_Date__c = Date.today() - 40;
        racc2.Registration__c = lreg.Id;
        insert racc2;
        
        //List<License_Registration__c> newList = new List<License_Registration__c>();
        //newList.add(lreg);
        
        License_Registration__c lr = [SELECT Id
                                      , License_Registration_Number__c
                                      , Record_Type_Name__c
                                      , Status_of_Payment__c
                                      , Status__c
                                      , Registration_Duration__c
                                      , Submission_Type__c
                                      FROM License_Registration__c WHERE Id=:lreg.Id Limit 1];
        
        lr.Status__c = 'Approved';
        lr.Submission_Type__c = 'Online';
        //lr.Status__c = 'Submitted';
        //lr.Ready_to_Submit__c = 'Yes';
        update lr;
                
        //List<License_Registration__c> newList2 = new List<License_Registration__c>();
        //newList2.add(lr);

        RegistrationEWPResultsController RegistrationResults = new RegistrationEWPResultsController();
        
        String registrationNumberStr = '12345';
        String locationZipStr = '54434';
        String selectedRecordType = 'Entertainment Work';
        
        String RegistrationNum = '12345';
        String Status = 'Active';
        //String ParentNm = 'Parent Test';
        String MinorNm = 'Minor Test';
        String StageNm = 'the artist formerly known as princess';
        Date EffectiveDate = NULL;
        Date ExpirationDate = NULL;
        
        
        test.startTest();
        RegistrationEWPResultsController.getAllRegistrations(lr.License_Registration_Number__c, selectedRecordType, racc1.Residential_Zip_Code__c);
        RegistrationResults.BackToSearch();
        RegistrationEWPResultsController.wrapRegistrationAccounts wrapper = new RegistrationEWPResultsController.wrapRegistrationAccounts(RegistrationNum, Status, MinorNm, StageNm, EffectiveDate, ExpirationDate);
        test.stopTest();
    }
    
}