/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest public with sharing class CommunityForgotPasswordControllerTest {
     @IsTest(SeeAllData=true) public static void testForgotPasswordController() {
      // Instantiate a new controller with all parameters in the page
      CommunityForgotPasswordController controller = new CommunityForgotPasswordController();
      controller.username = 'test@salesforce.com';       
    
      System.assertEquals(controller.forgotPassword(),null); 
    }
    
      @IsTest(SeeAllData=true) public static void testForgotPasswordController2() {
      // Instantiate a new controller with all parameters in the page
      CommunityForgotPasswordController controller = new CommunityForgotPasswordController();
      controller.username = '';       
    
      System.assertEquals(controller.forgotPassword(),null); 
    }
}