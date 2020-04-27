@isTest
private class AttPlusModelControllerTest {

    private static testMethod void testAttPlusModelController() {
        
        
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Contact objContact =  new Contact(LastName = 'Test', AccountId = objAccount.Id);
        insert objContact;
        
        Attachments_New__c objAttachment1 = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = objAccount.Id);
                                                                  
        Attachments_New__c objAttachment2 = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = objContact.Id);
                                                                  
        insert new List<Attachments_New__c> {objAttachment1,objAttachment2};
        
        insert new List<Attachments_Data__c> {new Attachments_Data__c(Field_Name__c = 'Test',
                                                                    Value__c = 'Test',
                                                                    Field_API_Name__c = 'Test',
                                                                    Attachments__c = objAttachment1.id),
                                                                    
                                            new Attachments_Data__c(Field_Name__c = 'Test',
                                                                    Value__c = 'Test',
                                                                    Field_API_Name__c = 'Test',
                                                                    Attachments__c = objAttachment2.id)};
                                                                        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'file_name.pdf';
        conVer.Title = 'file_name.pdf';
        conVer.VersionData = blob.valueOf('text file');
        conVer.Origin = 'C';
        insert conVer;
        
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = [select id, ContentDocumentId from ContentVersion where id = :conVer.id].ContentDocumentId;
        cDe.LinkedEntityId = objAttachment1.id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
		test.startTest();
        
        AttPlusModelController contlr = new AttPlusModelController();
        
        AttPlusModelController.deleteAttachment(objAttachment1.Id);
       
        test.stopTest();
        
    }

}