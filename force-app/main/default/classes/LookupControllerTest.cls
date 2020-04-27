@istest
public with sharing class LookupControllerTest {

    public static testMethod void test1() {
        
        Account a = new Account();
        a.Name = 'Test246343';
        insert a;
        
        Contact c = new Contact();
        c.LastName = 'Test823498';
        insert c;
        
        LookupController lc = new LookupController();
        lc.api_name = 'Account';
        lc.fieldOfMO = 'AccountId';
        lc.sobj = c;
        
        lc.SearchKeysobj = 'Test';
        
        lc.SearchSObject();
        lc.SelectSObject();
        
    }

}