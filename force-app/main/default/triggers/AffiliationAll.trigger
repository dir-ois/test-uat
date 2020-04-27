trigger AffiliationAll on Affiliation__c (after delete) {

	if (Trigger.isAfter && Trigger.isDelete)
		DeletePair();
		
	public void DeletePair() {
		
		Set<Id> mainAccIds = new Set<Id>();
		Set<Id> mainCntIds = new Set<Id>();
		Set<Id> afflAccIds = new Set<Id>();
		Set<Id> afflCntIds = new Set<Id>();
		
		for (Affiliation__c ap : Trigger.old) {
			if (ap.Main_Account__c != null)
				mainAccIds.add(ap.Main_Account__c);
			if (ap.Main_Contact__c != null)
				mainCntIds.add(ap.Main_Contact__c);
			if (ap.Affiliated_Account__c != null)
				afflAccIds.add(ap.Affiliated_Account__c);
			if (ap.Affiliated_Contact__c != null)
				afflCntIds.add(ap.Affiliated_Contact__c);
		}
		
		List<Affiliation__c> pairs = [SELECT Main_Account__c, Main_Contact__c, Affiliated_Account__c, Affiliated_Contact__c FROM Affiliation__c 
										WHERE (Main_Account__c IN :afflAccIds OR Main_Contact__c IN :afflCntIds) 
										  AND (Affiliated_Account__c IN :mainAccIds OR Affiliated_Contact__c IN :mainCntIds)];
										  
		Map<Id, Affiliation__c> toDelete = new Map<Id, Affiliation__c>();
		
		for (Affiliation__c ap : Trigger.old) {
			for (Affiliation__c pr : pairs) {
				if (ap.Main_Account__c == pr.Affiliated_Account__c && ap.Main_Contact__c == pr.Affiliated_Contact__c &&
					ap.Affiliated_Account__c == pr.Main_Account__c && ap.Affiliated_Contact__c == pr.Main_Contact__c) {
					toDelete.put(pr.Id, pr);
				}
			}
		}
		
		if (toDelete.size() > 0)
			delete toDelete.values();
		
	}

}