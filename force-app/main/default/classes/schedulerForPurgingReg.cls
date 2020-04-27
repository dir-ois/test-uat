global class schedulerForPurgingReg implements Schedulable {
    
    //Scheduling the batch class on 1st of every month
    public static final String CRON_EXPR_PROD = '0 0 0 1 * ? *';
    private static final Integer DEFAULT_BATCH_SIZE = 200;
    public static final String CRON_EXPR_UAT = '0 0 0 * * ? *';
    
    global void execute(SchedulableContext ctx) {
         Database.executeBatch(new purgeIncompleteRegistrations(), DEFAULT_BATCH_SIZE);
    }
    
    global static Id scheduleIt() {
        schedulerForPurgingReg job = new schedulerForPurgingReg();
        //String jobId = System.schedule('Schedule class for purging registerations', CRON_EXPR_PROD, job);
        String jobId = System.schedule('Schedule class for purging registerations', CRON_EXPR_UAT, job);
        return jobId;
  }
  
}