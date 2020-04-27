public with sharing class payment_Methods {

    public static void afterInsert(List<Payment__c> newList){
        Map<Id,Pay_Period__c> positionPayPeriodMap =  new Map<Id,Pay_Period__c>();
        Set<Id> positionIds = new Set<Id>();
        Set<Id> payPeriodIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Position__c != null ){
                positionIds.add(newList[i].Position__c);
            }           
            if ( newList[i].Pay_Period__c != null ){
                payPeriodIds.add(newList[i].Pay_Period__c);
            }
        }
        Map<Id,Pay_Period__c> payPeriodMap = new Map<Id,Pay_Period__c>([Select Id, End_Date__c from Pay_Period__c where Id in :payPeriodIds]);
        Map<Id,Position__c> positionMap = new Map<Id,Position__c>([Select Id, Last_Pay_Period__c, Last_Pay_Period__r.Id, Last_Pay_Period__r.End_Date__c from Position__c where id in : positionIds]);
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Pay_Period__c != null && newList[i].Position__c != null && positionMap.containsKey(newList[i].Position__c) && payPeriodMap.containsKey(newList[i].Pay_Period__c) ){
                if ( positionMap.get(newList[i].Position__c).Last_Pay_Period__c == null || positionMap.get(newList[i].Position__c).Last_Pay_Period__r.End_Date__c == null ){
                    Position__c p = positionMap.get(newList[i].Position__c);
                    p.Last_Pay_Period__c = newList[i].Pay_Period__c;
                    positionMap.put(p.Id,p);
                } else if ( positionMap.get(newList[i].Position__c).Last_Pay_Period__r.End_Date__c < payPeriodMap.get(newList[i].Pay_Period__c).End_Date__c ){
                    Position__c p = positionMap.get(newList[i].Position__c);
                    p.Last_Pay_Period__c = newList[i].Pay_Period__c;
                    positionMap.put(p.Id,p);
                }
            }
        }           
        update positionMap.values();
    }

    public static void afterUpdate(List<Payment__c> newList, List<Payment__c> oldList){
        Map<Id,Pay_Period__c> positionPayPeriodMap =  new Map<Id,Pay_Period__c>();
        Set<Id> positionIds = new Set<Id>();
        Set<Id> payPeriodIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Position__c != null ){
                positionIds.add(newList[i].Position__c);
            }           
            if ( newList[i].Pay_Period__c != null ){
                payPeriodIds.add(newList[i].Pay_Period__c);
            }
        }
        Map<Id,Pay_Period__c> payPeriodMap = new Map<Id,Pay_Period__c>([Select Id, End_Date__c from Pay_Period__c where Id in :payPeriodIds]);
        Map<Id,Position__c> positionMap = new Map<Id,Position__c>([Select Id, Last_Pay_Period__c, Last_Pay_Period__r.Id, Last_Pay_Period__r.End_Date__c from Position__c where id in : positionIds]);
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Pay_Period__c != null && newList[i].Position__c != null && positionMap.containsKey(newList[i].Position__c) && payPeriodMap.containsKey(newList[i].Pay_Period__c) ){
                if ( positionMap.get(newList[i].Position__c).Last_Pay_Period__c == null || positionMap.get(newList[i].Position__c).Last_Pay_Period__r.End_Date__c == null ){
                    Position__c p = positionMap.get(newList[i].Position__c);
                    p.Last_Pay_Period__c = newList[i].Pay_Period__c;
                    positionMap.put(p.Id,p);
                } else if ( positionMap.get(newList[i].Position__c).Last_Pay_Period__r.End_Date__c < payPeriodMap.get(newList[i].Pay_Period__c).End_Date__c ){
                    Position__c p = positionMap.get(newList[i].Position__c);
                    p.Last_Pay_Period__c = newList[i].Pay_Period__c;
                    positionMap.put(p.Id,p);
                }
            }
        }           
        update positionMap.values();
    }

}