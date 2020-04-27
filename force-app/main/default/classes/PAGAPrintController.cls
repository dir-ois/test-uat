/********************************************************************************************************
Name:  PAGAPrintController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/14/2017
VF Page: PAGAPrint.page
Test class: PAGAPrintControllerTest.cls

Behavior:
    Display PAGA Case as pdf (print document)
       
********************************************************************************************************/

public with sharing class PAGAPrintController {
    public DIR_Case__c currentCase {get; set;}
    private String currentCaseId;
    public List<DIR_Case__c> allResultCases {get; set;}
    
     // class constructor, executes first, as soon as the class is invoked
    public PAGAPrintController(){
        // get values from url parameters
        currentCaseId = ApexPages.currentPage().getParameters().get('Id');
        String eSearch = ApexPages.currentPage().getParameters().get('ss');
        String lwNumber = ApexPages.currentPage().getParameters().get('lwn');
        String sDate = ApexPages.currentPage().getParameters().get('sd');
        String eDate = ApexPages.currentPage().getParameters().get('ed');
        String eName = ApexPages.currentPage().getParameters().get('en');
        String eFiler = ApexPages.currentPage().getParameters().get('ef');
        String lawFirm = ApexPages.currentPage().getParameters().get('lf');
        String eCity = ApexPages.currentPage().getParameters().get('city');
        String eZipCode = ApexPages.currentPage().getParameters().get('zip');
        String eCourtCode = ApexPages.currentPage().getParameters().get('cc');
        String eCourtType = ApexPages.currentPage().getParameters().get('ct');
        String eCourtName = ApexPages.currentPage().getParameters().get('cn');
        
        String eViolationType = ApexPages.currentPage().getParameters().get('vt');
        String eSubmissionType = ApexPages.currentPage().getParameters().get('st');
        // calls getCurrentCases() method to retrieve the results (a list of DIR_Case__c records)  
        allResultCases = getCurrentCases(eSearch, lwNumber, sDate, eDate, eName, eFiler, lawFirm, eCity, eZipCode, eCourtCode, eCourtType, eCourtName, eViolationType, eSubmissionType);

    }
    
    public List<DIR_Case__c> getCurrentCases(String sString, String lwNumber, String startDate, String endDate, String eName, String eFiler, String lFirm, String ecity, String ezipCode, String CourtCaseNumber, String CourtType, String CourtName, String ViolationType, String SubmissionType) {

        List<DIR_Case__c> results = new List<DIR_Case__c>();
        
        if(String.isEmpty(sString) && String.isEmpty(lwNumber) && (String.isEmpty(startDate) || String.isEmpty(endDate)) 
        && String.isEmpty(ecity) && String.isEmpty(ezipCode) && String.isEmpty(CourtCaseNumber) && String.isEmpty(CourtType) 
        && String.isEmpty(CourtName) && String.isEmpty(ViolationType) && String.isEmpty(SubmissionType)) {
            // if the all the parameters are empty then don't show any results
        } else {
            // add conditions to the SOQL query to filter the results   
            
            String query = 'SELECT Id, Name, Case_Number__c, PAGA_LWDA_Number__c, Court_Case_Number_for_PAGA_Case__c, Notice_Filing_Date__c, Plaintiff_for_PAGA__c, Plaintiff_for_PAGA__r.Name, LWDA_Number__c, Legacy_PAGA_LWDA_Number__c, PAGA_Court_Case_Number__c, Employer_Filer__c, Employer_Filer__r.Name, Employer_Filer_Firm__c, Filer_for_Employer__c, Filer_for_Employer__r.Name, Law_Firm_for_PAGA_Case__c, Employer__c, Employer__r.Name, Employer__r.ShippingCity, Employer__r.ShippingPostalCode, Violation_Type__c, Plaintiff_for_PAGA_Case_Text__c, Filer_Attorney_for_PAGA_Case__c, Filer_Attorney_for_PAGA_Case__r.Name FROM DIR_Case__c WHERE RecordType.Name = \'PAGA Case\' AND PAGA_Status__c != \'Pending - Incomplete\' ';
            if(!String.isEmpty(sString)) {
                sString = string.escapeSingleQuotes(sString);
                String sn = '%'+sString+'%';
                query += ' AND ((Employer__r.Name LIKE  \'' + sn + '\') OR (Plaintiff_for_PAGA__r.Name LIKE \'' + sn + '\') OR (Plaintiff_for_PAGA_Case_Text__c LIKE \'' + sn + '\') OR (Filer_Attorney_for_PAGA_Case__r.Name LIKE \'' + sn + '\') OR (Law_Firm_for_PAGA_Case__c LIKE \'' + sn + '\') OR (Employer_Filer__r.Name LIKE \'' + sn + '\') OR (Employer_Filer_Firm__c LIKE \'' + sn + '\') OR (Filer_for_Employer__r.Name LIKE \'' + sn + '\') ) ';
            }
            
            if(!String.isEmpty(eName)) { 
                eName = '%' + eName + '%';
                query += ' AND Employer__r.Name LIKE  \'' + eName + '\' ';
            }
            if(!String.isEmpty(eFiler)) {
                eFiler = '%' + eFiler + '%';
                query += ' AND Employer_Filer__r.Name LIKE  \'' + eFiler + '\' ';
            }
            if(!String.isEmpty(lFirm)) {
                lFirm = '%' + lFirm + '%';
                query += ' AND Law_Firm_for_PAGA_Case__c LIKE  \'' + lFirm + '\' ';
            }
            
            if(!String.isEmpty(lwNumber)) {
                String ln = '%'+lwNumber+'%';
                query += ' AND (Name LIKE \'' + ln + '\' OR Case_Number__c LIKE \'' + ln + '\') ';
            }
            if(!String.isEmpty(startDate)) {
                List<String> startStringDate = startDate.split('-');
                String sD = startStringDate[0] + '-' + startStringDate[1] + '-' + startStringDate[2];
                Date sDate = Date.valueOf(sD);
                query += ' AND Notice_Filing_Date__c >= :sDate ';
            }
            if(!String.isEmpty(endDate)) {
                List<String> endStringDate = endDate.split('-');
                String eD = endStringDate[0] + '-' + endStringDate[1] + '-' + endStringDate[2];
                Date eDate = Date.valueOf(eD);
                query += ' AND Notice_Filing_Date__c <= :eDate ';
            }
            if(!String.isEmpty(ecity)) 
                query += ' AND Employer__r.ShippingCity = :ecity ';
            
            if(!String.isEmpty(ezipCode)) {
                ezipCode = ezipCode+'%';
                query += ' AND Employer__r.ShippingPostalCode LIKE \'' + ezipCode + '\'';
            }

            if(!String.isEmpty(CourtCaseNumber)) 
                query += ' AND PAGA_Court_Case_Number__c = :CourtCaseNumber';
            if(!String.isEmpty(CourtType)) 
                query += ' AND Court_Type__c = :CourtType ';
            if(!String.isEmpty(CourtName)) 
                query += ' AND Court_Name__c = :CourtName ';
            
            if(!String.isEmpty(ViolationType)) {
                List<String> allVTypes = ViolationType.split(';');
               
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
            if(!String.isEmpty(SubmissionType)) {
                List<String> allSTypes = SubmissionType.split(';');
               
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
            query += ' ORDER BY Name DESC';
            results = Database.query(query);
        }
        return results;

    }
    
}