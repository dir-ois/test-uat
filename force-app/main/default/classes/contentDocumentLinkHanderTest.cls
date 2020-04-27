@istest
private class contentDocumentLinkHanderTest {

    private static testmethod void CDLInsertTest(){
        
        Account objAccount = new Account(
                                    Name = 'test acct 123',
                                    Legal_Entity_Name__c = 'test acct 123',
                                    ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
                                    ShippingCity = 'Denver',
                                    ShippingState = 'CO',
                                    ShippingPostalCode = '80212' 
                                );
        insert objAccount;
        
        Contact objContact = new Contact(LastName ='testCon',AccountId = objAccount.Id,Email = 'test@test.com');
        insert objContact;  
        
        License_Registration__c objLR = new License_Registration__c(
                                                                    Account__c = objAccount.Id,
                                                                    License_Registration_Number__c = '222',
                                                                    License_Registration_Type__c = 'Car Wash',
                                                                    Status__c = 'Incomplete',
                                                                    Expiration_Date__c = Date.today(), 
                                                                    Mailing_Country__c = 'United States of America',
                                                                    Physical_Business_Country__c = 'United States of America',
                                                                    Effective_Date__c = Date.today(),
                                                                    Amount_Paid__c = 100, 
                                                                    Applicant__c = objContact.Id,
                                                                    RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId()
                                                                    );
                                                                    
        insert objLR;
        
        Attachments_Plus__c aPlus = new Attachments_Plus__c(
            Registration__c = objLR.Id,
            Attachment_Name__c = 'lrdoc',
            Attachment_Required__c = True
        );
        
        insert aPlus;
        
        Attachments_Plus__c aPlus1 = new Attachments_Plus__c(
            Registration__c = objLR.Id,
            Attachment_Name__c = 'lrdoc',
            Attachment_Required__c = False
        );
        
        insert aPlus1;
        
        ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            //content.LinkedEntityId=sub.id;
            content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=aPlus.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'V';            
        
        ContentVersion content1=new ContentVersion(); 
            content1.Title='Header_Picture1'; 
            content1.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
            content1.VersionData=bodyBlob1; 
            //content.LinkedEntityId=sub.id;
            content1.origin = 'H';
        insert content1;
        
        ContentDocumentLink contentlink1=new ContentDocumentLink();
            contentlink1.LinkedEntityId=aPlus1.id;
            contentlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: content1.id].contentdocumentid;
            contentlink1.ShareType = 'V';
        
        test.startTest();
        insert contentLink;
        insert contentlink1;
        
        License_Registration__c lr = [SELECT ID, Number_of_Attachments__c, Number_of_attachments_Required__c from License_Registration__c WHERE Id = :objlr.Id Limit 1 ];
        //system.assert(lr.Number_of_Attachments_Required__c == 1);
        //system.assert(lr.Number_of_Attachments__c == 1);
        
        delete contentLink;
        
        License_Registration__c lr1 = [SELECT ID, Number_of_Attachments__c, Number_of_attachments_Required__c from License_Registration__c WHERE Id = :objlr.Id Limit 1 ];
        //system.assert(lr1.Number_of_Attachments_Required__c == 1);
        //system.assert(lr1.Number_of_Attachments__c == 0);
        test.stopTest();
        
    }
}