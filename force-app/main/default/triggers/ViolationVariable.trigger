trigger ViolationVariable on Violation_Variable__c (after update) {
	//GenerateFieldHistory.checkHistoryConfig(trigger.new, trigger.oldMap);
	GenerateFieldHistoryAction.runHandler();
}