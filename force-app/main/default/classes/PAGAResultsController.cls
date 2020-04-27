/********************************************************************************************************
Name:  PAGAResultsController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/08/2017

VF Page: PAGASearchResults.page
Test class: PAGAResultsControllerTest.cls

Behavior:
    Filter cases search by case attributes so that it can narrow down to particular cases user is looking for. 
    Case attributes include Date Range of PAGA Notice Filed, employer city, employer zip code, court name, 
    court case number, and the type of violation.
       
********************************************************************************************************/

global class PAGAResultsController {
    
    // dummy DIR Case Record
    public DIR_Case__c dummyCase {get; set;}
    
    public String searchString {get; set;}
    public String employeeCity {get; set;}
    public String employeeZipCode {get; set;}
    public String employerName {get; set;}
    public String employerFilerName {get; set;}
    public String lawFirmPAGACase {get; set;}
    
    public String filterField {get; set;}
    // this is used to know which field to show in page - show only the fields that have a value or that were added from "Filters" picklist
    public Map<String, Boolean> filtersMap {get; set;}
    
    // class constructor, executes first, as soon as the class is invoked
    global PAGAResultsController() {
        
        
        Id pagaRTId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        // initialize dummy case record and specify the record type so that the Submission_Detail_Type__c and 
        // Violation_Type__c fields display only the values for that record type
        if(dummyCase == null) {
            dummyCase = new DIR_Case__c();
            dummyCase.recordTypeId = pagaRTId;
        }
        
        // initialize filtersMap
       
        filtersMap = new Map<String, Boolean>();
        filtersMap.put('Employer__r.Name', false);
        filtersMap.put('Employer_Filer__r.Name', false);
        filtersMap.put('Law_Firm_for_PAGA_Case__c', false);
        filtersMap.put('Date_Case_Received__c', false);
        filtersMap.put('Employer__r.ShippingCity', false);
        filtersMap.put('Employer__r.ShippingPostalCode', false);
        filtersMap.put('Court_Case_Number_for_PAGA_Case__c', false);
        filtersMap.put('Court_Type__c', false);
        filtersMap.put('Violation_Type__c', false);
        filtersMap.put('LWDA_Number__c', false);
        filtersMap.put('Submission_Detail_Type__c', false);
        
        // add the values received from url parameter, remove them from the "Filters" and add them on page
        searchString = ApexPages.currentPage().getParameters().get('ss');
        
        dummyCase.LWDA_Number__c = ApexPages.currentPage().getParameters().get('lwn');
        if(!String.isEmpty(dummyCase.LWDA_Number__c)) {
            filtersMap.put('LWDA_Number__c', true);
        }
        employeeCity = ApexPages.currentPage().getParameters().get('ec');
        if(!String.isEmpty(employeeCity)) {
            filtersMap.put('Employer__r.ShippingCity', true);
        }
        employeeZipCode = ApexPages.currentPage().getParameters().get('ezc');
        if(!String.isEmpty(employeeZipCode)) { 
            filtersMap.put('Employer__r.ShippingPostalCode', true);
        }   
        dummyCase.Court_Case_Number_for_PAGA_Case__c = ApexPages.currentPage().getParameters().get('ccn');
        if(!String.isEmpty(dummyCase.Court_Case_Number_for_PAGA_Case__c)) { 
            filtersMap.put('Court_Case_Number_for_PAGA_Case__c', true);
        }    
        dummyCase.Court_Type__c = ApexPages.currentPage().getParameters().get('ct');
        if(!String.isEmpty(dummyCase.Court_Type__c)) { 
            filtersMap.put('Court_Type__c', true);
        }
        dummyCase.Court_Name__c = ApexPages.currentPage().getParameters().get('cn');
        if(!String.isEmpty(dummyCase.Court_Name__c)) {
            filtersMap.put('Court_Name__c', true);
        }  
        dummyCase.Violation_Type__c = ApexPages.currentPage().getParameters().get('vt');
        if(!String.isEmpty(dummyCase.Violation_Type__c )) { 
            filtersMap.put('Violation_Type__c', true);
        }   
        dummyCase.Submission_Detail_Type__c = ApexPages.currentPage().getParameters().get('st');
        if(!String.isEmpty(dummyCase.Submission_Detail_Type__c)) { 
            filtersMap.put('Submission_Detail_Type__c', true);
        }
        String startDate = ApexPages.currentPage().getParameters().get('sd');
        if(!String.isEmpty(startDate)) {
            List<String> startStringDate = startDate.split('-');
            String sD = startStringDate[0] + '-' + startStringDate[1] + '-' + startStringDate[2];
            dummyCase.PAGA_Investigation_Decision_Date__c = Date.valueOf(sD);
            filtersMap.put('Date_Case_Received__c', true);
        }
        String endDate = ApexPages.currentPage().getParameters().get('ed');
        if(!String.isEmpty(endDate)) {
            List<String> endStringDate = endDate.split('-');
            String eD = endStringDate[0] + '-' + endStringDate[1] + '-' + endStringDate[2];
            dummyCase.Court_Filing_Date_for_PAGA_Cases__c = Date.valueOf(eD);
            filtersMap.put('Date_Case_Received__c', true);
        }
    }
    
    // action called from "Remove Filter Fields" link (PAGASearchResults.page)(PAGASearchResults.page)
    public void RemoveFilter() {
        if(!String.isEmpty(filterField)) {
            filtersMap.put(filterField, false);
            
            if(filterField == 'LWDA_Number__c') {
                dummyCase.LWDA_Number__c = '';
            }
            if(filterField == 'Date_Case_Received__c') {
                dummyCase.PAGA_Investigation_Decision_Date__c  = null;
                dummyCase.Court_Filing_Date_for_PAGA_Cases__c = null;
            }  
            
            if(filterField == 'Employer__r.Name')
                employerName = '';
            if(filterField == 'Employer_Filer__r.Name')
                employerFilerName = '';
            if(filterField == 'Law_Firm_for_PAGA_Case__c')
                lawFirmPAGACase = '';
                
            if(filterField == 'Employer__r.ShippingCity')
                employeeCity = '';
            if(filterField == 'Employer__r.ShippingPostalCode')
                employeeZipCode = '';
            if(filterField == 'Court_Case_Number_for_PAGA_Case__c')
                dummyCase.Court_Case_Number_for_PAGA_Case__c = ''; 
            if(filterField == 'Court_Type__c')
                dummyCase.Court_Type__c = '';
            if(filterField == 'Court_Name__c')
                dummyCase.Court_Name__c = ''; 
            if(filterField == 'Violation_Type__c')
                dummyCase.Violation_Type__c = '';  
            if(filterField == 'Submission_Detail_Type__c')
                dummyCase.Submission_Detail_Type__c = '';    
                
                
        }
    }
    
    
    // List with all the filters (all options shown in "Filters" picklist)
    public List<SelectOption> getPAGASearchFields() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('', '-- Select --'));
        options.add(new SelectOption('Court_Type__c', 'Court Type / Court Name'));
        options.add(new SelectOption('Court_Case_Number_for_PAGA_Case__c', 'Court Case Number'));
        options.add(new SelectOption('Date_Case_Received__c', 'Submission Date'));
        
        options.add(new SelectOption('Employer__r.Name', 'Employer Name'));
        options.add(new SelectOption('Employer_Filer__r.Name', 'Employer Filer Name'));
        options.add(new SelectOption('Law_Firm_for_PAGA_Case__c', 'Law Firm for PAGA Case'));
        
        
        options.add(new SelectOption('Employer__r.ShippingCity', 'Employer City'));
        options.add(new SelectOption('Employer__r.ShippingPostalCode', 'Employer Zip Code'));
        options.add(new SelectOption('LWDA_Number__c', 'LWDA Number'));
//        options.add(new SelectOption('Violation_Type__c', 'Violation Type'));
        options.add(new SelectOption('Submission_Detail_Type__c', 'Submission Type'));
        
        return options;
    }
    
    
    // END get filter fields from case PAGASearch fieldset ==========
    
    
    // Remote action called from PAGASearchResults.page via javascript function getRemoteCases()
    @RemoteAction
    global static List<DIR_Case__c> getAllCases(String searchName, String lwNumber, String startDate, String endDate, String empName, String empFirmName, String lawFirm, String employerCity, String employerZipCode, String countCaseNumber, String cType, String cName, String vType, String sType) {
        List<DIR_Case__c> allCases = new List<DIR_Case__c>();
        
        if(String.isEmpty(searchName) && String.isEmpty(lwNumber) && (String.isEmpty(startDate) || String.isEmpty(endDate)) 
        && String.isEmpty(employerCity) && String.isEmpty(employerZipCode) && String.isEmpty(countCaseNumber) && String.isEmpty(cType) 
        && String.isEmpty(cName) && String.isEmpty(vType) && String.isEmpty(sType)) {
        
        } else {
        
            String query = 'SELECT Id, Name, Case_Number__c, Court_Case_Number_for_PAGA_Case__c, PAGA_LWDA_Number__c, Notice_Filing_Date__c, Plaintiff_for_PAGA__c, Plaintiff_for_PAGA__r.Name, LWDA_Number__c, Legacy_PAGA_LWDA_Number__c, PAGA_Court_Case_Number__c, Employer_Filer__c, Employer_Filer__r.Name, Employer_Filer_Firm__c, Filer_for_Employer__c, Filer_for_Employer__r.Name, Law_Firm_for_PAGA_Case__c, Employer__c, Employer__r.Name, Employer__r.ShippingCity, Employer__r.ShippingPostalCode, Violation_Type__c, Plaintiff_for_PAGA_Case_Text__c, Filer_Attorney_for_PAGA_Case__c, Filer_Attorney_for_PAGA_Case__r.Name FROM DIR_Case__c WHERE RecordType.Name = \'PAGA Case\' AND PAGA_Status__c != \'Pending - Incomplete\' ';
            if(!String.isEmpty(searchName)) {
                searchName = string.escapeSingleQuotes(searchName);
                String sn = '%'+searchName.replace('\'','\'')+'%';
                system.debug('searchName ====>' + sn);
                query += ' AND ((Employer__r.Name LIKE  \'' + sn + '\') OR (Plaintiff_for_PAGA__r.Name LIKE \'' + sn + '\') OR (Plaintiff_for_PAGA_Case_Text__c LIKE \'' + sn + '\') OR (Filer_Attorney_for_PAGA_Case__r.Name LIKE \'' + sn + '\') OR (Law_Firm_for_PAGA_Case__c LIKE \'' + sn + '\') OR (Employer_Filer__r.Name LIKE \'' + sn + '\') OR (Employer_Filer_Firm__c LIKE \'' + sn + '\') OR (Filer_for_Employer__r.Name LIKE \'' + sn + '\') ) ';
            }
            if(!String.isEmpty(lwNumber)) {
                String ln = '%'+lwNumber+'%';
                query += ' AND (Name LIKE \'' + ln + '\' OR Case_Number__c LIKE \'' + ln + '\') ';
            }
            if(!String.isEmpty(startDate)) {
                List<String> startStringDate = startDate.split('/');
                String sD = startStringDate[2] + '-' + startStringDate[0] + '-' + startStringDate[1];
                Date sDate = Date.valueOf(sD);
                query += ' AND Notice_Filing_Date__c >= :sDate ';
            }
            if(!String.isEmpty(endDate)) {
                List<String> endStringDate = endDate.split('/');
                String eD = endStringDate[2] + '-' + endStringDate[0] + '-' + endStringDate[1];
                Date eDate = Date.valueOf(eD);
                query += ' AND Notice_Filing_Date__c <= :eDate ';
            }
            
            if(!String.isEmpty(empName)) { 
                empName = '%' + empName + '%';
                query += ' AND Employer__r.Name LIKE  \'' + empName + '\' ';
            }
            if(!String.isEmpty(empFirmName)) {
                empFirmName = '%' + empFirmName + '%';
                query += ' AND Employer_Filer__r.Name LIKE  \'' + empFirmName + '\' ';
            }
            if(!String.isEmpty(lawFirm)) {
                lawFirm = '%' + lawFirm + '%';
                query += ' AND Law_Firm_for_PAGA_Case__c LIKE  \'' + lawFirm + '\' ';
            }
            
            
            if(!String.isEmpty(employerCity)) 
                query += ' AND Employer__r.ShippingCity = :employerCity ';
            if(!String.isEmpty(employerZipCode)) {
                employerZipCode = employerZipCode+'%';
                query += ' AND Employer__r.ShippingPostalCode LIKE \'' + employerZipCode + '\'';
            }
            if(!String.isEmpty(countCaseNumber)) 
                query += ' AND PAGA_Court_Case_Number__c = :countCaseNumber ';
            if(!String.isEmpty(cType)) 
                query += ' AND Court_Type__c = :cType';
            if(!String.isEmpty(cName)) 
                query += ' AND Court_Name__c = :cName';
            if(!String.isEmpty(vType)) {
                List<String> allVTypes = vType.split(';');
               
                query += ' AND Violation_Type__c INCLUDES (';
                Integer i = 0;
                for(String s: allVTypes) {
                    if(i < allVTypes.size()-1)
                        query += '\'' + s + '\',';
                    else 
                        query += '\'' + s + '\'';
                    i++;
                }
                query += ' )';
            }
            
            if(!String.isEmpty(sType)) {
                List<String> allSTypes = sType.split(';');
               
                query += ' AND Submission_Detail_Type__c INCLUDES (';
                Integer i = 0;
                for(String s: allSTypes) {
                    if(i < allSTypes.size()-1)
                        query += '\'' + s + '\',';
                    else 
                        query += '\'' + s + '\'';
                    i++;
                }
                query += ' )';
            }
            query += ' ORDER BY Name DESC LIMIT 2001';
            allCases = Database.query(query);
        }
        return allCases;
    }
    
    
    public void SearchCases() {
        filtersMap.put('Date_Case_Received__c', false);
        filtersMap.put('Employer__r.Name', false);
        filtersMap.put('Employer_Filer__r.Name', false);
        filtersMap.put('Law_Firm_for_PAGA_Case__c', false);
        filtersMap.put('Employer__r.ShippingCity', false);
        filtersMap.put('Employer__r.ShippingPostalCode', false);
        filtersMap.put('Court_Type__c', false);
        filtersMap.put('Court_Case_Number_for_PAGA_Case__c', false);
        filtersMap.put('Violation_Type__c', false);
        filtersMap.put('LWDA_Number__c', false);
        filtersMap.put('Submission_Detail_Type__c', false);

    }

    // action called from "Add Filter Fields" link (PAGASearchResults.page)(PAGASearchResults.page)
    public void AddFilter() {
        if(!String.isEmpty(filterField)) {
            filtersMap.put(filterField, true);
        }
    }
    
    
    // action called from "Print PDF" btn (PAGASearchResults.page)
    public PageReference PrintResultsToPDF() {
 
        PageReference printPage = new PageReference('/apex/PAGAPrint');
        if(!String.isEmpty(searchString)) 
            printPage.getParameters().put('ss', searchString);
        if(!String.isEmpty(dummyCase.LWDA_Number__c)) 
            printPage.getParameters().put('lwn', dummyCase.LWDA_Number__c);
        if(dummyCase.PAGA_Investigation_Decision_Date__c != null) 
            printPage.getParameters().put('sd', String.valueof(dummyCase.PAGA_Investigation_Decision_Date__c));
        if(dummyCase.Court_Filing_Date_for_PAGA_Cases__c != null)
            printPage.getParameters().put('ed', String.valueof(dummyCase.Court_Filing_Date_for_PAGA_Cases__c));
        
        if(!String.isEmpty(employerName)) 
            printPage.getParameters().put('en', employerName);
        if(!String.isEmpty(employerFilerName)) 
            printPage.getParameters().put('ef', employerFilerName);
        if(!String.isEmpty(lawFirmPAGACase)) 
            printPage.getParameters().put('lf', lawFirmPAGACase);
        
        if(!String.isEmpty(employeeCity)) 
            printPage.getParameters().put('city', employeeCity);
        if(!String.isEmpty(employeeZipCode)) 
            printPage.getParameters().put('zip', employeeZipCode);
        if(!String.isEmpty(dummyCase.Court_Case_Number_for_PAGA_Case__c)) 
            printPage.getParameters().put('cc', dummyCase.Court_Case_Number_for_PAGA_Case__c);
        if(!String.isEmpty(dummyCase.Court_Type__c)) 
            printPage.getParameters().put('ct', dummyCase.Court_Type__c);
        if(!String.isEmpty(dummyCase.Court_Name__c)) 
            printPage.getParameters().put('cn', dummyCase.Court_Name__c);
        if(!String.isEmpty(dummyCase.Violation_Type__c)) 
            printPage.getParameters().put('vt', dummyCase.Violation_Type__c);
        if(!String.isEmpty(dummyCase.Submission_Detail_Type__c)) 
            printPage.getParameters().put('st', dummyCase.Submission_Detail_Type__c);
        printPage.setRedirect(true);
        return printPage;
    }
    
    // action called from "Return to Search" btn (PAGASearchResults.page)
    public PageReference BackToSearch() {
        PageReference searchPage = new PageReference('/apex/PAGASearch');
        searchPage.setRedirect(true);
        return searchPage;
    }
    
    
    // action called from "Print to Excel" btn (PAGASearchResults.page)
    public PageReference PrintResultsToExcel() {
 
        PageReference printPage = new PageReference('/apex/PAGAPrintExcel');
        if(!String.isEmpty(searchString)) 
            printPage.getParameters().put('ss', searchString);
        if(!String.isEmpty(dummyCase.LWDA_Number__c)) 
            printPage.getParameters().put('lwn', dummyCase.LWDA_Number__c);
        if(dummyCase.PAGA_Investigation_Decision_Date__c != null) 
            printPage.getParameters().put('sd', String.valueof(dummyCase.PAGA_Investigation_Decision_Date__c));
        if(dummyCase.Court_Filing_Date_for_PAGA_Cases__c != null)
            printPage.getParameters().put('ed', String.valueof(dummyCase.Court_Filing_Date_for_PAGA_Cases__c));
        if(!String.isEmpty(employerName)) 
            printPage.getParameters().put('en', employerName);
        if(!String.isEmpty(employerFilerName)) 
            printPage.getParameters().put('ef', employerFilerName);
        if(!String.isEmpty(lawFirmPAGACase)) 
            printPage.getParameters().put('lf', lawFirmPAGACase);
        if(!String.isEmpty(employeeCity)) 
            printPage.getParameters().put('city', employeeCity);
        if(!String.isEmpty(employeeZipCode)) 
            printPage.getParameters().put('zip', employeeZipCode);
        if(!String.isEmpty(dummyCase.Court_Case_Number_for_PAGA_Case__c)) 
            printPage.getParameters().put('cc', dummyCase.Court_Case_Number_for_PAGA_Case__c);
        if(!String.isEmpty(dummyCase.Court_Type__c)) 
            printPage.getParameters().put('ct', dummyCase.Court_Type__c);
        if(!String.isEmpty(dummyCase.Court_Name__c)) 
            printPage.getParameters().put('cn', dummyCase.Court_Name__c);
        if(!String.isEmpty(dummyCase.Violation_Type__c)) 
            printPage.getParameters().put('vt', dummyCase.Violation_Type__c);
        if(!String.isEmpty(dummyCase.Submission_Detail_Type__c)) 
            printPage.getParameters().put('st', dummyCase.Submission_Detail_Type__c);
        printPage.setRedirect(true);
        return printPage;
    }
}