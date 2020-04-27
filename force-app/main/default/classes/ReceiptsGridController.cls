public class ReceiptsGridController {
    
    @AuraEnabled
    public static List<RecordType> getRecTypeIds(){
        List<RecordType> recTypeList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case_Payment__c'];
        return recTypeList;
    }
   
    @AuraEnabled
    public static Map<Id, Id> saveReceiptCaseServer(String receipts, String casePmts, Boolean isEdited) { 
        System.debug('In Save Receipts Controller apxc');
        //List receiptId = '';
        Map<Id, Id> receiptCaseId = new Map<Id, Id>();
        
        DIR_Employee__c dirEmpl = new DIR_Employee__c();
        try {
            dirEmpl = [Select Id, Name FROM DIR_Employee__c WHERE Position__c = 'Cashiering' AND User__c = :UserInfo.getUserId() Limit 1];
        } catch(Exception e) {
            dirEmpl = null;
        }
        
        //String jsonStr = '\''+receipts+'\'';
        System.debug(receipts);
        List<Receipt__c> deserializedPayment = (List<Receipt__c>) JSON.deserialize(receipts, List<Receipt__c>.class);
        System.debug('________________________________________________deserializedPayment____________________________________________');
       	System.debug(deserializedPayment);
        List<Case_Payment__c> deserializedCases = (List<Case_Payment__c>) JSON.deserialize(casePmts, List<Case_Payment__c>.class);
        System.debug('________________________________________________deserializedCases____________________________________________');
       	System.debug(deserializedCases);
        
        if (deserializedPayment != null && deserializedPayment.size() > 0) {
            receiptCaseId = createRctCaseRecord(deserializedPayment, deserializedCases, isEdited);
        }
        return receiptCaseId;
    }
    
    private static Map<Id, Id> createRctCaseRecord(List<Receipt__c> receipts, List<Case_Payment__c> casePmts, Boolean isEdited) {
        Integer rctIndex;
        Integer caseIndex; 
        ID newRctId;
        Boolean deducVal;
        Map<Integer, Id> receiptMap = new Map<Integer, Id>();
        Map<Id, Id> rctCaseMap = new Map<Id, Id>();
        
        if (!isEdited) {
            //System.debug('insert Receipt');
            List<Receipt__c> receiptList = new List<Receipt__c> ();
            List<Case_Payment__c> caseList = new List<Case_Payment__c> ();
            for (Receipt__c eachReceipt : receipts) {
                receiptList.add(eachReceipt);
            }
            insert receiptList;
            
            for(Receipt__c receipt : receiptList){
                newRctId = receipt.Id;
                
                rctIndex = receipt.Receipt_Index__c.intValue();
                if(receipt.Deduction_Amount__c != 0 || receipt.Deduction_Amount__c != 0.0){
                    deducVal = true;
                }
                else{
                    deducVal = false;
                }
                receiptMap.put(rctIndex, newRctId);
                if(newRctId != null){
                    for(Case_Payment__c eachCase : casePmts){
                        caseIndex = eachCase.CP_Index__c.intValue();
                        //Id recTyp = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('PAGA').getRecordTypeId();
                        if(rctIndex == caseIndex){
                            eachCase.Receipt__c = newRctId;
                            eachCase.Deduction_Payment__c = deducVal;
                            caseList.add(eachCase);
                        }
                    }
                }
            }
            System.debug('Case List  ==== '+caseList);
            insert caseList;
            
            Id newMapCaseId;
            Id rctIdOfCase;
            Integer total = 1;
            
            for(Case_Payment__c casePmt : caseList){
                newMapCaseId = casePmt.Id;
                rctIdOfCase = casePmt.Receipt__c;
                System.debug('S.No: '+total+' , Case_Payment ID: '+newMapCaseId+' , Receipt Id'+rctIdOfCase);
                total = total + 1;
                rctCaseMap.put(newMapCaseId,rctIdOfCase);
            }
        }
        return rctCaseMap;
    }
  
}