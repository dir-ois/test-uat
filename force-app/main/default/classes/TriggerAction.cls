public abstract class TriggerAction {

	protected List<Sobject> triggerList;
	protected Map<ID,SObject> triggerMap;
	
	protected Map<ID,SObject> triggerNewMap;
	protected Map<ID,SObject> triggerOldMap;
 
 	
 	/**
 	Before Trigger insert uses this
 	**/
 	//could be trigger new or old
 	protected TriggerAction(List<Sobject> Triggerlist) {
 		this.triggerList = triggerList;
 	}
 	/**
 		After trigger insert uses this
 	**/
 	protected TriggerAction(Map<ID,SObject> triggerMap) {
 		this.triggerMap = triggerMap;
 	}
 	/**
 	Update triggers use this
 	**/
 	protected TriggerAction(Map<ID,SObject> triggerNewMap,Map<ID,SObject> triggerOldMap) {
 		this.triggerNewMap = triggerNewMap;
 		this.triggerOldMap = triggerOldMap;
 	}
 	
 	public abstract boolean shouldRunOnInsert() ;
 		
 	public abstract boolean shouldRunOnDelete() ;
 	
 	public abstract boolean shouldRunOnUpdate();
 	
 	public abstract void doAction(); 
}