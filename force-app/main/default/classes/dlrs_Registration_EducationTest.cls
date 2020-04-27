/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Registration_EducationTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Registration_EducationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Registration_Education__c());
    }
}