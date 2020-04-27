public with sharing class Task_Methods {
	public static void beforeUpsert(List<Task> oldList, List<Task> newList) {
		for(Task t : newList) {
			t.Due_Date__c = t.ActivityDate;
		}
	}
    
    public void afterInsert(list<Task> newList){
        System.debug('##### in task after insert method');
        
    }
    
    public void updateDueDate(list<Task> newList){
        System.debug('##### in task updateDueDate method');
        // get "days out" parameter from task 
        
        list<Task> tasksToUpdate = new list<Task>();
		for (task t : newlist){
			if ( t.days_out__c != null )
				tasksToUpdate.add(t);
		}
 		       
		if (tasksToUpdate.Size() > 0){
            for(task t : tasksToUpdate){
              // CalculateBusinessHours cbr = new CalculateBusinessHours();
              //  date d = cbr.addBusinessDays(date.today(), t.Days_Out__c);
              //  t.ActivityDate = d;
              //  t.Due_Date__c = d;
            }
			// update tasksToUpdate;
		}
		
    }
}