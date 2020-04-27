//-----------------------------
// @author: Oswin Correa
// @date: 20/4/2018
// @description: Trigger Handler of DIR_ContentDocumentLink Trigger on Content Document
//-----------------------------
public with sharing class DIR_ContentDocumentLinkTriggerHandler {
    
    //-----------------------------
    // @param: Map<Id,ContentDocumentLink> mapCDL
    // @description: Method called on After insert of ContentDocumentLinks
    // @return: void
    //-----------------------------    
    public static void onAfterInsert(Map<Id,ContentDocumentLink> mapCDL){
        
        linkFilesToAttachmentsNew(mapCDL);
    }
    
    //-----------------------------
    // @param: Map<Id,ContentDocumentLink> mapCDL
    // @description: Method to link inserted files to Attachments New
    // @return: void
    //-----------------------------    
    private static void linkFilesToAttachmentsNew(Map<Id,ContentDocumentLink> mapCDL){
        
        Map<String,String> mapFilteredCDL = new Map<String,String>();
        Set<String> setConfiguredObjects = new Set<String>();
        Map<String,List<ContentDocumentLink>> mapObjectNameToCDL =  new Map<String,List<ContentDocumentLink>>();
        Map<String,ContentDocumentLink> mapCDLidToAttachmentCDL = new Map<String,ContentDocumentLink>();
        Map<String,Attachments_New__c> mapCDLidToAttachment =  new Map<String,Attachments_New__c>();
        Map<String,Map<String,Attachments_Data__c>> mapCDLidToAttachmentData =  new Map<String,Map<String,Attachments_Data__c>>();
        List<Attachments_Data__c> lstAttachmentDetails =  new List<Attachments_Data__c>();
        
        String testConfigDataJSON = '[{"Id":"m06350000004DlIAAU","Object_API_Name__c":"Attachments_New__c","File_Type__c":"Intake","Record_Type_API_Names__c":"RCI"}]';
        String testRulesJSON = '[{"Id":"m083500000000Q9AAI","Field_value__c":"Intake Form","Keyword_To_Match__c":"test","Field_API_Name__c":"Subtype","A_Configuration__c":"m06350000004DlIAAU",'+
                                '"A_Configuration__r":{"Id":"m06350000004DlIAAU","Record_Type_API_Names__c":"RCI","File_Type__c":"Intake","Object_API_Name__c":"Attachments_New__c"}},'+
                                '{"Id":"m083500000000PVAAY","Field_value__c":"true","Keyword_To_Match__c":"test","Field_API_Name__c":"New_Boolean","A_Configuration__c":"m06350000004DlIAAU",'+
                                '"A_Configuration__r":{"Id":"m06350000004DlIAAU","Record_Type_API_Names__c":"RCI","File_Type__c":"Intake","Object_API_Name__c":"Attachments_New__c"}}]';

        
        List<A_Configuration__mdt>  configurations;
        
        if(!Test.isRunningTest()){
            
             configurations = [SELECT Id,Object_API_Name__c,File_Type__c,Record_Type_API_Names__c
                               FROM A_Configuration__mdt
                               WHERE Object_API_Name__c != Null
                               AND File_Type__c != Null];
        }
        else{
            
            configurations = (List<A_Configuration__mdt>) JSON.deserialize(testConfigDataJSON, List<A_Configuration__mdt>.class);
        }
            
        for(A_Configuration__mdt objConfig : configurations){
                                                   
             setConfiguredObjects.add(objConfig.Object_API_Name__c);
         }
         
         for(ContentDocumentLink objCDL : mapCDL.values()){
            
            if(setConfiguredObjects.contains(String.valueof(Id.valueof(objCDL.LinkedEntityId).getSobjectType()))){

                mapFilteredCDL.put(objCDL.Id,objCDL.ContentDocumentId);
            }
        }
        

         for(ContentDocument objCD: [SELECT Id,Title,
                                    (SELECT Id,LinkedEntityId,LinkedEntity.RecordType.DeveloperName,LinkedEntity.Type,ContentDocumentId,ContentDocument.Title FROM  ContentDocumentLinks 
                                    WHERE Id =: mapFilteredCDL.keyset())
                                    FROM ContentDocument 
                                    WHERE Id =: mapFilteredCDL.values()]){
                                        
                                        
              for(ContentDocumentLink objCDL : objCD.ContentDocumentLinks){
                  

                   if(!mapObjectNameToCDL.containskey(objCDL.LinkedEntity.Type)){
                
                        mapObjectNameToCDL.put(objCDL.LinkedEntity.Type, new List<ContentDocumentLink>());
                   }
                   
                   mapObjectNameToCDL.get(objCDL.LinkedEntity.Type).add(objCDL);
                   
                   mapCDLidToAttachmentCDL.put(objCDL.id,new ContentDocumentLink(ContentDocumentId = objCD.Id,ShareType = 'I'));
                                                              
                   mapCDLidToAttachment.put(objCDL.id, new Attachments_New__c(Related_Id__c = objCDL.LinkedEntityId,
                                                                              File_Type__c = 'Related Files',
                                                                              File_Name__c = objCD.Title));

                   mapCDLidToAttachmentData.put(objCDL.id,new Map<String,Attachments_Data__c>{'File_Name' => new Attachments_Data__c( Field_API_Name__c = 'File_Name',
                                                                                                                                       Field_Name__c = 'File_Name',
                                                                                                                                       Value__c = objCD.Title),
                                                                                                                       
                                                                                              'Private' => new Attachments_Data__c(Field_API_Name__c = 'Private',
                                                                                                                                   Field_Name__c = 'Private',
                                                                                                                                   Value__c = 'true')});                                                            
              }
                                        
        }
        
        List<A_Auto_Assign_Rule__mdt>  rules;
        
        if(!Test.isRunningTest()){
            
             rules = [SELECT Id,Field_value__c,Keyword_To_Match__c,Field_API_Name__c,A_Configuration__r.Record_Type_API_Names__c,A_Configuration__r.File_Type__c,A_Configuration__r.Object_API_Name__c 
                      FROM A_Auto_Assign_Rule__mdt
                      WHERE A_Configuration__r.Object_API_Name__c =: mapObjectNameToCDL.keyset()
                      AND A_Configuration__r.File_Type__c != Null];
        }
        else{
            rules = (List<A_Auto_Assign_Rule__mdt>) JSON.deserialize(testRulesJSON, List<A_Auto_Assign_Rule__mdt>.class);
        }
        
        for(A_Auto_Assign_Rule__mdt objAAR : rules){
          
             if(mapObjectNameToCDL.containsKey(objAAR.A_Configuration__r.Object_API_Name__c)){
                 
                for(ContentDocumentLink objCDL : mapObjectNameToCDL.get(objAAR.A_Configuration__r.Object_API_Name__c)){
                  
                  if((String.isBlank(objCDL.LinkedEntity.RecordType.DeveloperName) ||
                      objAAR.A_Configuration__r.Record_Type_API_Names__c.trim().contains(objCDL.LinkedEntity.RecordType.DeveloperName)) &&
                      objCDL.ContentDocument.Title.trim().toLowerCase().contains(objAAR.Keyword_To_Match__c.trim().toLowerCase())){
                          
                      mapCDLidToAttachment.get(objCDL.Id).File_Type__c = objAAR.A_Configuration__r.File_Type__c;
                      
                      if(objAAR.Field_API_Name__c == 'File_Name'){
                          
                          mapCDLidToAttachment.get(objCDL.Id).File_Name__c = objAAR.Field_value__c;
                          mapCDLidToAttachmentData.get(objCDL.Id).get('File_Name').Value__c = objAAR.Field_value__c;
                      }
                      else if(objAAR.Field_API_Name__c != 'Private'){
                          
                           mapCDLidToAttachmentData.get(objCDL.id).put(objAAR.Field_API_Name__c, new Attachments_Data__c(Field_API_Name__c = objAAR.Field_API_Name__c,
                                                                                                                         Field_Name__c = objAAR.Field_API_Name__c,
                                                                                                                         Value__c = objAAR.Field_value__c));
                      }
                  }
                }
            }
         }
         
         insert mapCDLidToAttachment.values();
         
         
         for(String clId : mapCDLidToAttachmentData.keyset()){
             
             Attachments_New__c objAtt = mapCDLidToAttachment.get(clId);
             mapCDLidToAttachmentCDL.get(clId).LinkedEntityId = objAtt.Id;
             
             for(Attachments_Data__c objAttDetails : mapCDLidToAttachmentData.get(clId).values()){
                 
                 objAttDetails.Attachments__c = objAtt.Id;
                 lstAttachmentDetails.add(objAttDetails);
             }
         }
         
         insert lstAttachmentDetails;
         
         if(!Test.isRunningTest()){
             
            insert mapCDLidToAttachmentCDL.values();
         }
    }

    //-----------------------------
    // @param: Map<Id,ContentDocumentLink> mapCDL
    // @description: Method called on Before Deelete of  ContentDocumentLinks
    // @return: void
    //-----------------------------    
    public static void onBeforeDelete(Map<Id,ContentDocumentLink> mapCDL){
        
        List<ContentDocumentLink> filteredCDL =  new List<ContentDocumentLink>();
        Set<String> setRelatedAttachments = new Set<String>();

        for(ContentDocumentLink objCDL : mapCDL.values()){
            
            if(String.valueof(Id.valueof(objCDL.LinkedEntityId).getSobjectType()) == 'Attachments_New__c'){
                
                 setRelatedAttachments.add(objCDL.LinkedEntityId);
                 filteredCDL.add(objCDL);
            }
        }
        
        
        if(!filteredCDL.isEmpty()){
            
            preventDelete(setRelatedAttachments,filteredCDL);
        }

    }
    
    //-----------------------------
    // @param: Set<String> setRelatedAttachments, List<ContentDocumentLink> filteredCDL
    // @description: Method to prevent non admins from deleting ContentDocumentLinks for the files uploaded via attachments + considering the related Case purge date
    // @return: void
    //-----------------------------
    private static void preventDelete(Set<String> setRelatedAttachments, List<ContentDocumentLink> filteredCDL){
         
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
                    
                    objCDL.addError('Only system administrators can delete historical attachments.');
                }
            }
            
         }
    }
}