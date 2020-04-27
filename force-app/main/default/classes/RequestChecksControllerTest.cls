@isTest
private class RequestChecksControllerTest{
    static testMethod void requestChecksControllerTest(){
        
        List<Trigger_Settings__c> triggerSettings = new List<Trigger_Settings__c>();
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettings.add(rctTriggerSetting);
        
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettings.add(cpTriggerSetting);
        insert triggerSettings;
        
        Account acc = new Account(
            name = 'Test Account',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        insert acc;
        
        Address__c accLocation = new Address__c(
            Entity__c = acc.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        insert accLocation;
        
        Office__c office = new Office__c(
            Name = 'Bakersfield WCA',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert office;
        
        DIR_Employee__c empMgr = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Title__c = 'Senior Deputy Labor Commissioner',
            Office__c = office.Id
        );
        insert empMgr;
        
        DIR_Employee__c emp = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Manager__c = empMgr.Id);
        
        insert emp;
        
        DIR_Case__c cMgmt = new DIR_Case__c(
            Employer__c = acc.id,
            Assigned_Deputy__c = emp.id);
        
        insert cMgmt;
        
        Office_Account__c OA = new Office_Account__c(
            Name = '01-112',
            Office__c = office.Id,
            Account__c = '112'
        );
        insert OA;
        
        
        Transaction__c TRN = new Transaction__c(
            Business_Unit__c = 'WCA 1',
            Check_Count__c = 1,
            Checks_Amount__c = 33.33,
            Deposit_Date__c = Date.today().addDays(-30),
            Office_Account__c = OA.Id,
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 33.33,
            Transaction_Type__c = 'Deposit',
            Treasury_Deposit_Number__c = 'testDepositNumber');
        
        insert TRN;
        
        Receipt__c RCT = new Receipt__c(
            Bank_Location__c = 'CA Bank',
            Instrument_Number__c = 'testCheckNumber',
            Date_Received__c = Date.today().addDays(-30),
            Clearance_Date__c = Date.today().addDays(-15),
            Hold_Date__c = Date.today().addDays(-15),
            Deposit_Account__c = '01-112',
            Status__c = 'Deposited',
            Office_Unit__c = 'WCA 1',
            Payment_Amount__c = 33.33,
            Payment_Exchange__c = 'Division Payment',
            Payment_Type__c = 'Check',
            Payor__c = acc.Id,
            Senior_Deputy__c = empMgr.Id,
            Transaction__c = TRN.Id);
        
        insert RCT;

        Case_Payment__c CP = new Case_Payment__c(
            Case__c = cMgmt.Id,
            Receipt__c = RCT.Id,
            Status__c = 'Posted',
            Payment_Amount__c = 33.33);
        
        insert CP;
        
        Case_Role__c cRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Entity__c = acc.Id,
            Case__c = cMgmt.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = accLocation.Id
        );
        insert cRole;

        Payee__c payee = new Payee__c(
            Case_Management__c = cMgmt.Id,
            Case_Role__c = cRole.Id,
            Factor__c = 100,
            Payee_Type__c = 'Employee',
            Status__c = 'Verified');
        
        insert payee;
        
        Liability_Payment__c LP = new Liability_Payment__c(
            Case_Payment__c = CP.Id
        );
        insert LP;
        
        Payment_Record__c PR = new Payment_Record__c(
            Payee__c = payee.Id,
            Liability_Payment__c = LP.Id,
            Check__c = null,
            Payment_Amount__c = 33.33
        );
        insert PR;
        
        List<Payee__c> payees = new List<Payee__c>();
        payees.add(payee);
        
        PageReference requestChecksPageRef = Page.RequestChecksVFP;
        requestChecksPageRef.getParameters().put('id', payee.Id);
        //ApexPages.currentPage().getParameters().put('ids', payee.Id);
        Test.startTest();
        Test.setCurrentPage(requestChecksPageRef);
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(payees);
        ssc.setSelected(payees);
        
        RequestChecksController rcc = new RequestChecksController(ssc);
        //rcc.ids = payeeIds;
        //rcc.retURL = 'www.google.com';
        rcc.requestChecks();
        rcc.returnToList();
        Test.stopTest();
    }
    
    static testMethod void requestChecksControllerErrorTest(){
        
        List<Payee__c> payees = new List<Payee__c>();
        
        PageReference requestChecksPageRef = Page.RequestChecksVFP;
        //requestChecksPageRef.getParameters().put('id', payee.Id);
        //ApexPages.currentPage().getParameters().put('ids', payee.Id);
        Test.startTest();
        Test.setCurrentPage(requestChecksPageRef);
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(payees);
        ssc.setSelected(payees);
        
        RequestChecksController rcc = new RequestChecksController(ssc);
        //rcc.ids = payeeIds;
        //rcc.retURL = 'www.google.com';
        rcc.requestChecks();
        rcc.returnToList();
        Test.stopTest();
    }
}