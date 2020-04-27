public with sharing class HearingResults {

    public Hearing__c hearing { get; set; }
    
    public List<HearingLiability> liabilities { get; set; }
    
    public HearingResults(ApexPages.StandardController sc) {
        hearing = [SELECT Id, Name, Failure_to_Appear__c, Appeal__r.Case__r.Case_Number__c, Appeal__r.Name, Hearing_Date__c, Appeal__r.Estimated_Length_of_Hearing_In_Minutes__c, Appeal__r.Case__r.Assigned_Deputy__r.Name, Appeal__r.Case__r.Assigned_Deputy__r.Manager__r.Name, Effective_date__c, Length_Of_Hearing__c, Minutes_to_Write_Findings__c FROM Hearing__c WHERE Id = :sc.getId()];
        
        liabilities = new List<HearingLiability>();
        Set<Id> assessIds = new Set<Id>();
        List<Hearing_Liability__c> liabs = [SELECT Id, Liability_Appeal__r.Liability__r.Assessment__c, Liability_Appeal__r.Liability__r.Citation_Number__c, Results__c, Hearing_Notes__c, Liability_Appeal__r.Liability__c FROM Hearing_Liability__c WHERE Hearing__c = :hearing.Id];
        for (Hearing_Liability__c liab : liabs) {
            liabilities.add(new HearingLiability(liab));
            if (liab.Liability_Appeal__r.Liability__r.Assessment__c != null){
                assessIds.add(liab.Liability_Appeal__r.Liability__r.Assessment__c);
            }
        }
        
        // S. Thornton 2/4/2016 Added Status__c to the SELECT statement.
        List<DIR_Violation__c> allViols = [SELECT Id, Name, Assessment__c, Violation_Type__r.Name, Civil_Penalty_Section_Conga__c, Status__c, Original_Penalty_Assessment_Amount__c, Citation_Amount__c, Original_Wage_Assessment_Amount__c, Wages_Due__c, Appeal_Finding_Date__c FROM DIR_Violation__c WHERE Assessment__c IN :assessIds];
        for (DIR_Violation__c viol : allViols) {
            for (HearingLiability hl : liabilities) {
                if (hl.liability.Liability_Appeal__r.Liability__r.Assessment__c == viol.Assessment__c) {
                    hl.violations.add(viol);
                }
            }
        }
    }
    
    public PageReference SaveHearing() {
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            hearing.Status__c = 'Complete';
            update hearing;
            List<Liability__c> liabList = new List<Liability__c>();
            List<Hearing_Liability__c> liabs = new List<Hearing_Liability__c>();
            List<DIR_Violation__c> viols = new List<DIR_Violation__c>();
            Map<Id, String> resultsMap = new Map<Id, String>();
            for (HearingLiability hl : liabilities) {
                liabs.add(hl.liability);
                hl.liab.Status__c = hl.liability.Results__c;
                liabList.add(hl.liab);
                for (DIR_Violation__c viol : hl.violations) {
                    /*
                    if (hl.liability.Results__c == 'Affirmed')
                        viol.Status__c = 'Affirmed';
                    if (hl.liability.Results__c == 'Modified')
                        viol.Status__c = 'Modified';
                    */
                    // S. Thornton 2/4/2016 Commented out the following line to allow the user selected case violations status to be saved.
                    /* viol.Status__c = hl.liability.Results__c; */
                    viol.Appeal_Finding_Date__c = hearing.Effective_Date__c;
                    if(!resultsMap.containsKey(viol.Id)){
                        resultsMap.put(viol.Id, viol.Status__c);
                        viols.add(viol);
                    }
                    else if(resultsMap.containsKey(viol.Id)){
                        String result = resultsMap.get(viol.Id);
                        if(viol.Status__c != result){
                            List<String> tempList = new List<String>();
                            for(HearingLiability h : liabilities){
                                if(h.liability.Liability_Appeal__r.Liability__r.Assessment__c == viol.Assessment__c){
                                    tempList.add(h.liability.Liability_Appeal__r.Liability__r.Citation_Number__c);
                                }
                            }
                            String errorString = 'You are attempting to update Case Violation: ' + viol.Name + ' from Citations: ';
//Next 2 lines below appended to line above. 5/31/19
/*                          errorString += viol.Name;
                            errorString += ' from Citations: '; */
                            for(String s : tempList){
                                errorString += (s+', ');
                            }
                            errorString = errorString.subString(0, errorString.length() - 2);
                            errorString += ' with different Hearing Results. Please ensure that the violation is set to the same Result.';
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, errorString));
                            return null;
                        }
                        else{
                            continue;
                        }
                    }
                }
            }
            update liabs;
            update viols;
            update liabList;
            
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference('/' + hearing.Id);
        
    }
    
    public class HearingLiability {
        
        public Hearing_Liability__c liability { get; set; }
        public List<DIR_Violation__c> violations { get; set; }
        public Liability__c liab { get; set; }
        
        public HearingLiability(Hearing_Liability__c hl) {
            
            liability = hl;
            violations = new List<DIR_Violation__c>();
            liab = hl.Liability_Appeal__r.Liability__r;         
        }
    }

}