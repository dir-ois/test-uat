trigger ContentDocumentLinkTrigger on ContentDocumentLink (after Insert, before Delete) {
    
    ContentDocumentLinkHandler handler = new ContentDocumentLinkHandler();
    
    if(trigger.isInsert && trigger.isAfter){
        handler.onAfterInsert(Trigger.New, Trigger.NewMap);
        //handler.broadcastReg_attachment_counter(trigger.new, 'insert');
    }
    
    if(trigger.isDelete && trigger.isBefore){
        handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
        //handler.broadcastReg_attachment_counter(trigger.old, 'delete');
    }

}