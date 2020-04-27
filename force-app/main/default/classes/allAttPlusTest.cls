@istest
public class allAttPlusTest {
      static testMethod void testallAttPlusTest() {
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        //temp.VIPForm__Form_Style__c = 'Vertical Navigation';
        insert temp;
        
        
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'WCI Documentation - External';
        section.Name = 'WCI Documentation - External';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        VIPForm__VIP_Category__c section1 = new VIPForm__VIP_Category__c();
        section1.VIPForm__Name_Displayed__c = 'Location Documentation - External';
        section1.Name = 'Location Documentation - External';
        section1.VIPForm__Object_API__c = 'License_Registration__c';
        section1.VIPForm__Order__c = 300;
        section1.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section1;
        
        VIPForm__VIP_Category__c section2 = new VIPForm__VIP_Category__c();
        section2.VIPForm__Name_Displayed__c = 'Company Information - External';
        section2.Name = 'Company Information - External';
        section2.VIPForm__Object_API__c = 'License_Registration__c';
        section2.VIPForm__Order__c = 300;
        section2.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section2;
        
        VIPForm__VIP_Category__c section3 = new VIPForm__VIP_Category__c();
        section3.VIPForm__Name_Displayed__c = 'Company Finances - CW - External';
        section3.Name = 'Company Finances - CW - External';
        section3.VIPForm__Object_API__c = 'License_Registration__c';
        section3.VIPForm__Order__c = 300;
        section3.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section3;
        
        VIPForm__VIP_Category__c section4 = new VIPForm__VIP_Category__c();
        section4.VIPForm__Name_Displayed__c = 'Company Managers - External';
        section4.Name = 'Company Managers - External';
        section4.VIPForm__Object_API__c = 'License_Registration__c';
        section4.VIPForm__Order__c = 300;
        section4.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section4;
        
        VIPForm__VIP_Category__c section5 = new VIPForm__VIP_Category__c();
        section5.VIPForm__Name_Displayed__c = 'Company Owners - External';
        section5.Name = 'Company Owners - External';
        section5.VIPForm__Object_API__c = 'License_Registration__c';
        section5.VIPForm__Order__c = 300;
        section5.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section5;
        
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
        
        test.startTest();
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
            Attachment_Name__c = 'test att name1', 
            Registration__c = lr.id,
            Description__c = 'test desc', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section1.id
            );
            insert attPlus1;
            
            Attachments_Plus__c attPlus2 = new Attachments_Plus__c(
            Attachment_Name__c = 'test att name1', 
            Registration__c = lr.id,
            Description__c = 'test desc', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section2.id
            );
            insert attPlus2;
            
            Attachments_Plus__c attPlus3 = new Attachments_Plus__c(
            Attachment_Name__c = 'test att name1', 
            Registration__c = lr.id,
            Description__c = 'test desc', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section3.id
            );
            insert attPlus3;
            
            Attachments_Plus__c attPlus4 = new Attachments_Plus__c(
            Attachment_Name__c = 'test att name1', 
            Registration__c = lr.id,
            Description__c = 'test desc', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section4.id
            );
            insert attPlus4;
            
            Attachments_Plus__c attPlus5 = new Attachments_Plus__c(
            Attachment_Name__c = 'test att name1', 
            Registration__c = lr.id,
            Description__c = 'test desc', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section5.id
            );
            insert attPlus5;
                        
        test.stopTest();
    }
    static testMethod void allAttPlusTest2() {
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        //temp.VIPForm__Form_Style__c = 'Vertical Navigation';
        insert temp;
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'Location Documentation - External';
        section.Name = 'Location Documentation - External';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        VIPForm__VIP_Category__c section1 = new VIPForm__VIP_Category__c();
        section1.VIPForm__Name_Displayed__c = 'WCI Documentation - External';
        section1.Name = 'WCI Documentation - External';
        section1.VIPForm__Object_API__c = 'License_Registration__c';
        section1.VIPForm__Order__c = 300;
        section1.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section1;
        
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
        Attachment_Required__c = TRUE, 
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
        
        test.startTest();
            
            
            Attachments_Plus__c attPlus1 = new Attachments_Plus__c(
            Attachment_Name__c = 'test att name1', 
            Registration__c = lr.id,
            Attachment_Required__c = TRUE,
            Description__c = 'test desc', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section1.id
            );
            insert attPlus1;
            
                    
        test.stopTest();
    }
    static testMethod void testallAttPlusTest3() {
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        //temp.VIPForm__Form_Style__c = 'Vertical Navigation';
        insert temp;
        
        
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'WCI Documentation - External';
        section.Name = 'WCI Documentation - External';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        VIPForm__VIP_Category__c section1 = new VIPForm__VIP_Category__c();
        section1.VIPForm__Name_Displayed__c = 'Location Documentation - External';
        section1.Name = 'Location Documentation - External';
        section1.VIPForm__Object_API__c = 'License_Registration__c';
        section1.VIPForm__Order__c = 300;
        section1.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section1;
        
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
        
        Attachments_Plus__c attPlus1 = new Attachments_Plus__c(
            Attachment_Name__c = 'test att name1', 
            Registration__c = lr.id,
            Attachment_Required__c = TRUE,
            Description__c = 'test desc', 
            Type__c = '', 
            Attorney_Client_Privilege__c = true, 
            Confidential__c = true, 
            Not_Subject_to_PRA__c = true,
            VIP_Form_Section__c = section1.id
            );
            insert attPlus1;
            
        test.startTest();
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
            
           delete cDe;
           //delete attPlus;
            //delete attPlus1;
                        
        test.stopTest();
    }
}