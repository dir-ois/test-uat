@isTest(SeeAllData=false)
private class FieldUpdateConfigControllerTest {

    static testMethod void testFieldHistoryConfig() {
        
        RecordType violRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Violation__c' AND Name LIKE '%BOFE%' AND IsActive = true LIMIT 1];
        
        History_Object_Configuration__c hoc = new History_Object_Configuration__c(
            Object_name__c = 'Case Violation',
            Object_API_Name__c = 'DIR_Violation__c',
            Active__c = true,
            Path_to_Case__c = 'Case__r'
        );
        insert hoc;
        
        History_Field_Configuration__c hfc = new History_Field_Configuration__c(
            History_Object_Configuration__c = hoc.Id,
            Active__c = true,
            API_Field_Name__c = 'Status__c',
            Tracked_Record_Types__c = violRT.Id
        );
        insert hfc;
        
        test.startTest();
        
        FieldUpdateConfigController fcc = new FieldUpdateConfigController();
        fcc.selectedType = 'fu';
        fcc.getSelected();
        fcc.selectedObject = 'DIR_Violation__c';
        fcc.renderSecondStep();
        fcc.fwList[0].rtMap.get(fcc.rtList[0].Id).selected = true;
        fcc.saveSelected();
        
        test.stopTest();
    }
    
    static testMethod void testActivityHistoryConfig() {
        
        History_Object_Configuration__c hocTask = new History_Object_Configuration__c(
            Object_name__c = 'Task',
            Object_API_Name__c = 'Task',
            Active__c = true
        );
        insert hocTask;
        
        History_Object_Configuration__c hocEvent = new History_Object_Configuration__c(
            Object_name__c = 'Event',
            Object_API_Name__c = 'Event',
            Active__c = true
        );
        insert hocEvent;
        
        Activity_Configuration__c acTask = new Activity_Configuration__c(
            History_Object_Configuration__c = hocTask.Id,
            Active__c = true,
            Activity_Type__c = 'Meeting',
            Tracked_Statuses__c = 'Not Started;'
        );
        insert acTask;
        
        Activity_Configuration__c acEvent = new Activity_Configuration__c(
            History_Object_Configuration__c = hocEvent.Id,
            Active__c = true,
            Activity_Type__c = 'Call',
            Tracked_Statuses__c = 'Not Started;'
        );
        insert acEvent;
        
        test.startTest();
        
        FieldUpdateConfigController fcc = new FieldUpdateConfigController();
        fcc.selectedType = 'act';
        fcc.getSelected();
        fcc.renderSecondStep();
        fcc.saveActivityConfig();
        
        test.stopTest();
    }
    
    static testMethod void testAttachmentHistoryConfig() {
        History_Object_Configuration__c hoc = new History_Object_Configuration__c(
            Object_name__c = 'Attachment',
            Object_API_Name__c = 'Attachment',
            Active__c = true
        );
        insert hoc;
        
        Attachment_Configuration__c ac = new Attachment_Configuration__c(
            History_Object_Configuration__c = hoc.Id,
            Active__c = true,
            Attachment_Criteria__c = 'test',
            Attachment_Operator__c = 'test',
            Type__c = 'TBD'
        );
        insert ac;
        
        test.startTest();
        
        FieldUpdateConfigController fcc = new FieldUpdateConfigController();
        fcc.selectedType = 'att';
        fcc.getSelected();
        fcc.renderSecondStep();
        fcc.newFilter.Attachment_Criteria__c = 'test2';
        fcc.newFilter.Attachment_Operator__c = 'test2';
        fcc.addNewFilter();
        fcc.selectedAttId = 'NEW';
        fcc.saveFilter();
        fcc.addNewFilter();
        fcc.newFilter = ac.clone();
        ac.Attachment_Criteria__c = 'test Update';
        fcc.selectedAttId = ac.Id;
        fcc.editFilter();
        fcc.saveFilter();
        test.stopTest();
    }
}