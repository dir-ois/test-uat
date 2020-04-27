@istest
public class referralAssignmentAllTest {

    public static testMethod void referralAssignmentTest(){
        
          test.startTest();
        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;
        
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
        //emp.Deputy_Number__c = '1122';
        emp.Title__c = 'Deputy Labor Commissioner';
        emp.Position__c = 'Deputy';
        emp.Office__c = off.Id;
        emp.Email__c = 'test_emp@email.com';
        emp.Manager__c = emp1.Id;
        emp.User__c = userInfo.getUserId();
        insert emp;
        
        DIR_Employee__c emp2 = new DIR_Employee__c();
        emp2.Active__c = true;
        //emp.Deputy_Number__c = '1122';
        emp2.Title__c = 'Attorney';
        emp2.Position__c = 'Legal';
        emp2.Office__c = off.Id;
        emp2.Email__c = 'test_emp@email.com';
        emp2.Manager__c = emp1.Id;
        emp2.User__c = userInfo.getUserId();
        insert emp2;
        
        DIR_Case__c c = new DIR_Case__c();
        c.Assigned_Deputy__c = emp.Id;
        c.Employer__c = acc.Id;
        insert c;
        
       
        RecordType rtReffid = [Select Id From RecordType Where SobjectType = 'Referral__c' and Name = 'BOFE Request for Legal Services'];
        
        Referral__c r = new Referral__c();
        r.Case__c = c.Id;
        r.Referring_Deputy__c=emp2.id;
        r.RecordTypeId = rtReffid.Id;
        r.Type_of_Request__c = 'Consultation - Citation';
        r.Request_Description__c = 'test';
        r.Request_Status__c = 'Request Approved';
        
        insert r;
        
        Referral_Assignment__c ra = new Referral_assignment__c();
        ra.Referral__c = r.Id;
        ra.Assigned_Employee__c = emp2.id;
        ra.Currently_Assigned__c = true;
     	ra.Employee_Email__c = 'test@xyz.com';
        ra.Deputy_Email__c='test1@xyz.com';
      
        insert ra;
        test.stopTest();
        
        
    }
}