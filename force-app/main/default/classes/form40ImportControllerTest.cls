/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/

@isTest
private class form40ImportControllerTest {
    
    static testMethod void importData() {
        
        List<StaticResource> csvData = [select id, name, body from StaticResource where name = 'form40TestCSV']; 
        
        Id accRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Id accRTID2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account acc = new Account();
        acc.recordtypeid = accRTID;
        acc.name = 'testAccount';        
        insert acc;
        
        Account acc2 = new Account();
        acc2.recordtypeid = accRTID2;
        acc2.FirstName = 'testName';  
        acc2.LastName  = 'TestlastName'; 
        acc2.ShippingStreet = 'testStreet'; 
        acc2.ShippingPostalCode  = 'testZip';       
        insert acc2;

        Dir_Case__c dirCase = new Dir_Case__c();
        dirCase.employer__c = acc.id;        
        insert dirCase;

        Dir_Case__c dirCase2 = new Dir_Case__c();
        dirCase2.employer__c = acc2.id;        
        insert dirCase2;
        
        Import__c newImport = new Import__c();
        newImport.Case_Management__c = dirCase.Id;
        insert newImport;

        Import__c newImport2 = new Import__c();
        newImport2.Case_Management__c = dirCase.Id;
        newImport2.Employee_First_Name__c = 'testName';
        newImport2.Employee_Last_Name__c = 'TestlastName';
        newImport2.Employee_Zip__c = 'testZip';
        newImport2.Employee_Street__c = 'testStreet';
        insert newImport2;

        Import__c newImport3 = new Import__c();
        newImport3.Case_Management__c = dirCase.Id;
        newImport3.Employee_First_Name__c = 'testName1';
        newImport3.Employee_Last_Name__c = 'TestlastName1';
        newImport3.Employee_Zip__c = 'testZip1';
        newImport3.Employee_Street__c = 'testStreet1';
        insert newImport3;

        PageReference testPage = Page.form40Import;
        testPage.getParameters().put('id', dirCase.id);
        
        Test.setCurrentPage(testPage);
        
        form40ImportController cont = new form40ImportController();
        cont.nameFile = 'form40TestCSV.csv';
        cont.contentFile = csvData[0].body;
        
        form40ImportController cont2 = new form40ImportController();
        cont2.nameFile = 'form40TestCSV.csv';
        cont2.contentFile = csvData[0].body;

        Test.StartTest();
        
        cont.ImportFile();
        cont.ProcessFile();
        
        cont2.ImportFile();
        
        Test.StopTest();
        
        
    }
    
}