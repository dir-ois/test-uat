/********************************************************************************************************
    Name:  allAttPlus.trigger
    Author:  Mirela Chituc (mirela.chituc@vertiba.com)
    Date:  08/30/2017
    Modified by: Kavya Somashekar(12/02/2018) for 170018 and 170019
    Date:
    Test class: allPlusTest.cls

    Behavior UpdateSubmissionType(): After insert, after update complete Submission_Detail_Type__c (multiple picklist field) on DIR_Case__c object
    based on the types of the related Attachments_Plus__c records 

    Behavior SetPubliclyAccessible(): Before insert, before update mark Publicly_Accessible__c field as TRUE when any of the following are not checked on the same record:
    Confidential, Client-Attorney Privilege, IFP Claimed, Not Subject to PRA
     
    Behavior UpdateRegistration():Before insert, before update registration's checkboxes based on whether the attachmnet has files associated or not
    ********************************************************************************************************/

    //trigger allAttPlus on Attachments_Plus__c (before insert, after insert, before update, after update, after delete) {
    trigger allAttPlus on Attachments_Plus__c (after delete, after update, after insert) {
        
        List<License_Registration__c> regListToUpdate =new List<License_Registration__c>();

        if ((trigger.isBefore && (trigger.isUpdate || trigger.isInsert))) {
            //SetPubliclyAccessible();
        }
        
        if (trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){ 
           // UpdateSubmissionType();
           
            UpdateRegistration(trigger.new);
        }
        if(trigger.isAfter && trigger.isDelete){
            UpdateRegistration(trigger.old);
        }

       /*
       public void SetPubliclyAccessible() {
            for(Attachments_Plus__c rlcv : trigger.new){
                rlcv.Publicly_Accessible__c = false;
                if(rlcv.Confidential__c == true || rlcv.Attorney_Client_Privilege__c == true || rlcv.IFP_Claimed__c == true || rlcv.Not_Subject_to_PRA__c == true){
                    rlcv.Publicly_Accessible__c = false;
                }
            }
        }
        
       
           
        public void UpdateSubmissionType() {
            List<String> casesIds = new List<String>();
            
            Set<String> subTypeForPAGACases = new Set<String>();
            subTypeForPAGACases.add('Cure Dispute');
            subTypeForPAGACases.add('Court Complaint');
            subTypeForPAGACases.add('Proposed Settlement');
            subTypeForPAGACases.add('PAGA Notice');
            subTypeForPAGACases.add('Other PAGA Document');
            subTypeForPAGACases.add('Employer Response/Cure');
            subTypeForPAGACases.add('Amended Notice');
            subTypeForPAGACases.add('Court Order/Judgment');

            if(trigger.isDelete) {
                for(Attachments_Plus__c rlcv : trigger.old){
                    if(rlcv.Case_Management__c != null)
                        casesIds.add(rlcv.Case_Management__c);
                    if(!String.isEmpty(rlcv.Record_ID__c))
                        casesIds.add(rlcv.Record_ID__c);
                }
            } else {
                for(Attachments_Plus__c rlcv : trigger.new){
                    if(rlcv.Case_Management__c != null)
                        casesIds.add(rlcv.Case_Management__c);
                    if(!String.isEmpty(rlcv.Record_ID__c))
                        casesIds.add(rlcv.Record_ID__c);
                }
            }
            if(casesIds.size() > 0) {
                Map<Id, DIR_Case__c> casesMap = new Map<Id, DIR_Case__c>([
                    SELECT Id, Submission_Detail_Type__c 
                    FROM DIR_Case__c
                    WHERE Id IN: casesIds
                ]);
                Map<Id, String> caseSubmissionMap = new Map<Id, String>();
                for(Id cId: casesMap.keySet()) {
                    DIR_Case__c currentCase = casesMap.get(cId); 
                    if(!caseSubmissionMap.containsKey(cId))
                        caseSubmissionMap.put(cId, '');  
                }
                
                List<Attachments_Plus__c> allAttPlusRecords = [SELECT Id, Type__c, Case_Management__c 
                    FROM Attachments_Plus__c WHERE (Case_Management__c IN: casesIds OR Record_ID__c IN: casesIds) AND Publicly_Accessible__c = true AND Type__c IN: subTypeForPAGACases];
            
                for(Attachments_Plus__c aplus : allAttPlusRecords){
                    Set<String> submissionTypeString = new Set<String>();
                    if(caseSubmissionMap.containsKey(aplus.Case_Management__c)) {   
                        String stString = caseSubmissionMap.get(aplus.Case_Management__c);
                        if(!String.isEmpty(stString)) {
                            List<String> parts = stString.split(';');
                            for(String s: parts) {
                                if(!String.isEmpty(s))
                                    submissionTypeString.add(s+';');
                            }
                        } 
                    }
                    
                    if(!String.isEmpty(aplus.Type__c)) 
                        if(subTypeForPAGACases.contains(aplus.Type__c))
                            submissionTypeString.add(aplus.Type__c);
                    String sSType = '';
                    for(String s: submissionTypeString) {
                        sSType += s + ';';
                    }
                    
                    caseSubmissionMap.put(aplus.Case_Management__c, sSType);   
                }
                
                for(Id i: caseSubmissionMap.keySet()) {
                    String ss = caseSubmissionMap.get(i);
                    List<String> x = ss.split(';');
                    Set<String> setValues = new Set<String>();
                    for(String y: x) {
                        if(!setValues.contains(y))
                            setValues.add(y);
                    }
                    String vType = '';
                    for(String z: setValues) {
                        vType += z + ';';
                    }
                    caseSubmissionMap.put(i, vType);
                }
                
                List<DIR_Case__c> DIRCasesToUpdate = new List<DIR_Case__c>();
                for(Id caseId: casesMap.keySet()) {
                    DIR_Case__c currentDirCase = casesMap.get(caseId);
                    currentDirCase.Submission_Detail_Type__c = caseSubmissionMap.get(caseId);
                    DIRCasesToUpdate.add(currentDirCase);
                }
                
                if(DIRCasesToUpdate.size() > 0)
                    update DIRCasesToUpdate;
            }
        }
        */
        public void UpdateRegistration(List<Attachments_Plus__c > newLst){
       //  if(checkRecursive.runOnce()){
         Map<Id,Set<String>> regAttPlusMap = new Map<Id,Set<String>>();
         Set<Id> regids = new Set<Id>();
         Set<String> sectionLst = new Set<String>();
         Map<Id, String> sectionMap = new Map<Id, String>(); 
         Map<String,String> secFeildMap = new Map<String,String>();
         
         //fetch metadata
         for(Registration_Attachments_Mapping__mdt ram: [Select MasterLabel,FieldAPI__c FROM Registration_Attachments_Mapping__mdt])
         secFeildMap.put(ram.MasterLabel,ram.FieldAPI__c);
         
         system.debug(LoggingLevel.INFO,'secFeildMap***'+secFeildMap);
         if(!secFeildMap.isEmpty()){
         //Get the name of each section related to documnets
         List<Registration_Template_Mapping__mdt> custMeta =[select id,Template_Id__c from Registration_Template_Mapping__mdt where developername='Car_Wash'];
         if(!custMeta.isEmpty()){
             /*for(VIPForm__VIP_Category__c obj : [SELECT Name,VIPForm__Name_Displayed__c, Id 
                                                    FROM VIPForm__VIP_Category__c 
                                                    WHERE VIPForm__Name_Displayed__c IN: secFeildMap.keyset() 
                                                    AND VIPForm__Template__c = : custMeta[0].Template_Id__c]
                                                    AND (NOT Name like '%Renewal%') )
             {
                if(!obj.Name.contains('Renewal'))
                    sectionMap.put(obj.Id, obj.VIPForm__Name_Displayed__c);
             }   
            */
            for(Attachments_Plus__c ap: newLst){
                regIds.add(ap.Registration__c);   
                if(trigger.IsDelete){
                    sectionLst.add(ap.VIP_Form_Section_Name_Display__c);
                }       
            }   
            //fetch all the registrations and its related attachments
            
            
             string query = 'SELECT Id,WCIDocumentationDocuments__c, LocationDocumentationDocuments__c, CompanyInformationDocuments__c,CompanyFinancesCWDocuments__c,CompanyManagersDocuments__c,CompanyOwnersDocuments__c,CPSLiveScanDocuments__c,';
            //if(trigger.isInsert)
            //    query += '(SELECT Id, Name, Type__c, Registration__c, Number_of_Attachments__c,VIP_Form_Section__c, VIP_Form_Section_Name_Display__c ,Attachment_Required__c,VIP_Form_Section__r.Name FROM Submission_Detail__r WHERE ID IN:newLst)';
            if(trigger.isUpdate || trigger.isInsert)
                query += '(SELECT Id, Name, Type__c, Registration__c, Number_of_Attachments__c,VIP_Form_Section__c, VIP_Form_Section_Name_Display__c ,Attachment_Required__c,VIP_Form_Section__r.Name FROM Submission_Detail__r WHERE Attachment_Required__c =TRUE AND (Number_of_Attachments__c = 0 OR Number_of_Attachments__c = NULL)) ';
            if(trigger.isDelete)
                query += '(SELECT Id, Name, Type__c, Registration__c, Number_of_Attachments__c,VIP_Form_Section__c, VIP_Form_Section_Name_Display__c ,Attachment_Required__c,VIP_Form_Section__r.Name FROM Submission_Detail__r WHERE VIP_Form_Section_Name_Display__c IN: sectionLst AND Attachment_Required__c =TRUE AND (Number_of_Attachments__c = 0 OR Number_of_Attachments__c = NULL)) ';
            
            query += 'FROM License_Registration__c WHERE Id IN: regIds';
            
            
            //fetch all the related registrations
            Map <Id, License_Registration__c> regLst = new Map<Id, License_Registration__c>(
                (List<License_Registration__c>)Database.query(query)
            );
                
            for(License_Registration__c reg:regLst.values()){
                for(Attachments_Plus__c ap: reg.Submission_Detail__r){
                //collect all those records which doesnt have attached files
                
                   // if(ap.Attachment_Required__c && (ap.Number_of_Attachments__c == 0 || ap.Number_of_Attachments__c == NULL)){                 
                        if(!regAttPlusMap.ContainsKey(ap.Registration__c)){  
                            Set<String> secLst = new Set<String>{ap.VIP_Form_Section_Name_Display__c };
                            regAttPlusMap.put(ap.Registration__c,secLst); 
                        }else{              
                            Set<String> secLst = regAttPlusMap.get(ap.Registration__c);
                            secLst.add(ap.VIP_Form_Section_Name_Display__c );
                            regAttPlusMap.put(ap.Registration__c,secLst); 
                        }
                   // }
                }
            }
            
            if(trigger.isInsert || trigger.isUpdate){
                for(Id regId: regLst.keyset()){
                    for(String secId: secFeildMap.keyset()){
                        if(regAttPlusMap.containsKey(regId)){
                            if(regAttPlusMap.get(regId).Contains(secId)){
                                //set this section checkbox to false
                                updateCheckbox(regLst.get(regId), secFeildMap.get(secId), FALSE); 
        
                            }else{
                                //set this section checkbox to true
                                
                                updateCheckbox(regLst.get(regId), secFeildMap.get(secId), TRUE);
                            }
                        }else{
                            //set this section checkbox to true
                            
                            updateCheckbox(regLst.get(regId), secFeildMap.get(secId), TRUE);
                        }
                    }
                    
                }
            }else{
                for(Attachments_Plus__c ap: newLst){
                    if(regAttPlusMap.ContainsKey(ap.Registration__c)){
                        if(regAttPlusMap.get(ap.Registration__c).Contains(ap.VIP_Form_Section_Name_Display__c)){
                            //make it false
                            updateCheckbox(regLst.get(ap.Registration__c), secFeildMap.get(ap.VIP_Form_Section_Name_Display__c), FALSE);
                        }else{
                            //make it true
                            updateCheckbox(regLst.get(ap.Registration__c), secFeildMap.get(ap.VIP_Form_Section_Name_Display__c), TRUE);
                        }
                    }else{
                        //make it true
                        updateCheckbox(regLst.get(ap.Registration__c), secFeildMap.get(ap.VIP_Form_Section_Name_Display__c), TRUE);
                        
                    }
                }
            }
                
            if(!regListToUpdate.isEmpty()){                
                Update regListToUpdate;
            }
            
            }
            }
       // }
        }
        public void updateCheckbox(License_Registration__c reg, String Section, Boolean noAttachment){
                
                //set this section checkbox to true
                    if(reg.get(Section) != noAttachment){                                
                        reg.put(Section,noAttachment);
                        
                        if(!regListToUpdate.Contains(reg))
                        regListToUpdate.add(reg);
                        
                    }
                                    
        }
    }