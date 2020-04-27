/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
@IsTest public with sharing class CommunityRegisterControllerTest {
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegController() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.confirmemail = 'test@force.com';
        
        controller.communityNickname = 'test';
        controller.SetState();
        controller.getBussinesItems();
        controller.getAffiliationItems();
        controller.getAffiliationVal();
        controller.getCountryVal();
     //   controller.getSecretQuestionVal();
       
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
        controller.cancelBtn();
    }    
    
    public static void testCommunitiesSelfRegController1() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.confirmemail = 'test@force.com';
        
        controller.communityNickname = 'test';
        controller.SetState();
        controller.getBussinesItems();
        controller.getAffiliationItems();
        controller.getAffiliationVal();
        controller.getCountryVal();
   //     controller.getSecretQuestionVal();
       
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'AVcd1234';
        controller.confirmPassword = 'ABcd123';
        System.assert(controller.registerUser() == null);  
        controller.cancelBtn();
    }    
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegController2() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = '';
        controller.lastName = 'LastName';
        controller.email = 'test1@force.com';
        controller.confirmemail = 'test@force.com';
        
        controller.communityNickname = 'test';
        
       
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
    } 
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegController3() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test1@force.com';
        controller.confirmemail = 'test@force.com';
        
        controller.communityNickname = 'test';
        
       
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
    } 
    
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegController4() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.confirmemail = 'test@force.com';
        
        controller.communityNickname = 'test';
        controller.SetState();
        controller.getBussinesItems();
        controller.getAffiliationItems();
        controller.getAffiliationVal();
        controller.getCountryVal();
      //  controller.getSecretQuestionVal();
       
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);  
        controller.cancelBtn();
    }      
    
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegControllerInvalidFirstName() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = 'FirstNameShouldFailBecauseItIsMoreThanFortyCharacters';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.confirmemail = 'test@force.com';
        
        controller.communityNickname = 'test';
        controller.SetState();
        controller.getBussinesItems();
        controller.getAffiliationItems();
        controller.getAffiliationVal();
        controller.getCountryVal();
        //  controller.getSecretQuestionVal();
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);  
    }
    
    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegControllerInvalidEmail() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'testNoAtSymbol.com';
        controller.confirmemail = 'testNoAtSymbol.com';
        
        controller.communityNickname = 'test';
        controller.SetState();
        controller.getBussinesItems();
        controller.getAffiliationItems();
        controller.getAffiliationVal();
        controller.getCountryVal();
        //  controller.getSecretQuestionVal();
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);  
    }

    @IsTest(SeeAllData=true) 
    public static void testCommunitiesSelfRegControllerInvalidLongEmail() {
        CommunityRegisterController controller = new CommunityRegisterController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'testEmailIsTooLongToRegisterForARegistrationAccount@force.com';
        controller.confirmemail = 'testEmailIsTooLongToRegisterForARegistrationAccount@force.com';
        
        controller.communityNickname = 'test';
        controller.SetState();
        controller.getBussinesItems();
        controller.getAffiliationItems();
        controller.getAffiliationVal();
        controller.getCountryVal();
        //  controller.getSecretQuestionVal();
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        System.assert(controller.registerUser() == null);  
    }
}