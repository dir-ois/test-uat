/********************************************************************************************************

Name:  UpdateLaborCodeViolationBatch.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  09/15/2017
Modified by: 
Date:

Behavior:
Updates all Report_of_Labor_Code_Violation__c records triggering RLCVAll.trigger to update 
DIR_Case__c.Violation_Type__c

Open Developer Console -> Debug -> Open Execute Anonymous Window 
Copy/Paste the code below and push Execute

UpdateLaborCodeViolationBatch  inF = new UpdateLaborCodeViolationBatch();
Database.executeBatch(inF, 50);

****************************************************************************************************************************/

global class UpdateLaborCodeViolationBatch implements Database.Batchable<sobject> {
  
    global Database.QueryLocator start(database.BatchableContext bc ){
        String query = 'SELECT Id FROM Report_of_Labor_Code_Violation__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<Report_of_Labor_Code_Violation__c> scope ) {
        update scope;
    }
    
    global void finish(Database.BatchableContext bc){
       
    }
}