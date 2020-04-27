public class createAccountForPublicWorksBatchSchedule implements ScheduledDispatcher.IScheduleDispatched {
    public void execute(SchedulableContext ctx) {
        Public_Works_Account_Scheduler__c scheduler;

        if ([SELECT COUNT()
             FROM License_Registration__c
             WHERE RecordType.DeveloperName = 'Public_Works'
             AND accAlreadyCreated__c = FALSE
             AND Status__c IN ('Pending Payment', 'Active')
             LIMIT 1] == 1) {

            scheduler = Public_Works_Account_Scheduler__c.getInstance('SCHEDULER');

            if (scheduler == null) {
                scheduler = new Public_Works_Account_Scheduler__c(Name = 'SCHEDULER');
                insert scheduler;
            }

            if (scheduler.BatchId__c == null || (scheduler.BatchId__c != null && [
                    SELECT count()
                    FROM AsyncApexJob
                    WHERE (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')
                    AND Id = :scheduler.BatchId__c] == 0)) {

                if (([SELECT count() FROM AsyncApexJob WHERE Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing'] < 5)) {
                    scheduler.BatchId__c = Database.executeBatch(new createAccountForPublicWorksBatch(), 1);
                    update scheduler;
                }
            }
        }
    }
}