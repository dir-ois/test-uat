global with sharing class RegistrationAttachmentController {
    
    public String thisObjId {get;set;}
    private String thisObjIdShort;
    public List<AttPlusWrapper> AttPlusWrapperList { get; set; }
    public Attachments_Plus__c AttPlusToUpdate {get; set;}
    public Attachment AttToUpdate {get; set;}
    public Attachment DummyAttachment {get; set;}
    
    public Boolean isCommunityUser {get; set;}
    
    public boolean displayPopup {get; set;}  
    public boolean displayUpload  {get; set;}  
    public String currentAttRecord {get; set;}
    private String categoryName;
    
    
    public RegistrationAttachmentController(apexPages.standardController controller){
        categoryName = ApexPages.currentPage().getParameters().get('category');
        sObject thisObj = (sObject)controller.getRecord();
        thisObjId = thisObj.Id;
        thisObjIdShort = thisObjId.subString(0, thisObjId.length() - 3);
        
        displayPopup = false;
        displayUpload = false;
        currentAttRecord = '';
        isCommunityUser = false;
        DummyAttachment = new Attachment();
        AttToUpdate = new Attachment();
        
        String UserProfile = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
        if(UserProfile.contains('Community'))
            isCommunityUser = true;
            
        
    }
    
    public List<AttPlusWrapper> getAttPlus() {
        AttPlusWrapperList = new List<AttPlusWrapper>();
        
        Map<Id, Attachments_Plus__c> attPlusMap = new Map<Id, Attachments_Plus__c>([SELECT Id, Attachment_ID__c, Attachment_Name__c, Type__c, Instructions__c, Description__c 
        FROM Attachments_Plus__c WHERE Registration__c =:thisObjId AND Registration_Document_Category__c =: categoryName]);
        List<Attachment> allRelatedAttachments = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN: attPlusMap.keySet()];
        Map<Id, Attachment> relAttMap = new Map<Id, Attachment>();
        for( Attachment a: allRelatedAttachments ) {
            if(!relAttMap.containsKey(a.ParentId))
                relAttMap.put(a.ParentId, a);
        }
        
        for(Id ap: attPlusMap.keySet()) {
            Attachments_Plus__c currentAttPlus = attPlusMap.get(ap);
            if(relAttMap.containsKey(ap)) {
                Attachment currentAttachment = relAttMap.get(ap);
                AttPlusWrapperList.add(new AttPlusWrapper(currentAttPlus, currentAttachment, true));
            } else {
                AttPlusWrapperList.add(new AttPlusWrapper(currentAttPlus, null, false));
            }
        }
        
        return AttPlusWrapperList; 
    }
    
    public void DisplayAttachment() {
        DummyAttachment = new Attachment();
        displayUpload = true; 
    }
    
    
    
    public PageReference UploadAttachment() {
        
        try {
            DummyAttachment.ParentId = currentAttRecord;
            insert DummyAttachment;
            
        } catch(DMLException ex) {
            return null;
        }
        
        Attachments_Plus__c currentAttPlus = [SELECT Id, Attachment_ID__c, Attachment_Name__c FROM Attachments_Plus__c WHERE Id=:currentAttRecord];
        currentAttPlus.Attachment_ID__c =  DummyAttachment.Id;
        try {
            update currentAttPlus;
        } catch(DMLException ex) {
            return null;
        } 
        
        DummyAttachment = new Attachment(); 
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'The document was successfully uploaded.');
        ApexPages.addMessage(myMsg); 
        return null;
    }
    

    
    public void EditAttachment() {
        displayPopup = true;
        AttToUpdate = new Attachment();
        //String attplusid = System.currentPageReference().getParameters().get('attPlusId');
        AttPlusToUpdate = [SELECT Id, Date_Submitted__c, Attachment_Name__c, Expiration_Date__c, Type__c, Instructions__c, Description__c FROM Attachments_Plus__c WHERE Id =: currentAttRecord ORDER BY CreatedDate DESC]; 
        //AttToUpdate = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentID =: AttPlusToUpdate.Id];
    }
    

    public PageReference UpdateRecord() {        
        
        try {
            update AttPlusToUpdate;
            
        } catch(DMLException ex) {
            return null;
        } 
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'The record was successfully updated.');
        ApexPages.addMessage(myMsg);
        return null;
    } 
    public PageReference UploadUpdateAttachment() {
        
        Attachments_Plus__c apnew = AttPlusToUpdate.clone(false);
        apnew.Registration__c = thisObjId;
        try {
            insert apnew;
        } catch(DMLException ex) {
            return null;
        }

        Attachment newatt = new Attachment(Name = AttToUpdate.Name, ParentId = apnew.Id, Body = AttToUpdate.Body);
        try {
            insert newatt;
        } catch(DMLException ex) {
            return null;
        }
        
        Attachments_Plus__c currentAttPlus = [SELECT Id, Attachment_ID__c, Attachment_Name__c FROM Attachments_Plus__c WHERE Id=:apnew.Id];
        currentAttPlus.Attachment_ID__c =  newatt.Id;
        try {
            update currentAttPlus;
        } catch(DMLException ex) {
            return null;
        } 
         
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'The document was successfully uploaded.');
        ApexPages.addMessage(myMsg);
        AttToUpdate = new Attachment();
        return null;
    }
         
    public void Cancel() {        
        displayPopup = false; 
        AttToUpdate = new Attachment();
        DummyAttachment = new Attachment();   
    } 
    
    public void CancelUpload() {        
        displayUpload = false; 
        AttToUpdate = new Attachment();
        DummyAttachment = new Attachment();  
    }
    
    
    public class AttPlusWrapper {

        public Attachments_Plus__c attPlus { get; set; }
        public Attachment attachment { get; set; }
        public Boolean hasAttachment {get; set;}

        public AttPlusWrapper(Attachments_Plus__c  ap, Attachment a, Boolean hatt) {
            this.attPlus = ap;
            this.attachment = a;
            this.hasAttachment = hatt;
        }
    }
    
    
}