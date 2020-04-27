public class checkBatchAction extends TriggerAction {

    public boolean shouldRun;
    
    private List<Check_Batch__c> batches = new List<Check_Batch__c>();
    
    public checkBatchAction(Map<Id, sObject> triggerNewMap, Map<Id, sObject> triggerOldMap){ //is update
        super(triggerNewMap, triggerOldMap);
        
        for(sObject sObj : triggerNewMap.values()){
        	//CV: put entrance logic here so that batches only contains records that we want to manipulate
            Check_Batch__c cb = (Check_Batch__c)sObj;
            Check_Batch__c oldCb = (Check_Batch__c)triggerOldMap.get(cb.Id);
            if ( cb.Starting_Check_Number__c != Null && cb.Starting_Check_Number__c != oldCb.Starting_Check_Number__c ){
                batches.add(cb);
            }
            
            
            
            
        }
        
    }
    

    
    public override boolean shouldRunOnInsert() {
    	return false; 
    }
     
    public override boolean shouldRunOnUpdate() {
    	//CV: put check here to validate that the batches list contains records (not empty). If it's empty, no reason to run the action
    	//CV: use and return the shouldRun variable here
    	if(!batches.isEmpty())
    		shouldRun = true; 
        else
            shouldRun = false;
        
        return shouldRun;
    }
    
    public override boolean shouldRunOnDelete() { return false; } 
        
    public override void doAction() {   
        
        Map<Id, Check_batch__c> checkBatchMap = new Map<Id, Check_batch__c>(batches);
        
        list<Check_Batch__c> checkBatch = new list<Check_Batch__c>([SELECT Id, Starting_Check_Number__c, (SELECT Id, Check_Number__c FROM Checks__r Order by Name) FROM Check_Batch__c WHERE ID in :checkBatchMap.keySet()]);
        system.debug('****** checkBatch' + checkBatch);
        
        if (!checkBatch.isEmpty()){
            list<Check__c> checksToUpdate = new list<Check__c>();
            for(Check_Batch__c cb : checkBatch){
                if (!cb.Checks__r.isEmpty()){
                    integer num = Integer.valueOf(cb.Starting_Check_Number__c);
                    for(Check__c c : cb.Checks__r){
                        c.Check_Number__c = string.valueOf(num);
                        num++;
                        checksToUpdate.add(c);
                        system.debug('******* Added ' + c.Id + ' to checksToUpdate');
                    }
                }
            }
            if(!checksToUpdate.isEmpty())
            update checksToUpdate;
        }
    }
    
    public static void runHandler() {  
        
        if (trigger.isBefore){
            return;
        }
        if (trigger.isUpdate) {
            checkBatchAction action = new checkBatchAction(trigger.newMap, trigger.oldMap);
            if(action.shouldRunOnUpdate()){
                action.doAction();
            }
        }

       
    }
}