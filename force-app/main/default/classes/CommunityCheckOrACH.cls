/********************************************************************************************************
Name:  CommunityCheckOrACH.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  11/29/2017

Modified by: Touk Ken
Date: 5/18/2018
B-25302

Modified by: Touk Ken
Date: 5/30/2018
B-25302

Modified by: Touk Ken
Date: 06/15/2018
added newChargentOrder.ChargentOrders__Gateway__c

Test class: CommunityCheckOrACHTest.cls

Behavior:
    
       
********************************************************************************************************/

public class CommunityCheckOrACH {
    
    private String RegistrationId;
    public Decimal TotalFees {get; set;}
    private License_Registration__c currentRegistration;
    private Fee_Summary__c currentFeeSummary; 
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    public String paymentGateway = '';
    private List<RecordType> registrationRecordTypes;
    
    public CommunityCheckOrACH(){
        RegistrationId = apexpages.currentpage().getparameters().get('id');
        currentRegistration = [SELECT Id, Applicant__c, Applicant__r.Email, Balance__c, RecordType.DeveloperName  FROM License_Registration__c WHERE Id =: RegistrationId];
        if(currentRegistration.Id != null) 
        currentFeeSummary = [SELECT Id FROM Fee_Summary__c WHERE Active__c = TRUE AND Registration__c =: currentRegistration.Id ORDER BY CreatedDate DESC LIMIT 1];
        
        errortype = '';
        errorDisplay = ''; 
        errormessage = '';
    }
    
    public Decimal getTotalFees() {
        return currentRegistration.Balance__c;
    }
    
    
    public List<Fee__c> getAllFees() {
       List<Fee__c> feesrec = [SELECT Id, Registration__c, Description__c, Fee__c FROM Fee__c WHERE Active__c = TRUE AND Registration__c =: RegistrationId];
       TotalFees = 0;
       for(Fee__c f: feesrec) {
           if(f.Fee__c != null)
               TotalFees += f.Fee__c;
       }
       //CBINOVI 2/26/2018 Overwrite fees with balance 
       TotalFees = currentRegistration.Balance__c;
       return feesrec;
    }
    
    public String PaymentType {get; set;}
    public List<SelectOption> getPaymentTypes() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('', ' -- Select -- '));
        //options.add(new SelectOption('Check', 'Check/ACH'));
        options.add(new SelectOption('Credit','Credit Card'));
        return options;
    }
    
    public PageReference EnterPaymentInfo() {
        ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c();
        if(String.isEmpty(PaymentType)) {
            errortype = 'alert alert-danger';
            errorDisplay = 'block'; 
            errormessage = 'Error: Please select a payment type.';
            return null;
        }
        
        // tken 06/12/2018
        Map<String,String> paymentGatewayMdt= new Map<String,String>();
        for(Registration_Payment_Gateway_Mapping__mdt pgmdt : [select id,DeveloperName, Record_Type_Name__c, Payment_Gateway_ID__c from Registration_Payment_Gateway_Mapping__mdt]){
            paymentGatewayMdt.put(pgmdt.Record_Type_Name__c, pgmdt.Payment_Gateway_ID__c );
        }
       
        System.debug('currentRegistration.RecordType.DeveloperName  :' + currentRegistration.RecordType.DeveloperName  );
        
        if(PaymentType == 'Check') {
            newChargentOrder.ChargentOrders__Payment_Method__c = 'Check';
            newChargentOrder.Registration__c  = currentRegistration.Id;
            newChargentOrder.Fee_Summary__c = currentFeeSummary.Id;
            newChargentOrder.ChargentOrders__Billing_Email__c = currentRegistration.Applicant__r.Email;
            newChargentOrder.ChargentOrders__Subtotal__c = TotalFees;
            newChargentOrder.ChargentOrders__Gateway__c = paymentGatewayMdt.get(currentRegistration.RecordType.DeveloperName);
            insert newChargentOrder;
            
            PageReference regPage = new PageReference('/CommunityPayCheck?id=' + newChargentOrder.Id);
            regPage.setRedirect(true);
            return regPage;
        }
        if(PaymentType == 'Credit') {
            newChargentOrder.ChargentOrders__Payment_Method__c = 'Credit Card';
            newChargentOrder.Registration__c  = currentRegistration.Id;
            newChargentOrder.Fee_Summary__c = currentFeeSummary.Id;
            newChargentOrder.ChargentOrders__Billing_Email__c = currentRegistration.Applicant__r.Email;
            newChargentOrder.ChargentOrders__Subtotal__c = TotalFees;
            newChargentOrder.ChargentOrders__Gateway__c = paymentGatewayMdt.get(currentRegistration.RecordType.DeveloperName);
            insert newChargentOrder;
            
            PageReference regPage = new PageReference('/CommunityPayCredit?id=' + newChargentOrder.Id);
            regPage.setRedirect(true);
            return regPage;
        }
        
        return null;
        
    }
    
     public PageReference CancelExit() {
        PageReference regPage = new PageReference('/CommunityRegistration');
        regPage.setRedirect(true);
        return regPage;
    }
    
}