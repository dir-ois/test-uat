/*
Called by the TransactionCustomObjectTrigger class.
Updates the status on all Receipts under a Transaction to "Deposited".
Batched because updating the RCT status affects the CP status, which in turn updates the Cash Balance on Case, which in turn triggers all the Case Management automation, yadda, yadda, yadda.
*/
global without sharing class AccountingDepositBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Set<Id> trnIds = new Set<Id>();
    
    public AccountingDepositBatch(Set<Id> transactionIds){
        trnIds = transactionIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        
        return Database.getQueryLocator(
            'SELECT Id, Name, Transaction__c, Status__c, Deposit_Account__c, Office_Unit__c, Payment_Can_Be_Processed__c '
                + 'FROM Receipt__c '
                + 'WHERE Payment_Can_Be_Processed__c = TRUE '
                    + 'AND Status__c != \'Mailed to Employee\' '
                    + 'AND Status__c != \'Returned to Sender\' '
                    + 'AND Transaction__c IN :trnIds'
        );
    }
    
    
    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<Receipt__c> scope = (List<Receipt__c>)scopeX;
        
        for(Receipt__c rct : scope){
            rct.Status__c = 'Deposited';
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext info) {
        AsyncApexJob job = [SELECT Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
                                CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :info.getJobId()];
        
        sendJobCompleteEmail(job);
    }
    
    
    private void sendJobCompleteEmail(AsyncApexJob job) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};
        
        List<String> trnURLhtmls = new List<String>();
        for(Id trnId : trnIds){ //get links for all bulkified TRNs--TODO: there must be a cleaner way to logic this
            String trnURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + trnId;
            String trnURLhtml = '<a href="'+ trnURL + '">' + trnURL + '</a><br/>'; 
            trnURLhtmls.add(trnURLhtml);
        }
        
        //String trnURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + trnIds[0];
        
        
        String body = ''
            + '<div style="font: bold 16px Arial; margin: 10px 0;">The Transaction you updated has now been marked deposited. Click or copy and paste this link into your browser: ' + String.join(trnURLhtmls, '<br/>') + '<br/><br/></div>'
            + '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
            + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
            + '<tr style="font-weight: bold">'
            + '<td>Total Job Items</td>'
            + '<td>Job Items Processed</td>'
            + '<td>Number of Errors</td>'
            + '<td>Status</td>'
            + '<td>Job Type</td>'
            + '<td>Created By</td>'
            + '<td>Created Date</td>'
            + '<td>Completed Date</td>'
            + '</tr>'
            + '<tr>'
            + '<td>' + job.TotalJobItems + '</td>'
            + '<td>' + job.JobItemsProcessed + '</td>'
            + '<td>' + job.NumberOfErrors + '</td>'
            + '<td>' + job.Status + '</td>'
            + '<td>' + job.JobType + '</td>'
            + '<td>' + job.CreatedBy.Name + '</td>'
            + '<td>' + job.CreatedDate + '</td>'
            + '<td>' + job.CompletedDate + '</td>'
            + '</tr>'
            + '</table>'
            + '<br/>';
        
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov','schandrasekar@dir.ca.gov'});
        mail.setSubject('Transaction Deposit Status - ' + job.Status);
        mail.setHtmlBody(body);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
}