public class registerationSuccessController {
    
    public Id regId {get;set;}
    public Boolean showMoreDetails {get;set;}
    public License_Registration__c newReg{get;set;}
    
    public registerationSuccessController(){
        
        showMoreDetails = false;
        
        try{
        regId = apexpages.currentpage().getparameters().get('id');    
        newReg = [SELECT id,Effective_Date__c,No_of_Years__c,renewal__c,Expiration_Date__c FROM License_Registration__c where id= :regId];
        if(!newReg.renewal__c){
            showMoreDetails = true;
        }            
        }catch(Exception e){
          showMoreDetails = false;  
        }

    }
    
    public pagereference redirectToHomePage(){
        pagereference pr = new pagereference('/registrations/apex/CommunityRegistration');
        return pr;
    }

}