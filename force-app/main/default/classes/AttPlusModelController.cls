public class AttPlusModelController{
    List<A_Config_Details__mdt> configDetails_mdt = new List<A_Config_Details__mdt>();
    public List<FileFormWrap> formWrapList {get; set;}
    public AttachmentPlusWrap attPlusWrap {get; set;}
    public static AttachmentPlusWrap attPlusWrap1 {get; set;}
    public Attachment tempFile {get; set;}
    Map<String,Integer> configIndexMap = new Map<String,Integer>();
    public static Map<String,Integer> headerIndexMap = new Map<String,Integer>();
    public Boolean showForm {get; set;}
    
    public AttPlusModelController(){
        showForm = false;
        
        loadHeaders();
        loadTable();
    } 
    
    public void loadHeaders(){
        Integer index = 0;
        for(A_Config_Details__mdt mdt : [select id, DeveloperName, A_Configuration__c, Active__c, Data_Type__c, Field_Name__c,
                                         Picklist_Values__c, Required__c, Show_in_Summary__c, Sort_Order__c
                                         from A_Config_Details__mdt ORDER BY Sort_Order__c ASC]){
            configDetails_mdt.add(mdt);
            configIndexMap.put(mdt.Field_Name__c,index);
            index = index + 1;
        }
    }
    
    @AuraEnabled
    public static Map<String,String> fetchFileTableHeadersAndData(){
        return  new Map<String,String>{'columns' => genFileHeaderJSON(),
                                       'data' => getFileDataJSON()};
    }
    
    @AuraEnabled
    public static void deleteAttachment(String attachId){
        delete new Attachments_New__c(Id = attachId);
    }
    
    @AuraEnabled
    public static void updateAttachment(String fileInfoJSON, String attachId){
        Map<String,String> mapFileData = (Map <String,String>)JSON.deserialize(fileInfoJSON, Map<String,String>.class);
        Attachments_New__c attPlus = new Attachments_New__c(File_Name__c = mapFileData.get('File_Name'), Id = attachId);
        update attPlus;
        
        List<Attachments_Data__c> attData = new List<Attachments_Data__c>();
        for(Attachments_Data__c objAtt : [Select Id, Field_Name__c, Value__c, Attachments__c,Field_API_Name__c 
                                          From Attachments_Data__c
                                          Where Attachments__c =: attachId
                                          And Field_API_Name__c =: mapFileData.keyset()]){
                                              
             if(objAtt.Value__c != mapFileData.get(objAtt.Field_API_Name__c)){
                 objAtt.Value__c = mapFileData.get(objAtt.Field_API_Name__c);
                 attData.add(objAtt);
             }
                 
        }
        update attData; 
    }
    
    @AuraEnabled
    public static void uploadFile(String fileInfoJSON, String base64Data){
        Map<String,String> mapFileData = (Map <String,String>)JSON.deserialize(fileInfoJSON, Map<String,String>.class);
        Attachments_New__c attPlus = new Attachments_New__c(File_Name__c = mapFileData.get('File_Name'));
        insert attPlus;
        
        List<Attachments_Data__c> attData = new List<Attachments_Data__c>();
        for(String attDataFieldInfo : mapFileData.keyset()){
            
            attData.add(new Attachments_Data__c(Field_Name__c = attDataFieldInfo,
                                                Value__c = mapFileData.get(attDataFieldInfo),
                                                Field_API_Name__c = attDataFieldInfo,
                                                Attachments__c = attPlus.id));
        }

        
        insert attData;
        
        ContentVersion conVer = new ContentVersion( ContentLocation = 'S',
                                                    PathOnClient = attPlus.File_Name__c,
                                                    Title = attPlus.File_Name__c,
                                                    VersionData = EncodingUtil.base64Decode(base64Data),
                                                    Origin = 'C');
        insert conVer;
        
        
        
        insert  new ContentDocumentLink(ContentDocumentId = [select id, ContentDocumentId 
                                                             from ContentVersion 
                                                             where id = :conVer.id].ContentDocumentId,
                                        LinkedEntityId = attPlus.id,
                                        ShareType = 'I',
                                        Visibility = 'AllUsers');
    }
    
    
    private static String genFileHeaderJSON(){
        Integer i = 0;
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartArray();
        for(A_Config_Details__mdt mdt : [select id, DeveloperName, A_Configuration__c, Active__c, Data_Type__c, Field_Name__c,
                                         Picklist_Values__c, Required__c, Show_in_Summary__c, Sort_Order__c
                                         from A_Config_Details__mdt ORDER BY Sort_Order__c ASC]){
            gen.writeStartObject();
            gen.writeStringField('label', mdt.Field_Name__c);
            gen.writeStringField('fieldName', mdt.DeveloperName);
            gen.writeStringField('type', mdt.Data_Type__c);
            if(mdt.Data_Type__c == 'Picklist'){
                gen.writeFieldName('values');
                gen.writeStartArray();
                for(string v : mdt.Picklist_Values__c.split(';')){
                    gen.writeStartObject();
                    gen.writeStringField('label',v);
                    gen.writeStringField('value',v);
                    gen.writeEndObject();
                }
                gen.writeEndArray();
            }
            gen.writeEndObject();
            headerIndexMap.put(mdt.DeveloperName,i);
            i = i + 1;
        }    
        gen.writeEndArray();
        system.debug('***Header JSON***' + gen.getAsString());
        return gen.getAsString();
    }
    
    private static String getFileDataJSON(){
        Map<Integer,Attachments_Data__c> attdMap = new Map<Integer,Attachments_Data__c>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        
        for(Attachments_New__c attP : [select id, File_Name__c, Visible__c, Community__c,
                                    (select id,ContentDocumentId from ContentDocumentLinks),
                                    (select id, Field_Name__c, Value__c, Attachments__c,Field_API_Name__c from Attachments_Data__r)
                                    from Attachments_New__c]){
            
            for(Attachments_Data__c attd : attP.Attachments_Data__r){
                if(headerIndexMap.containsKey(attd.Field_Name__c)){
                    attdMap.put(headerIndexMap.get(attd.Field_Name__c),attd);
                }
            }
            List<Integer> temp = new List<Integer>();
            temp.addAll(attdMap.keySet());
            temp.sort();
            List<Attachments_Data__c> sortedData = new List<Attachments_Data__c>();
            for(Integer i : temp){
                sortedData.add(attdMap.get(i));
            }
            
            gen.writeStartObject();
            gen.writeStringField('id', attP.id);
            for(Attachments_Data__c attd : sortedData){
                gen.writeStringField(attd.Field_API_Name__c, String.isNotBlank(attd.Value__c) ? attd.Value__c : '');
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        system.debug('***Data JSON***' + gen.getAsString());
        return gen.getAsString();
    }
    
    public void loadTable(){
        if(configDetails_mdt.size() > 0){
            Set<Id> contentDocumentIdSet = new Set<Id>();
            Map<Id,ContentVersion> contentDocVersionMap = new Map<Id,ContentVersion>();
            
            for(Attachments_New__c attP : [select id, File_Name__c, Visible__c, Community__c,
                                            (select id,ContentDocumentId from ContentDocumentLinks)
                                            from Attachments_New__c]){
                for(ContentDocumentLink cdLink : attP.ContentDocumentLinks){
                    contentDocumentIdSet.add(cdLink.ContentDocumentId);
                }
            }
            
            if(contentDocumentIdSet.size() > 0){
                for(ContentVersion cv : [select id, ContentDocumentId from ContentVersion WHERE ContentDocumentId IN :contentDocumentIdSet AND IsLatest = true]){
                    contentDocVersionMap.put(cv.ContentDocumentId, cv);
                }
            }
            
            List<AttachmentDataWrap> attDataWrapList = new List<AttachmentDataWrap>();
            for(Attachments_New__c attP : [select id, File_Name__c, Visible__c, Community__c,
                                            (select id,ContentDocumentId from ContentDocumentLinks),
                                            (select id, Field_Name__c, Value__c, Attachments__c from Attachments_Data__r)
                                            from Attachments_New__c]){
                if(attP.ContentDocumentLinks != null && attP.ContentDocumentLinks.size() > 0 && attP.Attachments_Data__r != null && attP.Attachments_Data__r.size() > 0){
                    Map<Integer,Attachments_Data__c> attdMap = new Map<Integer,Attachments_Data__c>();
                    for(Attachments_Data__c attd : attP.Attachments_Data__r){
                        if(configIndexMap.containsKey(attd.Field_Name__c)){
                            attdMap.put(configIndexMap.get(attd.Field_Name__c),attd);
                        }
                    }
                    List<Integer> temp = new List<Integer>();
                    temp.addAll(attdMap.keySet());
                    temp.sort();
                    List<Attachments_Data__c> sortedData = new List<Attachments_Data__c>();
                    for(Integer i : temp){
                        sortedData.add(attdMap.get(i));
                    }
                    AttachmentDataWrap attDataWrap = new AttachmentDataWrap(attP, attP.ContentDocumentLinks[0].ContentDocumentId, contentDocVersionMap.get(attP.ContentDocumentLinks[0].ContentDocumentId).id, sortedData);
                    attDataWrapList.add(attDataWrap);
                }
            }
            
            if(attDataWrapList.size() > 0){
                attPlusWrap = new AttachmentPlusWrap(configDetails_mdt, attDataWrapList);
            }
        }
    }
    
    public class FileFormWrap{
        public A_Config_Details__mdt mdt {get; set;}
        public String fieldName {get; set;}
        public String fieldAPIName;
        public String fieldValue {get; set;}
        public List<SelectOption> options {get; set;}
        
        public FileFormWrap(A_Config_Details__mdt mdt){
            this.mdt = mdt;
            this.fieldAPIName = mdt.DeveloperName;
            this.fieldName = mdt.Field_Name__c;
            if(mdt.Data_Type__c == 'Picklist'){
                options = new List<SelectOption>();
                for(string opt : mdt.Picklist_Values__c.split(';')){
                    options.add(new SelectOption(opt,opt));
                }
            }
        }
        
        public FileFormWrap(String fieldName, String fieldValue){
            this.fieldName = fieldName;
            this.fieldValue = fieldValue;
        }
    }
    
    public class AttachmentPlusWrap{
        public List<A_Config_Details__mdt> configHeaders {get; set;}
        public List<AttachmentDataWrap> attDataWrapList {get; set;}
        
        public AttachmentPlusWrap(List<A_Config_Details__mdt> configHeaders, List<AttachmentDataWrap> attDataWrapList){
            this.configHeaders  = configHeaders;
            this.attDataWrapList = attDataWrapList;
        }
    }
    
    public class AttachmentDataWrap{
        public Attachments_New__c attPlus {get; set;}
        public Attachment att;
        public string ContentDocumentId {get; set;}
        public string ContentVersionId {get; set;}
        public List<Attachments_Data__c> attDataList {get; set;}
        
        public AttachmentDataWrap(Attachments_New__c attPlus, string ContentDocumentId, string ContentVersionId, List<Attachments_Data__c> attDataList){
            this.attPlus = attPlus;
            this.ContentDocumentId = ContentDocumentId;
            this.ContentVersionId = ContentVersionId;
            this.attDataList = attDataList;
        }
    }
    
    public void addFile(){
        showForm = true;
        formWrapList = new List<FileFormWrap>();
        tempFile = new Attachment();
        for(A_Config_Details__mdt mdt : configDetails_mdt){
            formWrapList.add(new FileFormWrap(mdt));
        }
    }   
    
    public void saveFile(){
        try{
        Attachments_New__c attPlus = new Attachments_New__c();
        List<Attachments_Data__c> attDataList = new List<Attachments_Data__c>();
        attPlus.File_Name__c = tempFile.Name;
        insert attPlus;
        
        for(FileFormWrap fw : formWrapList){
            Attachments_Data__c attData = new Attachments_Data__c();
            attData.Field_Name__c = fw.fieldName;
            attData.Value__c = fw.fieldValue;
            attData.Field_API_Name__c = fw.fieldAPIName;
            attData.Attachments__c = attPlus.id;
            attDataList.add(attData);
        }
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = tempFile.Name;
        conVer.Title = tempFile.Name;
        conVer.VersionData = tempFile.body;
        conVer.Origin = 'C';
        insert conVer;
        
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = [select id, ContentDocumentId from ContentVersion where id = :conVer.id].ContentDocumentId;
        cDe.LinkedEntityId = attPlus.id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
        insert attDataList;
        showForm = false;
        loadTable();
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return;
        }
    }
}