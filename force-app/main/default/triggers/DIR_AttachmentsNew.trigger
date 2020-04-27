trigger DIR_AttachmentsNew on Attachments_New__c (before delete) {
    
    if(A_Plus_Controller.isNotAplusMode){
        
        DIR_AttachmentsNewTriggerHandler.onBeforeDelete(trigger.oldMap);
    }
}