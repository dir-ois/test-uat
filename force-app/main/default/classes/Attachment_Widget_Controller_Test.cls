@isTest(SeeAllData=false)
private class Attachment_Widget_Controller_Test {
  
    static testMethod void testAttachment_Widget_Controller() {
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'Name Display';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        Account a = new Account();
        a.Name = 'test account'+system.now();
        insert a;
        
        Contact con = new Contact();
        con.AccountId = a.id;
        con.LastName = 'lastName';
        insert con;
        
        License_Registration__c lr = new License_Registration__c();
        lr.Account__c = a.id;
        lr.Applicant__c = con.id;
        lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        insert lr;
        
        Attachments_Plus__c attPlus = new Attachments_Plus__c(
        Attachment_Name__c = 'test att name', 
        Registration__c = lr.id,
        //Attachment_URL__c, 
        Description__c = 'test desc', 
        //Object__c, 
        //Record_ID__c = cm.Id, 
        Type__c = '', 
        Attorney_Client_Privilege__c = true, 
        Confidential__c = true, 
        Not_Subject_to_PRA__c = true,
        VIP_Form_Section__c = section.id
        );
        insert attPlus;
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'file_name.pdf';
        conVer.Title = 'file_name.pdf';
        conVer.VersionData = blob.valueOf('text file');
        conVer.Origin = 'C';
        insert conVer;
        
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = [select id, ContentDocumentId from ContentVersion where id = :conVer.id].ContentDocumentId;
        cDe.LinkedEntityId = attPlus.id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
        Attachments_Plus__c attPlus1 = new Attachments_Plus__c(
        Attachment_Name__c = 'test att name', 
        Registration__c = lr.id,
        //Attachment_URL__c, 
        Description__c = 'test desc', 
        //Object__c, 
        //Record_ID__c = cm.Id, 
        Type__c = 'Unknown', 
        Attorney_Client_Privilege__c = true, 
        Confidential__c = true, 
        Not_Subject_to_PRA__c = true,
        VIP_Form_Section__c = section.id
        );
        insert attPlus1;
        
        
        Attachments_Plus__c attPlus2 = new Attachments_Plus__c(
        Attachment_Name__c = 'test att name', 
        Registration__c = lr.id,
        //Attachment_URL__c, 
        Description__c = 'test desc', 
        //Object__c, 
        //Record_ID__c = cm.Id, 
        Type__c = 'Subpoena', 
        Attorney_Client_Privilege__c = true, 
        Confidential__c = true, 
        Not_Subject_to_PRA__c = true,
        VIP_Form_Section__c = section.id
        );
        insert attPlus2;
        
        test.startTest();
        
        pageReference pageRef = Page.Attachment_Widget;
        pageRef.getParameters().put('id',lr.id);
        pageRef.getParameters().put('sectionId',section.id);
        system.Test.setCurrentPage(pageRef);
        
        Attachment att = new Attachment(
            Body = blob.valueOf('test body'),
            Name = 'testname.pdf',
            isPrivate = false
        );
        
        Attachment att1 = new Attachment(
            Body = blob.valueOf('test body'),
            Name = 'testname.pdf',
            isPrivate = false
        );
        
        Attachment_Widget_Controller controller = new Attachment_Widget_Controller();
        //controller.attTable = new List<Attachment_Widget_Controller.AttachmentTable>();
        
        controller.attTable.add(new Attachment_Widget_Controller.AttachmentTable(false,attPlus1,null,null));
        controller.attTable[1].att = att;
        controller.attTable.add(new Attachment_Widget_Controller.AttachmentTable(false,attPlus2,null,null));
        controller.attTable[2].att = att1;
        controller.attachPDF();
        //controller.updateAttTable();
        
        pageRef.getParameters().put('delID',attPlus.id);
        controller.deleteAttachment();
        
        test.stopTest();
    
    }  
    
    static testMethod void testAttachment_Widget_Controller1() {
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'Name Display';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        Account a = new Account();
        a.Name = 'test account'+system.now();
        insert a;
        
        Contact con = new Contact();
        con.AccountId = a.id;
        con.LastName = 'lastName';
        insert con;
        
        License_Registration__c lr = new License_Registration__c();
        lr.Account__c = a.id;
        lr.Applicant__c = con.id;
        lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        insert lr;
        
        Attachments_Plus__c attPlus = new Attachments_Plus__c(
        Attachment_Name__c = 'test att name', 
        Registration__c = lr.id,
        //Attachment_URL__c, 
        Description__c = 'test desc', 
        //Object__c, 
        //Record_ID__c = cm.Id, 
        Type__c = '', 
        Attorney_Client_Privilege__c = true, 
        Confidential__c = true, 
        Not_Subject_to_PRA__c = true,
        VIP_Form_Section__c = section.id
        );
        insert attPlus;
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'file_name.pdf';
        conVer.Title = 'file_name.pdf';
        conVer.VersionData = blob.valueOf('text file');
        conVer.Origin = 'C';
        insert conVer;
        
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = [select id, ContentDocumentId from ContentVersion where id = :conVer.id].ContentDocumentId;
        cDe.LinkedEntityId = attPlus.id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
        Attachments_Plus__c attPlus1 = new Attachments_Plus__c(
        Attachment_Name__c = 'test att name', 
        Registration__c = lr.id,
        //Attachment_URL__c, 
        Description__c = 'test desc', 
        //Object__c, 
        //Record_ID__c = cm.Id, 
        Type__c = 'Unknown', 
        Attorney_Client_Privilege__c = true, 
        Confidential__c = true, 
        Not_Subject_to_PRA__c = true,
        VIP_Form_Section__c = section.id
        );
        insert attPlus1;
        
        
        Attachments_Plus__c attPlus2 = new Attachments_Plus__c(
        Attachment_Name__c = 'test att name', 
        Registration__c = lr.id,
        //Attachment_URL__c, 
        Description__c = 'test desc', 
        //Object__c, 
        //Record_ID__c = cm.Id, 
        Type__c = 'Subpoena', 
        Attorney_Client_Privilege__c = true, 
        Confidential__c = true, 
        Not_Subject_to_PRA__c = true,
        VIP_Form_Section__c = section.id
        );
        insert attPlus2;
        
        test.startTest();
        
        pageReference pageRef = Page.Attachment_Widget;
        pageRef.getParameters().put('id',lr.id);
        pageRef.getParameters().put('sectionId',section.id);
        system.Test.setCurrentPage(pageRef);
        
        Attachment att = new Attachment(
            Body = blob.valueOf('test body'),
            Name = 'testname.pdf',
            isPrivate = false
        );
        
        Attachment att1 = new Attachment(
            Body = blob.valueOf('test body'),
            Name = 'testname.txt',
            isPrivate = false
        );
        
        Attachment_Widget_Controller controller = new Attachment_Widget_Controller();
        //controller.attTable = new List<Attachment_Widget_Controller.AttachmentTable>();
        controller.updateAttTable();
        controller.attTable.add(new Attachment_Widget_Controller.AttachmentTable(false,attPlus1,null,null));
        controller.attTable[1].att = att;
        controller.attTable.add(new Attachment_Widget_Controller.AttachmentTable(false,attPlus2,null,null));
        controller.attTable[2].att = att1;
        controller.attachPDF();
        //controller.updateAttTable();
        
        pageRef.getParameters().put('delID',attPlus.id);
        controller.deleteAttachment();
        
        test.stopTest();
    
    }  
}