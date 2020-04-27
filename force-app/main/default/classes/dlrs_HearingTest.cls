/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_HearingTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_HearingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Hearing__c());
    }
}