public class CaseHistory {
    
    @InvocableMethod
    public static void createHistoryNewMeeting(List<ID> objIDs){
        if(!objIDs.isEmpty()) {
            //create case history record
            Case_History__c ch = new Case_History__c();
                
            //grab meeting record from ID
            Hearing__c meeting = [SELECT Id, Case__c, Hearing_Date__c, Original_Hearing_Date__c, Meeting_Start_Date_Time__c, RecordTypeID, Meeting_Type__c 
                                  FROM Hearing__c
                                  WHERE Id =: objIDs[0]];
            
            if(meeting != NULL) {
                ch.Record_ID__c = meeting.Id;
        
                ch.Case_Management__c = meeting.Case__c;
                
                //Build string description for New_Value__c field
                String nv;
                nv = 'New Meeting scheduled';
        
                DateTime dt;
                if(meeting.Meeting_Start_Date_Time__c != NULL) {
                    dt = meeting.Meeting_Start_Date_Time__c;
                } else if (meeting.Hearing_Date__c != NULL) {
                    dt = meeting.Hearing_Date__c;
                } else if (meeting.Original_Hearing_Date__c != NULL) {
                    dt = meeting.Original_Hearing_Date__c;
                }
                
                if (dt != NULL) {
                    nv += ' for ' + dt.format();
                }
        
                nv += ' (';
                nv += Schema.SObjectType.Hearing__c.getRecordTypeInfosById().get(meeting.RecordTypeID).getname();
                
                if(String.isBlank(meeting.Meeting_Type__c)) {
                    nv += ')';
                } else {
                    nv += ', ';
                    nv += meeting.Meeting_Type__c;
                    nv += ')';
                }
        
                //set New_Value__c to string description
                ch.New_Value__c = nv;
                
                insert ch;
            }
        }            
    }      
}