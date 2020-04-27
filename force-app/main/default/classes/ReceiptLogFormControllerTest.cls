@isTest
public class ReceiptLogFormControllerTest {
    static testmethod void testPkList(){
        ReceiptLogFormController.getBankLocation();
        ReceiptLogFormController.getPaymentTypes();
        ReceiptLogFormController.getDepositAccount();
        ReceiptLogFormController.getPaymentExchange();
        ReceiptLogFormController.getOfficeUnit();
    }
    
    static testmethod void getPayorAndDeputyName(){
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.Bankruptcy_Status_Date__c = Date.today();
        insert acc;
        
        System.assertEquals(acc.name, ReceiptLogFormController.getPayorName(String.valueOf(acc.Id)));
        
        //If adding Senior Deputy in future
        /*
        Office__c o = new Office__c(
            Name = 'myOffice'
        );
        insert o;
        
        DIR_Employee__c ma = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Name = UserInfo.getName(),
            Email__c = 'testEmail@vertibatest.com'
        );
        insert ma; 
        
        DIR_Employee__c dir = new DIR_Employee__c(
            Manager__c = ma.Id,
            Office__c = o.Id,
            Name = UserInfo.getName(),
            User__c = UserInfo.getUserId()
        );
        insert dir;
        
        System.assertEquals(UserInfo.getName(), ReceiptLogFormController.getDeputyName(String.valueOf(dir.Id)));
		*/
        
    }
    
}