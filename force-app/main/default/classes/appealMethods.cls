public class appealMethods {

    public void WithdrawnAppeals(Set<String> WithdrawnAppealsIds) {
        if(WithdrawnAppealsIds.size() > 0) {
            List<Liability_Appeal__c> LiabilityAppeal = [SELECT Appeal__c, Liability__c FROM Liability_Appeal__c WHERE Appeal__c IN: WithdrawnAppealsIds];
            Set<String> LiabilitySet = new Set<String>();
            for(Liability_Appeal__c lap: LiabilityAppeal ) {
                LiabilitySet.add(lap.Liability__c);
            }
            Map<Id, Liability__c> AllLiabilityMap = new Map<Id, Liability__c>([SELECT Id, Status__c FROM Liability__c WHERE Id IN: LiabilitySet]);
            Map<String, List<Liability__c>> LiabilityListMap = new Map<String, List<Liability__c>>();
            for(Liability_Appeal__c lac: LiabilityAppeal) {
                if(!LiabilityListMap.containsKey(lac.Appeal__c)) {
                    List<Liability__c> newLiability = new List<Liability__c>();
                    Liability__c l = AllLiabilityMap.get(lac.Liability__c);
                    newLiability.add(l);
                    LiabilityListMap.put(lac.Appeal__c, newLiability);
                } else {
                    List<Liability__c> existingLiability = LiabilityListMap.get(lac.Appeal__c);
                    Liability__c l = AllLiabilityMap.get(lac.Liability__c);
                    existingLiability.add(l);
                    LiabilityListMap.put(lac.Appeal__c, existingLiability);
                }
            }

            Map<String, Liability_Appeal__c> ReceivedAppealsMap = new Map<String, Liability_Appeal__c>([SELECT Id, Appeal__c, Appeal__r.Status__c, Liability__c 
                        FROM Liability_Appeal__c WHERE Liability__c IN: LiabilitySet AND (Appeal__r.Status__c = 'Received - Timely' OR Appeal__r.Status__c = 'Hearing Scheduled')]);
            
            Set<String> LiabilitiesToUpdate = new Set<String>();
            if(LiabilityListMap.size() > 0) { 
                for(String lac: WithdrawnAppealsIds) {
                    List<Liability__c> allAppLiabilities = LiabilityListMap.get(lac);
                    Boolean x = true;
                    for(Liability__c l: allAppLiabilities) {
                        if(ReceivedAppealsMap.containsKey(l.Id)){
                            x = false;
                        }
                    }                                                
                    if(x == true){
                        for(Liability__c l: allAppLiabilities) {
                            LiabilitiesToUpdate.add(l.Id);
                        }
                    }
                }
            }
            
            if(LiabilitiesToUpdate.size() > 0) {
                List<Liability__c> Liabilities = [SELECT Id, Status__c FROM Liability__c WHERE Id IN: LiabilitiesToUpdate];
                if(Liabilities.size() > 0) {
                    for(Liability__c l: Liabilities) {
                        l.Status__c = 'Appeal Withdrawn';
                    }
                    update Liabilities;
                }
            }
            
            List<Appeal__c> Appeals = [SELECT Id, Case__c FROM Appeal__c WHERE Id IN: WithdrawnAppealsIds];
            Set<Id> CaseSet = new Set<Id>();
            for(Appeal__c a: Appeals) {
                CaseSet.add(a.Case__c);    
            }
            Map<String, DIR_Case__c> DIRCase = new Map<String, DIR_Case__c>([SELECT Id FROM DIR_Case__c WHERE Id IN: CaseSet]);
            List<Appeal__c> allTheOtherAppeals = [SELECT Id, Case__c FROM Appeal__c WHERE Case__c IN: CaseSet];
            
            Map<String, List<Appeal__c>> CaseMap = new Map<String, List<Appeal__c>>();
            for(Appeal__c a: allTheOtherAppeals) {
                if(!CaseMap.containsKey(a.Case__c)) {
                    List<Appeal__c> newAppList = new List<Appeal__c>();
                    newAppList.add(a);
                    CaseMap.put(a.Case__c, newAppList);
                } else {
                    List<Appeal__c> existingAppList = CaseMap.get(a.Case__c);
                    existingAppList.add(a);
                    CaseMap.put(a.Case__c, existingAppList);
                }
            }
            List<DIR_Case__c> DIRCaseToUpdate = new List<DIR_Case__c>();
            for(String s: CaseMap.keySet()) {
                List<Appeal__c> AllApp = CaseMap.get(s);
                if(AllApp.size() == 1) {
                    if(DIRCase.containsKey(s)) {
                        DIR_Case__c dc = DIRCase.get(s);
                        dc.Status__c = 'Under Investigation';
                        DIRCaseToUpdate.add(dc);
                    }
                }
            }
            if(DIRCaseToUpdate.size() > 0)
                update DIRCaseToUpdate;
        }
    }
 /*   
    public void SetStatusOnCase(List<Appeal__c> appeals) {
      
        Set<Id> caseIds = new Set<Id>();
    
        for (Appeal__c ap : appeals) {
            if (ap.Status__c == 'Received - Timely') {
                caseIds.add(ap.Case__c);
            }
        }
        
        List<DIR_Case__c> extractedCases = [SELECT Status__c FROM DIR_Case__c WHERE Id = :caseIds];
        List<DIR_Case__c> updateCases = new List<DIR_Case__c>();
        for (DIR_Case__c cs : extractedCases) {
            if (cs.Status__c != 'In Appeal') {
                cs.Status__c = 'In Appeal';
                updateCases.add(cs);
            }
        }
        
        if (updateCases.size() > 0) {
            update updateCases;
        }
    
    }
*/    
    public void SetStatusOnLiabilityAppeal(List<Appeal__c> appeals, Map<Id, Appeal__c> oldAppeals) {
        Map<Id, String> appStatuses = new Map<Id, String>();
        for (Appeal__c app : appeals) {
            Appeal__c oldApp = oldAppeals.get(app.Id);
            if (app.Status__c != oldApp.Status__c) {
                appStatuses.put(app.Id, app.Status__c);
            }
        }
        
        if (appStatuses.size() > 0) {
            List<Liability_Appeal__c> liabs = [SELECT Id, Appeal__c, Appeal_Status__c FROM Liability_Appeal__c WHERE Appeal__c IN :appStatuses.keyset()];
            List<Liability_Appeal__c> toSave = new List<Liability_Appeal__c>();
            for (Liability_Appeal__c liab : liabs) {
                if (liab.Appeal_Status__c != appStatuses.get(liab.Appeal__c)) {
                    liab.Appeal_Status__c = appStatuses.get(liab.Appeal__c);
                    toSave.add(liab);
                }
            }
            if (toSave.size() > 0) {
                update toSave;
            }
        }
    }
    
    public void SetStatusOnViolations() {
        
        List<Appealed_Violation__c> avs = [SELECT Id, Case_Violation__r.Id, Liability_Appeal__r.Appeal__c, Liability_Appeal__r.Appeal__r.Request_Receipt_Date__c, Case_Violation__r.Citation_Date__c, Case_Violation__r.Appeal_Date__c FROM Appealed_Violation__c WHERE Liability_Appeal__r.Appeal__c IN :Trigger.new];
        
        Map<Id, DIR_Violation__c> violations = new Map<Id, DIR_Violation__c>();
        
        for (Appealed_Violation__c av : avs) {
            
            if (Trigger.isInsert) {
                av.Case_Violation__r.Status__c = 'Under Appeal';
                av.Case_Violation__r.Appeal_Date__c = av.Liability_Appeal__r.Appeal__r.Request_Receipt_Date__c;
                violations.put(av.Case_Violation__r.Id, av.Case_Violation__r);
                av.Case_Violation__r.Payment_Due_Date__c = null;
            }
            if (Trigger.isUpdate) {
                if (((Appeal__c)Trigger.oldMap.get(av.Liability_Appeal__r.Appeal__c)).Status__c != 'Withdrawn' && ((Appeal__c)Trigger.newMap.get(av.Liability_Appeal__r.Appeal__c)).Status__c == 'Withdrawn') {
                    av.Case_Violation__r.Status__c = 'Appeal Withdrawn';
                    av.Case_Violation__r.Payment_Due_Date__c = av.Case_Violation__r.Citation_date__c;
                    violations.put(av.Case_Violation__r.Id, av.Case_Violation__r);
                }
                if(av.Case_Violation__r.Appeal_Date__c == null){
                    av.Case_Violation__r.Appeal_Date__c = av.Liability_Appeal__r.Appeal__r.Request_Receipt_Date__c == null ? null : av.Liability_Appeal__r.Appeal__r.Request_Receipt_Date__c;
                    violations.put(av.Case_Violation__r.Id, av.Case_Violation__r);
                }
            }
            
        }
        
        update violations.values();
        
    }
}