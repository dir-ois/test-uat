@isTest(SeeAllData=false)
private class WritCreateTest {

    // simple test method to create a settlement with no details
    static testMethod void testCreateWrit(){
        
        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1 ];
		
		Account a = new Account(
        	Name = 'name',
        	ShippingPostalCode = '234889'
        );
        insert a;
		
		DIR_Employee__c mgr = new DIR_Employee__c(
			Active__c = true,
			User__c = ADMIN_USER.Id
		);
		insert mgr;
		
		DIR_Employee__c de = new DIR_Employee__c(
			Active__c = true,
			User__c = ADMIN_USER.Id,
			Manager__c = mgr.Id
		);
		insert de;
        
        DIR_Case__c c = new DIR_Case__c(
        	Employer__c = a.Id,
        	Assigned_Deputy__c = de.Id
        );
        insert c;
        
        Writ__c w = new Writ__c(
        	Case_Management__c = c.Id,
            Filing_Date__c = date.today()
        );
        test.startTest();
        insert w;
        test.stopTest();
    }
    
}