/********************************************************************************************************
Name:    purgeIncompleteRegistrations.cls
Author:  Shivam Goyal (shivam.goyal@sapient.com)
Date:    18/12/2018
Modified by: 
Date:
Test class: 

Behavior:
    Schedule a purge of all Registrations that are in an Incomplete Status and the Last Modified Date is greater than 30 days.
       
********************************************************************************************************/

global class purgeIncompleteRegistrations implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        
        Integer purgeDuration = integer.valueOf(Key_Value_Store__c.getValues('Purge Public Works Registrations').Value__c);
        String recordType = Key_Value_Store__c.getValues('Purge Public Works Registrations').Record_Type__c;
        date purgeDurDate;
        
        if(Test.isRunningTest())
        purgeDurDate = system.today().addDays(10);
        else
        purgeDurDate = system.today().addDays(-purgeDuration);        
        
        return Database.getQueryLocator(
            'SELECT ID FROM License_Registration__c ' +
            'where Status__c=\'Incomplete\' and Record_Type_Name__c= :recordType and LastModifiedDate <=:purgeDurDate' 
        );
    }
    
    global void execute(Database.BatchableContext bc, List<License_Registration__c> scope){
     
     if(scope.size()>0){
         delete scope;
     }    
    }
    
    global void finish(Database.BatchableContext bc){
        
    }    

}