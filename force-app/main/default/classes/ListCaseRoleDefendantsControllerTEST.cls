@isTest(SeeAllData=false)
private class ListCaseRoleDefendantsControllerTEST {

    static testMethod void testCaseRole() {
        Account acc = new Account(
            Name = 'name',
            ShippingPostalCode = '234889'
        );
        insert acc;
        
        DIR_Case__c c = new DIR_Case__c(
            Employer__c = acc.Id
        );
        insert c;
        
        DIRCaseTriggerHandler.stopAffiliationCreation = true;
        
        Case_Role__c cr = new Case_Role__c(
            Case__c = c.Id,
            Role__c = 'Defendant',
            Entity__c = acc.Id
        );
        insert cr;
        
        test.startTest();
        
        ListCaseRoleDefendantsController controller = new ListCaseRoleDefendantsController();
        controller.caseId = c.Id;
        List<Case_Role__c> testList = controller.crList;
        system.debug('*******************testList: '+testList);
        
        test.stopTest();
        
    }

}