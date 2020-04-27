/********************************************************************************************************
Name:  CommunityPayCredit.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  11/30/2017
Modified by: 
Date:
Test class: CommunityPayCredit.cls

Behavior:
    
       
********************************************************************************************************/

public class CommunityPayCredit {
    
    private String coId;
    public ChargentOrders__ChargentOrder__c ChargentOrder {get; set;}
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    private License_Registration__c lReg ;
    
    public CommunityPayCredit(){
        coId = apexpages.currentpage().getparameters().get('id');
        ChargentOrder = [SELECT Id, Registration__c, ChargentOrders__Payment_Method__c, ChargentOrders__Card_Type__c,ChargentOrders__Billing_First_Name__c, ChargentOrders__Card_Number__c,
         ChargentOrders__Billing_Last_Name__c, ChargentOrders__Card_Expiration_Month__c, ChargentOrders__Billing_Company__c,
         ChargentOrders__Card_Expiration_Year__c, ChargentOrders__Billing_Address__c, ChargentOrders__Card_Security_Code__c,
         ChargentOrders__Billing_Address_Line_2__c, ChargentOrders__Billing_Phone__c, ChargentOrders__Billing_City__c,
         ChargentOrders__Billing_Email__c, ChargentOrders__Billing_State__c , ChargentOrders__Billing_Zip_Postal__c,
         ChargentOrders__Billing_Country__c
          FROM ChargentOrders__ChargentOrder__c WHERE Id =: coId];
        
        errormessage = '';
        errortype = '';
        errorDisplay = '';
        
        lReg = [SELECT Id, Status__c FROM License_Registration__c WHERE Id =: ChargentOrder.Registration__c]; 
    }
    
    public PageReference CancelPayment() {
        //delete ChargentOrder;
        lReg.Status__c = 'Pending Payment';
        //lReg.VIP_Date_Time_Submitted__c = null;
        update lReg;
        PageReference regPage = new PageReference('/CommunityRegistration');
        regPage.setRedirect(true);
        return regPage;
    }
    
    public PageReference NextPayment() {
        try {
            update ChargentOrder;
        } catch(Exception e) {
            errortype = 'alert alert-danger';
            errorDisplay = 'block'; 
            errormessage = 'Please specify how are you affiliated to the business.';
        }
        PageReference regPage = new PageReference('/CommunityPayCreditConfirm?id=' + ChargentOrder.Id);
        regPage.setRedirect(true);
        return regPage;
        
    }
    
     
}