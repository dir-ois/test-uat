/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_License_RegistrationTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_License_RegistrationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new License_Registration__c());
    }
}