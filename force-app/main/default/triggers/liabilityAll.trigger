trigger liabilityAll on Liability__c (Before Insert, Before Update, Before Delete, After Insert, After Update, After Delete) {

    //Before calls
    if(trigger.isInsert){
        if(trigger.isBefore){
            liabilityMethods.beforeInsert(trigger.new);
        } else if (trigger.isAfter){
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
            }
        }
    }
    else if(trigger.isUpdate){
        liabilityMethods.beforeUpdate(trigger.new, trigger.oldMap);
        if(trigger.isAfter){
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
                GenerateFieldHistoryAction.runHandler();
            }         
        }
    }
    
}