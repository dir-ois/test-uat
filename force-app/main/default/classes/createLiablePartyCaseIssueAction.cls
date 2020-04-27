public with sharing class createLiablePartyCaseIssueAction extends TriggerAction{
    
    private set<Id> liabIds = new set<Id>();
    private List<Liable_Party__c> lpList = new List<Liable_Party__c>();
    public boolean shouldRun;
    
    public createLiablePartyCaseIssueAction(Map<Id, sObject> triggerNewMap){ //is insert
        super(triggerNewMap);
        
        for(sObject sObj : triggerNewMap.values()){
            Liable_Party__c lp = (Liable_Party__c)sObj;
            if(lp.Liability__c != null){
                liabIds.add(lp.Liability__c);
                lpList.add(lp);
            }
        }

    }
    
    public override boolean shouldRunOnInsert() {
        
        shouldRun = liabIds.isEmpty() ? false : true;
        return shouldRun;

    }
     
    public override boolean shouldRunOnDelete() { return false; } 
    
    public override boolean shouldRunOnUpdate() { return false; } 
    
    public override void doAction() {
        if(hasBeenAudited()) return;

        List<Liability__c> liabs = [
                                    SELECT Id, Assessment__c 
                                    FROM Liability__c
                                    WHERE Id IN: liabIds
                                   ];

        set<Id> assessIds = new set<Id>();

        for(Liability__c l : liabs){
            if(l.Assessment__c != null){
                assessIds.add(l.Assessment__c);
            }
        }
        
        if(!assessIds.isEmpty()){
            List<DIR_Violation__c> viols = [
                                            SELECT Id 
                                            FROM DIR_Violation__c
                                            WHERE Assessment__c IN: assessIds
                                           ];

            if(viols != null){
                List<Liable_Party_Case_Issue__c> lpciInsertList = new List<Liable_Party_Case_Issue__c>();
                for(DIR_Violation__c viol : viols){
                    for(Liable_Party__c lp : lpList){
                        Liable_Party_Case_Issue__c lpci = new Liable_Party_Case_Issue__c(
                            Case_Issue__c = viol.Id,
                            Liable_Party__c = lp.Id
                        );
                        lpciInsertList.add(lpci);
                    }
                }
                if(!lpciInsertList.isEmpty()){
                    insert lpciInsertList;
                }
            }
        }
    }
    
    private static boolean hasBeenAudited() {
        return false;
    }
    
    public static void runHandler() {
        if (trigger.isbefore) {
            return;
        }   

        if (trigger.isInsert) {
            createLiablePartyCaseIssueAction action = new createLiablePartyCaseIssueAction(trigger.newMap);
            if(action.shouldRunOnInsert()){
                action.doAction();
            }
            if(action.shouldRunOnUpdate()){ return; }
            if(action.shouldRunOnDelete()){ return; }
        }
    }
}