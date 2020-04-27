/********************************************************************************************************
Name:  PAGASearchController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/08/2017
VF Page: PAGASearch.page
Test class: PAGASearchControllerTest.cls


Behavior:
    Filter cases search by case attributes so that it can narrow down to particular cases user is looking for. 
    Case attributes include Date Range of PAGA Notice Filed, employer city, employer zip code, court name, 
    court case number, and the type of violation.
       
********************************************************************************************************/

global class PAGASearchController {
    
    // dummy DIR Case Record
    public DIR_Case__c dummyCase {get; set;}
    
    public String searchString {get; set;}
    public String employeeCity {get; set;}
    public String employeeZipCode {get; set;}
    
    // class constructor, executes first, as soon as the class is invoked
    global PAGASearchController() {
        Id pagaRTId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        if(dummyCase == null) {
            dummyCase = new DIR_Case__c();
            dummyCase.recordTypeId = pagaRTId;
        }
        searchString = '';
    }
    
    // clears all the fields on Search page
    public void ClearFields() {
        dummyCase = new DIR_Case__c();
        searchString = '';
        employeeCity = '';
        employeeZipCode = '';
    } 
    
    
    // sends all inserted values as parameters and rediredcts to PAGASearchResults.page
    public PageReference SearchCases() {
        
        PageReference resultsPage = new PageReference('/apex/PAGASearchResults');
        if(!String.isEmpty(searchString)) 
            resultsPage.getParameters().put('ss', searchString);
        if(!String.isEmpty(dummyCase.LWDA_Number__c)) 
            resultsPage.getParameters().put('lwn', dummyCase.LWDA_Number__c);
        if(dummyCase.PAGA_Investigation_Decision_Date__c != null) 
            resultsPage.getParameters().put('sd', String.valueof(dummyCase.PAGA_Investigation_Decision_Date__c));
        if(dummyCase.Court_Filing_Date_for_PAGA_Cases__c != null)
            resultsPage.getParameters().put('ed', String.valueof(dummyCase.Court_Filing_Date_for_PAGA_Cases__c));
        if(!String.isEmpty(employeeCity)) 
            resultsPage.getParameters().put('ec', employeeCity);
        if(!String.isEmpty(employeeZipCode)) 
            resultsPage.getParameters().put('ezc', employeeZipCode);
        if(!String.isEmpty(dummyCase.Court_Case_Number_for_PAGA_Case__c)) 
            resultsPage.getParameters().put('ccn', dummyCase.Court_Case_Number_for_PAGA_Case__c);
        if(!String.isEmpty(dummyCase.Court_Type__c)) 
            resultsPage.getParameters().put('ct', dummyCase.Court_Type__c);
        if(!String.isEmpty(dummyCase.Court_Name__c)) 
            resultsPage.getParameters().put('cn', dummyCase.Court_Name__c);
        if(!String.isEmpty(dummyCase.Violation_Type__c)) 
            resultsPage.getParameters().put('vt', dummyCase.Violation_Type__c);
        if(!String.isEmpty(dummyCase.Submission_Detail_Type__c)) 
            resultsPage.getParameters().put('st', dummyCase.Submission_Detail_Type__c);
        resultsPage.setRedirect(true);
        return resultsPage;
    }
}