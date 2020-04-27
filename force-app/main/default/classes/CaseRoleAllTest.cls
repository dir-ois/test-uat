@isTest
public with sharing class CaseRoleAllTest {

    public static testMethod void TestCreateAffiliations1() {
        
        Affiliation_Pair__c ap = new Affiliation_Pair__c();
        ap.Name = 'Employer';
        ap.Relationship__c = 'Employee';
        insert ap;
        
        Account mainA = new Account();
        mainA.Name = 'Lucian459487';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        DIR_Case__c cs = new DIR_Case__c();
        cs.Employer__c = mainA.Id;
        insert cs;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = cs.Id;
        cr.Entity__c = affA.Id;
        cr.Role__c = 'Employer';
        insert cr;
        
        integer noAffs = [SELECT COUNT() FROM Affiliation__c];
        System.assertEquals(2, noAffs);
        
    } 
    
    public static testMethod void TestCreateAffiliations2() {
        
        Account mainA = new Account();
        mainA.Name = 'Lucian459487';
        insert mainA;
        
        Account affA = new Account();
        affA.Name = 'Lucian235432';
        insert AffA;
        
        DIR_Case__c cs = new DIR_Case__c();
        cs.Employer__c = mainA.Id;
        insert cs;
        
        Case_Role__c cr = new Case_Role__c();
        cr.Case__c = cs.Id;
        cr.Entity__c = affA.Id;
        insert cr;
        
        integer noAffs = [SELECT COUNT() FROM Affiliation__c];
        System.assertEquals(2, noAffs);
        
    } 

}