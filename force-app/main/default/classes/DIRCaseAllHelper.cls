public with sharing class DIRCaseAllHelper {

	public static boolean stopAffiliationCreation = false;

	public static void AddErrorsToCase(List<DIR_Case__c> cases) {
		
		Set<Id> caseIds = new Set<Id>();
		for (DIR_Case__c cs : cases) {
			if (cs.Refer_to_JEU__c == 'Referred') {
				caseIds.add(cs.Id);
			}
		}
		
		Map<Id, AggregateResult> PaymentPlans = new Map<Id, AggregateResult>([SELECT Case__c Id, COUNT(Id) Number FROM Payment_Plan__c WHERE Case__c IN :caseIds AND Payment_Plan_Status__c = 'Not Current' GROUP BY Case__c]);
		system.debug('PaymentPlans::: ' + PaymentPlans);
        
		//Map<Id, AggregateResult> Hearings = new Map<Id, AggregateResult>([SELECT Case__c Id, MAX(Hearing_Date__c) MaxDate FROM Hearing__c WHERE Case__c IN :caseIds  GROUP BY Case__c]);
		
		integer noDays = 0;
		List<Key_Value_Store__c> keyValueStoreList = [SELECT Id, Value__c FROM Key_Value_Store__c WHERE Name = 'BOFE JEU Referral Hearing Timeframe'];
		if (keyValueStoreList.size() != 0)
			noDays = integer.valueOf(keyValueStoreList.get(0).Value__c);
				
		for (DIR_Case__c cs : cases) {
			if (cs.Refer_to_JEU__c == 'Referred') {
				if (!PaymentPlans.containsKey(cs.Id) & PaymentPlans.size() > 0) {
					cs.addError('All Payment Plans are current for this case, it cannot be referred to JEU');
				}
				/*
				// performing this via flow and standard valication rule now
				if (Hearings.containsKey(cs.Id)) {
					if (Date.today().daysbetween(((DateTime)Hearings.get(cs.Id).get('MaxDate')).Date()) < noDays) {
						cs.addError('A hearing has been scheduled too recently to refer this case to JEU.');
					}
				}
				*/
			}
		}
		
	}

}