@isTest(SeeAllData=false)
private class JudgmentCreateControllerTest {
    
   static testMethod void testController() {

        Account a = new Account(
            Name = 'testAcct80211'
        );
        insert a;
        
        DIR_Employee__c ma = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = ma.Id
        );
        insert de; 
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = de.Id,
            Employer__c = a.Id
        );
        insert cm;

        Judgement__c j = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA',
            Closed__c = false,
            Judgement_Date__c = date.today(),
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Judgement_Amount__c = 20
        );
        insert j;
        
        test.startTest();

        JudgmentCreateController con = new JudgmentCreateController();
        con.CaseID = cm.Id;
        con.RecordID = j.Id;
        con.JudgmentID = j.Id;
        con.ObjectType = 'Judgement__c';

        //needs to be in try/catch until they support flow testing

        try{
            con.getJudgment();
        }
        catch(exception s){
            //Error derived from inability to properly test flows from apex
        }
        
        test.stopTest();

    }   
    
   static testMethod void testController2() {
        
        PageReference pageRef = Page.CreateJudgmentFromSettlement;
        
        Account a = new Account(
            Name = 'testAcct80211'
        );
        insert a;
        
        DIR_Employee__c ma = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = ma.Id
        );
        insert de; 
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = de.Id,
            Employer__c = a.Id
        );
        insert cm;
 
        Assessments__c ast = new Assessments__c(
            Case_Management__c = cm.Id,
            Appeal_Deadline_Selector__c = 'Business Days',
            Total_Citation_Penalties_Assessed__c = 5000,
            Total_Wages_Assessed__c = 1000,
            Total_Interest_Assessed__c = 500
        );
        insert ast;
        
        Liability__c lia = new Liability__c(
            Case_Management__c = cm.Id,
            Assessment__c = ast.Id
            //Total_Penalties_Assessed__c = ast.Total_Citation_Penalties_Assessed__c,
            //Total_Wages_Assessed__c = ast.Total_Wages_Assessed__c,
            //Total_Interest_Assessed__c = ast.Total_Interest_Assessed__c
        );
        insert lia;
/*        
         Judgement__c j = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'JEU',
            Liability__c = lia.id,
            Closed__c = false,
            Judgement_Date__c = date.today(),
            Status__c = 'Pending/Open',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId(),
            Judgement_Amount__c = 6500
        );
        insert j;
*/        
        Test.startTest();
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('vCaseId',cm.id);
        pageRef.getParameters().put('varRecordId',lia.id);
        pageRef.getParameters().put('vObjectType','Liability');
        pageRef.getParameters().put('varPenalties','$5000');
        pageRef.getParameters().put('varWages','$1000');
        pageRef.getParameters().put('varInterest','$500');
        
        JudgmentCreateController judcon = new JudgmentCreateController();
        judcon.getJudgment();
        Test.stopTest();
        
    }
}