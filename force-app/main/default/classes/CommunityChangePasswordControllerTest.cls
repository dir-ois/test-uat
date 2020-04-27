/**
 * An apex page controller that exposes the change password functionality
 */
@IsTest public with sharing class CommunityChangePasswordControllerTest {
     @IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        CommunityChangePasswordController controller = new CommunityChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}