@isTest
public with sharing class LRHandlerRegistrationsTest{
    
    
    public static testMethod void testCreateRegistrations1(){
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account(
            FirstName = 'test',
            LastName= 'acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            PersonEmail = 'lralltestusers@test.com',
            RecordTypeId = personRecordTypeId
        );
        insert acc;
        
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.Email = 'first.last@gmail.com';
        insert c;
        
        
        Id RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();
        
        License_Registration__c lReg1 = new License_Registration__c ();
        lReg1.Account__c = acc.Id;
        lReg1.RecordTypeId = RecordTypeId;
        lReg1.License_Registration_Number__c = acc.Id;
        lReg1.License_Registration_Type__c = '3333';
        lReg1.Submitted_Date__c = Date.today() - 3;
        lReg1.Mailing_City__c = 'Denver';
        lReg1.Applicant__c = c.Id;
        lReg1.Registration_Duration__c  = '10 Days - Temporary Permit';
        lReg1.Submission_Type__c = 'Online';
        //lReg1.Company_type__c = 'Sole Proprietorship';
        
        insert lReg1;
        
        lReg1.Submission_Type__c = 'Online';
        update lReg1;
        
        List<License_Registration__c> lrList = new List<License_Registration__c>();
        
        lrList.add(lReg1);
        
        Id indivRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = indivRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Birth_Date__c =  Date.Today() - 30;
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = lReg1.Id;
        
        insert racc1;

        test.startTest();
        
        LRHandlerRegistrations LRHandlerReg = new LRHandlerRegistrations();
        LRHandlerReg.CreateRegistrations(lrList);

        test.stopTest();
        
    }
}