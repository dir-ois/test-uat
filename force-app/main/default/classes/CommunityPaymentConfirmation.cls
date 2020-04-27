/********************************************************************************************************
Name:  CommunityCheckOrACH.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  11/29/2017
Modified by: 
Date:
Test class: CommunityCheckOrACHTest.cls

Behavior:
    
       
********************************************************************************************************/

public class CommunityPaymentConfirmation {
    
    
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    
    public CommunityPaymentConfirmation (){
        
        errortype = 'alert alert-success';
        errorDisplay = 'block'; 
        errormessage = 'Your Payment was successful.';
    }
    
    
    
     public PageReference BackToRegistrations() {
        PageReference regPage = new PageReference('/CommunityRegistration');
        regPage.setRedirect(true);
        return regPage;
    }
    
}