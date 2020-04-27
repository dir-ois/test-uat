trigger checkBatchTrigger on Check_Batch__c (before insert, before update, after insert, after update) {
	checkBatchAction.runHandler();
}