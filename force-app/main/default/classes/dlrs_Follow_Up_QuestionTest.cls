/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Follow_Up_QuestionTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Follow_Up_QuestionTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Follow_Up_Question__c());
    }
}