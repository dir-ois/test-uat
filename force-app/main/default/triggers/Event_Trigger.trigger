trigger Event_Trigger on Event (before insert, before update, after insert, after update) {
     
    GenerateActivityHistoryAction.runHandler();
}