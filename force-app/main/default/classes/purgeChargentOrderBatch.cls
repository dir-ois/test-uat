/********************************************************************************************************
Name:  purgeChargentOrderBatch.cls
Author:  vertiba
Date:  11/15/2018
Modified by: 
Date:
Test class: 

Behavior: Fetch All chargent orders without payment information and  the Chargent Order record is older than 7 days.
            Delete chargent orders.
********************************************************************************************************/
global without sharing class purgeChargentOrderBatch implements Database.Batchable<sObject>, Database.Stateful { 
    @TestVisible
    private DateTime lastweek = System.now().addDays(-1);
    
    public purgeChargentOrderBatch() {
        
    }
   
    global Database.QueryLocator start(Database.BatchableContext info){
        //DateTime lastweek = System.now().addDays(-7);
        //testing purpose
        //DateTime lastweek = System.now().addDays(-1);
        //get all chargent orders without payment information
        string q = 'SELECT Id, Name FROM ChargentOrders__ChargentOrder__c WHERE Id NOT IN (SELECT ChargentOrders__Order__c FROM ChargentOrders__Transaction__c) AND CreatedDate <=:lastweek';
        return Database.getQueryLocator(q);
    }

    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<ChargentOrders__ChargentOrder__c > scope = (List<ChargentOrders__ChargentOrder__c >)scopeX;
        //Delete all the chargent orders without associated transactin records        
        Delete scope;
        
    }
    
    global void finish(Database.BatchableContext info) {
        
    }
    
   
}