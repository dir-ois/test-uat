/*Scheduled by the SchedulePRRollupToCMHack class, q.v. 
-Runs nightly.
-Queries Checks last modified within the past X days, then for each Case on those Checks, updates one of the child PRs, seemingly pointlessly,
    to trigger the PaymentRecordTrigger so PR.Payment_Amount__c rolls up to the CM.Funds_Drawn_on_Deposits__c.
-This is a kludge which should no longer be needed once the Cashiering Rearchitecting (Tier 3?) project is completed.*/
global without sharing class PRRollupToCMHack implements Database.Batchable<sObject>, Database.Stateful{
    
    Set<Payment_Record__c> prs = new Set<Payment_Record__c>();
    Set<Id> cmIds = new Set<Id>();
    Set<Payment_Record__c> prsToUpdate = new Set<Payment_Record__c>();
    
    
    global Database.QueryLocator start(Database.BatchableContext info){
        
        return Database.getQueryLocator(
            'SELECT Id, Name, Case__c, LastModifiedDate, '
                    + '(SELECT Id, Name, Payment_Amount__c, Payee__c, Payee__r.Case_Management__c, Payee__r.Case_Management__r.Id '
                        + 'FROM Payment_Records__r) '
                + 'FROM Check__c'
        );
    }
    
    
    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<Check__c> scope = (List<Check__c>)scopeX;
        
        for(Check__c chk : scope){
            prs.addAll(chk.Payment_Records__r);
        }
        
        for(Payment_Record__c pr : prs){
            cmIds.add(pr.Payee__r.Case_Management__r.Id);
        }
        
        for(Id cmId : cmIds){
            for(Payment_Record__c pr : prs){
                if(cmId == pr.Payee__r.Case_Management__r.Id){
                    prsToUpdate.add(pr);
                    break; //We only need to find one PR under a Case
                }
            }
        }
        
        List<Payment_Record__c> prsToUpdateList = new List<Payment_Record__c>(prsToUpdate);
        update prsToUpdateList;
    }
    
    global void finish(Database.BatchableContext info){ }
    
}