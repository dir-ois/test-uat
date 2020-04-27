/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Follow_Up_Question_DataTrigger on Follow_Up_Question_Data__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Follow_Up_Question_Data__c.SObjectType);
}