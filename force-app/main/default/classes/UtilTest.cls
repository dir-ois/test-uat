@isTest
public class UtilTest{
    
    @isTest
    static void testSkipTrigger(){
        
                
        Account a = new Account();
        a.Name = 'employer';
        insert a;
        
        Account a2 = new Account();
        a2.Name = 'PartyAccount2';
        insert a2;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.Name = 'Touk Ken';
        ma.User__c = UserInfo.getUserId();
        ma.Position__c = 'Senior Deputy';
        ma.Title__c = 'Senior Deputy Labor Commissioner';
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'Bao Le';
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        Office__c office = new Office__c();
        office.Name = 'Bakersfield WCA';
        office.Office_Number__c = 'WCA 1';
        office.RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert office;
        
        DIR_Case__c cm = new DIR_Case__c();
        cm.Assigned_Deputy__c = de.Id;
        cm.Employer__c = a.Id;
        cm.Office__c = office.Id;
        cm.RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert cm;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId();
        vt.Active__c = true;
        insert vt;
        
        Assessments__c assess = new Assessments__c();
        assess.Case_Management__c = cm.Id;
        assess.RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId();
        insert assess;
        
        DIR_Violation__c caseIssue = new DIR_Violation__c();
        caseIssue.Violation_Type__c = vt.Id;
        caseIssue.Case__c = cm.Id;
        caseIssue.Assessment__c = assess.Id;
        caseIssue.Citation_Amount__c = 1000;
        caseIssue.Wages_Due__c = 500;
        caseIssue.Total_Interest_Amount__c = 500;
        caseIssue.Status__c = 'Open';
        caseIssue.RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId();
        insert caseIssue;

        Liability__c lia1 = new Liability__c();
        lia1.Assessment__c = assess.Id;
        lia1.RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert lia1;
        
        Liable_Party__c liabParty = new Liable_Party__c(
            Liability__c = lia1.Id,
            Entity__c = a.Id
        );
        insert liabParty; 
        
        Payment_Plan__c pp = new Payment_Plan__c(
            Case__c = cm.Id
        );
        insert pp;
        
        Judgement__c jgmt = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA'
        );
        insert jgmt;
    
        Liability_Judgement__c lj = new Liability_Judgement__c(
            Judgement__c = jgmt.Id,
            Liable_Party__c = liabParty.Id
        );
        insert lj;
        
        
        test.startTest();
        
        DIR_Case__c testCM = [SELECT Id, Name, Employer__c, Employer__r.Id, Assigned_Deputy__r.Manager__r.Id,
                            (SELECT Id, Name, Payment_Amount__c
                                FROM Case_Payments__r),
                            (SELECT Id, Name
                                FROM Payment_Plans__r)
                            FROM DIR_Case__c];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testCM);
        PageReference pageRef = Page.PartyPaymentVFP;
        pageRef.getParameters().put('caseId', String.valueOf(testCM.Id));
        Test.setCurrentPage(pageRef);
        
        
        //Util u = new Util();
        System.assertEquals(Util.skipTrigger(), false);
        
        Test.stopTest();
    }/*
    
    @isTest
    static void testSelectAllById(){
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        insert employer;
        
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
        
        Office__c office = new Office__c(
            Name = 'Bakersfield BOFE',
            Office_Number__c = 'BOFE 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert office;
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = office.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert cm;
        
        Case_Payment__c cp = new Case_Payment__c(
            Case__c = cm.Id,
            Payment_Received_Date__c = Date.today(),
            Payment_Amount__c = 2.00
        );
        insert cp;
        
        Liability_Payment__c lp = new Liability_Payment__c(
            Case_Payment__c = cp.Id
        );
        insert lp;

        Test.startTest();
        
        Util u = new Util();
        Case_Payment__c testCP = (Case_Payment__c)u.selectAllById('Case_Payment__c', cp.Id)[0];
        for(Liability_Payment__c testLP : testCP.Liability_Payments__r){
            System.assertEquals(testLP.Id, lp.Id);
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testQueryStarByObjectNameAndId(){
        
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        insert employer;
        
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
        
        Office__c office = new Office__c(
            Name = 'Bakersfield BOFE',
            Office_Number__c = 'BOFE 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert office;
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = office.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert cm;
        
        Case_Payment__c cp = new Case_Payment__c(
            Case__c = cm.Id,
            Payment_Received_Date__c = Date.today(),
            Payment_Amount__c = 2.00
        );
        insert cp;
        
        Test.startTest();
        
        Util u = new Util();
        
        List<String> fields = new List<String>{'Name', 'Payment_Amount__c'};
        
        //                             String sObjectName, String idType, String idValue, List<String> additionalFields, String OrderBy, Integer recordLimit
        Case_Payment__c testCP = (Case_Payment__c)u.queryStarByObjectNameAndId('Case_Payment__c', 'Id', cp.Id, fields, 'DESC', 1)[0];
        
        System.assertEquals(testCP.Payment_Amount__c, cp.Payment_Amount__c);
        Test.stopTest();
        
    }*/
}