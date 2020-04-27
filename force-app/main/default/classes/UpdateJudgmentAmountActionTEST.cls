@isTest(SeeAllData=false)
private class UpdateJudgmentAmountActionTEST {

    static testMethod void testUpdateJudgmentAmountAction() {
    	Account a = new Account(
			Name = 'testAcct80211'
		);
		insert a;
		
		DIR_Employee__c ma = new DIR_Employee__c(
			User__c = UserInfo.getUserId()
		);
		insert ma; 
		
		DIR_Employee__c de = new DIR_Employee__c(
			User__c = UserInfo.getUserId(),
			Position__c = 'Deputy',
			Manager__c = ma.Id
		);
		insert de; 
		
		DIR_Case__c cm = new DIR_Case__c(
			Assigned_Deputy__c = de.Id,
			Employer__c = a.Id
		);
		insert cm;
		
		Assessments__c assesment = new Assessments__c(
	        Appeal_Deadline_Selector__c = 'Business Days',
	        Appeal_Deadline_Days__c = 15,
	        Case_Management__c = cm.Id
        );
        insert assesment;

        Case_Role__c cr = new Case_Role__c(
        	Case__c = cm.Id,
        	Entity__c = a.Id
        );
        insert cr;
		
		Liability__c liability = new Liability__c(
	        Assessment__c = assesment.Id,
	        Case_Management__c = cm.Id,
	        Status__c = 'new',
	        Appeal_Deadline__c = Date.today()
        );
        insert liability;
		
        Judgement__c j = new Judgement__c(
        	Case_Management__c = cm.Id,
        	Type__c = 'ODA'
        );
        insert j;
        
        Liable_Party__c lp = new Liable_Party__c(
	        Liability__c = liability.Id,
	        Entity__c = a.id,
	        Interest_Amount_Received__c = -500,
	        Case_Role__c  = cr.Id
        );
        insert lp;
        
        test.startTest();
        
        Liability_Judgement__c lj = new Liability_Judgement__c(
        	Judgement__c = j.Id,
        	Liable_Party__c = lp.Id
        );
        insert lj;
        
        j = [SELECT Id, Judgement_Amount__c FROM Judgement__c WHERE Id =: j.Id LIMIT 1];
        system.assertEquals(500, j.Judgement_Amount__c);
        
        test.stopTest();
    }
}