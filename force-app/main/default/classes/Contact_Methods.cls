public with sharing class Contact_Methods {
	public static List<Account> otherContactsAccount = [Select Id From Account Where Name = 'Public Contacts' limit 1];
	
	public static void beforeUpsert(List<Contact> newList, Map<Id, Contact> oldMap) {
		for(Contact c : newList) {
			if(c.AccountId == null && otherContactsAccount.size() > 0) {
				c.AccountId = otherContactsAccount[0].Id;
			}
		}
	}
	
	public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
		
		Set<Id> contactIds = new Set<Id>();
		for(Contact con : newList) {
			if(con.FirstName != oldMap.get(con.Id).FirstName || con.LastName != oldMap.get(con.Id).LastName) {
				contactIds.add(con.Id);
			}
		}
		
		System.debug(contactIds);
		
		List<Wage_Claim_Party__c> wcpToUpdate = [Select Id From Wage_Claim_Party__c Where Contact__c IN :contactIds];
		if(wcpToUpdate.size() > 0) {
			update wcpToUpdate;
		}
		
		List<Appeal_Party__c> apToUpdate = [Select Id From Appeal_Party__c Where Contact__c IN :contactIds];
		if(apToUpdate.size() > 0) {
			update apToUpdate;
		}
	}
}