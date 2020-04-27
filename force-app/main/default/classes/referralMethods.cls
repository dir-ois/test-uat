public class referralMethods {

    // Updates the reminder dates for the referral based on the 
    public static void updateReminderDates(list<Referral__c> refList, Map<ID, Referral__c> oldMap){
        for(Referral__c ref : refList){
            Referral__c oldRef = oldMap.get(ref.Id);
            // 
            if ((ref.Request_Status__c == 'Request Sent' || ref.Request_Status__c == 'Request Approved') && 
                (oldRef.Request_Status__c != 'Request Sent' && oldRef.Request_Status__c != 'Request Approved') &&
                ref.Referral_Assignments__c > 0){
                    if (ref.First_Reminder_Date__c == null)
                    	customDateUtils.daysFrom('Referral__c', ref.Id, date.today(), 'First_Reminder_Date__c', (Integer)ref.First_Reminder_days__c, 'Weekdays');
                    if (ref.Second_Reminder_Date__c == null)
                    	customDateUtils.daysFrom('Referral__c', ref.Id, date.today(), 'Second_Reminder_Date__c', (Integer)ref.Second_Reminder_days__c, 'Weekdays');
            }
        }
    }
}