trigger AppealedViolationAll on Appealed_Violation__c (after insert) {

    if (Trigger.IsAfter && Trigger.isInsert) {
        SetStatusOnViolation();
    }

    void SetStatusOnViolation() {
    
        List<Appealed_Violation__c> avs = [SELECT Id, Case_Violation__r.Id, Liability_Appeal__r.Appeal__c, Liability_Appeal__r.Appeal__r.Request_Receipt_Date__c FROM Appealed_Violation__c WHERE Id IN :Trigger.new AND Liability_Appeal__r.Appeal__r.Status__c = 'Received - Timely'];
    
        Map<Id, DIR_Violation__c> violations = new Map<Id, DIR_Violation__c>();
        
        for (Appealed_Violation__c av : avs) {
            
            av.Case_Violation__r.Status__c = 'Under Appeal';
            av.Case_Violation__r.Appeal_Date__c = av.Liability_Appeal__r.Appeal__r.Request_Receipt_Date__c;
            violations.put(av.Case_Violation__r.Id, av.Case_Violation__r);
            
        }
        
        update violations.values();
    }
        
}