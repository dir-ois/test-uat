global class UpdateRegistrationAccountEmailBatch implements Database.Batchable<sObject> { 
   
    global Database.QueryLocator start(Database.BatchableContext info){
    
        String q;
        
        if(Test.isRunningTest())
        {
            q = 'Select Id, Email_Address__c from Registration_Account__c where Email_Address__c != \'\' limit 1 ';
        } else 
        {
            q = 'Select Id, Email_Address__c from Registration_Account__c where Email_Address__c != \'\' ';    
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
        
        List<Registration_Account__c> scope = (List<Registration_Account__c>)scopeX;
        for(Registration_Account__c ci : scope) {
             ci.Email_Address__c = ci.Email_Address__c + '.' + sandboxName;
        }
        update scope; 
    }
    
    global void finish(Database.BatchableContext bc) {
    }
            
}