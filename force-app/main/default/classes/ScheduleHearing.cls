public with sharing class ScheduleHearing {

    public Appeal__c app { get; set; }
    public string listType { get; set; }
    
    public List<CitationWrapper> citations { get; set; }
    
    public Hearing__c hearing { get; set; }

    public ScheduleHearing(ApexPages.StandardController sc) {
        
        app = [SELECT Id, Name, Case__c, Case__r.Name, Estimated_Length_of_Hearing_In_Minutes__c, Case__r.BoFE_Office_Location_City__c, Case__r.Assigned_deputy__r.name, Case__r.Assigned_Deputy__r.Manager__r.Name, Request_Receipt_Date__c, Unavailable_dates__c FROM Appeal__c WHERE Id = :sc.getId()];
        listType = 'appeal';
        
        ID rtID = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('BOFE Hearing').getRecordTypeId();
        system.debug('******* RecTypeID ::::: ' + rtID);
        
        //Get the ID of the record type for the Case Management record from the related Appeal record
        //Convert the record type ID to a string for comparison
         List <DIR_Case__c> cmRecordTypeID = [SELECT RecordType.ID FROM DIR_Case__c WHERE Id = :app.Case__c];
         string strcmRecordTypeID = string.join(cmRecordTypeID, ',');
        
        //Get the ID of the RCI record type for the DIR_Case__c object
        //Convert the RCI record type ID to a string for comparison
        ID RCIRecordTypeCM = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        string strRCIRecordTypeCM = string.valueof(RCIRecordTypeCM);
        
        //Compare the record type of the current Appeal's corresponding Case Managment record with the Case Managment RCI record type ID in the current environment
        //If the incoming ID matches the RCI Case Managment record type ID then set the record type of the new meeting record to RCI Hearing 
        if(strcmRecordTypeID.contains(strRCIRecordTypeCM))
			{
    			rtID = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('RCI Hearing').getRecordTypeId();
			}

		hearing = new Hearing__c();
        hearing.Appeal__c = app.Id;
        hearing.Office__c = app.Case__r.BoFE_Office_Location_City__c; 
        hearing.Case__c = app.case__c;
        hearing.RecordTypeID = rtID;
        hearing.Estimated_Duration__c = app.Estimated_Length_of_Hearing_In_Minutes__c;

        SelectCitations();
        
    }
    
    public void SelectCitations() { 
        
        citations = new List<CitationWrapper>();
        
        List<Liability_Appeal__c> selCitations;
        if (listType == 'appeal') {
            selCitations = [SELECT Liability__r.Citation_Number__c, Liability__r.CreatedDate, Appeal__r.Waive_Time_Limit__c, Appeal__r.Hearing_Must_Be_Set_No_Later_Than__c FROM Liability_Appeal__c WHERE Appeal__c = :app.Id];
        } else {
            selCitations = [SELECT Liability__r.Citation_Number__c, Liability__r.CreatedDate, Appeal__r.Waive_Time_Limit__c, Appeal__r.Hearing_Must_Be_Set_No_Later_Than__c FROM Liability_Appeal__c WHERE Liability__r.Case_Management__c = :app.Case__c];
        }
        for (Liability_Appeal__c selCitation : selCitations) {
            citations.add(new CitationWrapper(selCitation));
        }
        
    }
    
    public PageReference Schedule() {
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            insert hearing;
            
            List<Hearing_Liability__c> liabs = new List<Hearing_Liability__c>();
            for (CitationWrapper cw : citations) {
                Hearing_Liability__c hl = new Hearing_Liability__c();
                hl.Hearing__c = hearing.Id;
                hl.Liability_Appeal__c = cw.liability.Id;
                liabs.add(hl);
            }
            
            if (liabs.size() > 0) {
                insert liabs;
            }
            
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            return null;
        }
        
        PageReference pr = new PageReference('/' + hearing.Id);
        return pr;
        
    }
    
    public class CitationWrapper {
        
        public Liability_Appeal__c liability { get; set; }
        public boolean selected { get; set; }
        
        public CitationWrapper(Liability_Appeal__c l) {
            liability = l;
            selected = false;
        }
        
    }

}