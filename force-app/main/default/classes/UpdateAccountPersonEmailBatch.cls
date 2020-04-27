global class UpdateAccountPersonEmailBatch implements Database.Batchable<sobject> {
  
    global Database.QueryLocator start(database.BatchableContext bc ){
    
        String q = 'Select Id, personemail from account where personemail != \'\' and (not personemail like \'%.uat%\') ' ;
        return Database.getQueryLocator(q);
    }
    
    global void execute (Database.BatchableContext bc, List<Account> scope ) {
    
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
        

        List<Account> scopeAE = (List<Account>) scope;
            for(Account ci : scopeAE) {
                if (sandboxName != null)      
                {          
                    ci.personemail = ci.personemail + '.' + sandboxName;
                }
            }
            if (!scopeAE.isEmpty())
            {
                update scopeAE;
            }
    }
    
    global void finish(Database.BatchableContext bc){
       
    }
}