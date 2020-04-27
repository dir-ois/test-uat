trigger RejectionDefectTrigger on Rejection_Defect__c (before insert, after insert, before update, after update, after delete) {
    
    RejectionDefectTriggerHandler handler = new RejectionDefectTriggerHandler();
    
      if ( trigger.isBefore && trigger.isInsert ){
      
      }
      if ( trigger.isAfter && trigger.isInsert ){
          handler.afterInsert(trigger.new);
      }
      if ( trigger.isAfter && trigger.isUpdate ){
        System.debug('88888');
        handler.afterUpdate(trigger.new, trigger.oldMap);
      }
      if ( trigger.isBefore && trigger.isUpdate ){

      }
      if ( trigger.isAfter && trigger.isDelete ){
        handler.afterDelete(trigger.old);
      }
      
}