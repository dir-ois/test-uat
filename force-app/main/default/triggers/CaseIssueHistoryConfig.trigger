trigger CaseIssueHistoryConfig on DIR_Violation__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}