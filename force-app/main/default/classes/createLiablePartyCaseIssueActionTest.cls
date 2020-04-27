@isTest(SeeAllData=false)
private class createLiablePartyCaseIssueActionTest {
    
    static testMethod void testCreateLiablePartyCaseIssueAction() {
        
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

        DIR_Violation__c dv = new DIR_Violation__c(
            Case__c = cm.Id,
            Assessment__c = assesment.Id
        );
        insert dv;
        
        Liability__c liability = new Liability__c(
            Assessment__c = assesment.Id,
            Case_Management__c = cm.Id,
            Status__c = 'new',
            Appeal_Deadline__c = Date.today()
        );
        insert liability;
        
        test.startTest();

        Liable_Party__c lp = new Liable_Party__c(
            Liability__c = liability.Id,
            Entity__c = a.id,
            Interest_Amount_Received__c = -500,
            Case_Role__c = cr.Id
        );
        insert lp;

        test.stopTest();

        List<Liable_Party_Case_Issue__c> lpciList = [
                                                     SELECT Id, Case_Issue__c, Liable_Party__c
                                                     FROM Liable_Party_Case_Issue__c
                                                     WHERE Case_Issue__c =: dv.Id AND Liable_Party__c =: lp.Id
                                                    ];

        system.assertEquals(lpciList.size(), 1);

        Liable_Party_Case_Issue__c newLPCI = lpciList[0];
        
        system.assertEquals(newLPCI.Case_Issue__c, dv.Id);
        system.assertEquals(newLPCI.Liable_Party__c, lp.Id);
    }
}