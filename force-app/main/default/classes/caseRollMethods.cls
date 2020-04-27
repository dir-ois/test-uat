public class caseRollMethods {
// methods for triggers on case role


//on insert  - before  trigger.
    //set the location on the case role to be the primary location of the account
    public static void applyLocation(list<Case_Role__c> newList){
        system.debug('Setting location on case role');
        //get the accounts on each case role
        set<ID> acctIDs = new set<ID>();
        for (Case_Role__c cr : newList){
            acctIDs.add(cr.Entity__c);
            system.debug('Added entity: ' + cr.Entity__c + ' to account set');
        }
     
        list<Address__c> locList = new list<Address__c>([SELECT ID, Entity__c from Address__c Where Active_Location__c = true AND Type__c = 'Primary' AND Entity__c in :acctIDs]);
        system.debug('locList::: ' + locList);
        
        Map<ID, Address__c> locMap = new Map<ID, Address__c>();
        for(Address__c a : locList){
            locMap.put(a.Entity__c, a);
        }
        
      
        if(locMap.size() > 0){
            for (Case_Role__c cr : newList){
                if (locMap.containsKey(cr.Entity__c)){
                    Address__c addr = locMap.get(cr.Entity__c);
                    system.debug('Address to add as location:::' + addr);
                    cr.location__c = addr.id;
                }
                
            }
      
        } 
  
      
  }
        public static void countDefs(list<Case_Role__c> newList){
            String[] crType = new String[]{'Defendant','Case Employer'};
            set<ID> CaseIDs = new set<ID>();
            for(Case_Role__c cr: newList ){
                    CaseIDs.add(cr.Case__c); 
            }
            list<Case_Role__c> defCRs = new list<Case_Role__c>([SELECT ID, Role__c, Case__c FROM Case_Role__c WHERE Case_Role_Status__c != 'No Longer Active On Case' AND Case__c IN :CaseIDs AND Role__c IN :crType]);
//            system.debug('Number of defendant case roles found is:: ' + defCRs.size() + ' on case :: ' + CaseIDs + ' list of case roles is :: ' + defCRs );
			list<DIR_Case__c> cases = new list<DIR_Case__c>([SELECT ID, Number_of_Employer_s__c FROM DIR_Case__c Where ID IN :CaseIDs ]);
            for(DIR_Case__c defCase : cases){
                defCase.Number_of_Employer_s__c = defCRs.size();
                update defCase;
            }
         }


    
}