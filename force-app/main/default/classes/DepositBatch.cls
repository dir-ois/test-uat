global without sharing class DepositBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<Id> rctIDs = new List<Id>();
    public Id trnId;
    
    public DepositBatch(List<Id> receiptIds, Id transactionId){
        rctIDs = receiptIds;
        trnId = transactionId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){ 

        return Database.getQueryLocator(
            'SELECT Id, Name, Transaction__c, Status__c, Deposit_Account__c, Office_Unit__c '
                + 'FROM Receipt__c '
                + 'WHERE Id IN :rctIDs'
            );
            
    }
    
    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<Receipt__c> scope = (List<Receipt__c>)scopeX;
        
        for(Receipt__c rct : scope){
            rct.Transaction__c = trnId;
            rct.Status__c = 'Deposit Pending';
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
        String trnURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + trnId;
        
        
        String body = ''
            + '<div style="font: bold 16px Arial; margin: 10px 0;">The Receipts you requested have now been deposited. Click or copy and paste this link into your browser: <a href="'+ trnURL   + '">' + trnURL +   '</a><br/><br/></div>'
            + '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>'
            + '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">'
            + '<tr style="font-weight: bold">'
            + '<td>Total Job Items</td>'
            + '<td>Job Items Processed</td>'
            + '<td>Number of Errors</td>'
            + '<td>Status</td>'
            //+ '<td>Apex Class Id</td>'
            + '<td>Job Type</td>'
            + '<td>Created By</td>'
            + '<td>Created Date</td>'
            + '<td>Completed Date</td>'
            + '</tr>'
            + '<tr>'
            + '<td>' + job.TotalJobItems + '</td>'
            + '<td>' + job.JobItemsProcessed + '</td>'
            + '<td>' + job.NumberOfErrors + '</td>'
            //+ '<td>' + job.Status + cpLimitHit + '</td>'
            + '<td>' + job.Status + '</td>'
            //+ '<td><a href="https://login.salesforce.com/' + job.ApexClassId + '">' + job.ApexClassId + '</a></td>'
            + '<td>' + job.JobType + '</td>'
            + '<td>' + job.CreatedBy.Name + '</td>'
            + '<td>' + job.CreatedDate + '</td>'
            + '<td>' + job.CompletedDate + '</td>'
            + '</tr>'
            + '</table>'
            + '<br/>';
        
        //mail.setToAddresses(new List<String>{'mteixeira@dir.ca.gov'});
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov','schandrasekar@dir.ca.gov'});
        mail.setSubject('Receipt Deposit Status - ' + job.Status);
        mail.setHtmlBody(body);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}