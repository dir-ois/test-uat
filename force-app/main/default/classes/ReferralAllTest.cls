@isTest
public with sharing class ReferralAllTest {
    
    
    public static testMethod void TestReferralAll() {

        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Office__c off = new Office__c();
        off.Name = 'Test Office';
        insert off;
        
        DIR_Employee__c emp1 = new DIR_Employee__c();
        emp1.Active__c = true;
        //emp1.Deputy_Number__c = '1122';
        emp1.Title__c = 'Deputy Labor Commissioner';
        emp1.Position__c = 'Senior Deputy';
        emp1.Office__c = off.Id;
        emp1.Email__c = 'test_emp@email.com';
        emp1.User__c = UserInfo.getUserId();
        insert emp1;
        
        DIR_Employee__c emp = new DIR_Employee__c();
        emp.Active__c = true;
        emp.User__c = userInfo.getUserId();
        //emp.Deputy_Number__c = '1122';
        emp.Title__c = 'Deputy Labor Commissioner';
        emp.Position__c = 'Deputy';
        emp.Office__c = off.Id;
        emp.Email__c = 'test_emp@email.com';
        emp.Manager__c = emp1.Id;
        insert emp;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Assigned_Deputy__c = emp.Id;
        c.Employer__c = acc.Id;
        insert c;
        
        RecordType rtReffid = [Select Id From RecordType Where SobjectType = 'Referral__c' and Name = 'BOFE Civil Litigation Referral'];
        
        Referral__c r = new Referral__c();
        r.Case__c = c.Id;
        r.RecordTypeId = rtReffid.Id;
        r.Type_of_Request__c = 'Consultation - Citation';
        r.Request_Description__c = 'test';
        r.Request_Status__c = 'Pending Approval';
        insert r;
        
        Referral__c ref = [SELECT Id FROM Referral__c WHERE Id =: r.Id];
        ref.Request_Status__c = 'Request Sent';
        update ref;
        
    }
}