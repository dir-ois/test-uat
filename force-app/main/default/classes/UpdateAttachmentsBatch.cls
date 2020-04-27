/********************************************************************************************************

Name:  UpdateAttachmentsBatch.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  09/15/2017
Modified by: 
Date:

Behavior:
Updates all Attachments_Plus__c records triggering allAttPlus.trigger to update 
Attachments_Plus__c.Publicly_Accessible__c and DIR_Case__c.Submission_Detail_Type__c

Open Developer Console -> Debug -> Open Execute Anonymous Window 
Copy/Paste the code below and push Execute

UpdateAttachmentsBatch  inF = new UpdateAttachmentsBatch ();
Database.executeBatch(inF, 50);

****************************************************************************************************************************/
global class UpdateAttachmentsBatch implements Database.Batchable<sobject> {
  
    global Database.QueryLocator start(database.BatchableContext bc ){
        String query = 'SELECT Id FROM Attachments_Plus__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<Attachments_Plus__c> scope ) {
        update scope;
    }
    
    global void finish(Database.BatchableContext bc){
       
    }
}