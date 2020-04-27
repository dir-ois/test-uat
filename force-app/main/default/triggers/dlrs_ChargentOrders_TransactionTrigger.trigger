/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_ChargentOrders_TransactionTrigger on ChargentOrders__Transaction__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(ChargentOrders__Transaction__c.SObjectType);
}