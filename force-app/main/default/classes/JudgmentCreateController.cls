public class JudgmentCreateController {
    
    public Flow.Interview.Judgment_Create Judgment_Create {get;set;}
    public string CaseID {get; set;}
    public string RecordID {get; set;}
    public string JudgmentID {get;set;}
    public string ObjectType {get;set;}
    public string AmountAccruesInterest {get;set;}
    public string TotalPenalties {get;set;}
    public string TotalWages {get;set;}
    public string TotalInterest {get;set;}
    public decimal Penalties {get; set;}
    public decimal Wages {get; set;}
    public decimal Interest {get; set;}

    public JudgmentCreateController(){
        CaseID  = apexpages.currentpage().getParameters().get('vCaseId');
        system.debug('Case ID set in constructor::: ' + CaseID);
        RecordID  = apexpages.currentpage().getParameters().get('varRecordId');
        system.debug('RecordID set in constructor::: ' + RecordID);
        ObjectType = apexpages.currentpage().getParameters().get('vObjectType');
        system.debug('ObjectType set in constructor::: ' + ObjectType);
        AmountAccruesInterest = apexpages.currentpage().getParameters().get('vAmountsDueAccrueInterest');
        //Liability to Judgement
        if(ObjectType == 'Liability')
        {
            TotalPenalties = apexpages.currentpage().getParameters().get('varPenalties').replaceAll('[^.0-9]','');
            Penalties = decimal.valueOf(TotalPenalties);
            system.debug('Total Penalties Assessed set in constructor::: ' + Penalties);
            TotalWages = apexpages.currentpage().getParameters().get('varWages').replaceAll('[^.0-9]','');
            Wages = decimal.valueOf(TotalWages);
            system.debug('Total Wages Assessed set in constructor::: ' + Wages);
            TotalInterest = apexpages.currentpage().getParameters().get('varInterest').replaceAll('[^.0-9]','');
            Interest = decimal.valueOf(TotalInterest);
            system.debug('Total Interest Assessed set in constructor::: ' + Interest);
        }
    }

    public PageReference getJudgment(){
        //String returnID ='home/home.jsp';
        String returnID = RecordID;
        system.debug('returnID Set to RecordID:::: ' + returnID);
        if (Judgment_Create != null && Judgment_Create.vJudgmentId != null) {
            returnID = Judgment_Create.vJudgmentId; 
            system.debug('ReturnID:::: ' + returnID); 
        }
        PageReference send = new PageReference('/' + returnID);
        system.debug('PageReference sent as finish location::: ' + send);
        send.setRedirect(true);
        return send;
    }
    

}