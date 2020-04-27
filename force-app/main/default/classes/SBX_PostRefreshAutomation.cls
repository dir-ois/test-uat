global class SBX_PostRefreshAutomation implements SandboxPostCopy{

    @testVisible static final Integer DEFAULT_BATCH_SIZE = 200; 
    String currHost = URL.getSalesforceBaseUrl().getHost();
    String currProtocol = URL.getSalesforceBaseUrl().getProtocol();
    String sandboxName;
    String instanceName;
    String commBaseURL;
    String orgId;
    String baseUrl;
       

    global void runApexClass(SandboxContext context) {
        System.debug('Base URL External form ' + url.getsalesforcebaseurl().toexternalform());        
        System.debug('SandboxContext Org ID: ' + context.organizationId());
        System.debug('SandboxContext Sandbox ID: ' + context.sandboxId());
        System.debug('SandboxContext Sandbox Name: ' + context.sandboxName());
        
        baseUrl = url.getsalesforcebaseurl().toexternalform();
        //https://cadir--UAT.cs32.my.salesforce.com
        
        if (baseUrl.containsignorecase('--'))
        {
            sandboxName = baseUrl.substringBetween('--','.').toLowerCase();
            //uat

            instanceName = baseUrl.substringBetween('.','.my.').toLowerCase();
            //cs32
            }
        else if(Test.isRunningTest() || !baseUrl.containsignorecase('--'))
        {            
            sandboxName = 'prod';
            instanceName = '';
        }
        

        if (sandboxName != null)
        {
            commBaseURL = currProtocol + '://' + sandboxName + '-mycadir.' + instanceName + '.force.com/registrations';
            commBaseURL = commBaseURL.toLowerCase();
        } 
        else 
        {
            commBaseURL = 'https://mycadir.force.com/registrations';
        }       

        if ((sandboxName != null && sandboxName != 'uat') || Test.isRunningTest())
        {
            updateAdministratorsAccount();
        }
        
        if (sandboxName != null && sandboxName.containsignorecase('uat'))
        {
            updateSMEAndRegistratiorUsers();
        }
        
        updateCustomSettings();
        Id batchJobId1 = Database.executeBatch(new UpdateAccountEmailBatch(), DEFAULT_BATCH_SIZE);
        Id batchJobId2 = Database.executeBatch(new UpdateAccountPersonEmailBatch(), DEFAULT_BATCH_SIZE);
        Id batchJobId3 = Database.executeBatch(new UpdateRegistrationLicenseEmailBatch(), DEFAULT_BATCH_SIZE);
        Id batchJobId4 = Database.executeBatch(new UpdateRegistrationAccountEmailBatch(), DEFAULT_BATCH_SIZE);
    }
        
    @testVisible
    public void updateAdministratorsAccount()
    {
        List<User> adminUserlist = [SELECT id, Name, Profile.Name, Profile.Id, email from User where Profile.Name like 'System Administrator%' and isActive = true];
    
        if (!adminUserlist.isEmpty()){
            for(user u: adminUserlist){
                //update email address       
                u.email = u.email.replace('.invalid', '');
                
                //if sandbox not UAT and Profile is System Administrator LTD, change profile to System Administrator
                //as they need to be admin in other sandboxes
                if (!sandboxName.containsignorecase('uat') && u.Profile.Name.containsignorecase('System Administrator LTD'))
                {
                     u.profileid = '00ed00000013xgXAAQ';
                }                        
            }
            update adminUserlist;
        }        
    }
    
    @testVisible
    private void updateSMEAndRegistratiorUsers()
    {
        //Update SME and some registration users
        List<User> smeuserlist = [SELECT id, Name, Profile.Name, email from User where isActive = true and 
            Name IN ('Maria Padua', 'Helen Ang', 'Paul Tsan', 'Sandra Rizo', 'Regina Pagalilauan', 'Tamara Ferrari', 'David Rosales', 
                    'Ashley Johnson', 'Camille Macias', 'Lizbeth Woo', 'Patti Huber', 'Victor Lao') and email like '%.invalid%'];
        if (!smeuserlist.isEmpty()){
            for (user u : smeuserlist){
                u.email = u.email.replace('.invalid', '');
            }
            update smeuserlist;               
        }
    }
    
    @testVisible 
    private void updateCustomSettings()
    {
        //update some key-value-store variables
        List<Key_Value_Store__c> kvslist = [select id, name, Description__c, Value__c from Key_Value_Store__c];
        if (!kvslist.isEmpty()){
            for (Key_Value_Store__c kvs : kvslist){
                if (kvs.name == 'Community UserID Suffix')
                    kvs.value__c = kvs.value__c + '.' + sandboxName;
                if (kvs.name == 'RS Community Base URL')
                    kvs.value__c = commBaseURL;
                if (kvs.name == 'BaseURL')
                    kvs.value__c = currHost;
            }
            update kvslist;
        }
    }
}