/********************************************************************************************************
Name:  LicenseRegistrationAllHandler.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  10/03/2017
Modified by: 
Date:
Trigger: LicenseRegistrationAll.trigger
Test class: LicenseRegistrationAllTest.cls

Behavior: After Insert - CreateRegistrationQuestions() - When a registration is CREATED, query for all Question Rule records for those records where the 
Registration record type name = Registration Record Type on the question rule, active is true. 
Create a Registration Question record setting the Registration ID and the Question ID accordingly and setting
the Record Type of the Registration Question = Answer type from the question bank.

CreateAttachmentNotesOnInsert() 
When a new Registration record is created, query the system for Registration_Attachment_Bank__c 
records where the value in Registration_Type__c = the initiating Registration record's Record Type Name.
For each matching record, create an Attachments_Plus__c record with the Registration__c field populated with the
initiating Registration record. 

CreateRejectionDefect()
Write a trigger that queries Defect__c records when a Registration Status = Submitted. 
For each returned Defect__c record, create a child Rejection_Defect__c record that pulls field values from it's 
matching Defect__c record

CreateRejection() 
When the reviewer sets the Registration status to 'Pending / Defect", the following logic should fire:
1.Create a Rejection__c record and populate its Id on the Rejection__c lookup for all Rejection_Defect__c records 
that are child records of the initiation Registration record where Applies__c = TRUE
2.Delete all Rejection_Defect__c records that are child records of the initiation Registration record where 
Applies__c = FALSE
********************************************************************************************************/
@SuppressWarnings('sf:ClassWithOnlyPrivateConstructorsShouldBeFinal')
public without sharing class LicenseRegistrationAllHandler {
    
    private static LicenseRegistrationAllHandler classInstance = null;
    private LicenseRegistrationAllHandler() {
        stopRecursion = false;
    }
    
    public static LicenseRegistrationAllHandler getInstance(){
        if (null == classInstance) {
            classInstance = new LicenseRegistrationAllHandler();
        }
        return classInstance;
    }
    public Boolean stopRecursion {get; set;}
    static Map<Id,RecordType> recTypeMap = new Map<Id,RecordType>([select id,DeveloperName,Name from RecordType Where SobjectType = 'License_Registration__c']);  
    
    //Handler for before insert methods
    public void onBeforeInsert(list<License_Registration__c> newList) {
        CheckEntityLicenceNumbers(newList);
        setFormTemplate(newList);
        Logger.pop();
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      Handler for after insert methods
* @VersionHistory   20190104_HB : Changes for Registrations Cloned after renewals
*****************************************************************************/
    public void onAfterInsert(list<License_Registration__c> newList , map<id, License_Registration__c> newMap) {
        Logger.push('onAfterInsert','LicenseRegistrationAllHandler');
        // for each License_Registration__c record created populate the map
        // RecordTypeNames - map to keep License_Registration__c RecordType.Name (key) and Id (value)
        Map<String, List<License_Registration__c>> notimportedrecordTypeNames = new Map<String, List<License_Registration__c>>();
        Map<String, List<License_Registration__c>> allrecordTypeNames = new Map<String, List<License_Registration__c>>();
        Map<String, List<License_Registration__c>> clonedrecordTypeNames = new Map<String, List<License_Registration__c>>();
        for(License_Registration__c l: newList) {
            String rtName = recTypeMap.get(l.RecordTypeId).Name;
            if(l.Imported_From__c == NULL) {
                if(!notimportedrecordTypeNames .containsKey(rtName)) {
                    notimportedrecordTypeNames .put(rtName, new List<License_Registration__c>());
                }
                notimportedrecordTypeNames .get(rtName).add(l);
            }
            if(!allrecordTypeNames.containsKey(rtName)) {
                allrecordTypeNames.put(rtName, new List<License_Registration__c>());
            }
            allrecordTypeNames.get(rtName).add(l);
            if(l.Original_Registration__c != null)
            {
                if(!clonedrecordTypeNames .containsKey(rtName)) {
                    clonedrecordTypeNames .put(rtName, new List<License_Registration__c>());
                }
                clonedrecordTypeNames .get(rtName).add(l);
            }
            
            
        }
        upsertRegistrationQuestions(notimportedrecordTypeNames );
        createEducation(notimportedrecordTypeNames );
        CreateAttachmentNotesOnInsert(allrecordTypeNames);
        CreateAttachmentNotesOnClone(clonedrecordTypeNames);
        CreateDummyRegAccounts(newList);
        Logger.pop();
        
    }
    
    //Handler for 
    public void onAfterClone(list<License_Registration__c> newList) {
        Logger.push('onAfterClone','LicenseRegistrationAllHandler');
        //CreateAttachmentNotesOnClone(newList);
        Logger.pop();
    }
    
    //Handler for before Update methods
    public  void onBeforeUpdate(list<License_Registration__c> newList, map<id, License_Registration__c> newMap , map<id, License_Registration__c> oldMap) {
        Logger.push('onBeforeUpdate','LicenseRegistrationAllHandler');  
        //System.debug('Entering onBeforeUpdate' + newMap.keyset());
        if(stopRecursion == null || !stopRecursion)
        {
            
            clearFieldOnReview(newList, oldMap);
            createRejectionBeforeUpdate(newList, oldMap);
            CheckTwelveMonthRule(newMap);
            CheckEntityLicenceNumbers(newList);
            CreateAccount(newList, oldMap);
            AutoApproveTempEWPRegistration(newList, oldMap);
            LRHandlerHelper.getInstance().isExistingPermitHolder(newList, oldMap);
            LRHandlerHelper.getInstance().CheckValidRegistrationAge(newList, oldMap);
            updateIsSkipMedicalComponent(newList, oldMap);
            updateEffectiveExpirationDate(newList, oldMap);            
        }
        Logger.debug('Exiting onBeforeUpdate: ' + newMap.keyset());
        Logger.pop();
    }
    //Handler for after Update methods
    public void onAfterUpdate(list<License_Registration__c> newList, map<id, License_Registration__c> newMap,  map<id, License_Registration__c> oldMap) {
        //System.debug('LRAH onAfterUpdate');
        Logger.debug('Entering onAfterUpdate' + newMap.keyset());
        if(stopRecursion == null || !stopRecursion)
        {
            
            // if(checkRecursive.runOnce()){
            stopRecursion = true;
            //LRHandlerAccountLocations.getInstance().CreateAccountsAndLocations(newList, oldMap);
            LRHandlerChangeSectionStatus changeSectionStatus = LRHandlerChangeSectionStatus.getInstance();
            changeSectionStatus.ChangeSectionStatusOnUpdate(newList, oldMap);
            
            publishCreateAccountsAndLocations(newList, oldMap);
            CreateAttachmentNotesOnUpdate(newList, oldMap);
            CreateRejectionDefect(newList, oldMap);
            CreateRejectionAfterUpdate(newList, oldMap);
            RegistrationApproved(newList, oldMap);
            CreateRegistrationAccount(newList, oldMap);
            CreateDummyRegAccounts(newList);
            LRHandlerCreateFees.getInstance().CreateFees(newList,newMap, oldMap);
            AssignChargentLicense(newList, oldMap);
            publishCreateLR(newList, oldMap);
            
            
            Map<String, List<License_Registration__c>> recordTypeNames = new Map<String, List<License_Registration__c>>();
            for(License_Registration__c l : newList) {
                String rtName = recTypeMap.get(l.RecordTypeId).Name;
                if((oldMap == null || (l.recreate_Questions__c && !oldMap.get(l.Id).recreate_Questions__c)) && l.Imported_From__c == NULL) 
                {
                    if(!recordTypeNames.containsKey(rtName)) {
                        recordTypeNames.put(l.RecordType.Name, new List<License_Registration__c>());
                    }
                    recordTypeNames.get(rtName).add(l);
                }
                
            }
            if(!recordTypeNames.isEmpty())
            {
                upsertRegistrationQuestions(recordTypeNames);
                
            }
            stopRecursion = false;
        }
        Logger.debug('Exiting onAfterUpdate: ' + newMap.keyset());
        Logger.pop();
        
    }
    
    //Handler for before Deletes methods
    public  void onBeforeDelete(list<License_Registration__c> oldList , map<id, License_Registration__c> oldMap) {
        
        
        
    }
    //Handler for after Deletes methods
    public  void onAfterDelete(List<License_Registration__c> oldList , Map<id, License_Registration__c> oldMap) {
        
    }
    
    private void CreateAccount(List<License_Registration__c> newList, Map<Id, License_Registration__c> oldMap) {
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        List<Account> newAccounts = new List<Account>();
        List<Address__c> newLocations = new List<Address__c>();
        Map<String, List<String>> configMap = new Map<String, List<String>>();
        List<License_Registration__c> registrations = new List<License_Registration__c>();
        Map<Id, Account> accountsByIds = new Map<Id, Account>();
        
        List<Account_Creation_Config__mdt> configs = [
            SELECT Record_Type__c, Status__c
            FROM Account_Creation_Config__mdt
        ];
        
        for (Account_Creation_Config__mdt c : configs) {
            configMap.put(c.Record_Type__c, c.Status__c.split(','));
        }
        
        for (License_Registration__c r : newList){
            if (r.accAlreadyCreated__c == false &&
                configMap.get(r.Record_Type_Name__c) != null &&
                configMap.get(r.Record_Type_Name__c).contains(r.Status__c) &&
                r.Status__c != oldMap.get(r.Id).Status__c) {
                    registrations.add(r);
                }
        }
        
        for (License_Registration__c reg : registrations) {
            Account newAccount = new Account();
            
            if (reg.Company_Type__c == 'Sole Proprietorship') {
                newAccount.RecordTypeId = personRecordTypeId;
                newAccount.LastName = reg.Legal_Entity_Name__c;
            } else  {
                newAccount.RecordTypeId = businessRecordTypeId;
                newAccount.Name = reg.Legal_Entity_Name__c;
            }
            
            newAccount.Entity_Type__c = reg.Company_Type__c;
            newAccount.ShippingStreet = reg.Physical_Business_Address_Line_1__c + reg.Physical_Business_Address_Line_2__c;
            newAccount.ShippingCity = reg.Physical_Business_City__c;
            newAccount.ShippingState = reg.Physical_Business_State__c;
            newAccount.ShippingPostalCode = reg.Physical_Business_Postal_Code__c;
            
            newAccounts.add(newAccount);
            accountsByIds.put(reg.Id, newAccount);
        }
        
        insert newAccounts;
        
        for (License_Registration__c reg : registrations) {
            reg.accAlreadyCreated__c = true;
            reg.Account__c = accountsByIds.get(reg.Id).Id;
        }
        
        for (Account a : newAccounts) {
            if (!a.Registration__r.Mailing_Address_Same_as_Physical__c) {
                Address__c location = new Address__c(Type__c = 'Mailing Address');
                
                location.Address__c = a.Registration__r.Mailing_Address_Line_1__c;
                location.Address_2__c = a.Registration__r.Mailing_Address_Line_2__c;
                location.City__c = a.Registration__r.Mailing_City__c;
                location.State__c = a.Registration__r.Mailing_State__c;
                location.Country__c = a.Registration__r.Mailing_Country__c;
                location.Zip_Code__c = a.Registration__r.Mailing_Postal_Code__c;
                location.Entity__c = a.Id;
                
                newLocations.add(location);
            }
        }
        
        insert newLocations;
    }
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19            
* @description      Method gets the last audit number, increments it, mods by 10 and sets the new audit number for new renewal applications
* @Version History  20181219_HB : Moved the code to Before Insert from After Insert to avoid an extra DML 
******************************************************************************/
    private static void populateAuditNumber(list<License_Registration__c> newList) {
        Logger.push('populateAuditNumber','LicenseRegistrationAllHandler');
        Logger.debug('######## Beginning setting the audit number for the registration');
        Set<License_Registration__c> LicenseRegistrations = new Set<License_Registration__c>();
        
        for(License_Registration__c l: newList) {
            if(l.Renewal__c && l.Audit_Number__c == NULL && l.Imported_From__c == NULL){
                LicenseRegistrations.add(l);  
            }
        }
        if(!LicenseRegistrations.isEmpty()) {
            Logger.debug('######## There are ' + LicenseRegistrations.size() + ' registrations that need audit numbers');
            List<License_Registration__c> lastLR = [SELECT Id, Audit_Number__c FROM License_Registration__c WHERE 
                                                    Audit_Number__c != null AND Renewal_Date__c != null ORDER BY Renewal_Date__c DESC LIMIT 1];
            Integer lastAuditNumber = 0;
            if(!lastLR.isEmpty())
                lastAuditNumber = Integer.valueOf(lastLR[0].Audit_Number__c);
            
            
            for(License_Registration__c l: LicenseRegistrations) {
                
                l.Renewal_Date__c = System.Now();
                if(lastAuditNumber < 10)
                    lastAuditNumber += 1;
                else
                    lastAuditNumber = 1;
                l.Audit_Number__c = lastAuditNumber;
            }
            
        }
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      set form template if not set on insert 
* @VersionHistory   20181219_HB : Moved from After Insert to Before Insert
******************************************************************************/
    private static void setFormTemplate(list<License_Registration__c> newList) {
        Logger.push('setFormTemplate','LicenseRegistrationAllHandler');    
        list<License_Registration__c> licenseRegistrations = new list<License_Registration__c>();
        for(License_Registration__c l : newList){
            if(l.VIP_Template__c == NULL) {
                licenseRegistrations.add(l);
            }
        }
        if(!licenseRegistrations.isEmpty()) {
            Logger.debug('##### FormTemplate not set. Looking up and setting');
            Map<String,String> TemplateMap = new Map<String,String>();
            for(Registration_Template_Mapping__mdt t : [Select Record_Type_Developer_Name__c,
                                                        Template_Id__c FROM Registration_Template_Mapping__mdt]){
                                                            TemplateMap.put(t.Record_Type_Developer_Name__c, t.Template_ID__c);
                                                        }
            
            //Map rec type ids and names
            Map<String,String> templateIdMap = new Map<String,String>();
            for(RecordType rt : recTypeMap.values()) {
                templateIdMap.put(rt.id, templateMap.get(rt.DeveloperName));
            }
            
            //build update to LR to set the template
            for(License_Registration__c lr : licenseRegistrations){
                lr.VIP_Template__c = templateIdMap.get(lr.RecordTypeId);
            }
            
        }
        Logger.pop();
    }
    
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      Creating Registration Questions under the License Registration 
* @VersionHistory   20181219_HB : Merged create and reCreateRegistrationQuestions in one Method
******************************************************************************/
    private static void upsertRegistrationQuestions(Map<String, List<License_Registration__c>> RecordTypeNames) {
        Logger.push('upsertRegistrationQuestions','LicenseRegistrationAllHandler');  
        if(!RecordTypeNames.isEmpty()) {
            
            // List of Registration_Question__c to insert
            List<Registration_Question__c> RegistrationQuestionToInsert = new List<Registration_Question__c>();
            for(Question_Rule__c qr: [SELECT Id, Question_ID__c, Sort_Order__c, Question_ID__r.Correction_Instructions__c,
                                      Question_ID__r.Question_Text__c,Question_ID__r.Stop_Auto_Renew_Value__c, Registration_Type__c FROM Question_Rule__c WHERE 
                                      Active__c = TRUE AND Registration_Type__c IN: RecordTypeNames.keySet() ORDER BY Sort_Order__c NULLS LAST]) {
                                          List<License_Registration__c> allLRegs = RecordTypeNames.get(qr.Registration_Type__c);  
                                          for(License_Registration__c lr : allLRegs) 
                                          {
                                              // Create new Registration_Question__c record
                                              Registration_Question__c newRegistrationQuestion = new Registration_Question__c();
                                              newRegistrationQuestion.Question_ID__c = qr.Question_ID__c;
                                              newRegistrationQuestion.Correction_Instructions__c = qr.Question_ID__r.Correction_Instructions__c;
                                              newRegistrationQuestion.Registration_ID__c = lr.Id;
                                              newRegistrationQuestion.Question_Text__c = qr.Question_ID__r.Question_Text__c;
                                              newRegistrationQuestion.Stop_Auto_Renew_Value__c = qr.Question_ID__r.Stop_Auto_Renew_Value__c;
                                              newRegistrationQuestion.Sort_Order__c = qr.Sort_Order__c;
                                              // add each new record to the list
                                              RegistrationQuestionToInsert.add(newRegistrationQuestion);
                                          }
                                      }
            
            // if the list is not empty insert all new records
            if(!RegistrationQuestionToInsert.isEmpty())
                insert RegistrationQuestionToInsert;
        }
        Logger.pop();
    }
    
    
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19           
* @description      Assign chargent license when ready to pay 
* @VersionHistory   20181219_HB : Added Custom apex Logger
******************************************************************************/
    private static void assignChargentLicense(list<License_Registration__c> newList , map<id, License_Registration__c> oldMap){
        Logger.push('assignChargentLicense','LicenseRegistrationAllHandler');  
        Logger.debug('##### entering method to assign chargent license');
        list<AssignChargentLicense__e> assignLicense = new list<AssignChargentLicense__e>();      
        // check to see if this reg needs a license check        
        for(License_Registration__c l : newList){
            License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
            
            if(l.Ready_to_Submit__c == 'Yes' && oldLicenseRegistration.Ready_to_Submit__c != 'Yes' && userInfo.getUserType() == 'CspLitePortal'){
                Logger.debug('##### Registration record meets criteria for license to be assigned');
                AssignChargentLicense__e a = new AssignChargentLicense__e();
                a.UserId__c = userInfo.getUserId();
                assignLicense.add(a);
            }
        }
        
        if(!assignLicense.isEmpty()){
            Logger.debug('##### Attempting to publish assign license event');
            list<Database.SaveResult> results = EventBus.publish(assignLicense);
            Integer i=0;
            for(Database.SaveResult sr : results){
                if(sr.isSuccess()) {
                    Logger.debug('##### Successfully published assign license event for ' + assignLicense[i].UserId__c);
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        Logger.debugException('##### Error returned from publishing assign license event for ' + assignLicense[i].UserId__c + 
                                              '\n Error : ' + err.getStatusCode() +  ' - ' +  err.getMessage());
                    }
                }
                i++;
            }
            
        }
        Logger.pop();
        
        
        
    }
    
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      Creating Registration Education under the License Registration 
* @VersionHistory   20181219_HB : Moved some duplicate logic to AfterInsert Method and also added custom debugs
******************************************************************************/  
    private static void createEducation(Map<String, List<License_Registration__c>> RecordTypeNames) {
        Logger.push('createEducation','LicenseRegistrationAllHandler');  
        if(!RecordTypeNames.isEmpty()) {
            
            // List of Registration_Question__c to insert
            List<Registration_Education__c> RegistrationEducationToInsert = new List<Registration_Education__c>();
            for(Registration_Education_Bank__c eb: [SELECT Id, Instructions__c, Name_of_Exam__c, 
                                                    Registration_Type__c, Version__c FROM Registration_Education_Bank__c WHERE Active__c = TRUE AND Registration_Type__c IN: RecordTypeNames.keySet()]) {
                                                        List<License_Registration__c> allLRegs = RecordTypeNames.get(eb.Registration_Type__c);
                                                        for(License_Registration__c lr: allLRegs) {
                                                            // Create new Registration_Question__c record
                                                            Registration_Education__c newRegistrationEducation = new Registration_Education__c();
                                                            newRegistrationEducation.Registration__c = lr.Id;
                                                            newRegistrationEducation.Name = eb.Name_of_Exam__c ;
                                                            newRegistrationEducation.Instructions__c = eb.Instructions__c;
                                                            newRegistrationEducation.Version__c = eb.Version__c;
                                                            
                                                            // add each new record to the list
                                                            RegistrationEducationToInsert.add(newRegistrationEducation);
                                                        }
                                                    }
            // if the list is not empty insert all new records
            if(!RegistrationEducationToInsert.isEmpty())
                insert RegistrationEducationToInsert;
        }
        Logger.pop();
    }
    
    
    //To-Do: Merge all Attachment methods in one method. Pass on both NewLiost and OldMap and if oldMap == null than run the insert logic else run the update logic
    // Also pass a Boolean flag for Clone
    private static void CreateAttachmentNotesOnUpdate(list<License_Registration__c> newList, map<id, License_Registration__c> oldMap) {
        Logger.push('CreateAttachmentNotesOnUpdate','LicenseRegistrationAllHandler');
        Logger.debug('######## Entering CreateAttachmentNotesOnUpdate Method');
        if(checkRecursive.runOnce()){
            Set<Id> LicenseRegistrationIds = oldMap.keyset();
            Map<String, List<License_Registration__c>> RecordTypeNames = new Map<String, List<License_Registration__c>>();
            for(License_Registration__c l: newList) {
                String rtName = recTypeMap.get(l.RecordTypeId).Name;
                if(!recordTypeNames.containsKey(rtName)) {
                    recordTypeNames.put(rtName, new List<License_Registration__c>());
                }
                recordTypeNames.get(rtName).add(l);
                
            }
            
            if(RecordTypeNames.size() > 0) {
                // Map of Registration_Attachment_Bank__c  for each the record type
                String registrationFields = '';
                Map<String, String> registrationMap = new Map<String, String>();
                Map<String, Registration_Attachment_Bank__c> registrationAttMap = new Map<String, Registration_Attachment_Bank__c>();
                
                List<Registration_Attachment_Bank__c> allRegistrationAttachmentBank = [SELECT Id, name, Attachment_Name__c, 
                                                                                       Instructions__c, Registration_Document_Category__c, Registration_Document_Type__c, Registration_Type__c, 
                                                                                       Trigger_Field__c, Trigger_Field_Value__c, VIP_Form_Section__c, Attachment_Required__c  
                                                                                       FROM Registration_Attachment_Bank__c WHERE Active__c = TRUE AND On_Create__c = FALSE 
                                                                                       AND Trigger_Field__c != null AND Registration_Type__c IN: RecordTypeNames.keySet()];
                Set<String> allSelFields = new Set<String>();
                for( Registration_Attachment_Bank__c ab: allRegistrationAttachmentBank ) {
                    if(!String.isEmpty(ab.Trigger_Field__c)) {
                        registrationMap.put(ab.Name + '|' + ab.Trigger_Field__c, ab.Trigger_Field_Value__c);
                        registrationAttMap.put(ab.Registration_Type__c + '|' + ab.Name + '|' + ab.Trigger_Field__c + '|' + ab.Trigger_Field_Value__c, ab);
                        allSelFields.add(ab.Trigger_Field__c);
                    }
                }
                
                for(String s: allSelFields) {
                    registrationFields += ', ' + s;
                }
                //Logger.debug('registrationMap =====> ' + registrationMap);
                //Logger.debug('registrationAttMap  =====> ' + registrationAttMap);
                //Logger.debug('registrationFields  =====> ' + registrationFields);
                List<Registration_Attachment_Bank__c> RegistrationAttachmentBank = new List<Registration_Attachment_Bank__c>();
                Set<Id> regLst = new Set<Id>();
                Set<Id> rabLst = new Set<Id>();
                if(!String.isEmpty(registrationFields)) {
                    String queryStr = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, RecordType.Name ' + 
                        registrationFields + ' FROM License_Registration__c WHERE Id IN :LicenseRegistrationIds';
                    List<License_Registration__c> allLicenceReg1 = Database.query(queryStr);
                    //System.debug('allLicenceReg1 =====> ' + allLicenceReg1 );
                    for(License_Registration__c lr: allLicenceReg1 ) {
                        if(oldMap.containsKey(lr.Id)) {
                            
                            License_Registration__c oldRecord = oldMap.get(lr.Id);
                            
                            for(String s: registrationMap.keySet()) {
                                String tempStr = s;
                                s = s.subStringAfter('|');
                                if(lr.get(s) != oldRecord.get(s)){
                                    //Below code added by Kavya Somashekar for req 170020
                                    if(registrationAttMap.containsKey(String.ValueOf(lr.RecordType.Name) + '|' + tempStr + '|' + String.ValueOf(oldRecord.get(s)))){
                                        regLst.add(lr.Id);
                                        rabLst.add(registrationAttMap.get(String.ValueOf(lr.RecordType.Name) + '|' + tempStr + '|' + String.ValueOf(oldRecord.get(s))).Id);
                                    }                               
                                    
                                    if(lr.get(s) != null && lr.get(s) != '') {
                                        //if(registrationAttMap.containsKey(String.ValueOf(lr.RecordType.Name) + '|' + s + '|' + String.ValueOf(lr.get(s)))) {
                                        if(registrationAttMap.containsKey(String.ValueOf(lr.RecordType.Name) + '|' + tempStr + '|' + String.ValueOf(lr.get(s)))){
                                            //Registration_Attachment_Bank__c rat = registrationAttMap.get(String.ValueOf(lr.RecordType.Name) + '|' + s + '|' + String.ValueOf(lr.get(s)));
                                            Registration_Attachment_Bank__c rat = registrationAttMap.get(String.ValueOf(lr.RecordType.Name) 
                                                                                                         + '|' + tempStr + '|' + String.ValueOf(lr.get(s)));
                                            RegistrationAttachmentBank.add(rat);
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    //fetch all the unwanted old attachments
                    List<Attachments_Plus__c> attLst = new List<Attachments_Plus__c>([SELECT Id,Registration__c,Registration_Attachment__c 
                                                                                      FROM Attachments_Plus__c 
                                                                                      WHERE Registration__c IN: regLst 
                                                                                      AND Registration_Attachment__c IN: rabLst]);
                    //System.debug('RegistrationAttachmentBank =====> ' + RegistrationAttachmentBank);
                    // Map of Registration_Attachment_Bank__c  for each the record type
                    Map<String, List<Registration_Attachment_Bank__c >> AttachmentBankMap = new Map<String, List<Registration_Attachment_Bank__c >>();
                    for( Registration_Attachment_Bank__c ab: RegistrationAttachmentBank) {
                        if(!AttachmentBankMap.containsKey(ab.Registration_Type__c)) {
                            List<Registration_Attachment_Bank__c> abList = new List<Registration_Attachment_Bank__c>();
                            abList.add(ab);
                            AttachmentBankMap.put(ab.Registration_Type__c, abList);
                        } else {
                            List<Registration_Attachment_Bank__c> existingList = AttachmentBankMap.get(ab.Registration_Type__c);
                            existingList.add(ab);
                            AttachmentBankMap.put(ab.Registration_Type__c, existingList);
                        }
                    } 
                    //System.debug('AttachmentBankMap =====> ' + AttachmentBankMap);
                    // List of Attachments_Plus__c to insert
                    List<Attachments_Plus__c> AttachmentsPlusToInsert = new List<Attachments_Plus__c>();
                    
                    for( String s: RecordTypeNames.keySet() ) {
                        if(AttachmentBankMap.containsKey(s)) {
                            List<Registration_Attachment_Bank__c> allAttachmentBank = AttachmentBankMap.get(s);
                            List<License_Registration__c> allLRegs = RecordTypeNames.get(s);
                            for(Registration_Attachment_Bank__c rab: allAttachmentBank) {
                                for(License_Registration__c lr: allLRegs) {
                                    // Create new Attachments_Plus__c record
                                    Attachments_Plus__c newAttachmentsPlus = new Attachments_Plus__c();
                                    newAttachmentsPlus.Registration__c = lr.Id;                                
                                    newAttachmentsPlus.Registration_Attachment__c = rab.Id;
                                    newAttachmentsPlus.Attachment_Name__c = rab.Attachment_Name__c;
                                    newAttachmentsPlus.Registration_Document_Category__c = rab.Registration_Document_Category__c;
                                    newAttachmentsPlus.Type__c = rab.Registration_Document_Type__c;
                                    newAttachmentsPlus.Instructions__c = rab.Instructions__c ;
                                    newAttachmentsPlus.VIP_Form_Section__c = rab.VIP_Form_Section__c;
                                    newAttachmentsPlus.Attachment_Required__c = rab.Attachment_Required__c;
                                    // add each new record to the list
                                    AttachmentsPlusToInsert.add(newAttachmentsPlus);
                                }
                            }
                        }
                    }
                    Logger.debug('AttachmentsPlusToInsert =====> ' + AttachmentsPlusToInsert);
                    // if the list is not empty delete all old attachments
                    if(attLst.size() > 0) {
                        delete attLst;  
                    }
                    // if the list is not empty insert all new records
                    if(AttachmentsPlusToInsert.size() > 0) {
                        insert AttachmentsPlusToInsert;  
                    }
                } 
            }
        }
        Logger.pop();
    } 
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      Handler for creating attachments when they are cloned after renewals
* @VersionHistory   20190104_HB : Changes for Registrations Cloned after renewals
*****************************************************************************/
    private static void CreateAttachmentNotesOnClone(Map<String, List<License_Registration__c>> clonedrecordTypeNames) {
        Logger.push('CreateAttachmentNotesOnClone','LicenseRegistrationAllHandler');
        
        if(clonedrecordTypeNames.size() > 0) {
            // Map of Registration_Attachment_Bank__c  for each the record type
            String registrationFields = '';
            Map<String, String> registrationMap = new Map<String, String>();
            Map<String, Registration_Attachment_Bank__c> registrationAttMap = new Map<String, Registration_Attachment_Bank__c>();
            
            List<Registration_Attachment_Bank__c> allRegistrationAttachmentBank = [SELECT Id, name, Attachment_Name__c,
                                                                                   Instructions__c, Registration_Document_Category__c, Registration_Document_Type__c, 
                                                                                   Registration_Type__c, Trigger_Field__c, Trigger_Field_Value__c, VIP_Form_Section__c, 
                                                                                   Attachment_Required__c  FROM Registration_Attachment_Bank__c WHERE Active__c = TRUE AND 
                                                                                   On_Create__c = FALSE AND Trigger_Field__c != null AND Registration_Type__c IN: clonedrecordTypeNames.keySet()];
            Set<String> allSelFields = new Set<String>();
            for( Registration_Attachment_Bank__c ab: allRegistrationAttachmentBank ) {
                if(!String.isEmpty(ab.Trigger_Field__c)) {
                    registrationMap.put(ab.Name + '|' + ab.Trigger_Field__c, ab.Trigger_Field_Value__c);
                    registrationAttMap.put(ab.Registration_Type__c + '|' + ab.Name + '|' + ab.Trigger_Field__c + '|' + ab.Trigger_Field_Value__c, ab);
                    allSelFields.add(ab.Trigger_Field__c);
                }
            }
            
            for(String s: allSelFields) {
                registrationFields += ', ' + s;
            }
            //Logger.debug('registrationMap =====> ' + registrationMap);
            //Logger.debug('registrationAttMap  =====> ' + registrationAttMap);
            //Logger.debug('registrationFields  =====> ' + registrationFields);
            List<Registration_Attachment_Bank__c> RegistrationAttachmentBank = new List<Registration_Attachment_Bank__c>();
            
            if(!String.isEmpty(registrationFields)) 
            {
                
                //System.debug('allLicenceReg1 =====> ' + allLicenceReg1 );
                for(list<License_Registration__c> newList: clonedrecordTypeNames.values() )
                {
                    for(License_Registration__c lr : newList ) {
                        String rtName = recTypeMap.get(lr.RecordTypeId).Name;
                        for(String s: registrationMap.keySet()) {
                            String tempStr = s;
                            s = s.subStringAfter('|');
                            if(lr.get(s) != null && lr.get(s) != '' && 
                               registrationAttMap.containsKey(String.ValueOf(rtName) + '|' + tempStr + '|' + String.ValueOf(lr.get(s)))){
                                   Registration_Attachment_Bank__c rat = registrationAttMap.get(String.ValueOf(rtName) 
                                                                                                + '|' + tempStr + '|' + String.ValueOf(lr.get(s)));
                                   RegistrationAttachmentBank.add(rat);
                                   
                               }
                        }
                        
                    }
                }
                
                // Map of Registration_Attachment_Bank__c  for each the record type
                // List of Attachments_Plus__c to insert
                List<Attachments_Plus__c> AttachmentsPlusToInsert = new List<Attachments_Plus__c>();
                for( Registration_Attachment_Bank__c rab: RegistrationAttachmentBank) {
                    List<License_Registration__c> allLRegs = clonedrecordTypeNames.get(rab.Registration_Type__c);
                    for(License_Registration__c lr: allLRegs) {
                        // Create new Attachments_Plus__c record
                        Attachments_Plus__c newAttachmentsPlus = new Attachments_Plus__c();
                        newAttachmentsPlus.Registration__c = lr.Id; 
                        newAttachmentsPlus.Registration_Attachment__c = rab.Id;
                        newAttachmentsPlus.Attachment_Name__c = rab.Attachment_Name__c;
                        newAttachmentsPlus.Registration_Document_Category__c = rab.Registration_Document_Category__c;
                        newAttachmentsPlus.Type__c = rab.Registration_Document_Type__c;
                        newAttachmentsPlus.Instructions__c = rab.Instructions__c ;
                        newAttachmentsPlus.VIP_Form_Section__c = rab.VIP_Form_Section__c;
                        newAttachmentsPlus.Attachment_Required__c = rab.Attachment_Required__c;
                        // add each new record to the list
                        AttachmentsPlusToInsert.add(newAttachmentsPlus);
                    }
                } 
                
                Logger.debug('AttachmentsPlusToInsert =====> ' + AttachmentsPlusToInsert);
                // if the list is not empty insert all new records
                if(AttachmentsPlusToInsert.size() > 0) {
                    insert AttachmentsPlusToInsert;  
                }
            }
        }
        Logger.pop();
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      Creating Attachments based on the RecordType and Attachment Bank Mapping
* @VersionHistory   20181219_HB : Moved some duplicate logic to AfterInsert Method and also added custom debugs
******************************************************************************/  
    private static void CreateAttachmentNotesOnInsert(Map<String, List<License_Registration__c>> RecordTypeNames ) {
        Logger.push('CreateAttachmentNotesOnInsert','LicenseRegistrationAllHandler');
         Id regDocRecordTypeId = Schema.SObjectType.Attachments_Plus__c.getRecordTypeInfosByName().get('Registration Document').getRecordTypeId();
        if(RecordTypeNames.size() > 0) {
            
            // List of Attachments_Plus__c to insert
            List<Attachments_Plus__c> AttachmentsPlusToInsert = new List<Attachments_Plus__c>();
            // Map of Registration_Attachment_Bank__c  for each the record type
            for( Registration_Attachment_Bank__c rab: [SELECT Id, name, Attachment_Name__c, Instructions__c, 
                                                       Registration_Document_Category__c, Registration_Document_Type__c, Registration_Type__c, VIP_Form_Section__c, Attachment_Required__c
                                                       FROM Registration_Attachment_Bank__c WHERE Active__c = TRUE AND On_Create__c = TRUE AND Registration_Type__c IN: RecordTypeNames.keySet()] ) {
                                                           List<License_Registration__c> allLRegs = RecordTypeNames.get(rab.Registration_Type__c); 
                                                           for(License_Registration__c lr: allLRegs) {
                                                               System.debug('#################lr' + lr);
                                                               // Create new Attachments_Plus__c record
                                                               Attachments_Plus__c newAttachmentsPlus = new Attachments_Plus__c();
                                                               newAttachmentsPlus.Registration__c = lr.Id; 
                                                               newAttachmentsPlus.Registration_Attachment__c = rab.Id;
                                                               newAttachmentsPlus.Attachment_Name__c = rab.Attachment_Name__c;
                                                               newAttachmentsPlus.Registration_Document_Category__c = rab.Registration_Document_Category__c;
                                                               newAttachmentsPlus.Type__c = rab.Registration_Document_Type__c;
                                                               newAttachmentsPlus.Instructions__c = rab.Instructions__c ;
                                                               newAttachmentsPlus.VIP_Form_Section__c = rab.VIP_Form_Section__c;
                                                               newAttachmentsPlus.Attachment_Required__c = rab.Attachment_Required__c;
                                                               // tken 04/08/2020 - SR-008673, B-000335
                                                               newAttachmentsPlus.OwnerId = lr.OwnerId;
                                                               newAttachmentsPlus.RecordTypeId = regDocRecordTypeId;
                                                               // add each new record to the list
                                                               AttachmentsPlusToInsert.add(newAttachmentsPlus);
                                                           }
                                                       }
            
            // if the list is not empty insert all new records
            if(AttachmentsPlusToInsert.size() > 0)
                insert AttachmentsPlusToInsert;
        }
        Logger.pop();
    }
    
    
    private static void CreateRejectionDefect(list<License_Registration__c> newList, map<id, License_Registration__c> oldMap) {
        Map<Id, List<Id>> rejectionDefectsToNotDuplicate = new Map<Id, List<Id>>();
        List<Rejection_Defect__c> rejectionDefectsToDelete = new List<Rejection_Defect__c>();
        Set<Id> LicenseRegistrationIds = new Set<Id>();
        Map<String, List<License_Registration__c>> RecordTypeNames = new Map<String, List<License_Registration__c>>();
        
        for(License_Registration__c l: newList) {
            License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
            
            
            if((oldLicenseRegistration.Status__c != 'Submitted' && l.Status__c == 'Submitted') 
               || (oldLicenseRegistration.Status__c != 'Resubmitted' && l.Status__c == 'Resubmitted'))
                LicenseRegistrationIds.add(l.Id);
        }
        
        Logger.debug('######## There are ' + LicenseRegistrationIds.size() + ' registrations that need rejection defects created');
        if (LicenseRegistrationIds.size() > 0){
            
            // for each License_Registration__c record created populate the map
            // RecordTypeNames - map to keep License_Registration__c RecordType.Name (key) and Id (value)
            List<License_Registration__c> allLR = [
                SELECT Id, RecordTypeId, RecordType.DeveloperName, RecordType.Name
                FROM License_Registration__c
                WHERE Id IN: LicenseRegistrationIds
            ];
            
            // get existing un-applied registration defects for deletion
            List<Rejection_Defect__c> openDefects = [
                SELECT Id, Applies__c, Defect__c, Registration__c
                FROM Rejection_Defect__c
                WHERE Registration__c IN :LicenseRegistrationIds
            ];
            
            for (Rejection_Defect__c rejectionDefect : openDefects) {
                if (rejectionDefect.Applies__c == true)
                    if(rejectionDefectsToNotDuplicate.get(rejectionDefect.Defect__c) != null)
                    rejectionDefectsToNotDuplicate.get(rejectionDefect.Defect__c).add(rejectionDefect.Registration__c);
                else rejectionDefectsToNotDuplicate.put(rejectionDefect.Defect__c, new List<Id>{rejectionDefect.Registration__c});
                if (rejectionDefect.Applies__c == false) rejectionDefectsToDelete.add(rejectionDefect);
            }
            
            if (rejectionDefectsToDelete.size() > 0) delete rejectionDefectsToDelete;
            
            for(License_Registration__c l: allLR) {
                if(!RecordTypeNames.containsKey(l.RecordType.Name)) {
                    List<License_Registration__c> nList = new List<License_Registration__c>();
                    nList.add(l);
                    RecordTypeNames.put(l.RecordType.Name, nList);
                } else {
                    List<License_Registration__c> existingList = RecordTypeNames.get(l.RecordType.Name);
                    existingList.add(l);
                    RecordTypeNames.put(l.RecordType.Name, existingList);
                }
            }
        }    
        
        if(RecordTypeNames.size() > 0) {
            // List of Defects for each the record type
            
            Map<String, List<Defect__c>> DefectsMap = new Map<String, List<Defect__c>>();
            List<Defect__c> allDefects = [SELECT Id, Description__c, Registration_Type__c, Item_Name__c, Section__c, Sub_Section__c FROM Defect__c WHERE Active__c = TRUE AND Registration_Type__c IN: RecordTypeNames.keySet()];
            for(Defect__c d: allDefects) {
                if(!DefectsMap.containsKey(d.Registration_Type__c)) {
                    List<Defect__c> dList = new List<Defect__c>();
                    dList.add(d);
                    DefectsMap.put(d.Registration_Type__c, dList);
                } else {
                    List<Defect__c> existingList = DefectsMap.get(d.Registration_Type__c);
                    existingList.add(d);
                    DefectsMap.put(d.Registration_Type__c, existingList);
                }
            }
            
            
            // List of Rejection_Defect__c to insert
            List<Rejection_Defect__c> RejectionDefectsToInsert = new List<Rejection_Defect__c>();
            // get all RecordTypes for Rejection_Defect__c
            List<RecordType> RDRecordTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType='Rejection_Defect__c'];
            
            
            for( String s: RecordTypeNames.keySet() ) {
                if(DefectsMap.containsKey(s)) {
                    List<Defect__c> Defects = DefectsMap.get(s);
                    List<License_Registration__c> allLRegs = RecordTypeNames.get(s);
                    for(Defect__c de: Defects) {
                        // Create new Rejection_Defect__c record
                        for(License_Registration__c lr: allLRegs) {
                            if (rejectionDefectsToNotDuplicate.get(de.Id) != null && rejectionDefectsToNotDuplicate.get(de.Id).contains(lr.Id)) continue;
                            
                            Rejection_Defect__c newRejectionDefect = new Rejection_Defect__c();
                            // set the record type id from the Defect__c.Section__c field
                            for(RecordType rt: RDRecordTypes) {
                                if(rt.Name == de.Section__c)
                                    newRejectionDefect.RecordTypeId = rt.Id;
                            }
                            newRejectionDefect.Defect__c = de.Id;
                            newRejectionDefect.Description_of_Defect__c = de.Description__c;
                            newRejectionDefect.Registration__c = lr.Id;
                            newRejectionDefect.Item_Name__c = de.Item_Name__c;
                            newRejectionDefect.Section__c = de.Section__c;
                            newRejectionDefect.Sub_Section__c = de.Sub_Section__c;
                            // add each new record to the list
                            RejectionDefectsToInsert.add(newRejectionDefect);
                        }
                    }
                }
            }
            
            
            // if the list is not empty insert all new records
            if(RejectionDefectsToInsert.size() > 0)
                insert RejectionDefectsToInsert;
        }
        Logger.pop();
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      
* @VersionHistory   20181219_HB : Added custom debugs
******************************************************************************/ 
    private static void createRejectionBeforeUpdate(list<License_Registration__c> newList, map<id, License_Registration__c> oldMap) {
        Logger.push('createRejectionBeforeUpdate','LicenseRegistrationAllHandler');
        Logger.debug('######## Entering CreateRejection Method');
        for(License_Registration__c l: newList) {
            License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
            if(oldLicenseRegistration.Status__c != 'Pending / Defect' && l.Status__c == 'Pending / Defect') {
                l.Ready_to_Submit__c = 'No';
            }
        }
        Logger.pop();
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      
* @VersionHistory   20181219_HB : Added custom debugs
******************************************************************************/ 
    private static void createRejectionAfterUpdate(list<License_Registration__c> newList, map<id, License_Registration__c> oldMap) {
        Logger.push('createRejectionAfterUpdate','LicenseRegistrationAllHandler');
        Logger.debug('######## Entering CreateRejection Method');
        
        Set<License_Registration__c> LicenseRegistrations = new Set<License_Registration__c>();
        Set<Id> LicenseRegistrationIds = new Set<Id>();
        for(License_Registration__c l: newList) {
            License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
            if(oldLicenseRegistration.Status__c != 'Pending / Defect' && l.Status__c == 'Pending / Defect') {
                LicenseRegistrations.add(l);
                LicenseRegistrationIds.add(l.Id);
            }
        }
        
        Logger.debug('######## There are ' + LicenseRegistrations.size() + ' registrations that need rejections created');
        if (!LicenseRegistrations.isEmpty()) {
            // Create a map with all related Rejection
            Map<Id, Rejection__c> allRejectionMap = new Map<Id, Rejection__c>();
            // Create a map with existing Rejection
            for(Rejection__c rej: [SELECT Id, Registration__c FROM Rejection__c WHERE Registration__c IN: LicenseRegistrations]) {
                LicenseRegistrationIds.remove(rej.Registration__c);
                allRejectionMap.put(rej.Registration__c, rej);
            }
            
            if(!LicenseRegistrationIds.isEmpty())
            {
                List<Rejection__c> RejectionToInsert = new List<Rejection__c>();
                for(Id  lrId: LicenseRegistrationIds) {
                    Rejection__c newRejection = new Rejection__c();
                    newRejection.Registration__c = lrId;
                    RejectionToInsert.add(newRejection);
                }
                
                insert RejectionToInsert;
                for(Rejection__c newRejection : RejectionToInsert)
                {
                    allRejectionMap.put(newRejection.Registration__c, newRejection);
                }
                
            }
            
            List<Rejection_Defect__c> RejectionDefectsToUpdate = new List<Rejection_Defect__c>();
            List<Rejection_Defect__c> RejectionDefectsToDelete = new List<Rejection_Defect__c>();
            
            for(Rejection_Defect__c rd: [SELECT Id, Rejection__c, Registration__c, Applies__c 
                                         FROM Rejection_Defect__c WHERE Registration__c IN: LicenseRegistrations]) {
                                             if(rd.Applies__c == true) {
                                                 rd.Rejection__c = allRejectionMap.get(rd.Registration__c).Id;
                                                 RejectionDefectsToUpdate.add(rd);
                                             } else {
                                                 RejectionDefectsToDelete.add(rd);
                                             }
                                         }
            
            if(!RejectionDefectsToUpdate.isEmpty() )
                update RejectionDefectsToUpdate;
            if(!RejectionDefectsToDelete.isEmpty() )
                delete RejectionDefectsToDelete;
        }
        Logger.pop();
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      checks for and handles defects when registration is set to approved
* @VersionHistory   20181219_HB : Added custom debugs
******************************************************************************/ 
    private static void registrationApproved(list<License_Registration__c> newList, map<id, License_Registration__c> oldMap){
        Logger.push('registrationApproved','LicenseRegistrationAllHandler');
        Logger.debug('##### Entering Registration Approved Method');
        //check to see that registration is set to approved
        list<License_Registration__c> regList = new list<License_Registration__c>();
        for(License_Registration__c l : newList){
            if(oldMap.get(l.Id).Status__c != 'Approved' && l.Status__c == 'Approved'){
                regList.Add(l);
            }
        }
        
        if(!regList.isEmpty()) {
            Logger.debug('##### Registration set to approved');
            //Get defects that have not been resolved
            list<Rejection_Defect__c> defectsToDelete = [SELECT ID, Applies__c, Resolved__c 
                                                         FROM Rejection_Defect__c WHERE Registration__c IN :regList
                                                         and applies__c = false];
            //check to see if any defects need to be deleted
            if(!defectsToDelete.isEmpty()) {
                Logger.debug('##### Deleting ' + defectsToDelete.size() + ' defects');
                delete defectsToDelete;
                
            }
            
        }
        Logger.pop();
        
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      Creates Registration Account record from the details captured on the registration itself
* @VersionHistory   20181219_HB : Added custom debugs
******************************************************************************/  
    private void CreateRegistrationAccount(list<License_Registration__c> newList, map<id, License_Registration__c> oldMap) {
        Map<String, Id> RegAccRTMap = new Map<String, Id>();
        List<Registration_Account__c> RegistrationAccountToInsert = new List<Registration_Account__c>();
        Set<String> recordTypesToSkip = new Set<String>{'Public_Works','Car_Wash','Janitorial','Talent_Agency'};
            
            for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Registration_Account__c'] ) {
                RegAccRTMap.put(rt.Name, rt.Id);
            }
        for(License_Registration__c lr : newList) {
            License_Registration__c oldLicenseRegistration = oldMap.get(lr.ID);
            // do not create registration accounts and accounts for individual permit
            if (lr.Company_Type__c != 'Individual Permit' && !recordTypesToSkip.contains(lr.Record_Type_Name__c)) {
                if(oldLicenseRegistration.VIP_Date_Time_Submitted__c == null && lr.VIP_Date_Time_Submitted__c != null && lr.Company_Type__c != 'Joint Venture'
                   && lr.Renewal__c == False && !String.isEmpty(lr.Company_Type__c) && RegAccRTMap.containsKey(lr.Company_Type__c) 
                   /*&& l.Registration_Account__c == null*/) {
                       Registration_Account__c regAccount = new Registration_Account__c();
                       if(lr.Company_Type__c == 'Corporation' || lr.Company_Type__c == 'LLC')
                           regAccount.RecordTypeId = RegAccRTMap.get('Corp or LLC');
                       else if(lr.Company_Type__c == 'LLP LP')
                           regAccount.RecordTypeId = RegAccRTMap.get('Limited Partnership');
                       else 
                           regAccount.RecordTypeId = RegAccRTMap.get(lr.Company_Type__c);
                       if(LRHandlerHelper.getInstance().isDuplicateRegAccount(lr,  regAccount.RecordTypeId)){
                           RegistrationAccountToInsert.add(LRHandlerHelper.getInstance().initiateRegAccount(lr,regAccount));
                       }  
                   }
            }
            if(!RegistrationAccountToInsert.isEmpty())
                insert RegistrationAccountToInsert;
        }
        Logger.pop(); 
    }
    
    private void CheckEntityLicenceNumbers(List<License_Registration__c> newList) {
        //Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        
        //if (profile.Name != 'Community Registrations User') return;
        
        Set<String> entityNumbers = new Set<String>();
        Set<String> licenseNumbers = new Set<String>();
        Set<String> newEntityNumbers = new Set<String>();
        Set<String> newLicenseNumbers = new Set<String>();
        Id licenseRecTypeId = SObjectType.License_Registration__c.getRecordTypeInfosByName().get('License').getRecordTypeId();
        Id pwRecTypeId = SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        
        for (License_Registration__c lr : newList) {
            if (lr.RecordTypeId == pwRecTypeId && lr.EntityNumber__c != null)
                newEntityNumbers.add(lr.EntityNumber__c);
            
            if (lr.RecordTypeId == licenseRecTypeId && lr.License_Number__c != null)
                newLicenseNumbers.add(lr.License_Number__c);
        }
        
        if (!newEntityNumbers.isEmpty() || !newLicenseNumbers.isEmpty()) {
            List<License_Registration__c> registrations = [
                SELECT EntityNumber__c,
                (SELECT License_Number__c
                 FROM Registrations__r
                 WHERE RecordTypeId = :licenseRecTypeId
                 AND License_Number__c != null)
                FROM License_Registration__c
                WHERE RecordTypeId = :pwRecTypeId
                AND Status__c = 'Disqualified'
                AND EntityNumber__c != null
            ];
            
            if (!registrations.isEmpty()) {
                for (License_Registration__c lr : registrations) {
                    entityNumbers.add(lr.EntityNumber__c);
                    
                    for (License_Registration__c r : lr.Registrations__r)
                        licenseNumbers.add(r.License_Number__c);
                }
                
                for (License_Registration__c lr : newList) {
                    if (lr.RecordTypeId == pwRecTypeId && entityNumbers.contains(lr.EntityNumber__c) || lr.RecordTypeId == licenseRecTypeId && licenseNumbers.contains(lr.License_Number__c))
                        lr.addError(Label.Registration_Disqualified_Entity_License_Number);
                }
            }
        }
    }
    
    private void CheckTwelveMonthRule(map<id, License_Registration__c> newMap) {
        List<Id> penaltyIds = new List<Id>();
        
        for (License_Registration__c r : newMap.values()) {
            if (r.Penalty_I__c) penaltyIds.add(r.Id);
        }
        
        List<License_Registration__c> registrations = [
            SELECT Renewal_Registration__c
            FROM License_Registration__c
            WHERE Renewal_Registration__c IN :penaltyIds
            AND Penalty_I__c = TRUE
            AND Payment_Date_Time__c > :Date.Today().addYears(-1)
        ];
        
        for (License_Registration__c r : registrations) {
            if (newMap.get(r.Renewal_Registration__c) != null) {
                newMap.get(r.Renewal_Registration__c).addError(Label.PW_12_Month_Rule_Error);
            }
        }
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      This method checks to see if applicable and publishes platform event Create_Accounts_Locations to call the CreateAccountsAndLocations 
*                    method in this class in system mode allowing accounts and locations to be created from an auto-renewed application
* @VersionHistory   20181219_HB : Added custom debugs
******************************************************************************/  
    private static void publishCreateAccountsAndLocations(list<License_Registration__c> newList, map<Id, License_Registration__c> oldMap){
        Logger.push('publishCreateAccountsAndLocations','LicenseRegistrationAllHandler');
        List<Create_Accounts_Locations__e> cal = new list<Create_Accounts_Locations__e>();
        for(License_Registration__c l: newList) {
            License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
            if((oldLicenseRegistration.Status__c != 'Approved' && l.Status__c == 'Approved') || 
               (!(oldLicenseRegistration.Status__c).contains('Closed') && (l.Status__c).contains('Closed')) /*||
(oldLicenseRegistration.Status__c != 'Renewed' && l.Status__c == 'Renewed')*/) {
    cal.add(new Create_Accounts_Locations__e (RegistrationID__c = l.Id));
}
            
        }
        
        if(!cal.isEmpty()){
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(cal);
            // Inspect publishing result for each event
            Integer i = 0;
            for(Database.SaveResult sr : results){
                if(sr.isSuccess()) {
                    Logger.debug('Successfully published Create_Accounts_Locations event for ' + cal[i].RegistrationID__c);
                } else
                {
                    for(Database.Error err : sr.getErrors()){
                        Logger.debugException('Error returned for ' +  cal[i].RegistrationID__c 
                                              + ' \n Error : ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
                i++;
            }
        }
        Logger.pop();
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-12-19             
* @description      Added by Kavya Somashekar for rer 170018, 170019
* @VersionHistory   20181219_HB : Added custom debugs
*****************************************************************************/
    private static void clearFieldOnReview(list<License_Registration__c> newList,map<Id, License_Registration__c> oldMap) {
        Logger.push('clearFieldOnReview','LicenseRegistrationAllHandler');
        
        Map<String,Registration_Defects_Mapping__mdt> secDefFeildMap = new Map<String,Registration_Defects_Mapping__mdt>();
        
        for(Registration_Defects_Mapping__mdt rdm: [Select MasterLabel,Field_API__c,Reviewed_Field__c FROM Registration_Defects_Mapping__mdt])
            secDefFeildMap.put(rdm.MasterLabel,rdm);
        
        for(License_Registration__c lr: newList) {
            //B-29575
            if(oldMap.get(lr.Id).Employee_Leasing__c == 'No' && lr.Employee_Leasing__c == 'Yes'){
                if(lr.Function_as_Employee_Leasing_Co__c != NULL && lr.Function_as_Employee_Leasing_Co__c != '')
                    lr.Function_as_Employee_Leasing_Co__c = '';
                if(lr.Workers_Comp_Selection__c != NULL && lr.Workers_Comp_Selection__c !='')
                    lr.Workers_Comp_Selection__c = '';
            }
            
            if(lr.Status__c =='Resubmitted') {
                for(String def:secDefFeildMap.keyset())
                {
                    if(lr.get(secDefFeildMap.get(def).Reviewed_Field__c) == TRUE)
                        lr.put(secDefFeildMap.get(def).Reviewed_Field__c,FALSE);
                }
            }
        }
        Logger.pop();
        
    }
    
    /******************************************************************************
* @author           Sapient
* @LastModifiedDate 2018-1-23             
* @description      Added by Shivam Goyal for TC-23884
*****************************************************************************/    
    
    public void CreateDummyRegAccounts(list<License_Registration__c> newList){
        
        Id jointVentureId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Joint Venture').getRecordTypeId();
        Id PartnershipId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
        Id publicWorksId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        
        Map<Id,License_Registration__c> regMap = new Map<Id,License_Registration__c>([select id,Company_Type__c,(select id,recordtypeid from Registration_Accounts__r where recordtypeid in (:jointVentureId,:PartnershipId)) from License_Registration__c where id in :newList]);
        List<Registration_Account__c> regAccountsList = new List<Registration_Account__c> ();
        
        for(License_Registration__c reg : newList){
            
            if(reg.recordtypeid==publicWorksId){
                Integer jointVentureCount = 0;
                Integer partnershipCount=0;
                
                for(Registration_Account__c regAccount : regMap.get(reg.id).Registration_Accounts__r){
                    if(regAccount.recordtypeid==jointVentureId){
                        jointVentureCount++;
                    }else if(regAccount.recordtypeid==PartnershipId){
                        partnershipCount++;
                    }
                }
                //
                //                if(reg.Company_Type__c=='Joint Venture' && jointVentureCount<2){
                //                    for(integer i=0;i<2-jointVentureCount;i++){
                //                        Registration_Account__c regAcc = new Registration_Account__c();
                //                        regAcc.Registration__c=reg.id;
                //                        regAcc.recordtypeid=jointVentureId;
                //                        regAccountsList.add(regAcc);
                //                    }
                //                }else if(reg.Company_Type__c=='General Partnership' && partnershipCount<2){
                //                    for(integer i=0;i<2-partnershipCount;i++){
                //                        Registration_Account__c regAcc = new Registration_Account__c();
                //                        regAcc.Registration__c=reg.id;
                //                        regAcc.recordtypeid=PartnershipId;
                //                        regAccountsList.add(regAcc);
                //                    }
                //                }
                
                if(regAccountsList.size()>0){
                    insert regAccountsList;
                }
            }
            
        }        
        
    }
    
    public List<Registration_Account__c> raList = new List<Registration_Account__c>();
    
    public void AutoApproveTempEWPRegistration(List<License_Registration__c> newList, Map<Id, License_Registration__c> oldMap){      
        Logger.push('registrationApproved','LicenseRegistrationAllHandler');
        Logger.debug('##### Entering Registration Approved Method');
        if(!newList.isEmpty()){
 //           for(License_Registration__c lr: newList){
                if(newList[0].Record_Type_Name__c == 'Entertainment_Work'){
                    
                    //String rtName = recTypeMap.get(newList[0].RecordTypeId).Name;
                    //System.debug('*************rtName: ' + rtName);
                    //System.debug('*************lr.__c: ' + newList[0].Service_Type__c);
                    //System.debug('*************newList[0]: ' + newList[0]);
                    //System.debug('*************lr.Record_Type_Name__c: ' + newList[0].Record_Type_Name__c);            
                    //System.debug('*************lr.Status_of_Payment__c: ' + newList[0].Status_of_Payment__c);
                    //System.debug('*************lr.Status__c: ' + newList[0].Status__c);
                    //System.debug('*************lr.Submitted__c: ' + newList[0].Submitted__c);
                    //System.debug('*************lr.Registration_Duration__c: ' + newList[0].Registration_Duration__c);
                    //System.debug('*************lr.Submission_Type__c: ' + newList[0].Submission_Type__c);
                    //System.debug('*************lr.Ready_to_Submit__c: ' + newList[0].Ready_to_Submit__c);
                    
                    if(newList[0].Record_Type_Name__c == 'Entertainment_Work'
                       && newList[0].Status_of_Payment__c == 'Paid / No Balance Due'
                       && newList[0].Status__c == 'Submitted'
                       && newList[0].Registration_Duration__c  == '10 Days - Temporary Permit'
                       && newList[0].Submission_Type__c == 'Online'
                       && newList[0].Ready_to_Submit__c == 'Yes'
                       //; && ra.Birth_Date__c.addDays(30) < Date.today()
                      ){
                          if(raList.isEmpty()) { raList = getEWPRA(newList); }
                          
                          for(Registration_Account__c eachRa : raList){
                              if(eachRa.Birth_Date__c.addDays(30) < Date.today()){
                                  newList[0].Effective_Date__c = newList[0].Effective_Date__c != NULL ? newList[0].Effective_Date__c : Date.today() ;
                                  newList[0].Expiration_Date__c = newList[0].Effective_Date__c.addDays(10);
                                  newList[0].Status__c = 'Approved';
                              }  
                              //NewRegistration(newList, oldMap);
                          }
                      }
                    // Logger.pop(); 
                }
            }
   //     }
    }
    
    // used by EWP to create new 6-month registration for temporary permits
    public void publishCreateLR(list<License_Registration__c> newList, map<Id, License_Registration__c> oldMap){
        //Logger.push('publishCreateLR','LicenseRegistrationAllHandler');
        if(!newList.isEmpty()){
            if(newList[0].Record_Type_Name__c == 'Entertainment_Work'){
                
                List<Create_Registrations__e > createLR = new list<Create_Registrations__e >();
                
                for(License_Registration__c l: newList) {
                    
                    //System.debug('************* l.Record_Type_Name__: ' + l.Record_Type_Name__c);
                    //System.debug('************* l.Status_of_Payment__c: ' + l.Status_of_Payment__c);
                    //System.debug('************* l.Status__c: ' + l.Status__c);
                    //System.debug('************* l.Registration_Duration__c: ' + l.Registration_Duration__c);
                    //System.debug('************* l.Submission_Type__c: ' + l.Submission_Type__c);
                    //System.debug('************* l.Ready_to_Submit__c: ' + l.Ready_to_Submit__c);
                    
                    if( l.Record_Type_Name__c == 'Entertainment_Work'
                       && l.Status_of_Payment__c == 'Paid / No Balance Due'
                       && l.Status__c == 'Approved'
                       && l.Registration_Duration__c  == '10 Days - Temporary Permit'
                       && l.Submission_Type__c == 'Online'
                       && l.Ready_to_Submit__c == 'Yes')
                    {
                        
                        License_Registration__c oldLicenseRegistration = oldMap.get(l.Id);
                        if((oldLicenseRegistration.Status__c != 'Approved' && l.Status__c == 'Approved') || 
                           (!(oldLicenseRegistration.Status__c).contains('Closed') && (l.Status__c).contains('Closed'))) {
                               createLR.add(new Create_Registrations__e  (RegistrationID__c = l.Id));
                           }
                    }
                }
                
                if(!createLR.isEmpty()){
                    // Call method to publish events
                    List<Database.SaveResult> results = EventBus.publish(createLR);
                    // Inspect publishing result for each event
                    Integer i = 0;
                    for(Database.SaveResult sr : results){
                        if(sr.isSuccess()) {
                            Logger.debug('Successfully published Create Registration event for ' + createLR[i].RegistrationID__c);
                        } else
                        {
                            for(Database.Error err : sr.getErrors()){
                                Logger.debugException('Error returned for ' +  createLR[i].RegistrationID__c 
                                                      + ' \n Error : ' + err.getStatusCode() + ' - ' + err.getMessage());
                            }
                        }
                        i++;
                    }
                }
            }
        }
        //Logger.pop();
    }
    
    // used in medical section of ewp vip form.  
    // if the minor is under 30 days or 6 month permit, users must fill out medical section
    public void updateIsSkipMedicalComponent(List<License_Registration__c> newList, Map<Id, License_Registration__c> oldMap){
        if(newList.isEmpty() || newList[0].Record_Type_Name__c != 'Entertainment_Work'){ return;}

        if(raList.isEmpty()) { raList = getEWPRA(newList); }
        // if the list is still empty after query, return
        if(raList.isEmpty()) {return;}
        
        if(raList[0].Birth_Date__c == NULL) {return;}
        
        if(raList[0].Birth_Date__c.addDays(30) >= Date.today() || newList[0].Registration_Duration__c == '6 Months - Permit'){
            newList[0].isSkipMedicalComponent__c = false;
        } 
        else if(newList[0].Registration_Duration__c == '10 Days - Temporary Permit'){
            newList[0].isSkipMedicalComponent__c = true;
        } 
        else{
            newList[0].isSkipMedicalComponent__c = false;
        }
    }
    
    private List<Registration_Account__c> getEWPRA(List<License_Registration__c> newList){
        if(!newList.isEmpty()){
            if(newList[0].Record_Type_Name__c == 'Entertainment_Work'){
                
                raList = [SELECT id
                          , Birth_Date__c
                          FROM Registration_Account__c
                          WHERE RecordType.DeveloperName = 'Individual_Permit'
                          AND Registration__r.Record_Type_Name__c =: newList[0].Record_Type_Name__c
                          AND Registration__r.Id =: newList[0].Id];
            }
        }
        return raList;
    }
    
    public void updateEffectiveExpirationDate(List<License_Registration__c> newList, Map<Id, License_Registration__c> oldMap){
        License_Registration__c oldLicenseRegistration = oldMap.get(newList[0].Id);// get previous registration
        
        if(!newList.isEmpty() 
           && newList[0].Record_Type_Name__c == 'Entertainment_Work' 
           && newList[0].Registration_Duration__c == '6 Months - Permit'
           && userInfo.getUserType() != 'CspLitePortal')
        {
            if( oldLicenseRegistration.Effective_Date__c == NULL)
            {
                
                newList[0].Effective_Date__c = Date.today();
                newList[0].Expiration_Date__c = newList[0].Effective_Date__c.addMonths(6);
            }
            else if((newList[0].Status__c == 'Approved' 
                     || newList[0].Status__c == 'Submitted' 
                     || newList[0].Status__c == 'Resubmitted'
                     || newList[0].Status__c == 'In Review'
                     || newList[0].Status__c == 'Incomplete')
                    && ((newList[0].Effective_Date__c != oldLicenseRegistration.Effective_Date__c)
                        || (newList[0].Expiration_Date__c != oldLicenseRegistration.Expiration_Date__c)
                        ||  newList[0].Override_Default_Effective_Date__c != oldLicenseRegistration.Override_Default_Effective_Date__c
                        || newList[0].Override_Default_Expiration_Date__c != oldLicenseRegistration.Override_Default_Expiration_Date__c))
            {
                if(newList[0].Override_Default_Effective_Date__c == FALSE
                   && (newList[0].Effective_Date__c != oldLicenseRegistration.Effective_Date__c  
                       || newList[0].Override_Default_Effective_Date__c != oldLicenseRegistration.Override_Default_Effective_Date__c))
                {
                    if(newList[0].Approval_Date_Time__c == NULL 
                       && newList[0].Effective_Date__c <= Date.today()){
                           
                           newList[0].Effective_Date__c = Date.today();
                       }
                    else if(newList[0].Approval_Date_Time__c != NULL){
                        //License_Registration__c oldLicenseRegistration = oldMap.get(newList[0].Id);// get previous registration
                        //newList[0].Effective_Date__c =  oldLicenseRegistration.effective_date__c;
                        //
                        newList[0].addError('You cannot change the effective date of an approved permit.');
                    }
                }
                if(newList[0].Override_Default_Expiration_Date__c == FALSE)
                {
                    newList[0].Expiration_Date__c = newList[0].Effective_Date__c.addMonths(6);
                }
            }   
        }
    }
}