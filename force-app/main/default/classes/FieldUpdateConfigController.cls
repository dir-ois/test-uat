public with sharing class FieldUpdateConfigController {
    
    public boolean firstStep {get;set;}
    public boolean secondStep {get;set;}
    public boolean renderFieldUpdate {get;set;}
    public boolean renderAttachmentUpdate {get;set;}
    public boolean renderActivityUpdate {get;set;}
    public boolean hasSelected {get;set;}
    public boolean renderPopup {get;set;}
    
    public List<string> statusList {get;set;}
    public List<fieldWrapper> fwList {get;set;}
    public List <taskWrapper> twList {get;set;}
    public List <eventWrapper> ewList {get;set;}
    public List <attWrapper> attList {get;set;}
    public List<SelectOption> availObjects {get;set;}
    public List<SelectOption> availRTs {get;set;}
    public List<SelectOption> filterOptions {get;set;}
    public Map<String, List<RecordType>> rtMap {get;set;}
    public List<RecordType> rtList {get;set;}
    public List<RecordType> rtListTask {get;set;}
    public List<RecordType> rtListEvent {get;set;}
    public Map<String, Map<Id, rtWrapper>> trackedFieldsMap {get;set;}
    public Attachment_Configuration__c newFilter {get;set;}
    
    public String selectedAttId {get;set;}
    public String selectedType {get;set;}
    public String selectedObject {get;set;}
    public String selectedRT {get;set;}
    
    public attWrapper selectedAtt {get;set;}
    
    private History_Object_Configuration__c thisHistObj;
    private History_Object_Configuration__c taskHist;
    private History_Object_Configuration__c eventHist;
    private List<History_Object_Configuration__c> histConfigList = new List<History_Object_Configuration__c>();
    private static Map<String,Map<String,Schema.SObjectField>> fieldMaps = new Map<String,Map<String,Schema.SObjectField>> ();
    
    public FieldUpdateConfigController(){
        firstStep = true;
        secondStep = false;
        hasSelected = false;
        renderFieldUpdate = false;
        renderAttachmentUpdate = false;
        renderActivityUpdate = false;
        //renderPopup = false;
        newFilter = new Attachment_Configuration__c();
        getObjectHistoryConfigData();
        getAttachmentData();
        getActivityData();
        
    }
    
    public void getFieldUpdateData(){
        if(fwList == null){
            fwList = new List<fieldWrapper>();
        }
        rtList = rtMap.get(selectedObject);
        system.debug('******************rtMap: '+rtMap);
        system.debug('******************selectedObject: '+selectedObject);
        system.debug('**************rtList: '+rtList);
        if(rtList == null){
            rtList = new List<RecordType>();
            RecordType fakeRT = new RecordType(
                Name = 'Select'
            );
            rtList.add(fakeRT);
        }
        system.debug('**************1: ');
        Map<String, Schema.SObjectField> objFields = getObjectFields(selectedObject);
        for(History_Object_Configuration__c h : histConfigList){
            if(h.Object_API_Name__c == selectedObject){
                system.debug('**************2: ');
                thisHistObj = h;
                break;
            }
        }
        if(thisHistObj != null){
            system.debug('**************3: ');
            for(Schema.SObjectField s : objFields.values()){
                fwList.add(new fieldWrapper(s, rtList));
            }
            system.debug('**************4: '+fwList);
            for(fieldWrapper fw : fwList){
                system.debug('**************5: ');
                boolean hasHist = false;
                for(History_Field_Configuration__c fh : thisHistObj.History_Field_Configuration__r){
                    system.debug('**************6: ');
                    if(fh.API_Field_Name__c == fw.apiName && fh.Active__c == true){
                        system.debug('**************7: ');
                        hasHist = true;
                        for(String i : fw.rtMap.keySet()){
                            system.debug('*******************i: '+i);
                            if(fh.Tracked_Record_Types__c != null && fh.Tracked_Record_Types__c.contains(i)){
                                rtWrapper temp = fw.rtMap.get(i);
                                temp.selected = true;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void editFilter(){
        renderPopup =! renderPopup;
        if(renderPopup == true){
            for(attWrapper aw : attList){
                if(aw.thisAtt.Id == selectedAttId){
                    selectedAtt = aw;
                    selectedAtt.updated = true;
                    break;
                }
            }
        }
    }
    
    public void addNewFilter(){
        renderPopup = true;
        Attachment_Configuration__c newAC = new Attachment_Configuration__c(
            History_Object_Configuration__c = thisHistObj.Id
        );
        attWrapper tempAtt = new attWrapper(newAC);
        selectedAtt = tempAtt;
        //attList.add(new attWrapper(newAC));   
    }
    
    public void saveFilter(){
        if(selectedAttId != '' && selectedAttId != 'NEW'){
            for(attWrapper aw : attList){
                if(aw.thisAtt.Id == selectedAttId){
                    Attachment_Configuration__c thisAtt = aw.thisAtt;
                    system.debug('*******************thisAtt: '+thisAtt);
                    update thisAtt;
                    aw.thisAtt = thisAtt;
                    break;
                }
            }
        }
        else if(selectedAttId == 'NEW'){
            newFilter.History_Object_Configuration__c = thisHistObj.Id;
            newFilter.Active__c = true;
            insert newFilter;
            newFilter = new Attachment_Configuration__c();
        }
        getObjectHistoryConfigData();
        getAttachmentData();
        
    }
    
    public void removeFilter(){
        system.debug('******************selectedAttId: '+selectedAttId);
        if(selectedAttId != null){
            for(attWrapper aw : attList){
                if(aw.thisAtt.Id == selectedAttId){
                    selectedAtt = aw;
                    selectedAtt.updated = true;
                    selectedAtt.thisAtt.Active__c = false;
                    getObjectHistoryConfigData();
                    getAttachmentData();
                    break;
                }
            }
        }
    }

    public void getAttachmentData(){
        attList = new List<attWrapper>();
        for(History_Object_Configuration__c h : histConfigList){
            if(h.Object_API_Name__c == 'Attachment'){
                thisHistObj = h;
            }
        }
        if(thisHistObj != null){
            for(Attachment_Configuration__c ac : thisHistObj.History_Field_Configuration1__r){
                attList.add(new attWrapper(ac));
            }
        }
    }
    
    public class attWrapper{
        public Attachment_Configuration__c thisAtt {get;set;}
        public boolean updated {get;set;}
        public attWrapper(Attachment_Configuration__c ac){
            thisAtt = ac;
            updated = false;
        }
    }
    
    public void getActivityData(){
        statusList = new List<String>();
        rtListTask = rtMap.get('Task');
        rtListEvent = rtMap.get('Event');
        for(History_Object_Configuration__c h : histConfigList){
            if(h.Object_API_Name__c == 'Task'){
                taskHist = h;
                thisHistObj = h;
            }
            else if(h.Object_API_Name__c == 'Event'){
                eventHist = h;
                thisHistObj = h;
            }
            if(taskHist != null && eventHist != null){
                break;
            }
        }
        twList = new List<taskWrapper>();
        ewList = new List<eventWrapper>();
        
        Schema.DescribeFieldResult taskFieldType = Task.Type.getDescribe();
        List<Schema.PicklistEntry> taskTypes = taskFieldType.getPicklistValues();
        
        Schema.DescribeFieldResult taskFieldStatus = Task.Status.getDescribe();
        List<Schema.PicklistEntry> taskStatuses = taskFieldStatus.getPicklistValues();
        
        for(Schema.PicklistEntry s : taskStatuses){
            statusList.add(s.getLabel());
        }
        
        if(taskHist != null){
            for(Schema.PicklistEntry s : taskTypes){
                twList.add(new taskWrapper(s.getLabel(), taskStatuses));
            }
            for(taskWrapper tw : twList){
                boolean hasHist = false;
                for(Activity_Configuration__c ac : taskHist.Activity_Configuration__r){
                    if(ac.Activity_Type__c == tw.activityType){
                        hasHist = true;
                        for(Schema.PicklistEntry s : taskStatuses){
                            if(ac.Tracked_Statuses__c != null && ac.Tracked_Statuses__c.contains(s.getLabel())){
                                tw.statusMap.get(s.getLabel()).selected = true;
                            }
                        }
                    }
                }
            }
            system.debug('*****************twList: '+twList);
        }
        
        Schema.DescribeFieldResult eventFieldType = Event.Type.getDescribe();
        List<Schema.PicklistEntry> eventTypes = eventFieldType.getPicklistValues();
        if(eventHist != null){
            for(Schema.PicklistEntry s : eventTypes){
                ewList.add(new eventWrapper(s.getLabel()));
            }
            for(eventWrapper ew : ewList){
                boolean hasHist = false;
                for(Activity_Configuration__c ac : eventHist.Activity_Configuration__r){
                    if(ac.Activity_Type__c == ew.activityType){
                        hasHist = true;
                        ew.thisAC = ac;
                        if(ac.Active__c == true){
                            ew.selected = true;
                        }
                    }
                }
            }
        }
    }
    
    public class activityTypeWrapper{
        public boolean selected {get;set;}
        public activityTypeWrapper(boolean sel){
            selected = sel;
        }
    }
    
    public class rtWrapper{
        public boolean selected {get;set;}
        public String fieldName {get;set;}
        public RecordType rt {get;set;}
        public rtWrapper(Schema.SObjectField f, RecordType r, boolean s){
            selected = s;
            rt = r;
            fieldName = f.getDescribe().getName();
        }
    }
    
    public class fieldWrapper{
        public boolean selected {get;set;}
        public String apiName {get;set;}
        public String devName {get;set;}
        public Map<String, rtWrapper> rtMap {get;set;}
        public fieldWrapper(Schema.SObjectField f, List<RecordType> rts){
            selected = false;
            apiName = f.getDescribe().getName();
            devName = f.getDescribe().getLabel();
            rtMap = new Map<String, FieldUpdateConfigController.rtWrapper>();
            system.debug('**************a: ');
            if(rts != null && !rts.isEmpty()){
                system.debug('**************b: ');
                for(RecordType r : rts){
                    if(r.Name == 'Select'){
                        system.debug('**************c: '+r);
                        rtMap.put('ALL', new FieldUpdateConfigController.rtWrapper(f, r, false));
                    }
                    else{
                        system.debug('**************d: ');
                        rtMap.put(r.Id, new FieldUpdateConfigController.rtWrapper(f, r, false));
                    }
                }
            }
        }
    }
    
    public class taskWrapper{
        public String activityType {get;set;}
        public Map<String, FieldUpdateConfigController.activityTypeWrapper> statusMap {get;set;}
        public taskWrapper(String s, List<Schema.PicklistEntry> statuses){
            activityType = s;
            if(statuses != null){
                statusMap = new Map<String, FieldUpdateConfigController.activityTypeWrapper>();
                for(Schema.PicklistEntry st : statuses){
                    statusMap.put(st.getLabel(), new FieldUpdateConfigController.activityTypeWrapper(false));
                }
            }
        }
    }
    
    public class eventWrapper{
        public Activity_Configuration__c thisAC {get;set;}
        public String activityType {get;set;}
        public Boolean selected {get;set;}
        public eventWrapper(String s){
            activityType = s;
            selected = false;
        }
    }
    
    public void getSelected(){
        if(selectedType == 'fu'){
            renderFieldUpdate =! renderFieldUpdate;
            
        }
        if(selectedType == 'att'){
            renderAttachmentUpdate = true;
        }
        if(selectedType == 'act'){
            renderActivityUpdate = true;
        }
    }
    
    public void renderSecondStep(){
        firstStep = false;
        secondStep = true;
        if(selectedType == null){
            //add error
            return;
        }
        if(selectedType == 'att'){
            renderAttachmentUpdate = true;
            firstStep = false;
            //getAttachmentData();
        }
        else if(selectedType == 'fu'){
            renderFieldUpdate = true;
            getFieldUpdateData();
        }
        else if(selectedType == 'act'){
            renderActivityUpdate = true;
            firstStep = false;
            //getActivityData();
        }
    }
    
    public pageReference saveAtts(){
        
        //getObjectHistoryConfigData();
        PageReference pageRef = new PageReference('/apex/FieldUpdateConfig');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pageReference saveActivityConfig(){
        List<Activity_Configuration__c> acList = new List<Activity_Configuration__c>();
        system.debug('********************twList: '+twList);
        for(taskWrapper tw : twList){
            boolean hasHist = false;
            system.debug('********************thisHistObj: '+thisHistObj);
            for(Activity_Configuration__c ac : taskHist.Activity_Configuration__r){
                if(ac.Activity_Type__c == tw.activityType){
                    String statuses = '';
                    hasHist = true;
                    for(String s : tw.statusMap.keySet()){
                        if(tw.statusMap.get(s).selected == true){
                            statuses += s+';';
                        }   
                    }
                    if(ac.Tracked_Statuses__c != statuses){
                        ac.Tracked_Statuses__c = statuses;
                        if(statuses == ''){
                            ac.Active__c = false;
                        }
                        else if(statuses != '' && ac.Active__c == false){
                            ac.Active__c = true;
                        }
                        acList.add(ac);
                    }
                }
            }
            system.debug('******************hasHist: '+hasHist);
            if(hasHist == false){
                Activity_Configuration__c newAC = new Activity_Configuration__c(
                    Active__c = true,
                    History_Object_Configuration__c = taskHist.Id,
                    Activity_Type__c = tw.activityType
                );
                String statuses = '';
                for(String s : tw.statusMap.keySet()){
                    if(tw.statusMap.get(s).selected == true){
                        statuses += s;
                    }   
                }
                newAC.Tracked_Statuses__c = statuses;
                acList.add(newAC);
            }
        }
        for(eventWrapper ew : ewList){
            if(ew.thisAC == null){
                ew.thisAC = new Activity_Configuration__c(
                    Active__c = false,
                    History_Object_Configuration__c = eventHist.Id,
                    Activity_Type__c = ew.activityType
                );
            }
            if(ew.selected == true){
                ew.thisAC.Active__c = true;
            }
            else{
                ew.thisAC.Active__c = false;
            }
            acList.add(ew.thisAC);
        }
        if(!acList.isEmpty()){
            system.debug('****************ACLIST: '+acList);
            upsert acList;
            getObjectHistoryConfigData();
            PageReference pageRef = new PageReference('/apex/FieldUpdateConfig');
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have not made any changes. Please select Statuses to add or de-select fields you no longer wish to track. Click \'Cancel\' to return to the start page.'));
            return null;
        }
    }
    
    public pageReference saveSelected(){
        List<History_Field_Configuration__c> histList = new List<History_Field_Configuration__c>();
        for(fieldWrapper fw : fwList){
            History_Field_Configuration__c hist;
            boolean hasHist = false;
            String rtString = '';
            for(History_Field_Configuration__c h : thisHistObj.History_Field_Configuration__r){
                if(h.API_Field_Name__c == fw.apiName){
                    hist = h;
                    hasHist = true;
                    for(String rId : fw.rtMap.keySet()){
                        rtWrapper rtw = fw.rtMap.get(rId);
                        if(rtw.selected == true){
                            if(rtw.rt.Name == 'Select'){
                                rtString = 'ALL;';
                            }
                            else{
                                rtString += rId+';';
                            }
                        }
                    }
                    if(rtString != ''){
                        hist.Active__c = true;
                        rtString = rtString.subString(0, rtString.length() - 1);
                    }
                    else{
                        hist.Active__c = false;
                    }
                    hist.Tracked_Record_Types__c = rtString;
                    histList.add(hist);
                }
            }
            if(hasHist == false){
                for(String rId : fw.rtMap.keySet()){
                    rtWrapper rtw = fw.rtMap.get(rId);
                    if(rtw.Selected == true){
                        rtString += rId+';';
                    }
                }
                if(rtString != ''){
                    rtString = rtString.subString(0, rtString.length() -1);
                    History_Field_Configuration__c newHist = new History_Field_Configuration__c(
                        History_Object_Configuration__c = thisHistObj.Id,
                        API_Field_Name__c = fw.apiName,
                        Tracked_Record_Types__c = rtString,
                        Active__c = true
                    );
                    histList.add(newHist);
                }
            }   
        }
        if(!histList.isEmpty()){
            upsert histList;
            histList = new List<History_Field_Configuration__c>();
            getObjectHistoryConfigData();
            PageReference pageRef = new PageReference('/apex/FieldUpdateConfig');
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have not made any changes. Please select fields to add or de-select fields you no longer wish to track. Click \'Cancel\' to return to the start page.'));
            return null;
        }
    }
    
    public pageReference resetView(){
        PageReference pageRef = new PageReference('/apex/FieldUpdateConfig');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private void getObjectHistoryConfigData(){
        histConfigList = [SELECT Id, Name, Active__c, Object_API_Name__c, Object_Name__c, Path_to_Case__c,
                            (SELECT Id, Name, Active__c, API_Field_Name__c, History_Object_Configuration__c, Tracked_Record_Types__c FROM History_Field_Configuration__r),
                            (SELECT Id, Name, Active__c, Attachment_Criteria__c, Attachment_Operator__c,  History_Object_Configuration__c, Type__c, Attorney_Client_Privilege__c, Not_Subject_to_PRA__c, Confidential__c FROM History_Field_Configuration1__r),
                            (SELECT Id, Name, Active__c, Activity_Status__c, Activity_Type__c, Tracked_Statuses__c, History_Object_Configuration__c FROM Activity_Configuration__r)
                          FROM History_Object_Configuration__c 
                          WHERE Active__c = true];
        availObjects = new List<SelectOption>();
        availObjects.add(new SelectOption('NONE', '--Select Object--'));
        for(History_Object_Configuration__c h : histConfigList){
            availObjects.add(new SelectOption(h.Object_API_Name__c, h.Object_Name__c));
        }
        if(rtMap == null){
            rtMap = new Map<String, List<RecordType>>();
            List<RecordType> rtList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType];
            for(RecordType r : rtList){
                if(r.SobjectType == 'DIR_Violation__c'){
                    //then what
                }
            }
            
            for(RecordType rt : rtList){
                List<RecordType> tempList;
                if(rtMap.containsKey(rt.SobjectType)){
                    tempList = rtMap.get(rt.SobjectType);
                    tempList.add(rt);
                    rtMap.put(rt.SobjectType, tempList);
                }
                else{
                    tempList = new List<RecordType>();
                    tempList.add(rt);
                    rtMap.put(rt.SobjectType, tempList);
                }
            }
        }
    }
    
    private Map<String, Schema.SObjectField> getObjectFields(String objName){
        SObjectType objectType = Schema.getGlobalDescribe().get(objName);
        Map<String, Schema.SObjectField> objFields = objectType.getDescribe().fields.getMap();
        return objFields;
    }

}