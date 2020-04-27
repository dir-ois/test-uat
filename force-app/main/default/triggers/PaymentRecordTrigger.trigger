trigger PaymentRecordTrigger on Payment_Record__c (before insert, after insert, before update, after update, after delete){
    if(trigger.isBefore){
        
    }
    
    if(trigger.isAfter){
        if(trigger.isUpdate || trigger.isInsert){
            PaymentRecordMethods.afterUpdateOrInsert(trigger.new);
        }
        
        if(trigger.isDelete){
            PaymentRecordMethods.afterDelete(trigger.old);
        }
    }
}