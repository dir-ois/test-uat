@isTest(SeeAllData=false)
public with sharing class RLCVAllTest {

    private static testmethod void testUpdateRLCV(){
        
        String recordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name = 'BOFE Intake'].Id;
        
        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE Intake, BOFE Investigation';
        insert kvs;
        
        List<Account> accountList = new List<Account>();

        Account acc = new Account();
        acc.Name = 'name';
        accountList.add(acc);

        Account acc2 = new Account();
        acc2.Name = 'name2';
        AccountList.add(acc2);

        insert accountList;

        DIR_Employee__c mgr = new DIR_Employee__c();
        mgr.User__c = userinfo.getuserid();
        mgr.Active__c = true;
        mgr.Email__c = 'mgr@test.com';
        mgr.Phone__c = '2223335555';
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = userinfo.getuserid();
        de.Active__c = true;
        de.Email__c = 'dep@test.com';
        de.Phone__c = '2223335555';
        de.Manager__c = mgr.id;
        insert de;

        List<DIR_Case__c> caseList = new List<DIR_Case__c>();   
        
        DIR_Case__c dc = new DIR_Case__c();
        dc.Employer__c = acc.Id;
        dc.RecordTypeId = recordType;
        dc.Assigned_Deputy__c = de.Id;
        caseList.add(dc);
        
        DIR_Case__c dc2 = new DIR_Case__c();
        dc2.Employer__c = acc2.Id;
        dc2.RecordTypeId = recordType;
        dc2.Assigned_Deputy__c = de.Id;
        caseList.add(dc2);

        insert caseList;
        
        Wage_Claim__c cw = new Wage_Claim__c();
        cw.Last_Name__c = 'test';
        insert cw;
        
        Report_of_Labor_Code_Violation__c rlcv = new Report_of_Labor_Code_Violation__c();
        rlcv.DIR_Case__c = dc.Id;
        rlcv.Account__c = acc.Id;
        rlcv.Source__c = 'Community Group Referral';
        rlcv.Child_Labor_Violations__c = 'No valid work permit(s)';
        rlcv.No_number_of_minors_affected__c = 5;
        rlcv.Wage_Claim__c = cw.Id;
        insert rlcv;
        
        test.startTest();

        rlcv.Account__c = acc2.Id;
        update rlcv;
        
        Report_of_Labor_Code_Violation__c rlcv2 = [SELECT Id, DIR_Case__c FROM Report_of_Labor_Code_Violation__c WHERE Id =: rlcv.Id];
        DIR_Case__c dc3 = [SELECT Id FROM DIR_Case__c WHERE Id =: dc2.Id];
        system.assertEquals(rlcv2.DIR_Case__c, dc3.Id);

        test.stopTest();
        
    }
    
    private static testmethod void testUpdateRLCVWithInspections(){
        
        String recordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name = 'BOFE Investigation'].Id;
        
        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE Intake, BOFE Investigation';
        insert kvs;

        List<Account> accountList = new List<Account>();
        
        Account acc = new Account();
        acc.Name = 'name';
        accountList.add(acc);

        Account acc2 = new Account();
        acc2.Name = 'name2';
        accountList.add(acc2);

        insert accountList;
        
        DIR_Employee__c mgr = new DIR_Employee__c();
        mgr.User__c = userinfo.getuserid();
        mgr.Active__c = true;
        mgr.Email__c = 'mgr@test.com';
        mgr.Phone__c = '2223335555';
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = userinfo.getuserid();
        de.Active__c = true;
        de.Email__c = 'dep@test.com';
        de.Phone__c = '2223335555';
        de.Manager__c = mgr.id;
        insert de;

        List<DIR_Case__c> caseList = new List<DIR_Case__c>();
        
        DIR_Case__c dc = new DIR_Case__c();
        dc.Employer__c = acc.Id;
        dc.RecordTypeId = recordType;
        dc.Assigned_Deputy__c = de.Id;
        caseList.add(dc);
        
        DIR_Case__c dc2 = new DIR_Case__c();
        dc2.Employer__c = acc2.Id;
        dc2.RecordTypeId = recordType;
        dc2.Assigned_Deputy__c = de.Id;
        caseList.add(dc2);

        insert caseList;
        
        DIR_Inspection__c insp = new DIR_Inspection__c();
        insp.DIR_Case__c = dc2.Id;
        insert insp;
        
        Report_of_Labor_Code_Violation__c rlcv = new Report_of_Labor_Code_Violation__c();
        rlcv.DIR_Case__c = dc.Id;
        rlcv.Account__c = acc.Id;
        rlcv.Source__c = 'Community Group Referral';
        rlcv.Child_Labor_Violations__c = 'No valid work permit(s)';
        rlcv.No_number_of_minors_affected__c = 5;
        insert rlcv;
        
        test.startTest();

        checkRecursive.run = true;
        rlcv.Account__c = acc2.Id;
        update rlcv;
        
        DIR_Case__c dc3 = [SELECT Id, Status__c FROM DIR_Case__c WHERE Id =: dc2.Id];
        Report_of_Labor_Code_Violation__c rlcv2 = [SELECT Id, DIR_Case__c FROM Report_of_Labor_Code_Violation__c WHERE Id =: rlcv.Id];
        system.assertEquals(rlcv2.DIR_Case__c, dc3.Id);

        test.stopTest();
        
    }
    
    private static testmethod void testUpdateCaseAfterMovingRLCV(){
        
        String recordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name = 'BOFE Intake'].Id;
        
        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE Intake, BOFE Investigation';
        insert kvs;
        
        Account acc = new Account();
        acc.Name = 'name';
        insert acc;
        
        DIR_Employee__c mgr = new DIR_Employee__c();
        mgr.User__c = userinfo.getuserid();
        mgr.Active__c = true;
        mgr.Email__c = 'mgr@test.com';
        mgr.Phone__c = '2223335555';
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = userinfo.getuserid();
        de.Active__c = true;
        de.Email__c = 'dep@test.com';
        de.Phone__c = '2223335555';
        de.Manager__c = mgr.id;
        insert de;
        
        List<DIR_Case__c> caseList = new List<DIR_Case__c>();

        DIR_Case__c dc = new DIR_Case__c();
        dc.Employer__c = acc.Id;
        dc.RecordTypeId = recordType;
        dc.Assigned_Deputy__c = de.Id;
        caseList.add(dc);
        
        DIR_Case__c dc2 = new DIR_Case__c();
        dc2.Employer__c = acc.Id;
        dc2.RecordTypeId = recordType;
        dc2.Assigned_Deputy__c = de.Id;
        caseList.add(dc2);

        insert caseList;
        
        Report_of_Labor_Code_Violation__c rlcv = new Report_of_Labor_Code_Violation__c();
        rlcv.DIR_Case__c = dc.Id;
        rlcv.Account__c = acc.Id;
        rlcv.Source__c = 'Community Group Referral';
        rlcv.Child_Labor_Violations__c = 'No valid work permit(s)';
        rlcv.No_number_of_minors_affected__c = 5;
        rlcv.No_Workers_Compensation_Insurance__c = true;
        rlcv.Minimum_Wage_Violations__c = 'Paid below minimum wage';
        rlcv.Unpaid_Overtime_Violations__c = 'Over 8 hours/day or (10 hours/day-farm)';
        rlcv.Pay_Stub_Violations__c = 'Paid by Cash or No wage statement';
        rlcv.Meal_Period_Violations__c = 'No 30-minute off-duty meal period';
        insert rlcv;
        
        test.startTest();

        rlcv.DIR_Case__c = dc2.Id;
        update rlcv;
        
        DIR_Case__c dc3 = [SELECT Id, Status__c FROM DIR_Case__c WHERE Id =: dc.Id];
        system.assertEquals(dc3.Status__c, 'No Citations or Other Issues');     
        
        dc.Status__c = 'New';
        dc.RecordTypeId = recordType;
        update dc;
    
        Report_of_Labor_Code_Violation__c rlcv2 = new Report_of_Labor_Code_Violation__c();
        rlcv2.DIR_Case__c = dc.Id;
        rlcv2.Account__c = acc.Id;
        rlcv2.Source__c = 'Community Group Referral';
        rlcv2.Child_Labor_Violations__c = 'No valid work permit(s)';
        rlcv2.No_number_of_minors_affected__c = 5;
        rlcv2.No_Workers_Compensation_Insurance__c = true;
        rlcv2.Minimum_Wage_Violations__c = 'Paid below minimum wage';
        rlcv2.Unpaid_Overtime_Violations__c = 'Over 8 hours/day or (10 hours/day-farm)';
        rlcv2.Pay_Stub_Violations__c = 'Paid by Cash or No wage statement';
        rlcv2.Meal_Period_Violations__c = 'No 30-minute off-duty meal period';
        insert rlcv2;
    
        Report_of_Labor_Code_Violation__c rlcv3 = new Report_of_Labor_Code_Violation__c();
        rlcv3.DIR_Case__c = dc.Id;
        rlcv3.Account__c = acc.Id;
        rlcv3.Source__c = 'Community Group Referral';
        rlcv3.Child_Labor_Violations__c = 'No valid work permit(s)';
        rlcv3.No_number_of_minors_affected__c = 5;
        rlcv3.No_Workers_Compensation_Insurance__c = true;
        rlcv3.Minimum_Wage_Violations__c = 'Paid below minimum wage';
        rlcv3.Unpaid_Overtime_Violations__c = 'Over 8 hours/day or (10 hours/day-farm)';
        rlcv3.Pay_Stub_Violations__c = 'Paid by Cash or No wage statement';
        rlcv3.Meal_Period_Violations__c = 'No 30-minute off-duty meal period';
        rlcv3.Violation_No_valid_work_permit_s__c = true;
        rlcv3.How_are_Employees_Paid__c = 'Cash';
        rlcv3.Violation_Paid_check_cash_WO_itemize__c = true;
        rlcv3.Violation_30_minute_off_duty_meal_period__c = true;
        rlcv3.Violation_Paycheck_issued_with_ISF__c = true;
        rlcv3.Violation_Paid_below_minimum_wage__c = true;
        rlcv3.Violation_Not_Paid_OT_Over_8_hours__c = true;
        rlcv3.Source__c = 'LC 2699';
        insert rlcv3;
    
        rlcv2.DIR_Case__c = dc2.Id;
        update rlcv2;
    
        DIR_Case__c dc4 = [SELECT Id, Status__c FROM DIR_Case__c WHERE Id =: dc.Id];
        system.assertEquals(dc4.Status__c, 'New');
        
        test.stopTest();
    }
    
    private static testmethod void testUpdateCaseFields(){
        
        String recordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name = 'BOFE Intake'].Id;
        
        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE Intake, BOFE Investigation';
        insert kvs;
        
        Account acc = new Account();
        acc.Name = 'name';
        insert acc;
        
        DIR_Employee__c mgr = new DIR_Employee__c();
        mgr.User__c = userinfo.getuserid();
        mgr.Active__c = true;
        mgr.Email__c = 'mgr@test.com';
        mgr.Phone__c = '2223335555';
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = userinfo.getuserid();
        de.Active__c = true;
        de.Email__c = 'dep@test.com';
        de.Phone__c = '2223335555';
        de.Manager__c = mgr.id;
        insert de;
        
        test.startTest();

        DIR_Case__c dc = new DIR_Case__c();
        dc.Employer__c = acc.Id;
        dc.RecordTypeId = recordType;
        dc.Assigned_Deputy__c = de.Id;
        insert dc;
        
        Report_of_Labor_Code_Violation__c rlcv = new Report_of_Labor_Code_Violation__c();
        rlcv.DIR_Case__c = dc.Id;
        rlcv.Account__c = acc.Id;
        rlcv.Source__c = 'Community Group Referral';
        rlcv.Child_Labor_Violations__c = 'No valid work permit(s)';
        rlcv.No_number_of_minors_affected__c = 5;
        rlcv.No_Workers_Compensation_Insurance__c = true;
        rlcv.Minimum_Wage_Violations__c = 'Paid below minimum wage';
        rlcv.Unpaid_Overtime_Violations__c = 'Over 8 hours/day or (10 hours/day-farm)';
        rlcv.Pay_Stub_Violations__c = 'Paid by Cash or No wage statement';
        rlcv.Meal_Period_Violations__c = 'No 30-minute off-duty meal period';
        
        insert rlcv;
        
        DIR_Case__c dc2 = [SELECT Id, Worker_s_Comp_Violation__c FROM DIR_Case__c WHERE Id =: dc.Id];
        system.assertEquals(dc2.Worker_s_Comp_Violation__c, true);

        test.stopTest();
        
    }
    
    @isTest static void testAddCasePriortity(){
        String recordTypeBOFE = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name = 'BOFE Investigation'].Id;
        String recordTypePAGA = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name = 'PAGA Case'].Id;
        
        List<Account> accountList = new List<Account>();
        Account acc = new Account(
            Name = 'test account',
            Low_wage_Industry__c = 'Yes'
        );
        accountList.add(acc);
        
        Account acc2 = new Account(
            Name = 'test account',
            Low_wage_Industry__c = 'No'
        );
        accountList.add(acc2);
        
        insert accountList;
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            User__c = userinfo.getuserid(),
            Active__c = true,
            Email__c = 'mgr@test.com',
            Phone__c = '2223335555'
        );
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c(
            User__c = userinfo.getuserid(),
            Active__c = true,
            Email__c = 'dep@test.com',
            Phone__c = '2223335555',
            Manager__c = mgr.id
        );
        insert de;
        
        List<DIR_Case__c> caseList = new List<DIR_Case__c>();
        DIR_Case__c dcClosed = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc.Id,
            RecordTypeId = recordTypeBOFE,
            Assigned_Deputy__c = de.Id,
            Case_Closed_Date__c = date.today()
        );
        caseList.add(dcClosed);
        
        DIR_Case__c dc0 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc0);
        
        DIR_Case__c dc1 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc1);
        
        DIR_Case__c dc2 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc2);
        
        DIR_Case__c dc3 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc3);
        
        DIR_Case__c dc4 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc4);
        
        DIR_Case__c dc5 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc5);
        
        DIR_Case__c dc6 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc6);
        
        DIR_Case__c dc7 = new DIR_Case__c(
            Low_wage_Industry__c = 'Yes',
            PAGA_entered_Industry__c = 'Agriculture',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc7);
        
        DIR_Case__c dc8 = new DIR_Case__c(
            Low_wage_Industry__c = 'No',
            PAGA_entered_Industry__c = 'Other-Not-Low-Wage',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc8);
        
        DIR_Case__c dc9 = new DIR_Case__c(
            Low_wage_Industry__c = 'No',
            PAGA_entered_Industry__c = 'Other-Not-Low-Wage',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc9);
        
        DIR_Case__c dc10 = new DIR_Case__c(
            Low_wage_Industry__c = 'No',
            PAGA_entered_Industry__c = 'Other-Not-Low-Wage',
            Employer__c = acc2.Id,
            RecordTypeId = recordTypePAGA,
            Assigned_Deputy__c = de.Id,
            Status__c = 'Other'
        );
        caseList.add(dc10);
        
        insert caseList;
        
        List<Id> caseIds = new List<Id>();
        for(DIR_Case__c dc : caseList){
            caseIds.add(dc.Id);
        }
        
        test.startTest();
        List<Report_of_Labor_Code_Violation__c> rlcvList = new List<Report_of_Labor_Code_Violation__c>();
        
        Report_of_Labor_Code_Violation__c rlcvAny = new Report_of_Labor_Code_Violation__c( //priority 1
            DIR_Case__c = dcClosed.Id,
            Account__c = acc.Id
        );
        rlcvList.add(rlcvAny);
        
        Report_of_Labor_Code_Violation__c rlcv1 = new Report_of_Labor_Code_Violation__c( //priority 1
            DIR_Case__c = dc1.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_Minimum_Wage__c = true
        );
        rlcvList.add(rlcv1);
        
        Report_of_Labor_Code_Violation__c rlcv0 = new Report_of_Labor_Code_Violation__c( //priority 2
            DIR_Case__c = dc0.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 30,
            PAGA_Minimum_Wage__c = true
        );
        rlcvList.add(rlcv0);
        
        Report_of_Labor_Code_Violation__c rlcv2 = new Report_of_Labor_Code_Violation__c( //priority 3
            DIR_Case__c = dc2.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_No_Workers_Compensation__c = true
        );
        rlcvList.add(rlcv2);
        
        Report_of_Labor_Code_Violation__c rlcv3 = new Report_of_Labor_Code_Violation__c( //priority 4
            DIR_Case__c = dc3.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_Meal_and_Rest_Breaks__c = true
        );
        rlcvList.add(rlcv3);
        
        Report_of_Labor_Code_Violation__c rlcv4 = new Report_of_Labor_Code_Violation__c( //priority 4
            DIR_Case__c = dc4.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_Independent_Contractor__c = true
        );
        rlcvList.add(rlcv4);
       
        Report_of_Labor_Code_Violation__c rlcv5 = new Report_of_Labor_Code_Violation__c( //priority 3
            DIR_Case__c = dc5.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_Improper_or_Inc_Wage_Statements__c = true
        );
        rlcvList.add(rlcv5);
         
        Report_of_Labor_Code_Violation__c rlcv6 = new Report_of_Labor_Code_Violation__c( //priority 5
            DIR_Case__c = dc6.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 30,
            PAGA_Improper_or_Inc_Wage_Statements__c = true
        );
        rlcvList.add(rlcv6);
        
        Report_of_Labor_Code_Violation__c rlcv7 = new Report_of_Labor_Code_Violation__c( //priority 5
            DIR_Case__c = dc7.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 30,
            PAGA_Meal_and_Rest_Breaks__c = true
        );
        rlcvList.add(rlcv7);
        
        Report_of_Labor_Code_Violation__c rlcv8 = new Report_of_Labor_Code_Violation__c( //priority 6
            DIR_Case__c = dc8.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_Overtime__c = true
        );
        rlcvList.add(rlcv8);
        
        Report_of_Labor_Code_Violation__c rlcv9 = new Report_of_Labor_Code_Violation__c( //priority 7
            DIR_Case__c = dc9.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_Improper_form_incl_NSF_check__c = true
        );
        rlcvList.add(rlcv9);
        
        Report_of_Labor_Code_Violation__c rlcv10 = new Report_of_Labor_Code_Violation__c( //priority 8
            DIR_Case__c = dc10.Id,
            Account__c = acc2.Id,
            PAGA_Impacted_Employees__c = 50,
            PAGA_Meal_and_Rest_Breaks__c = true
        );
        rlcvList.add(rlcv10);

        insert rlcvList;
        test.stopTest();
        Map<Id, DIR_Case__c> caseMap = new Map<Id, DIR_Case__c>([SELECT Id, PAGA_Priority__c, Low_wage_Industry__c FROM DIR_Case__c WHERE Id IN: caseIds]);
        
        system.assertEquals(1, caseMap.get(dcClosed.Id).PAGA_Priority__c);
        system.assertEquals(1, caseMap.get(dc1.Id).PAGA_Priority__c);
        system.assertEquals(2, caseMap.get(dc0.Id).PAGA_Priority__c);
        system.assertEquals(3, caseMap.get(dc2.Id).PAGA_Priority__c);
        system.assertEquals(4, caseMap.get(dc3.Id).PAGA_Priority__c);
        system.assertEquals(4, caseMap.get(dc4.Id).PAGA_Priority__c);
        system.assertEquals(3, caseMap.get(dc5.Id).PAGA_Priority__c);
        system.assertEquals(5, caseMap.get(dc6.Id).PAGA_Priority__c);
        system.assertEquals(5, caseMap.get(dc7.Id).PAGA_Priority__c);
        system.assertEquals(6, caseMap.get(dc8.Id).PAGA_Priority__c);
        system.assertEquals(7, caseMap.get(dc9.Id).PAGA_Priority__c);
        system.assertEquals(8, caseMap.get(dc10.Id).PAGA_Priority__c);
    }
}