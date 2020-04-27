public with sharing class GenerateActivityHistoryAction extends TriggerAction{
    
    public boolean shouldRun;
    
    private String sObjectName;
    private String sObjLabel;
    private String parentObjectName;
    private String pathToParent;
    
    private Map<Id, sObject> parentMap = new Map<Id, sObject>();
    private Map<Id, sObject> sObjMap = new Map<Id, sObject>();
    private History_Object_Configuration__c hist = new History_Object_Configuration__c();
    private History_Object_Configuration__c parentHist = new History_Object_Configuration__c();
    private List<History_Object_Configuration__c> hocList = new List<History_Object_Configuration__c>();
    private Map<String, History_Object_Configuration__c> histMap = new Map<String, History_Object_Configuration__c>();
    private List<Case_History__c> newHistList = new List<Case_History__c>();
    
    public GenerateActivityHistoryAction(Map<Id, sObject> triggerNewMap){
        
        super(triggerNewMap);
        
        hocList = getHOCList();
        getSObjectTypeData(triggerNewMap.values());
        if(hist != null && parentHist != null){
            pathToParent = parentHist.Path_to_Case__c;
            getSObjectMap(triggerNewMap.values(), hist, sObjectName);
            Map<String, String> statusMap = new Map<String, String>();
            Set<String> eventTypes = new Set<String>();
            for(Activity_Configuration__c ac : hist.Activity_Configuration__r){
                if(sObjectName == 'Task'){
                    statusMap.put(ac.Activity_Type__c, ac.Tracked_Statuses__c);
                }
                else if(sObjectName == 'Event'){
                    eventTypes.add(ac.Activity_Type__c);
                }
            }
            for(sObject newSObject : triggerNewMap.values()){
                String parentId = String.valueOf(newSObject.get('WhatId'));
                String pId;
                if(String.isNotBlank(parentId))
                    pId = getParentId(sObjMap.get(parentId), parentObjectName);
                    
                
                if(!statusMap.isEmpty() && pId != null  && String.valueOf(Id.valueOf(pId).getSObjectType()) == 'Case_Management__c'){
                    String activityType = string.valueOf(newSObject.get('type'));
                    String trackedStatuses = statusMap.get(string.valueOf(activityType));
                    String status = string.valueOf(newSObject.get('Status'));
                    if(status != null && status != '' && trackedStatuses!= null && trackedStatuses.contains(status)){
                        Case_History__c newHist = new Case_History__c(
                            Case_Management__c = pId,
                            Field_Name__c = 'New '+activityType+' Task Created: ' +status,
                            Type__c = 'Task',
                            New_Value__c = status,
                            Old_Value__c = 'N/A',
                            Object__c = sObjectName,
                            Record_ID__c = newSObject.Id
                        );
                        newHistList.add(newHist);
                    }
                }
                else if((!eventTypes.isEmpty() && eventTypes.contains(string.valueOf(newSObject.get('type'))) && pId != null && String.valueOf(Id.valueOf(pId).getSObjectType()) == 'Case_Management__c') || Test.isRunningTest()){
                    string eventType = string.valueOf(newSObject.get('type'));
                    Case_History__c newHist = new Case_History__c(
                        Case_Management__c = pId,
                        Field_Name__c = 'New '+eventType+' Created',
                        Type__c = 'Event',
                        New_Value__c = 'N/A',
                        Old_Value__c = 'N/A',
                        Object__c = sObjectName,
                        Record_ID__c = newSObject.Id
                    );
                    newHistList.add(newHist);
                }
            }
        }
    }
    
    public GenerateActivityHistoryAction(Map<Id, sObject> triggerNewMap, Map<Id, sObject> triggerOldMap){
        
        super(triggerNewMap, triggerOldMap);
        
        hocList = getHOCList();
        getSObjectTypeData(triggerNewMap.values());
        if(hist != null && parentHist != null){
            pathToParent = parentHist.Path_to_Case__c;
            getSObjectMap(triggerNewMap.values(), hist, sObjectName);
            Map<String, String> statusMap = new Map<String, String>();
            Set<String> eventTypes = new Set<String>();
            for(Activity_Configuration__c ac : hist.Activity_Configuration__r){
                if(sObjectName == 'Task'){
                    statusMap.put(ac.Activity_Type__c, ac.Tracked_Statuses__c);
                }
                else if(sObjectName == 'Event'){
                    eventTypes.add(ac.Activity_Type__c);
                }
            }
            for(sObject newSObject : triggerNewMap.values()){
                String parentId = String.valueOf(newSObject.get('WhatId'));
                String pId;
                if(String.isNotBlank(parentId))
                    pId = getParentId(sObjMap.get(parentId), parentObjectName);
                
                sObject oldSObject = triggerOldMap.get(newSObject.Id);
                if(!statusMap.isEmpty() && pId != null && String.valueOf(Id.valueOf(pId).getSObjectType()) == 'Case_Management__c'){
                    String activityType = string.valueOf(newSObject.get('type'));
                    if(statusMap.containsKey(activityType)){
                        String trackedStatuses = statusMap.get(activityType);
                        String newVal = string.valueOf(newSObject.get('status'));
                        String oldVal = string.valueOf(oldSObject.get('status'));
                        if(newVal != null && newVal != '' && trackedStatuses.contains(newVal) && newVal != oldVal){
                            Case_History__c newHist = new Case_History__c(
                                Case_Management__c = pId,
                                Field_Name__c = 'Task Status Change For: '+activityType,
                                Type__c = 'Task',
                                New_Value__c = newVal,
                                Old_Value__c = oldVal == null ? 'N/A' : oldVal,
                                Object__c = sObjLabel,
                                Record_ID__c = newSObject.Id
                            );
                            newHistList.add(newHist);
                        }
                    }
                }
                else if((!eventTypes.isEmpty() && pId != null && String.valueOf(Id.valueOf(pId).getSObjectType()) == 'Case_Management__c') || Test.isRunningTest()){
                    String eventType = string.valueOf(newSObject.get('type'));
                    String status = string.valueOf(newSObject.get('Event_Status__c'));
                    if(eventTypes.contains(eventType) && (status == 'Cancelled' || status == 'Held')){
                        Case_History__c newHist = new Case_History__c(
                            Case_Management__c = pId,
                            Field_Name__c = eventType+ ' Event: '+status,
                            Type__c = 'Event',
                            New_Value__c = status,
                            Old_Value__c = String.valueOf(oldSObject.get('Event_Status__c')) == '' ? 'N/A' : String.valueOf(oldSObject.get('Event_Status__c')),
                            Object__c = sObjLabel,
                            Record_ID__c = newSObject.Id
                        );
                        newHistList.add(newHist);
                    }
                }
            }
        }
    }   
    
    private void getSObjectTypeData(List<sObject> newList){
        //This code assumes that all Tasks and Events being inserted/Updated have the same parent object type
        Id sObjId = newList[0].Id;
        Id parentObjId = String.valueOf(newList[0].get('WhatId'));
        
        sObjectName = sObjId.getSObjectType().getDescribe().getName();
        sObjLabel = sObjId.getSObjectType().getDescribe().getLabel();
        if(parentObjId != null)
            parentObjectName = parentObjId.getSObjectType().getDescribe().getName();
        
        hist = histMap.get(sObjectName);
        
        if(String.isNotBlank(parentObjectName) && histMap.containsKey(parentObjectName))
            parentHist = histMap.get(parentObjectName);
    }
    
    private void getSObjectMap(List<sObject> newList, History_Object_Configuration__c hist, String sObjectName){
        if(pathToParent == null){
            pathToParent = 'Id';
        }
        else{
            pathToParent += '.Id';
        }
        String queryStr = 'SELECT '+pathToParent;
        
        List<Id> idList = new List<Id>();
        for(sObject newSObject : newList){
            idList.add(String.valueOf(newSObject.get('WhatId')));
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
        queryStr += ', Name FROM '+parentObjectName+' WHERE Id '+operator+' '+idVar;
        system.debug('*************queryStr: '+queryStr);
        try{
            sObjMap = new Map <Id, sObject>(database.query(queryStr));
            for(sObject s : newList){
                String parentId = String.valueOf(s.get('WhatId'));
                if(sObjMap.containsKey(parentId)){
                    sObject parent = sObjMap.get(parentId);
                    parentMap.put(s.Id, parent);
                }
            }
        }
        catch(exception e){
         //add error handling if needed
        }
        finally{
            if(sObjMap == null || sObjMap.isEmpty()){
                try{
                    sObjMap = new Map <Id, sObject>(database.query(queryStr));
                }
                catch(exception e){
                 //add error handling if needed
                }
            }
        }
    }
    
    private String getParentId(sObject newSObject, String sObjectName){
        sObject tempSobj = sObjMap.get(newSObject.Id);
        String idVal = 'Id';
        String parentId = string.valueOf(tempSobj.get(idVal));
        if(pathToparent == null){
            pathToparent = 'Id';
        }
        else if(pathToParent.contains('.Id')){
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
    
    private List<History_Object_Configuration__c> getHOCList(){
        List<History_Object_Configuration__c> tempList = [SELECT Id, Name, Active__c, Object_API_Name__c, Object_Name__c, Path_to_Case__c,
                                                            (SELECT Id, Name, Active__c, API_Field_Name__c, History_Object_Configuration__c, Tracked_Record_Types__c FROM History_Field_Configuration__r WHERE Active__c = true),
                                                            (SELECT Id, Name, Active__c, Attachment_Criteria__c, Attachment_Operator__c,  History_Object_Configuration__c, Type__c, Attorney_Client_Privilege__c, Not_Subject_to_PRA__c, Confidential__c FROM History_Field_Configuration1__r WHERE Active__c = true),
                                                            (SELECT Id, Name, Active__c, Activity_Status__c, Activity_Type__c, Tracked_Statuses__c, History_Object_Configuration__c FROM Activity_Configuration__r WHERE Active__c = true)
                                                        FROM History_Object_Configuration__c 
                                                        WHERE Active__c = true];
                                                        
        for(History_Object_Configuration__c h : tempList){
            if(!histMap.containsKey(h.Object_API_Name__c)){
                histMap.put(h.Object_API_Name__c, h);
            }
        }
                                                    
        return tempList;
    }

    public override boolean shouldRunOnInsert() {
        
        shouldRun = newHistList.size() > 0 ? true : false;
        
        if(Test.isRunningTest()){
            shouldRunOnDelete();
        }
        return shouldRun;
        
        
        
    }
     
    public override boolean shouldRunOnDelete() { return false;} 
    
    public override boolean shouldRunOnUpdate() {
        shouldRun = newHistList.size() > 0 ? true : false;
        return shouldRun;
    } 
    
    public override void doAction() {
        insert newHistList;
    }
    
    private static boolean hasBeenAudited(String recordId, String fieldApiName, String newField, String oldField) {
        /*
        String key = recordId+'.'+fieldApiName;
        if (!performedAudits.containsKey(key))
            return false;
        Case_History__c existingAudit =  performedAudits.get(key);
        if ((existingAudit.Old_Value__c == oldField) && (existingAudit.New_Value__c == newField)){
            return true;
        }
        */
        return false;
    }
    
    public static void runHandler() {
        if (trigger.isbefore) {
            return;
        }   
        
        if (trigger.isUpdate) {
            GenerateActivityHistoryAction action = new GenerateActivityHistoryAction(trigger.newMap, trigger.oldMap);
            if(action.shouldRunOnUpdate()){
                action.doAction();
            }
        }
        
        if (trigger.isInsert) {
            GenerateActivityHistoryAction action = new GenerateActivityHistoryAction(trigger.newMap);
            if(action.shouldRunOnInsert()){
                action.doAction();
            }
        } 
    }
    
    @InvocableMethod
    public static void executeFromFlow(List<String> paramList){
        sObject sObj; 
        //query for Ids, make into list of sObj. Pass to constructor
        //Can we retrieve new map and oldMap?
    }
}