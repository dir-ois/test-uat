public class Check_Batch_Flow_Button_Controller {

    public Flow.Interview.Check_Batch_Approval Check_Batch_Approval {get;set;}
    public string startvar_check_batch_id {get;set;}
    public string var_reviewed_by {get;set;}
    public string var_check_batch_status {get;set;}
    public String var_check_batch_name {get;set;}
    
    public Check_Batch_Flow_Button_Controller(){
    	startvar_check_batch_id = apexpages.currentpage().getParameters().get('batchID');
    	var_reviewed_by = apexpages.currentpage().getParameters().get('reviewedBy');
    	var_check_batch_status = apexpages.currentpage().getParameters().get('batchStatus');
    	var_check_batch_name = apexpages.currentpage().getParameters().get('batchName');
  
    }
	
  	public PageReference getCheckBatch(){
        system.debug('*** Check_Batch_Approval====== ' + Check_Batch_Approval);
        String returnID ='home/home.jsp';
        if (startvar_check_batch_id != null) {
            returnID = startvar_check_batch_id; 
            system.debug('ReturnID:::: ' + returnID); 
        }
        PageReference send = new PageReference('/' + returnID);
        system.debug('PageReference sent as finish location::: ' + send);
        send.setRedirect(true);
        return send;
    }
    
}