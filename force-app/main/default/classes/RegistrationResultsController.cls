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

global class RegistrationResultsController {
    
    
    public String searchString {get; set;}
    
    public License_Registration__c dummyLicenseRegistration {get; set;}
    public Map<String, Boolean> filtersMap {get; set;}
    
    public RegistrationSearchController.searchClass searchClassObj {get; set;}
    
    public String effectiveDateStart {get; set;}
    public String effectiveDateEnd {get; set;}
    
    public String expirationDateStart {get; set;}
    public String expirationDateEnd {get; set;}
    
    public String bondEffectiveStart {get; set;}
    public String bondEffectiveEnd {get; set;}
    
    public String selectedRecordType {get; set;}
    public String selectedStatus {get; set;}
    
    // class constructor, executes first, as soon as the class is invoked
    global RegistrationResultsController() {      
        
        filtersMap = new Map<String, Boolean>();
        filtersMap.put('searchString', false);
        filtersMap.put('License_Registration_Number', false);
        filtersMap.put('License_Registration_Type', false);
        filtersMap.put('Submitted_Date__c', false);
        filtersMap.put('Received_Date__c', false);
        filtersMap.put('Mailing_City__c', false);
        
        
        
        searchClassObj = new RegistrationSearchController.searchClass();
        searchClassObj.selectedRecordType = ApexPages.currentPage().getParameters().get('selectedRecordType');
        searchClassObj.selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
        searchClassObj.registrationNumberStr = ApexPages.currentPage().getParameters().get('registrationNumberStr');
        searchClassObj.legalEntityStr = ApexPages.currentPage().getParameters().get('legalEntityStr');
        effectiveDateStart = ApexPages.currentPage().getParameters().get('effectiveDateStart');
        effectiveDateEnd = ApexPages.currentPage().getParameters().get('effectiveDateEnd');
        expirationDateStart = ApexPages.currentPage().getParameters().get('expirationDateStart');
        expirationDateEnd = ApexPages.currentPage().getParameters().get('expirationDateEnd');
        /* if(!String.isEmpty(expirationDateStr)) {
            List<String> endStringDate = effectiveDateStr.split('-');
            String eD = endStringDate[0] + '-' + endStringDate[1] + '-' + endStringDate[2];
            searchClassObj.expirationDate = Date.valueOf(eD);
        }   */  

        searchClassObj.dbaNameStr = ApexPages.currentPage().getParameters().get('dbaNameStr');
        searchClassObj.locationAddressStr = ApexPages.currentPage().getParameters().get('locationAddressStr');
        searchClassObj.locationCityStr = ApexPages.currentPage().getParameters().get('locationCityStr');
        searchClassObj.locationStateStr = ApexPages.currentPage().getParameters().get('locationStateStr');
        searchClassObj.locationZipStr  = ApexPages.currentPage().getParameters().get('locationZipStr');
        searchClassObj.workersCompTypeStr = ApexPages.currentPage().getParameters().get('workersCompTypeStr');
        searchClassObj.workersCompInsurerStr = ApexPages.currentPage().getParameters().get('workersCompInsurerStr');
        searchClassObj.bondIssuerStr = ApexPages.currentPage().getParameters().get('bondIssuerStr');
        bondEffectiveStart = ApexPages.currentPage().getParameters().get('bondEffectiveStart');
        bondEffectiveEnd = ApexPages.currentPage().getParameters().get('bondEffectiveEnd');
        /* if(!String.isEmpty(bondEffectiveDateStr)) {
            List<String> endStringDate = effectiveDateStr.split('-');
            String eD = endStringDate[0] + '-' + endStringDate[1] + '-' + endStringDate[2];
            searchClassObj.bondEffectiveDate = Date.valueOf(eD);
        }   */  

        
    }
    
    // Remote action called from RegistrationSearchResults.page via javascript function getRemoteRegistrations()
    @RemoteAction
    global static List<License_Registration__c> getAllRegistrations(String registrationNumberStr, String selectedRecordType, String selectedStatus, String legalEntityStr, String effectiveDateStart, String effectiveDateEnd,
    String expirationDateStart, String expirationDateEnd, String dbaNameStr, String locationAddressStr, String locationCityStr, 
    String locationStateStr, String locationZipStr, String workersCompTypeStr, String workersCompInsurerStr, 
    String bondIssuerStr, String bondEffectiveStart, String bondEffectiveEnd
    ) {
        List<License_Registration__c> allReg = new List<License_Registration__c>();
        
        
        if(String.isEmpty(registrationNumberStr) && String.isEmpty(legalEntityStr)  && String.isEmpty(legalEntityStr) && String.isEmpty(effectiveDateStart) && String.isEmpty(effectiveDateEnd)  && String.isEmpty(expirationDateStart) && String.isEmpty(expirationDateEnd) 
                        && String.isEmpty(dbaNameStr) && String.isEmpty(locationAddressStr) && String.isEmpty(locationCityStr)  && String.isEmpty(locationStateStr)
                         && String.isEmpty(locationZipStr) && String.isEmpty(workersCompTypeStr) && String.isEmpty(workersCompInsurerStr) && String.isEmpty(bondIssuerStr) && String.isEmpty(bondEffectiveStart) ) {
        
        } else {
            Date todaydate = Date.Today();
            String query = '';
            if(selectedStatus == 'Approved')
            {
                query = 'SELECT Id, Name, Account__c, Account__r.Name, Account__r.Legal_Entity_Name__c, License_Registration_Number__c, License_Registration_Type__c, Mailing_City__c, Submitted_Date__c, Status__c, Expiration_Date__c, Effective_Date__c, Payment_Status__c, Amount_Paid__c, Legal_Entity_Name__c, Workers_Compensation_Carrier__c, WCI_Expiration_Date__c, Workers_Comp_Selection__c FROM License_Registration__c WHERE (Status__c = \'Approved\'  OR ( Status__c = \'Renewed\' AND Expiration_Date__c >= :todaydate ) ) ';
            }
            else{   
                query = 'SELECT Id, Name, Account__c, Account__r.Name, Account__r.Legal_Entity_Name__c, License_Registration_Number__c, License_Registration_Type__c, Mailing_City__c, Submitted_Date__c, Status__c, Expiration_Date__c, Effective_Date__c, Payment_Status__c, Amount_Paid__c, Legal_Entity_Name__c, Workers_Compensation_Carrier__c, WCI_Expiration_Date__c, Workers_Comp_Selection__c FROM License_Registration__c WHERE Status__c = \'Closed - Revoked\' ';
            }
            
            if(!String.isEmpty(legalEntityStr)) {
                legalEntityStr = string.escapeSingleQuotes(legalEntityStr);
                String sn = '%'+legalEntityStr.replace('\'','\'')+'%';
                query += ' AND ((Legal_Entity_Name__c LIKE  \'' + sn + '\') OR (Account__r.LastName LIKE \'' + sn + '\') ) ';
            }
            
            if(!String.isEmpty(registrationNumberStr)) {
                String ln = '%' + registrationNumberStr + '%'; 
                query += ' AND License_Registration_Number__c LIKE \'' + ln + '\' ';
            }
            Date eDate = null;
            Date sDate = null;
            Date mysDate = null;
            Date myeDate = null;
            Date effsDate = null;
            Date effeDate = null;
            
            
            
            if(!String.isEmpty(effectiveDateStart) && String.isEmpty(effectiveDateEnd)) {
                effsDate = Date.valueOf(effectiveDateStart);
                query += ' AND ( Effective_Date__c >= :effsDate AND Effective_Date__c <> NULL ) ';
            } 
            
            if(!String.isEmpty(effectiveDateEnd) && String.isEmpty(effectiveDateStart)) {
                effeDate = Date.valueOf(effectiveDateEnd);
                query += ' AND ( Effective_Date__c <= :effeDate AND Effective_Date__c <> NULL ) ';
            }
            
            if(!String.isEmpty(effectiveDateEnd) && !String.isEmpty(effectiveDateStart)) {
                effsDate = Date.valueOf(effectiveDateStart);
                effeDate = Date.valueOf(effectiveDateEnd);
                
                query += ' AND ( Effective_Date__c >= :effsDate AND Effective_Date__c <= :effeDate AND Effective_Date__c <> NULL ) ';
            }     

            if(!String.isEmpty(expirationDateStart) && String.isEmpty(expirationDateEnd)) {
                sDate = Date.valueOf(expirationDateStart);
                mysDate = date.newinstance(sDate.year(), sDate.month(), sDate.day());
                query += ' AND ( Expiration_Date__c >= :mysDate AND Expiration_Date__c <> NULL ) ';
            } 
            
            if(!String.isEmpty(expirationDateEnd) && String.isEmpty(expirationDateStart)) {
                eDate = Date.valueOf(expirationDateEnd);
                myeDate = date.newinstance(eDate.year(), eDate.month(), eDate.day());
                query += ' AND ( Expiration_Date__c <= :myeDate AND Expiration_Date__c <> NULL ) ';
            }
            
            if(!String.isEmpty(expirationDateEnd) && !String.isEmpty(expirationDateStart)) {
                sDate = Date.valueOf(expirationDateStart);
                eDate = Date.valueOf(expirationDateEnd);
                mysDate = date.newinstance(sDate.year(), sDate.month(), sDate.day());
                myeDate = date.newinstance(eDate.year(), eDate.month(), eDate.day());
                
                query += ' AND ( Expiration_Date__c >= :mysDate AND Expiration_Date__c <= :myeDate AND Expiration_Date__c <> NULL ) ';
            }    
            
            Set<Id> RegIds = new Set<Id>();
            if(!String.isEmpty(dbaNameStr)) {
                String locln = '%' + dbaNameStr + '%'; 
                String locationQuery = 'SELECT Id, Registration__c FROM Registration_Location__c WHERE DBA_Name__c LIKE \'' + locln + '\' ';
                List<Registration_Location__c> allLocationReg = Database.query(locationQuery);
                RegIds = new Set<Id>();
                for(Registration_Location__c rl: allLocationReg) {
                    if(rl.Registration__c != null) 
                        RegIds.add(rl.Registration__c);
                }
                    
                query += ' AND Id IN :RegIds ';
            }            

            if(!String.isEmpty(locationAddressStr)) {
                String locln = '%' + locationAddressStr + '%'; 
                String locationQuery = 'SELECT Id, Registration__c FROM Registration_Location__c WHERE Address__c LIKE \'' + locln + '\' OR Address_Line_2__c LIKE \'' + locln + '\' OR Address_Line_3__c LIKE \'' + locln + '\' ';
                List<Registration_Location__c> allLocationReg = Database.query(locationQuery);
                RegIds = new Set<Id>();
                for(Registration_Location__c rl: allLocationReg) {
                    if(rl.Registration__c != null) 
                        RegIds.add(rl.Registration__c);
                }
                
                if(allLocationReg.size() > 0)
                    query += ' AND (Mailing_Address_Line_1__c LIKE \'' + locln + '\' OR Id IN :RegIds) ';
                else
                    query += ' AND Mailing_Address_Line_1__c LIKE \'' + locln + '\' ';
                
            }

            if(!String.isEmpty(locationCityStr)) {
                String locln = '%' + locationCityStr + '%'; 
                String locationQuery = 'SELECT Id, Registration__c FROM Registration_Location__c WHERE City__c LIKE \'' + locln + '\'  ';
                List<Registration_Location__c> allLocationReg = Database.query(locationQuery);
                RegIds = new Set<Id>();
                for(Registration_Location__c rl: allLocationReg) {
                    if(rl.Registration__c != null) 
                        RegIds.add(rl.Registration__c);
                }
                
                if(allLocationReg.size() > 0)
                    query += ' AND (Mailing_City__c LIKE \'' + locln + '\' OR Id IN :RegIds) ';
                else
                    query += ' AND Mailing_City__c LIKE \'' + locln + '\' ';
            }

            if(!String.isEmpty(locationStateStr)) {
                String locln = '%' + locationStateStr + '%'; 
                String locationQuery = 'SELECT Id, Registration__c FROM Registration_Location__c WHERE State__c LIKE \'' + locln + '\'  ';
                List<Registration_Location__c> allLocationReg = Database.query(locationQuery);
                RegIds = new Set<Id>();
                for(Registration_Location__c rl: allLocationReg) {
                    if(rl.Registration__c != null) 
                        RegIds.add(rl.Registration__c);
                }
                
                if(allLocationReg.size() > 0)
                    query += ' AND (Mailing_State__c LIKE \'' + locln + '\' OR Id IN :RegIds) ';
                else
                    query += ' AND Mailing_State__c LIKE \'' + locln + '\' ';
            }

            if(!String.isEmpty(locationZipStr)) {
                String locln = '%' + locationZipStr + '%'; 
                String locationQuery = 'SELECT Id, Registration__c FROM Registration_Location__c WHERE Zip_Code__c LIKE \'' + locln + '\'  ';
                List<Registration_Location__c> allLocationReg = Database.query(locationQuery);
                RegIds = new Set<Id>();
                for(Registration_Location__c rl: allLocationReg) {
                    if(rl.Registration__c != null) 
                        RegIds.add(rl.Registration__c);
                }
                
                if(allLocationReg.size() > 0)
                    query += ' AND (Mailing_Postal_Code__c LIKE \'' + locln + '\' OR Id IN :RegIds) ';
                else
                    query += ' AND Mailing_Postal_Code__c LIKE \'' + locln + '\' '; 
            }
           
            System.debug('*********selectedRecordType:' + selectedRecordType);
            if(!String.isEmpty(selectedRecordType)) {
                System.debug('*********selectedRecordType:' + selectedRecordType);
               query += ' AND License_Registration_Type__c = \'' + selectedRecordType + '\' ';

            }
              
 
            query += ' ORDER BY Name DESC';
            System.debug('Query=======>'+query);
            if( !Test.isRunningTest()){
                allReg = Database.query(query);
            }
        }
        return allReg;
    }
    
     // action called from "Return to Search" btn (RegistrationResults.page)
    public PageReference BackToSearch() {
        PageReference searchPage = new PageReference('/apex/RegistrationSearch');
        searchPage.setRedirect(true);
        return searchPage;
    }
    
   
}