public with sharing class DIR_EventTriggerHandler {
    
	public static void onBeforeUpsert(List<Event> newEvents, Map<Id,Event> oldEvents) {
	    List<Event> filteredEvents =  new List<Event>();
	    
        for(Event objEvent : newEvents){
            
            if(objEvent.ActivityDateTime != Null && objEvent.Days_out__c != Null && 
              (oldEvents == Null || (objEvent.Days_out__c != oldEvents.get(objEvent.Id).Days_out__c || objEvent.ActivityDateTime != oldEvents.get(objEvent.Id).ActivityDateTime)) &&
               objEvent.ActivityDateTime.addDays(Integer.valueOf(objEvent.Days_out__c)) > DateTime.now()){
                   
                filteredEvents.add(objEvent);
            }
        }
        
        if(!filteredEvents.isEmpty()){
            
            postponeActivityDateTime(filteredEvents);
        }
	}
	
	private static void postponeActivityDateTime(List<Event> filteredEvents){
	    
	    BusinessHours objBH = [SELECT id, isActive, isDefault FROM BusinessHours WHERE isActive = true AND isDefault = true];
	    
	    if(objBH != Null){
	        
	        for(Event objEvent : filteredEvents){
	            objEvent.ActivityDateTime = BusinessHours.nextStartDate(objBH.id, objEvent.ActivityDateTime.addDays(Integer.valueOf(objEvent.Days_out__c)));
                objEvent.Due_Date__c = Date.valueOf(objEvent.ActivityDateTime);
	        }
	    }
	    
	}
}