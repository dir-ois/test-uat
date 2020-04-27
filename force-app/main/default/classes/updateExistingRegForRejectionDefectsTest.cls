@istest
public class updateExistingRegForRejectionDefectsTest {
      public static testMethod void testupdateExistingRegForRejectionDefects(){
        
        Account acc = new Account(
            Name = 'test acct 123',
            Legal_Entity_Name__c = 'test acct 123',
            ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
            ShippingCity = 'Denver',
            ShippingState = 'CO',
            ShippingPostalCode = '80212'
        );
        insert acc;
        
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert con;  
        
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();

    
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        newLR.RecordTypeId = lrRecordTypeID;
        insert newLR;
                
        Defect__c defect = new Defect__c();
        defect.Active__c = true;
        defect.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect.Section__c = 'Disclaimer';
        insert defect;
        
        Rejection_Defect__c rejDefects1 = new Rejection_Defect__c();
        rejDefects1.Item_Name__c = 'Application must be signed by owner';
        rejDefects1.Section__c = 'Disclaimer';
        rejDefects1.Applies__c = true;
        rejDefects1.Resolved__c = false;
        rejDefects1.Registration__c = newLR.Id;
        rejDefects1.Defect__c  = defect.Id; 
        insert rejDefects1;
        
        test.startTest();
            updateExistingRegForRejectionDefects obj = new updateExistingRegForRejectionDefects();
            DataBase.executeBatch(obj);
        test.stopTest();
    }
}