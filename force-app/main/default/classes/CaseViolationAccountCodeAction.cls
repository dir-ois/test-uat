public class CaseViolationAccountCodeAction extends TriggerAction {
 
   
    public boolean shouldRun;
    private Map<ID,Set<ID>> violationToAccountCodes;
    public CaseViolationAccountCodeAction(List<DIR_Violation__c> triggerList) {
        
        super(triggerList);
        
        Set<Id> caseIds = new Set<Id>();
    
        violationToAccountCodes = new Map<ID,Set<ID>>();
        Map<ID,ID> violationToViolationType =  new Map<ID,ID>();
        Set<ID> violationIDs = new Set<ID>();
        for (Sobject result: triggerList) {
            
            DIR_Violation__c violation= (DIR_Violation__c)result;
            
            if (violation.Violation_Type__c!=null) {
                violationIDs.add(violation.Violation_Type__c);
                violationToViolationType.put(violation.id,violation.Violation_Type__c);
            }
            
            if (violation.Case__c != null) {
                caseIds.add(violation.Case__c);
            }
        }
        
        Map<Id, DIR_Case__c> casesMap = new Map<Id, DIR_Case__c>([SELECT Id, Employer_Industry__c, DIR_Accounting_Program__c FROM DIR_Case__c WHERE Id IN :caseIds]);
        //get violationTypes 
        
        List<Applicable_Accounting_Code__c> acctCodes = [select id, Accounting_Code__c, Violation_Type__c, Active__c, Industry__c, Program__c from Applicable_Accounting_Code__c where Violation_Type__c in : violationIDs AND Active__c = true];
        Map<ID,List<Applicable_Accounting_Code__c>> violationTypeToAccountCodes = new Map<ID,List<Applicable_Accounting_Code__c>>();
        //map violationTypes to appropriate accountcodes
        for (Applicable_Accounting_Code__c code : acctCodes) {
            List<Applicable_Accounting_Code__c> codeIDs  =  (violationTypeToAccountCodes.containsKey(code.Violation_Type__c))? violationTypeToAccountCodes.get(code.Violation_Type__c): new List<Applicable_Accounting_Code__c>();
            codeIDs.add(code);
            
            //codeIDs.add(code.Accounting_Code__c);
            violationTypeToAccountCodes.put(code.Violation_Type__c,codeIDs);
        }
        //map violations to accountcodes
        violationToAccountCodes = new Map<ID,Set<ID>>();
        for (Sobject result: triggerList) {
            
            DIR_Violation__c violation= (DIR_Violation__c)result;
        
            if (violation.Violation_Type__c!=null) {
                violationToAccountCodes.put(violation.ID, new Set<Id>());
                if (violationTypeToAccountCodes.containsKey(violation.Violation_Type__c)) {
                    for (Applicable_Accounting_Code__c code : violationTypeToAccountCodes.get(violation.Violation_Type__c)) {
                        if (code.Industry__c == casesMap.get(violation.Case__c).Employer_Industry__c && code.Program__c == casesMap.get(violation.Case__c).DIR_Accounting_Program__c) {
                            violationToAccountCodes.get(violation.ID).add(code.Id);
                        }
                    }
                }
                
            }
        
        }
    }
    public override boolean shouldRunOnInsert() { 
    
        
        shouldRun = ( violationToAccountCodes.keyset().size()>0)? true: false;
        
        return shouldRun;
    } 
    public override boolean shouldRunOnDelete() { return false;} 
    
 
    public override boolean shouldRunOnUpdate() {  return false; } 
    
 
    public override void doAction() {
        
        List<Violation_Accounting_Code__c> vacList = new List<Violation_Accounting_Code__c>();
        
        for (ID vid : violationToAccountCodes.keySet()) {
            if (violationToAccountCodes.get(vid) != null) {
                for ( ID accId :violationToAccountCodes.get(vid)){
                    Violation_Accounting_Code__c vac = new Violation_Accounting_Code__c();
                    vac.Applicable_Accounting_Code__c = accId;
                    vac.Case_Violation__c = vid;
                    vacList.add(vac);
                }
            }
        }
        insert vacList;
        
     
    } 
    public static void runHandler() {
    
        if (trigger.isbefore) {
            return;
        }   
        
        if (trigger.isInsert) {
            CaseViolationAccountCodeAction action = new CaseViolationAccountCodeAction(Trigger.new);
            if (action.shouldRunOnInsert()) {
                action.doAction(); 
            }
            
        }   
      

    } 
    
}