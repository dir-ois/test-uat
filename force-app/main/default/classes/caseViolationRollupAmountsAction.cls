public with sharing class caseViolationRollupAmountsAction extends TriggerAction{
    
    public boolean shouldRun;

    set<Id> assessmentIds = new set<Id>();
    set<Id> canceledViols = new set<Id>();

    public caseViolationRollupAmountsAction(Map<Id, sObject> triggerNewMap){ //is insert
        super(triggerNewMap);
        
        for(sObject sObj : triggerNewMap.values()){
            DIR_Violation__c newViol = (DIR_Violation__c)sObj;
            if(newViol.Assessment__c != null){
                assessmentIds.add(newViol.Assessment__c);
            }
        }
    }

    public caseViolationRollupAmountsAction(Map<Id, sObject> triggerNewMap, Map<Id, sObject> triggerOldMap){ //is update
        super(triggerNewMap, triggerOldMap);

        for(sObject sObj : triggerNewMap.values()){
            DIR_Violation__c newViol = (DIR_Violation__c)sObj;
            DIR_Violation__c oldViol = (DIR_Violation__c)triggerOldMap.get(sObj.Id);
            if(newViol.Assessment__c != null 
                &&(newViol.Citation_Amount__c != oldViol.Citation_Amount__c
                    || newViol.Wages_Due__c != oldViol.Wages_Due__c
                    || newViol.Wages_Due_Date__c != oldViol.Wages_Due_Date__c
                    || newViol.Penalty_Payments_Received__c != oldViol.Penalty_Payments_Received__c
                    || newViol.Wage_Payments_Received__c != oldViol.Wage_Payments_Received__c
                    || newViol.Total_Interest_Amount__c != oldViol.Total_Interest_Amount__c
                    || newViol.Interest_Payments_Received__c != oldViol.Interest_Payments_Received__c
                    || (newViol.Status__c == 'Canceled - Invalid' && oldViol.Status__c != 'Canceled - Invalid')
                    || (newViol.Status__c != 'Canceled - Invalid' && oldViol.Status__c == 'Canceled - Invalid'))) {

                assessmentIds.add(newViol.Assessment__c);
                if(newViol.Status__c != 'Canceled - Invalid'){
                    canceledViols.add(newViol.Id);
                }
            }
        }
    }

    public override boolean shouldRunOnInsert() { 
        shouldRun = assessmentIds.isEmpty() ? false : true;
        return shouldRun; 
    }
     
    public override boolean shouldRunOnDelete() { return false; } 
    
    public override boolean shouldRunOnUpdate() {
        shouldRun = assessmentIds.isEmpty() ? false : true;
        return shouldRun;
    } 
    
    public override void doAction() {

        if(hasBeenAudited()) return;

        List<Assessments__c> updateList = new List<Assessments__c>();

        map<Id, Assessments__c> assessmentMap = new map<Id, Assessments__c>([
                                                                             SELECT Id, Name, Total_Citation_Penalties_Assessed__c, Total_Citations_Penalties_Paid__c, Total_Interest_Assessed__c,
                                                                                    Total_Interest_Paid__c, Total_Wages_Assessed__c, Total_Wages_Paid__c,
                                                                                    (
                                                                                     SELECT Citation_Amount__c, Penalty_Payments_Received__c, Total_Interest_Amount__c, Interest_Payments_Received__c, 
                                                                                            Wages_Due__c, Wage_Payments_Received__c, Status__c
                                                                                     FROM Case_Violations__r
                                                                                    )
                                                                             FROM Assessments__c
                                                                             WHERE Id IN: assessmentIds
                                                                            ]);

        Map<Id, Map<String, Decimal>> amountsMap = new Map<Id, Map<String, Decimal>> ();
        for(Assessments__c a : assessmentMap.values()){
            if(!a.Case_Violations__r.isEmpty()){
                for(DIR_Violation__c viol : a.Case_Violations__r){
                    Map<String, Decimal> valMap;
                    boolean invalid = Viol.Status__c == 'Canceled - Invalid' ? true : false;
                    if(!amountsMap.containsKey(a.Id)){
                        valMap = new Map<String, Decimal>();
                        valMap.put('Total_Citation_Penalties_Assessed__c', ( (viol.Citation_Amount__c == null || invalid) ? 0 : viol.Citation_Amount__c) );
                        valMap.put('Total_Citations_Penalties_Paid__c', ( (viol.Penalty_Payments_Received__c == null || invalid) ? 0 : viol.Penalty_Payments_Received__c) );
                        valMap.put('Total_Interest_Assessed__c', ( (viol.Total_Interest_Amount__c == null || invalid) ? 0 : viol.Total_Interest_Amount__c) );
                        valMap.put('Total_Interest_Paid__c', ( (viol.Interest_Payments_Received__c == null || invalid) ? 0 : viol.Interest_Payments_Received__c) );
                        valMap.put('Total_Wages_Assessed__c', ( (viol.Wages_Due__c == null || invalid) ? 0 : viol.Wages_Due__c) );
                        valMap.put('Total_Wages_Paid__c', ( (viol.Wage_Payments_Received__c == null || invalid) ? 0 : viol.Wage_Payments_Received__c) );
                    }
                    else{
                        Decimal amt;
                        valMap = amountsMap.get(a.Id);

                        amt = valMap.get('Total_Citation_Penalties_Assessed__c') + ( (viol.Citation_Amount__c == null || invalid) ? 0 : viol.Citation_Amount__c);
                        valMap.put('Total_Citation_Penalties_Assessed__c', amt);

                        amt = valMap.get('Total_Citations_Penalties_Paid__c') + ( (viol.Penalty_Payments_Received__c == null || invalid) ? 0 : viol.Penalty_Payments_Received__c);
                        valMap.put('Total_Citations_Penalties_Paid__c', amt);

                        amt = valMap.get('Total_Interest_Assessed__c') + ( (viol.Total_Interest_Amount__c == null || invalid) ? 0 : viol.Total_Interest_Amount__c);
                        valMap.put('Total_Interest_Assessed__c', amt);

                        amt = valMap.get('Total_Interest_Paid__c') + ( (viol.Interest_Payments_Received__c == null || invalid) ? 0 : viol.Interest_Payments_Received__c);
                        valMap.put('Total_Interest_Paid__c', amt);

                        amt = valMap.get('Total_Wages_Assessed__c') + ( (viol.Wages_Due__c == null || invalid) ? 0 : viol.Wages_Due__c);
                        valMap.put('Total_Wages_Assessed__c', amt);

                        amt = valMap.get('Total_Wages_Paid__c') + ( (viol.Wage_Payments_Received__c == null || invalid) ? 0 : viol.Wage_Payments_Received__c);
                        valMap.put('Total_Wages_Paid__c', amt);
                    }
                    amountsMap.put(a.Id, valMap);
                }
                Map<String, Decimal> valMap = amountsMap.get(a.Id);

                a.Total_Citation_Penalties_Assessed__c = valMap.get('Total_Citation_Penalties_Assessed__c');
                a.Total_Citations_Penalties_Paid__c = valMap.get('Total_Citations_Penalties_Paid__c');
                a.Total_Interest_Assessed__c = valMap.get('Total_Interest_Assessed__c');
                a.Total_Interest_Paid__c = valMap.get('Total_Interest_Paid__c');
                a.Total_Wages_Assessed__c = valMap.get('Total_Wages_Assessed__c');
                a.Total_Wages_Paid__c = valMap.get('Total_Wages_Paid__c');

                updateList.add(a);
            }
        }
        if(!updateList.isEmpty()){
            update updateList;
        }
    }
    
    private static boolean hasBeenAudited() {
        return false;
    }
    
    public static void runHandler() {
        if (trigger.isbefore) {
            return;
        }   
        if(trigger.isInsert){
            caseViolationRollupAmountsAction action = new caseViolationRollupAmountsAction(trigger.newMap);
            if(action.shouldRunOnInsert()){
                action.doAction();
            }
        }
        if (trigger.isUpdate) {
            caseViolationRollupAmountsAction action = new caseViolationRollupAmountsAction(trigger.newMap, trigger.oldMap);
            if(action.shouldRunOnUpdate()){
                action.doAction();
            }
        }
    }
}