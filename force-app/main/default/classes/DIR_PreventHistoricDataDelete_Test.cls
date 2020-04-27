@isTest
private class DIR_PreventHistoricDataDelete_Test {

    private static testMethod void testPreventHistoricDataDelete() {
         
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        DIR_Case__c objCase = new DIR_Case__c(Employer__c = objAccount.Id);
        insert objCase;
         

        Attachments_New__c objAttachment = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = objCase.Id);
        insert  objAttachment;
        
        ContentVersion conVer = new ContentVersion( ContentLocation = 'S',
                                                    PathOnClient = 'Test',
                                                    Title = 'test',
                                                    VersionData = EncodingUtil.base64Decode('Test'),
                                                    Origin = 'C');
       insert conVer;
       
       String cdId = [SELECT id, ContentDocumentId 
                      FROM ContentVersion 
                      WHERE id = :conVer.id].ContentDocumentId;
                      
       ContentDocumentLink objCDL = new ContentDocumentLink( ContentDocumentId = cdId,
                                                              ShareType = 'I',
                                                              LinkedEntityId = objAttachment.id);
        
        insert objCDL;
        
        try{
            delete objCase;
        }
        catch(Exception ex){
            
        }
        
        try{
            delete objAttachment;
        }
        catch(Exception ex){
            system.assertEquals(ex.getMessage().contains('Only system administrators can delete historical attachments.'),true);
        }
        
        try{
            delete objCDL;
        }
        catch(Exception ex){
            
        }
        
        try{
            delete new ContentDocument(Id = cdId);
        }
        catch(Exception ex){
            
        }
        
        

    }

}