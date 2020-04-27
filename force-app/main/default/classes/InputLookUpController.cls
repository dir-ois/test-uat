public class InputLookUpController { 

/*
     * Returns the "Name" field for a given SObject (e.g. Case has CaseNumber, Account has Name)
    */
    private static String getSobjectNameField(SobjectType sobjType){
        
        //describes lookup obj and gets its name field
        String nameField = 'Name';
        Schema.DescribeSObjectResult dfrLkp = sobjType.getDescribe();
        for(schema.SObjectField sotype : dfrLkp.fields.getMap().values()){
            Schema.DescribeFieldResult fieldDescObj = sotype.getDescribe();
            if(fieldDescObj.isNameField() ){
                nameField = fieldDescObj.getName();
                break;
            }
        }
        system.debug(nameField);
        return nameField;
    }

    /*
     * Loads the initial value of the given SObject type with ID "value"
     */
    @AuraEnabled
    public static List<SObject> getCurrentValue(String searchVal, String typeVal){
        
        SObjectType objType = Schema.getGlobalDescribe().get(typeVal);
        if(objType == null){
            return null;
        }
        System.debug('typeVal: ' + typeVal);
        System.debug('objType: ' + objType);
        String nameField = getSobjectNameField(objType);
        System.debug('nameField: ' + nameField);
        System.debug('Search Param:' + searchVal);
        
        //if searchVal have special char
        if(searchVal.contains('\'')){
            searchVal = searchVal.split('\'')[0] + '\\\'';
        }

        //max. number of records to display for payor field
        Integer noOfRec = 20; 

        //Generate Query
        system.debug('searchVal: ' + searchVal);
        String s = '\'%' + searchVal + '%\'';
        String nl = '\'***Deleted%'; 
        String query = 'Select Id, '+ nameField + ' from ' + typeVal +' where '+ nameField + ' LIKE ' + s + ' LIMIT ' + noOfRec;
        if(typeVal == 'DIR_Employee__c'){
            query = 'Select Id, '+ nameField + ', Position__c from ' + typeVal +' where '+ nameField + ' LIKE ' + s + ' and Position__c = \'Senior Deputy\' LIMIT 5';
        }
        System.debug('### Query: ' + query);
        List<SObject> oList = Database.query(query);
        System.debug('### Query oList: ' + oList);
        
        return oList;
    }

}