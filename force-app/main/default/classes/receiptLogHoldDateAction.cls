/*************************************************************************************************
Class     :  receiptLogHoldDateAction.cls
Developer :  Sathya Chandrasekar
Created   :  June 2019
Modified  :  June 2019
Objective :  This class provides methods for receiptLog_Trigger.apxt
*************************************************************************************************/
public class receiptLogHoldDateAction extends TriggerAction {
   
    public boolean shouldRun;
    public Map<Id, Receipt_Log_Setting__mdt> logSettingMap = new Map<Id, Receipt_Log_Setting__mdt>();
    
    List<Receipt__c> receiptLogs = new List<Receipt__c>();
    public receiptLogHoldDateAction(Map<Id, sObject> triggerNewMap, Map<Id, sObject> triggerOldMap){ //is update
        super(triggerNewMap, triggerOldMap);
        
        for(sObject sObj : triggerNewMap.values()){
            Receipt__c rl = (Receipt__c)sObj;
            receiptLogs.add(rl);
            
        }
        
    }
    
    List<Receipt__c> updateReceiptLogs = new List<Receipt__c>();
    public receiptLogHoldDateAction(List<Receipt__c> triggerList){ //is insert
        super(triggerList);
        
        for (Receipt__c result: triggerList) {
            
            receiptLogs.add(result);
            
        }
        
    }
    
    public override boolean shouldRunOnInsert() { return true; }
     
    public override boolean shouldRunOnDelete() { return false; } 
    
    public override boolean shouldRunOnUpdate() { return true; }
        
    public override void doAction() {   

        calculateBusinessHours cbh = new calculateBusinessHours();
        
        List<Receipt_Log_Setting__mdt> rls = [SELECT Bank_Location__c,Id,Number_of_Days__c,Payment_Type__c FROM Receipt_Log_Setting__mdt];
        
        for(Receipt_Log_Setting__mdt r : rls){
            logSettingMap.put(r.id, r);
            
        }

        
        for(Receipt__c rl : receiptLogs){
            
            for(Id r : logSettingMap.keySet()){
                Receipt_Log_Setting__mdt rlData = logSettingMap.get(r);
                
                if(rlData.Payment_Type__c == rl.Payment_Type__c && (rlData.Bank_Location__c == rl.Bank_Location__c || rlData.Bank_Location__c == null)){
                    
                    Integer numDaysInt = Integer.valueOf(rlData.Number_of_Days__c);

                    if(rl.Deposit_Date__c != null)
                        rl.Hold_Date__c = cbh.addBusinessDays(rl.Deposit_Date__c, numDaysInt);
                    
                }
            }
        }
    }
    
    public static void runHandler() {  
        
        if (trigger.isAfter){
            return;
        }
        if (trigger.isUpdate) {
            system.debug('Trigger Update');
            receiptLogHoldDateAction action = new receiptLogHoldDateAction(trigger.newMap, trigger.oldMap);
            if(action.shouldRunOnUpdate()){
                action.doAction();
            }
        }

        if (trigger.isInsert){
            system.debug('Trigger Insert');
            receiptLogHoldDateAction action = new receiptLogHoldDateAction(trigger.new);
            if(action.shouldRunOnUpdate()){
                action.doAction();
            }
        }
    }
    
}