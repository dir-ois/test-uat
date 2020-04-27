@isTest 
public class DisplayCheckRecordsControllerTest 
{
    static testMethod void testMethod1() 
    {
        Test.StartTest(); 
        
        pageReference displayCheckRecords= Page.DisplayCheckRecords;
        
        Test.setCurrentPage(displayCheckRecords);
        
        Account a = new Account(
            Name = 'Test Account'
        );
        insert a;
         
        DIR_Employee__c employeeMgr = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert employeeMgr;
        
        DIR_Employee__c employee = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Manager__c = employeeMgr.Id
        );
        insert employee;
     
        Office__c office = new Office__c(
            Name = 'test office'
        );
        insert office;
        
        Office_Account__c officeAccount = new Office_Account__c(
            Name = 'test office account',
            Office__c = office.id
        );
        insert officeAccount;
        
        DIR_Case__c caseMgmt = new DIR_Case__c(
            Employer__c = a.Id,
            Assigned_Deputy__c = employee.Id
        );
        insert caseMgmt;
        
        Case_Role__c caseRole = new Case_Role__c(
            Case_Role_Status__c = 'Active',
            Case__c = caseMgmt.Id,
            IsPersonAccount__c = false,
            Entity__c = a.Id
        );
        insert caseRole;
        
        Payee__c payee = new Payee__c(
            Case_Management__c = caseMgmt.Id,
            Case_Role__c = caseRole.Id,
            Factor__c = 100,
            Payee_Type__c = 'Employee',
            Status__c = 'Unverified'
        );
        insert payee;
        
        Check_Batch__c cb = new Check_Batch__c(
        Requesting_Cashier__c = employee.id,
        Office_Account__c= officeAccount.id
        );
        insert cb;
        
        Check__c cl= new Check__c(
        Check_Number__c ='58787',
        Check_Batch__c = cb.id,
        Office_Account__c = officeAccount.id,
        Status_Date__c = Date.today(),
        Status__c = 'Approved'
        );
        insert cl;
        
        Check__c cl2= new Check__c(
        Check_Number__c ='87878',
        Check_Batch__c = cb.id,
        Office_Account__c = officeAccount.id,
        Status_Date__c = Date.today(),
        Status__c = 'Not Approved'
        );
        insert cl2;
           
        
        DisplayCheckRecordsController testAccPlan = new DisplayCheckRecordsController();
        testAccPlan.runMethod(); 
        testAccPlan.DisplayCheckRecordsController();
        system.assertEquals(testAccPlan.today,Date.today());
        Test.StopTest();
    }
    
    }