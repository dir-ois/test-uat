/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_License_RegistrationTrigger on License_Registration__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    if(Label.runRegistrationTrigger=='true'){
        dlrs.RollupService.triggerHandler(License_Registration__c.SObjectType);
    }
}