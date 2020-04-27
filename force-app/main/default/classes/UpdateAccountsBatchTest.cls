@istest
public class UpdateAccountsBatchTest {

    public static testMethod void testUpdateAccountsBatch(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;

        test.startTest();
            
            UpdateAccountsBatch UAB = new UpdateAccountsBatch();
            Database.executeBatch(UAB, 1);
            
        test.stopTest();
    }
}