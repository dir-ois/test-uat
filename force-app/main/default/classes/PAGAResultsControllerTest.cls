@istest
public class PAGAResultsControllerTest {

    public static testMethod void testPAGAResults1(){
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
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('ss', 'Case');
            ApexPages.CurrentPage().getParameters().put('sD', '2017-01-01');
            ApexPages.CurrentPage().getParameters().put('eD', '2017-08-08');
            ApexPages.CurrentPage().getParameters().put('en', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ef', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lf', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ccn', '3333');
            ApexPages.CurrentPage().getParameters().put('ct', 'Other');
            ApexPages.CurrentPage().getParameters().put('cn', 'Other');
            ApexPages.CurrentPage().getParameters().put('vt', 'Child Labor');
            ApexPages.CurrentPage().getParameters().put('ec', 'Denver');
            ApexPages.CurrentPage().getParameters().put('ezc', '80212');
            ApexPages.CurrentPage().getParameters().put('cn', 'name');
            ApexPages.CurrentPage().getParameters().put('vt', 'name');
            ApexPages.CurrentPage().getParameters().put('st', 'name');
            PAGAResultsController pagaResults = new PAGAResultsController();
            
            PAGAResultsController.getAllCases('Case', '444333', '01/01/2017', '08/08/2017', 'Case 1', 'Case 1', 'Case 1', 'Denver', '80212', '3333', 'California Courts', 'Court Name',  'Child Labor;', 'Intake;');
            
            pagaResults.getPAGASearchFields();
            pagaResults.SearchCases();
            pagaResults.filterField= 'Date_Case_Received__c';
            pagaResults.AddFilter();
            pagaResults.filterField = 'LWDA_Number__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Date_Case_Received__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer__r.Name';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer_Filer__r.Name';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Law_Firm_for_PAGA_Case__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer__r.ShippingCity';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Employer__r.ShippingPostalCode';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Court_Case_Number_for_PAGA_Case__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Court_Type__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Court_Name__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Violation_Type__c';
            pagaResults.RemoveFilter();
            pagaResults.filterField = 'Submission_Detail_Type__c';
            pagaResults.RemoveFilter();
            pagaResults.PrintResultsToPDF();
            pagaResults.PrintResultsToExcel();
            
            
        test.stopTest();
    }
    
    public static testMethod void testPAGAResults2(){
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
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        //dirCase1.Violation_Type__c = 'Child Labor';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        
        test.startTest();
            
            ApexPages.CurrentPage().getParameters().put('ss', 'Case');
            ApexPages.CurrentPage().getParameters().put('sD', '2017-01-01');
            ApexPages.CurrentPage().getParameters().put('eD', '2017-08-08');
            ApexPages.CurrentPage().getParameters().put('en', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('ef', 'Case 1');
            ApexPages.CurrentPage().getParameters().put('lf', 'Case 1');
            
            ApexPages.CurrentPage().getParameters().put('ccn', '3333');
            ApexPages.CurrentPage().getParameters().put('ct', 'Other');
            ApexPages.CurrentPage().getParameters().put('cn', 'Other');
            ApexPages.CurrentPage().getParameters().put('vt', 'Child Labor');
            ApexPages.CurrentPage().getParameters().put('ec', 'Denver');
            ApexPages.CurrentPage().getParameters().put('ezc', '80212');
            ApexPages.CurrentPage().getParameters().put('cn', 'name');
            ApexPages.CurrentPage().getParameters().put('vt', 'name');
            ApexPages.CurrentPage().getParameters().put('st', 'name');
            PAGAPrintController pagaPrint = new PAGAPrintController();
            
            pagaPrint.getCurrentCases('Case', '444333', '2017-01-01', '2017-08-08', 'Case 1', 'Case 1', 'Case 1', 'Denver', '80212', '3333', 'California Courts', 'California Courts', 'Child Labor;', 'Intake;');
            
        test.stopTest();
    }
}