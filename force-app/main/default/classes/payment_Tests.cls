@isTest
(SeeAllData = true)
private class payment_Tests {

    static testMethod void payment_Methods_UnitTest() {
        test.startTest();
        Contact c = new Contact();
        c.LastName = 'Test';
        insert c;
        
        Position__c p = new Position__c();
        p.Name = '400-152-1441-888';
        p.Serial_Number__c = '888';
        p.Manual_Entry__c = false;
        p.IsActive__c = true;
        //p.Location__c = 'Van Nuys';
        insert p;
        
        Pay_Period__c pp = new Pay_Period__c();
        pp.Start_date__c = system.today().addDays(-7);
        pp.End_date__c = system.today().addDays(7);
        insert pp;
        
        Payment__c pay = new Payment__c();
        pay.Employee_Contact__c = c.Id;
        pay.Position__c = p.Id;
        pay.Pay_Period__c = pp.Id;
        pay.Hours__c = 1;
        insert pay;
        
        pay.Hours__c = 2;
        update pay;

        test.stopTest();
    }

}