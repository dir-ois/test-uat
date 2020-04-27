@isTest(SeeAllData=false)
private class UpdateCaseStatusActionTEST {
	
	private static Id wcaRT = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('WCA Hearing').getRecordTypeId();
	
	
    static testMethod void testUpdateCaseStatus() {
        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1 ];
		
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
    	
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;

        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.Id;
        insert c;

        Hearing__c h = new Hearing__c();
        h.Case__c = c.Id;
        h.Status__c = 'New';
        h.RecordTypeId = wcaRT;
        insert h;
        
        test.startTest();
        
        h.Status__c = 'Pending Approval';
        update h;
        
        DIR_Case__c testCase1 = [SELECT Id, Name, Status__c FROM DIR_Case__c WHERE id =: c.Id];
        system.assertEquals(testCase1.Status__c, 'Awaiting Approval');
        
        h.Status__c = 'Meeting Approved';
        update h;
        
        DIR_Case__c testCase2 = [SELECT Id, Name, Status__c FROM DIR_Case__c WHERE id =: c.Id];
        system.assertEquals(testCase2.Status__c, 'Hearing Approved');
        
        test.stopTest();
    }
}