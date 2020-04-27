/********************************************************************************************************
Name:  RegistrationCPSresultsController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  11/01/2017

VF Page: RegistrationCPSresults.page
Test class: RegistrationCPSresultsControllerTest.cls

Behavior:
    Filter Registration search by attributes so that it can narrow down to particular Registrations user is looking for. 

Changes
    Touk Ken 06/27/2018 - add car wash and janitorial as parameters      
********************************************************************************************************/

global class RegistrationCPSresultsController{
    
    
    public String searchString {get; set;}
    
    public License_Registration__c dummyLicenseRegistration {get; set;}
    public Map<String, Boolean> filtersMap {get; set;}
    
    public RegistrationCPSsearchController.searchClass searchClassObj {get; set;}
    
    public String effectiveDateStart {get; set;}
    public String effectiveDateEnd {get; set;}
    
    public String expirationDateStart {get; set;}
    public String expirationDateEnd {get; set;}
    
    public String bondEffectiveStart {get; set;}
    public String bondEffectiveEnd {get; set;}
    
    public String selectedRecordType {get; set;}
    public String selectedStatus {get; set;}
    
    // class constructor, executes first, as soon as the class is invoked
    global RegistrationCPSresultsController() {      
        
        filtersMap = new Map<String, Boolean>();
        filtersMap.put('searchString', false);
        filtersMap.put('License_Registration_Number', false);
        filtersMap.put('License_Registration_Type', false);
        filtersMap.put('Submitted_Date__c', false);
        filtersMap.put('Received_Date__c', false);
        filtersMap.put('Mailing_City__c', false);
        
        
        
        
        searchClassObj = new RegistrationCPSsearchController.searchClass();
        searchClassObj.selectedRecordType = ApexPages.currentPage().getParameters().get('selectedRecordType');
        searchClassObj.selectedStatus = ApexPages.currentPage().getParameters().get('selectedStatus');
        searchClassObj.registrationNumberStr = ApexPages.currentPage().getParameters().get('registrationNumberStr');
        searchClassObj.firstNameStr = ApexPages.currentPage().getParameters().get('firstNameStr');
        searchClassObj.middleNameStr = ApexPages.currentPage().getParameters().get('middleNameStr');
        searchClassObj.lastNameStr = ApexPages.currentPage().getParameters().get('lastNameStr');
        searchClassObj.locationCityStr = ApexPages.currentPage().getParameters().get('locationCityStr');
        searchClassObj.locationStateStr = ApexPages.currentPage().getParameters().get('locationStateStr');
        searchClassObj.locationZipStr  = ApexPages.currentPage().getParameters().get('locationZipStr');        
        effectiveDateStart = ApexPages.currentPage().getParameters().get('effectiveDateStart');
        effectiveDateEnd = ApexPages.currentPage().getParameters().get('effectiveDateEnd');
        expirationDateStart = ApexPages.currentPage().getParameters().get('expirationDateStart');
        expirationDateEnd = ApexPages.currentPage().getParameters().get('expirationDateEnd');

        /* if(!String.isEmpty(expirationDateStr)) {
            List<String> endStringDate = effectiveDateStr.split('-');
            String eD = endStringDate[0] + '-' + endStringDate[1] + '-' + endStringDate[2];
            searchClassObj.expirationDate = Date.valueOf(eD);
        }   */ 
         
    }
    
    // Remote action called from RegistrationCPSsearchResults.page via javascript function getRemoteRegistrations()
    @RemoteAction
    global static List<License_Registration__c> getAllRegistrations(String registrationNumberStr, String selectedRecordType, String selectedStatus, String firstNameStr,
                                                                    String middleNameStr, String lastNameStr, String locationCityStr, String locationStateStr, 
                                                                    String locationZipStr, String effectiveDateStart, String effectiveDateEnd,
    																String expirationDateStart, String expirationDateEnd ) 
    {
        System.debug('registrationNumberStr=======>'+registrationNumberStr);
        List<License_Registration__c> allReg = new List<License_Registration__c>();
        
        Id indvRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Individual Permit').getRecordTypeId();

        if(String.isEmpty(registrationNumberStr) && String.isEmpty(firstNameStr)  && String.isEmpty(middleNameStr) && String.isEmpty(lastNameStr) && String.isEmpty(locationCityStr)  && String.isEmpty(locationStateStr)
                         && String.isEmpty(locationZipStr) && String.isEmpty(effectiveDateStart) && String.isEmpty(effectiveDateEnd)  && String.isEmpty(expirationDateStart) && String.isEmpty(expirationDateEnd)) {
                     System.debug('registrationNumberStr=======>'+registrationNumberStr);

        } else {
            Date todaydate = Date.Today();
            String query = '';
            if(selectedStatus == 'Approved')
            {
                query = 'SELECT Id ' 
                    + ', (select id, first_name__c, middle_name__c, last_name__c, Residential_City__c, Residential_State__c, Residential_Zip_Code__c from Registration_Accounts__r) '
                    + ', License_Registration_Number__c, License_Registration_Type__c, Status__c, Expiration_Date__c '
                    + ' FROM License_Registration__c WHERE (Status__c = \'Approved\' OR  Status__c = \'Renewed\') ';
            }
            else{   
                query = 'SELECT Id ' 
                    + ', (select id, first_name__c, middle_name__c, last_name__c, Residential_City__c, Residential_State__c, Residential_Zip_Code__c from Registration_Accounts__r) '
                    + ', License_Registration_Number__c, License_Registration_Type__c, Status__c, Expiration_Date__c '
                    + ' FROM License_Registration__c WHERE (Status__c = \'Closed - Revoked\') ';
            }

           
            if(!String.isEmpty(registrationNumberStr)) {
                String ln = '%' + registrationNumberStr + '%'; 
                query += ' AND License_Registration_Number__c LIKE \'' + ln + '\' ';
                
            }
  
             System.debug('registrationNumberStr=======>'+registrationNumberStr);
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
             	                                  
            if(!String.isEmpty(firstNameStr)) {
                String fn = '%' + firstNameStr + '%'; 
                String fnQuery = 'SELECT Id, Registration__c FROM Registration_Account__c WHERE First_Name__c LIKE \'' + fn + '\'  ';
                List<Registration_Account__c> allFnReg = Database.query(fnQuery);
                RegIds = new Set<Id>();
                for(Registration_Account__c eachFn: allFnReg) {
                    if(eachFn.Registration__c != null) 
                        RegIds.add(eachFn.Registration__c);
                    	System.debug('eachFn.Registration__c:' + eachFn.Registration__c);
                }
                
                if(allFnReg.size() > 0)

                    query += ' AND (First_Name__c LIKE \'' + fn + '\' OR Id IN :RegIds) ';
                else
                    query += ' AND First_Name__c LIKE \'' + fn + '\' ';
            }
            
			if(!String.isEmpty(middleNameStr)) {
                String mn = '%' + middleNameStr + '%'; 
                String mnQuery = 'SELECT Id, Registration__c FROM Registration_Account__c WHERE Middle_Name__c LIKE \'' + mn + '\'  ';
                List<Registration_Account__c> allMnReg = Database.query(mnQuery);
                RegIds = new Set<Id>();
                for(Registration_Account__c eachMn: allMnReg) {
                    if(eachMn.Registration__c != null) 
                        RegIds.add(eachMn.Registration__c);
                    	System.debug('eachMn.Registration__c:' + eachMn.Registration__c);
                }
                
                if(allMnReg.size() > 0)
                     query += ' AND (Middle_Name__c LIKE \'' + mn + '\' OR Id IN :RegIds) ';
                else
                    query += ' AND Middle_Name__c LIKE \'' + mn + '\' ';
            }
            
            if(!String.isEmpty(lastNameStr)) {
                String ln = '%' + lastNameStr + '%'; 
                String lnQuery = 'SELECT Id, Registration__c FROM Registration_Account__c WHERE Last_Name__c LIKE \'' + ln + '\'  ';
                List<Registration_Account__c> allLnReg = Database.query(lnQuery);
                RegIds = new Set<Id>();
                for(Registration_Account__c eachLn: allLnReg) {
                    if(eachLn.Registration__c != null) 
                        RegIds.add(eachLn.Registration__c);
                    	System.debug('eachLn.Registration__c:' + eachLn.Registration__c);
                }
                
                if(allLnReg.size() > 0)
                     query += ' AND (Last_Name__c LIKE \'' + ln + '\' OR Id IN :RegIds) ';
                else
                    query += ' AND Last_Name__c LIKE \'' + ln + '\' ';
            }
            
            if(!String.isEmpty(locationCityStr)) {
                String rc = '%' + locationCityStr + '%'; 
                String CityQuery = 'SELECT Id, Registration__c FROM Registration_Account__c WHERE Residential_City__c LIKE \'' + rc + '\'  AND RECORDTYPEID = \'' + indvRecordTypeId + '\' ';
                List<Registration_Account__c> allRegAccount = Database.query(CityQuery);
                RegIds = new Set<Id>();
                for(Registration_Account__c ra: allRegAccount) {
                    if(ra.Registration__c != null) 
                        RegIds.add(ra.Registration__c);
                }
                
//                if(allRegAccount.size() > 0)
//                    query += ' AND (Residential_City__c LIKE \'' + rc + '\' OR Id IN :RegIds) ';
//                else
//                    query += ' AND Residential_City__c LIKE \'' + rc + '\' ';
//                    
                query += ' AND Id IN :RegIds ';

            }

                
            if(!String.isEmpty(locationStateStr)) {
                String rs = '%' + locationStateStr + '%'; 
                String StateQuery = 'SELECT Id, Registration__c FROM Registration_Account__c WHERE 	Residential_State__c LIKE \'' + rs + '\' AND RECORDTYPEID = \'' + indvRecordTypeId + '\' ' ;
                List<Registration_Account__c> allRegAccount = Database.query(StateQuery);
                RegIds = new Set<Id>();
                for(Registration_Account__c ra: allRegAccount) {
                    if(ra.Registration__c != null) 
                        RegIds.add(ra.Registration__c);
                }
                
//                if(allRegAccount.size() > 0)
//                    query += ' AND (	Residential_State__c LIKE \'' + rs + '\' OR Id IN :RegIds) ';
//                else
//                    query += ' AND 	Residential_State__c LIKE \'' + rs + '\' ';
                query += ' AND Id IN :RegIds ';
            }
            
            if(!String.isEmpty(locationZipStr)) {
                //String rz = '%' + locationZipStr + '%'; 
                String ZipQuery = 'SELECT Id, Registration__c FROM Registration_Account__c WHERE Residential_Zip_Code__c = \'' + locationZipStr + '\' AND RECORDTYPEID = \'' + indvRecordTypeId + '\'  ';
                List<Registration_Account__c> allRegAccount = Database.query(ZipQuery);
                RegIds = new Set<Id>();
                for(Registration_Account__c ra: allRegAccount) {
                    if(ra.Registration__c != null) 
                        RegIds.add(ra.Registration__c);
                }
                
 //               if(allRegAccount.size() > 0)
 //                   query += ' AND (Residential_Postal_Code__c LIKE \'' + rz + '\' OR Id IN :RegIds) ';
 //               else
 //                   query += ' AND Residential_Postal_Code__c LIKE \'' + rz + '\' ';
                query += ' AND Id IN :RegIds ';
            } 
            
            System.debug('*********selectedRecordType:' + selectedRecordType);
            if(!String.isEmpty(selectedRecordType)) {
                System.debug('*********selectedRecordType:' + selectedRecordType);
                query += ' AND License_Registration_Type__c = \'' + selectedRecordType + '\' ';
                
            }
                       
            query += ' ORDER BY Name DESC LIMIT 2001';
            System.debug('Query=======>'+query);
            if( !Test.isRunningTest()){
                allReg = Database.query(query);
                System.debug('allReg1:' + allReg.size());
            }
        }

        return allReg;
    }
    
    // action called from "Return to Search" btn (RegistrationResults.page)
    public PageReference BackToSearch() {
        PageReference searchPage = new PageReference('/RegistrationCPSsearch');
        searchPage.setRedirect(true);
        return searchPage;
    }
        
}