@istest
public class UpdateAccountPersonEmailBatchTest {

    public static testMethod void UpdateAccountPersonEmailBatch(){
        Account acc = new Account();
        acc.FirstName='Test FName';
        acc.LastName='Test LName';
        acc.PersonMailingStreet='test@yahoo.com';
        acc.PersonMailingPostalCode='12345';
        acc.PersonMailingCity='SFO';
        acc.PersonEmail='test_personemail_account=test.com@example.com';
        acc.PersonHomePhone='1234567';
        acc.PersonMobilePhone='12345678' ;
        insert acc;

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

        test.startTest();
        
        Id tb = Database.executeBatch(new UpdateAccountPersonEmailBatch(), 1);
                            
        test.stopTest();

        Account acct1 = [SELECT id, name, personemail from Account where id = :acc.Id];
        if (sandboxName != null && sandboxName.contains('uat'))
        {
            System.assertEquals('test_personemail_account=test.com@example.com.uat', acct1.personemail );
        } else 
        {
            System.assertEquals('test_personemail_account=test.com@example.com', acct1.personemail );
        }
    }
}