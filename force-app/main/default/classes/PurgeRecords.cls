public with sharing class PurgeRecords implements PurgeRecordsScheduler.ISchedulePurge {
    public void execute(SchedulableContext sc) {
        Datetime dt = Datetime.now().addMinutes(10);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

        if ([SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 5){
            Database.executeBatch(new PurgeRecordsBatch(), 5);
        } else {
            System.Schedule('PurgeRecordsBatch_RETRY_' + timeForScheduler, timeForScheduler, new PurgeRecordsScheduler());
        }
    }
}