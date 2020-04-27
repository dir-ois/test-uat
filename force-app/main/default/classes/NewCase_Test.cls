@isTest
private class NewCase_Test {

    private static testMethod void newCasetest() {
        
         Account objAccount = new Account(Name = 'Test');
         insert objAccount;
         
         DIR_Case__c c = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId());
         
         ApexPages.currentPage().getParameters().put('RecordType',c.RecordTypeId);
         ApexPages.currentPage().getParameters().put('CF00Nm0000000Q6jJ_lkid',objAccount.Id);
         ApexPages.currentPage().getParameters().put('retURL','/'+objAccount.Id);
         
         system.assertNotEquals(new NewCase(new ApexPages.StandardController(c)).RedirectOrMessage() ,new PageReference('/'));
         
         
         
         c = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Legacy WCA Case').getRecordTypeId());
         
         ApexPages.currentPage().getParameters().put('RecordType',c.RecordTypeId);

         system.assertNotEquals(new NewCase(new ApexPages.StandardController(c)).RedirectOrMessage() ,new PageReference('/'));
         
         c = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
         
         ApexPages.currentPage().getParameters().put('RecordType',c.RecordTypeId);
         
         system.assertNotEquals(new NewCase(new ApexPages.StandardController(c)).RedirectOrMessage() ,new PageReference('/'));
         
         Profile p = [SELECT Id FROM Profile WHERE Name='RCI User']; 
         
         User u = new User(Alias = 'standt', Email='standasdsrduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardsdsdsduser@testorg.com');

        System.runAs(u) {
            c = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
         
            ApexPages.currentPage().getParameters().put('RecordType',c.RecordTypeId);
         
            system.assertNotEquals(new NewCase(new ApexPages.StandardController(c)).RedirectOrMessage() ,new PageReference('/'));
        }

         DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId());
         insert objCase;
         
         
         new NewCase(new ApexPages.StandardController(objCase)).validateCase(); 

         

    }

}