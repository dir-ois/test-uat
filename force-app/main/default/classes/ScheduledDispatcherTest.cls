@isTest
private class ScheduledDispatcherTest {
    @testSetup
    static void setup() {
        Account acc = new Account(
                Name = 'test acct 123',
                ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
                ShippingCity = 'Denver',
                ShippingState = 'CO',
                ShippingPostalCode = '80212'
        );
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;

        Defect__c de = new Defect__c();
        de.Active__c = true;
        de.Description__c = 'Description test';
        de.Registration_Type__c = 'Car Wash';
        de.Section__c = 'Company Information';
        de.Sub_Section__c = 'Documents';
        de.Object__c = 'Business Account';
        insert de;

        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Public Works').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = acc.Id;
        lreg.Applicant__c = con.Id;
        lreg.Status__c = 'Incomplete';
        lreg.License_Registration_Number__c = '00023568500';
        lreg.Audit_Number__c = null;
        lreg.accAlreadyCreated__c = false;
        lreg.Status__c = 'Active';
        lreg.Legal_Entity_Name__c = 'name';

        insert lreg;
    }

    @isTest static void testClass() {
        String CRON_EXP = '0 0 0 3 9 ? 2022';

        Test.startTest();

        String jobId = System.schedule('ScheduledDispatcher', CRON_EXP, new ScheduledDispatcher());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE id = :jobId];

        System.debug('HHH');
        System.debug(ct);
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }
}