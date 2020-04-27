@istest
public class PAGASearchControllerTest {

    public static testMethod void testPAGASearch1(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        dirCase1.Violation_Type__c = 'Child Labor';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            PAGASearchController pagaSearch = new PAGASearchController();
            
            pagaSearch.employeeCity = 'Denver';
            pagaSearch.employeeZipCode = '80212';
            pagaSearch.dummyCase.PAGA_Court_Case_Number__c = '3333';
            pagaSearch.dummyCase.Court_Type__c = 'Other';
            pagaSearch.dummyCase.Court_Name__c = 'Other';
            pagaSearch.dummyCase.Violation_Type__c = 'Child Labor;';
            pagaSearch.dummyCase.Notice_Filing_Date__c = Date.Today().addDays(-4);
            pagaSearch.dummyCase.Court_Filing_Date_for_PAGA_Cases__c = Date.Today().addDays(4);
            pagaSearch.SearchCases();
            pagaSearch.ClearFields();
            
            
        test.stopTest();
    }
    
   
}