/********************************************************************************************************
Name:  LicenseRegistrationAll.trigger
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  10/03/2017
Modified by: 
Date:
Handler class: LicenseRegistrationAllHandler.cls
Test class: LicenseRegistrationAllTest.cls

********************************************************************************************************/
trigger LicenseRegistrationAll on License_Registration__c (before insert, before update, after insert, after update, before delete, after delete) {
    if(Label.runRegistrationTrigger=='true'){
    
    
    LicenseRegistrationAllHandler handler = LicenseRegistrationAllHandler.getInstance();
    
    if (Trigger.isInsert) {
        if (Trigger.isBefore)
            handler.onBeforeInsert(Trigger.New) ;
            
        if (Trigger.isAfter) 
            handler.onAfterInsert(Trigger.New, Trigger.NewMap);
    }
    
    if (Trigger.isUpdate) {
        if (Trigger.isBefore)
            handler.onBeforeUpdate(Trigger.New, Trigger.NewMap, Trigger.oldMap);
        
        if (Trigger.isAfter)
            handler.onAfterUpdate(Trigger.New, Trigger.NewMap , Trigger.oldMap);
    }

    if (Trigger.isDelete) {
        if (Trigger.isBefore)
            handler.onBeforeDelete(Trigger.Old, Trigger.oldMap);
        
        if (Trigger.isAfter)
            handler.onAfterDelete(Trigger.Old, Trigger.oldMap );
    }
    
    }
}