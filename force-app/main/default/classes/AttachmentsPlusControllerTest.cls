@isTest(SeeAllData=false)
private class AttachmentsPlusControllerTest {
    
    static testMethod void testAttachmentsPlusController() {
        Account a = new Account();
        a.Name = 'test account'+system.now();
        insert a;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de;
        
        DIR_Case__c cm = new DIR_Case__c();
        cm.Employer__c = a.Id;
        cm.Status__c = 'Open';
        cm.Assigned_Deputy__c = de.Id;
        cm.RecordtypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert cm;

        Attachment att = new Attachment(
            Body = blob.valueOf('test body'),
            Name = 'test name',
            isPrivate = false,
            ParentId = cm.Id
        );
        insert att;
        
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        //temp.VIPForm__Form_Style__c = 'Vertical Navigation';
        insert temp;
        
        
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'WCI Documentation';
        section.Name = 'WCI Documentation';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
       
        
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
            Attachment_ID__c = att.Id, 
            Attachment_Name__c = 'test att name', 
            Registration__c = lr.id,
            //Attachment_URL__c, 
            Description__c = 'test desc', 
            //Object__c, 
            Record_ID__c = cm.Id, 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section.Id
        );
        insert attPlus;

        Attachments_Plus__c attPlus1 = new Attachments_Plus__c(
            Attachment_ID__c = att.Id, 
            Attachment_Name__c = 'test att name', 
            //Attachment_URL__c, 
            Description__c = 'test desc', 
            //Object__c, 
            Record_ID__c = cm.Id, 
            Type__c = 'Unknown', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true
        );
        insert attPlus1;

        Attachments_Plus__c attPlus2 = new Attachments_Plus__c(
            Attachment_ID__c = att.Id, 
            Attachment_Name__c = 'test att name', 
            //Attachment_URL__c, 
            Description__c = 'test desc', 
            //Object__c, 
            Record_ID__c = cm.Id, 
            Type__c = 'Subpoena', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true
        );

        test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(cm);
        AttachmentsPlusController controller = new AttachmentsPlusController(sc);
        pageReference pageRef = Page.addAttachmentsPlus;
        system.Test.setCurrentPage(pageRef);

        controller.fname = att.Name;
        controller.body = att.Body;
        controller.newAttPlus = attPlus2;

        attPlus.Description__c = 'test new desc';
        String jsonStr = getJsonString(attPlus);
        AttachmentsPlusController.updateAttAction(jsonStr);

        attPlus = [
                   SELECT Id, Name, OwnerId, Attachment_ID__c, Attachment_Name__c, Attachment_URL__c, Description__c, Object__c, Record_ID__c, Type__c, Attorney_Client_Privilege__c, Confidential__c, Not_Subject_to_PRA__c
                   FROM Attachments_Plus__c
                   WHERE Id =: attPlus.Id
                  ];

        system.assertEquals(attPlus.Description__c, 'test new desc');

        AttachmentsPlusController.deleteAttAction(attPlus.Id);

        Attachments_Plus__c deletedAttPlus;
        try{
            deletedAttPlus = [
                              SELECT Id, Name, OwnerId, Attachment_ID__c, Attachment_Name__c, Attachment_URL__c, Description__c, Object__c, Record_ID__c, Type__c, Attorney_Client_Privilege__c, Confidential__c, Not_Subject_to_PRA__c
                              FROM Attachments_Plus__c
                              WHERE Id =: attPlus.Id
                             ];
        }
        catch(exception e){
            system.assertEquals(null, deletedAttPlus);
        }

        controller.newAttPlus = attPlus;
        controller.saveAttachment();
        controller.queryAttsPlus();

        system.assertNotEquals(null, controller.attPlusList);

        test.stopTest();

    }

    private static String getJsonString(Attachments_Plus__c ap){
        String jsonStr = ''
        +'{'
            +'"Id":"'+ap.Id+'",'
            +'"Attachment_Name__c":"'+ap.Name+'",'
            +'"Description__c":"'+ap.Description__c+'",'
            +'"Type__c":"'+ap.Type__c+'",'
            +'"Attorney_Client_Privilege__c":"'+ap.Attorney_Client_Privilege__c+'",'
            +'"Not_Subject_to_PRA__c":"'+ap.Not_Subject_to_PRA__c+'",'
            +'"Confidential__c":"'+ap.Confidential__c+'"'
        +'}';

        return jsonStr;
    }
    
}