/*
 * class to take actions on creation of content document links
 * 
 * Initial goal is to count files attached to submission details (legacy attachments plus) and roll that count
 * to the registration to which it belongs. 
 * 
 * 
 * 
 */
public without sharing class ContentDocumentLinkHandler {

    public void onAfterInsert(list<ContentDocumentLink> newList, map<id, ContentDocumentLink> newMap){
        rollupCDL(newList, newMap);
    }
    
    public void onBeforeDelete(list<ContentDocumentLink> oldList, map<id, ContentDocumentLink> oldMap ){
        rollupCDL_Delete(oldList, oldMap);
    }
    
    
    // class methods
    
    //method to rollup cdl count to registration and to submission detail record
    public void rollupCDL(list<ContentDocumentLink> newList, map<Id, ContentDocumentLink> newMap){
        System.debug('##### Entering rollupCDL Method #####');
        
        list<License_Registration__c> regList = new list<License_Registration__c>();
        List<Attachments_Plus__c> attPlusList = new List<Attachments_Plus__c>();
        set<Id> aPlusIds = new set<Id>();
        set<Id> regIds = new set<Id>();
        Map<string, License_Registration__c> regMap = new Map<string, License_Registration__c>();
        
        
        // get the prefex for the attachments plus object
        //string aPlusPrefix = objectPrefixHelper();
        
        for(ContentDocumentLink l : newList){
            Schema.SObjectType sObjectType = l.LinkedEntityId.getSObjectType();
            if(sObjectType == Attachments_Plus__c.SObjectType){
                system.debug('##### file is on AttachmentsPlus');
                aPlusIds.add(l.LinkedEntityId);
            }
        }
        
        if(aPlusIds.size() > 0){
            for(Attachments_Plus__c  aPlus : [Select ID, Registration__c FROM Attachments_Plus__c WHERE ID in :aPlusIds]){
                regIds.add(aPlus.Registration__c);
            }
            
            Set<Id> attPlusSet = new Set<Id>();
            for(Attachments_Plus__c aPlus : [select id, Number_of_Attachments__c, Attachment_Required__c, (select id from ContentDocumentLinks) from Attachments_Plus__c WHERE Registration__c in :regIds]){
                system.debug('aPlus***'+aPlus);
                if(aPlus.ContentDocumentLinks != null && aPlus.ContentDocumentLinks.size() > 0){
                    aPlus.Number_of_Attachments__c = aPlus.ContentDocumentLinks.size();
                    if(aPlus.Attachment_Required__c){
                        attPlusSet.add(aPlus.id);
                    }
                }else{
                    aPlus.Number_of_Attachments__c = 0;
                }
                attPlusList.add(aPlus);
            }
            system.debug('attPlusList****'+attPlusList);
            update attPlusList;
            for(License_Registration__c reg : [Select Id, Number_of_Attachments__c, Number_of_Attachments_Required__c,
                                        (select id from Submission_Detail__r WHERE Attachment_Required__c = true)
                                       from License_Registration__c WHERE Id IN :regIds]){
                if(reg.Submission_Detail__r != null && reg.Submission_Detail__r.size() > 0){
                    reg.Number_of_Attachments_Required__c = reg.Submission_Detail__r.size();
                    
                    Integer count = 0;
                    for(Attachments_Plus__c aPlus : reg.Submission_Detail__r){
                        if(attPlusSet.contains(aPlus.id)){
                            count = count + 1;
                        }
                        
                    }
                    reg.Number_of_Attachments__c = count;
                }else{
                    reg.Number_of_Attachments_Required__c = 0;
                }
                regList.add(reg);
            }
            if(regList.size() > 0){
                update regList;
            }
        }
    }
    
    
    public void rollupCDL_Delete(list<ContentDocumentLink> newList, map<Id, ContentDocumentLink> newMap){
        System.debug('##### Entering rollupCDL_Delete Method #####');
        
        list<License_Registration__c> regList = new list<License_Registration__c>();
        List<Attachments_Plus__c> attPlusList = new List<Attachments_Plus__c>();
        set<Id> aPlusIds = new set<Id>();
        set<Id> regIds = new set<Id>();
        
        
        // get the prefex for the attachments plus object
        //string aPlusPrefix = objectPrefixHelper();
        
        for(ContentDocumentLink l : newList){
            Schema.SObjectType sObjectType = l.LinkedEntityId.getSObjectType();
            if(sObjectType == Attachments_Plus__c.SObjectType){
                system.debug('##### file is on AttachmentsPlus');
                aPlusIds.add(l.LinkedEntityId);
            }
        }
        
        if(aPlusIds.size() > 0){
            for(Attachments_Plus__c  aPlus : [Select ID, Registration__c FROM Attachments_Plus__c WHERE ID in :aPlusIds]){
                regIds.add(aPlus.Registration__c);
            }
            
            Set<Id> attPlusSet = new Set<Id>();
            for(Attachments_Plus__c aPlus : [select id, Attachment_Required__c, Number_of_Attachments__c, (select id from ContentDocumentLinks) from Attachments_Plus__c WHERE Registration__c in :regIds]){
                system.debug('aPlus ***'+aPlus );
                if(aPlus.ContentDocumentLinks != null && aPlus.ContentDocumentLinks.size() > 0){
                system.debug('aPlusIds.contains(aPlus.id)******'+aPlusIds.contains(aPlus.id));
                    if(aPlusIds.contains(aPlus.id)){
                        aPlus.Number_of_Attachments__c = aPlus.ContentDocumentLinks.size() - 1;
                        system.debug('inside if***'+aPlus.Number_of_Attachments__c);
                    }else{
                        aPlus.Number_of_Attachments__c = aPlus.ContentDocumentLinks.size();
                        system.debug('inside else****'+aPlus.Number_of_Attachments__c);
                        if(aPlus.Attachment_Required__c){
                            attPlusSet.add(aPlus.id);
                        }
                    }
                }else{
                    aPlus.Number_of_Attachments__c = 0;
                }
                system.debug('attPlusList****'+attPlusList);
                attPlusList.add(aPlus);
            }
            
            update attPlusList;
            for(License_Registration__c reg : [Select Id, Number_of_Attachments__c, Number_of_Attachments_Required__c,
                                        (select id from Submission_Detail__r WHERE Attachment_Required__c = true)
                                       from License_Registration__c WHERE Id IN :regIds]){
                if(reg.Submission_Detail__r != null && reg.Submission_Detail__r.size() > 0){
                    reg.Number_of_Attachments_Required__c = reg.Submission_Detail__r.size();
                    
                    Integer count = 0;
                    for(Attachments_Plus__c aPlus : reg.Submission_Detail__r){
                        if(attPlusSet.contains(aPlus.id)){
                            count = count + 1;
                        }
                    }
                    reg.Number_of_Attachments__c = count;
                }else{
                    reg.Number_of_Attachments_Required__c = 0;
                }
                regList.add(reg);
            }
            if(regList.size() > 0){
                update regList;
            }
        }
    }
    
    /*
    // private, helper methods
    private string objectPrefixHelper(){
        // get keyPrefix for sumbmission details
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        system.debug('##### m is==>'+m);
        Schema.SObjectType s = m.get('Attachments_Plus__c') ;
        system.debug('##### Sobject Type is ==>'+s);
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        system.debug('#### keyPrefix: ' + keyPrefix);
        return keyPrefix;
    }
    
    */
    
    public void broadcastReg_attachment_counter(List<ContentDocumentLink> cdlList, String dmlAction){
        List<Reg_attachment_counter__e> cdlEvents = new List<Reg_attachment_counter__e>();
        for(ContentDocumentLink cdl : cdlList){
            cdlEvents.add(new Reg_attachment_counter__e(CDL_Id__c = cdl.id, Linked_Entity_ID__c = cdl.LinkedEntityId, Action__c = dmlAction));
        }
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(cdlEvents);
        // Inspect publishing result for each event
        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                System.debug('Successfully published event.');
            }else{
                for(Database.Error err : sr.getErrors()){
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
            
    }
}