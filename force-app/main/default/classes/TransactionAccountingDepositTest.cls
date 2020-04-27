/*************************************************************************************************
TransactionAccountingDepositTest - tests TransactionDIRTrigger, TransactionMethods and AccountingDepositBatch classes
*************************************************************************************************/

@isTest
public class TransactionAccountingDepositTest{
    
    @isTest
    public static void testAccountingDepositBatch(){
        
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
        
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
        
        Office__c WCAoffice = new Office__c(
            Name = 'Bakersfield WCA',
            Office_Number__c = 'WCA 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert WCAoffice;
        
        Office_Account__c WCAofficeAccount = new Office_Account__c(
            Name = '01-112',
            Office__c = WCAoffice.Id
        );
        insert WCAofficeAccount;
        
        Account employer = new Account(
            Name = 'Employer',
            ShippingPostalCode = '92345'
        );
        insert employer;
        
        Transaction__c WCAtrn = new Transaction__c(
            Office_Account__c = WCAofficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-8),
            Business_Unit__c = 'WCA',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Pending',
            Transaction_Sum__c = 44.44
        );
        insert WCAtrn;
        
        Receipt__c WCArct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '01-112',
            Date_Received__c = Date.today().addDays(-15),
            Status__c = 'Deposit Pending',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 44.44,
            Transaction__c = WCAtrn.Id,
            Instrument_Number__c = '🌮🍔🌮🍔💯',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'WCA 1',
            Senior_Deputy__c = manager.Id
        );
        insert WCArct;
        
        Test.startTest();
        WCAtrn.Check_Count__c = 1;
        WCAtrn.Checks_Amount__c = 44.44;
        WCAtrn.Treasury_Deposit_Number__c = '🥓🥩🌈';
        update WCAtrn;
        
        Set<Id> trnIdSet = new Set<Id>();
        trnIdSet.add(WCAtrn.Id);
        
        Id db = Database.executeBatch(new AccountingDepositBatch(trnIdSet), 10);
        Test.stopTest();
        
        Transaction__c updatedTRN = [SELECT Id, Transaction_Status__c, Balances_Set__c FROM Transaction__c WHERE Id = :WCAtrn.Id];
        Receipt__c updatedRCT = [SELECT Id, Status__c FROM Receipt__c WHERE Id = :WCArct.Id];
        
        System.assertEquals(updatedRCT.Status__c, 'Deposited');
        System.assertEquals(updatedTRN.Transaction_Status__c, 'Deposited');
        System.assertEquals(updatedTRN.Balances_Set__c, TRUE);
        
    }
}