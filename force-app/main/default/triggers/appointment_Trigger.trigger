trigger appointment_Trigger on Appointment__c (before insert, after insert, before update, after update, after delete) {

	if ( trigger.isBefore && trigger.isInsert ){
		appointment_Methods.beforeInsert(trigger.new);
	}
	if ( trigger.isAfter && trigger.isInsert ){
	
	}
	if ( trigger.isAfter && trigger.isUpdate ){
		appointment_Methods.afterUpdate(trigger.new, trigger.old);
	}
	if ( trigger.isBefore && trigger.isUpdate ){
		appointment_Methods.beforeUpdate(trigger.new, trigger.old);
	}
	if ( trigger.isAfter && trigger.isDelete ){
		appointment_Methods.afterDelete(trigger.old);
	}
}