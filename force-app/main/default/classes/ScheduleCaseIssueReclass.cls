global class ScheduleCaseIssueReclass Implements Schedulable {
    
    // Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
    // runs a scheduled job at midnight July. 1st. every year

    public static String CRON_SCHEDULE = '0 0 0 7 1 ?';
        
    global void execute (SchedulableContext sc)
    {
        start();
    }
    
    public void start(){
        
        Id job = Database.executeBatch(new CaseIssueBatch(),200);
    }

}