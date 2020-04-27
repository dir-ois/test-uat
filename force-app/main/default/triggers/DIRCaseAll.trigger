trigger DIRCaseAll on DIR_Case__c (after insert, after update, before insert, before update, before delete) {
    
    //All logic moved to DIRCaseTriggerHandler
    
    if(trigger.isBefore && trigger.isDelete){
        
        DIRCaseTriggerHandler.validateBeforeCaseDelete(trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        List<DIR_Case__c> caseList = new List<DIR_Case__c>();
        for(DIR_Case__c c : trigger.new){
            if(c.Status__c != null && c.Status__c != trigger.oldMap.get(c.id).Status__c && c.Closed__c){
                caseList.add(c);
            }
        }
        if(caseList.size() > 0){
            DIRCaseTriggerHandler.updateClosedCaseAssignedHistory(caseList);
        }
    }
    // ldavala changes 06.20.2018 - added trigger.newMap to list of parameters
    DIRCaseTriggerHandler.triggerHandler(trigger.new, trigger.oldMap, trigger.newMap, trigger.isUpdate, trigger.isInsert, trigger.isBefore, trigger.isAfter);
   
}