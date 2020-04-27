trigger CaseRoleAll on Case_Role__c (before insert, before update, after insert, after update, after delete) {

    //before methods
    if (trigger.isBefore){
        if(trigger.isInsert){
            caseRollMethods.applyLocation(trigger.new);
            InsertAccountName(trigger.new);
        }
    }
    
    if (Trigger.isAfter){
        if(Trigger.isInsert) {
            CreateAffiliations();
			caseRollMethods.countDefs(trigger.new);            
            
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
            }
            
        }
        else if(Trigger.isUpdate) {
            caseRollMethods.countDefs(trigger.old);
            // PT-000045:Consolidate Multiple Triggers Per Object
            if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
            }
        }
        else if(Trigger.isDelete){
            caseRollMethods.countDefs(trigger.old);
        }
    }
    

    
    public void CreateAffiliations() {
        
        if (DIRCaseTriggerHandler.stopAffiliationCreation)
            return;

        list<Case_Role__c> applicableCaseRoles = new list<Case_Role__c>();
        // don't create affiliation of the case employer/defendant to itself
        List<Id> idList = new List<Id>();
        for(Case_Role__c cr : trigger.new){
            idList.add(cr.Id);
        }
        List<Case_Role__c> crList = [SELECT Id, Name, case__r.Employer__c, Entity__c, Role__c FROM Case_Role__c WHERE Id IN: idList];
        for(Case_Role__c cr : crList){
            system.debug(' ***** checking the case role entity against the case employer ******');
            system.debug(' **** cr entity: ' + cr.Entity__c + ' and case employer: ' + cr.case__r.Employer__c);
            if (cr.Entity__c <> cr.Case__r.Employer__c)
                applicableCaseRoles.add(cr);
        }
        
        // Get affiliation pairs first
        Map<String, Affiliation_Pair__c> affPairMap = new Map<String, Affiliation_Pair__c>();
        for (Affiliation_Pair__c ap : [SELECT Name, Relationship__c FROM Affiliation_Pair__c]) {
            affPairMap.put(ap.Name, ap);
        }
        
        // Get the account ids (both main and affiliated)
        Set<Id> mainAccIds = new Set<Id>();
        Set<Id> affAccIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();

        for (Case_Role__c cr : applicableCaseRoles) {
            affAccIds.add(cr.Entity__c);
            caseIds.add(cr.Case__c);
        }
        Map<Id, DIR_Case__c> cases = new Map<Id, DIR_Case__c>([SELECT Employer__c, Employer__r.Name, Employer__r.IsPersonAccount, Employer__r.firstName, Employer__r.lastName FROM DIR_Case__c WHERE Id IN :caseIds AND Employer__c != NULL]);
        for (DIR_Case__c cs : cases.values()) {
            mainAccIds.add(cs.Employer__c);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name, IsPersonAccount, FirstName, lastName FROM Account WHERE Id IN :affAccIds]);
        
        // Get the affiliations
        List<Affiliation__c> affiliations = [SELECT Id, Main_Account__c, Affiliated_Account__c FROM Affiliation__c WHERE Main_Account__c IN :mainAccIds AND Affiliated_Account__c IN :affAccIds];
        
        // Go through case roles and check if there any affiliations
        List<Affiliation__c> affiliationsToInsert = new List<Affiliation__c>();
        for (Case_Role__c cr : applicableCaseRoles) {
            DIR_Case__c thisCase = cases.get(cr.Case__c);
            Account thisAccount = accMap.get(cr.Entity__c);
            
            //Modified By Oswin 2/5/18 For Null Pointer Exceptions
            
            String caseEmployerName = '';
            String caseRoleEntityName = '';
            
            if(thisAccount != Null && thisAccount.IsPersonAccount){
                caseRoleEntityName = ((String.isNotBlank(thisAccount.firstName) ? thisAccount.firstName : '')+' '+(String.isNotBlank(thisAccount.lastName) ? thisAccount.lastName : '')).trim();
            }
            else{
                caseRoleEntityName = thisAccount.Name;
            }
            if(thisCase != Null && thisCase.Employer__c != Null){
            
                if(thisCase.Employer__r.IsPersonAccount){
                    caseEmployerName = ((String.isNotBlank(thisCase.Employer__r.firstName) ? thisCase.Employer__r.firstName : '')+' '+(String.isNotBlank(thisCase.Employer__r.lastName) ? thisCase.Employer__r.lastName : '')).trim();
                }
                else{
                    caseEmployerName = thisCase.Employer__r.Name;
                }
            }
            

            
            if(caseEmployerName.length() > 36) caseEmployerName = caseEmployerName.subString(0, 36);
            if(caseRoleEntityName.length() > 36) caseRoleEntityName = caseRoleEntityName.subString(0, 36);
            boolean foundAffiliation = false;
            for (Affiliation__c affiliation : affiliations) {
                if (affiliation.Main_Account__c == cases.get(cr.Case__c).Employer__c && affiliation.Affiliated_Account__c == cr.Entity__c) {
                    foundAffiliation = true;
                    break;
                }
            }
            if (!foundAffiliation) {
                if (affPairMap.containsKey(cr.Role__c)) {
                    // First affiliation
                    Affiliation__c aff = new Affiliation__c();
                    aff.Name = caseEmployerName + ' >> ' + caseRoleEntityName;
                    //if block added
                    if(cr.Case__c != Null && cases.containsKey(cr.Case__c)){
                        aff.Main_Account__c = cases.get(cr.Case__c).Employer__c;
                    }
                    aff.Affiliated_Account__c = cr.Entity__c;
                    aff.Affiliation_Type__c = affPairMap.get(cr.Role__c).Name;
                    affiliationsToInsert.add(aff);
                    // Second affiliation
                    aff = new Affiliation__c();
                    aff.Name =  caseRoleEntityName + ' >> ' + caseEmployerName;
                    aff.Main_Account__c = cr.Entity__c;
                    if(cr.Case__c != Null && cases.containsKey(cr.Case__c)){
                    
                        aff.Affiliated_Account__c = cases.get(cr.Case__c).Employer__c;
                        //commented
                        //aff.Main_Account__c = cases.get(cr.Case__c).Employer__c;
                    }
                        
                    aff.Affiliation_Type__c = affPairMap.get(cr.Role__c).Relationship__c;
                    affiliationsToInsert.add(aff);
                } else {
                    // First affiliation
                    Affiliation__c aff = new Affiliation__c();
                    aff.Name = caseEmployerName + ' >> ' + caseRoleEntityName;
                    
                    if(cr.Case__c != Null && cases.containsKey(cr.Case__c)){
                         aff.Affiliated_Account__c = cases.get(cr.Case__c).Employer__c;
                         aff.Main_Account__c = cases.get(cr.Case__c).Employer__c;
                    }
                        
                        
                    aff.Affiliated_Account__c = cr.Entity__c;
                    aff.Affiliation_Type__c = cr.Role__c;
                    affiliationsToInsert.add(aff);
                    // Second affiliation
                    aff = new Affiliation__c();
                    aff.Name =  caseRoleEntityName + ' >> ' + caseEmployerName;
                    aff.Main_Account__c = cr.Entity__c;
                    aff.Affiliation_Type__c = 'Unknown';
                    affiliationsToInsert.add(aff);
                }
            }
        }
        insert affiliationsToInsert;
        
    }
    
    public void InsertAccountName(List<Case_Role__c> newList){
        set<Id> idSet = new set<Id>();
        for(Case_Role__c cr : newList){
            if(!idSet.contains(cr.Entity__c)){
                idSet.add(cr.Entity__c);
            }
        }
        Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Name, firstName, lastName, IsPersonAccount FROM Account WHERE Id IN: idSet]);
        for(Case_Role__c cr : newList){
            if (accountMap.size() > 0){
                Account a = accountMap.get(cr.Entity__c);
                
                if(a.IsPersonAccount){
                    cr.Account_Name__c = a.firstName+' '+a.lastName;
                }
                else{
                    cr.Account_Name__c = a.Name;
                }
            }    
        }
            
    }

}