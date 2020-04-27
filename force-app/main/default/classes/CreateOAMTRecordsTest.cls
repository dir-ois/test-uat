/*************************************************************************************************
Class     :  CreateOAMTRecordsTest.cls
Created   :  July 30, 2019
Modified  :  
Objective :  Obvious test class is obvious.

*************************************************************************************************/
@isTest
public class CreateOAMTRecordsTest{
    
    static testmethod void test(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettings.add(cpTriggerSetting);
        insert triggerSettings;

        
        
        Date today = Date.parse('08/01/2019');
        Date firstOfPreviousMonth = today.addMonths(-1).toStartOfMonth(); //first day of the month that the OAMT records are created FOR
        Date lastOfPreviousMonth = Date.newInstance(firstOfPreviousMonth.year(), firstOfPreviousMonth.month(), Date.daysInMonth(firstOfPreviousMonth.year(), firstOfPreviousMonth.month()));
        Date firstOf2MonthsPrevious = firstOfPreviousMonth.addMonths(-1).toStartOfMonth();
        Date lastOf2MonthsPrevious = Date.newInstance(firstOf2MonthsPrevious.year(), firstOf2MonthsPrevious.month(), Date.daysInMonth(firstOf2MonthsPrevious.year(), firstOf2MonthsPrevious.month()));

        DIR_Employee__c SrDep = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert SrDep;
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Manager__c = SrDep.Id
        );
        insert deputy;
        
        Account acct = new Account(
            Name = 'Fred Flintstone'
        );
        insert acct;
        
        DIR_Case__c CM = new DIR_Case__c(
            Employer__c = acct.Id,
            Assigned_Deputy__c = deputy.Id, 
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Status__c = 'Judgment Issued',
            Case_Closed_Date__c = date.today(),
            Purge_Date__c = date.today() + 1,
            Case_Number__c = '123'
        );
        insert CM;
        
        Case_Role__c caseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = CM.Id,
            Entity__c = acct.Id,
            Role__c = 'Employee',
            Case_Role_Status__c = 'Active'
        );
        insert caseRole;
        
        Payee__c payee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100,
            Payee_Type__c = 'Employee',
            Case_Management__c = CM.Id,
            Case_Role__c = caseRole.Id
        );
        insert payee;
        
        Office__c office = new Office__c(
            Name = 'Sacramento CCU'
        );
        insert office;
        
        Office_Account__c OA = new Office_Account__c(
            Name = '32-117',
            Office__c = office.Id
        );
        insert OA;
        
        Transaction__c TRN = new Transaction__c(
            Office_Account__c = OA.Id,
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 66.66,
            Business_Unit__c = 'CCU',
            Check_Count__c = 1,
            Checks_Amount__c = 66.66,
            Treasury_Deposit_Number__c = 'elasticbands',
            Deposit_Date__c = Date.parse('07/16/2019')
        );
        insert TRN;
        
        Receipt__c RCT = new Receipt__c(
            Date_Received__c = Date.parse('07/15/2019'),
            Payment_Amount__c = 66.66,
            Instrument_Number__c = 'dobedobedo',
            Payment_Exchange__c = 'Division Payment',
            Payment_Type__c = 'Check',
            Office_Unit__c = 'CCU 32',
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Can_Be_Processed__c = true,
            Senior_Deputy__c = SrDep.Id,
            Transaction__c = TRN.Id
        );
        insert RCT;
        
        Check_Batch__c CB = new Check_Batch__c(
            Office_Account__c = OA.Id,
            Status__c = 'Printed'
        );
        insert CB;
        
        Check__c check = new Check__c(
            RecordTypeId = Schema.SObjectType.Check__c.getRecordTypeInfosByName().get('Check Approved').getRecordTypeId(),
            Check_Batch__c = CB.Id,
            Amount__c = 66.66,
            Office_Account__c = OA.Id,
            Payee__c = payee.Id,
            Status__c = 'Printed',
            Issue_Date__c = Date.parse('07/16/2019')
        );
        insert check;
        
        Office_Account_Monthly_Totals__c oldOAMT = new Office_Account_Monthly_Totals__c(
            Office_Account__c = OA.Id,
            Date__c = Date.parse('06/30/2019'),
            Prior_Month_Starting_Balance__c = 0.00,
            Deposited_Receipts__c = 77.77
        );
        insert oldOAMT;
        
        
        Test.startTest();
        
        CreateOAMTRecords coamtr = new CreateOAMTRecords();
        coamtr.CreateOAMTRecords();
        
        //Office_Account_Monthly_Totals__c newOAMT = [SELECT Id, Name, Date__c, Ending_Balance__c
        //                                              FROM Office_Account_Monthly_Totals__c
        //                                              WHERE Date__c = :lastOfPreviousMonth][0];
        
        //System.assertEquals(newOAMT.Ending_Balance__c, oldOAMT.Ending_Balance__c); //one RCT for $66.66, one Check for $66.66, balance should still be the $77.77 from the previous OAMT.
        System.assertEquals(coamtr.OAMTsToInsert[0].Ending_Balance__c, oldOAMT.Ending_Balance__c);
        
        Test.stopTest();
        
    }
}