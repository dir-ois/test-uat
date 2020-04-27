@isTest
public with sharing class CasePaymentAllTest {

    public static testMethod void TestPaymentPlanRollUp() {
        
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
        
        Account a = new Account(
            Name = '12thStOaklandBART'
        );
        insert a;
        
        DIR_Employee__c srDeputy = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert srDeputy; 
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = srDeputy.Id
        );
        insert deputy; 
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id
        );
        insert cm;
        
        Payment_Plan__c pp = new Payment_Plan__c(
            Frequency__c ='Semi-monthly',
            Payment_Plan_Day_of_Month_Payment_Due__c = 7,
            Days_of_Semi_Monthly_Payment_Due__c = '10',
            Payment_Plan_Status__c = 'Current',
            Number_of_Payments__c = 2.0,
            Payment_Plan_Total_Amount_Due__c = 150,
            Total_Payment_Amount__c = 500,
            Due_Date__c=date.today().addDays(60),
            Case__c = cm.Id
        );
        insert pp;
        
        Office__c office = new Office__c(
            Name = 'Sacramento CCU',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        insert office;
        
        Office_Account__c officeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = office.Id
        );
        insert officeAccount;
        
        office.Office_Account__c = officeAccount.Id;
        update office;
        
        Transaction__c trn = new Transaction__c(
            Office_Account__c = officeAccount.Id,
            Deposit_Date__c = Date.today() - 7,
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 2500,
            Check_Count__c = 2,
            Checks_Amount__c = 2500,
            Treasury_Deposit_Number__c = 'jeremiahwasabullfrog'
        );
        insert trn;
        
        Receipt__c rct1 = new Receipt__c(
            Payor__c = a.Id,
            Deposit_Account__c = '32-117',
            Date_Received__c = Date.today() - 14,
            Payment_Amount__c = 1000,
            Transaction__c = trn.Id,
            Instrument_Number__c = 'nowhereman',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank'
        );
        insert rct1;
        
        
        Case_Payment__c cp1 = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Receipt__c = rct1.Id,
            Payment_Amount__c = 1000,
            Payment_Plan__c = pp.Id,
            Status__c = 'Posted'
        );
        insert cp1;

        Receipt__c rct2 = new Receipt__c(
            Payor__c = a.Id,
            Deposit_Account__c = '32-117',
            Date_Received__c = Date.today() - 14,
            Payment_Amount__c = 1500,
            Transaction__c = trn.Id,
            Instrument_Number__c = 'letitbe',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank'
        );
        insert rct2;
        
        
        Case_Payment__c cp2 = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Receipt__c = rct2.Id,
            Payment_Amount__c = 1500,
            Payment_Plan__c = pp.Id,
            Status__c = 'Posted'
        );
        insert cp2;

        pp = [SELECT Total_payment_Amount__c FROM Payment_Plan__c WHERE Id = :pp.Id];
        System.assertEquals(2500, pp.Total_payment_Amount__c);
        
        rct2.Payment_Amount__c = 2500;
        update rct2;
        cp2.Payment_Amount__c = 2500;
        update cp2;
        
        pp = [SELECT Total_payment_Amount__c FROM Payment_Plan__c WHERE Id = :pp.Id];
        System.assertEquals(3500, pp.Total_payment_Amount__c);
        
        delete cp1;
        
        pp = [SELECT Total_payment_Amount__c FROM Payment_Plan__c WHERE Id = :pp.Id];
        System.assertEquals(2500, pp.Total_payment_Amount__c);
    }
}