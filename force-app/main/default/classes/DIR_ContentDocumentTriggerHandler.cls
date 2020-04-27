//-----------------------------
// @author: Oswin Correa
// @date: 20/4/2018
// @description: Trigger Handler of DIR_ContentDocument Trigger on Content Document
//-----------------------------
public with sharing class DIR_ContentDocumentTriggerHandler { 

    //-----------------------------
    // @param: Map<Id,ContentDocument> mapCD
    // @description: Method called on Before Delete of ContentDocuments
    // @return: void
    //-----------------------------    
    public static void onBeforeDelete(Map<Id,ContentDocument> mapCD){
        
        List<ContentDocumentLink> filteredCDL =  new List<ContentDocumentLink>();
        Set<String> setRelatedAttachments = new Set<String>();
        
        for(ContentDocument objCD: [SELECT Id,
                                    (SELECT Id,ContentDocumentId,LinkedEntity.Type FROM  ContentDocumentLinks WHERE LinkedEntity.Type = 'Attachments_New__c') 
                                    FROM ContentDocument 
                                    WHERE Id =: mapCD.keyset()]){
                
            for(ContentDocumentLink objCDL : objCD.ContentDocumentLinks){
                
                if(String.valueof(Id.valueof(objCDL.LinkedEntityId).getSobjectType()) == 'Attachments_New__c'){
                    
                     setRelatedAttachments.add(objCDL.LinkedEntityId);
                     filteredCDL.add(objCDL);
                }
            }
        
        }
        
        if(!filteredCDL.isEmpty()){
            
            preventDelete(setRelatedAttachments,filteredCDL,mapCD);
        }
    }
    
   
    //-----------------------------
    // @param: Set<String> setRelatedAttachments, List<ContentDocumentLink> filteredCDL, Map<Id,ContentDocument> mapCD
    // @description: Method to prevent non admins from deleting ContentDocuments for the files uploaded via attachments + considering the related Case purge date
    // @return: void
    //-----------------------------
    private static void preventDelete(Set<String> setRelatedAttachments, List<ContentDocumentLink> filteredCDL, Map<Id,ContentDocument> mapCD){
         
         Set<String> setCaseIds = new Set<String>();
         Map<String,String> mapAttachmentIdToRelatedCase =  new Map<String,String>();
         
         Boolean isSystemAdmin = false;
         
         List<Profile> sysAdminList = [SELECT Id FROM Profile WHERE Name  like 'System Administrator%'];
         
         if (sysAdminList.size() > 0)
         {
             for (Integer i = 0; i < sysAdminList.size(); i++)
             {
                 if (Userinfo.getProfileId() == sysAdminList[i].Id)
                 {
                     isSystemAdmin = true;
                 }
             }
         }                
         
         if(!isSystemAdmin || Test.isRunningTest()){ 
             
            for(Attachments_New__c objAttachment : [SELECT Id,Related_Id__c
                                                    FROM Attachments_New__c
                                                    WHERE Id =: setRelatedAttachments]){
            
                if(String.isNotBlank(objAttachment.Related_Id__c) && objAttachment.Related_Id__c InstanceOf Id && 
                    String.valueof(Id.valueof(objAttachment.Related_Id__c).getSobjectType()) == 'DIR_Case__c'){
                        
                        mapAttachmentIdToRelatedCase.put(objAttachment.Id,objAttachment.Related_Id__c);
                        
                }
            }
            
            
            
            for(DIR_Case__c objCase : [SELECT Id
                                       FROM DIR_Case__c
                                       WHERE Id =: mapAttachmentIdToRelatedCase.values()
                                       AND(Purge_Date__c = Null OR Purge_Date__c < TODAY)]){
                                       
                 setCaseIds.add(objCase.Id);                      
            }
            

            for(ContentDocumentLink objCDL : filteredCDL){
                
                if(mapAttachmentIdToRelatedCase.containsKey(objCDL.LinkedEntityId) && 
                    setCaseIds.contains(mapAttachmentIdToRelatedCase.get(objCDL.LinkedEntityId))){ 
                    
                    mapCD.get(objCDL.ContentDocumentId).addError('Only system administrators can delete historical attachments.');
                }
            }
            
         }
    }
}