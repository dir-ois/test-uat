trigger inspectionAll on DIR_Inspection__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    if(trigger.isInsert){
        if(trigger.isAfter){
            updateMinorEmployee();
            // PT-000045:Consolidate Multiple Triggers Per Object
                GenerateFieldHistoryAction.runHandler();

        }
    } 
    
    else if(trigger.isUpdate){
        
        if(trigger.isAfter){ 
            // PT-000045:Consolidate Multiple Triggers Per Object           
                GenerateFieldHistoryAction.runHandler();          
        }
    }	
    
	public void updateMinorEmployee(){
		
		Set<Id> dcSet = new Set<Id>();
		Map<Id, Id> caseToInspection = new Map<Id, Id>();
		for (DIR_Inspection__c i : trigger.new){
			dcSet.add(i.DIR_Case__c);
			caseToInspection.put(i.DIR_Case__c, i.Id);
		}
		
		List<Report_of_Labor_Code_Violation__c> rlcvList = new List<Report_of_Labor_Code_Violation__c>();
		rlcvList = [SELECT Id FROM Report_of_Labor_Code_Violation__c WHERE DIR_Case__c IN : dcset];
		
		Set<Id> rlcvSet = new Set<Id>();
		for (Report_of_Labor_Code_Violation__c rlcv : rlcvList)
			rlcvSet.add(rlcv.Id);
			
		List<Minor_Employee__c> meList = new List<Minor_Employee__c>();
		meList = [SELECT Id, Report_of_Labor_Code_Violation__r.DIR_Case__c, Report_of_Labor_Code_Violation__c, Inspection__c FROM Minor_Employee__c WHERE Report_of_Labor_Code_Violation__c IN : rlcvSet];
		
		for (Minor_Employee__c me : meList){
			if ((me.Report_of_Labor_Code_Violation__c != null) && (caseToInspection.containsKey(me.Report_of_Labor_Code_Violation__r.DIR_Case__c)))
				me.Inspection__c = caseToInspection.get(me.Report_of_Labor_Code_Violation__r.DIR_Case__c);
		}
		
		update meList;
	}

}