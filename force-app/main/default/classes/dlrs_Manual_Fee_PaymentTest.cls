/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Manual_Fee_PaymentTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Manual_Fee_PaymentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Manual_Fee_Payment__c());
    }
}