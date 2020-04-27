public with sharing class UpdateJudgmentAmountAction extends TriggerAction{
	
	public boolean shouldRun;
	
	private List<Id> idList = new List<Id>();
	
	//is insert
	public UpdateJudgmentAmountAction(Map<ID,SObject> triggerMap) {
 		super(triggerMap);
 		
 		if(!idList.isEmpty()) idList.clear();
 		for(sObject sObj : triggerMap.values()){
			Liability_Judgement__c newLJ = (Liability_Judgement__c)sObj;
			if(newLJ.Judgement__c  != null){
				idList.add(newLJ.Judgement__c);
			}
 		}
 		
 	}
	
	public override boolean shouldRunOnInsert() {
		shouldRun = idList.isEmpty() ? false : true;
    	return shouldRun;
	}
	 
    public override boolean shouldRunOnDelete() { return false;} 
    
    public override boolean shouldRunOnUpdate() { return false;} 

    public override void doAction() {
    	
		List<Judgement__c> updateList = new List<Judgement__c>();
		
		List<Judgement__c> judgements = [
										 SELECT Id, Name, Judgement_Amount__c,
										 	(
										 	 SELECT Penalty_Balance_Due__c, Wage_Balance_Due__c, Interest_Balance_Due__c, Liable_Party__r.Liability__r.Joint_Liability__c
										 	 FROM Liability_Judgements__r
										 	)
										 FROM Judgement__c
										 WHERE Type__c = 'ODA' AND Id IN: idLIst
										];
										
		for(Judgement__c j : judgements){
			decimal amt = 0;
			for(Liability_Judgement__c lj : j.Liability_Judgements__r){
				amt += (lj.Penalty_Balance_Due__c + lj.Wage_Balance_Due__c + lj.Interest_Balance_Due__c);
				if(lj.Liable_Party__r.Liability__r.Joint_Liability__c)
					break;
			}
			j.Judgement_Amount__c = amt;
			updateList.add(j);
		}
				
    	update updateList;
    }
	
	public static void runHandler() {
		
        if (trigger.isbefore) {
            return;
        } 
        
        if (trigger.isInsert) {
        	UpdateJudgmentAmountAction action = new UpdateJudgmentAmountAction(trigger.newMap);
        	if(action.shouldRunOnInsert()){
        		action.doAction();
        	}
            
            if(trigger.isAfter){
                // PT-000045:Consolidate Multiple Triggers Per Object
                if(!Test.isRunningTest()){
                    GenerateFieldHistoryAction.runHandler();
                }    
            }
                 
	    }
        
        if (trigger.isUpdate){
            if(trigger.isAfter){
                // PT-000045:Consolidate Multiple Triggers Per Object
                if(!Test.isRunningTest()){
                    GenerateFieldHistoryAction.runHandler();
                }      
            }
        }
	    
	}
}