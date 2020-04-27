global without sharing class TransmittalBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Id transmittalId;
    
    public String cpsEligible = '';
    
    
    public TransmittalBatch(Id transId) {
        transmittalId = transId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){ 

        //TODO: verify these filters, clean up extraneous filters
        return Database.getQueryLocator(
            'SELECT Id, Transmittal__c, Transmittal_Unit__c, Status__c, Case__c, Case__r.Id '
                + 'FROM Case_Payment__c '
                + 'WHERE RecordType.Name = \'Posted\' '
                    + 'AND Status__c = \'Posted\' '
                    + 'AND Transmittal__c = null '
                    + 'AND (Transmittal_Unit__c = \'CCU 32\' '
                        + 'OR Transmittal_Unit__c = \'JEU\' '
                        + 'OR Transmittal_Unit__c = \'RCI\') '
                    + 'AND (Case__r.RecordType.Name LIKE \'%BOFE%\' '
                        + 'OR Case__r.RecordType.Name LIKE \'%PASS%\' '
                        + 'OR Case__r.RecordType.Name LIKE \'%RCI%\' '
                        + 'OR Case__r.RecordType.Name LIKE \'%JEU%\')'
        );
        
    }
    
    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<Case_Payment__c> scope = (List<Case_Payment__c>)scopeX;
        
        if(scope.isEmpty()){
            cpsEligible = '<br>There were no unbatched Case Payments that fit the criteria for Transmittal batching. This Transmittal has zero Case Payments.';
        }else{
            for(Case_Payment__c cp : scope) {
                cp.Transmittal__c = transmittalId;
            }
            update scope; 
        }
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
        String transURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + transmittalId;
        string html = ''
            + '<div style="font: bold 16px Arial; margin: 10px 0;">The transmittal you requested is now complete. You can now run the transmittal report to see the results.</div><br/>'
            + '<div style="font: bold 16px Arial; margin: 10px 0;">If there was at least one item in the batch, click <a href="'+ transURL + '">here</a> to view the Transmittal record, or copy and paste this link into your browser: <a href="'+ transURL + '">' + transURL + '</a><br/><br/></div>'
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
            + '<td>' + job.Status + cpsEligible + '</td>'
            //+ '<td><a href="https://login.salesforce.com/' + job.ApexClassId + '">' + job.ApexClassId + '</a></td>'
            + '<td>' + job.JobType + '</td>'
            + '<td>' + job.CreatedBy.Name + '</td>'
            + '<td>' + job.CreatedDate + '</td>'
            + '<td>' + job.CompletedDate + '</td>'
            + '</tr>'
            + '</table>'
            + '<br/>';
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov'});
        mail.setSubject('Transmittal Batch - ' + job.Status);
        mail.setHtmlBody(html);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}