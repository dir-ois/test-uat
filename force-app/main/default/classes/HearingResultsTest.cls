@isTest
public with sharing class HearingResultsTest {
    public static testMethod void TestHearingResults1() {
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Affiliation__c aff = new Affiliation__c();
        aff.Affiliated_Account__c = acc.Id;
        aff.Main_Account__c = acc.Id;
        insert aff;

        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        insert c;
        
        Assessments__c assess = new Assessments__c();
        assess.Case_Management__c = c.Id;
        assess.Appeal_Deadline_Selector__c = 'Business Days';
        insert assess;
        
        DIR_Violation__c dv = new DIR_Violation__c();
        dv.Case__c = c.Id;
        dv.Assessment__c = assess.Id;
        insert dv;

        Liability__c lia = new Liability__c();
        lia.Assessment__c = assess.Id;
        insert lia;
        
        Appeal__c appeal1 = new Appeal__c();
        appeal1.Status__c = 'New';
        appeal1.Case__c = c.Id;
        appeal1.X2810_3_Case__c = 'Yes';
        appeal1.Citation_Selected__c = true;
        appeal1.Estimated_Length_of_Hearing_In_Minutes__c = 60;
        insert appeal1;
        
        Liability_Appeal__c la = new Liability_Appeal__c();
        la.Appeal__c = appeal1.Id;
        la.Liability__c = lia.Id;
        insert la;
        
        Hearing__c h = new Hearing__c();
        h.Appeal__c = appeal1.Id;
        h.Case__c = c.Id;
        h.Status__c = 'New';
        insert h;

        Hearing_Liability__c hl = new Hearing_Liability__c();
        hl.Hearing__c = h.Id;
        hl.Liability_Appeal__c = la.Id;
        insert hl;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(h);
        HearingResults hr = new HearingResults(sc);
        
        PageReference pageRef = Page.HearingResults;
        pageRef.getParameters().put('id', String.valueOf(h.Id));
        Test.setCurrentPage(pageRef);
        
        hr.SaveHearing();
    }
    
    public static testMethod void TestHearingResults2() {
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Affiliation__c aff = new Affiliation__c();
        aff.Affiliated_Account__c = acc.Id;
        aff.Main_Account__c = acc.Id;
        insert aff;
    
        Profile p = [select id from profile where name='RCI User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testuser1@ca-dir.com');
        insert u;
    
        //manager
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        
        //internal employee
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        insert de;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.id;
        insert c;
        
        Assessments__c assess = new Assessments__c();
        assess.Case_Management__c = c.Id;
        assess.Appeal_Deadline_Selector__c = 'Business Days';
        insert assess;
        
        DIR_Violation__c dv = new DIR_Violation__c();
        dv.Case__c = c.Id;
        dv.Assessment__c = assess.Id;
        insert dv;

        Liability__c lia = new Liability__c();
        lia.Assessment__c = assess.Id;
        insert lia;
        
        Appeal__c appeal1 = new Appeal__c();
        appeal1.Status__c = 'New';
        appeal1.Case__c = c.Id;
        appeal1.X2810_3_Case__c = 'Yes';
        appeal1.Citation_Selected__c = true;
        appeal1.Estimated_Length_of_Hearing_In_Minutes__c = 60;
        insert appeal1;
        
        Liability_Appeal__c la = new Liability_Appeal__c();
        la.Appeal__c = appeal1.Id;
        la.Liability__c = lia.Id;
        insert la;
        
        Hearing__c h = new Hearing__c();
        h.Appeal__c = appeal1.Id;
        h.Case__c = c.Id;
        h.Status__c = 'Scheduled';
        h.Meeting_Start_Date_Time__c = Date.today();
        h.Meeting_End_Date_Time__c = Date.today() + 1;
        h.Meeting_Type__c = 'Conference';
        h.Length_of_Hearing__c = 30;
        h.Meeting_Scheduled_For__c = de.id;
        insert h;

        Hearing_Liability__c hl = new Hearing_Liability__c();
        hl.Hearing__c = h.Id;
        hl.Liability_Appeal__c = la.Id;
        insert hl;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(h);
        HearingResults hr = new HearingResults(sc);
        
        test.startTest();
        
        PageReference pageRef = Page.HearingResults;
        pageRef.getParameters().put('id', String.valueOf(h.Id));
        Test.setCurrentPage(pageRef);
       
        hr.SaveHearing();
        
        test.stopTest();
    }
    
}