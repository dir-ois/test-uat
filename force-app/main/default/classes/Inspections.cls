public with sharing class Inspections {
    
    public List<Inspection_Questions__c> employerList {get;set;}
    public List<Inspection_Questions__c> employerDetail {get;set;}
    public List<Inspection_Questions__c> employerPrincipalList {get;set;}
    public List<Inspection_Questions__c> intervieweeList {get;set;}
    public List<Inspection_Questions__c> licenseList {get;set;}
    public List<Inspection_Questions__c> compensationList {get;set;}
    public List<Inspection_Questions__c> wageList {get;set;}
    public List<Inspection_Questions__c> iwcList {get;set;}
    public Map<Id, String> typeMap {get;set;}
    public Map<Id, String> textMap {get;set;}
    public Map<Id, String> numberMap {get;set;}
    public Map<Id, Boolean> checkboxMap {get;set;}
    public Map<Id, String> listValueMap {get;set;}
    public Map<Id, List<SelectOption>> itemsMap {get;set;}
    public Map<Id, Contact> dateMap {get;set;}
    public List<Inspection_Questions__c> allQuestions;
    public Boolean showError {get;set;}
    public String cid, rt;
    public List<DIR_Employee__c> employeeList {get;set;}
    public String typeValue;
    public String statusValue;
    public DIR_Case__c dc;
    public Boolean renderInspectionSelector {get;set;}
    
    public Inspections(){
        
        String uid = UserInfo.getUserId();
        String rtype = [Select Id From RecordType  Where SobjectType = 'DIR_Employee__c' and DeveloperName = 'DLSE_Employees'].Id;
        cid = ApexPages.currentPage().getParameters().get('CaseID');
        rt = ApexPages.currentPage().getParameters().get('RT');
        
        dc = [SELECT Id FROM DIR_Case__c WHERE Id =: cid];
        
        employeeList = new List<DIR_Employee__c>();
        employeeList = [SELECT Id FROM DIR_Employee__c WHERE User__c =: uid AND RecordTypeId =: rtype AND (Position__c = 'Deputy' OR Position__c = 'Senior Deputy') AND Active__c = true];
        
        //get number of existing inspections and restrict/set the inspection field to follow-up if one exists
        Integer inspectionCount = [select count() from DIR_Inspection__c where DIR_Case__c = :cid];
        renderInspectionSelector = true;
        
        if(inspectionCount > 0){
            renderInspectionSelector = false;
            statusValue = 'Follow-up';
        }
        else{
        statusValue = 'New';
        }
            
        
        
        if ((employeeList.size() == 0) || (employeeList.size() > 1))
            showError = true;
        else
            showError = false;
        
        system.debug('error:' + showError);
        
        typeMap = new Map<Id, String>();
        textMap = new Map<Id, String>();
        numberMap = new Map<Id, String>();
        checkBoxMap = new Map<Id, Boolean>();
        listValueMap = new Map<Id, String>();
        itemsMap = new Map<Id, List<SelectOption>>();
        dateMap = new Map<Id, Contact>();
        
        allQuestions = new List<Inspection_Questions__c>();
        employerList = new List<Inspection_Questions__c>();
        employerList = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'Primary Employer' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(employerList);
        
        employerDetail = new List<Inspection_Questions__c>();
        employerDetail = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'Primary Employer Detail' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(employerDetail);
        
        employerPrincipalList = new List<Inspection_Questions__c>();
        employerPrincipalList = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'Employer/Principle Information' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(employerPrincipalList);
        
        intervieweeList = new List<Inspection_Questions__c>();
        intervieweeList = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'Interviewee' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(intervieweeList);
        
        licenseList = new List<Inspection_Questions__c>();
        licenseList = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'License Information' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(licenseList);
        
        compensationList = new List<Inspection_Questions__c>();
        compensationList = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'Worker\'s Compensation Insurance Information' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(compensationList);
        
        iwcList = new List<Inspection_Questions__c>();
        iwcList = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'IWC Order' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(iwcList);
        
        wageList = new List<Inspection_Questions__c>();
        wageList = [SELECT Id, Inspection_Question__c, Response_Type__c, Response_Options__c, Source_Data__c, Update_Parent_Record__c FROM Inspection_Questions__c WHERE Inspection_Section__c = 'Wage Information' AND Active__c = true ORDER BY Sort_Order__c NULLS LAST];
        allquestions.addAll(wageList);
        
        typeMap = new Map<Id, String>();
        
        Set<String> fieldSet = new Set<String>();
        for (Inspection_Questions__c ie : allquestions){
            typeMap.put(ie.Id, ie.Response_Type__c);
            if ((ie.Source_Data__c != null) && (ie.Source_Data__c != ''))
                fieldSet.add(ie.Source_Data__c.toLowerCase());
        }
        
        String query;
        query = 'SELECT Id ';
        for (String s : fieldSet)
            query += ', ' + s;
        query += ' FROM DIR_Case__c WHERE Id =: cid';
        
        dc = database.query(query);
        Map<String, Schema.SObjectField> M = Schema.SObjectType.DIR_Case__c.fields.getMap();
        Map<String, String> valueMap = new Map<String, String>();
        for(String key : M.KeySet()){
            if (fieldSet.contains(key.toLowerCase()))
                valueMap.put(key.toLowerCase(), M.get(key).getDescribe().getName().toLowerCase());
        } 
        
        for (Inspection_Questions__c ie : allquestions){
            if (ie.Response_Type__c == 'Text'){
                if ((ie.Source_Data__c == null) || (ie.Source_Data__c == ''))
                    textMap.put(ie.Id, '');
                else {
                    if ((valueMap.containsKey(ie.Source_Data__c.toLowerCase())) && (M.get(ie.Source_Data__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.String)) {
                        if (dc.get(valueMap.get(ie.Source_Data__c.toLowerCase())) != null) {
                            textMap.put(ie.Id, (string)dc.get(valueMap.get(ie.Source_Data__c.toLowerCase())));
                        } else {
                            textMap.put(ie.Id, '');
                        }
                    } else {
                        textMap.put(ie.Id, '');
                    }
                }
            }
            if (ie.Response_Type__c == 'Number'){
                if ((ie.Source_Data__c == null) || (ie.Source_Data__c == ''))
                    numberMap.put(ie.Id, '');
                else{
                    if ((valueMap.containsKey(ie.Source_Data__c.toLowerCase())) && (valueMap.get(ie.Source_Data__c.toLowerCase()).isNumeric())) {
                        if (dc.get(valueMap.get(ie.Source_Data__c.toLowerCase())) != null) {
                            numberMap.put(ie.Id, (string)dc.get(valueMap.get(ie.Source_Data__c.toLowerCase())));
                        } else {
                            numberMap.put(ie.Id, '');
                        }
                    } else {
                        numberMap.put(ie.Id, '');
                    }
                }
            }
            if (ie.Response_Type__c == 'Checkbox'){ 
                if ((ie.Source_Data__c == null) || (ie.Source_Data__c == ''))
                    checkboxMap.put(ie.Id, false);
                else{
                    if ((valueMap.containsKey(ie.Source_Data__c.toLowerCase())) && (M.get(ie.Source_Data__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.Boolean)) {
                        if (dc.get(valueMap.get(ie.Source_Data__c.toLowerCase())) != null) {
                            checkboxMap.put(ie.Id, Boolean.valueOf((string)dc.get(valueMap.get(ie.Source_Data__c.toLowerCase()))));
                        } else {
                            checkboxMap.put(ie.Id, false);
                        }
                    } else {
                        checkboxMap.put(ie.Id, false);
                    }
                }
            }
            if (ie.Response_Type__c == 'Picklist'){
                List<String> valuesList = new List<String>();
                valuesList = ie.Response_Options__c.split('\r\n', 0);
                for (String s : valuesList){
                    if (!itemsMap.containsKey(ie.Id)){
                        listValueMap.put(ie.Id, s);
                        itemsMap.put(ie.Id, new List<selectOption>{new selectOption(s, s)});
                    }
                    else
                        itemsMap.get(ie.Id).add(new selectOption(s, s));
                    system.debug('itemsmap:' + itemsMap);
                }
            }
            if (ie.Response_Type__c == 'Date'){
                if ((ie.Source_Data__c == null) || (ie.Source_Data__c == '')) {
                    Contact dummyContact = new Contact();
                    dateMap.put(ie.Id, dummyContact);
                } else {
                    Contact dummyContact = new Contact();
                    if (valueMap.containsKey(ie.Source_Data__c.toLowerCase())) {
                        if (dc.get(valueMap.get(ie.Source_Data__c.toLowerCase())) != null) {
                            try {
                                dummyContact.BirthDate = (date)dc.get(valueMap.get(ie.Source_Data__c.toLowerCase()));
                            } catch (Exception ex) {
                            }
                        }
                    }
                    dateMap.put(ie.Id, dummyContact);
                }
            }
        }
        
        if (employeeList.size() > 0)
            inspection = new DIR_Inspection__c(DIR_Case__c = cid, Deputy__c = employeeList.get(0).Id, Inspection_Date__c = date.today());
        else
            inspection = new DIR_Inspection__c(DIR_Case__c = cid, Inspection_Date__c = date.today());
        
    }
    
    public String gettypeValue() {
        
        return typeValue;
        
    }
    
    public String getstatusValue() {
        
        return statusValue;
        
    }
                    
    public void settypeValue(String typeValue) { this.typeValue = typeValue; }
    public void setstatusValue(String statusValue) { this.statusValue = statusValue; }
    
    public List<SelectOption> gettypeItems() {
        
        List<SelectOption> options = new List<SelectOption>();
        
       Schema.DescribeFieldResult fieldResult = DIR_Inspection__c.Inspection_Type__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options; 
        
    }
   /* 
    public List<SelectOption> getStatusItems() {
        
        List<SelectOption> options1 = new List<SelectOption>();
        
       Schema.DescribeFieldResult fieldResult = DIR_Inspection__c.Inspection_New_Follow_Up__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options1.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options1; 
        
    }
    
*/
    
    public DIR_Inspection__c inspection { get; set; }
    
    
    public pageReference save(){
        
        Savepoint sp = Database.setSavepoint();
        
        inspection.Inspection_Type__c = typeValue;
        inspection.Inspection_New_Follow_Up__c = statusValue;
        insert inspection;
        
        
        Boolean numberError = false;
        List<Inspection_Data__c> dataList = new List<Inspection_Data__c>();
        for (Inspection_Questions__c iq : allQuestions){
            Inspection_Data__c id = new Inspection_Data__c(Inspection__c = inspection.Id, Inspection_Question__c = iq.Id);
            if (typeMap.get(iq.Id) == 'Text')
                id.Response__c = textMap.get(iq.Id);
            if (typeMap.get(iq.Id) == 'Number'){
                if (numberMap.get(iq.Id).isNumeric())
                    id.Response__c = numberMap.get(iq.Id);
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The response for question: ' + iq.Inspection_Question__c + ' must have a numeric value.');//Same old drama 
                    ApexPages.addMessage(myMsg);
                    numberError = true;
                }
            }
            if (typeMap.get(iq.Id) == 'Checkbox')
                id.Response__c = String.valueOf(checkboxMap.get(iq.Id));
            if (typeMap.get(iq.Id) == 'Picklist')
                id.Response__c = listValueMap.get(iq.Id);
            if (typeMap.get(iq.Id) == 'Date')
                id.Response__c = String.valueOf(dateMap.get(iq.Id).BirthDate);
            dataList.add(id);
            
            // Save the case fields
            if (iq.Update_Parent_Record__c)
                dc.put(iq.Source_Data__c, id.Response__c);
        }
        
        insert dataList;
        
        update dc;
        
        if (numberError == false){
            pageReference pr = new pageReference('/' + cid);
            pr.setRedirect(true);
            return pr;
        }
        Database.rollback(sp);
        return null;
        
    }
    
    public pageReference cancel(){
        
        pageReference pr = new pageReference('/' + cid);
        pr.setRedirect(true);
        return pr;
        
    }

}