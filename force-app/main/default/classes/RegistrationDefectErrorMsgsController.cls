public class RegistrationDefectErrorMsgsController {

    public List<Rejection_Defect__c>  rejDefects { get; set; }
    @TestVisible
    private static String registrationId;

public RegistrationDefectErrorMsgsController (){

    registrationId = ApexPages.CurrentPage().getParameters().get('id');
    getDefects();

    }
 
    public List<Rejection_Defect__c> getDefects(){
        
        rejdefects = new List<Rejection_Defect__c>();
        
        if(String.isBlank(registrationId))
        {
            return rejDefects ;
        }
        
        rejdefects = [
                    SELECT id
                        , Name
                        , Item_Name__c
                        , Section__c 
                        , Applies__c
                        , Resolved__c
                        , Registration__r.id
                    FROM Rejection_Defect__c
                    WHERE Registration__r.id =: registrationId
                    AND Applies__c = TRUE
                    AND Resolved__c = FALSE
                ];
        System.Debug('rejDefects:' + rejDefects);

        return rejDefects ;
    }

}