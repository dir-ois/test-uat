trigger referralAll on Referral__c (before insert, after insert, before update, after update, before delete) {

    if(trigger.isInsert){
        if(trigger.isAfter){
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
            }    
        }
    } else if(trigger.isUpdate){
        if(trigger.isAfter){
            referralMethods.updateReminderDates(Trigger.New, Trigger.OldMap);
            
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
            }
        }
    }
}