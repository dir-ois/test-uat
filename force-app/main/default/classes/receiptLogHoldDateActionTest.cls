@isTest
public class receiptLogHoldDateActionTest {
    static testMethod void testHoldDate(){
    
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
    
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        
        Map<id,Receipt__c> oldmap = new Map<id,Receipt__c>();
        Map<id,Receipt__c> newmap = new Map<id,Receipt__c>();
        List<Receipt__c> rctList = new List<Receipt__c>();
        
        Receipt__c rct = new Receipt__c();
        rct.Instrument_Number__c = 'test123';
        rct.Payment_Exchange__c = 'Division Payment';
        rct.Bank_Location__c = 'CA Bank';
        rct.Payment_Type__c = 'Check';
        rct.Date_Received__c = date.today();
        rct.Payment_Amount__c = 3000;
        rct.Deduction_Amount__c = 0;
        rct.Payee__c = acc.id;
        rct.Deposit_Account__c = '04-112';
        rct.Office_Unit__c = 'CCU 32';
        insert rct;
        //oldmap.put(rct.id, rct);
        
        rct.Payment_Type__c = 'Cash';
        update rct;
        rctList.add(rct);
        
        receiptLogHoldDateAction rLHDA = new receiptLogHoldDateAction(rctList);

        //newmap.put(rct.id, rct);
    }
    
}