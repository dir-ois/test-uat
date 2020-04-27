trigger JudgmentHistoryConfig on Judgement__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}