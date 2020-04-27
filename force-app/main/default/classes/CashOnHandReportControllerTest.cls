/* CashOnHandReportControllerTest */
@isTest(SeeAllData=true) //SeeAllData=true to bring in all Office_Account__c records, and these records are quite static.
public with sharing class CashOnHandReportControllerTest{
    
    @isTest
    static void testOA(){
        
        Office_Account__c oa = [SELECT Id, Name
                                    FROM Office_Account__c][0];
        
        System.debug('oa:'+oa);
        
        ApexPages.StandardController cohOaReportSC = new ApexPages.StandardController(oa);
        PageReference cohOaPageRef = Page.CashOnHandReportVFP;
        cohOaPageRef.getParameters().put('Id', oa.Id);
        
        Test.setCurrentPage(cohOaPageRef);
        
        CashOnHandReportController cohReportController = new CashOnHandReportController(cohOaReportSC);
        
        List<DIR_Case__c> testCases = [SELECT Id, Name, Case_Number__c, Cash_Balance_on_Case__c, 
                                        Office__c, Office__r.Name, Office__r.Office_Account__c, Office__r.Office_Account__r.Id, Office__r.Office_Account__r.Name, Employer__c, Employer__r.Name
                                            FROM DIR_Case__c
                                            WHERE Cash_Balance_on_Case__c != 0.00
                                                AND Office__r.Office_Account__r.Id = :oa.Id];
        
        Decimal testSum = 0.00;
        
        for(DIR_Case__c cm : testCases){
            testSum += cm.Cash_Balance_on_Case__c;
        }
        
        System.assertEquals(cohReportController.sum, testSum);
        
    }
    
    @isTest
    static void testOther(){
        
        //ApexPages.StandardController cohOaReportSC = new ApexPages.StandardController(oa);
        PageReference cohOaPageRef = Page.CashOnHandReportOtherVFP;
        //cohOaPageRef.getParameters().put('Id', oa.Id);
        
        Test.setCurrentPage(cohOaPageRef);
        
        CashOnHandReportController cohReportController = new CashOnHandReportController();
        
        List<Id> ourOfficeRTIDs = new List<Id>();
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId());
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('Garment').getRecordTypeId());
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId());
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId());
        
        List<DIR_Case__c> testCases = [SELECT Id, Name, Case_Number__c, Cash_Balance_on_Case__c, 
                                            Office__c, Office__r.RecordTypeID, Office__r.Office_Account__c, Office__r.Office_Account__r.Name, Office__r.Office_Account__r.Id, Employer__c, Employer__r.Name
                                        FROM DIR_Case__c
                                        WHERE Cash_Balance_on_Case__c != 0.00
                                            AND (Office__c = NULL
                                                OR Office__r.RecordTypeID NOT IN :ourOfficeRTIDs)]; //assumes all pertinent Offices have an Office Account and is of a WCA, BOFE, or CCU record type
        
        
        Decimal testSum = 0.00;
        
        for(DIR_Case__c cm : testCases){
            testSum += cm.Cash_Balance_on_Case__c;
        }
        
        System.assertEquals(cohReportController.sum, testSum);
        
    }
}