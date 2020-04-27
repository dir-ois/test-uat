public class RegistrationErrorMsgsController {

    public List<Attachments_Plus__c> attachments;
    private String registrationId;

public RegistrationErrorMsgsController(){
    registrationId = ApexPages.CurrentPage().getParameters().get('id');
    getAttachments();

    }
 
    public List<Attachments_Plus__c> getAttachments(){
        
        attachments = new List<Attachments_Plus__c>();
        
        if(String.isBlank(registrationId))
        {
            return attachments ;
        }
        
        attachments = [
            SELECT id
            , VIP_Form_Section__r.VIPForm__Name_Displayed__c
            , Name
            , Attachment_Name__c
            , Type__c
            , Expiration_Date__c
            , Attachment_Required__c
            , Number_of_Attachments__c
            FROM Attachments_Plus__c
            WHERE Registration__r.id =: registrationId 
            AND attachment_required__c =  true 
            AND Number_of_Attachments__c = 0
                ];
        System.Debug('attachments:' + attachments);

        return attachments ;
    }

}