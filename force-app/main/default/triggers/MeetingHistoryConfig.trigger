trigger MeetingHistoryConfig on Hearing__c (after update, after insert) {
  GenerateFieldHistoryAction.runHandler();
}