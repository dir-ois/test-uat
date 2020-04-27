//Called 'TransactionDIRTrigger' because sfxOrgData gets confused with the Chargent 'TransactionTrigger'
trigger TransactionDIRTrigger on Transaction__c (after update){
    
    if(trigger.isAfter){
        if(trigger.isUpdate){
            if(!TransactionMethods.hasRun){
                TransactionMethods.accountingDeposit(trigger.new, trigger.oldMap);
                
            }
        }
    }
}