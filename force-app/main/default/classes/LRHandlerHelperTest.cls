@isTest
public class LRHandlerHelperTest {
    
    public static testMethod void testLRHandlerHelper(){
        
        Id recTypeIdEWP = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Entertainment Work').getRecordTypeId();        
        Id recTypeIdIndvPermit = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account(
            FirstName = 'test',
            LastName = 'acct 123',
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
        
        
        
        License_Registration__c lReg1 = new License_Registration__c ();
        lReg1.Account__c = acc.Id;
        lReg1.RecordTypeId = recTypeIdEWP;
        lReg1.License_Registration_Number__c = acc.Id;
        lReg1.License_Registration_Type__c = '3333';
        lReg1.Submitted_Date__c = Date.today() - 3;
        lReg1.Applicant__c = c.Id;
        lReg1.Registration_Duration__c  = '10 Days - Temporary Permit';
        lReg1.Submission_Type__c = 'Online';
        lReg1.Company_type__c = 'Sole Proprietorship';
        //lReg1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        lReg1.First_Name__c = 'FirstName';
        lReg1.Last_Name__c = 'LastName';
        lReg1.Account_Email__c = 'test@asdadad.com';
        lReg1.Legal_Entity_Name__c = 'Legal Entity Name';
        lReg1.Mailing_Address_Line_1__c = 'Street';
        //lReg1.Mailing_Address_Line_2__c = '';
        lReg1.Mailing_City__c = 'San Francisco';
        lReg1.Mailing_State__c = 'CA';
        lReg1.Mailing_Postal_Code__c = '54434';
        //lReg1.Mailing_Country__c = '';
        lReg1.Daytime_Phone__c = '1234567890';
        lReg1.Mobile_Phone__c = '1234567890';
        lReg1.Date_Formed__c = Date.today();                   
        lReg1.Daytime_Phone_Ext__c ='123';          
        lReg1.Federal_Employer_Identification_Number__c ='123456789';
        //lReg1.Good_standing_with_CA_Secretary_of_State__c = 'Yes';
        lReg1.Physical_Business_Address_Line_1__c = 'asdf';            
        //lReg1.Physical_Business_Address_Line_2__c = '';             
        lReg1.Physical_Business_City__c = 'asdf';           
        //lReg1.Physical_Business_Country__c = 'United States of America';
        lReg1.Physical_Business_Postal_Code__c = '12345';           
        lReg1.Physical_Business_State__c = 'CA';          
        lReg1.State_Employer_Identification_Number__c = '12345678';            
        lReg1.State_of_Incorporation__c = 'CA';
 
        insert lReg1;
        
        License_Registration__c lReg2= new License_Registration__c ();
        lReg2.Account__c = acc.Id;
        lReg2.RecordTypeId = recTypeIdEWP;
        lReg2.License_Registration_Number__c = acc.Id;
        lReg2.License_Registration_Type__c = '3333';
        lReg2.Applicant__c = c.Id;
        lReg2.Registration_Duration__c  = '10 Days - Temporary Permit';
        insert lReg2; 
        
        Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = recTypeIdIndvPermit;
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Birth_Date__c =  Date.Today() - 30;
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_Street__c = 'Street';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '1234567890';
        racc1.Mobile_Phone__c = '1234567890';
        racc1.Date_Formed__c = Date.today();        
        racc1.Business_Phone__c = '1234567890';             
        //racc1.Daytime_Phone_Ext__c ='123';          
        racc1.Physical_Business_Street__c = 'asdf';            
        //racc1.Physical_Business_Line_2__c = '';             
        racc1.Physical_Business_City__c = 'asdf';           
        //racc1.Physical_Business_Country__c = '';
        racc1.Physical_Business_Zip_Code__c = '12345';           
        racc1.Physical_Business_State__c = 'CA'; 
        racc1.Federal_Employer_Identification_Number__c ='123456789';
        racc1.State_Employer_Identification_Number_c__c = '12345678';    
        racc1.State_of_Incorporation__c = 'CA';
        racc1.Registration__c = lReg1.Id;
        
        insert racc1;
        
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = recTypeIdIndvPermit;
        racc2.First_Name__c = 'FirstName';
        racc2.Last_Name__c = 'LastName';
        racc2.Birth_Date__c =  Date.Today() - 30;
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Legal_Entity_Name__c = 'Legal Entity Name';
        racc2.Mailing_Street__c = 'Street';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Registration__c = lReg2.id;
        insert racc2;
        
        List<License_Registration__c> lrList = new List<License_Registration__c>();
        lrList.add(lReg1);
        
        List<License_Registration__c> lReg3 = [SELECT Id, RecordTypeId, Record_Type_Name__c, Registration_Duration__c FROM License_Registration__c WHERE Id =: lReg1.Id];
        
        test.startTest();
        
        //LRHandlerRegistrations LRHandlerReg = new LRHandlerRegistrations();
        //LRHandlerReg.CreateRegistrations(lrList);
        LRHandlerHelper.getInstance().initiateRegAccount(lReg1, racc1);
        
        LRHandlerHelper.getInstance().isDuplicateRegAccount(lReg1, recTypeIdIndvPermit);
        
        Map<Id, License_Registration__c> oldMap = new Map<Id, License_Registration__c>();
        LRHandlerHelper.getInstance().isExistingPermitHolder(lReg3, oldMap);
        LRHandlerHelper.getInstance().CheckValidRegistrationAge(lReg3, oldMap);
        //LRHandlerHelper.getInstance().getAllEWPRA();
        
        test.stopTest();
        
    }
}