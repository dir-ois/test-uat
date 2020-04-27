@isTest
public with sharing class CaseHistoryTest {

    	public static testMethod void TestHearingCaseHistory() {
            
        Account act = new Account();
        act.Name = 'meet';
        act.ShippingPostalCode = '12345';
        insert act;

        DIR_Case__c cse = new DIR_Case__c();
        cse.Employer__c = act.Id;
        insert cse;

        Hearing__c h = new Hearing__c();
        h.Case__c = cse.Id;
        h.Status__c = 'New';
        insert h;

        }
}