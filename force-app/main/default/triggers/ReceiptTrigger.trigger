/*************************************************************************************************
Class     :  ReceiptTrigger on Receipt__c 
Developer :  Sathya Chandrasekar
Created   :  June 2019
Modified  :  November 2019
Objective :  This class is triggered when a Receipt__c object record is created or modified.
*************************************************************************************************/
trigger ReceiptTrigger on Receipt__c (before update, after insert, after update, after delete) {
    ///if(!Test.isRunningTest()){
        if(Trigger_Settings__c.getInstance('Receipt Trigger').Is_Active__c){ //managed in Setup->Custom Settings
            receiptLogHoldDateAction.runHandler();
        
        
            if(trigger.isBefore){
                if(trigger.isUpdate){
                    
                    /* Process Returns and Voids */
                    List<Id> returnedRCTIdList = new List<Id>();
                    List<Id> voidedRCTIdList = new List<Id>();
                    
                    for(Receipt__c rct : trigger.new){
                        if(rct.Returned_Item__c == true && trigger.oldMap.get(rct.Id).Returned_Item__c == false){
                            returnedRCTIdList.add(rct.Id);
                        }
                        if(rct.Voided_Item__c == true && trigger.oldMap.get(rct.Id).Voided_Item__c == false){
                            voidedRCTIdList.add(rct.Id);
                        }
                    }
                    
                    if(!returnedRCTIdList.isEmpty()){
                        ReturnedVoidedReceipt.returnReceipts(returnedRCTIdList);
                    }
                    if(!voidedRCTIdList.isEmpty()){
                        ReturnedVoidedReceipt.voidReceipts(voidedRCTIdList);
                    }
                }
            }
            
            if(trigger.isAfter){
                
                /* Roll up RCT Payment_Amount__c to TRN.Transaction_Sum__c */
                Set<Id> trnIds = new Set<Id>();
                
                if(Trigger.isInsert){
                    for(Receipt__c rct : Trigger.new){
                        trnIds.add(rct.Transaction__c);
                    }
                    
                    /* Seemingly pointless DML to trigger the CasePaymentAll trigger so the deposited CPs roll up to CM.Deposited_Funds__c */
                    List<Case_Payment__c> cpList = [SELECT Id, Name, Receipt__c
                                                        FROM Case_Payment__c
                                                        WHERE Receipt__c IN :trigger.newMap.keySet()];
                
                    update cpList;
                }
                
                if(Trigger.isUpdate){
                    for(Receipt__c rct : Trigger.new){
                        trnIds.add(rct.Transaction__c);
                    }
                    for(Receipt__c rct : Trigger.old){
                        trnIds.add(rct.Transaction__c);
                    }
                    
                    /* Seemingly pointless DML to trigger the CasePaymentAll trigger so the deposited CPs roll up to CM.Deposited_Funds__c */
                    List<Case_Payment__c> cpList = [SELECT Id, Name, Receipt__c
                                                        FROM Case_Payment__c
                                                        WHERE Receipt__c IN :trigger.newMap.keySet()];
                    
                    update cpList;
                }
                
                if(Trigger.isDelete){
                    for(Receipt__c rct : Trigger.old){
                        trnIds.add(rct.Transaction__c);
                    }
                    /* Seemingly pointless DML to trigger the CasePaymentAll trigger so the deposited CPs roll up to CM.Deposited_Funds__c */
                    List<Case_Payment__c> cpList = [SELECT Id, Name, Receipt__c
                                                        FROM Case_Payment__c
                                                        WHERE Receipt__c IN :trigger.oldMap.keySet()];
                    
                    update cpList;
                }
                
                
                if(!trnIds.isEmpty()){
                    receiptMethods.rollUpToTRN(trnIds);
                }
            }
        }
    ///}
}