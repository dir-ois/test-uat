/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitySelfRegConfirmControllerTest {
    @IsTest(SeeAllData=true) public static void testCommunitySelfRegConfirmController() {
        // Instantiate a new controller with all parameters in the page
        CommunitySelfRegConfirmController controller = new CommunitySelfRegConfirmController();
      }    
}