trigger payment_Trigger on Payment__c (after insert, after update) {
	if ( trigger.isAfter && trigger.isInsert ){
		payment_Methods.afterInsert(trigger.new);
	}
	if ( trigger.isAfter && trigger.isUpdate ){
		payment_Methods.afterUpdate(trigger.new, trigger.old);
	}
}