global class EmailToSupportRequest implements Messaging.InboundEmailHandler {
 global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
    
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
          
        String myPlainText= '';     
            
        myPlainText = email.plainTextBody;  
        
        List<Support_Request__c> SRs = new List<Support_Request__c>();
            
        try {
            Support_Request__c SR = new Support_Request__c(Description__c = myPlainText, Subject__c = email.Subject);
            
            SRs.add(SR);
            
            insert SR;    
             
            System.debug('New SR: ' + SR);   
        } 
            
        catch (Exception e) {
            System.debug('Error is: ' + e);
        }   
          
        result.success = true;
         
        return result;
    }
}