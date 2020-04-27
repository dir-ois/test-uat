@isTest(SeeAllData=false)
private class scheduleCalculateInterestTest {
    
    static testMethod void testScheduleCalculateInterest() {

        List<Interest__c> interestList = new List<Interest__c>();
        Interest__c judgementOpen = new Interest__c(
            Name = 'Judgement Open',
            Record_Type__c = 'WCA',
            Interest_Rate__c = 10,
            Object__c = 'Judgment__c',
            Status__c = 'Open'
        );
        interestList.add(judgementOpen);

        Interest__c settlement = new Interest__c(
            Name = 'Settlement',
            Interest_Rate__c = 10,
            Object__c = 'Settlement__c'
        );
        interestList.add(settlement);

        Interest__c wca = new Interest__c(
            Name = 'WCA Violations',
            Interest_Rate__c = 10,
            Object__c = 'DIR_Violation__c'
        );
        interestList.add(wca);

        insert interestList;

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

        Judgement__c j = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA',
            Closed__c = false,
            Judgement_Date__c = date.today()-1,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Judgement_Amount__c = 20
        );
        insert j;

        test.startTest();
        
        ScheduleCalculateInterest scheduler = new ScheduleCalculateInterest();
        String jobId = System.schedule('ScheduleCalculateInterest', ScheduleCalculateInterest.CRON_SCHEDULE, scheduler);
        
        CronTrigger ct = [select Id, CronExpression, TimesTriggered from CronTrigger where Id = :jobId];
        system.assertEquals(ScheduleCalculateInterest.CRON_SCHEDULE, ct.CronExpression);
        system.assertEquals(0, ct.TimesTriggered);
        
        ID batchProcessId = Database.executeBatch(scheduler);

        test.stopTest();

        j = [SELECT Id, Post_Judgement_Interest__c, Judgment_Balance__c FROM Judgement__c WHERE Id =: j.Id];

        Interest__c csInterest = Interest__c.getInstance('Judgement Open');
        Decimal dailyInterest = (csInterest.Interest_Rate__c * 0.01 / 365) * j.Judgment_Balance__c;

        system.assertEquals(j.Post_Judgement_Interest__c.setScale(2, system.RoundingMode.HALF_UP), dailyInterest.setScale(2, system.RoundingMode.HALF_UP));


        
        
    }

    /** Test methods to hit scheduler utility lines **/

    static testMethod void testScheduleUtility() {

        test.startTest();

        ScheduleCalculateInterest.schedule();

        test.stopTest();
        
    }

    static testMethod void testScheduleNowUtility() {

        test.startTest();

        ScheduleCalculateInterest.scheduleNow();

        test.stopTest();

    }

    static testMethod void testScheduleWithCron() {

        test.startTest();

        String CRON_SCHEDULE = '38 0 0 * * ?';

        ScheduleCalculateInterest.schedule(CRON_SCHEDULE);

        test.stopTest();
        
    }
}