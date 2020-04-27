/********************************************************************************************************
Name:  RegistrationSearchController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  12/15/2017
VF Page: RegistrationSearch.page
Test class: RegistrationSearchControllerTest.cls

Behavior:
    Filter registrations search by registration attributes so that it can narrow down to particular registrations user is looking for. 
    Registration attributes include Date Range of PAGA Notice Filed, employer city, employer zip code, court name, 
    court case number, and the type of violation.
       
********************************************************************************************************/

global class RegistrationSearchController {

    // dummy License_Registration__c Record
    public License_Registration__c dummyLicenseRegistration {get; set;}
    
    public String searchString {get; set;}
   
    public searchClass searchClassObj {get; set;}
    
    private List<RecordType> registrationRecordTypes;
    
    // class constructor, executes first, as soon as the class is invoked
    global RegistrationSearchController () {
        //Id pagaRTId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        if(dummyLicenseRegistration == null) {
            dummyLicenseRegistration = new License_Registration__c();
            
        }
        searchString = '';
        
        ClearFields();
        
        // get registration types
        List<String> devNames = new List<String>();
        for(Registration_Template_Mapping__mdt mdt : [select id,DeveloperName,Record_Type_Developer_Name__c,Template_ID__c from Registration_Template_Mapping__mdt]){
            devNames.add(mdt.Record_Type_Developer_Name__c);
        }
        
        // get record types
        registrationRecordTypes = new List<RecordType>();
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='License_Registration__c' AND DeveloperName IN :devNames AND IsActive = true ORDER BY Name ASC]){
            if (rt.Name == 'Public Works') continue;
            registrationRecordTypes.add(rt);
        }
        
    }
    
    // clears all the fields on Search page
    public void ClearFields() {
        searchClassObj = new searchClass();
        searchClassObj.registrationNumberStr = '';
        searchClassObj.legalEntityStr = '';
        searchClassObj.effectiveDate = NULL;
        searchClassObj.effectiveDateStart = NULL;
        searchClassObj.effectiveDateEnd = NULL;
        searchClassObj.expirationDateStart = NULL;
        searchClassObj.expirationDateEnd = NULL;
        searchClassObj.expirationDate = NULL;
        searchClassObj.dbaNameStr = '';
        searchClassObj.locationAddressStr = '';
        searchClassObj.locationCityStr = '';
        searchClassObj.locationStateStr = '';
        searchClassObj.locationZipStr = '';
        searchClassObj.workersCompTypeStr = '';
        searchClassObj.workersCompInsurerStr = '';
        searchClassObj.bondIssuerStr = '';
        searchClassObj.bondEffectiveStart = NULL;
        searchClassObj.bondEffectiveEnd = NULL;
        //searchClassObj.registrationRecordTypes = NULL;
        searchClassObj.selectedRecordType = '';
        searchClassObj.selectedStatus = '';        
    } 
    
    
    // sends all inserted values as parameters and rediredcts to RegistrationSearchResults.page
    public PageReference SearchRegistration() {
        
        PageReference resultsPage = new PageReference('/apex/RegistrationResults');
        // Legal_Entity_Name__c, Last_Name__c

        if(!String.isEmpty(searchClassObj.registrationNumberStr)) 
            resultsPage.getParameters().put('registrationNumberStr', searchClassObj.registrationNumberStr);        
        if(!String.isEmpty(searchClassObj.legalEntityStr)) 
            resultsPage.getParameters().put('legalEntityStr', searchClassObj.legalEntityStr);        
        if(searchClassObj.effectiveDateStart != NULL) 
            resultsPage.getParameters().put('effectiveDateStart', String.valueof(searchClassObj.effectiveDateStart));
        if(searchClassObj.effectiveDateEnd != NULL) 
            resultsPage.getParameters().put('effectiveDateEnd', String.valueof(searchClassObj.effectiveDateEnd));     
        if(searchClassObj.expirationDateStart != NULL) 
            resultsPage.getParameters().put('expirationDateStart', String.valueof(searchClassObj.expirationDateStart));
        if(searchClassObj.expirationDateEnd != NULL) 
            resultsPage.getParameters().put('expirationDateEnd', String.valueof(searchClassObj.expirationDateEnd));            
        if(!String.isEmpty(searchClassObj.dbaNameStr)) 
            resultsPage.getParameters().put('dbaNameStr', searchClassObj.dbaNameStr);        
        if(!String.isEmpty(searchClassObj.locationAddressStr)) 
            resultsPage.getParameters().put('locationAddressStr', searchClassObj.locationAddressStr);        
        if(!String.isEmpty(searchClassObj.locationCityStr)) 
            resultsPage.getParameters().put('locationCityStr', searchClassObj.locationCityStr);        
        if(!String.isEmpty(searchClassObj.locationStateStr)) 
            resultsPage.getParameters().put('locationStateStr', searchClassObj.locationStateStr);        
        if(!String.isEmpty(searchClassObj.locationZipStr)) 
            resultsPage.getParameters().put('locationZipStr', searchClassObj.locationZipStr);        
        /*if(!String.isEmpty(searchClassObj.workersCompTypeStr)) 
            resultsPage.getParameters().put('workersCompTypeStr', searchClassObj.workersCompTypeStr);        
        if(!String.isEmpty(searchClassObj.workersCompInsurerStr)) 
            resultsPage.getParameters().put('workersCompInsurerStr', searchClassObj.workersCompInsurerStr);        
        if(!String.isEmpty(searchClassObj.bondIssuerStr)) 
            resultsPage.getParameters().put('bondIssuerStr', searchClassObj.bondIssuerStr);        
        if(searchClassObj.bondEffectiveStart != NULL) 
            resultsPage.getParameters().put('bondEffectiveStart', String.valueof(searchClassObj.bondEffectiveStart));  
        if(searchClassObj.bondEffectiveEnd != NULL) 
            resultsPage.getParameters().put('bondEffectiveEnd', String.valueof(searchClassObj.bondEffectiveEnd));*/         
         // tken 06/27/2018
         if(!String.isEmpty(searchClassObj.selectedRecordType )) 
            resultsPage.getParameters().put('selectedRecordType', String.valueof(searchClassObj.selectedRecordType ));
        if(!String.isEmpty(searchClassObj.selectedStatus )) 
            resultsPage.getParameters().put('selectedStatus', String.valueof(searchClassObj.selectedStatus ));       
        resultsPage.setRedirect(true);
        return resultsPage;
    }
    
    
    public class searchClass {
        public String registrationNumberStr { get; set; }
        public String legalEntityStr { get; set; }
        public Date effectiveDate { get; set; }
        public Date expirationDate { get; set; }
        public Date effectiveDateStart { get; set; }
        public Date effectiveDateEnd { get; set; }
        public Date expirationDateStart { get; set; }
        public Date expirationDateEnd { get; set; }
        public String dbaNameStr { get; set; }
        public String locationAddressStr { get; set; }
        public String locationCityStr { get; set; }
        public String locationStateStr { get; set; }
        public String locationZipStr { get; set; }
        public String workersCompTypeStr { get; set; }
        public String workersCompInsurerStr { get; set; }
        public String bondIssuerStr { get; set; }
        public Date bondEffectiveStart { get; set; }
        public Date bondEffectiveEnd { get; set; }
        //private List<RecordType> registrationRecordTypes;
        public String selectedRecordType { get; set; }
        public String selectedStatus { get; set; }
    }
    
    
    public List<SelectOption> getcompType()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = License_Registration__c.Workers_Comp_Selection__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
       options.add(new SelectOption('', ''));     
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
 
    public List<SelectOption> getRegistrationRecordTypes() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select','Select One...'));
        options.add(new SelectOption('Car Wash','Car Wash'));
        options.add(new SelectOption('Janitorial','Janitorial'));
        options.add(new SelectOption('Talent Agency','Talent Agency'));
        return options;
    }
    
    public List<SelectOption> getRegistrationStatus() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Approved','Approved'));
        options.add(new SelectOption('Closed - Revoked','Closed - Revoked'));
        return options;
    } 
}