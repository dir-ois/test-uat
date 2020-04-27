@istest
public class RegistrationQuestionAllTest {

    public static testMethod void testRegistrationQuestionAll1(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        Question_Bank__c qb = new Question_Bank__c();
        qb.Answer_Type__c = 'YesNo'; 
        qb.Question_Text__c = 'Is this a test question?';
        insert qb;
        
        Question_Bank__c qb1 = new Question_Bank__c();
        qb1.Answer_Type__c = 'YesNo'; 
        qb1.Question_Text__c = 'Is this a test question?';
        qb1.Follow_up_Criteria__c = 'Yes';
        qb1.Controlling_Question__c = qb.Id;
        insert qb1;
        
        Question_Rule__c qr = new Question_Rule__c();
        qr.Active__c = true;
        qr.Question_ID__c = qb.Id;
        qr.Registration_Type__c = 'Car Wash';
        qr.Sort_Order__c = 1;
        insert qr;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        insert lreg;
        
        Registration_Question__c rq = [SELECT Id, Reg_Answer__c FROM Registration_Question__c WHERE Question_ID__c =: qb.Id AND Registration_ID__c =:lreg.Id];
        rq.Reg_Answer__c = 'Yes';
        
        test.startTest();
            update rq;
            Registration_Question__c rq1 = [SELECT Id, Reg_Answer__c FROM Registration_Question__c WHERE Question_ID__c =: qb.Id AND Registration_ID__c =:lreg.Id];
            rq1.Reg_Answer__c = '';
            update rq1;
        test.stopTest();
    }
    
    
    public static testMethod void testRegistrationQuestionAll2(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        Question_Bank__c qb = new Question_Bank__c();
        qb.Answer_Type__c = 'YesNo'; 
        qb.Question_Text__c = 'Is this a test question?';
        insert qb;
        
        Question_Bank__c qb1 = new Question_Bank__c();
        qb1.Answer_Type__c = 'YesNo'; 
        qb1.Question_Text__c = 'Is this a test question?';
        qb1.Follow_up_Criteria__c = 'Yes';
        qb1.Controlling_Question__c = qb.Id;
        insert qb1;
        
        Question_Rule__c qr = new Question_Rule__c();
        qr.Active__c = true;
        qr.Question_ID__c = qb.Id;
        qr.Registration_Type__c = 'Car Wash';
        qr.Sort_Order__c = 1;
        insert qr;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        insert lreg;
        
        Registration_Question__c rq = [SELECT Id, Reg_Answer__c FROM Registration_Question__c WHERE Question_ID__c =: qb.Id AND Registration_ID__c =:lreg.Id];
        rq.Reg_Answer__c = 'Yes';
        
        test.startTest();
            update rq;
            Registration_Question__c rq1 = [SELECT Id, Reg_Answer__c FROM Registration_Question__c WHERE Question_ID__c =: qb.Id AND Registration_ID__c =:lreg.Id];
            rq1.Reg_Answer__c = 'No';
            update rq1;
        test.stopTest();
    }
   
}