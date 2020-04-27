@istest
public class CommunityPaymentConfirmationTest {

    public static testMethod void testCommunityPaymentConfirmation(){
        
        test.startTest();
            CommunityPaymentConfirmation CPC = new CommunityPaymentConfirmation();  
            CPC.BackToRegistrations();
            
        test.stopTest();
    }
}