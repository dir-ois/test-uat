public with sharing class UpdateCaseStatusAction extends TriggerAction{
		
	private Id wcaRT = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('WCA Hearing').getRecordTypeId();
	private Id gmtRT = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('Garment Hearing').getRecordTypeId();
	private List<DIR_Case__c> updateCaseList = new List<DIR_Case__c>();
	public boolean shouldRun;
	
	public UpdateCaseStatusAction(Map<Id, sObject> triggerNewMap, Map<Id, sObject> triggerOldMap){
		super(triggerNewMap, triggerOldMap);
		set<Id> approvedIds = new set<Id>();
		set<Id> awaitingIds = new set<Id>();
		for(Id m : triggerNewMap.keySet()){
			Hearing__c newHearing = (Hearing__c)triggerNewMap.get(m);
			if(newHearing.RecordTypeId == wcaRT || newHearing.RecordTypeId == gmtRT){
				Hearing__c oldHearing = (Hearing__c)triggerOldMap.get(m);
				if(newHearing.Status__c == 'Pending Approval' && oldHearing.Status__c != 'Pending Approval'){
					awaitingIds.add(newHearing.Case__c);
				}
				else if(newHearing.Status__c == 'Meeting Approved' && oldHearing.Status__c != 'Meeting Approved'){
					approvedIds.add(newHearing.Case__c);
				}
			}
			else{
				continue;
			}
		}
		if(!approvedIds.isEmpty() || !awaitingIds.isEmpty()){
			List<DIR_Case__c> caseList = [SELECT Id, Name, Status__c FROM DIR_Case__c WHERE Id IN: approvedIds OR Id IN: awaitingIds];
			for(DIR_Case__c c : caseList){
				if(approvedIds.contains(c.Id)){
					c.Status__c = 'Hearing Approved';
					updateCaseList.add(c);
				}
				else if(awaitingIds.contains(c.Id)){
					c.Status__c = 'Awaiting Approval';
					updateCaseList.add(c);
				}
			}
		}
	}
	
	public override boolean shouldRunOnInsert() { return false;}
	 
    public override boolean shouldRunOnDelete() { return false;} 
    
    public override boolean shouldRunOnUpdate() {
    	shouldRun = updateCaseList.size() > 0 ? true : false;
    	return shouldRun;
    } 
    
    public override void doAction() {
    	update updateCaseList;
    }
	
	public static void runHandler() {
        if (trigger.isbefore) {
            return;
        }   
        
        if (trigger.isUpdate) {
        	UpdateCaseStatusAction action = new UpdateCaseStatusAction(trigger.newMap, trigger.oldMap);
        	if(action.shouldRunOnUpdate()){
        		action.doAction();
        	}
        } 
    }

}