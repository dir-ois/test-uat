global with sharing class Util {
    
    global static boolean skipTrigger(){
        Boolean skip = false;
        
        String a;
        String b;
        String c;
        String d;
        String e;
        String f;
        String g;
        String h;
        String i;
        String j;
        String k;
        String l;
        String m;
        String n;
        String o;
        String p;
        String q;
        String r;
        String s;
        String t;
        String u;
        String v;
        String w;
        String x;
        String y;
        String z;
        
        if(test.isRunningTest()) return skip;
        if(ApexPages.currentPage() != null){
            System.debug('ApexPages.currentPage() = '+ApexPages.currentPage());
            String strUrl = ApexPages.currentPage().getUrl();
            strUrl = strUrl.split('apex/')[1];
            skip =  strUrl.containsIgnoreCase('attachmentsplus');
        }

        return skip;
    }
    
    /*

    
    public static List<SObject> selectAllById(String sobjectName, List<String> ids) {
        Set<String> fieldNames = schema.describeSObjects(new String[] {sobjectName})[0].fields.getMap().keyset();
        List<String> iterableFields = new List<String>(fieldNames);
        String adtlParams = '';
        if(sObjectName == 'Case_Payment__c'){
            adtlParams += ''
            +',(SELECT Id, Payment_on_Behalf_of__c FROM Liability_Payments__r)'
            +',(SELECT Id, Payment_on_Behalf_of__c FROM Judgment_Payments__r)';
        }
        String queryString = String.format('SELECT {0} {1} FROM {2}', new String[] {String.join(iterableFields, ','), adtlParams, sobjectName});
        if(ids != null) {
            queryString += ' WHERE ID IN :ids';
        }
        System.debug('@@@queryString: '+queryString);
        return Database.query(queryString);
    }
    
    public static List<sObject> queryStarByObjectNameAndId(String sObjectName, String idType, String idValue, List<String> additionalFields, String OrderBy, Integer recordLimit){

        SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> fldObjMap = new Map<String,Schema.SObjectField>();
        
        fldObjMap = sObjectType.getDescribe().fields.getMap();
        
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String queryStr = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues){
            Schema.DescribeFieldResult fieldResult= s.getDescribe();
           
            String fieldName = fieldResult.getName();
            if (fieldResult.isAccessible()) {
                queryStr += fieldName + ',';
                
            }
        }
        
        if(additionalFields != null && !additionalFields.isEmpty()){
            for(String s : additionalFields){
                queryStr += s+',';
            }
        }
        
        queryStr = queryStr.subString(0, queryStr.length() - 1);
        
        queryStr += ' FROM '+ sObjectName;

        if(!String.isBlank(idType) && !String.isBlank(idValue)){
            queryStr += ' WHERE '+idType+' = \''+idValue+'\'';
        }
        if(!String.isBlank(OrderBy)){
            queryStr += ' ORDER BY '+OrderBy;
        }
        if(recordLimit != null){
            queryStr += ' LIMIT '+string.valueOf(recordLimit);
        }

        System.debug('@@@QueryString: '+queryStr);
        return Database.query(queryStr);
    }*/
}