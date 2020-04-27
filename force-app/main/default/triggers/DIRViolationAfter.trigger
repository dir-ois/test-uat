trigger DIRViolationAfter on DIR_Violation__c (after delete, after insert, after update) {

    CaseViolationAccountCodeAction.runHandler();
    GenerateFieldHistoryAction.runHandler();
    if(trigger.isUpdate && trigger.isAfter){
        //GenerateFieldHistory.checkHistoryConfig(trigger.new, trigger.oldMap);
    }
}