public class liabilityMethods {
	// all methods related to liailities
	
    // Get BOFE liabilities and make BOFE calls
    public static void beforeInsert(list<liability__c> newList){

        // make method calls related to Bofe
        setAppealDeadline(getBOFELiabilities(newList));
    }
    
    public static void beforeUpdate(list<Liability__c> newList, map<ID, Liability__c> oldMap){
        setAppealDeadline(getBOFELiabilities(newList));
    }
    
    //Trigger Methods
    
    // Sets the appeal deadline on the liability
    public static void setAppealDeadline(list<Liability__c> liaList){
        system.debug('Setting appeal deadline');
        
        set<ID> assID = new set<ID>();
        list<Liability__c> liabilitiesList = new list<Liability__c>();
        for(Liability__c l : liaList ){
            if(l.Assessment__c != null && (l.Imported_From__c == null || l.Imported_From__c != '') && l.Appeal_Deadline__c == Null ){
                assID.add(l.Assessment__c);
                liabilitiesList.add(l);
            }
        }
        // get violations on assessments from the appealed liabilities
        list<DIR_violation__c> violList = new list<DIR_Violation__c>([SELECT ID, Citation_Date__c, Appeal_Deadline_Date__c from DIR_Violation__c where Assessment__c in :assID]) ;
        
        // Get appeal deadline days and selector from parent assessment
        map<ID, Assessments__c> assMap = new Map<ID, Assessments__c> ([SELECT ID, Appeal_Deadline_Days__c, Appeal_Deadline_Selector__c FROM Assessments__c Where ID in :assID]);
        
        // get max of citation dates from violations on appeal
        
        date citDate = date.newInstance(1900, 1, 7);
        for(DIR_Violation__c v : violList){
            if(v.Citation_Date__c > citDate)
                citDate = v.Citation_Date__c;
        }

        decimal Appeal_Deadline;
        string Appeal_Selector;
        for(Liability__c lia : liabilitiesList){
            Appeal_Deadline = assMap.get(lia.Assessment__c).Appeal_Deadline_Days__c;
            if (Appeal_Deadline == null)
            	Appeal_Deadline = 0;
            Appeal_selector = assMap.get(lia.Assessment__c).Appeal_Deadline_Selector__c;
            date startDate = date.newInstance(1900, 1, 7);
            system.debug('deadline days:: ' + Appeal_Deadline + ' & Selector:: ' + Appeal_Selector);
            
            if(Appeal_Selector == 'Calendar Days'){
                // add calendar days
                date deadline;
                    if (lia.Manual_Citation_Date__c == null) {
                    deadline = citDate + Appeal_Deadline.intValue();
                    }
                else {
                    deadline = lia.Manual_Citation_Date__c + Appeal_Deadline.intValue();
                }
                // if final day is a weekend, go to next weekday
                while(math.mod(startDate.daysBetween(deadline), 7) == 0 || math.mod(startDate.daysBetween(deadline), 7) == 6){
                    deadline = deadline.addDays(1);
                }
                lia.Appeal_Deadline__c = deadline;
                system.debug('Set appeal deadline to Today + Appeal deadline');
                for(DIR_Violation__c vio : violList){
                    if(vio.Appeal_Deadline_Date__c == Null)
                    vio.Appeal_Deadline_Date__c = deadline;
                }
            }
            else if (Appeal_Selector == 'Business Days'){
                // add weekedays
                Integer i = Appeal_Deadline.intValue();
                system.debug('i = ' + i);
                date deadDate;
                    if (lia.Manual_Citation_Date__c == null) {
                        deadDate = citDate;
                    }
                	else {
                    deadDate = lia.Manual_Citation_Date__c;
                	}
    
                while(i > 0){          
                    //iterate through the value of the appeal deadline adding the days until counted down to zero
                    //Start with the next day
                    system.debug('next day');
                    deadDate = deadDate.addDays(1);
                    system.debug('deadDate = ' + deadDate);
                    system.debug('days mod: ' + math.mod(startDate.daysBetween(deadDate), 7));
                    
                    if((math.mod(startDate.daysBetween(deadDate), 7) != 0 ) && (math.mod(startDate.daysBetween(deadDate), 7) != 6 )){
                        i--;
                        system.debug('weekday day, decrement i. i= ' + i);
                    }
                    else
                        system.debug('WEEKEND DAY');
  
                }
                // update deadline to be the final deadDate
                lia.Appeal_Deadline__c = deadDate;
                for(DIR_Violation__c vio : violList){
                    if(vio.Appeal_Deadline_Date__c == Null)
                    vio.Appeal_Deadline_Date__c = deadDate;
                }
            }
            else{
                if(lia.Imported_From__c == null || lia.Imported_From__c == ''){
                    //throw error
                    lia.addError('No appeal selection has been selected. Please modify the Assessment and set the Appeal Deadline Selector. You should also contact your system administrator to ensure all violations on this liability are setup correctly.');
                }
            }
            
        }
        update violList;
        
    } // End setAppealDeadline
    
    //Private methods
    
    // Get BOFE liabilities
    private static list<Liability__c> getBOFELiabilities(list<Liability__c> tLiabilities) {
        list<Liability__c> bofeLiabilities = new list<Liability__c>();
        Id BOFERecType = Schema.SObjectType.liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        for (Liability__c bofe : tLiabilities){
            if(bofe.RecordTypeId == BOFERecType)
                bofeLiabilities.add(bofe);
            	system.debug('Record added to bofeLiabilities:::: ' + bofe.Id);
        }
        return bofeLiabilities;
    }
}