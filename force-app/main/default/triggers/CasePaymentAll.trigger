trigger CasePaymentAll on Case_Payment__c (after delete, after insert, after update, before update) {
    
    if(Trigger_Settings__c.getInstance('CasePaymentAll').Is_Active__c){ //managed in Setup->Custom Settings
        
        if(Trigger.isInsert){
            System.debug('isInsert');
            
            if(Trigger.isAfter){
                System.debug('isInsertIsAfter');
                
                PaymentPlanRollUp();
                DepositedFundsRollUp();
                
                // PT-000045:Consolidate Multiple Triggers Per Object
                if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
                }
            }
        }
        else if(Trigger.isUpdate){
            System.debug('isUpdate');
            if(Trigger.isAfter){
                System.debug('isUpdateIsAfter');
                PaymentPlanRollUp();
                DepositedFundsRollUp();
                
                // PT-000045:Consolidate Multiple Triggers Per Object
                if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
                }
            }
        }
        else if(Trigger.isDelete){
            System.debug('isDelete');
            if(Trigger.isAfter){
                System.debug('isDeleteIsAfter');
                PaymentPlanRollUp();
                DepositedFundsRollUp();
            }
        }
    }
    
    /*
    Rolls up deposited Case Payment funds to the parent DIR_Case__c.Deposited_Funds__c field.
    TODO: rewrite this to use SOQL aggregate results (as the payment plan rollup does); TEST to see if it's faster. 
    */
    public void DepositedFundsRollUp(){
        System.debug('entered trigger CasePaymentAll.DepositedFundsRollUp()');
        
        Set<Id> cmIds = new Set<Id>();
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Case_Payment__c cp : Trigger.new){
                cmIds.add(cp.Case__c);
            }
        }
        if(Trigger.isUpdate || Trigger.isDelete){
            for(Case_Payment__c cp : Trigger.old){
                cmIds.add(cp.Case__c);
            }
        }
        
        List<DIR_Case__c> allCMList = [SELECT Id, Name, Deposited_Funds__c
                                        FROM DIR_Case__c
                                        WHERE Id in :cmIds];
        
        //Not all of a Case's CPs will be in Trigger.new or Trigger.old
        List<Case_Payment__c> allCPList = [SELECT Id, Name, Case__c, Deposited__c, Payment_Amount__c, Voided_Item__c, Returned_Item__c, Receipt__c, Receipt__r.Deposit_Account__c, Receipt__r.Transaction__c
                                            FROM Case_Payment__c
                                            WHERE Case__c in :cmIds
                                                AND (Deposited__c = TRUE
                                                    OR Returned_Item__c = TRUE) //if a CP has been returned, it was once deposited--it should still roll up to the CM
                                                AND Payment_Amount__c != NULL];
        
        Boolean shouldUpdateCases = false;
        
        for(DIR_Case__c cm : allCMList){
            Decimal cpAmountSum = 0.00;
            for(Case_Payment__c cp : allCPList){
                if(cp.Case__c == cm.Id && !cp.Voided_Item__c && (cp.Deposited__c || cp.Returned_Item__c) && cp.Receipt__r.Deposit_Account__c != '108' && cp.Receipt__r.Deposit_Account__c != 'None'){
                    cpAmountSum += cp.Payment_Amount__c;
                }
                
            }
            
            if(cm.Deposited_Funds__c != cpAmountSum){
                cm.Deposited_Funds__c = cpAmountSum;
                shouldUpdateCases = true;
            }
        }
        
        if(shouldUpdateCases){
            update allCMList;
        }
    }
    

    /* 
    Rolls up the payments made on the payment plan as case payment child records and puts the total of all case
    payments made on this payment plan in the Total Payment Amount field 
    */
    public void PaymentPlanRollUp() {
        System.debug('enter CasePaymentAlltrigger.PaymentPlanRollUp()');
        
        Set<Id> ppIds = new Set<Id>();
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Case_Payment__c cp : Trigger.new) {
                if (cp.Payment_Plan__c != null) {
                    ppIds.add(cp.Payment_Plan__c);
                }
            }
        }
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Case_Payment__c cp : Trigger.old) {
                if (cp.Payment_Plan__c != null) {
                    ppIds.add(cp.Payment_Plan__c);
                }
            }
        }
        
        List<Payment_Plan__c> pps = [SELECT Id, Total_Payment_Amount__c FROM Payment_Plan__c WHERE Id IN :ppIds];
        
        Map<Id, AggregateResult> stats = new Map<Id, AggregateResult>([SELECT Payment_Plan__c Id, SUM(Payment_Amount__c) Amount FROM Case_Payment__c WHERE Payment_Plan__c IN :ppIds GROUP BY Payment_Plan__c]);
        
        List<Payment_Plan__c> paymentPlansToUpdate = new List<Payment_Plan__c>();
        
        for (Payment_Plan__c pp : pps) {
            if(stats.containsKey(pp.Id)){
                Decimal casePaymentSum = (Decimal)stats.get(pp.Id).get('Amount');
                if(pp.Total_Payment_Amount__c != casePaymentSum){
                    pp.Total_Payment_Amount__c = casePaymentSum;
                    paymentPlansToUpdate.add(pp);
                }
            }
        }
        if(paymentPlansToUpdate.size() > 0){
            update paymentPlansToUpdate;
        }
    }
}