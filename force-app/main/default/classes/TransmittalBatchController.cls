public with sharing class TransmittalBatchController {
    
    public boolean isAdmin {get;set;}
    public boolean isRunning {get;set;}
    public Id transmittalId;
    
    public TransmittalBatchController(){
        isRunning = false;
        User user = [SELECT Id, Profile.Name
                        FROM User
                        WHERE Id =: userInfo.getUserId()];

        if(user.Profile.Name != 'System Administrator'){
            //isAdmin = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must be a System Administrator in order to access this page.'));
        }
        else{
            //isAdmin = true;
        }
    }
    
    public void runTransmittalBatch(){
        isRunning = true;
        
        Transmittal__c trans = new Transmittal__c(
            RecordTypeId = Schema.SObjectType.Transmittal__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert trans;
        transmittalId = trans.Id;
        
        Id tb = Database.executeBatch(new TransmittalBatch(transmittalId), 25);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'The Transmittal Batch job is now queued to run. You will receive an email once the batch process is complete. You can now close this window.'));
    }
}