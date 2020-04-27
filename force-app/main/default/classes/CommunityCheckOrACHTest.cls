@istest
public class CommunityCheckOrACHTest {

    public static testMethod void testCommunityCheckOrACH1(){
        
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
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

        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
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
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = newLR.Id;
        feeSummary.Active__c = TRUE;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = newLR.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        test.startTest();
            ApexPages.CurrentPage().getParameters().put('id', newLR.Id);
            CommunityCheckOrACH CCACH = new CommunityCheckOrACH();  
            CCACH.getAllFees();
            CCACH.getPaymentTypes();
            CCACH.PaymentType = 'Check';
            CCACH.EnterPaymentInfo();
            CCACH.CancelExit();
        test.stopTest();
    }
    
    public static testMethod void testCommunityCheckOrACH2(){

        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
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
     
        
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
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
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = newLR.Id;
        feeSummary.Active__c = TRUE;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = newLR.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        test.startTest();
            ApexPages.CurrentPage().getParameters().put('id', newLR.Id);
            CommunityCheckOrACH CCACH = new CommunityCheckOrACH();  
            CCACH.getAllFees();
            CCACH.getPaymentTypes();
            CCACH.PaymentType = 'ACH';
            CCACH.EnterPaymentInfo();
            CCACH.CancelExit();
        test.stopTest();
    }
    
    public static testMethod void testCommunityCheckOrACH3(){

        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
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
                  
   
        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        newLR.RecordTypeID = lrRecordTypeID;
        insert newLR;
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = newLR.Id;
        feeSummary.Active__c = TRUE;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = newLR.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        test.startTest();
            ApexPages.CurrentPage().getParameters().put('id', newLR.Id);
            CommunityCheckOrACH CCACH = new CommunityCheckOrACH();  
            CCACH.getAllFees();
            CCACH.getPaymentTypes();
            CCACH.EnterPaymentInfo();
            CCACH.CancelExit();
            CCACH.getTotalFees();
        test.stopTest();
    }
    
    
    public static testMethod void testCommunityCheckOrACH4(){
        
        
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
       
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

        Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        id lrRecordTypeId = Schema.sObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeID();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        License_Registration__c  newLR = new License_Registration__c();
        newLR.Account__c = acc.Id;
        newLR.License_Registration_Number__c = '222';
        newLR.License_Registration_Type__c = 'Car Wash';
        newLR.Status__c = 'Incomplete'; 
        newLR.Expiration_Date__c = Date.today() + 10; 
        newLR.Amount_Paid__c = 100; 
        newLR.Applicant__c = con.Id;
        newLR.RecordTypeID = lrRecordTypeID;
        insert newLR;
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = newLR.Id;
        feeSummary.Active__c = TRUE;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = newLR.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        test.startTest();
            ApexPages.CurrentPage().getParameters().put('id', newLR.Id);
            CommunityCheckOrACH CCACH = new CommunityCheckOrACH();  
            CCACH.getAllFees();
            CCACH.getPaymentTypes();
            CCACH.PaymentType = 'Credit';
            CCACH.EnterPaymentInfo();
            CCACH.CancelExit();
        test.stopTest();
    }
}