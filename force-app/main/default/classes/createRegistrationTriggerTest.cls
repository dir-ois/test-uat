@istest
public class createRegistrationTriggerTest {
    
    public static testMethod void testCreateRegistration(){
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id parentRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Parent Guardian').getRecordTypeId();
        //Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        
        Account acc = new Account(
            FirstName = 'ewp',
            LastName = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            PersonEmail = 'lralltestusers@test.com',
            RecordTypeId = personRecordTypeId
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = RecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        //lreg.Assigned_Deputy__c = deputy.Id;
        lreg.Legal_Entity_Name__c = 'name';
        lreg.Registration_Duration__c  = '10 Days - Temporary Permit';
        lreg.Submission_Type__c = 'Online';
        //lreg.Status_of_Payment__c = 'Paid / No Balance Due';
        //lreg.Balance__c = 0;
        lreg.Amount_Due__c = 50;
        lreg.Amount_Paid_Online__c  = 50;
        lreg.Amount_Paid_Manually__c = 0;
        lreg.Effective_Date__c = Date.today() + 5;
        lreg.Status__c = 'Incomplete';
        //lreg.Ready_to_Submit__c = 'Yes';
        
        insert lreg; 
        
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = indivRecordTypeId;
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Birth_Date__c = Date.today() - 20;
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
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        //racc2.Birth_Date__c = Date.today() - 40;
        racc2.Registration__c = lreg.Id;
        insert racc2;
        
        License_Registration__c lr = [SELECT Id
                                      , Record_Type_Name__c
                                      , Status_of_Payment__c
                                      , Status__c
                                      , Registration_Duration__c
                                      , Submission_Type__c
                                      FROM License_Registration__c WHERE Id=:lreg.Id];
        
        lr.Submission_Type__c = 'Online';
        lr.Status__c = 'Submitted';
        lr.Ready_to_Submit__c = 'Yes';
        update lr;
        
        test.startTest();
        List<Create_Registrations__e > createLR = new list<Create_Registrations__e >();
        createLR.add(new Create_Registrations__e  (RegistrationID__c = lr.Id));
        EventBus.publish(createLR);
        
        test.stopTest();
        
    }
}