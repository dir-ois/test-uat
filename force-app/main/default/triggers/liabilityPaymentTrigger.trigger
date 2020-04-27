trigger liabilityPaymentTrigger on Liability_Payment__c (before insert, after insert, before update, after update) {
    
    if(trigger.isAfter) {
        
        Set<Id> LPidsForAeACs = new Set<Id>();
        Set<Id> LPIdsForCIRollup = new Set<Id>();
        
        if(trigger.isInsert) {
            for(Liability_Payment__c lp: Trigger.New) {
                LPidsForAeACs.add(lp.Id);
                
                if(lp.Case_Violation__c != null) {
                    LPIdsForCIRollup.add(lp.Id);
                }
            }
        }
        
        if(trigger.isUpdate) {
            for(Liability_Payment__c lp: Trigger.New) {
                if((lp.Case_Violation__c != null && lp.Payment_Amount__c != null && lp.Payment_Applied_To__c != null) && 
                    (lp.Case_Violation__c != Trigger.oldMap.get(lp.Id).Case_Violation__c || 
                    lp.Payment_Amount__c != Trigger.oldMap.get(lp.Id).Payment_Amount__c || 
                    lp.Payment_Applied_To__c != Trigger.oldMap.get(lp.Id).Payment_Applied_To__c)){
                        LPidsForAeACs.add(lp.Id);
                        LPIdsForCIRollup.add(lp.Id);
                }
            }
        }
        
        System.debug('### liabilityPaymentTrigger entered, LPidsForAeACs.size() = '+LPidsForAeACs.size());
        if(LPidsForAeACs.size() > 0) {
            liabilityPaymentMethods liabilityMethod = new liabilityPaymentMethods();
            liabilityMethod.CreateAppliedAccountingCode(LPidsForAeACs);
        }
        
        if(LPIdsForCIRollup.size() > 0) {
            liabilityPaymentMethods liabilityMethod = new liabilityPaymentMethods();
            liabilityMethod.CaseIssueRollups(LPIdsForCIRollup);
        }
    }
}