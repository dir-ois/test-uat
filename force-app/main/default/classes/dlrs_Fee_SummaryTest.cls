/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Fee_SummaryTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Fee_SummaryTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Fee_Summary__c());
    }
}