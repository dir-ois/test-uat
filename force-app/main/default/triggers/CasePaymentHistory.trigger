trigger CasePaymentHistory on Case_Payment__c (after insert, after update) {
    //if(!Test.isRunningTest()){
        GenerateFieldHistoryAction.runHandler();
    //}
}