public class referralAssignmentMethods {

    public static void updateReminderDates(list<Referral_Assignment__c> refAList, Map<ID, Referral_Assignment__c> oldMap){
        for(Referral_Assignment__c ref : refAList){
            Referral_Assignment__c oldRef = oldMap.get(ref.Id);
            // 
            if (ref.Currently_Assigned__c && !oldRef.Currently_Assigned__c){
                    if (ref.First_Reminder_Date__c == null)
                    	customDateUtils.daysFrom('Referral_Assignment__c', ref.Id, date.today(), 'First_Reminder_Date__c', (Integer)ref.Referral__r.First_Reminder_days__c, 'Weekdays');
                    if (ref.Second_Reminder_Date__c == null)
                    	customDateUtils.daysFrom('Referral_Assignment__c', ref.Id, date.today(), 'Second_Reminder_Date__c', (Integer)ref.Referral__r.Second_Reminder_days__c, 'Weekdays');
            }
        }
    }
    
    public static void updateReminderDates(list<Referral_Assignment__c> refAList){
        System.debug('****  Running updateReminderDates with list only.');
        Set <Id> refSet = new set<Id>();

        for (Referral_Assignment__c r : refAList){
            refSet.add(r.Referral__c);
        }

            Map<Id, Referral__c> refMap = new Map <Id, Referral__c> ([Select Id, First_Reminder_days__c, Second_Reminder_days__c From Referral__c Where Id in :refSet]);
        
        if(refMap.size() > 0){
            for(Referral_Assignment__c ref : refAList){
                if (ref.Currently_Assigned__c){
                        System.debug('****  Currently_Assigned__c = true, running updates. Input variables: refID = ' + ref.Id + ' & First_Reminder_days__c= ' + (integer)refMap.get(ref.Referral__c).First_Reminder_Days__c  + ' & Second_Reminder_days__c = ' + (Integer)refMap.get(ref.Referral__c).Second_Reminder_days__c);
                        if (ref.First_Reminder_Date__c == null)
                        	customDateUtils.daysFrom('Referral_Assignment__c', ref.Id, date.today(), 'First_Reminder_Date__c', (integer)refMap.get(ref.Referral__c).First_Reminder_Days__c, 'Weekdays');
                        if (ref.Second_Reminder_Date__c == null)
                        	customDateUtils.daysFrom('Referral_Assignment__c', ref.Id, date.today(), 'Second_Reminder_Date__c', (Integer)refMap.get(ref.Referral__c).Second_Reminder_days__c, 'Weekdays');
                }
            }
        }
    }
}