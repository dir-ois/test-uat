trigger LiabilityJudgmentCaseHistory on Liability_Judgement__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}