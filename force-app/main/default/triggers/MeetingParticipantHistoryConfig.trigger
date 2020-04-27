trigger MeetingParticipantHistoryConfig on Meeting_Participant__c (after update, after insert) {
  GenerateFieldHistoryAction.runHandler();
}