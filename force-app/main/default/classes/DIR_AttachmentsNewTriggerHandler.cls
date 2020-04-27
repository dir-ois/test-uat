//-----------------------------
// @author: Oswin Correa
// @date: 20/4/2018
// @description: Trigger Handler of DIR_AttachmentsNewTrigger Trigger on Attachments_New__c
//-----------------------------
public with sharing class DIR_AttachmentsNewTriggerHandler {
    
    //-----------------------------
    // @param: Map<Id,Attachments_New__c> mapattachments
    // @description: Method called on Before Deelete of  Attachments
    // @return: void
    //----------------------------- 
    public static void onBeforeDelete(Map<Id,Attachments_New__c> mapattachments){
       
        Map<String,String> mapAttachIdToRelatedCase =  new Map<String,String>();
        
        for(Attachments_New__c objAttachment : mapattachments.values()){
            
            if(String.isNotBlank(objAttachment.Related_Id__c) && objAttachment.Related_Id__c InstanceOf Id && 
                String.valueof(Id.valueof(objAttachment.Related_Id__c).getSobjectType()) == 'DIR_Case__c'){
                    
                mapAttachIdToRelatedCase.put(objAttachment.Id,objAttachment.Related_Id__c);
            }
        }
        
        if(!mapAttachIdToRelatedCase.isEmpty()){
            
            preventDelete(mapAttachIdToRelatedCase,mapattachments);
        }

    }
    
    //-----------------------------
    // @param: Map<String,String> mapAttachIdToRelatedCase, Map<Id,Attachments_New__c> mapattachments
    // @description: Method to prevent non admins from deleting Attachments uploaded via attachments + considering the related Case purge date
    // @return: void
    //-----------------------------
    private static void preventDelete(Map<String,String> mapAttachIdToRelatedCase, Map<Id,Attachments_New__c> mapattachments){
         
         Set<String> setCaseIds = new Set<String>();
         
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
             
            for(DIR_Case__c objCase : [SELECT Id
                                       FROM DIR_Case__c
                                       WHERE Id =: mapAttachIdToRelatedCase.values()
                                       AND(Purge_Date__c = Null OR Purge_Date__c < TODAY)]){
                                       
                 setCaseIds.add(objCase.Id);                      
            }
            
            for(String attachId : mapAttachIdToRelatedCase.keyset()){
                 
                 if(setCaseIds.contains(mapAttachIdToRelatedCase.get(attachId))){
                     
                     mapattachments.get(attachId).addError('Only system administrators can delete historical attachments.');
                     
                 }
             }
         }
    }
}