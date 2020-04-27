trigger appealTrigger on Appeal__c (before insert, before update, after insert, after update) {
    // holds calls to appealMethods class to accomplish tasks that must take place on an appeal
    if (Trigger.isUpdate && Trigger.isAfter) {
        Set<String> AppIds = new Set<String>();
        for (Appeal__c app : Trigger.new) {
            Appeal__c oldApp = Trigger.oldMap.get(app.Id);
            if (app.Status__c == 'Withdrawn' && (app.Status__c != oldApp.Status__c)) {
                AppIds.add(app.Id);
            } 
        }
        appealMethods aMethods = new appealMethods();
        aMethods.SetStatusOnLiabilityAppeal(Trigger.New, Trigger.OldMap);
        if(AppIds.size() > 0) {
            aMethods.WithdrawnAppeals(AppIds);
        }

        //aMethods.SetStatusOnViolations(trigger.new, trigger.oldMap);
        aMethods.SetStatusOnViolations();
        
        // PT-000045:Consolidate Multiple Triggers Per Object
        if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
        }        
    }
    if (Trigger.IsInsert && Trigger.isAfter) {
        appealMethods aMethods = new appealMethods();
        //aMethods.SetStatusOnCase(Trigger.New);
        //aMethods.SetStatusOnViolations(trigger.new);
        aMethods.SetStatusOnViolations();
        
        // PT-000045:Consolidate Multiple Triggers Per Object
        if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
        }        
    }

    
}