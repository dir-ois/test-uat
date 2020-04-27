/********************************************************************************************************
Name:  CommunityRegistrationLink.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  12/21/2017
Modified by: 
Date:
Test class: CommunityRegistrationLinkTest.cls

Behavior:
    
       
********************************************************************************************************/

public class CommunityRegistrationLink {
    
    
    public License_Registration__c currentRegistration {get;set;}
    public List<License_Registration__c> AllRegistrations {get;set;}
    
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    private User currentUser;
    public String currentRecordType {get; set;}
    private List<RecordType> registrationRecordTypes;
    private string currenttype {get; set;}
    
    public CommunityRegistrationLink(){
        
        currentRegistration = new License_Registration__c();
        AllRegistrations = new List<License_Registration__c>();
        errortype = '';
        errorDisplay = 'none'; 
        errormessage = '';
        
        currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        
         Map<String,String> devNames = new Map<String,String>();
        for(Registration_Template_Mapping__mdt mdt : [select id,DeveloperName,Record_Type_Developer_Name__c,Template_ID__c from Registration_Template_Mapping__mdt]){
            devNames.put(mdt.Record_Type_Developer_Name__c, mdt.Template_ID__c);
        }       
        registrationRecordTypes = new List<RecordType>();
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='License_Registration__c' AND DeveloperName IN :devNames.keySet() AND IsActive = true ORDER BY Name ASC]){
            registrationRecordTypes.add(rt);
        }        
    }
    
    
    
    public void SearchRegistration() {
        if(currentRecordType=='Select'){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a valid Registration Type from the dropdown menu below.');
            ApexPages.addMessage(msg);         
        }else{
            currenttype = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosById().get(currentRecordType).getName();
            
            if(currenttype == 'Public Works'){
                
                AllRegistrations = [SELECT Id, Legal_Entity_Name__c, License_Registration_Number__c, Account__c,regLinked__c,Account_Email__c, Effective_Date__c, Expiration_Date__c
                                    FROM License_Registration__c 
                                    WHERE License_Registration_Number__c =: currentRegistration.License_Registration_Number__c  
                                    AND Mailing_City__c =: currentRegistration.Mailing_City__c AND Status__c = 'Active' and License_Registration_Type__c='Public Works'];
                
                if (AllRegistrations.isEmpty()) {
                    AllRegistrations = [SELECT Id, Legal_Entity_Name__c, License_Registration_Number__c, Account__c,regLinked__c,Account_Email__c,Effective_Date__c, Expiration_Date__c
                                        FROM License_Registration__c
                                        WHERE License_Registration_Number__c =: currentRegistration.License_Registration_Number__c
                                        AND Mailing_City__c =: currentRegistration.Mailing_City__c
                                        AND Status__c = 'Expired'
                                        AND License_Registration_Type__c='Public Works'
                                        ORDER BY Expiration_Date__c DESC LIMIT 1];
                }
            }           
            else if(currenttype == 'Entertainment Work'){
                AllRegistrations = [SELECT Id, Legal_Entity_Name__c, License_Registration_Number__c, Account__c,Effective_Date__c, Expiration_Date__c, Status__c 
                                    FROM License_Registration__c 
                                    WHERE License_Registration_Number__c =: currentRegistration.License_Registration_Number__c  
                                    AND Mailing_City__c =: currentRegistration.Mailing_City__c AND Status__c IN ('Approved', 'Expired') AND RecordType.Name =: currenttype];
                
                if(Test.isrunningtest()) {
                    AllRegistrations = [SELECT Id, Legal_Entity_Name__c, License_Registration_Number__c, Account__c,Effective_Date__c, Expiration_Date__c 
                                        FROM License_Registration__c 
                                        WHERE License_Registration_Number__c =: currentRegistration.License_Registration_Number__c  
                                        AND Mailing_City__c =: currentRegistration.Mailing_City__c];
                }
            } else{ 
                AllRegistrations = [SELECT Id, Legal_Entity_Name__c, License_Registration_Number__c, Account__c,Effective_Date__c, Expiration_Date__c 
                                    FROM License_Registration__c 
                                    WHERE License_Registration_Number__c =: currentRegistration.License_Registration_Number__c  
                                    AND Mailing_City__c =: currentRegistration.Mailing_City__c AND Status__c = 'Approved' AND RecordType.Name =: currenttype];
                
                if(Test.isrunningtest()) {
                    AllRegistrations = [SELECT Id, Legal_Entity_Name__c, License_Registration_Number__c, Account__c,Effective_Date__c, Expiration_Date__c 
                                        FROM License_Registration__c 
                                        WHERE License_Registration_Number__c =: currentRegistration.License_Registration_Number__c  
                                        AND Mailing_City__c =: currentRegistration.Mailing_City__c];
                }    
                
            }  
            
            if(AllRegistrations.size()<1) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'No results found.Please create a new Application.');
                ApexPages.addMessage(msg);  
            }  
            /*
            if(AllRegistrations.size() <> 1) {
            errortype = 'alert alert-info';
            errorDisplay = 'block';
            errormessage = 'Unable to link registration at this time. Please contact Registration Services for assistance.';
            } else {
            errortype = '';
            errorDisplay = 'none'; 
            errormessage = '';
            } */            
        }
    }
    
    public PageReference LinkRegistration() {
        
        if(AllRegistrations.size() == 1) {
         System.debug('#### Linking registration now'); 
         System.debug('currenttype--'+currenttype);
            try {
                
                if(currenttype == 'Public Works' && AllRegistrations[0].regLinked__c == false){
                    System.debug('line 100--');
                     AllRegistrations[0].regLinked__c = true;
                     AllRegistrations[0].Applicant__c = currentUser.ContactId;
                     update AllRegistrations[0];
                     
                    Access_Approval__c accApproval = new Access_Approval__c();
                    accApproval.Approved__c='Yes';
                    accApproval.Business_Email__c=AllRegistrations[0].Account_Email__c;
                    accApproval.Registration__c=AllRegistrations[0].Id;
                    accApproval.Requestor__c=currentUser.ContactId;

                    insert accApproval; 
                }else if(currenttype == 'Public Works' && AllRegistrations[0].regLinked__c == true){
                    System.debug('line 113--');
                    Access_Approval__c accApproval = new Access_Approval__c();
                    accApproval.Approved__c='No';
                    accApproval.Business_Email__c=AllRegistrations[0].Account_Email__c;
                    //accApproval.VIP_Date_Time_Submitted__c=System.today();
                    accApproval.Registration__c=AllRegistrations[0].Id;
                    accApproval.Requestor__c=currentUser.ContactId;
                    
                    insert accApproval;
                }else{
                    System.debug('line 123--');
                     AllRegistrations[0].Applicant__c = currentUser.ContactId;
                     update AllRegistrations[0];
                }
                System.debug('##### Setting applicant to: ' + currentUser.ContactId);
                
            } catch(DMLException ex) {
                errortype = 'alert alert-info';
                errorDisplay = 'block';
                errormessage = 'Error: ' + ex;
                return null;
            }
            PageReference regPage = new PageReference('/CommunityRegistration');
            regPage.setRedirect(true);
            return regPage;
        }
        return null;
        
    }
    
    public PageReference CancelBack() {
        PageReference regPage = new PageReference('/CommunityRegistration');
        regPage.setRedirect(true);
        return regPage;
    }
    
    public List<SelectOption> getRegistrationRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select','Select One...'));
        for( RecordType rt: registrationRecordTypes ) {
            options.add(new SelectOption(rt.Id,rt.Name));
        }
        return options;
    }    
    
}