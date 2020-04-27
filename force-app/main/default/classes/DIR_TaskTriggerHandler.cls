public with sharing class DIR_TaskTriggerHandler {
    
	public static void onBeforeUpsert(List<Task> newTasks, Map<Id,Task> oldTasks) {
	    List<Task> filteredTasks =  new List<Task>();
	    
        for(Task objTask : newTasks){
            
            if(objTask.ActivityDate != Null && objTask.Days_out__c != Null && 
              (oldTasks == Null || (objTask.Days_out__c != oldTasks.get(objTask.Id).Days_out__c || objTask.ActivityDate != oldTasks.get(objTask.Id).ActivityDate)) &&
               objTask.ActivityDate.addDays(Integer.valueOf(objTask.Days_out__c)) > Date.today()){
                   
                filteredTasks.add(objTask);
            }
        }
        
        if(!filteredTasks.isEmpty()){
            
            postponeActivityDate(filteredTasks);
        }
	}
	
	private static void postponeActivityDate(List<Task> filteredTasks){
	    
	    BusinessHours objBH = [SELECT id, isActive, isDefault FROM BusinessHours WHERE isActive = true AND isDefault = true];
	    
	    if(objBH != Null){
	        
	        for(Task objTask : filteredTasks){
	            objTask.ActivityDate = Date.valueOf(BusinessHours.nextStartDate(objBH.id, objTask.ActivityDate.addDays(Integer.valueOf(objTask.Days_out__c))));
                objTask.Due_Date__c = objTask.ActivityDate;
	        }
	    }
	    
	}
}