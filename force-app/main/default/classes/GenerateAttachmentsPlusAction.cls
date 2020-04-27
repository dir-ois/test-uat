public class GenerateAttachmentsPlusAction extends TriggerAction{
    
    private static Set<Id> performedAudits = new Set<Id>();
    
    public boolean shouldRun;
    private String sObjectName;
    private String parentObjectName;
    private String pathToParent;
    //private String parentPathToParent;
    private History_Object_Configuration__c hist;
    private History_Object_Configuration__c parentHist;
    
    private Map<Id, sObject> parentMap = new Map<Id, sObject>();
    private Map<String, History_Object_Configuration__c> histMap = new Map<String, History_Object_Configuration__c>();
    private Map<String, Set<String>> filterMap = new Map<String, Set<String>>();
    private Map<String, Attachment_Configuration__c> startsWithMap = new Map<String, Attachment_Configuration__c>();
    private Map<String, Attachment_Configuration__c> containsMap = new Map<String, Attachment_Configuration__c>();
    private Map<String, Attachment_Configuration__c> equalsMap = new Map<String, Attachment_Configuration__c>();
    private List<Attachments_Plus__c> newAttPlusList = new List<Attachments_Plus__c>();
    private List<Case_History__c> chList = new List<Case_History__c>();
    
    private Map<Id, sObject> sObjMap = new Map<Id, sObject>();
    
    public GenerateAttachmentsPlusAction(Map<Id, sObject> triggerNewMap){
        //This class does not support bulk inserts of Attachments that have different parent object types.
        //For this code to operate correctly in a bulk Insert, all Attachments must have the same Parent object type
        super(triggerNewMap);
        sObjectName = 'Attachment';
        List<History_Object_Configuration__c> hocList = [SELECT Id, Name, Active__c, Object_API_Name__c, Object_Name__c, Path_to_Case__c,
                                                            (SELECT Id, Name, Active__c, API_Field_Name__c, History_Object_Configuration__c, Tracked_Record_Types__c FROM History_Field_Configuration__r WHERE Active__c = true),
                                                            (SELECT Id, Name, Active__c, Attachment_Criteria__c, Attachment_Operator__c,  History_Object_Configuration__c, Type__c, Attorney_Client_Privilege__c, Not_Subject_to_PRA__c, Confidential__c FROM History_Field_Configuration1__r WHERE Active__c = true),
                                                            (SELECT Id, Name, Active__c, Activity_Status__c, Activity_Type__c, Tracked_Statuses__c, History_Object_Configuration__c FROM Activity_Configuration__r WHERE Active__c = true)
                                                        FROM History_Object_Configuration__c 
                                                        WHERE Active__c = true];
        Id tempParentObjId = String.valueOf(triggerNewMap.values()[0].get('ParentId'));                                             
        parentObjectName = tempParentObjId.getSObjectType().getDescribe().getName();
        for(History_Object_Configuration__c h : hocList){
            if(!histMap.containsKey(h.Object_API_Name__c)){
                histMap.put(h.Object_API_Name__c, h);
            }
        }
        hist = histMap.get(sObjectName);
        parentHist = histMap.get(parentObjectName);
        if(hist == null || parentHist == null){
            return;
        }
        else{
            getFilterMap(hist);
            pathToParent = parentHist.Path_to_case__c;
            getSObjectMap(triggerNewMap.values(), hist, sObjectName);
            for(sObject s : triggerNewMap.values()){
                Attachment att = (Attachment)s;
                String parentId = att.ParentId;
                if(sObjMap.containsKey(parentId)){
                    sObject parentObj = sObjMap.get(parentId);
                    String pId;
                    List<Attachment_Configuration__c> configList = new List<Attachment_Configuration__c>();
                    for(String str : filterMap.keySet()){
                        Set<String> tempSet = filterMap.get(str);
                        for(String cStr : tempSet){
                            String compareString = cStr;
                            String attName = att.Name;
                            Boolean createAP = false;
                            Map<String, Attachment_Configuration__c> acConfigMap = new Map<String, Attachment_Configuration__c>();
                            if(str == 'Starts With'){
                                if(cStr.length() > attName.length()){
                                    continue;
                                }
                                else if(attName.subString(0, cStr.length()) == cStr){
                                    acConfigMap = startsWithMap;
                                }
                            }
                            else if(str == 'Contains' && attName.contains(cStr)){
                                acConfigMap = containsMap;
                            }
                            else if(str == 'Equals' && attName == cStr){
                                acConfigMap = equalsMap;
                            }
                            pId = getParentId(sObjMap.get(parentId), parentObjectName);
                            Attachment_Configuration__c thisAC;
                            if(acConfigMap.containsKey(cStr)){
                                thisAC = acConfigMap.get(cStr);
                                configList.add(thisAC);
                            }
                        }
                    }
                    if(!hasBeenAudited(att.Id)){
                        if(!configList.isEmpty()){
                            for(Attachment_Configuration__c thisAC : configList){
                                Attachments_Plus__c ap = new Attachments_Plus__c(
                                    Attachment_ID__c = att.Id,
                                    Attachment_Name__c = att.Name,
                                    Attorney_Client_Privilege__c = thisAC.Attorney_Client_Privilege__c,
                                    Confidential__c = thisAC.Confidential__c,
                                    Not_Subject_to_PRA__c = thisAC.Not_Subject_to_PRA__c,
                                    Object__c = parentObjectName,
                                    Parent_Record_ID__c = pId,
                                    Record_ID__c = parentId,
                                    Type__c = thisAC.Type__c
                                );
                                newAttPlusList.add(ap);

                                if(parentObjectName.equalsIgnoreCase('account')) continue;

                                Case_History__c ch = new Case_History__c(
                                    Case_Management__c = pId,
                                    Record_ID__c = parentId,
                                    Type__c = 'Attachment',
                                    New_Value__c = 'New '+thisAC.Type__c+' Attachment Created: '+att.Name
                                );
                                chList.add(ch);
                            }
                        }
                        else{
                            Attachments_Plus__c ap = new Attachments_Plus__c(
                                    Attachment_ID__c = att.Id,
                                    Attachment_Name__c = att.Name,
                                    Attorney_Client_Privilege__c = false,
                                    Confidential__c = false,
                                    Not_Subject_to_PRA__c = false,
                                    Object__c = parentObjectName,
                                    Parent_Record_ID__c = pId,
                                    Record_ID__c = parentId,
                                    Type__c = 'Unknown'
                                );
                            newAttPlusList.add(ap);

                            if(parentObjectName.equalsIgnoreCase('account')) continue;

                            Case_History__c ch = new Case_History__c(
                                Case_Management__c = pId,
                                Record_ID__c = parentId,
                                Type__c = 'Attachment',
                                New_Value__c = 'New Unknown Attachment Created: '+att.Name
                            );
                            chList.add(ch);
                        }
                        
                        performedAudits.add(att.Id);
                    }
                }
            }
        }
    }
    
    private void getFilterMap(History_Object_Configuration__c hist){
        for(Attachment_Configuration__c ac : hist.History_Field_Configuration1__r){
            if(ac.Attachment_Operator__c != null && ac.Attachment_Criteria__c != null){
                Set<String> tempSet = new Set<String>();
                if(!filterMap.containsKey(ac.Attachment_Operator__c)){
                    tempSet.add(ac.Attachment_Criteria__c);
                    filterMap.put(ac.Attachment_Operator__c, tempSet);
                }
                else{
                    tempSet = filterMap.get(ac.Attachment_Operator__c);
                    tempSet.add(ac.Attachment_Criteria__c);
                    filterMap.put(ac.Attachment_Operator__c, tempSet);
                }

                if(ac.Attachment_Operator__c == 'Starts With' && !startsWithMap.containsKey(ac.Attachment_Criteria__c)){
                    startsWithMap.put(ac.Attachment_Criteria__c, ac);
                }
                if(ac.Attachment_Operator__c == 'Contains' && !containsMap.containsKey(ac.Attachment_Criteria__c)){
                    containsMap.put(ac.Attachment_Criteria__c, ac);
                }
                if(ac.Attachment_Operator__c == 'Equals' && !equalsMap.containsKey(ac.Attachment_Criteria__c)){
                    equalsMap.put(ac.Attachment_Criteria__c, ac);
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
        if(pathToParent == null){
            pathToParent = 'Id';
        }
        else{
            pathToParent += '.Id';
        }
        String queryStr = 'SELECT '+pathToParent;
        
        List<Id> idList = new List<Id>();
        for(sObject newSObject : newList){
            idList.add(String.valueOf(newSObject.get('ParentId')));
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
                String parentId = String.valueOf(s.get('ParentId'));
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
                sObjMap = new Map <Id, sObject>(database.query(queryStr));
            }
        }
    }
    
    public override boolean shouldRunOnInsert() {

        shouldRun = newAttPlusList.size() > 0 ? true : false;
        
        return shouldRun;
    }
     
    public override boolean shouldRunOnDelete() { return false;} 
    
    public override boolean shouldRunOnUpdate() { return false;}
    
    public override void doAction() {
        
        insert newAttPlusList;
        insert chList;
        
    }
    
    private static boolean hasBeenAudited(String attId) {
        if (performedAudits.contains(attId)){
            return true;
        }
        else{
            return false;
        }
    }

    public static void runHandler() {
        if(Util.skipTrigger()){
            return;
        }
        
        if (trigger.isBefore) {
            return;
        }   
        
        if (trigger.isInsert) {
            GenerateAttachmentsPlusAction action = new GenerateAttachmentsPlusAction(trigger.newMap);
            if(action.shouldRunOnInsert()){
                action.doAction();
            }
        } 
        
    }
}