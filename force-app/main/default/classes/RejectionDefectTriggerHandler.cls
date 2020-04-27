/********************************************************************************************************
Name:  RejectionDefectTriggerHandler.cls
Author:  vertiba
Date:  11/26/2018
Modified by: 
Date:
Test class: 

Behavior: 170016,170017
********************************************************************************************************/
public without sharing class RejectionDefectTriggerHandler{
    
    List<License_Registration__c> regToUpdate = new List<License_Registration__c>();

    
    public void afterInsert(List<Rejection_Defect__c> newList){
        //if(checkRecursive.runOnce())
       // UpdateRegistration(newList);
    }
    public void afterUpdate(List<Rejection_Defect__c> newList, Map<Id,Rejection_Defect__c > oldMap){
        //if(checkRecursive.runOnce())
        UpdateRegistration(newList);
    }
    public void afterDelete(List<Rejection_Defect__c> oldList){
        //if(checkRecursive.runOnce())
        UpdateRegistration(oldList);
    }
    
    public void UpdateRegistration(List<Rejection_Defect__c> newList){
        System.debug('in update regi');
        Logger.push('UpdateRegistration','RejectionDefectTriggerHandler');
        Set<Id> regids = new Set<Id>();
        Map<Id,Set<String>> regRejDefMap = new Map<Id,Set<String>>();
        Set<String> sectionLst = new Set<String>();
        Map<String,String> secFeildMap = new Map<String,String>();
        
        for(Rejection_Defect__c rd: newList){
            regIds.add(rd.Registration__c);  
            if(trigger.isDelete)
                sectionLst.add(rd.Section__c);
        }
     
         //fetch metadata
         for(Registration_Defects_Mapping__mdt rdm: [Select MasterLabel,Field_API__c FROM Registration_Defects_Mapping__mdt])
             secFeildMap.put(rdm.MasterLabel,rdm.Field_API__c);

         if(!secFeildMap.isEmpty()){
         Logger.debug('secFeildMap***'+secFeildMap);
         
        string query = 'Select ID,VIP_Template_Status__c, AgentAuthorizationDA__c,AgreementsDA__c,CompanyContactDA__c,CompanyFinancesDA__c,CompanyInformationDA__c,CompanyLocationsDA__c,CompanyManagersDA__c,CompanyNameTypeDA__c,CompanyOwnersDA__c, CompanyTypeRenewalDA__c,DisclaimerDA__c,EducationDA__c, FeesDA__c,FollowupQuestionsDA__c,QuestionnaireDA__c,WCIDocumentationDA__c,CompanyAddressInformationDA__c,WorkersCompDA__c,LocationDocumentationDA__c,PermitApplicantDA__c,LiveScanDA__c,QualifyingQuestionDA__c, ParentGuardianInformationDA__c, UploadDocumentDA__c, MedicalInformationDA__c, MinorInformationDA__c, RegistrationDurationDA__c, SchoolInformationDA__c, ';
        if(trigger.isInsert)
            query += '(SELECT ID,Applies__c, Resolved__c,Registration__c,Section__c FROM Rejection_Defects__r WHERE ID IN:newList )';
        if(trigger.isUpdate)
            query += '(SELECT ID,Applies__c, Resolved__c,Registration__c,Section__c FROM Rejection_Defects__r)';
        if(trigger.isDelete)
            query += '(SELECT ID,Applies__c, Resolved__c,Registration__c,Section__c FROM Rejection_Defects__r WHERE Section__c IN: sectionLst)';
        query += 'FROM License_Registration__c WHERE Id IN: regIds';
        
            //fetch all the related registrations
            Map <Id, License_Registration__c> regLst = new Map<Id, License_Registration__c>(
                (List<License_Registration__c>)Database.query(query)
            );
            
                                               
            for(License_Registration__c reg : regLst.Values()){
                if(!reg.Rejection_Defects__r.isEmpty()){
                    
                    for(Rejection_Defect__c rd:reg.Rejection_Defects__r){
                        //collect all those rejection defects which applies and not resolved
                        
                        if(rd.Applies__c && !rd.Resolved__c){
                            if(!regRejDefMap.ContainsKey(rd.Registration__c)){
                                Set<String> secLst = new Set<String>{rd.Section__c};
                                regRejDefMap.put(rd.Registration__c,secLst); 
                            }else{              
                                Set<String> secLst = regRejDefMap.get(rd.Registration__c);
                                secLst.add(rd.Section__c);
                                regRejDefMap.put(rd.Registration__c,secLst); 
                            }
                        }
                        
                    }
                }                
            }
            System.debug('regRejDefMap--'+regRejDefMap);
        if(trigger.isInsert || trigger.isUpdate){
            for(License_Registration__c reg : regLst.Values()){
                
                if(!reg.Rejection_Defects__r.isEmpty()){
                    for(Rejection_Defect__c rd:reg.Rejection_Defects__r){
                        if(regRejDefMap.containsKey(reg.Id)){
                            if(regRejDefMap.get(reg.Id).Contains(rd.Section__c)){
                             //make it true
                                updateCheckbox(reg, secFeildMap.get(rd.Section__c), TRUE);
                            }else{
                                //make it false   
                                updateCheckbox(reg, secFeildMap.get(rd.Section__c), FALSE);
                            }
                        }
                        else{
                         //make it false
                             //system.debug(Logginglevel.INFO,'rd.Section__c***'+rd.Section__c);
                            updateCheckbox(reg, secFeildMap.get(rd.Section__c), FALSE);
                        }
                         
                    }
                }
                
            }
        }else if(trigger.isDelete){
            
            for(Rejection_Defect__c rd: newList){
                if(regRejDefMap.ContainsKey(rd.Registration__c)){
                    if(regRejDefMap.get(rd.Registration__c).Contains(rd.Section__c)){
                        //make it true
                        updateCheckbox(regLst.get(rd.Registration__c), secFeildMap.get(rd.Section__c), TRUE);
                    }else{
                        //make it false
                        updateCheckbox(regLst.get(rd.Registration__c), secFeildMap.get(rd.Section__c), FALSE);
                    }
                }else{
                    //make it false
                    updateCheckbox(regLst.get(rd.Registration__c), secFeildMap.get(rd.Section__c), FALSE);
                    
                }
            }
        }
        //If list not empty, update the registrations
      }      
      system.debug('regToUpdate--'+regToUpdate);
            if(!regToUpdate.isEmpty()){
                update regToUpdate;
            }
      Logger.pop();
    }
    public void updateCheckbox(License_Registration__c reg, String Section, Boolean defectIdentified){
      Logger.push('updateCheckbox','RejectionDefectTriggerHandler');
        System.debug('updateCheckbox');
        System.debug(Section);
        System.debug(defectIdentified);
        //make it true/false
        try {
            if(Section != null && reg.get(Section) != defectIdentified){
                reg.put(Section,defectIdentified);

                if(!regToUpdate.Contains(reg))
                    regToUpdate.add(reg);
            }
        } catch(DmlException de) {
            System.debug(de.getMessage());
        }

    Logger.pop();
    }
}