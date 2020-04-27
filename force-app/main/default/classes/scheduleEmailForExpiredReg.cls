global class scheduleEmailForExpiredReg implements Schedulable {

    //Scheduling the batch class on 1st July
    public static final String CRON_EXPR = '0 0 6 1 JUL ?';
    private static final Integer DEFAULT_BATCH_SIZE = 200;    
    
    global void execute(SchedulableContext ctx) {
         Database.executeBatch(new emailForExpiredRegistrations(), DEFAULT_BATCH_SIZE);
    }
    
    global static Id scheduleIt() {
        scheduleEmailForExpiredReg job = new scheduleEmailForExpiredReg();
        String jobId = System.schedule('Schedule email for expired registerations', CRON_EXPR, job);
        return jobId;
  }
  
}