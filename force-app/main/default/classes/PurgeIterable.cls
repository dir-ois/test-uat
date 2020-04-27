public with sharing class PurgeIterable implements Iterable<SObject> {
    public Iterator<SObject> iterator() {
        List<SObject> sobjects = new List<SObject>();
        Map<String, List<String>> recordTypesByObject = new Map<String, List<String>>();
        Map<String, List<String>> statusesByObject = new Map<String, List<String>>();
        Map<String, Decimal> daysByObject = new Map<String, Decimal>();

        for (Purge_Settings__mdt setting : [
                SELECT Object__r.QualifiedApiName,
                        Record_Type__c,
                        Status__c,
                        Age_of_Records_to_Purge__c
                FROM Purge_Settings__mdt
        ]) {
            String objectApiName = setting.Object__r.QualifiedApiName;
            recordTypesByObject.put(objectApiName, setting.Record_Type__c.replaceAll( '\\s+', '').split(','));
            statusesByObject.put(objectApiName, setting.Status__c.split(','));
            daysByObject.put(objectApiName, Integer.valueOf(Math.round(setting.Age_of_Records_to_Purge__c)));
            List<SObject> records;
            List<String> recordTypes = recordTypesByObject.get(objectApiName);
            List<String> statuses = statusesByObject.get(objectApiName);
            String query;

            query = 'SELECT Id FROM ' + objectApiName + ' ';
            query += 'WHERE RecordType.DeveloperName IN :recordTypes' + ' ';
            query += 'AND Status__c IN :statuses' + ' ';
            query += 'AND LastModifiedDate < LAST_N_DAYS:' + daysByObject.get(objectApiName);

            records = Database.query(query);
            sobjects.addAll(records);
        }

        return sobjects.iterator();
    }
}