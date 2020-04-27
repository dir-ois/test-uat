global without sharing class RequestChecksBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<Id> payeeIds = new List<Id>();
    public List<Id> checkBatchIds = new List<Id>();
    
    public RequestChecksBatch(List<Id> pIds, List<Id> cbIds){
        payeeIds = pIds;
        checkBatchIds = cbIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        return Database.getQueryLocator('SELECT Id FROM Payee__c WHERE Id IN :payeeIds');
    }
    
    global void execute(Database.BatchableContext info, List<sObject> scope){
        List<Payee__c> payeeList = [SELECT Id, Name, Payee_Name__c, Case_Role__c, Factor__c, Payee_Type__c, Status__c, DIR_Office__c,
                                            Wage_Payable_Balance__c, Penalty_Payable_Balance__c, Other_Payable_Balance__c, Case_Management__c,
                                            Case_Management__r.Office__r.Office_Account__c,
                                            Case_Management__r.Employer__r.Subject_to_Garnishment__c,
                                            Case_Management__r.Employer__r.Subject_to_Lien__c, 
                        
                                        (SELECT Id, Receipt_Hold_Date__c, Liability_Payment__c, Payee__c, Payee__r.Id, Payee_Name__c,
                                                Check__c, Payment_Amount__c, Liability_Payment__r.Case_Payment__c, Liability_Payment__r.Case_Payment__r.Id,
                                                Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c,
                                                Judgment_Payment__c, Judgment_Payment__r.Case_Payment__c, Judgment_Payment__r.Case_Payment__r.Id,
                                                Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c
                                            FROM Payment_Records__r
                                            WHERE Check__c = null
                                            AND Check_Issued__c = false)

                                        FROM Payee__c
                                        WHERE Id IN :scope];
        
        List<Payment_Record__c> paymentRecordList = new List<Payment_Record__c>();
        for(Payee__c payee : payeeList){
            paymentRecordList.addAll(payee.Payment_Records__r);
        }
        
        List<Check_Batch__c> checkBatchList = [SELECT Id, Name, Office_Account__c
                                                FROM Check_Batch__c
                                                WHERE Id IN :checkBatchIds];
        
        List<Check__c> checksToInsert = new List<Check__c>();
        
        for(Check_Batch__c checkBatch : checkBatchList){
            for(Payee__c payee : payeeList){
                if(payee.Case_Management__r.Office__r.Office_Account__c == checkBatch.Office_Account__c){
                    Decimal checkAmount = 0.00;
                    for(Payment_Record__c paymentRecord : payee.Payment_Records__r){
                        checkAmount += paymentRecord.Payment_Amount__c;
                    }
                    if(checkAmount != 0.00){
                        Check__c check = new Check__c(
                            Payee__c = payee.Id,
                            Amount__c = checkAmount,
                            Case__c = payee.Case_Management__c,
                            Status__c = 'Pending Approval',
                            Check_Batch__c = checkBatch.Id,
                            Office_Account__c = checkBatch.Office_Account__c
                        );
                        checksToInsert.add(check);
                    }
                }
            }
        }
        insert checksToInsert;
            
        for(Check__c check : checksToInsert){
            for(Payment_Record__c pr : paymentRecordList){
                if(check.Payee__c == pr.Payee__c){
                    pr.Check__c = check.Id;
                }
            }
        }
        update paymentRecordList;
    }
  
  
  
  
  ////left off on Fri Mar 20 2020 :
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
        List<String> cbURLs = new List<String>();
        String body = '';
        
        for(Id checkBatchId : checkBatchIds){
            String cbURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + checkBatchId;
            body +=
                '<div style="font: bold 14px Arial; margin: 10px 0;">The Checks you requested have now been created. The link to (one of) the Check Batch(es) is: <a href="' + cbURL + '">' + cbURL + '</a><br/><br/></div>';           
        }
        
        body += '<div style="font: bold 16px Arial; margin: 10px 0;">AsyncApexJob:</div>';
        body += '<table style="font: normal 12px verdana;" border="1" cellpadding="5" cellspacing="0" width="100%">';
        body += '<tr style="font-weight: bold">';
        body += '<td>Total Job Items</td>';
        body += '<td>Job Items Processed</td>';
        body += '<td>Number of Errors</td>';
        body += '<td>Status</td>';
        //+ '<td>Apex Class Id</td>'
        body += '<td>Job Type</td>';
        body += '<td>Created By</td>';
        body += '<td>Created Date</td>';
        body += '<td>Completed Date</td>';
        body += '</tr>';
        body += '<tr>';
        body += '<td>' + job.TotalJobItems + '</td>';
        body += '<td>' + job.JobItemsProcessed + '</td>';
        body += '<td>' + job.NumberOfErrors + '</td>';
        //+ '<td>' + job.Status + cpLimitHit + '</td>'
        body += '<td>' + job.Status + '</td>';
        //+ '<td><a href="https://login.salesforce.com/' + job.ApexClassId + '">' + job.ApexClassId + '</a></td>'
        body += '<td>' + job.JobType + '</td>';
        body += '<td>' + job.CreatedBy.Name + '</td>';
        body += '<td>' + job.CreatedDate + '</td>';
        body += '<td>' + job.CompletedDate + '</td>';            
        body += '</tr>';            
        body += '</table>';            
        body += '<br/>';
        
        mail.setToAddresses(new List<String>{'mteixeira@dir.ca.gov'});
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(new List<String>{'mteixeira@dir.ca.gov','schandrasekar@dir.ca.gov'});
        mail.setSubject('Check Request Status - ' + job.Status);
        mail.setHtmlBody(body);
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}