trigger DIR_RCIOnly on RCI_Only__c (after update) {
    
    DIR_RCIOnlyTriggerHandler.onAfterUpdate(trigger.oldMap,trigger.newMap);
}