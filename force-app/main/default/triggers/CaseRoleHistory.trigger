trigger CaseRoleHistory on Case_Role__c (after update, after insert) {
    GenerateFieldHistoryAction.runHandler();
}