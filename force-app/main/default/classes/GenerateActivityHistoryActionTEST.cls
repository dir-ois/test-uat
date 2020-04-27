@isTest(SeeAllData=false)
private class GenerateActivityHistoryActionTEST {

    static testMethod void testGenerateActivityHistory() {
        
        List<History_Object_Configuration__c> hocList = new List<History_Object_Configuration__c>();

        History_Object_Configuration__c hoc1 = new History_Object_Configuration__c(
            Object_name__c = 'Case Violation',
            Object_API_Name__c = 'DIR_Violation__c',
            Active__c = true,
            Path_to_Case__c = 'Case__r'
        );
        hocList.add(hoc1);
        
        History_Object_Configuration__c hoc2 = new History_Object_Configuration__c(
            Object_name__c = 'Event',
            Object_API_Name__c = 'Event',
            Active__c = true
        );
        hocList.add(hoc2);

        History_Object_Configuration__c hoc3 = new History_Object_Configuration__c(
            Object_name__c = 'Task',
            Object_API_Name__c = 'Task',
            Active__c = true
        );
        hocList.add(hoc3);

        insert hocList;
        
        RecordType caseRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Case__c' AND IsActive = true LIMIT 1];
                
        DIR_Case__c dirCase = new DIR_Case__c(
            RecordTypeId = caseRT.Id
        );
        insert dirCase;
        
        RecordType violRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Violation__c' AND Name LIKE '%BOFE%' AND IsActive = true LIMIT 1];

        Assessments__c assess = new Assessments__c(
            Case_Management__c = dirCase.Id
            );
        insert assess;
        
        DIR_Violation__c viol = new DIR_Violation__c(
            Case__c = dirCase.Id,
            Assessment__c = assess.Id,
            Status__c = 'Open',
            RecordTypeId = violRT.Id
        );
        insert viol;

        List<Activity_Configuration__c> acList = new List<Activity_Configuration__c>();

        Activity_Configuration__c ac = new Activity_Configuration__c(
            History_Object_Configuration__c = hoc3.Id,
            Active__c = true,
            Activity_Type__c = 'Call',
            Tracked_Statuses__c = 'In Progress'
        );
        acList.add(ac);
        
        Activity_Configuration__c ac2 = new Activity_Configuration__c(
            History_Object_Configuration__c = hoc2.Id,
            Active__c = true,
            Activity_Type__c = 'Call'
        );
        acList.add(ac2);

        insert acList;

        Task t =  new Task(
            WhatId = viol.Id,
            Subject = 'test Task',
            Type = 'Call',
            Status = 'Not Started'
        );
        insert t;

        t.Status = 'In Progress';
        update t;
        
        Event e = new Event(
            WhatId = viol.Id,
            Subject = 'Test',
            startDateTime = date.today(),
            endDateTime = date.today() + 1,
            Type = 'Call'
        );
        insert e;
        
        
        Event e1 = new Event(
            WhatId = dirCase.Id,
            Subject = 'Test',
            startDateTime = date.today(),
            endDateTime = date.today() + 1,
            Type = 'Call'
        );
        insert e1;
        
        e1.Event_Status__c = 'Cancelled';
        update e1;
        
        GenerateActivityHistoryAction.executeFromFlow(new List<String>());

    }
}