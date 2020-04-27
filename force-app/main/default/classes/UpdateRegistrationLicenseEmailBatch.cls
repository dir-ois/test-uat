global class UpdateRegistrationLicenseEmailBatch implements Database.Batchable<sObject> { 
     
    global Database.QueryLocator start(Database.BatchableContext info){

        String q;
        
        if(Test.isRunningTest())
        {        
            q = 'Select Id, Account_Email__c from License_Registration__c where Account_Email__c != \'\' limit 1' ;
        } else 
        {
            q = 'Select Id, Account_Email__c from License_Registration__c where Account_Email__c != \'\' ' ;
        }
        return Database.getQueryLocator(q);
    }
    
    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        String sandboxName;

        List<Organization> orgsList = [SELECT id, Name, isSandbox, instancename FROM Organization limit 1];
        if (orgsList != null)
        {
            for (Organization org : orgsList)
            {
                if (org.isSandbox)
                {
                    sandboxName = URL.getSalesforceBaseUrl().getHost().substringBetween('--','.').toLowerCase();
                }
            }
        }
        
        List<License_Registration__c> scope = (List<License_Registration__c>)scopeX;
        for(License_Registration__c ci : scope) {
             ci.Account_Email__c= ci.Account_Email__c + '.' + sandboxName;
        }
        update scope; 
    }
    
    global void finish(Database.BatchableContext bc) {
    }    
}