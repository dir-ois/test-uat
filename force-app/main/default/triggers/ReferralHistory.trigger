trigger ReferralHistory on Referral__c (after insert, after update) {
    GenerateFieldHistoryAction.runHandler();
}