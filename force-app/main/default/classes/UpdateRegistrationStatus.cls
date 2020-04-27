public with sharing class UpdateRegistrationStatus implements UpdateRegistrationStatusScheduler.IScheduleUpdate {
    public void execute(SchedulableContext sc) {
        Datetime dt = Datetime.now().addMinutes(10);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

        if ([SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 1){
            Database.executeBatch(new UpdateRegistrationStatusBatch(), 1);
        } else {
            System.Schedule('UpdateRegistrationStatusBatch_RETRY_' + timeForScheduler, timeForScheduler, new UpdateRegistrationStatusScheduler());
        }
    }
}