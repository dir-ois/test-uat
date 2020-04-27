trigger Reg_attachment_counter_trigger on Reg_attachment_counter__e (after insert) {
    List<ContentDocumentLink> cdlList_new = new List<ContentDocumentLink>();
    List<ContentDocumentLink> cdlList_del = new List<ContentDocumentLink>();
    
    for(Reg_attachment_counter__e event : trigger.new){
        if(event.Action__c != null && event.Action__c == 'insert'){
            cdlList_new.add(new ContentDocumentLink(id = event.CDL_Id__c, LinkedEntityId = event.Linked_Entity_ID__c));
        }else if(event.Action__c != null && event.Action__c == 'delete'){
            cdlList_del.add(new ContentDocumentLink(id = event.CDL_Id__c, LinkedEntityId = event.Linked_Entity_ID__c));
        }
    }
    
    ContentDocumentLinkHandler handler = new ContentDocumentLinkHandler();
    if(cdlList_new.size() > 0){
        handler.onAfterInsert(cdlList_new, null);
    }
    if(cdlList_del.size() > 0){
       handler.onBeforeDelete(cdlList_del, null);
    }
}