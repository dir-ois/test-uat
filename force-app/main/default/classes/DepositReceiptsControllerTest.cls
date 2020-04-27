@isTest(SeeAllData=false)
private class DepositReceiptsControllerTest {

    static testMethod void recordDepositsPassAll(){
    
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
        
        DIR_Employee__c emp = new DIR_Employee__c();
        emp.Position__c = 'Cashiering';
        emp.User__c = UserInfo.getUserId();
        
        insert emp;
        
        Office__c o = new Office__c();
        o.RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeID();
        insert o;
        
        Office_Account__c oa = new Office_Account__c();
        oa.Office__c = o.Id;
        oa.Name = '32-117';
        
        insert oa;
        
        Receipt__c rct = new Receipt__c();
        rct.Bank_Location__c = 'CA Bank';
        rct.Payment_Type__c = 'Check';
        rct.Date_Received__c = date.today();
        rct.Payment_Amount__c = 3000;
        rct.Payee__c = acc.id;
        rct.Deposit_Account__c = '32-117';
        
        
        insert rct;
        
        String[] rctArray = new String[]{};
        rctArray.add(rct.id);
        
        PageReference myVfPage = Page.DepositReceiptsVFP;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('ids','(' + rct.Id + ')');
        
        DepositReceiptsController rdc = new DepositReceiptsController();
        rdc.ids = rctArray;
        rdc.retURL = 'www.google.com';
        rdc.recordDeposits();
        rdc.returnToList();
    }
    
    static testMethod void recordDepositsExceptions(){
    
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

        Receipt__c rct = new Receipt__c();
        rct.Bank_Location__c = 'CA Bank';
        rct.Payment_Type__c = 'Check';
        rct.Date_Received__c = date.today();
        rct.Payment_Amount__c = 3000;
        rct.Payee__c = acc.id;
        rct.Deposit_Account__c = '32-117';
        rct.Office_Unit__c = 'CCU 32';
        
        insert rct;
    
        Receipt__c rct2 = new Receipt__c();
        rct2.Bank_Location__c = 'CA Bank';
        rct2.Payment_Type__c = 'Check';
        rct2.Date_Received__c = date.today();
        rct2.Payment_Amount__c = 3000;
        rct2.Payee__c = acc.id;
        rct2.Deposit_Account__c = '17-113';
        rct2.Office_Unit__c = 'JEU';
        
        insert rct2;
        
        Receipt__c rct3 = new Receipt__c();
        rct3.Bank_Location__c = 'CA Bank';
        rct3.Payment_Type__c = 'Check';
        rct3.Date_Received__c = date.today();
        rct3.Payment_Amount__c = 0.00;
        rct3.Deduction_Amount__c = 30;
        rct3.Payee__c = acc.id;
        rct3.Deposit_Account__c = '108';
        rct3.Office_Unit__c = 'JEU';
        
        insert rct3;
        
        String[] rctArray = new String[]{};
        rctArray.add(rct.id);
        rctArray.add(rct2.id);
        rctArray.add(rct3.id);
        
        PageReference myVfPage = Page.DepositReceiptsVFP;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('ids','(' + rct.Id + ')');
        
        DepositReceiptsController rdc = new DepositReceiptsController();
        rdc.ids = rctArray;
        rdc.recordDeposits();
        
    }

}