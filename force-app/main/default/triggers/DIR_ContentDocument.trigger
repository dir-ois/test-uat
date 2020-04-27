trigger DIR_ContentDocument on ContentDocument (before delete) {   
    
    if(trigger.isBefore && trigger.isDelete && A_Plus_Controller.isNotAplusMode){
        
        DIR_ContentDocumentTriggerHandler.onBeforeDelete(trigger.oldMap); 
    }
}