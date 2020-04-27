/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Liable_PartyTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Liable_PartyTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Liable_Party__c());
    }
}