global class updateExistingRegForCheckBox implements Database.Batchable<sObject> {
    
        global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Attachments_Plus__c WHERE Attachment_Required__c =TRUE AND (Number_of_Attachments__c = 0 OR Number_of_Attachments__c = NULL)' 
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Attachments_Plus__c> scope){
        
        update scope;
           
    }
    
    global void finish(Database.BatchableContext bc){
        
    }    

}