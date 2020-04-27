@isTest
private class RegistrationErrorMsgsTest{
    @isTest
    static void RegistrationErrorMsgsTest(){
    
        RegistrationErrorMsgsController regErr = new RegistrationErrorMsgsController ();
        regErr.getAttachments();
        
        
        List<License_Registration__c> licenseReg = new List<License_Registration__c>();
        
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
  //      insert newLR;

	List <License_Registration__c> newLRList = new List<License_Registration__c>();
    newLRList.add(newLR);
    insert newLRList;

    PageReference pageRef = Page.RegistrationDefectErrorMsgs;
	test.setCurrentPageReference(pageRef);
	pageRef.getParameters().put('Id',newLR.id);
	test.startTest();
   RegistrationErrorMsgsController regErr2 = new RegistrationErrorMsgsController();
    regErr2.getAttachments();
    test.stopTest();
        
        
    }  
}