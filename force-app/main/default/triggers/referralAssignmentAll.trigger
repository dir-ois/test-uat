trigger referralAssignmentAll on Referral_Assignment__c (before insert, after insert, before update, after update, before delete) {

ReferralUpdateDateAction.runHandler();
}