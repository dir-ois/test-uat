@isTest
private class GenerateAttachmentsPlusActionTEST {

    static testMethod void testCreateAttachmentsPlus() {
        History_Object_Configuration__c hoc1 = new History_Object_Configuration__c(
            Object_name__c = 'Case Violation',
            Object_API_Name__c = 'DIR_Violation__c',
            Active__c = true,
            Path_to_Case__c = 'Case__r'
        );
        insert hoc1;
        
        History_Object_Configuration__c hoc2 = new History_Object_Configuration__c(
            Object_name__c = 'Attachment',
            Object_API_Name__c = 'Attachment',
            Active__c = true
        );
        insert hoc2;
        
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
        
        Attachment_Configuration__c ac = new Attachment_Configuration__c(
            History_Object_Configuration__c = hoc2.Id,
            Active__c = true,
            Attachment_Criteria__c = 'test',
            Attachment_Operator__c = 'Starts With',
            Confidential__c = true,
            Not_Subject_to_PRA__c = true,
            Attorney_Client_Privilege__c = true,
            Type__c = 'test type'
        );
        insert ac;
         
        Attachment att = new Attachment(
            parentId = viol.Id,
            Name = 'test attachment',
            body = blob.valueOf('test')
        );
        insert att;
        
        Attachment_Configuration__c ac1 = new Attachment_Configuration__c(
            History_Object_Configuration__c = hoc2.Id,
            Active__c = true,
            Attachment_Criteria__c = 'test2',
            Attachment_Operator__c = 'Contains',
            Confidential__c = true,
            Not_Subject_to_PRA__c = true,
            Attorney_Client_Privilege__c = true,
            Type__c = 'test type'
        );
        insert ac1;
        
		Attachment_Configuration__c ac3 = new Attachment_Configuration__c(
            History_Object_Configuration__c = hoc2.Id,
            Active__c = true,
            Attachment_Criteria__c = 'test2',
            Attachment_Operator__c = 'Equals',
            Confidential__c = true,
            Not_Subject_to_PRA__c = true,
            Attorney_Client_Privilege__c = true,
            Type__c = 'test type'
        );
        insert ac3;
         
        Attachment att1 = new Attachment(
            parentId = viol.Id,
            Name = 'test attachment',
            body = blob.valueOf('test2')
        );
        insert att1;
        
        Attachments_Plus__c a = [SELECT Id, Confidential__c, Not_Subject_to_PRA__c, Attorney_Client_Privilege__c, Type__c FROM Attachments_Plus__c LIMIT 1];
        
        system.assertEquals(a.Confidential__c, ac.Confidential__c);
        system.assertEquals(a.Not_Subject_to_PRA__c, ac.Not_Subject_to_PRA__c);
        system.assertEquals(a.Attorney_Client_Privilege__c, ac.Attorney_Client_Privilege__c);
        system.assertEquals(a.Type__c, ac.Type__c);
    }
}