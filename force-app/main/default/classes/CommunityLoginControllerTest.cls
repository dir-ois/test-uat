/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class CommunityLoginControllerTest {
    @IsTest(SeeAllData=true) 
    global static void testCommunityLoginController () {
       
       
       CommunityLoginController controller = new CommunityLoginController();
       controller.username = 'test@tesrtest.com';
       controller.login();
       controller.SignIn();
       controller.forwardToCustomAuthPage();       
    }    
}