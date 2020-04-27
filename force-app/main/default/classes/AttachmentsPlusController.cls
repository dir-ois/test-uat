global with sharing class AttachmentsPlusController {
    
    public transient Blob body {get;set;}
    public String fname {get;set;}
    public List<Attachments_Plus__c> attPlusList {get;set;}
    public boolean renderUploadAtt {get;set;}
    public String baseURL {get;set;}
    public Attachments_Plus__c newAttPlus {get;set;}
    public Map<String, List<Attachments_Plus__c>> typeMap {get;set;}
    public Map<Id, Attachments_Plus__c> attPlusMap {get;set;}
    public String thisObjId {get;set;}
    public String reloadURL {get;set;}
    public boolean ErrorExists {get;set;}
    
    private String pageName;
    private String thisObjIdShort;

    public AttachmentsPlusController(apexPages.standardController controller){
        sObject thisObj = (sObject)controller.getRecord();
        pageName = getVFPageName();
        thisObjId = thisObj.Id;
        thisObjIdShort = thisObjId.subString(0, thisObjId.length() - 3);
        baseURL = url.getSalesforceBaseUrl().toExternalForm();
        renderUploadAtt = false;
        attPlusList = new List<Attachments_Plus__c>();
        attPlusList = queryAttsPlus();
        instantiateNewAttPlus();
        reloadURL = baseURL+'/apex/'+pageName+'?id='+thisObjId;
        if(attPlusList.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no attachments for this record yet.'));
            return;
        }
    }
    
    @remoteAction
    global static void deleteAttAction(string deleteAttId){
        Attachments_Plus__c thisAP;
        Attachment a;
        try{
            thisAP = [SELECT Id, Attachment_ID__c FROM Attachments_Plus__c WHERE Id =: deleteAttId];
            a = [SELECT Id FROM Attachment WHERE Id =: thisAP.Attachment_ID__c];
        }
        catch(exception e){
            system.debug('**ERROR**: '+e.getMessage());
        }
        if(a != null){
            delete a;
        }
        if(thisAP != null ){
            delete thisAP;
        }
    }

    @remoteAction
    global static void updateAttAction(String JSONStr){
        Attachments_Plus__c att = (Attachments_Plus__c)JSON.deSerialize(JSONStr, Attachments_Plus__c.class);

        update att;
    }
    
    @testVisible
    private List<Attachments_Plus__c> queryAttsPlus(){
        List<Attachments_Plus__c> atts = [SELECT Id, Name, OwnerId, Attachment_ID__c, Attachment_Name__c, Attachment_URL__c, Description__c, Object__c, Record_ID__c, Type__c, Attorney_Client_Privilege__c, Confidential__c, Not_Subject_to_PRA__c
                       FROM Attachments_Plus__c
                       WHERE Record_ID__c =: thisObjId OR Record_ID__c =: thisObjIdShort ORDER BY Attachment_Name__c ASC];
        typeMap = new Map<String, List<Attachments_Plus__c>>();
        attPlusMap = new Map<Id, Attachments_Plus__c>();
        if(atts != null){
            for(Attachments_Plus__c a : atts){
                attPlusMap.put(a.Id, a);
                List<Attachments_Plus__c> tempList = new List<Attachments_Plus__c>();
                if(a.Type__c == null || a.Type__c.trim() == ''){
                    a.Type__c = 'Unknown';
                }
                if(!typeMap.containsKey(a.Type__c)){
                    tempList.add(a);
                    typeMap.put(a.Type__c, tempList);
                }
                else{
                    tempList = typeMap.get(a.Type__c);
                    tempList.add(a);
                    typeMap.put(a.Type__c, tempList);
                }
            }               
        }
        return atts;
    }
    
    public void instantiateNewAttPlus(){
        newAttPlus = new Attachments_Plus__c(
            Record_Id__c = thisObjId
        );
    }
    
    public pageReference saveAttachment(){
        try{
            Attachment attachment = new Attachment();
                attachment.OwnerId = UserInfo.getUserId();
                attachment.ParentId = thisObjId; // the record the file is attached to
                attachment.Name = fname;
                attachment.Body = body;
                attachment.IsPrivate = false;        
            insert attachment;
            newAttPlus.Attachment_ID__c = attachment.Id;
            newAttPlus.Record_ID__c = thisObjId;
            newAttPlus.Attachment_Name__c = (newAttPlus.Attachment_Name__c == null || newAttPlus.Attachment_Name__c.trim() == '') ? fname : newAttPlus.Attachment_Name__c;

            insert newAttPlus;
        }
        catch(exception e) {
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));  
            ErrorExists=True;
            //return if failed
            return null;
        }
        finally {
            body=null;
            fname=null;
            instantiateNewAttPlus();
            attPluslist = queryAttsPlus();
            pageReference reload = new pageReference(reloadURL);
           	reload.setRedirect(true);
			if(ErrorExists=False){
	       		return reload;
            }
        }
        return null;
    }
    public string getVFPageName()  {
        if(test.isRunningTest()) return 'addAttachmentsPlus';
        String pageName = ApexPages.CurrentPage().getUrl();  
        pageName = pageName.replaceFirst('/apex/','');         
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
        string[] pageNameExtra = pageName.split('%3F',0);   
        pageName = pageNameExtra[0]; 
        return pageName;                                        
    }
}