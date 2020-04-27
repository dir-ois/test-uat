trigger LiabilityHistory on Liability__c (after update, after insert) {
  //GenerateFieldHistory.checkHistoryConfig(trigger.new, trigger.oldMap);
  GenerateFieldHistoryAction.runHandler();

}