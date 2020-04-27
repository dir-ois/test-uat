public class GenerateFieldHistoryAction extends TriggerAction{
    
    private static Map<String, Case_History__c> performedAudits = new  Map<String,Case_History__c>();
    
    public boolean shouldRun;
    private String sObjectName;
    private String sObjLabel;
    
    private Map<String,Map<String,Schema.SObjectField>> fieldMaps = new Map<String,Map<String,Schema.SObjectField>>();
    private Map<Id, sObject> sObjMap = new Map<Id, sObject>();
    private Map<String, String> hfcMap = new Map<String, String>();
    private List<Case_History__c> newHistList = new List<Case_History__c>();
    private String pathToParent;
    private SObjectType sObjectType;
    
    public GenerateFieldHistoryAction(Map<Id, sObject> triggerNewMap, Map<Id, sObject> triggerOldMap){
        super(triggerNewMap, triggerOldMap);
        sObjectName = triggerNewMap.values()[0].getSObjectType().getDescribe().getName();
        sObjLabel = triggerNewMap.values()[0].getSObjectType().getDescribe().getLabel();
        History_Object_Configuration__c hist = (History_Object_Configuration__c)selectSObjectHistory(sObjectName);
        if(hist == null){
            return;
        }
        else{
            system.debug('*******************hist: '+hist);
            pathToParent = hist.Path_to_Case__c;
            getSObjectMap(triggerNewMap.values(), hist, sObjectName);
            sObjectType = Schema.getGlobalDescribe().get(sObjectName);
            Map<String,Schema.SObjectField> sObjFieldMap = sObjectType.getDescribe().fields.getMap();
            fieldMaps.put(string.valueOf(sObjectType), sObjFieldMap);
            for(History_Field_Configuration__c hfc : hist.History_Field_Configuration__r){
                if(hfc.Tracked_Record_Types__c == null){
                    hfc.Tracked_Record_Types__c = 'ALL';
                }
                hfcMap.put(hfc.API_Field_Name__c, hfc.Tracked_Record_Types__c);
            }
            for(String s : hfcMap.keySet()){
                String fieldName = s;
                String fieldLabel = sObjFieldMap.get(s).getDescribe().getLabel();
                String trackedRTs = hfcMap.get(s);
                for(Id sObjId : triggerNewMap.keySet()){
                    boolean isDateField = false;
                    sObject newSObj = triggerNewMap.get(sObjId);
                    sObject oldSObj = triggerOldMap.get(sObjId);
                    Object oldFeild = oldSObj.get(fieldName);
                    Object newField = newSObj.get(fieldName);
                    String oldVal;
                    String newVal;
                    Schema.DisplayType fieldDataType = fieldMaps.get(String.valueOf(SObjectType)).get(fieldName).getDescribe().getType();
                    if(fieldDataType == Schema.DisplayType.DateTime){
                        oldVal = oldFeild == null ? '' : dateTime.valueOf(oldFeild).format();
                        newVal = newField == null ? '' : dateTime.valueOf(newField).format();
                    }
                    else if(fieldDataType == Schema.DisplayType.Date){
                        oldVal = oldFeild == null ? '' : date.valueOf(oldFeild).format();
                        newVal = newField == null ? '' : date.valueOf(newField).format();
                    }
                    else{
                        oldVal = String.valueOf(oldFeild);
                        newVal = String.valueOf(newField);
                    }
                    
                    String rtId;
                    try{
                        rtId = string.valueOf(sObjMap.get(sObjId).get('RecordTypeId'));
                    }
                    catch(exception e){/*sObect has no Record Types defined*/}
                    
                    if( newVal != oldVal && ((rtId == null && trackedRTs.contains('ALL')) || (rtId != null && trackedRTs.contains(rtId))) ){
                        if (hasBeenAudited (newSObj.Id, fieldName, newVal, oldVal)) {
                            continue;
                        }
                        else{
                            String parentId = getParentId(newSObj, sObjectName);
                            Case_History__c newHist = new Case_History__c(
                                Case_Management__c = parentId,
                                Field_Name__c = fieldLabel,
                                Type__c = 'Field Update',
                                New_Value__c = newVal,
                                Old_Value__c = oldVal,
                                Object__c = sObjLabel,
                                Record_ID__c = newSObj.Id
                            );
                            newHistList.add(newHist);
                            
                            performedAudits.put(newHist.Record_ID__c+'.'+newHist.Field_Name__c, newHist);
                        }
                    }
                }
            }
        }
    }
    
    private String getParentId(sObject newSObject, String sObjectName){
        sObject tempSobj = sObjMap.get(newSObject.Id);
        String idVal = 'Id';
        String parentId = string.valueOf(tempSobj.get(idVal));
        if(pathToParent.contains('.Id')){
            String tempPathToParent = pathToParent.replace('.Id', '');
            List<String> tempList = tempPathToParent.split('\\.');
            if(tempList.size() == 1){
                parentId = string.valueOf(tempSobj.getsObject(tempList[0]).get('Id'));
            }
            else if(tempList.size() == 2){
                parentId = string.valueOf(tempSobj.getsObject(tempList[0]).getsObject(tempList[1]).get('Id'));
            }
            else if(tempList.size() == 3){
                parentId = string.valueOf(tempSobj.getsObject(tempList[0]).getsObject(tempList[1]).getsObject(tempList[2]).get('Id'));
            }
        }
        return parentId;
    }
    
    private void getSObjectMap(List<sObject> newList, History_Object_Configuration__c hist, String sObjectName){
        String queryStr;
        if(pathToParent == null || pathToParent == ''){
            pathToParent = 'Id';
            queryStr = 'SELECT '+pathToParent;
        }
        else{
            pathToParent += '.Id';
            queryStr = 'SELECT Id, '+pathToParent;
        }
        List<Id> idList = new List<Id>();
        for(sObject newSObject : newList){
            idList.add(newSObject.Id);
        }
        String operator;
        String idVar;
        if(idList.size() == 1){
            operator = '=';
            idVar = '\''+idList[0]+'\'';
        }
        else{
            operator = 'IN';
            idvar = '(';
            for(Id i : idList){
                idvar += '\''+i+'\',';
            }
            idVar = idVar.subString(0, idVar.length() - 1) + ')';
        }
        queryStr += ', RecordTypeId FROM '+sObjectName+' WHERE Id '+operator+' '+idVar;
        system.debug('***************queryStr: '+queryStr);
        try{
            sObjMap = new Map <Id, sObject>(database.query(queryStr));
        }
        catch(exception e){
            if(e.getMessage().contains('RecordTypeId')){
                queryStr = queryStr.replace('RecordTypeId', 'CreatedDate'); //replace with system field so there is no error if RecordTypeId isn't available
            }
        }
        finally{
            if(sObjMap == null || sObjMap.isEmpty()){
                sObjMap = new Map <Id, sObject>(database.query(queryStr));
            }
        }
    }
    
    private SObject selectSObjectHistory(String sObjectName){
        
        SObjectType sObjectType = Schema.getGlobalDescribe().get('History_Object_Configuration__c');
        Map<String,Schema.SObjectField> fldObjMap;
        
        fldObjMap = sObjectType.getDescribe().fields.getMap();
        
        if (fieldMaps.containsKey('History_Object_Configuration__c')) {
            fldObjMap = fieldMaps.get('History_Object_Configuration__c');
        }
        else {
            fldObjMap = sObjectType.getDescribe().fields.getMap();
            fieldMaps.put('History_Object_Configuration__c', fldObjMap);
        }
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String queryStr = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues){
            Schema.DescribeFieldResult fieldResult = s.getDescribe();
            
            String fieldName = fieldResult.getName();
            
            if (fieldResult.isAccessible()) {
                queryStr += fieldName + ',';
                
            }
        }
        queryStr += ''
        +'(SELECT Id, Name, Active__c, API_Field_Name__c, History_Object_Configuration__c, Tracked_Record_Types__c FROM History_Field_Configuration__r WHERE Active__c = true),'
        +'(SELECT Id, Name, Active__c, Attachment_Criteria__c, Attachment_Operator__c,  History_Object_Configuration__c, Type__c, Attorney_Client_Privilege__c, Not_Subject_to_PRA__c, Confidential__c FROM History_Field_Configuration1__r WHERE Active__c = true),'
        +'(SELECT Id, Name, Active__c, Activity_Status__c, Activity_Type__c, Tracked_Statuses__c, History_Object_Configuration__c FROM Activity_Configuration__r WHERE Active__c = true)';
        queryStr += ' FROM History_Object_Configuration__c WHERE Object_API_Name__c = \''+sObjectName+'\' AND Active__c = true LIMIT 1';
        System.debug('**queryStr**: '+queryStr);
        sObject tempSObject;
        try{
            tempSObject = Database.query(queryStr);
        }
        catch(exception e){
            system.debug('**************ERROR ON: '+sObjectName);
            return null;
        }
        return tempSObject;
    }
    
    public override boolean shouldRunOnInsert() { return false;}
     
    public override boolean shouldRunOnDelete() { return false;} 
    
    public override boolean shouldRunOnUpdate() {
        shouldRun = newHistList.size() > 0 ? true : false;
        return shouldRun;
    } 
    
    public override void doAction() {
        system.debug('@@@@newHistList: '+newHistList);
        insert newHistList;
    }
    
    private static boolean hasBeenAudited(String recordId, String fieldApiName, String newField, String oldField) {
        String key = recordId+'.'+fieldApiName;
        if (!performedAudits.containsKey(key))
            return false;
        Case_History__c existingAudit =  performedAudits.get(key);
        if ((existingAudit.Old_Value__c == oldField) && (existingAudit.New_Value__c == newField)){
            return true;
        } 
        return false;
    }
    
    public static void runHandler() {
        if (trigger.isbefore) {
            return;
        }   
        
        if (trigger.isUpdate) {
            GenerateFieldHistoryAction action = new GenerateFieldHistoryAction(trigger.newMap, trigger.oldMap);
            if(action.shouldRunOnUpdate() && checkRecursive.runOnce()){
                action.doAction();
            }
        } 
    }
}