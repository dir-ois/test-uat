@istest
public class CommunityPayCreditConfirmTest {

    @istest(seeAlldata = true)
    static void testCommunityPayCreditConfirm() {
    //SeeAlldata is set to TRUE to query manage object record
        //BEGIN: some setup items
        Profile commProfile = [SELECT Id FROM Profile WHERE Name = 'Community Registrations User' LIMIT 1];
        
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       
        account a = new Account(
          RecordTypeID=personAccountRTId,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
        insert a;
               
        //system.debug('##### A: ' + a);
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(contactId = acc.PersonContactId, Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = commProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        system.debug('##### u: ' + u);
        insert u;
        
        
        List<User> newUsers = [SELECT Id FROM User WHERE Id=: u.Id AND ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        //END: some setup items
        //validate the initial contact information
        newUsers[0].Street = 'aaaaa\nbbbbb';
        
         Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        License_Registration__c lr = new License_Registration__c();
        lr.Account__c = a.id;
        lr.Applicant__c = acc.PersonContactId;
        lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        lr.Account_Email__c = 'standarduser@testorg.com';
        lr.Amount_Due__c = 100;
        lr.Amount_Paid_Manually__c = 0;
        lr.Amount_Paid_Online__c  = 0;
        
        
        insert lr;
        List<Registration_Question__c > queLst = new List<Registration_Question__c >();
        
        queLst = [SELECT Id,Answered__c FROM Registration_Question__c WHERE Registration_ID__c =: lr.Id];
        for(Registration_Question__c  que: queLst){
            que.Answered__c = TRUE;
        }
        if(!queLst .isEmpty()){
            update queLst;
        }
        
        List<Follow_Up_Question__c> fqLst = new List<Follow_Up_Question__c>();
        
        fqLst = [SELECT Id,Answered__c FROM Follow_Up_Question__c WHERE Registration_Question_ID__c =: lr.Id];
        for(Follow_Up_Question__c  fq: fqLst){
            fq.Answered__c = TRUE;
        }
        if(!fqLst.isEmpty()){
            update fqLst;
        }
        
        lr.Number_of_Attachments__c = 0;
        lr.Number_of_Attachments_Required__c = 0;
        lr.Ready_to_Submit__c = 'Yes';
        update lr;
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = lr.Id;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = lr.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        
       
        
        Test.startTest();
        System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
        
           
           CommunityLoginController controller = new CommunityLoginController();
           controller.username = 'test@tesrtest.com';
           controller.login();
           controller.SignIn();
           controller.forwardToCustomAuthPage();   
        
            ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c();
            newChargentOrder.ChargentOrders__Payment_Method__c = 'Credit Card';
            newChargentOrder.Registration__c  = lr.Id;
            newChargentOrder.Fee_Summary__c = feeSummary.Id;
            newChargentOrder.ChargentOrders__Billing_Email__c = lr.Applicant__r.Email;
            newChargentOrder.ChargentOrders__Subtotal__c = 0;
            insert newChargentOrder;
            
            List<Chargent_Error_Code__mdt> usrMsg = new List<Chargent_Error_Code__mdt>([SELECT MasterLabel, Error_ID__c, Technical_Message__c,User_Message__c 
                                                                                        FROM Chargent_Error_Code__mdt 
                                                                                        ]);        
        
        
        
            ApexPages.CurrentPage().getParameters().put('id', newChargentOrder.Id);
            CommunityPayCreditConfirm CCACH = new CommunityPayCreditConfirm();  
            CCACH.ChargentOrder = newChargentOrder;
            ChargentOrders__Transaction__c tranRec = [SELECT ID,ChargentUserMessage__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Response_Message__c,ChargentErrorCode__c,TransactionMessage__c,ChargentOrders__Gateway_Response__c FROM ChargentOrders__Transaction__c WHERE ChargentOrders__Response__c != 'Approved' LIMIT 1];
            CCACH.transactionId = tranRec.Id;
            
            CCACH.ConfirmSubmitPayment();
            CCACH.Back();
            CCACH.CancelPayment();
        
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
     @istest(seeAlldata = true)
    static void testCommunityPayCreditConfirm1() {
    //SeeAlldata is set to TRUE to query manage object record
        //BEGIN: some setup items
        Profile commProfile = [SELECT Id FROM Profile WHERE Name = 'Community Registrations User' LIMIT 1];
        
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       
        account a = new Account(
          RecordTypeID=personAccountRTId,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
        insert a;
               
        //system.debug('##### A: ' + a);
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(contactId = acc.PersonContactId, Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = commProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        system.debug('##### u: ' + u);
        insert u;
        
        
        List<User> newUsers = [SELECT Id FROM User WHERE Id=: u.Id AND ProfileId =: commProfile.Id AND isActive = true LIMIT 1];
        //END: some setup items
        //validate the initial contact information
        newUsers[0].Street = 'aaaaa\nbbbbb';
        
         Id RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('PAGA Case').getRecordTypeId();
        
        DIR_Case__c dirCase1  = new DIR_Case__c();
        dirCase1.RecordTypeId = RecordTypeId;
        dirCase1.Employer__c = acc.Id;
        dirCase1.PAGA_Court_Case_Number__c = '333';
        dirCase1.Court_Type__c = 'Other';
        dirCase1.Court_Name__c = 'Other';
        //dirCase1.Court_Name_Other_Specify__c = 'test';
        dirCase1.Date_Case_Received__c = Date.Today();
        insert dirCase1;
        
        License_Registration__c lr = new License_Registration__c();
        lr.Account__c = a.id;
        lr.Applicant__c = acc.PersonContactId;
        lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        lr.Account_Email__c = 'standarduser@testorg.com';
        lr.Amount_Due__c = 100;
        lr.Amount_Paid_Manually__c = 0;
        lr.Amount_Paid_Online__c  = 0;
        
        
        insert lr;
        List<Registration_Question__c > queLst = new List<Registration_Question__c >();
        
        queLst = [SELECT Id,Answered__c FROM Registration_Question__c WHERE Registration_ID__c =: lr.Id];
        for(Registration_Question__c  que: queLst){
            que.Answered__c = TRUE;
        }
        if(!queLst .isEmpty()){
            update queLst;
        }
        
        List<Follow_Up_Question__c> fqLst = new List<Follow_Up_Question__c>();
        
        fqLst = [SELECT Id,Answered__c FROM Follow_Up_Question__c WHERE Registration_Question_ID__c =: lr.Id];
        for(Follow_Up_Question__c  fq: fqLst){
            fq.Answered__c = TRUE;
        }
        if(!fqLst.isEmpty()){
            update fqLst;
        }
        
        lr.Number_of_Attachments__c = 0;
        lr.Number_of_Attachments_Required__c = 0;
        lr.Ready_to_Submit__c = 'Yes';
        update lr;
        
        Fee_Summary__c feeSummary = new Fee_Summary__c();
        feeSummary.Registration__c = lr.Id;
        insert feeSummary;
        
        Fee__c newFee = new Fee__c();
        newFee.Fee__c = 100;
        newFee.Registration__c = lr.Id;
        newFee.Fee_Summary__c = feeSummary.Id;
        newFee.Description__c = 'Fee description';
        insert newFee;
        
        
       
        
        Test.startTest();
        System.runAs ( new User(Id = newUsers[0].Id) ) { //runAs in order to avoid MIXED_DML_OPERATION error
        
           
           CommunityLoginController controller = new CommunityLoginController();
           controller.username = 'test@tesrtest.com';
           controller.login();
           controller.SignIn();
           controller.forwardToCustomAuthPage();   
        
            ChargentOrders__ChargentOrder__c newChargentOrder = new ChargentOrders__ChargentOrder__c();
            newChargentOrder.ChargentOrders__Payment_Method__c = 'Credit Card';
            newChargentOrder.Registration__c  = lr.Id;
            newChargentOrder.Fee_Summary__c = feeSummary.Id;
            newChargentOrder.ChargentOrders__Billing_Email__c = lr.Applicant__r.Email;
            newChargentOrder.ChargentOrders__Subtotal__c = 0;
            insert newChargentOrder;
            
            List<Chargent_Error_Code__mdt> usrMsg = new List<Chargent_Error_Code__mdt>([SELECT MasterLabel, Error_ID__c, Technical_Message__c,User_Message__c 
                                                                                        FROM Chargent_Error_Code__mdt 
                                                                                        ]);        
        
        
        
            ApexPages.CurrentPage().getParameters().put('id', newChargentOrder.Id);
            CommunityPayCreditConfirm CCACH = new CommunityPayCreditConfirm();  
            CCACH.ChargentOrder = newChargentOrder;
            ChargentOrders__Transaction__c tranRec = [SELECT ID,ChargentUserMessage__c,ChargentOrders__Gateway_ID__c,ChargentOrders__Response_Message__c,ChargentErrorCode__c,TransactionMessage__c,ChargentOrders__Gateway_Response__c FROM ChargentOrders__Transaction__c WHERE ChargentOrders__Response__c = 'Approved' LIMIT 1];
            CCACH.transactionId = tranRec.Id;
            
            CCACH.ConfirmSubmitPayment();
            CCACH.Back();
            CCACH.CancelPayment();
        
        }
        Test.stopTest();
        //validate that it worked as intended
        
    }
}