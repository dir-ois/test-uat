trigger InspectionHistoryConfig on DIR_Inspection__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}