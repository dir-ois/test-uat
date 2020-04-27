trigger position_Trigger on Position__c (before insert, before update, before delete) {

	if (trigger.isBefore && trigger.isInsert){
		position_Methods.beforeInsert(trigger.new);
	}
	
	if (trigger.isBefore && trigger.isUpdate){
		position_Methods.beforeUpdate(trigger.old, trigger.new);
	}
}