trigger LiableParty on Liable_Party__c (before insert, before update, after insert, after update) {

	createLiablePartyCaseIssueAction.runHandler();

}