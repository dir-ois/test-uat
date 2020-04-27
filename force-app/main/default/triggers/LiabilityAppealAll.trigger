trigger LiabilityAppealAll on Liability_Appeal__c (after insert) {

	if (Trigger.isAfter && Trigger.isInsert) {
		CreateAppealedLiability();
	}
	
	public void CreateAppealedLiability() {
		
		Set<Id> liabIds = new Set<Id>();
		for (Liability_Appeal__c la : Trigger.new) {
			liabIds.add(la.Liability__c);
		}
		
		Map<Id, Liability__c> liabs = new Map<Id, Liability__c>([SELECT Assessment__c FROM Liability__c WHERE Id IN :liabIds]);
		Map<Id, Id> lasToAssess = new Map<Id, Id>();
		for (Liability_Appeal__c la : Trigger.new) {
			lasToAssess.put(la.Id, liabs.get(la.Liability__c).Assessment__c);
		}
		
		Set<Id> assessIds = new Set<Id>();
		for (Liability__c liab : liabs.values()) {
			assessIds.add(liab.Assessment__c);
		}
		
		List<DIR_Violation__c> viols = [SELECT Id, Assessment__c FROM DIR_Violation__c WHERE Assessment__c IN :assessIds];
		
		List<Appealed_Violation__c> appViols = new List<Appealed_Violation__c>();
		for (DIR_Violation__c viol : viols) {
			for (Liability_Appeal__c la : Trigger.new) {
				if (lasToAssess.get(la.Id) == viol.Assessment__c) {
					Appealed_Violation__c appViol = new Appealed_Violation__c();
					appViol.Liability_Appeal__c = la.Id;
					appViol.Case_Violation__c = viol.Id;
					appViols.add(appViol);
				}
			}
		}
		
		insert appViols;
		
	}

}