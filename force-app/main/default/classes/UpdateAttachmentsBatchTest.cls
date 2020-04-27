@istest
public class UpdateAttachmentsBatchTest {

    public static testMethod void testUpdateAttachmentsBatch(){
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
        //dirCase1.Court_Type__c = 'Federal Courts';
        //dirCase1.Court_Name__c = 'U.S. Supreme';
        //dirCase1.Violation_Type__c = 'Child Labor';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        List<Attachments_Plus__c> attToInsert = new List<Attachments_Plus__c>();
        
        Attachments_Plus__c attPlus = new Attachments_Plus__c();
        attPlus.Attachment_Name__c = 'Test PAGA Attachment';
        attPlus.Case_Management__c = dirCase1.Id;
        attPlus.Type__c = 'Audit';
        attPlus.Confidential__c = true;
        attPlus.Attorney_Client_Privilege__c = true;
        attPlus.Not_Subject_to_PRA__c = true;
        attPlus.IFP_Claimed__c = true;
        attToInsert.add(attPlus);
        
       
        insert attToInsert;
        test.startTest();
            
            UpdateAttachmentsBatch UAB = new UpdateAttachmentsBatch();
            Database.executeBatch(UAB, 1);
            
        test.stopTest();
    }
}