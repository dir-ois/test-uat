trigger AppealHistoryConfig on Appeal__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}