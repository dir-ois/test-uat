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

global class RegistrationEWPSearchController {

    // dummy License_Registration__c Record
    public License_Registration__c dummyLicenseRegistration {get; set;}
    
    public String searchString {get; set;}
   
    public searchClass searchClassObj {get; set;}
    
    private List<RecordType> registrationRecordTypes;
    
    // class constructor, executes first, as soon as the class is invoked
    global RegistrationEWPSearchController () {
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
        searchClassObj.effectiveDate = NULL;
        searchClassObj.expirationDate = NULL;
        searchClassObj.selectedRecordType = '';
        
        
    } 

    // sends all inserted values as parameters and rediredcts to RegistrationSearchResults.page
    public PageReference SearchRegistration() {
        
        PageReference resultsPage = new PageReference('/apex/RegistrationEWPResults');
        if(!String.isEmpty(searchClassObj.registrationNumberStr)) 
            resultsPage.getParameters().put('registrationNumberStr', searchClassObj.registrationNumberStr);        
        if(!String.isEmpty(searchClassObj.locationZipStr)) 
            resultsPage.getParameters().put('locationZipStr', searchClassObj.locationZipStr);        
        
        // tken 06/27/2018
        if(!String.isEmpty(searchClassObj.selectedRecordType )) 
            resultsPage.getParameters().put('selectedRecordType', String.valueof(searchClassObj.selectedRecordType ));
        
        resultsPage.setRedirect(true);
        return resultsPage;
    }
    
    
    public class searchClass {
        public String registrationNumberStr { get; set; }
        public Date effectiveDate { get; set; }
        public Date expirationDate { get; set; }
        public String locationZipStr { get; set; }
        public String selectedRecordType { get; set; }
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
        options.add(new SelectOption('Entertainment Work','Entertainment Work'));
        return options;
    }  
    
}