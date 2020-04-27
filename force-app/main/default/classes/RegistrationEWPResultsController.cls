/********************************************************************************************************
Name:  RegistrationResultsController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  11/01/2017

VF Page: RegistrationSearchResults.page
Test class: RegistrationResultsControllerTest.cls

Behavior:
Filter Registration search by attributes so that it can narrow down to particular Registrations user is looking for. 

Changes
Touk Ken 06/27/2018 - add car wash and janitorial as parameters      
********************************************************************************************************/

global class RegistrationEWPResultsController {

    public String searchString {get; set;}
    public License_Registration__c dummyLicenseRegistration {get; set;}
    public RegistrationEWPSearchController.searchClass searchClassObj {get; set;}
    public String selectedRecordType {get; set;}

    // class constructor, executes first, as soon as the class is invoked
    global RegistrationEWPResultsController() {      

        searchClassObj = new RegistrationEWPSearchController.searchClass();
        searchClassObj.selectedRecordType = ApexPages.currentPage().getParameters().get('selectedRecordType');
        searchClassObj.registrationNumberStr = ApexPages.currentPage().getParameters().get('registrationNumberStr');
        searchClassObj.locationZipStr  = ApexPages.currentPage().getParameters().get('locationZipStr'); 
    }
    
    // Remote action called from RegistrationEWPResults.page via javascript function getAllRegistrations()
    @RemoteAction
    global static List<wrapRegistrationAccounts> getAllRegistrations(String registrationNumberStr, String selectedRecordType, String locationZipStr) {
        List<Registration_Account__c> allReg = new List<Registration_Account__c>();
        List<wrapRegistrationAccounts> wrapRALists = new List<wrapRegistrationAccounts>();
        
        if(String.isEmpty(registrationNumberStr) && String.isEmpty(selectedRecordType) && String.isEmpty(locationZipStr) ) {
            
        } else {
            Date todaydate = Date.Today();
            String query = 'SELECT'
                + ' Id'
                + ' ,  First_Name__c'
                + ' ,  Middle_Name__c'
                + ' ,  Last_Name__c'
                + ' ,  Stage_Name__c'
                + ' ,  RecordType.Name'
                + ' ,  Registration__r.License_Registration_Number__c'
                + ' ,  Registration__r.Effective_Date__c'
                + ' ,  Registration__r.Expiration_Date__c'
                + ' ,  Registration__r.Status__c'
                + ' FROM Registration_Account__c'
                + ' WHERE ( (Registration__r.Status__c = \'Approved\')'
                + '  OR ( Registration__r.Status__c = \'Closed - Renewed\')' 
                + '  OR ( Registration__r.Status__c = \'Renewed\' ) )'
                + ' AND Registration__r.License_Registration_Number__c like ' + '\'%' + registrationNumberStr + '\''
                + ' AND Residential_Zip_Code__c = ' + '\'' + locationZipStr + '\''
                + ' AND RecordType.Name = \'Individual Permit\''
                + ' AND Registration__r.Expiration_Date__c >=: todaydate ';

            //System.debug('*********selectedRecordType:' + selectedRecordType);
            if(!String.isEmpty(selectedRecordType)) {
                //System.debug('*********selectedRecordType:' + selectedRecordType);
                query += ' AND Registration__r.License_Registration_Type__c = \'' + selectedRecordType + '\' ';
            }
            
            query += ' ORDER BY Name DESC';
            System.debug('Query=======>'+query);
                allReg = Database.query(query);
        }

        String RegistrationNum = '';
        String Status = '';
        String MinorNm = '';
        String StageNm = '';
        Date EffectiveDate = NULL;
        Date ExpirationDate = NULL;

        for(Registration_Account__c eachRegistration: allReg){
            RegistrationNum = eachRegistration.Registration__r.License_Registration_Number__c;
            Status = eachRegistration.Registration__r.Status__c;
            EffectiveDate  = eachRegistration.Registration__r.Effective_Date__c;
            ExpirationDate = eachRegistration.Registration__r.Expiration_Date__c;

            if(eachRegistration.RecordType.Name == 'Individual Permit'){
                eachRegistration.First_Name__c = eachRegistration.First_Name__c == NULL ? '' : eachRegistration.First_Name__c;
                eachRegistration.Middle_Name__c = eachRegistration.Middle_Name__c == NULL ? '' : eachRegistration.Middle_Name__c;
                eachRegistration.Last_Name__c = eachRegistration.Last_Name__c == NULL ? '' : eachRegistration.Last_Name__c;
                StageNm = eachRegistration.Stage_Name__c == NULL ? '' : eachRegistration.Stage_Name__c;
                MinorNm = eachRegistration.First_Name__c + ' ' + eachRegistration.Middle_Name__c + ' ' + eachRegistration.Last_Name__c;
            }
            wrapRALists.add(new wrapRegistrationAccounts(RegistrationNum, Status, MinorNm, StageNm, EffectiveDate, ExpirationDate));
        }
        return wrapRALists;
    }
    
    // action called from "Return to Search" btn (RegistrationEWPResults.page)
    public PageReference BackToSearch() {
        PageReference searchPage = new PageReference('/apex/RegistrationEWPSearch');
        searchPage.setRedirect(true);
        return searchPage;
    }

    global class wrapRegistrationAccounts{
        public String RegistrationNum {get;set;}
        public String Status {get;set;}
        public String MinorName {get;set;}
        public String StageName {get;set;}
        public Date EffectiveDte {get;set;}
        public Date ExpirationDte {get;set;}
        
        public wrapRegistrationAccounts(String sRegistrationNum, String sStatus, String sMinorName, String sStageName, Date sEffectiveDte, Date sExpirationDte){
            RegistrationNum = sRegistrationNum;
            Status = sStatus;
            MinorName = sMinorName;
            StageName = sStageName;
            EffectiveDte = sEffectiveDte;
            ExpirationDte = sExpirationDte;
        }
    }
}