trigger Contact_Trigger on Contact (before insert, before update, after update) {
	if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert)) {
		Contact_Methods.beforeUpsert(trigger.new, trigger.oldMap);
	}
	if(trigger.isAfter && trigger.isUpdate) {
		Contact_Methods.afterUpdate(trigger.new, trigger.oldMap);
	}
}