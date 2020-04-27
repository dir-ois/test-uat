@isTest
public with sharing class appealTriggerTest {
    
    public static testMethod void TestWithdrawnAppeals1() {
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        insert c;
        
        Appeal__c appeal1 = new Appeal__c();
        appeal1.Status__c = 'Received - Timely';
        //appeal1.Case__c = c.Id;
        appeal1.X2810_3_Case__c = 'Yes';
        appeal1.Citation_Selected__c = true;
        appeal1.Estimated_Length_of_Hearing_In_Minutes__c = 60;
        insert appeal1;
        
        Assessments__c assesment = new Assessments__c();
        assesment.Appeal_Deadline_Selector__c = 'Business Days';
        assesment.Appeal_Deadline_Days__c = 15;
        assesment.Case_Management__c = c.Id;
        insert assesment;

        Liability__c liability1 = new Liability__c();
        liability1.Assessment__c = assesment.Id;
        liability1.Status__c = 'New';
        liability1.Case_Management__c = c.Id;
        insert liability1;
        
        Liability_Appeal__c la = new Liability_Appeal__c();
        la.Appeal__c = appeal1.Id;
        la.Liability__c = liability1.Id;
        la.Appeal_Status__c = 'Received - Untimely';
        insert la;
        
        test.startTest();
        
        Appeal__c app = [SELECT Id, Status__c FROM Appeal__c WHERE Id =: appeal1.Id];
        app.Status__c = 'Withdrawn';
        update app;
        
        test.stopTest();
    }
    
    public static testMethod void TestWithdrawnAppeals2() {
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        //c.RecordTypeId = caseRecordType.Id;
        insert c;
        
        Appeal__c appeal1 = new Appeal__c();
        appeal1.Status__c = 'Received - Timely';
        appeal1.Case__c = c.Id;
        appeal1.X2810_3_Case__c = 'Yes';
        appeal1.Citation_Selected__c = true;
        appeal1.Estimated_Length_of_Hearing_In_Minutes__c = 60;
        insert appeal1;
        
        Appeal__c appeal2 = new Appeal__c();
        appeal2.Status__c = 'Received - Timely';
        appeal2.Case__c = c.Id;
        appeal2.X2810_3_Case__c = 'Yes';
        appeal2.Citation_Selected__c = true;
        appeal2.Estimated_Length_of_Hearing_In_Minutes__c = 60;
        insert appeal2;
        
        Assessments__c assesment = new Assessments__c();
        assesment.Appeal_Deadline_Selector__c = 'Business Days';
        assesment.Appeal_Deadline_Days__c = 15;
        assesment.Case_Management__c = c.Id;
        insert assesment;

        Liability__c liability1 = new Liability__c();
        liability1.Assessment__c = assesment.Id;
        liability1.Status__c = 'New';
        liability1.Case_Management__c = c.Id;
        insert liability1;
        
        Liability_Appeal__c la = new Liability_Appeal__c();
        la.Appeal__c = appeal1.Id;
        la.Liability__c = liability1.Id;
        la.Appeal_Status__c = 'Received - Untimely';
        insert la;
        
        Liability_Appeal__c la1 = new Liability_Appeal__c();
        la1.Appeal__c = appeal2.Id;
        la1.Liability__c = liability1.Id;
        la.Appeal_Status__c = 'Received - Untimely';
        insert la1;
        
        test.startTest();
        
        Appeal__c app = [SELECT Id, Status__c FROM Appeal__c WHERE Id =: appeal1.Id];
        app.Status__c = 'Withdrawn';
        update app;
        
        test.stopTest();
    }
}