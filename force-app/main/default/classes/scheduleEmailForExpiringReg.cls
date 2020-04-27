global class scheduleEmailForExpiringReg implements Schedulable {
    
    public static final String CRON_EXPR_15_JUNE = '0 0 6 15 JUN ?';
    public static final String CRON_EXPR_1_JUNE = '0 0 6 1 JUN ?';
    public static final String CRON_EXPR_1_May = '0 0 6 1 MAY ?';
    private static final Integer DEFAULT_BATCH_SIZE = 200;
    
    global void execute(SchedulableContext ctx) {
         Database.executeBatch(new emailForExpiringRegistrations(), DEFAULT_BATCH_SIZE);
    }
    
    global static Id schedule_15_Days() {
        scheduleEmailForExpiringReg job = new scheduleEmailForExpiringReg();
        String jobId = System.schedule('Schedule email for expiring registerations on 15 June', CRON_EXPR_15_JUNE, job);
        
        return jobId;
  }
  
    global static Id schedule_30_Days() {
        scheduleEmailForExpiringReg job = new scheduleEmailForExpiringReg();
        String jobId = System.schedule('Schedule email for expiring registerations on 1 June', CRON_EXPR_1_JUNE, job);
        
        return jobId;
  }  
  
    global static Id schedule_60_Days() {
        scheduleEmailForExpiringReg job = new scheduleEmailForExpiringReg();
        String jobId = System.schedule('Schedule email for expiring registerations on May 1st', CRON_EXPR_1_May, job);
        
        return jobId;
  }   
  
}