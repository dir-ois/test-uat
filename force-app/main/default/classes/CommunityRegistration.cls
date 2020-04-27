/********************************************************************************************************
Name:  CommunityRegistration.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/14/2017
Modified by: 
Date:
Test class: CommunityRegistrationTest.cls

Modified by: Touk Ken, SR-004558, SR-004501
Date: 09/07/2018

Behavior:
    Display My Registrations
        VF component - shows Registration (License_Registration__c) records where Account__c is related to logged-in 
        user's contact record. (print document)
    My Payments
        VF Component - shows Payment (object TBD) records where Payee__c = logged-in user's contact record.
       
********************************************************************************************************/

public class CommunityRegistration {
    
    private User currentUser;
    private Id regRecordType;
    public String currentRecordType {get; set;}
    private List<RecordType> registrationRecordTypes;
    Map<String,String> templateIdMap = new Map<String,String>();
    public boolean displayPopup {get; set;} 
    public boolean dupRecordFound {get; set;} 
    public String licenseRegistrationNumber;
    public String acRequestor;
    public String acRegistration;
    public DateTime acLastModifiedDate;
    public DateTime acLatestCreatedDate;
     
    public CommunityRegistration(){
        dupRecordFound = false;
        currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        //regRecordType = [SELECT DeveloperName FROM RecordType WHERE Id IN (SELECT RecordType FROM License_Registration__c Where ID = ApexPages.currentPage().getParameters().get('recId')) ];
        //registrationRecordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType='License_Registration__c' ORDER BY Name ASC];
        Map<String,String> devNames = new Map<String,String>();
        for(Registration_Template_Mapping__mdt mdt : [select id,DeveloperName,Record_Type_Developer_Name__c,Template_ID__c from Registration_Template_Mapping__mdt]){
            devNames.put(mdt.Record_Type_Developer_Name__c, mdt.Template_ID__c);
        }
        registrationRecordTypes = new List<RecordType>();
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='License_Registration__c' AND DeveloperName IN :devNames.keySet() AND IsActive = true ORDER BY Name ASC]){
            registrationRecordTypes.add(rt);
            templateIdMap.put(rt.id, devNames.get(rt.DeveloperName));
        }
    }
    
    public List<License_Registration__c> getAllRegistrations() {
        List<Id> accApprovalId =  new List<Id>();
        
        
        try{
            List<Access_Approval__c> accApproval = [select id,Registration__c from Access_Approval__c where Approved__c='Yes' and Requestor__c= :currentUser.ContactId order by LastModifiedDate DESC];
            for(Access_Approval__c acc:accApproval){
                accApprovalId.add(acc.Registration__c);
            }
        }catch(Exception e){
            
        } 
                
        System.debug('accApprovalId--'+accApprovalId);
        
        List<License_Registration__c> regList = [SELECT Id,Renewal_Registration__c, Account__c, Account__r.Name, Account__r.Legal_Entity_Name__c, License_Registration_Number__c, License_Registration_Type__c,
            Submitted_Date__c, Status__c,Effective_Date__c, Expiration_Date__c, Payment_Status__c, Status_of_payment__c, Amount_Paid__c, Amount_Due__c, Balance__c, Legal_Entity_Name__c, 
            Service_Type__c, Exam_Status__c, displayRenewalButton__c, OwnerId, Applicant__c, Registration_Duration__c
                FROM License_Registration__c WHERE (Applicant__c =: currentUser.ContactId or id in :accApprovalId) /*Account__c =: currentUser.Contact.AccountId*/ ORDER BY CreatedDate DESC LIMIT 500];
         
         //Changes done by Shivam Goyal for REEQ 169949(Displaying renewal button for public works)       
         List<License_Registration__c> finalRegList = new List<License_Registration__c>(); 
         Integer renewalDuration = integer.valueOf(Key_Value_Store__c.getValues('Renewal Button Availability').Value__c);
         
         System.debug('renewalDuration--'+renewalDuration);
         for(License_Registration__c reg:regList){ 
            
             //King don't display the reg if owner isn't the logged-in user for public works users
             if((reg.License_Registration_Type__c=='Public Works' && reg.OwnerId != UserInfo.getUserId()) && 
                (reg.License_Registration_Type__c=='Public Works' && reg.Applicant__c != currentUser.ContactId)){
                    continue;
                }
             
             if(reg.Renewal_Registration__c!=null){
                 reg.displayRenewalButton__c=False;
             }
             //Renewal button will be displayed for active registrations having record type public works and which are expiring this year. It will be displayed from 1st may(based on custom setting) til 30th Sep
             else if(reg.License_Registration_Type__c=='Public Works' && (reg.Status__c=='Active' || reg.Status__c=='Expired') && reg.Expiration_Date__c !=null && reg.Expiration_Date__c.year()<=System.Today().year()
                     && System.Today()>=reg.Expiration_Date__c-renewalDuration){
                         reg.displayRenewalButton__c=True;
                     }
             //Renewal button will be displayed for inactive registrations having record type public works and which have already expired. It will be displayed from 1st July till 30th Sep
             else if(reg.License_Registration_Type__c=='Public Works' && reg.Status__c=='Inactive'  && reg.Expiration_Date__c !=null && reg.Expiration_Date__c.year()<=System.Today().year()
                     && System.Today()>reg.Expiration_Date__c){
                         reg.displayRenewalButton__c=True;
                     }else{
                         reg.displayRenewalButton__c=False;  
                     }
             
             finalRegList.add(reg);
             
         }
                
        return finalRegList;        
    }
    
    public void DeleteRegistration() {
        String delRecordId = ApexPages.currentPage().getParameters().get('recId');
        License_Registration__c lrDel = [SELECT Id FROM License_Registration__c WHERE Id =: delRecordId];
        delete lrDel;
    }
    
    public void PrintApplication() {
        String printRecordId = ApexPages.currentPage().getParameters().get('printId');
        License_Registration__c lrPrint = [
                SELECT Id, Approved__c, Record_Type_Name__c
                FROM License_Registration__c
                WHERE Id =: printRecordId
        ];

        if (lrPrint.Record_Type_Name__c == 'Public_Works') lrPrint.Send_PW_Affidavit__c = true;
        else lrPrint.Send_Application__c = true;

        update lrPrint;
    }
    
    public void ResendApplication() {
        String resendId = ApexPages.currentPage().getParameters().get('resendId');
        License_Registration__c lrSend = [SELECT Id, Resend_Certificate__c FROM License_Registration__c WHERE Id =: resendId];
        lrSend.Resend_Certificate__c = True;
        update lrSend;
    }
    
    public PageReference SubmitPayment() {
        String recordId = ApexPages.currentPage().getParameters().get('rId');
        PageReference regPage = new PageReference('/apex/CommunityCheckOrACH?id=' + recordId);
        regPage.setRedirect(true);
        return regPage;
    }
    
    public PageReference  RenewRegistration() {
        //CBINOVI 1-24-18 The following clones the Registration and displays it in the form wizard 
        
        PageReference regPage = null;  
        String recordId = null;
        
        try{
            recordId = ApexPages.currentPage().getParameters().get('renewId'); 
        }catch(Exception e){
            System.debug('error in CommunityRegistration:' + e);
        }
        
        if(recordid=='' || recordid==null){
            System.debug('inside if--');
            recordId = ApexPages.currentPage().getParameters().get('publicowrksrenewid'); 
            System.debug('recordid2--'+recordId);            
        }
        
        currentUser = [SELECT Id, userType , ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //Clone License Registration
            DescribeSObjectResult describeResult = License_Registration__c.sObjectType.getDescribe();
            
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            String query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' ID = :recordId ' +
              ' '
            ;
            
            //Set overriden values for cloned registration
            Map<String, String> overrideValue = new Map<String,String>();

            
            
            
            License_Registration__c toCloneLicRegObj = Database.query( query );
            //License_Registration__c newLicenseRegObj = toCloneLicRegObj.clone(false, false, false, false);
            sObject newLicenseRegObj = toCloneLicRegObj.clone(false, false, false, false);
            string recType = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosById().get(toCloneLicRegObj.RecordTypeId).getName();

            //get overrides
            //Map<String,Registration_Renewal_Field_Override__mdt> renewFieldMap = new Map<String,Registration_Renewal_Field_Override__mdt>();
            for(Registration_Renewal_Field_Override__mdt mdt : [SELECT ID, Registration_Record_Type__c, Field_API_Name__c, Value__c FROM Registration_Renewal_Field_Override__mdt]){
                if(String.isBlank(mdt.Registration_Record_Type__c) || (mdt.Registration_Record_Type__c != null && recType == mdt.Registration_Record_Type__c)){
                    //renewFieldMap.put(mdt.Field_API_Name__c + ':' + mdt.Registration_Record_Type__c, mdt);
                    //Dynamically adding field key/value.
                    if( mdt.Value__c == 'true'){
                        newLicenseRegObj.put(mdt.Field_API_Name__c, True);
                    }
                    Else IF (mdt.Value__c == 'False'){
                        newLicenseRegObj.put(mdt.Field_API_Name__c, False);
                    }
                    /*
                    Else If (mdt.Value__c.isNumeric()){
                        newLicenseRegObj.put(mdt.Field_API_Name__c, decimal.valueOf(mdt.Value__c));
                    }
                    */
                    Else{
                        newLicenseRegObj.put(mdt.Field_API_Name__c, mdt.Value__c);
                    }
                    
                    System.debug('##### Added to NewLicenseRegObj built from mdt: ' + mdt.Field_API_Name__c + ' , ' + mdt.Value__c);
                }
            }
            
            newLicenseRegObj.put('Original_Registration__c', recordId);
            newLicenseRegObj.put('License_Registration_Number__c', toCloneLicRegObj.License_Registration_number__c);
            
            //Changes done for bug TC-25077 - Don't copy effective date and expiration date for public works
            if(recType!='Public Works'){
            newLicenseRegObj.put('Effective_Date__c', toCloneLicRegObj.Expiration_Date__c);
            newLicenseRegObj.put('Expiration_Date__c', toCloneLicRegObj.Expiration_Date__c.addYears(1));    
            }  
            
            //tk 04/26/2019 - CPS changes          
            if(toCloneLicRegObj.Record_Type_Name__c == 'Child_Performer_Services'){
                newLicenseRegObj.put('Expiration_Date__c', toCloneLicRegObj.Expiration_Date__c.addYears(2));
            }
            //B-000268
            //SR-007758
            
            System.debug('#####toCloneLicRegObj.Record_Type_Name__c:' + toCloneLicRegObj.Record_Type_Name__c);
            
            if(toCloneLicRegObj.Record_Type_Name__c == 'Entertainment_Work'){
                System.debug('#####toCloneLicRegObj.Status__c:' + toCloneLicRegObj.Status__c);
                newLicenseRegObj.put('Override_Default_Effective_Date__c', FALSE);
                newLicenseRegObj.put('Override_Default_Expiration_Date__c', FALSE);
                if(toCloneLicRegObj.Status__c == 'Expired'){
                    newLicenseRegObj.put('Effective_Date__c', Date.today());
                    newLicenseRegObj.put('Expiration_Date__c', Date.today().addMonths(6));
                }
                else{
                    newLicenseRegObj.put('Expiration_Date__c', toCloneLicRegObj.Expiration_Date__c.addMonths(6));
                }
            }
            
            newLicenseRegObj.put('Renewal__c', True);
            newLicenseRegObj.put('Internal_Notes__c', NULL);
            newLicenseRegObj.put('Ready_To_Submit__c', NULL);
            newLicenseRegObj.put('Ready_to_resubmit__c', NULL);
            newLicenseRegObj.put('Assigned_Deputy__c', NULL);
            newLicenseRegObj.Put('Imported_From__c', NULL);
            newLicenseRegObj.Put('Submitted__c', False);
            if(currentUser.UserType == 'CspLitePortal'){
                newLicenseRegObj.put('Submission_Type__c', 'Online');
            }
            Else{
                newLicenseRegObj.put('Submission_Type__c' , 'Paper');
            }
            If (toCloneLicRegObj.VIP_Template_Status__c != null)
            newLicenseRegObj.put('VIP_Template_Status__c', toCloneLicRegObj.VIP_Template_Status__c.Replace('Completed', 'Incomplete'));
            
            // tk 09/06/2018 SR-004558, SR-004501
            newLicenseRegObj.Put('Approval_Date_Time__c', NULL);
            newLicenseRegObj.Put('Approved__c', false);
            
            // tk 04/26/2019 CPS changes
            newLicenseRegObj.Put('isConvicted__c', NULL);
            // tk 5/14/2019 B-000224
            newLicenseRegObj.Put('I_Acknowledge_Labor_Code_Compliance__c', NULL);
            
            //Perry Security Settings Changes - set Renewer the new Submitter
            if(recType == 'Public Works'){
                newLicenseRegObj.put('Applicant__c', currentUser.ContactId);
            }            
            
            System.debug('##### Ready to insert NewLicenseRegObj: ' + newLicenseRegObj);
            insert newLicenseRegObj;
            
            // tk 05/10/2019 CPS changes
            //Clone Live Scan Data
            describeResult = Live_Scan__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
                ' SELECT ' +
                String.join( fieldNames, ',' ) +
                ' FROM ' +
                describeResult.getName() +
                ' WHERE ' +
                ' Registration__c = :recordId ' +
                ' '
                ;               
            List<Live_Scan__c> toLiveScanList = Database.query( query ); 
            
            List<Live_Scan__c> newLiveScanList = new List<Live_Scan__c>(); 
            for(Live_Scan__c toLiveScanObj: toLiveScanList){
                Live_Scan__c newLiveScanObj = toLiveScanObj.clone(false, true, false, false);
                newLiveScanObj.Registration__c = newLicenseRegObj.Id;
                newLiveScanList.add(newLiveScanObj);
            }
            insert newLiveScanList;   
            
            //Clone Bond
            describeResult = Bond__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
              ' '
            ;
            List<Bond__c> toCloneBondList = Database.query( query );                                        
                                            
            List<Bond__c> newBondObjList = new List<Bond__c>(); 
            for(Bond__c toCloneBondObj: toCloneBondList){
                Bond__c newBondObj = toCloneBondObj.clone(false, false, false, false);
                newBondObj.Registration__c = newLicenseRegObj.Id;
                newBondObjList.add(newBondObj);
            }
            insert newBondObjList;
            
            //Clone Attachment
            /*
            describeResult = Attachment.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' ParentId = :recordId ' +
              ' '
            ;
            
            List<Attachment> toAttachmentList =  Database.query( query ); 
                                            
                                            
            List<Attachment> newAttachmentList = new List<Attachment>(); 
            for(Attachment toAttachmentObj: toAttachmentList){
                Attachment newAttachmentObj = toAttachmentObj.clone(false, true, false, false);
                newAttachmentObj.ParentId = newLicenseRegObj.Id;
                newAttachmentList.add(newAttachmentObj);
            }
            insert newAttachmentList;       
            
    
            //Clone Attachment Plus (Submission Detail)
            describeResult = Attachments_Plus__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
              ' '
            ;           
            List<Attachments_Plus__c> toAttachmentsPlusList = Database.query( query ); 
            
            //Clone Attachment (related to Submission Detail)
            Set<Id> attPlusIds = new Set<Id>();
            for(Attachments_Plus__c ap: toAttachmentsPlusList) {
               attPlusIds.add(ap.Id); 
                
            }
            
            if(attPlusIds.size() > 0) {
                LIST <ContentDocumentLink> cdl = [ SELECT Id, ContentDocumentId, ShareType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :attPlusIds];
                Map<Id, ContentDocumentLink> ContentDocumentLinkMap = new Map<Id, ContentDocumentLink>();                             
                for(ContentDocumentLink c: cdl) {
                    ContentDocumentLinkMap.put(c.LinkedEntityId, c);
                }
    
    
                List<Attachments_Plus__c> newAttachmentsPlusList = new List<Attachments_Plus__c>(); 
                for(Attachments_Plus__c toAttachmentsPlusObj: toAttachmentsPlusList){
                    Attachments_Plus__c newAttachmentsPlusObj = toAttachmentsPlusObj.clone(false, true, false, false);
                    newAttachmentsPlusObj.Registration__c = newLicenseRegObj.Id;
                    newAttachmentsPlusObj.Clone_For__c = toAttachmentsPlusObj.Id;
                    newAttachmentsPlusObj.Number_of_Attachments__c = null;
                    newAttachmentsPlusObj.Attachment_Needed__c = '';
                    newAttachmentsPlusList.add(newAttachmentsPlusObj);
                }
            
                insert newAttachmentsPlusList;  
               
                List<Attachments_Plus__c> ClonedAttachmentsPlus = [SELECT Id, Clone_For__c FROM Attachments_Plus__c WHERE Id IN: newAttachmentsPlusList];                               
                List<ContentDocumentLink> ContentDocumentLinkToClone = new List<ContentDocumentLink>();
                for(Attachments_Plus__c ap: ClonedAttachmentsPlus) {
                    if(ContentDocumentLinkMap.containsKey(ap.Clone_For__c)) {
                        ContentDocumentLink cdlToClone = ContentDocumentLinkMap.get(ap.Clone_For__c);
                        ContentDocumentLink newContentDocumentLink = cdlToClone.clone(false, true, false, false);
                        newContentDocumentLink.LinkedEntityId = ap.Id;
                        
                        ContentDocumentLinkToClone.add(newContentDocumentLink);
                    }
                }
                insert ContentDocumentLinkToClone;
                
            }
            */
            
            //Clone Registration Accounts
            describeResult = Registration_Account__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
              ' '
            ;               
            List<Registration_Account__c> toRegistrationAccountsList = Database.query( query ); 
                                            
            List<Registration_Account__c> newRegistrationAccountsList = new List<Registration_Account__c>(); 
            for(Registration_Account__c toRegistrationAccountsObj: toRegistrationAccountsList){
                Registration_Account__c newRegistrationAccountsObj = toRegistrationAccountsObj.clone(false, true, false, false);
                newRegistrationAccountsObj.Registration__c = newLicenseRegObj.Id;
                newRegistrationAccountsList.add(newRegistrationAccountsObj);
            }
            insert newRegistrationAccountsList;   
            
            //Clone DBA's :code starts
            describeResult = DBA__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
              ' '
            ;               
            List<DBA__c> toDBAList = Database.query( query ); 
                                            
            List<DBA__c> newDBAList = new List<DBA__c>(); 
            for(DBA__c toDBAObj: toDBAList){
                DBA__c newDBAObj = toDBAObj.clone(false, true, false, false);
                newDBAObj.Registration__c = newLicenseRegObj.Id;
                if(newDBAObj.Active__c == 'Yes')
                {    
                newDBAList.add(newDBAObj);
                }
            }
            insert newDBAList; 
            //Clone DBA's :code ends
            //Clone Registration Locations
            describeResult = Registration_Location__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
              ' '
            ;                           
            List<Registration_Location__c> toRegistrationLocationList = Database.query( query );                                            
                                            
            List<Registration_Location__c> newRegistrationLocationList = new List<Registration_Location__c>(); 
            for(Registration_Location__c toRegistrationLocationObj: toRegistrationLocationList){
                Registration_Location__c newRegistrationLocationObj = toRegistrationLocationObj.clone(false, true, false, false);
                newRegistrationLocationObj.Registration__c = newLicenseRegObj.Id;
                if(newRegistrationLocationObj.Date_Deactivated__c == Null || newRegistrationLocationObj.Date_Deactivated__c > date.today() )
                    newRegistrationLocationList.add(newRegistrationLocationObj);
            }
            insert newRegistrationLocationList;         
    
    
            //Clone Owner
            describeResult = Ownership__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' Registration__c = :recordId ' +
              ' '
            ;                   
            List<Ownership__c> toOwnershipList = Database.query( query ); 
                                            
            List<Ownership__c> newOwnershipList = new List<Ownership__c>(); 
            for(Ownership__c toOwnershipObj: toOwnershipList){
                Ownership__c newOwnershipObj = toOwnershipObj.clone(false, true, false, false);
                newOwnershipObj.Registration__c = newLicenseRegObj.Id;
                newOwnershipList.add(newOwnershipObj);
            }
            insert newOwnershipList;     
            
            //Clone License Registrations
            describeResult = License_Registration__c.sObjectType.getDescribe();
            
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
              ' SELECT ' +
                  String.join( fieldNames, ',' ) +
              ' FROM ' +
                  describeResult.getName() +
              ' WHERE ' +
                  ' License__c = :recordId ' +
              ' '
            ;
            List<License_Registration__c> toCloneLicenseList = Database.query( query );                                        
                                            
            List<License_Registration__c> newLicenseObjList = new List<License_Registration__c>(); 
            for(License_Registration__c toCloneLicenseObj: toCloneLicenseList){
                License_Registration__c newLicenseObj = toCloneLicenseObj.clone(false, false, false, false);
                newLicenseObj.License__c = newLicenseRegObj.Id;
                newLicenseObjList.add(newLicenseObj);
            }
            insert newLicenseObjList;            
            
            //Update existing record
            if(recType!='Public Works'){
              toCloneLicRegObj.Status__c = 'Renewed';  
            }else{
              toCloneLicRegObj.Renewal_Registration__c = newLicenseRegObj.id;   
            }    
            
            if(!Test.isRunningTest())
            update toCloneLicRegObj;

            //Redirect Page    
            If( currentUser.UserType == 'CspLitePortal'){
                regPage = new PageReference('/registrations/VIPForm__VIP_FormWizard?id=' + newLicenseRegObj.Id);
            }
            else{
                regPage = new PageReference('/apex/VIPForm__VIP_FormWizard?id=' + newLicenseRegObj.Id);
            }
            regPage.setRedirect(true);

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'OPTIONAL MESSAGE'));
        }
        catch(Exception e) {
            Database.RollBack(sp);
            ApexPages.addMessages(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ADDITIONAL MESSAGE'));
        }

        return regPage;

    }
    
    
    public List<SelectOption> getRegistrationRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select','Select One...'));
        for( RecordType rt: registrationRecordTypes ) {
            if(rt.Name == 'Child Performer Services') { 
                options.add(new SelectOption(rt.Id,'Child Performer Services (Providers)'));
            }
            else if(rt.Name == 'Entertainment Work') {
                options.add(new SelectOption(rt.Id,'Entertainment Work (Minors)'));
            }
            else {
                options.add(new SelectOption(rt.Id,rt.Name)); 
            }
        }
        return options;
    }
    
    public void closePopup() {        
        displayPopup = false;    
    } 
    
    public pagereference checkActiveRegistration() {  
        
        if(currentRecordType=='Select'){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a valid Registration Type from the dropdown menu above.');
            ApexPages.addMessage(msg);
            return null;             
        }
        
        PageReference regPageRef;
        string currenttype = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosById().get(currentRecordType).getName();
        if(currenttype == 'Public Works'){
            currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            List<License_Registration__c> reglst = [SELECT Id, Status__c FROM License_Registration__c 
                                                    WHERE Applicant__c =: currentUser.ContactId
                                                    AND Status__c ='Active' 
                                                    AND License_Registration_Type__c='Public Works'];
            if(!regLst.isEmpty()){                                        
                displayPopup = true;                 
            }else{
                regPageRef = AddRegistration();
            }  
        }else{
            regPageRef = AddRegistration();
        }
        if(regPageRef != null)
            return regPageRef;
        else
            return null; 
    }
    /*public PageReference AddRegistrationnew() {
        PageReference regPage1 = AddRegistration();
        if(regPage1 != null)
            return regPage1 ;
        else
        return null;
    }*/
    public PageReference AddRegistration() {
        try{
            License_Registration__c newRegistration = new License_Registration__c();
            newRegistration.RecordTypeId = currentRecordType;
            newRegistration.Account__c = currentUser.Contact.AccountId;
            newRegistration.Applicant__c = currentUser.ContactId;
            newRegistration.Status__c = 'Incomplete';
            //newRegistration.License_Registration_Type__c = 'Car Wash';
            newRegistration.License_Registration_Type__c = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosById().get(currentRecordType).getName();
            newRegistration.License_Registration_Number__c = 'XXXXXX';
            newRegistration.VIP_Template__c = templateIdMap.get(currentRecordType);
            if(dupRecordFound){
                newRegistration.Dup_Found_Proceed__c='Yes';
            }
            insert newRegistration;
            
            PageReference regPage = new PageReference('/VIPForm__VIP_FormWizard?id=' + newRegistration.Id);//?id=' + newRegistration.Id);
            regPage.setRedirect(true);
            return regPage;
         }catch(Exception e){
             System.debug('error in CommunityRegistration:' + e);
//             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a valid Registration Type from the dropdown menu below.');
//             ApexPages.addMessage(msg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
             return null;
         }

    }
    
    public PageReference LinkRegistration() {
        PageReference regPage = new PageReference('/CommunityRegistrationLink');
        regPage.setRedirect(true);
        return regPage;
    }
    
    /*public List<License_Registration__c> getAllRegistrations() {
        return [SELECT Id, Account__c, Account__r.Name, License_Registration_Number__c,
            Submitted_Date__c, Status__c, Expiration_Date__c 
                FROM License_Registration__c WHERE Account__c =: currentUser.Contact.AccountId];
    }*/

    public void sendLicenseRegistrationPermitPDF() {
        String permitRecordId = ApexPages.currentPage().getParameters().get('permitId');
        License_Registration__c lrSendPDF = [
            SELECT Id, Approved__c, Record_Type_Name__c
            FROM License_Registration__c
            WHERE Id =: permitRecordId
        ];
        
        if (lrSendPDF.Record_Type_Name__c == 'Entertainment_Work' || lrSendPDF.Record_Type_Name__c == 'Child_Performer_Services' || lrSendPDF.Record_Type_Name__c == 'Janitorial'  || lrSendPDF.Record_Type_Name__c == 'Car_Wash' || lrSendPDF.Record_Type_Name__c == 'Talent_Agency') 
        {
            lrSendPDF.Send_License_Registration_Permit_Boolean__c = true;
        }
        
        update lrSendPDF;
    }
}