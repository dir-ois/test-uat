trigger ConfiscationBagAll on Confiscation_Bag__c (after update) {

	if (Trigger.isAfter && Trigger.isUpdate) {
		UpdateChildItems();
	}
	
	public void UpdateChildItems() {
		
		Set<Id> bags = new Set<Id>();
		for (Confiscation_Bag__c newBag : Trigger.new) {
			Confiscation_Bag__c oldBag = Trigger.oldMap.get(newBag.Id);
			if (newBag.Returned__c == true && oldBag.Returned__c == false) {
				bags.add(newBag.Id);
			}
		}
		
		List<Confiscated_Item__c> children = [SELECT Id FROM Confiscated_Item__c WHERE Confiscation_Bag__c IN :bags];
		
		if (children.size() > 0) {
			for (Confiscated_Item__c child : children) {
				child.Returned__c = true;
			}
			update children;
		}
		
	}

}