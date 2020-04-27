@istest
public class UpdateLaborCodeViolationBatchTest {

    public static testMethod void testUpdateLaborCodeViolationBatch(){
        Account acc = new Account(
            Name = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;

        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        Wage_Claim__c cw = new Wage_Claim__c();
        cw.Last_Name__c = 'test';
        insert cw;
        
        Report_of_Labor_Code_Violation__c rlcv = new Report_of_Labor_Code_Violation__c();
        rlcv.DIR_Case__c = dirCase1.Id;
        rlcv.Account__c = acc.Id;
        rlcv.Source__c = 'Community Group Referral';
        rlcv.Child_Labor_Violations__c = 'No valid work permit(s)';
        rlcv.No_number_of_minors_affected__c = 5;
        rlcv.Wage_Claim__c = cw.Id;
        insert rlcv;
        
        test.startTest();
            
            UpdateLaborCodeViolationBatch ULCV = new UpdateLaborCodeViolationBatch();
            Database.executeBatch(ULCV, 1);
            
        test.stopTest();
    }
}