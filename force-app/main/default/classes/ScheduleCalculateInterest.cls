global class ScheduleCalculateInterest implements Schedulable, Database.Batchable<sObject>, Database.Stateful{
	// Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
	// Runs each day at 00:00:38
	public static final String CRON_SCHEDULE = '38 0 0 * * ?';
	private static final Integer DEFAULT_BATCH_SIZE = 200;
	private static Interest__c csInterest = Interest__c.getInstance('Judgement Open');
	private String baseURL;
	
	private Integer batchSize;
	
	public ScheduleCalculateInterest() {
		this(DEFAULT_BATCH_SIZE);
	}
	
	public ScheduleCalculateInterest(Integer batchSize) {
		this.batchSize = batchSize;
	}

	public static Id schedule() {
		return schedule(ScheduleCalculateInterest.CRON_SCHEDULE);
	}
	
	public static Id scheduleNow() {
		DateTime Soon = System.now().addSeconds(10);
		String sec = String.valueOf(Soon.second());
		String min = String.valueOf(Soon.minute());
		String hour = String.valueOf(Soon.hour());
		String day = String.valueOf(Soon.day());
		String month = String.valueOf(Soon.month());
		String year = String.valueOf(Soon.year());
		String schedule = sec + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
		return schedule(schedule);
	}
	
	public static Id schedule(String schedule) {
		ScheduleCalculateInterest scheduler = new ScheduleCalculateInterest();
		String jobId = System.schedule('Schedule Calculate Interest', schedule, scheduler);
		return jobId;
	}
	
	global Database.QueryLocator start(Database.BatchableContext ctx) {
		return Database.getQueryLocator ([SELECT Id, Name, RecordType.Name, RecordTypeId, Settlement_Amounts_that_Accrue_Interest__c, Judgment_Balance__c, Post_Judgement_Interest__c, 
												 Post_hearing_Interest_Balance_Due__c, Filing_Fee__c, Attorney_Fees__c, Status__c, Judgement_Date__c, 	Filing_Fees_Balance_Due__c, Attorney_Fees_Balance_Due__c 
										  FROM Judgement__c 
										  WHERE Closed__c = false AND Judgement_Date__c != null]);
	}
	
	global void execute(Database.BatchableContext ctx, List<Judgement__c> jList) {
		List<Judgement__c> updateList = new List<Judgement__c>();
		for(Judgement__c j : jList){
			if((j.Status__c != null && j.RecordTypeId != null) && (csInterest.Status__c.contains(j.Status__c) && csInterest.Record_Type__c.contains(j.RecordType.Name))){
				Decimal jBal = j.Judgment_Balance__c == null ? 0 : j.Judgment_Balance__c;
                Decimal iAmt = j.Settlement_Amounts_that_Accrue_Interest__c == null ? 0 : j.Settlement_Amounts_that_Accrue_Interest__c;
				Decimal phIntBal = j.Post_hearing_Interest_Balance_Due__c == null ? 0 : j.Post_hearing_Interest_Balance_Due__c;
                Decimal fileFee = j.Filing_Fees_Balance_Due__c == null ? 0 : j.Filing_Fees_Balance_Due__c;
                Decimal attFee = j.Attorney_Fees_Balance_Due__c == null ? 0 : j.Attorney_Fees_Balance_Due__c;
				Decimal totalBal = jBal + phIntBal + fileFee + attFee;
				Decimal dailyInterest = (csInterest.Interest_Rate__c * .01 / 365) * totalBal;
				j.Post_Judgement_Interest__c = j.Post_Judgement_Interest__c == null ? dailyInterest * math.abs(date.today().daysBetween(j.Judgement_Date__c)) : j.Post_Judgement_Interest__c + dailyInterest;
				updateList.add(j);
			}
		}
		if(!updateList.isEmpty()){
			update updateList;
		}
	}
	
	global void execute(SchedulableContext ctx) {
		Database.executeBatch(new ScheduleCalculateInterest(), DEFAULT_BATCH_SIZE);
	}
	
	global void finish(Database.BatchableContext ctx) {
		//option code to run once job finishes
	}
}