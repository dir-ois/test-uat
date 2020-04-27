trigger CaseManagementHistoryConfig on DIR_Case__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}