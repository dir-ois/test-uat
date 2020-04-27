/*
 Global Recordtype util class for looking up recordtype ids 
 luke lim 
 written 3/5
*/
global class RecordTypeUtil {
    
    // Holds the master map of all record types in the system
    private static Map<String, Id> allRecordTypes;
    
    // Indicates whether the list has already been retrieved
    private static Boolean isInitialized = false;
    
    // This method can be called from anywhere, and will return the record type id
    // matching the "recordTypeName" input if a match is found.
    public static Id getRecordTypeIDByName(String objType, String recordTypeName) {
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE sObjectType = :objType AND Name = :recordTypeName AND isActive = true];
        if (rts.size() == 1) {
            return rts[0].Id;
        } else {
            return null;
        }
    }
    
    public static Id getRecordTypeIDByDevName(String sObjectType, String recordTypeDeveloperName) {
        // Concatenate input together
        String key = sObjectType + recordTypeDeveloperName;
        key = key.toLowerCase();
        
        // First, check to see if the record type map has been initialized.
        if (!isInitialized) {
            // If we haven't initialized the map yet, then we enter this block where it gets initialized
            allRecordTypes = new Map<String, Id>();
            // Create the record type map
            for (RecordType r : [SELECT Name, DeveloperName, Id, sObjectType FROM RecordType WHERE isActive = true]) {
                //Add a map entry, concatenating the sobject type + name as the key for each record type
                allRecordTypes.put((r.sObjectType + r.DeveloperName).toLowerCase(), r.Id);
            }
            // Indicate that we have initialized the record type map
            isInitialized = true;
        }
        // Finally, return the record type from the map
        return allRecordTypes.get(key);
    }
    
    // Returns a map of active, user-available RecordType IDs for a given SObjectType,
    // keyed by each RecordType's unique, unchanging DeveloperName 
    /*
    global static Map<String, Id> getRecordTypeIdsByDeveloperNameForContext(Schema.SObjectType token) {
        // Build a map of RecordTypeIds keyed by DeveloperName
        Map<String, Id> mapRecordTypes = new Map<String, Id>();
    
        // Get the Describe Result
        Schema.DescribeSObjectResult obj = token.getDescribe();
    
        // Obtain ALL Active Record Types for the given SObjectType token
        // (We will filter out the Record Types that are unavailable to the Running User using Schema information)
        String soql = 'SELECT Id, Name, DeveloperName FROM RecordType ' +
        			  'WHERE SObjectType = \'' + String.escapeSingleQuotes(obj.getName()) + '\' ' +
        			  'AND IsActive = TRUE';
        List<SObject> results;
        try {
            results = Database.query(soql);
        } catch (Exception ex) {
            results = new List<SObject>();
        }
    
        // Obtain the RecordTypeInfos for this SObjectType token
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
    
        // Loop through all of the Record Types we found, and weed out those that are unavailable to the Running User
        for (SObject rt : results) {  
            if (recordTypeInfos.get(rt.Id).isAvailable()) {
                // This RecordType IS available to the running user, so add it to our map of RecordTypeIds by DeveloperName
                mapRecordTypes.put(String.valueOf(rt.get('DeveloperName')), rt.Id);
            }
        }
    
        return mapRecordTypes;
    }
    
    // Returns a map of active, user-available RecordType IDs for a given SObjectType,
    // keyed by each RecordType's Name 
    global static Map<String, Id> getRecordTypeIdsByNameForContext(Schema.SObjectType token) {
        // Build a map of RecordTypeIds keyed by Name
        Map<String, Id> mapRecordTypes = new Map<String, Id>();
    
        // Get the Describe Result
        Schema.DescribeSObjectResult obj = token.getDescribe();
    
        // Obtain ALL Active Record Types for the given SObjectType token
        // (We will filter out the Record Types that are unavailable to the Running User using Schema information)
        String soql = 'SELECT Id, Name FROM RecordType ' +
        			  'WHERE SObjectType = \'' + String.escapeSingleQuotes(obj.getName()) + '\' ' +
        			  'AND IsActive = TRUE';
        List<SObject> results;
        try {
            results = Database.query(soql);
        } catch (Exception ex) {
            results = new List<SObject>();
        }
    
        // Obtain the RecordTypeInfos for this SObjectType token
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
    
        // Loop through all of the Record Types we found, and weed out those that are unavailable to the Running User
        for (SObject rt : results) {  
            if (recordTypeInfos.get(rt.Id).isAvailable()) {
                // This RecordType IS available to the running user, so add it to our map of RecordTypeIds by Name
                mapRecordTypes.put(String.valueOf(rt.get('Name')),rt.Id);
            }
        }
    
        return mapRecordTypes;
    }
*/
}