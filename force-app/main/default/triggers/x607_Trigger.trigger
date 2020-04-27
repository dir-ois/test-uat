trigger x607_Trigger on X607__c (after update) {

	if ( trigger.isAfter && trigger.isUpdate ){
		x607_Methods.afterUpdate(trigger.new, trigger.old);
	}

}