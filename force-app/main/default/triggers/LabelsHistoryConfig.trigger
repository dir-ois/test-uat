trigger LabelsHistoryConfig on Labels__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}