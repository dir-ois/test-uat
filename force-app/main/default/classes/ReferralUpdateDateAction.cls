public class ReferralUpdateDateAction extends TriggerAction {
 	
 	private static final ID COURT_RTID = RecordTypeUtil.getRecordTypeIDByDevName('Referral__c','BOFE_Request_for_Legal_Court_Action');
    private static final ID LEGAL_RTID = RecordTypeUtil.getRecordTypeIDByDevName('Referral__c','BOFE_Request_for_Legal_Services');
   	private set<id> PARENT_RT_ID = new Set<ID> { COURT_RTID,LEGAL_RTID};
    public boolean shouldRun;
    private Map<ID,Set<ID>> violationToAccountCodes;
    private List<Referral_Assignment__c> relevantAssignments = new List<Referral_Assignment__c>();
    private static boolean hasRun = false;
    public ReferralUpdateDateAction(List<SOBject> triggerList) {	
    	
        super(triggerList);
    
     	Set<ID> parentReferrals = new SEt<ID>();
     	Map<ID,Referral_Assignment__c> referralToReferralAssignment  = new Map<ID,Referral_Assignment__c>();
    	for (Sobject result: triggerList) {
    		
    		Referral_Assignment__c assignment= (Referral_Assignment__c)result;
    		parentReferrals.add(assignment.referral__c);
    		//parentreferral --> child
    		referralToReferralAssignment.put(assignment.referral__c,assignment);
   		}
   		//list of relevant parent erferrals
   		Map<id,Referral__c> referrals=  new Map<ID,Referral__c> ([select id, name from Referral__c where id in :parentReferrals and recordtypeid in :PARENT_RT_ID]);
               System.debug('****  Referrals map: ' + referrals);
   		//get violationTypes 
   		//List<Referral_Assignment__c> relevantAssignments = new List<Referral_Assignment__c>();
   		for (ID referralID: referrals.keyset()) {
   			//for every relevant parent referral
   			//find the child  = referralToReferralAssignment.get(referralID)
   			//and add to the relevant assignment list
   			relevantAssignments.add(referralToReferralAssignment.get(referralID));
                      System.debug('****   relevantAssignments added: ' + relevantAssignments);
   		}
   		shouldRun =  (relevantAssignments.size()>0) ? true:false;
   	       
    }
    public override boolean shouldRunOnInsert() { 
            if (ReferralUpdateDateAction.hasRun)
                return false;
            else ReferralUpdateDateAction.hasrun=true;
    	
  
   		
    	return shouldRun;
    } 
    public override boolean shouldRunOnDelete() { return false;} 
    
 
    public override boolean shouldRunOnUpdate() {  return false; } 
    
 
    public override void doAction() {
    	//user list of relevant assignemtns
    	//to preform date update.
    	//since its a before trigger you do not have to call "insert'   you shouldn't actually
      System.debug('****  doAction started');
      System.debug('****  Running referralAssignmentMethods with the list: ' + relevantAssignments);
    	referralAssignmentMethods.UpdateReminderDates(relevantAssignments);
    
     
    } 
    public static void runHandler() {
    
        if (!trigger.isAfter) { //this runs on befores only
            return;
        }   
        
        if (trigger.isInsert) {
            ReferralUpdateDateAction action = new ReferralUpdateDateAction(Trigger.new);
            if (action.shouldRunOnInsert()) {
            	action.doAction(); 
            }
            
        }   
      

    } 
    
}