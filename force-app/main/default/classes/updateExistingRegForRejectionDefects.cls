global class updateExistingRegForRejectionDefects implements Database.Batchable<sObject> {
    
        global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID FROM Rejection_Defect__c where Applies__c=true and Resolved__c=false' 
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Rejection_Defect__c> scope){
        
        System.debug('scope--'+scope);
        update scope;
           
    }
    
    global void finish(Database.BatchableContext bc){
        
    }    

}