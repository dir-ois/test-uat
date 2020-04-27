public class ListCaseRoleDefendantsController {
    
    public String caseId {
        get;
        set{
            caseId = value;
        }
    }
    private DIR_Case__c thisCase;
    
    public ListCaseRoleDefendantsController(){}
    
    public List<Case_Role__c> crList {
        get{
            thisCase = [SELECT Id, Name, (SELECT Id, Name, Account_Name__c, Role__c FROM Case_Roles__r) FROM DIR_Case__c WHERE Id =: caseId];
            crList = new List<Case_Role__C>();
            for(Case_Role__c cr : thisCase.Case_Roles__r){
                if(cr.Role__c != null && cr.Role__c.contains('Defendant')){
                    crList.add(cr);
                }
            }
            return crList;
        }
        set;
    }

}