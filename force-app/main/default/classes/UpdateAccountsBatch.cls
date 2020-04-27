/********************************************************************************************************

Name:  UpdateAccountsBatch.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  10/02/2017
Modified by: 
Date:

Behavior:
Updates all Accounts records triggering dlrs_AccountTrigger.trigger to update 
Number of Pending L&R

Open Developer Console -> Debug -> Open Execute Anonymous Window 
Copy/Paste the code below and push Execute

UpdateAccountsBatch uab = new UpdateAccountsBatch();
Database.executeBatch(uab, 50);

****************************************************************************************************************************/
global class UpdateAccountsBatch implements Database.Batchable<sobject> {
  
    global Database.QueryLocator start(database.BatchableContext bc ){
        String query = 'SELECT Id FROM Account';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<Account> scope ) {
        update scope;
    }
    
    global void finish(Database.BatchableContext bc){
       
    }
}