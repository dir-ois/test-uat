/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ChargentOrders_TransactionTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ChargentOrders_TransactionTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new ChargentOrders__Transaction__c());
    }
}