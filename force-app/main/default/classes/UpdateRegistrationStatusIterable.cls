public with sharing class UpdateRegistrationStatusIterable implements Iterable<SObject> {
    public Iterator<SObject> iterator() {
        List<License_Registration__c> sobjects = new List<License_Registration__c>();
        List<License_Registration__c> records = new List<License_Registration__c>();
        
        String query = 'SELECT id '
            + ' FROM License_Registration__c'
            + ' WHERE Status__c IN (\'Approved\', \'Active\')'
            + ' AND Expiration_Date__c != NULL'
            + ' AND Expiration_Date__c < TODAY '
            + ' AND Applicant__r.id != NULL'
            + ' AND Account__r.id != NULL';
        
        records = Database.query(query);
        if (!records.isEmpty()) {
            for(License_Registration__c rec : records){
                rec.Status__c = 'Expired';
            }            
        }
        
        sobjects.addAll(records);
        
        return sobjects.iterator();
    }
}