/********************************************************************************************************
Name:  RegistrationQuestionAll.trigger
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  10/03/2017
Modified by: 
Date:
Test class: RegistrationQuestionAllTest.cls

Behavior: When a user answers a question, the answer field ( reg_answer__c ) on the registration question 
record is populated. This should trigger looking up to see if there are any follow-up questions necessary 
for the question that was answered. 
 
********************************************************************************************************/

trigger RegistrationQuestionAll on Registration_Question__c (before insert, after insert, before update, after update, before delete, after delete) {
    
    RegistrationQuestionAllHandler handler = new RegistrationQuestionAllHandler();
    
    if (Trigger.isInsert) {
        if (Trigger.isBefore)
            handler.onBeforeInsert(Trigger.New, Trigger.NewMap ) ;
            
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