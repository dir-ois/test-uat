/********************************************************************************************************
Name:  RegistrationDetailsController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  11/01/2017
VF Page: RegistrationDetails.page
Test class: RegistrationDetailsControllerTest.cls

Behavior:
    takes the current Registration record & displays Registration details fields from the field set specified in the VF page
       
********************************************************************************************************/

public class RegistrationDetailsController {

    // public License_Registration__c cRegistration{get; set;}
    public License_Registration__c currentRegistration {get; set;}
     public Id regId {get;set;}
    // The extension constructor initializes the private member
    // variable cRegistration by using the getRecord method from the standard
    // controller.
    public RegistrationDetailsController() {
        //this.cRegistration = (License_Registration__c)stdController.getRecord();
        regId = apexpages.currentpage().getparameters().get('id');
        
        currentRegistration = [SELECT Id, Name FROM License_Registration__c WHERE id =: regId];
 
    }
    
    // get the attachments list to be displayed in the table
    /*public List<Attachments_Plus__c> getAttachments() {
        String thisObjId = cRegistration.Id;
        String thisObjIdShort = thisObjId.subString(0, thisObjId.length() - 3);
        List<Attachments_Plus__c> allAttPlus = [SELECT Id, Attachment_ID__c FROM Attachments_Plus__c WHERE (Registration__c  =: thisObjId OR Record_ID__c =: thisObjId OR Record_ID__c =: thisObjIdShort) AND Attachment_ID__c != null AND Publicly_Accessible__c = true];
        Set<String> attSet = new Set<String>();
        for(Attachments_Plus__c ap: allAttPlus) {
            attSet.add(ap.Attachment_ID__c);
        }
        Map<Id, Attachment> allAttMap = new Map<Id, Attachment>([SELECT Id FROM Attachment WHERE Id IN: attSet]);
        
        Set<String> attPlusSet = new Set<String>();
        for(Attachments_Plus__c ap: allAttPlus) {
            if(allAttMap.containsKey(ap.Attachment_ID__c))
                attPlusSet.add(ap.Id);
        }
        
        
        return [SELECT Id, Name, Attachment_ID__c, Attachment_Name__c, CreatedDate, Description__c, Notice_Filer_Name__c, Attachment_URL__c, Employer__c, Type__c FROM Attachments_Plus__c WHERE Id IN: attPlusSet ORDER BY Attachment_Name__c]; 
    
    }*/
    
    
    // get the Bond list to be displayed in the table
    public List<Bond__c> getBonds() {
        return [SELECT Id, Effective_Date__c, Applicant_Email__c, Name_of_Surety_Company__c FROM Bond__c WHERE Registration__c =: currentRegistration.Id]; 
    }
    
    // get the Registration Location list to be displayed in the table
    public List<Registration_Location__c> getRegistrationLocation() {
        return [SELECT Id, Address__c, Address_Line_2__c, City__c, State__c, Zip_Code__c, DBA_Name__c FROM Registration_Location__c WHERE Registration__c =: currentRegistration.Id AND Date_Deactivated__c = NULL]; 
    }
    
     // get the Registration Registration DBAs list to be displayed in the table - added by Jag
    public List<DBA__c> getRegistrationDBAs() {
        return [SELECT Id,Name,Active__c FROM DBA__c WHERE Registration__c =: currentRegistration.Id]; 
    }

}