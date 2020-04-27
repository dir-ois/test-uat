@isTest
(SeeAllData = true)
public with sharing class position_Extension_Test {
    public static testMethod void position_extension_UnitTest() {
        Position__c p = new Position__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(p);
        position_Extension pe = new position_Extension(sc);
        pe.save();
        pe.searchUnit();
        pe.searchClassification();
        
        pe.position.Reporting_Unit_CodeNo__c = 'xxx';
        pe.position.Class_Title_CodeNo__c = 'xxxx';
        pe.searchUnit();
        pe.searchClassification();
        
        pe.position.Reporting_Unit_CodeNo__c = '152';
        pe.position.Class_Title_CodeNo__c = '1441';
        pe.position.Serial_Number__c = '909';
        pe.searchUnit();
        pe.searchClassification();
        
        pe.createForm1Onload();
        position_Extension.formatString('0', 4);
    } 
}