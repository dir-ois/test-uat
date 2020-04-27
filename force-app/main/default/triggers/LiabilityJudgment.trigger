trigger LiabilityJudgment on Liability_Judgement__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	UpdateJudgmentAmountAction.runHandler();
	
}