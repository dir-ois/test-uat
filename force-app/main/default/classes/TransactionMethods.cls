/*
Called by the TransactionDIRTrigger class
*/
public class TransactionMethods{
    
    public static boolean hasRun = false;
    
    public void TransactionMethods(){  }
    
    public static void accountingDeposit(List<Transaction__c> newTrnList, Map<Id, Transaction__c> oldTrnMap){
        
        hasRun = true;
        
        Set<Id> trnIdsWithRctsToUpdate = new Set<Id>();
        List<Transaction__c> trnsToUpdate = new List<Transaction__c>();
        
        for(Transaction__c trn : [SELECT Id, Transaction_Type__c, Transaction_Status__c, Transaction_Sum__c, Treasury_Deposit_Number__c, Check_Count__c, Checks_Amount__c,
                                        Account_Balance_Before_Transaction__c, Account_Balance_After_Transaction__c, Balances_Set__c, RecordTypeId,
                                        Office_Account__c, Office_Account__r.Account_Balance__c
                                    FROM Transaction__c
                                    WHERE Id IN :newTrnList]){
            
            if(trn.Transaction_Type__c == 'Deposit' && trn.Transaction_Status__c == 'Pending' &&
                    trn.Treasury_Deposit_Number__c != NULL && oldTrnMap.get(trn.Id).Treasury_Deposit_Number__c == NULL &&
                    trn.Check_Count__c != NULL && oldTrnMap.get(trn.Id).Check_Count__c == NULL &&
                    trn.Checks_Amount__c != NULL && oldTrnMap.get(trn.Id).Checks_Amount__c == NULL){
                    
                trn.Transaction_Status__c = 'Deposited';
                trn.Account_Balance_Before_Transaction__c = trn.Office_Account__r.Account_Balance__c;
                trn.Account_Balance_After_Transaction__c = trn.Office_Account__r.Account_Balance__c + trn.Transaction_Sum__c;
                trn.Balances_Set__c = TRUE;
                trn.RecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('TRN Locked').getRecordTypeId();
                
                trnIdsWithRctsToUpdate.add(trn.Id);
                trnsToUpdate.add(trn);
            }
        }
        update trnsToUpdate;
        
        if(!trnIdsWithRctsToUpdate.isEmpty()){
            Id db = Database.executeBatch(new AccountingDepositBatch(trnIdsWithRctsToUpdate), 10);
        }
    }
}