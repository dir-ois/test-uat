trigger Hearing on Hearing__c (after insert, after update, before insert, before update) {
    
    UpdateCaseStatusAction.runHandler();
    
    
    if(trigger.isInsert){
        if(trigger.isAfter){
            HearingTriggerHandler.updateMeetingParticipants(trigger.new);
            HearingTriggerHandler.sendEmailToDeputy(trigger.new);
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
            }
        }
    }
    
    else if(trigger.isUpdate){
        if(trigger.isAfter){
            HearingTriggerHandler.sendEmailToDeputy(trigger.new);
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
            }
        }
    }
}