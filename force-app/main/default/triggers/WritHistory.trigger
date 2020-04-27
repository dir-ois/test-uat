trigger WritHistory on Writ__c (after update, after insert) {
  //GenerateFieldHistory.checkHistoryConfig(trigger.new, trigger.oldMap);
  GenerateFieldHistoryAction.runHandler();
}