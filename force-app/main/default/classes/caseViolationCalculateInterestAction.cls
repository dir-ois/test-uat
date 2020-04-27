public with sharing class caseViolationCalculateInterestAction extends TriggerAction{
	
	public boolean shouldRun;

	Id wcaRT = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId();
	List<DIR_Violation__c> viols = new List<DIR_Violation__c>();

	public caseViolationCalculateInterestAction(Map<Id, sObject> triggerNewMap, Map<Id, sObject> triggerOldMap){ //is update
		super(triggerNewMap, triggerOldMap);
		
		for(sObject sObj : triggerNewMap.values()){
        	DIR_Violation__c newViol = (DIR_Violation__c)sObj;
        	DIR_Violation__c oldViol = (DIR_Violation__c)triggerOldMap.get(sObj.Id);
        	if(newViol.RecordTypeId == wcaRT && newViol.Wages_Due_Date__c != null && newViol.Wages_Due_Date__c != oldViol.Wages_Due_Date__c){
        		viols.add(newViol);
        	}
        }
	}

	public override boolean shouldRunOnInsert() { return false; }
	 
    public override boolean shouldRunOnDelete() { return false; } 
    
    public override boolean shouldRunOnUpdate() {
		
    	shouldRun = viols.isEmpty() ? false : true;

    	return shouldRun;
    } 
    
    public override void doAction() {

        Interest__c interest = Interest__c.getInstance('WCA Violations');
        Decimal interestRate = interest.Interest_Rate__c;

        if(interestRate == null) return;

        Set<Id> idSet = new Set<Id>();
        for(DIR_Violation__c viol : viols){
            idSet.add(viol.Violation_Type__c);
        }

        Map<Id, Violation_Type__c> vtMap = new Map<Id, Violation_Type__c>([
            SELECT Id, Interest_Type__c 
            FROM Violation_Type__c
            WHERE Id IN: idSet
        ]);
		for(DIR_Violation__c viol : viols){
            if(viol.Wages_Due_Date__c == null 
                || viol.Meeting_Date__c == null 
                || viol.Violation_Type__c == null 
                || !vtMap.containsKey(viol.Violation_Type__c)
                || vtMap.get(viol.Violation_Type__c).Interest_Type__c == null
                || vtMap.get(viol.Violation_Type__c).Interest_Type__c.equalsIgnoreCase('post judgment')){
                continue;
            } 
            else{
                viol.Total_Interest_Amount__c = ( (viol.Wages_Due__c == null ? 0 : viol.Wages_Due__c) * interestRate * 0.01 * math.abs(viol.Wages_Due_Date__c.daysBetween(viol.Meeting_Date__c)) ) / 365;
            }
			
		}
    }
	
	public static void runHandler() {
        if (trigger.isAfter) {
            return;
        }   
        
        if (trigger.isUpdate) {
        	caseViolationCalculateInterestAction action = new caseViolationCalculateInterestAction(trigger.newMap, trigger.oldMap);
        	if(action.shouldRunOnUpdate()){
        		action.doAction();
        	}
        }
    }
}