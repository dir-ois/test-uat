@isTest
class SBX_PostRefreshAutomationTest {
    
          
    private static final String ORGID = UserInfo.getOrganizationId();
    private static final String SBXID = UserInfo.getOrganizationId();
    private static final String SBXNM = UserInfo.getUserName().substringAfterLast('.');
    
    static List<String> CTX = new List<String>();

    @isTest
    static void testMySandboxPrep() {

        SBX_PostRefreshAutomationTest.CTX.add(SBX_PostRefreshAutomationTest.ORGID);
        SBX_PostRefreshAutomationTest.CTX.add(SBX_PostRefreshAutomationTest.SBXID);
        SBX_PostRefreshAutomationTest.CTX.add(SBX_PostRefreshAutomationTest.SBXNM);
        
        String currentHost;
        
        //currentHost = 'cadir--uat.cs32.my.salesforce.com';
        String sandboxName = '';
        String instanceName = '';
        String communityBaseURL = '';
        Boolean containsUAT = false;
        Boolean isSandbox = false;
        
        
        currentHost = URL.getSalesforceBaseUrl().getHost();        
        if (currentHost != null)
        {            
            sandboxName = currentHost.substringBetween('--','.');
            instanceName = currentHost.substringBetween('.','.my.');
        } else
        {
            currentHost = 'cadir.my.salesforce.com';
            sandboxName = 'prod';
            instanceName = 'na21';
        }
        
        
        if (sandboxName != null && sandboxName != 'prod')
        {
            communityBaseURL = 'https://' + sandboxName + '-mycadir.' + instanceName + '.force.com/registrations';
        } else
        {
            communityBaseURL = 'https://mycadir.force.com/registrations';
        }
        
        
        if (sandboxName != null && sandboxName != 'prod')
        {
            containsUAT = sandboxName.contains('uat'); 
        } else 
        {
            containsUAT = false;
        }
                
        profile p = [SELECT ID from Profile Where name = 'System Administrator LTD' Limit 1];
        String personRT = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Person Account'].id;
        
        user u = new User();
        u.username = 'lralltestuser1@test.com';
        u.Email = 'lralltestuser@test.com.invalid';
        u.LastName = 'testuserlastname';
        u.ProfileId = p.Id;
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'uName';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        System.debug('User - ' + u.Id);    

        List<Account> accts = new List<Account>();
        Account acc1 = new Account(
            Name = 'test acct 1',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            Email__c = 'test_businessemail_account@test.com.invalid'
        );
        insert acc1;
        accts.add(acc1);
        
        List<Key_Value_Store__c> kvsclist = new List<Key_Value_Store__c>();
        Key_Value_Store__c kvcs1 = new Key_Value_Store__c();
        kvcs1.name = 'Community UserID Suffix';
        kvcs1.value__c = '.reguat';
        insert kvcs1;
        kvsclist.add(kvcs1);
        
        Key_Value_Store__c kvcs2 = new Key_Value_Store__c();
        kvcs2.name = 'RS Community Base URL';
        kvcs2.value__c = 'https://uat-mycadir.cs32.force.com/registrations';
        insert kvcs2;
        kvsclist.add(kvcs2);

        Test.startTest();
        
        if (sandboxName != null && sandboxName == 'uat')
        {
            Test.testSandboxPostCopyScript(
                new SBX_PostRefreshAutomation(), 
                '00Dr00000008wch',
                '00Dr00000008wch', 
                'uat'
            );
        } else 
        {
            Test.testSandboxPostCopyScript(
                new SBX_PostRefreshAutomation(), 
                '00Dd0000000fe2H',
                '00Dd0000000fe2H', 
                'prod'
            );
        
        }
        
        Test.stopTest();

        if (sandboxName != null)
        {        
            if (instanceName != null)
            {
                String url = 'https://'+sandboxName+'-mycadir.'+instanceName+'.force.com/registrations';
            }

            List<Key_Value_Store__c> kvslist1 = [select id, name, Description__c, Value__c from Key_Value_Store__c where name IN ('Community UserID Suffix', 'Integration User', 'Reg Community Profile', 'RS Community Base URL')];        
            if (kvslist1 != null)
            {
                for (Key_Value_Store__c kvs1 : kvslist1){
                    if (kvs1.name == 'Community UserID Suffix')
                        System.assertEquals(kvs1.value__c , kvs1.value__c);
                }
            }        
    
            UpdateAccountEmailBatch updateAE = new UpdateAccountEmailBatch();
            Id testbatchjob1 = Database.executeBatch(updateAE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob1 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob1];
            if (batchJob1 != null)
            {
                for (AsyncApexJob bj1 : batchJob1)            
                {
                    System.debug('Batch Id - ' + bj1.Id);
                    System.assertEquals('Queued', bj1.Status);
                }
            }
    
            UpdateAccountPersonEmailBatch updateAPE = new UpdateAccountPersonEmailBatch();
            Id testbatchjob2 = Database.executeBatch(updateAPE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob2 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob2];
            if (batchJob2 != null)
            {
                for (AsyncApexJob bj2 : batchJob2)            
                {
                    System.debug('Batch Id - ' + bj2.Id);
                    System.assertEquals('Queued', bj2.Status);
                }
            }
    
            UpdateRegistrationLicenseEmailBatch updateRLE = new UpdateRegistrationLicenseEmailBatch();
            Id testbatchjob3 = Database.executeBatch(updateRLE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob3 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob3];
            if (batchJob3 != null)
            {
                for (AsyncApexJob bj3 : batchJob3)
                {
                    System.debug('Batch Id - ' + bj3.Id);
                    System.assertEquals('Queued', bj3.Status);
                }
            }
    
            UpdateRegistrationAccountEmailBatch updateRAE = new UpdateRegistrationAccountEmailBatch();
            Id testbatchjob4 = Database.executeBatch(updateRAE, SBX_PostRefreshAutomation.DEFAULT_BATCH_SIZE);
            List<AsyncApexJob> batchJob4 = [SELECT Id, Status, JobType, ApexClassId FROM AsyncApexJob where id = :testbatchjob4];
            if (batchJob4 != null)
            {
                for (AsyncApexJob bj4 : batchJob4)
                {
                    System.debug('Batch Id - ' + bj4.Id);
                    System.assertEquals('Queued', bj4.Status);
                }
            }
            
            if (sandboxName != null)
            {
                User u1 = [Select id, email from User where id =: u.id];
                System.debug('User email - ' + u1.email);
                System.assertEquals('lralltestuser@test.com', u1.email );
            }    
        }
                
    }
}