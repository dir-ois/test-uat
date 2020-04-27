global without sharing class CaseIssueBatch implements Database.Batchable<sObject>, Database.Stateful { 
   
    public CaseIssueBatch() {
        
    }
   
    global Database.QueryLocator start(Database.BatchableContext info){
        
		string q = 'Select Id, Fiscal_Reclass__c from DIR_Violation__c where RecordTypeId = \'' + getBofeRT() + '\'' +
            ' and ' + 'Fiscal_Year__c = \'' + getYear()  + '\'' + ' and ' + 'Fiscal_Reclass__c = false';
        return Database.getQueryLocator(q);
    }

    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<DIR_Violation__c> scope = (List<DIR_Violation__c>)scopeX;
        System.debug('execute');     
        for(DIR_Violation__c ci : scope) { 
             ci.Fiscal_Reclass__c = true;
        }
        update scope; 
    }
    
    global void finish(Database.BatchableContext info) {
        AsyncApexJob job = [Select Id, ApexClassId, CompletedDate, CreatedBy.Email, CreatedBy.Name,
            CreatedDate, JobItemsProcessed, JobType, NumberOfErrors, Status, 
            TotalJobItems from AsyncApexJob where Id = :info.getJobId()];
            
            sendJobCompleteEmail(job);
    }
    
    private void sendJobCompleteEmail(AsyncApexJob job) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};
        String html = ''
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
            //+ '<td><a href="https://login.salesforce.com/' + job.ApexClassId + '">' + job.ApexClassId + '</a></td>'
            + '<td>' + job.JobType + '</td>'
            + '<td>' + job.CreatedBy.Name + '</td>'
            + '<td>' + job.CreatedDate + '</td>'
            + '<td>' + job.CompletedDate + '</td>'
            + '</tr>'
            + '</table>'
            + '<br/>';
        mail.setToAddresses(toAddresses);
        mail.setSubject('Case Issue Batch - ' + job.Status);
        mail.setHtmlBody(html);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    private String getYear() {
        // year = current year - 2
    	Integer cdt = system.today().year() - 2;
    	String year = String.valueOf(cdt);
    	return year;
  	}
    
    private String getBofeRT(){
         return Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
    }
}