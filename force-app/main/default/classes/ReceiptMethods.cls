public with sharing class ReceiptMethods{
    public static void rollUpToTRN(Set<Id> trnIds){
        if(trnIds == null || trnIds.isEmpty()){
            return;
        }
        
        List<Receipt__c> rctList = new List<Receipt__c>([SELECT Id, Name, Payment_Amount__c, Transaction__c, Payment_Can_Be_Processed__c, Status__c
                                                            FROM Receipt__c
                                                            WHERE Transaction__c != NULL
                                                                AND Transaction__c IN :trnIds
                                                                AND Payment_Can_Be_Processed__c = TRUE
                                                                AND Returned_Item__c = FALSE
                                                                AND Voided_Item__c = FALSE
                                                                AND (Status__c = 'Deposited'
                                                                    OR Status__c = 'New'
                                                                    OR Status__c = 'Deposit Pending')]);
                                                                    
        System.debug('rctList: ' + rctList);
        
        List<Transaction__c> trnList = new List<Transaction__c>([SELECT Id, Name, Transaction_Sum__c
                                                                    FROM Transaction__c
                                                                    WHERE Id IN :trnIds]);
        
        List<Transaction__c> trnsToUpdate = new List<Transaction__c>();
        
        for(Transaction__c trn : trnList){
            Decimal sumOfRCTs = 0.00;
            for(Receipt__c rct : rctList){
                if(trn.Id == rct.Transaction__c){
                    sumOfRCTs += rct.Payment_Amount__c;
                }
            }
            
            if(sumOfRCTs != trn.Transaction_Sum__c){
                trn.Transaction_Sum__c = sumOfRCTs;
                trnsToUpdate.add(trn);
            }
        }
        
        update trnsToUpdate;
    }
}