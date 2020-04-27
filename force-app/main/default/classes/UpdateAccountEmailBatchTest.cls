@istest
public class UpdateAccountEmailBatchTest {

    public static testMethod void updateAccountEmailBatch(){
                
        Account acc1 = new Account(
            Name = 'test acct 1',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212',
            Email__c = 'test_businessemail_account=test.com@example.com'
        );
        insert acc1;

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
        
        Id tb = Database.executeBatch(new UpdateAccountEmailBatch(), 1);
                            
        test.stopTest();

        Account acct1 = [SELECT id, name, email__c from Account where id = :acc1.Id];
        if (sandboxName != null && sandboxName.contains('uat'))
        {
            System.assertEquals('test_businessemail_account=test.com@example.com.uat', acct1.Email__c );
        } else 
        {
            System.assertEquals('test_businessemail_account=test.com@example.com', acct1.Email__c );
        }
            
    }
}