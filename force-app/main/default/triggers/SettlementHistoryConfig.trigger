trigger SettlementHistoryConfig on Settlement__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}