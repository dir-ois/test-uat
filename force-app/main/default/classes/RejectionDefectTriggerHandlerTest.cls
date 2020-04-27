@isTest
private class RejectionDefectTriggerHandlerTest{
    @isTest
    static void RejectionDefectTriggerTest(){
        
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
        insert newLR;
        
        
        License_Registration__c  newLR1 = new License_Registration__c();
        newLR1.Account__c = acc.Id;
        newLR1.License_Registration_Number__c = '222';
        newLR1.License_Registration_Type__c = 'Car Wash';
        newLR1.Status__c = 'Incomplete'; 
        newLR1.Expiration_Date__c = Date.today() + 10; 
        newLR1.Amount_Paid__c = 100; 
        newLR1.Applicant__c = con.Id;
        newLR1.RecordTypeId = lrRecordTypeID;
        insert newLR1;
    
        List <Defect__c> ListDefects = new List<Defect__c>();
         
        Defect__c defect = new Defect__c();
        defect.Active__c = true;
        defect.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect.Section__c = 'Disclaimer';
        ListDefects.add(defect);
        
        /*Defect__c defect1 = new Defect__c();
        defect1.Active__c = true;
        defect1.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect1.Section__c = 'Company Contact';
        ListDefects.add(defect1);
        */
        Defect__c defect2 = new Defect__c();
        defect2.Active__c = true;
        defect2.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect2.Section__c = 'Company Type';
        ListDefects.add(defect2);
        
        Defect__c defect3 = new Defect__c();
        defect3.Active__c = true;
        defect3.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect3.Section__c = 'Company Information';
        ListDefects.add(defect3);
        
        Defect__c defect4 = new Defect__c();
        defect4.Active__c = true;
        defect4.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect4.Section__c = 'Company Owners';
        ListDefects.add(defect4);
        
        Defect__c defect5 = new Defect__c();
        defect5.Active__c = true;
        defect5.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect5.Section__c = 'Company Managers';
        ListDefects.add(defect5);
        
        Defect__c defect6 = new Defect__c();
        defect6.Active__c = true;
        defect6.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect6.Section__c = 'Agent Authorization';
        ListDefects.add(defect6);
        
        Defect__c defect7 = new Defect__c();
        defect7.Active__c = true;
        defect7.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect7.Section__c = 'WCI Documentation';
        ListDefects.add(defect7);
        
        Defect__c defect8 = new Defect__c();
        defect8.Active__c = true;
        defect8.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect8.Section__c = 'Company Locations';
        ListDefects.add(defect8);
        
        Defect__c defect9 = new Defect__c();
        defect9.Active__c = true;
        defect9.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect9.Section__c = 'Company Finances';
        ListDefects.add(defect9);
        
        Defect__c defectx = new Defect__c();
        defectx.Active__c = true;
        defectx.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defectx.Section__c = 'Follow up Questions';
        ListDefects.add(defectx);
        
        Defect__c defecty = new Defect__c();
        defecty.Active__c = true;
        defecty.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defecty.Section__c = 'Education';
        ListDefects.add(defecty);
        
        Defect__c defectz = new Defect__c();
        defectz.Active__c = true;
        defectz.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defectz.Section__c = 'Agreements';
        ListDefects.add(defectz);
        
        Defect__c defectw = new Defect__c();
        defectw.Active__c = true;
        defectw.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defectw.Section__c = 'Fees';
        ListDefects.add(defectw);
        
        insert ListDefects;
        
        List <Rejection_Defect__c> ListRejDefects = new List<Rejection_Defect__c>();
        
        Rejection_Defect__c rejDefectsx = new Rejection_Defect__c();
        rejDefectsx.Item_Name__c = 'Application must be signed by owner';
        rejDefectsx.Section__c = 'Follow up Questions';
        rejDefectsx.Applies__c = true;
        rejDefectsx.Resolved__c = false;
        rejDefectsx.Registration__c = newLR.Id;
        rejDefectsx.Defect__c  = defectx.Id;
        ListRejdefects.add(rejDefectsx);
        
        Rejection_Defect__c rejDefectsy = new Rejection_Defect__c();
        rejDefectsy.Item_Name__c = 'Application must be signed by owner';
        rejDefectsy.Section__c = 'Education';
        rejDefectsy.Applies__c = true;
        rejDefectsy.Resolved__c = false;
        rejDefectsy.Registration__c = newLR.Id;
        rejDefectsy.Defect__c  = defecty.Id;
        ListRejdefects.add(rejDefectsy);
        
        Rejection_Defect__c rejDefectsz = new Rejection_Defect__c();
        rejDefectsz.Item_Name__c = 'Application must be signed by owner';
        rejDefectsz.Section__c = 'Agreements';
        rejDefectsz.Applies__c = true;
        rejDefectsz.Resolved__c = false;
        rejDefectsz.Registration__c = newLR.Id;
        rejDefectsz.Defect__c  = defectz.Id;
        ListRejdefects.add(rejDefectsz);
        
        Rejection_Defect__c rejDefectsw = new Rejection_Defect__c();
        rejDefectsw.Item_Name__c = 'Application must be signed by owner';
        rejDefectsw.Section__c = 'Fees';
        rejDefectsw.Applies__c = true;
        rejDefectsw.Resolved__c = false;
        rejDefectsw.Registration__c = newLR.Id;
        rejDefectsw.Defect__c  = defectw.Id;
        ListRejdefects.add(rejDefectsw);
        
        /*
        Rejection_Defect__c rejDefects = new Rejection_Defect__c();
        rejDefects.Item_Name__c = 'Application must be signed by owner';
        rejDefects.Section__c = 'Company Contact';
        rejDefects.Applies__c = true;
        rejDefects.Resolved__c = false;
        rejDefects.Registration__c = newLR.Id;
        rejDefects.Defect__c  = defect1.Id;
        ListRejdefects.add(rejDefects);
        */
        Rejection_Defect__c rejDefects1 = new Rejection_Defect__c();
        rejDefects1.Item_Name__c = 'Application must be signed by owner';
        rejDefects1.Section__c = 'Disclaimer';
        rejDefects1.Applies__c = false;
        rejDefects1.Resolved__c = false;
        rejDefects1.Registration__c = newLR.Id;
        rejDefects1.Defect__c  = defect.Id;        
        ListRejdefects.add(rejDefects1);
        /*
        Rejection_Defect__c rejDefects2 = new Rejection_Defect__c();
        rejDefects2.Item_Name__c = 'Application must be signed by owner';
        rejDefects2.Section__c = 'Company Contact';
        rejDefects2.Applies__c = true;
        rejDefects2.Resolved__c = true;
        rejDefects2.Registration__c = newLR1.Id;
        rejDefects2.Defect__c  = defect1.Id;
        ListRejdefects.add(rejDefects2);
        */
        Rejection_Defect__c rejDefects3 = new Rejection_Defect__c();
        rejDefects3.Item_Name__c = 'Application must be signed by owner';
        rejDefects3.Section__c = 'Company Type';
        rejDefects3.Applies__c = true;
        rejDefects3.Resolved__c = false;
        rejDefects3.Registration__c = newLR.Id;
        rejDefects3.Defect__c  = defect2.Id;
        ListRejdefects.add(rejDefects3);
        
        Rejection_Defect__c rejDefects4 = new Rejection_Defect__c();
        rejDefects4.Item_Name__c = 'Application must be signed by owner';
        rejDefects4.Section__c = 'Company Information';
        rejDefects4.Applies__c = true;
        rejDefects4.Resolved__c = false;
        rejDefects4.Registration__c = newLR.Id;
        rejDefects4.Defect__c  = defect3.Id;
        ListRejdefects.add(rejDefects4);
        
        Rejection_Defect__c rejDefects5 = new Rejection_Defect__c();
        rejDefects5.Item_Name__c = 'Application must be signed by owner';
        rejDefects5.Section__c = 'Company Owners';
        rejDefects5.Applies__c = true;
        rejDefects5.Resolved__c = false;
        rejDefects5.Registration__c = newLR.Id;
        rejDefects5.Defect__c  = defect4.Id;
        ListRejdefects.add(rejDefects5);
        
        Rejection_Defect__c rejDefects6 = new Rejection_Defect__c();
        rejDefects6.Item_Name__c = 'Application must be signed by owner';
        rejDefects6.Section__c = 'Company Managers';
        rejDefects6.Applies__c = true;
        rejDefects6.Resolved__c = false;
        rejDefects6.Registration__c = newLR.Id;
        rejDefects6.Defect__c  = defect5.Id;
        ListRejdefects.add(rejDefects6);
        
        Rejection_Defect__c rejDefects7 = new Rejection_Defect__c();
        rejDefects7.Item_Name__c = 'Application must be signed by owner';
        rejDefects7.Section__c = 'Agent Authorization';
        rejDefects7.Applies__c = true;
        rejDefects7.Resolved__c = false;
        rejDefects7.Registration__c = newLR.Id;
        rejDefects7.Defect__c  = defect6.Id;
        ListRejdefects.add(rejDefects7);
        
        Rejection_Defect__c rejDefects8 = new Rejection_Defect__c();
        rejDefects8.Item_Name__c = 'Application must be signed by owner';
        rejDefects8.Section__c = 'WCI Documentation';
        rejDefects8.Applies__c = true;
        rejDefects8.Resolved__c = false;
        rejDefects8.Registration__c = newLR.Id;
        rejDefects8.Defect__c  = defect7.Id;
        ListRejdefects.add(rejDefects8);
        
        Rejection_Defect__c rejDefects9 = new Rejection_Defect__c();
        rejDefects9.Item_Name__c = 'Application must be signed by owner';
        rejDefects9.Section__c = 'Company Locations';
        rejDefects9.Applies__c = true;
        rejDefects9.Resolved__c = false;
        rejDefects9.Registration__c = newLR.Id;
        rejDefects9.Defect__c  = defect8.Id;
        ListRejdefects.add(rejDefects9);
        
        Rejection_Defect__c rejDefects0 = new Rejection_Defect__c();
        rejDefects0.Item_Name__c = 'Application must be signed by owner';
        rejDefects0.Section__c = 'Company Finances';
        rejDefects0.Applies__c = true;
        rejDefects0.Resolved__c = false;
        rejDefects0.Registration__c = newLR.Id;
        rejDefects0.Defect__c  = defect9.Id;
        ListRejdefects.add(rejDefects0);
        
        test.startTest();
         insert ListRejdefects;
        test.stopTest();
    } 
    @isTest 
    static void RejectionDefectTriggerTest1(){
        
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
        insert newLR;
    
        Defect__c defect = new Defect__c();
        defect.Active__c = true;
        defect.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect.Section__c = 'Disclaimer';
        insert defect;
        
        Defect__c defect1 = new Defect__c();
        defect1.Active__c = true;
        defect1.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect1.Section__c = 'Company Information';
        insert defect1;
        
        List <Rejection_Defect__c> ListRejDefects = new List<Rejection_Defect__c>();
        
        Rejection_Defect__c rejDefects = new Rejection_Defect__c();
        rejDefects.Item_Name__c = 'Application must be signed by owner';
        rejDefects.Section__c = 'Disclaimer';
        rejDefects.Applies__c = true;
        rejDefects.Resolved__c = false;
        rejDefects.Registration__c = newLR.Id;
        rejDefects.Defect__c  = defect.Id;
        ListRejdefects.add(rejDefects);
        
        Rejection_Defect__c rejDefects1 = new Rejection_Defect__c();
        rejDefects1.Item_Name__c = 'Application must be signed by owner';
        rejDefects1.Section__c = 'Company Information';
        rejDefects1.Applies__c = false;
        rejDefects1.Resolved__c = false;
        rejDefects1.Registration__c = newLR.Id;
        rejDefects1.Defect__c  = defect1.Id;        
        ListRejdefects.add(rejDefects1);
        insert ListRejdefects;
        
        test.startTest();
             rejDefects1.Applies__c = true;
             update rejDefects1;
        test.stopTest();
    } 
    @isTest 
    static void RejectionDefectTriggerTest2(){
        
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
        insert newLR;
    
        Defect__c defect = new Defect__c();
        defect.Active__c = true;
        defect.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect.Section__c = 'Disclaimer';
        insert defect;
        /*
        Defect__c defect1 = new Defect__c();
        defect1.Active__c = true;
        defect1.Description__c = 'The individual owner, a general partner for partnership, any authorized corporate officer,';
        defect1.Section__c = 'Company Contact';
        insert defect1;
        */
        List <Rejection_Defect__c> ListRejDefects = new List<Rejection_Defect__c>();
        /*
        Rejection_Defect__c rejDefects = new Rejection_Defect__c();
        rejDefects.Item_Name__c = 'Application must be signed by owner';
        rejDefects.Section__c = 'Company Contact';
        rejDefects.Applies__c = true;
        rejDefects.Resolved__c = false;
        rejDefects.Registration__c = newLR.Id;
        rejDefects.Defect__c  = defect1.Id;
        ListRejdefects.add(rejDefects);
        */
        Rejection_Defect__c rejDefects1 = new Rejection_Defect__c();
        rejDefects1.Item_Name__c = 'Application must be signed by owner';
        rejDefects1.Section__c = 'Disclaimer';
        rejDefects1.Applies__c = false;
        rejDefects1.Resolved__c = false;
        rejDefects1.Registration__c = newLR.Id;
        rejDefects1.Defect__c  = defect.Id;        
        ListRejdefects.add(rejDefects1);
        
        Rejection_Defect__c rejDefects2 = new Rejection_Defect__c();
        rejDefects2.Item_Name__c = 'Application must be signed by owner';
        rejDefects2.Section__c = 'Disclaimer';
        rejDefects2.Applies__c = true;
        rejDefects2.Resolved__c = false;
        rejDefects2.Registration__c = newLR.Id;
        rejDefects2.Defect__c  = defect.Id;        
        ListRejdefects.add(rejDefects2);
        
        insert ListRejdefects;
        
        test.startTest();             
             delete rejDefects1;
        test.stopTest();
    }  

}