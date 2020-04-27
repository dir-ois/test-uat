@isTest
private class ActivitiesTriggerHandlerTest {

    private static testMethod void activitiesTriggerHandlerTest() {
        
        Task objTask = new Task(Subject = 'Test',Days_out__c = 10,ActivityDate =  Date.today());
        insert  objTask;
        
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Event objEvent = new Event(Subject = 'Test',Days_out__c = 10,ActivityDateTime =  DateTime.Now(),DurationInMinutes = 10,WhatId = objAccount.Id);
        insert  objEvent;
        
        objTask.Days_out__c = 12;
        objEvent.Days_out__c = 12;
        update objTask;
        update objEvent;

        
    }

}