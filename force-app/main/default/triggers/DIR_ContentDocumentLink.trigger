trigger DIR_ContentDocumentLink on ContentDocumentLink (before delete, after insert) {
    
    if(trigger.isBefore && trigger.isDelete && A_Plus_Controller.isNotAplusMode){
        
        DIR_ContentDocumentLinkTriggerHandler.onBeforeDelete(trigger.oldMap);
    }
    
     if(trigger.isAfter && trigger.isInsert){
         
        DIR_ContentDocumentLinkTriggerHandler.onAfterInsert(trigger.newMap);
    }
}