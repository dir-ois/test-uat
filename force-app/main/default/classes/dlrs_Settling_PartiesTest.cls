/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Settling_PartiesTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Settling_PartiesTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Settling_Parties__c());
    }
}