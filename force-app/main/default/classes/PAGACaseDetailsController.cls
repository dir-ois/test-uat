/********************************************************************************************************
Name:  PAGACaseDetailsController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  08/08/2017
VF Page: PAGACaseDetails.page
Test class: PAGACaseDetailsControllerTest.cls

Behavior:
    takes the current DIR_Case__c record & displays case details fields from the field set specified in the VF page
       
********************************************************************************************************/

public class PAGACaseDetailsController {

    private final DIR_Case__c cCase;
    public DIR_Case__c currentCase {get; set;}
    // The extension constructor initializes the private member
    // variable cCase by using the getRecord method from the standard
    // controller.
    public PAGACaseDetailsController(ApexPages.StandardController stdController) {
        this.cCase = (DIR_Case__c)stdController.getRecord();
        currentCase = [SELECT Id FROM DIR_Case__c WHERE Id =: cCase.Id];
    }
    
    // get the attachments list to be displayed in the table
    public List<Attachments_Plus__c> getAttachments() {
        String thisObjId = cCase.Id;
        String thisObjIdShort = thisObjId.subString(0, thisObjId.length() - 3);
        List<Attachments_Plus__c> allAttPlus = [SELECT Id, Attachment_ID__c FROM Attachments_Plus__c WHERE (Case_Management__c =: thisObjId OR Record_ID__c =: thisObjId OR Record_ID__c =: thisObjIdShort) AND Attachment_ID__c != null AND Publicly_Accessible__c = true];
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
    
    }
}