public class RLLVInternalController {
    public Flow.Interview.Internal_Report_of_Labor_Code_Violation_Entry_Flow InternalRLLV {get;set;}
     
    public PageReference getRLLV(){
        String returnID ='home/home.jsp';
        if (InternalRLLV != null) {
            returnID = InternalRLLV.ReportofLaborCodeViolationID;  
        }
        PageReference send = new PageReference('/' + returnID);
        send.setRedirect(true);
        return send;
    }
    
}