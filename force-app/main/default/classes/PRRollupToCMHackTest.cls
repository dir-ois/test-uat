@isTest
public with sharing class PRRollupToCMHackTest{
    
    @isTest
    static void testPRRollupToCMHack(){
        
        Trigger_Settings__c triggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        insert triggerSetting;
        
        Trigger_Settings__c triggerSetting2 = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        insert triggerSetting2;
        
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        insert employer;
        /*
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        insert employerAccountLocation;*/
        /*
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        insert statePayeeAccount;
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        insert statePayeeAccountLocation;
        */
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        insert employeePayeeAccount;
        /*
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        insert employeePayeeAccountLocation;
        */
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy; 
        
        Office__c WCAoffice = new Office__c(
            Name = 'Bakersfield WCA',
            Office_Number__c = 'WCA 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert WCAoffice;
        
        DIR_Case__c WCAcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = WCAoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Deposited_Funds__c = 44.44,
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert WCAcase;
        /*
        Case_Role__c WCAdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        insert WCAdefendantCaseRole;*/
        /*
        Case_Role__c WCAstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        insert WCAstatePayeeCaseRole;
        */
        Case_Role__c WCAemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Entity__c = employeePayeeAccount.Id,
            Case__c = WCAcase.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active' //,
            //Location__c = employeePayeeAccountLocation.Id
        );
        insert WCAemployeePayeeCaseRole;
        
/*        Payee__c WCAstatePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = WCAcase.Id,
            Case_Role__c = WCAstatePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert WCAstatePayee;
        
        Payee__c WCAcourtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = WCAcase.Id,
            Case_Role__c = WCAcourtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert WCAcourtPayee;
        */
        
        Payee__c WCAemployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = WCAcase.Id,
            Case_Role__c = WCAemployeePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert WCAemployeePayee;
        
        Violation_Type__c WCAviolationType = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        insert WCAviolationType;
        /*
        Assessments__c WCAassessment = new Assessments__c(
            Case_Management__c = WCAcase.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert WCAassessment;
    */
        DIR_Violation__c WCAcaseIssue = new DIR_Violation__c(
            Violation_Type__c = WCAviolationType.Id,
            Case__c = WCAcase.Id,
            //Assessment__c = WCAassessment.Id,
            Citation_Amount__c = 3333,
            Wages_Due__c = 2499.75,
            Total_Interest_Amount__c = 833.25,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()
        );
        insert WCAcaseIssue;
        /*
        Liability__c WCAliability = new Liability__c(
            Case_Management__c = WCAcase.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = WCAassessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert WCAliability;
        
        Liable_Party__c WCAliableParty = new Liable_Party__c(
            Liability__c = WCAliability.Id,
            Entity__c = employer.Id,
            Case_Role__c = WCAdefendantCaseRole.Id
        );
        insert WCAliableParty;
        
        Liable_Party_Case_Issue__c WCAlpci = new Liable_Party_Case_Issue__c(
            Liable_Party__c = WCAliableParty.Id,
            Case_Issue__c = WCAcaseIssue.Id
        );
        insert WCAlpci;
        
        Payment_Plan__c WCApaymentPlan = new Payment_Plan__c(
            Case__c = WCAcase.Id
        );
        insert WCApaymentPlan;
        
        Judgement__c WCAjudgment = new Judgement__c(
            Case_Management__c = WCAcase.Id,
            Type__c = 'ODA',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert WCAjudgment;
        
        Liability_Judgement__c WCAjudgmentParty = new Liability_Judgement__c(
            Judgement__c = WCAjudgment.Id,
            Liable_Party__c = WCAliableParty.Id
        );
        insert WCAjudgmentParty;
        */
        Office_Account__c WCAofficeAccount = new Office_Account__c(
            Name = '01-112',
            Office__c = WCAoffice.Id
        );
        insert WCAofficeAccount;
        
        Transaction__c WCAtrn = new Transaction__c(
            Office_Account__c = WCAofficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-8),
            Business_Unit__c = 'WCA',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 44.44,
            Check_Count__c = 1,
            Checks_Amount__c = 44.44,
            Treasury_Deposit_Number__c = '🥓🥩🌈'
        );
        insert WCAtrn;
        
        Receipt__c WCArct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '01-112',
            Date_Received__c = Date.today().addDays(-15),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 44.44,
            Transaction__c = WCAtrn.Id,
            Instrument_Number__c = '🌮🍔🌮🍔💯',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'WCA 1',
            Senior_Deputy__c = manager.Id
        );
        insert WCArct;

        Case_Payment__c WCAcp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Receipt__c = WCArct.Id,
            Payment_Amount__c = 44.44,
            Status__c = 'New'
        );
        insert WCAcp;
        
        Liability_Payment__c WCAlp = new Liability_Payment__c(
            Case_Payment__c = WCAcp.Id,
            Payment_Amount__c = 44.44,
            Payment_Applied_To__c = 'Wages',
            //Assessment__c = WCAassessment.Id,
            //Liability__c = WCAliability.Id,
            Case_Violation__c = WCAcaseIssue.Id
        );
        insert WCAlp;
        
        Check_Batch__c WCAcb = new Check_Batch__c(
            Status__c = 'Printed',
            Office_Account__c = WCAofficeAccount.Id,
            Request_Date__c = Date.today().addDays(-12),
            Requested_By__c = deputy.Id,
            Requesting_Cashier__c = deputy.Id,
            Requesting_Cashier_Date__c = Date.today().addDays(-6),
            Requesting_Cashier_Attest__c = true,
            Reviewed_By__c = manager.Id
        );
        insert WCAcb;
        
        Check__c WCAcheck = new Check__c(
            RecordTypeId = Schema.SObjectType.Check__c.getRecordTypeInfosByName().get('Check Approved').getRecordTypeId(),
            Check_Batch__c = WCAcb.Id,
            Check_Number__c = 'X50987467XX',
            Amount__c = 44.44,
            Case__c = WCAcase.Id,
            Office_Account__c = WCAofficeAccount.Id,
            Payee__c = WCAemployeePayee.Id,
            Issue_Date__c = Date.today().addDays(-1),
            Mailed_Date__c = Date.today().addDays(-1),
            Status_Date__c = Date.today().addDays(-1),
            Status__c = 'Printed',
            Approved_By__c = manager.Id,
            Approved_Date__c = Date.today().addDays(-1),
            Approved_Check__c = true
        );
        insert WCAcheck;
        
        Payment_Record__c WCApr1 = new Payment_Record__c(
            Liability_Payment__c = WCAlp.Id,
            Payment_Amount__c = 22.21,
            Payee__c = WCAemployeePayee.Id,
            Check__c = WCAcheck.Id,
            Check_Issued__c = true
        );
        insert WCApr1;
        
        Payment_Record__c WCApr2 = new Payment_Record__c(
            Liability_Payment__c = WCAlp.Id,
            Payment_Amount__c = 22.23,
            Payee__c = WCAemployeePayee.Id,
            Check__c = WCAcheck.Id,
            Check_Issued__c = true
        );
        insert WCApr2;
        
        List<Id> WCAprIds = new List<Id>();
        WCAprIds.add(WCApr1.Id);
        WCAprIds.Add(WCApr2.Id);
        
        Test.startTest();
        
        Database.executeBatch(new PRRollupToCMHack(), 2);

        List<Payment_Record__c> testPRs = [SELECT Id, Name, Payee__c, Payee__r.Case_Management__c, Payee__r.Case_Management__r.Id
                                            FROM Payment_Record__c
                                            WHERE Id IN :WCAprIds];
                                            
        Id testCMId = testPRs[0].Payee__r.Case_Management__r.Id;
        
        List<DIR_Case__c> testCM = [SELECT Id, Name, Funds_Drawn_on_Deposits__c
                                        FROM DIR_Case__c
                                        WHERE Id = :testCMId];
                                        
        System.assertEquals(44.44, testCM[0].Funds_Drawn_on_Deposits__c);
        
        delete WCApr1;
        
        testCM = [SELECT Id, Name, Funds_Drawn_on_Deposits__c
                                        FROM DIR_Case__c
                                        WHERE Id = :testCMId];
        
        System.assertEquals(22.23, testCM[0].Funds_Drawn_on_Deposits__c);
        
        
        Test.stopTest();
    }
}