public with sharing class CreateODAController {
    
    public List<SelectOption> caseRoleList {get;set;}
    public List<violationWrapper> violations {get;set;}
    public String selectedRole {get;set;}
    public ODAS__c oda {get;set;}
    
    private Hearing__c h;
    private Meeting_Participant__c mp;
    private String meetingId;
    
    private map<String, Meeting_Participant__c> mpMap = new map<String, Meeting_Participant__c>();
    private map<String, Case_Role__c> crMap;
    private map<String, Liability__c> liabMap;
    private map<String, DIR_Violation__c> violMap;
    private map<String, List<violationWrapper>> queryMap = new map<String, List<violationWrapper>>();
    private map<String, List<Liable_Party__c>> liabPartyMap = new map<String, List<Liable_Party__c>>();
    private map<String, List<Liability__c>> jointLiabMap = new map<String, List<Liability__c>>();
    private map<String, List<Liability__c>> singleLiabMap = new map<String, List<Liability__c>>();
    
    @testVisible private ODAS__c newODA;
    
    public CreateODAController(ApexPages.StandardController controller){
        meetingId = controller.getRecord().Id;
        oda = new ODAS__c();
        h = [
             SELECT Id, Name, Case__c, Case__r.Name, Case__r.Employer__c,
                 (SELECT Id, Name, Case__c, Case__r.Name, Case__r.Employer__c, Case__r.Employer__r.Name, Meeting__c, Case_Role__c, Case_Role__r.Name, Case_Role__r.Role__c, Case_Role__r.Entity__r.Name FROM Meeting_Participants__r)
             FROM Hearing__c
             WHERE Id =: meetingId LIMIT 1
            ];
            
        if(h.Meeting_Participants__r.isEmpty()){
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'There are no Meeting Participants related to this Meeting'));
            return;
        }
        List<Id> crIdList = new List<Id>();
        for(Meeting_Participant__c m : h.Meeting_Participants__r){
            mpMap.put(m.Case_Role__c, m);
            crIdList.add(m.Case_Role__c);
        }
        
        crMap = new map<String, Case_Role__c>([
                                               SELECT Id, Name, Role__c, Entity__r.Name,
                                                (SELECT Id, Name, Liability__c, Case_Role__c, Liability__r.Assessment__c, Liability__r.Joint_Liability__c FROM Liable_Parties__r),
                                                (SELECT Id, Name, Case_Role__c FROM Meeting_participants__r)
                                               FROM Case_Role__c
                                               WHERE Id IN: crIdList
                                              ]);
                                              
        List<Id> assessIdList = new List<Id>();
        set<Id> liabIdSet = new set<Id>();
        for(Case_Role__c cr : crMap.values()){
            for(Liable_Party__c lp : cr.Liable_Parties__r){
                assessIdList.add(lp.Liability__r.Assessment__c);
                liabIdSet.add(lp.Liability__c);
            }
        }
        
        liabMap = new map<String, Liability__c>([
                                                 SELECT Id, Name, Assessment__c, Joint_Liability__c,
                                                    (SELECT Id, Name, Case_Role__c, Liability__c, ODA__c, Basis_for_Liability__c FROM Liable_Parties__r)
                                                 FROM Liability__c
                                                 WHERE Id IN: liabIdSet     
                                                ]);
        system.debug(
                     '\n**********Liabilities**********\n'
                         +String.valueOf(liabMap.keySet()).replace(',','\n')
                     +'\n*******************************'
                    );          
        
        if (liabMap.size() == 0){
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'None of the Meeting Participants in this meeting is a liable party on any liablity on this case.'));            
            return;
        }
        
        for(Liability__c l : liabMap.values()){
            List<Liable_Party__c> tempList = new List<Liable_Party__c>();
            for(Liable_Party__c lp : l.Liable_Parties__r){
                tempList.add(lp);
            }
            liabPartyMap.put(l.Id, tempList);
        }                                                    
        
        violMap = new map<String, DIR_Violation__c>([
                                                     SELECT Id, Name, Violation_Type__c, Violation_Short_Description_Conga__c, Status__c, 
                                                            Wages_Due__c, Wage_Balance_Due__c, Interest_Balance_Due__c, Assessment__c, Wages_Due_Date__c,
                                                            Violation_Type__r.Name, Decided_at_Meeting__c
                                                     FROM DIR_Violation__c
                                                     WHERE Assessment__c IN: assessIdList
                                                     AND Status__c = 'Open'
//above line inserted to only Case Issues with "Open" status on the Create ODA page (per SR-005623)
                                                    ]);
        caseRoleList = new List<SelectOption>();                                            
        for(Liability__c l : liabMap.values()){
            String idStr = '';
            String nameStr = '';
            List<Liable_Party__c> lpList = liabPartyMap.get(l.Id);
            List<Id> idSort = new List<Id>();
            for(Liable_Party__c lp : lpList){
                Case_Role__c cr = crMap.get(lp.Case_Role__c);
                boolean proceed = false;
                if(cr == null){
                    continue;
                }
                if(l.Joint_Liability__c == true){
                    if(lp.Basis_for_Liability__c != null && ('Employer Liability, Joint Employer, Joint Liability').contains(lp.Basis_for_Liability__c)){
                        idSort.add(cr.Id);
                        nameStr += cr.Entity__r.Name+', ';
                    }
                    else{
                        proceed = true;
                    }
                }
                else{
                    proceed = true;
                }
                if(proceed){
                    String valStr = cr.Id+'::'+l.Id;
                    List<Liability__c> liabs = new List<Liability__c>();
                    if(singleLiabMap.containsKey(cr.Id)){
                        liabs.addAll(singleLiabMap.get(cr.Id));
                        liabs.add(l);
                        singleLiabMap.put(cr.Id, liabs);
                    }
                    else{
                        liabs.add(l);
                        singleLiabMap.put(cr.Id, liabs);
                        caseRoleList.add(New SelectOption(valStr, cr.Entity__r.Name+' - '+cr.Role__c));
                    }
                }
            }
            system.debug('********************COUNT: '+singleLiabMap.keySet().size());
            for(String s : singleLiabMap.keySet()){
                system.debug('********************singleLiabMap: '+s);
            }
            if(l.Joint_Liability__c == true){
                idSort.sort();
                String idSortStr = '';
                for(String i : idSort){
                    idSortStr += i+'::';
                }
                idSortStr = idSortStr.subString(0, idSortStr.length() - 2);
                List<Liability__c> liabs = new List<Liability__c>();
                if(jointLiabMap.containsKey(idSortStr)){
                    liabs.addAll(jointLiabMap.get(idSortStr));
                    liabs.add(l);
                    jointLiabMap.put(idSortStr, liabs);
                }
                else{
                    liabs.add(l);
                    jointLiabMap.put(idSortStr, liabs);
                    nameStr = nameStr.subString(0, nameStr.length() - 2);
                    caseRoleList.add(New SelectOption(idSortStr, nameStr+' - Jointly Liable'));
                }
            }
        }
        
        selectedRole = caseRoleList[0].getValue();
        getCaseViolations();                                        
    }
    
    public void getCaseViolations(){
        
        if(selectedRole == null || selectedRole == ''){
            return;
        }
        
        if(queryMap.containsKey(selectedRole)){
            violations = queryMap.get(selectedRole);
            return;
        }
        
        List<DIR_Violation__c> tempList = new List<DIR_Violation__c>();
        set<String> assessmentIds = new set<String>();
        
        if(jointLiabMap.containsKey(selectedRole)){
            for(Liability__c l : jointLiabMap.get(selectedRole)){
                assessmentIds.add(l.Assessment__c);
            }
        }
        else{
            List<String> idParts = selectedRole.split('::');
            List<Liability__c> liabList = singleLiabMap.get(idParts[0]);
            for(Liability__c l : liabList){
                assessmentIds.add(l.Assessment__c);
            }
        }
        
        for(DIR_Violation__c v : violMap.values()){
            if(assessmentIds.contains(v.Assessment__c)){
                tempList.add(v);
            }
        }
        
        List<violationWrapper> tempWrapper = new List<violationWrapper>();
        for(DIR_Violation__c v : tempList){
            tempWrapper.add(New violationWrapper(v));
        }
        
        queryMap.put(selectedRole, tempWrapper);
        
        violations = tempWrapper;
        
    }
    
    public pageReference createODA(){
        
        boolean isError = false;
        
        if(selectedRole == null || selectedRole == ''){
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'Please select a Case Role in order to proceed'));
            isError = true;
        }
        
        if(oda.Decision_Date__c == null){
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'Please select a Decision Date in order to proceed'));
            isError = true;
        }
        
        if(isError){
            return null;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        String errorStr = '';
        
        try{
            oda.Case_Management__c = h.Case__c; //same as meeting
            oda.Meeting__c = h.Id;
            
            List<DIR_Violation__c> updateViols = new List<DIR_Violation__c>();
            
            for(violationWrapper v : violations){
                v.thisViol.Decided_at_Meeting__c = h.Id;
                updateViols.add(v.thisViol);
            }
            
            List<Liable_Party__c> updateParties = new List<Liable_Party__c>();
            
            List<String> strParts = selectedRole.split('::');
            if(jointLiabMap.containsKey(selectedRole)){
                oda.Joint_Liability__c = true;
                for(Liability__c l : jointLiabMap.get(selectedRole)){
                    for(Liable_Party__c lp : l.Liable_Parties__r){
                        if(lp.ODA__c == null && lp.Basis_for_Liability__c != null && ('Employer Liability, Joint Employer, Joint Liability').contains(lp.Basis_for_Liability__c)){
                            updateParties.add(lp);
                        }
                        else if(lp.ODA__c != null && lp.Basis_for_Liability__c != null && ('Employer Liability, Joint Employer, Joint Liability').contains(lp.Basis_for_Liability__c)){
                            errorStr += lp.Name+', ';
                        }
                    }
                }
            }
            else if(singleLiabMap.containsKey(strParts[0])){
                for(Liability__c l : singleLiabMap.get(strParts[0])){
                    for(Liable_Party__c lp : l.Liable_Parties__r){
                        if(lp.Case_Role__c == strParts[0] && lp.ODA__c == null/* && lp.Basis_for_Liability__c != null && !('Employer Liability, Joint Employer, Joint Liability').contains(lp.Basis_for_Liability__c)*/){
                            updateParties.add(lp);
                        }
                        else if(lp.Case_Role__c == strParts[0] && lp.ODA__c != null/* && lp.Basis_for_Liability__c != null && !('Employer Liability, Joint Employer, Joint Liability').contains(lp.Basis_for_Liability__c)*/){
                            errorStr += lp.Name+', ';
                        }
                    }
                }
            }
            
            //moved update viols from this point to belose party and hearing update.
            
            if(!updateParties.isEmpty()){
                insert oda;
                newODA = oda;

                h.Effective_Date__c = oda.Decision_Date__c;
                update h;

                for(Liable_Party__c lp : updateParties){
                    lp.ODA__c = oda.Id;
                }
                update updateParties;
                
                if(errorStr.trim() != ''){
                    errorStr = errorStr.subString(0, errorStr.length() - 2);
                    ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.CONFIRM, 'ODA created successfully. However, the following Liable Parties were already had an ODA associated and, therefore, were not updates: '+errorStr));
                    return null;
                }
            }
            else{
                ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.Error, 'All Liable Parties related to the selected Case Role already have an associated ODA record.'));
                return null;
            }

            if(!updateViols.isEmpty()){
                update updateViols;
            }
        }
        catch(exception e){
            database.rollback(sp);
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, e.getMessage()));
            return null;
        }
        
        return new pageReference('/'+h.Id);
    }
    
    public class violationWrapper{
        
        public date currentDate {get;set;}
        public DIR_Violation__c thisViol {get;set;}
        
        public violationWrapper(DIR_Violation__c v){
            thisViol = v;
            currentDate = v.Wages_Due_Date__c;
        }
    }
    
}