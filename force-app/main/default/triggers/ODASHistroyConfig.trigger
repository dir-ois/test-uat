trigger ODASHistroyConfig on ODAS__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}