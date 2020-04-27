trigger CaseViolationAll on DIR_Violation__c (before insert, before update, after insert, after update, after delete) {

    caseViolationRollupAmountsAction.runHandler();
    caseViolationCalculateInterestAction.runHandler();

    if (Trigger.isInsert) {
        
        if(Trigger.isBefore) {
            // Process Before Inert
            PreventAppealSelector();
        }else if(Trigger.isAfter){
            
            SetAppealDeadline();
            // PT-000045:Consolidate Multiple Triggers Per Object
            CaseViolationAccountCodeAction.runHandler();
            if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
            }
        }
    }
    
    else if (Trigger.isUpdate) {
        
        if(Trigger.isAfter) {
            //GenerateFieldHistory.checkHistoryConfig(Trigger.new, Trigger.oldMap);
            
            // PT-000045:Consolidate Multiple Triggers Per Object
            CaseViolationAccountCodeAction.runHandler();
            if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();   
            }
        }
    }
    
    else if (Trigger.isDelete){
        if(Trigger.isAfter){
            // PT-000045:Consolidate Multiple Triggers Per Object
            CaseViolationAccountCodeAction.runHandler();
            if(!Test.isRunningTest()){
            GenerateFieldHistoryAction.runHandler();
            }
            
        }
    }

    
    public void PreventAppealSelector() {

        Set<Id> assessIds = new Set<Id>();
        Set<Id> vtIds = new Set<Id>();
        for (DIR_Violation__c viol : Trigger.new) {
            if (viol.Assessment__c != null) {
                assessIds.add(viol.Assessment__c);
            }
            if (viol.Violation_Type__c != null) {
                vtIds.add(viol.Violation_Type__c);
            }
        }
        
        Map<Id, Violation_Type__c> vtMap = new Map<Id, Violation_Type__c>([SELECT Id, Appeal_Deadline_Selector__c FROM Violation_Type__c WHERE Id IN :vtIds]);
        
        List<DIR_Violation__c> violationsList = [SELECT Id, Assessment__c, Violation_Type__r.Appeal_Deadline_Selector__c FROM DIR_Violation__c WHERE Violation_Type__r.RecordType.Name = 'BOFE Violations' AND Assessment__c IN :assessIds];
        
        for (DIR_Violation__c viol : Trigger.new) {
            if (viol.Assessment__c != null && viol.Violation_Type__c != null && vtMap.containsKey(viol.Violation_Type__c)) {
                for (DIR_Violation__c existingViol : violationsList) {
                    if (viol.Assessment__c == existingViol.Assessment__c) {
                        if (viol.Violation_Type__r.Appeal_Deadline_Selector__c != null && viol.Violation_Type__r.Appeal_Deadline_Selector__c != '' && 
                                vtMap.get(viol.Violation_Type__c).Appeal_Deadline_Selector__c != null && vtMap.get(viol.Violation_Type__c).Appeal_Deadline_Selector__c != '' &&
                                vtMap.get(viol.Violation_Type__c).Appeal_Deadline_Selector__c != viol.Violation_Type__r.Appeal_Deadline_Selector__c) {
                            viol.addError('The appeal deadline configuration for the selected violations are in conflict. Please contact your system administrator to correct this error and verify that the appeal deadline is correct on the assessment');
                        }
                    }
                }
            }
        }
    }
    
    public void SetAppealDeadline() {
        System.debug('****  setting appeal deadline based on insert of violation');
        Set<Id> assessIds = new Set<Id>();
        for (DIR_Violation__c viol : Trigger.new) {
            if (viol.Assessment__c != null) {
                assessIds.add(viol.Assessment__c);
            }
        }
        System.debug('****  assessIds::: ' + assessIds);

        List<Assessments__c> assessments = [SELECT Id, Appeal_Deadline_Days__c, Appeal_Deadline_Selector__c FROM Assessments__c WHERE Id IN :assessIds];
        Set<Assessments__c> assessmentsToUpdate = new Set<Assessments__c>();
        
        List<DIR_Violation__c> violationsList = [SELECT Id, Assessment__c, Appeal_Deadline_Days__c, Violation_Type__r.Appeal_Deadline_Selector__c FROM DIR_Violation__c WHERE Violation_Type__r.RecordType.Name = 'BOFE Violations' AND Assessment__c IN :assessIds];
        System.debug('****  violationsList::: ' + violationsList);

        for (Assessments__c assess : assessments) {
            decimal maxDays = 0;
            string selSelector = null;
            for (DIR_Violation__c violation : violationsList) {
                if (violation.Assessment__c == assess.Id) {
                    if (violation.Appeal_Deadline_Days__c != null && violation.Appeal_Deadline_Days__c > maxDays) {
                        maxDays = violation.Appeal_Deadline_Days__c;
                        System.debug('****  maxDays:' + maxDays);
                    }
                    if (violation.Violation_Type__r.Appeal_Deadline_Selector__c != null && violation.Violation_Type__r.Appeal_Deadline_Selector__c != '') {
                        selSelector = violation.Violation_Type__r.Appeal_Deadline_Selector__c;
                        System.debug('****  Appeal_Deadline_Selector__c:: ' + selSelector);
                    }
                }
            }

            boolean updated = false;            
            if (maxDays != 0 && maxDays != assess.Appeal_Deadline_Days__c) {
                assess.Appeal_Deadline_Days__c = maxDays;
                updated = true;
                System.debug('****  Updating Appeal_Deadline_Days__c on Assessment: ' + assess.Id + ' to ' + maxDays);
            }
            if (selSelector != null && selSelector != assess.Appeal_Deadline_Selector__c) {
                assess.Appeal_Deadline_Selector__c = selSelector;
                updated = true;
                System.debug('****  Updating Appeal_Deadline_Selector__c to ' + selSelector);
            }
            if (updated) {
                assessmentsToUpdate.add(assess);
            }
            
        }
        
        update new List<Assessments__c>(assessmentsToUpdate);
        
    }

}