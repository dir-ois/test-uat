@isTest
public with sharing class CaseViolationAllTest {

    public static testMethod void TestSetAppealDeadline() {
        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1 ];
        
        DIR_Employee__c employee1 = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id
        );
        insert employee1;
        
        DIR_Employee__c employee2 = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id,
            Manager__c = employee1.Id
        );
        insert employee2;
        
        DIR_Case__c cm = new DIR_Case__c();
        cm.Assigned_Deputy__c = employee2.Id;
        insert cm;
        
        Assessments__c assess = new Assessments__c();
        assess.Case_Management__c = cm.Id;
        insert assess;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        insert vt;
        
        DIR_Violation__c viol = new DIR_Violation__c();
        viol.Violation_Type__c = vt.Id;
        viol.Case__c = cm.Id;
        viol.Assessment__c = assess.Id;
        insert viol;
        
        assess = [SELECT Appeal_Deadline_Days__c FROM Assessments__c WHERE Id = :assess.Id];
        System.AssertEquals(12, assess.Appeal_Deadline_Days__c);
        
    }

}