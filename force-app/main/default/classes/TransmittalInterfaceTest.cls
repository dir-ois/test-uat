@isTest
public class TransmittalInterfaceTest {
    
    @isTest
    static void testLockBoxPayments(){
    
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
        
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        insert employerAccountLocation;

        
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
        
        Office__c office = new Office__c(
            Name = 'Bakersfield BOFE',
            Office_Number__c = 'BOFE 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert office;
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = office.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert cm;
        
        Case_Role__c defendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        insert defendantCaseRole;
        
        Violation_Type__c violationType = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true,
            Appeal_Deadline_Selector__c = 'Business Days'
        );
        insert violationType;
        
        Assessments__c assessment = new Assessments__c(
            Case_Management__c = cm.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert assessment;
    
        DIR_Violation__c caseIssue = new DIR_Violation__c(
            Violation_Type__c = violationType.Id,
            Case__c = cm.Id,
            Assessment__c = assessment.Id,
            Citation_Amount__c = 3333,
            Wages_Due__c = 2499.75,
            Total_Interest_Amount__c = 833.25,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
        );
        insert caseIssue;
        
        Liability__c liability = new Liability__c(
            Case_Management__c = cm.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = assessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert liability;

        Liable_Party__c liableParty = new Liable_Party__c(
            Liability__c = liability.Id,
            Entity__c = employer.Id,
            Case_Role__c = defendantCaseRole.Id
        );
        insert liableParty;
        
        Liable_Party_Case_Issue__c lpci = new Liable_Party_Case_Issue__c(
            Liable_Party__c = liableParty.Id,
            Case_Issue__c = caseIssue.Id
        );
        insert lpci;
        
        Office_Account__c officeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = office.Id
        );
        insert officeAccount;
        
        Transaction__c trn = new Transaction__c(
            Office_Account__c = officeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-8),
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 44.44,
            Check_Count__c = 1,
            Checks_Amount__c = 44.44,
            Treasury_Deposit_Number__c = '🥓🥩🌈'
        );
        insert trn;
        
        Receipt__c rct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '32-117',
            Bank_Deposit_Date__c = Date.newInstance(2018, 12, 05),
            Date_Received__c = Date.newInstance(2018, 12, 05).addDays(-15),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 44.44,
            Transaction__c = trn.Id,
            Instrument_Number__c = '🌮🍔🌮🍔💯',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id
        );
        insert rct;
        
        Transmittal__c transmittal = new Transmittal__c();
        insert transmittal;

        Case_Payment__c cp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 44.44,
            Status__c = 'New',
            Transmittal__c = transmittal.Id
        );
        insert cp;
        
        test.startTest();
        
        Liability_Payment__c lp110440 = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_on_Behalf_of__c = liableParty.Id,
            Payment_Amount__c = 22.23,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = assessment.Id,
            Liability__c = liability.Id,
            Case_Violation__c = caseIssue.Id
        );
        insert lp110440;
        
        Liability_Payment__c lp110441 = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_on_Behalf_of__c = liableParty.Id,
            Payment_Amount__c = 22.21,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = assessment.Id,
            Liability__c = liability.Id,
            Case_Violation__c = caseIssue.Id
        );
        insert lp110441;
        
        Accounting_Code__c ac00000 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3071',
            Payment_Type__c = 'Penalty',
            PCA__c = '98067',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWF-00',
            FM_Doc_Type__c = 'CWF',
            Description__c = 'BOFE CAR WASH WORKER REST FUND',
            RSC__c = '164300-96',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173000',
            Alt_Account__c = '4173000096',
            Reporting_Structure__c = '73505001'
        );
        insert ac00000;
        
        Accounting_Code__c ac00001 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3071',
            Payment_Type__c = 'Interest',
            PCA__c = '98067',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWF-00',
            FM_Doc_Type__c = 'CWF',
            Description__c = 'BOFE CAR WASH WORKER REST FUND',
            RSC__c = '163000-03',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500006',
            Reporting_Structure__c = '73505001'
        );
        insert ac00001;
        
        Accounting_Code__c ac00208 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3072',
            Payment_Type__c = 'Penalty',
            PCA__c = '98068',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWP-00',
            FM_Doc_Type__c = 'CWP',
            Description__c = 'BOFE CAR WASH WORKER FUND',
            RSC__c = '164300-97',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500097',
            Reporting_Structure__c = '73505001'
        );
        insert ac00208;
        
        Accounting_Code__c ac00209 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3072',
            Payment_Type__c = 'Penalty',
            PCA__c = '98068',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWP-00',
            FM_Doc_Type__c = 'CWP',
            Description__c = 'BOFE CAR WASH WORKER FUND',
            RSC__c = '16300-03',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500003',
            Reporting_Structure__c = '73505001'
        );
        insert ac00209;
        
        Applicable_Accounting_Code__c acac006352 = new Applicable_Accounting_Code__c(
            Accounting_Code__c = ac00000.Id,
            Violation_Type__c = violationType.Id,
            Split_Percentage__c = 50.00,
            Active__c = true
        );
        insert acac006352;
        
        
        Violation_Accounting_Code__c vac0048637 = new Violation_Accounting_Code__c(
            Case_Violation__c = caseIssue.Id,
            Applicable_Accounting_Code__c = acac006352.Id
        );
        insert vac0048637;
        
        Applied_Accounting_Code__c aeac0177577 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110440.Id,
            Accounting_Code__c = ac00000.Id,
            Amount__c = 22.23,
            Payment_Type__c = 'Penalties',
            Violation_Accounting_Code__c = vac0048637.Id
        );
        insert aeac0177577;
        
        Applied_Accounting_Code__c aeac0177578 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110440.Id,
            Accounting_Code__c = ac00000.Id,
            Amount__c = 22.23,
            Payment_Type__c = 'Penalties'
        );
        insert aeac0177578;
        
        Applied_Accounting_Code__c aeac0177579 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110441.Id,
            Accounting_Code__c = ac00001.Id,
            Amount__c = 11.10,
            Payment_Type__c = 'Penalties',
            Violation_Accounting_Code__c = vac0048637.Id
        );
        insert aeac0177579;
        
        Applied_Accounting_Code__c aeac0177580 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110441.Id,
            Accounting_Code__c = ac00209.Id,
            Amount__c = 11.11,
            Payment_Type__c = 'Interest'
        );
        insert aeac0177580;
        
        //create custom setting value
        Key_Value_Store__c settings = new Key_Value_Store__c();
        settings.Name = 'AR018 Email Group';
        settings.Value__c = 'testing@dir.ca.gov';
        insert settings;
        
        //set the values CHK for AR018
        TransmittalInterface.bankDepositDate1 = Date.newInstance(2018, 12, 05);
        TransmittalInterface.depositType = 'R';
        TransmittalInterface.depositId = 'DLSE20181205';
        TransmittalInterface.paymentMethod = 'CHK';
        
        TransmittalInterface tran = new TransmittalInterface();
        tran.sendAR();
        test.stopTest();
        
    }
    
    
    //method for Testing EFT Payments
    @isTest static void testEFTBoxPayments(){
        
        Trigger_Settings__c triggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = false
        );
        insert triggerSetting;
        
        Trigger_Settings__c triggerSetting2 = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = false
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
        
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        insert employerAccountLocation;

        
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
        
        Office__c office = new Office__c(
            Name = 'Bakersfield BOFE',
            Office_Number__c = 'BOFE 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert office;
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = office.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert cm;
        
        Case_Role__c defendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        insert defendantCaseRole;
        
        Violation_Type__c violationType = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true,
            Appeal_Deadline_Selector__c = 'Business Days'
        );
        insert violationType;
        
        Assessments__c assessment = new Assessments__c(
            Case_Management__c = cm.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert assessment;
        
        DIR_Violation__c caseIssue = new DIR_Violation__c(
            Violation_Type__c = violationType.Id,
            Case__c = cm.Id,
            Assessment__c = assessment.Id,
            Citation_Amount__c = 3333,
            Wages_Due__c = 2499.75,
            Total_Interest_Amount__c = 833.25,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
        );
        insert caseIssue;
        
        Liability__c liability = new Liability__c(
            Case_Management__c = cm.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = assessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert liability;
        
        Liable_Party__c liableParty = new Liable_Party__c(
            Liability__c = liability.Id,
            Entity__c = employer.Id,
            Case_Role__c = defendantCaseRole.Id
        );
        insert liableParty;
        
        Liable_Party_Case_Issue__c lpci = new Liable_Party_Case_Issue__c(
            Liable_Party__c = liableParty.Id,
            Case_Issue__c = caseIssue.Id
        );
        insert lpci;
        
        Office_Account__c officeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = office.Id
        );
        insert officeAccount;
        
        Transaction__c trn = new Transaction__c(
            Office_Account__c = officeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-8),
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 44.44,
            Check_Count__c = 1,
            Checks_Amount__c = 44.44,
            Treasury_Deposit_Number__c = '🥓🥩🌈'
        );
        insert trn;
        
        Receipt__c rct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '32-117',
            Bank_Deposit_Date__c = Date.newInstance(2018, 12, 05),
            Date_Received__c = Date.newInstance(2018, 12, 05).addDays(-15),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 44.44,
            Transaction__c = trn.Id,
            Instrument_Number__c = '🌮🍔🌮🍔💯',
            Payment_Type__c = 'EFT',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id
        );
        insert rct;
        
        Transmittal__c transmittal = new Transmittal__c();
        insert transmittal;

        Case_Payment__c cp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 44.44,
            Status__c = 'New',
            Transmittal__c = transmittal.Id
        );
        insert cp;
        
        test.startTest();
        
        Liability_Payment__c lp110440 = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_on_Behalf_of__c = liableParty.Id,
            Payment_Amount__c = 22.23,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = assessment.Id,
            Liability__c = liability.Id,
            Case_Violation__c = caseIssue.Id
        );
        insert lp110440;
        
        Liability_Payment__c lp110441 = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_on_Behalf_of__c = liableParty.Id,
            Payment_Amount__c = 22.21,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = assessment.Id,
            Liability__c = liability.Id,
            Case_Violation__c = caseIssue.Id
        );
        insert lp110441;
        
        Accounting_Code__c ac00000 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3071',
            Payment_Type__c = 'Penalty',
            PCA__c = '98067',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWF-00',
            FM_Doc_Type__c = 'CWF',
            Description__c = 'BOFE CAR WASH WORKER REST FUND',
            RSC__c = '164300-96',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173000',
            Alt_Account__c = '4173000096',
            Reporting_Structure__c = '73505001'
        );
        insert ac00000;
        
        Accounting_Code__c ac00001 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3071',
            Payment_Type__c = 'Interest',
            PCA__c = '98067',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWF-00',
            FM_Doc_Type__c = 'CWF',
            Description__c = 'BOFE CAR WASH WORKER REST FUND',
            RSC__c = '163000-03',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500006',
            Reporting_Structure__c = '73505001'
        );
        insert ac00001;
        
        Accounting_Code__c ac00208 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3072',
            Payment_Type__c = 'Penalty',
            PCA__c = '98068',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWP-00',
            FM_Doc_Type__c = 'CWP',
            Description__c = 'BOFE CAR WASH WORKER FUND',
            RSC__c = '164300-97',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500097',
            Reporting_Structure__c = '73505001'
        );
        insert ac00208;
        
        Accounting_Code__c ac00209 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3072',
            Payment_Type__c = 'Penalty',
            PCA__c = '98068',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWP-00',
            FM_Doc_Type__c = 'CWP',
            Description__c = 'BOFE CAR WASH WORKER FUND',
            RSC__c = '16300-03',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500003',
            Reporting_Structure__c = '73505001'
        );
        insert ac00209;
        
        Applicable_Accounting_Code__c acac006352 = new Applicable_Accounting_Code__c(
            Accounting_Code__c = ac00000.Id,
            Violation_Type__c = violationType.Id,
            Split_Percentage__c = 50.00,
            Active__c = true
        );
        insert acac006352;
        
        Violation_Accounting_Code__c vac0048637 = new Violation_Accounting_Code__c(
            Case_Violation__c = caseIssue.Id,
            Applicable_Accounting_Code__c = acac006352.Id
        );
        insert vac0048637;
        
        Applied_Accounting_Code__c aeac0177577 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110440.Id,
            Accounting_Code__c = ac00000.Id,
            Amount__c = 22.23,
            Payment_Type__c = 'Penalties',
            Violation_Accounting_Code__c = vac0048637.Id
        );
        insert aeac0177577;
        
        Applied_Accounting_Code__c aeac0177578 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110440.Id,
            Accounting_Code__c = ac00000.Id,
            Amount__c = 22.23,
            Payment_Type__c = 'Penalties'
        );
        insert aeac0177578;
        
        Applied_Accounting_Code__c aeac0177579 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110441.Id,
            Accounting_Code__c = ac00001.Id,
            Amount__c = 11.10,
            Payment_Type__c = 'Penalties',
            Violation_Accounting_Code__c = vac0048637.Id
        );
        insert aeac0177579;
        
        Applied_Accounting_Code__c aeac0177580 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110441.Id,
            Accounting_Code__c = ac00209.Id,
            Amount__c = 11.11,
            Payment_Type__c = 'Interest'
        );
        insert aeac0177580;
        
        //create custom setting value
        Key_Value_Store__c settings = new Key_Value_Store__c();
        settings.Name = 'AR018 Email Group';
        settings.Value__c = 'testing@dir.ca.gov';
        insert settings;
        
        //set the values for AR018
        TransmittalInterface.bankDepositDate1 = Date.newInstance(2018, 12, 05);
        TransmittalInterface.depositType = 'R';
        TransmittalInterface.depositId = 'DLSE20181205';
        TransmittalInterface.paymentMethod = 'EFT';
        
        TransmittalInterface tran = new TransmittalInterface();
        tran.sendAR();
        test.stopTest();  
    }
    
    //method for checking Required Fields
    @isTest static void testEFTBoxPaymentsWithoutReqiredField(){
        
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
        
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        insert employerAccountLocation;

        
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
        
        Office__c office = new Office__c(
            Name = 'Bakersfield BOFE',
            Office_Number__c = 'BOFE 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert office;
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = office.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert cm;
        
        Case_Role__c defendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        insert defendantCaseRole;
        
        Violation_Type__c violationType = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true,
            Appeal_Deadline_Selector__c = 'Business Days'
        );
        insert violationType;
        
        Assessments__c assessment = new Assessments__c(
            Case_Management__c = cm.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert assessment;
        
        DIR_Violation__c caseIssue = new DIR_Violation__c(
            Violation_Type__c = violationType.Id,
            Case__c = cm.Id,
            Assessment__c = assessment.Id,
            Citation_Amount__c = 3333,
            Wages_Due__c = 2499.75,
            Total_Interest_Amount__c = 833.25,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
        );
        insert caseIssue;
        
        Liability__c liability = new Liability__c(
            Case_Management__c = cm.Id,
            Manual_Citation_Number__c = 'Whoops',
            Manual_Citation_Date__c = Date.today().addDays(-15),
            Assessment__c = assessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert liability;
        
        Liable_Party__c liableParty = new Liable_Party__c(
            Liability__c = liability.Id,
            Entity__c = employer.Id,
            Case_Role__c = defendantCaseRole.Id
        );
        insert liableParty;
        
        Liable_Party_Case_Issue__c lpci = new Liable_Party_Case_Issue__c(
            Liable_Party__c = liableParty.Id,
            Case_Issue__c = caseIssue.Id
        );
        insert lpci;
        
        Office_Account__c officeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = office.Id
        );
        insert officeAccount;
        
        Transaction__c trn = new Transaction__c(
            Office_Account__c = officeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-8),
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 44.44,
            Check_Count__c = 1,
            Checks_Amount__c = 44.44,
            Treasury_Deposit_Number__c = '🥓🥩🌈'
        );
        insert trn;
        
        Receipt__c rct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '32-117',
            Bank_Deposit_Date__c = Date.newInstance(2018, 12, 05),
            Date_Received__c = Date.newInstance(2018, 12, 05).addDays(-15),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 44.44,
            Transaction__c = trn.Id,
            Instrument_Number__c = '🌮🍔🌮🍔💯',
            Payment_Type__c = 'EFT',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id
        );
        insert rct;
        
        Transmittal__c transmittal = new Transmittal__c();
        insert transmittal;

        Case_Payment__c cp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 44.44,
            Status__c = 'New',
            Transmittal__c = transmittal.Id
        );
        insert cp;
        
        test.startTest();
        
        Liability_Payment__c lp110440 = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_on_Behalf_of__c = liableParty.Id,
            Payment_Amount__c = 22.23,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = assessment.Id,
            Liability__c = liability.Id,
            Case_Violation__c = caseIssue.Id
        );
        insert lp110440;
        
        Liability_Payment__c lp110441 = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_on_Behalf_of__c = liableParty.Id,
            Payment_Amount__c = 22.21,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = assessment.Id,
            Liability__c = liability.Id,
            Case_Violation__c = caseIssue.Id
        );
        insert lp110441;
        
        Accounting_Code__c ac00000 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3071',
            Payment_Type__c = 'Penalty',
            PCA__c = '98067',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWF-00',
            FM_Doc_Type__c = 'CWF',
            Description__c = 'BOFE CAR WASH WORKER REST FUND',
            RSC__c = '164300-96',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173000',
            Alt_Account__c = '4173000096',
            Reporting_Structure__c = '73505001'
        );
        insert ac00000;
        
        Accounting_Code__c ac00001 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3071',
            Payment_Type__c = 'Interest',
            PCA__c = '98067',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWF-00',
            FM_Doc_Type__c = 'CWF',
            Description__c = 'BOFE CAR WASH WORKER REST FUND',
            RSC__c = '163000-03',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500006',
            Reporting_Structure__c = '73505001'
        );
        insert ac00001;
        
        Accounting_Code__c ac00208 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3072',
            Payment_Type__c = 'Penalty',
            PCA__c = '98068',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWP-00',
            FM_Doc_Type__c = 'CWP',
            Description__c = 'BOFE CAR WASH WORKER FUND',
            RSC__c = '164300-97',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500097',
            Reporting_Structure__c = '73505001'
        );
        insert ac00208;
        
        Accounting_Code__c ac00209 = new Accounting_Code__c(
            Industry__c = 'Car Wash',
            Program__c = 'BOFE',
            Fund__c = '3072',
            Payment_Type__c = 'Penalty',
            PCA__c = '98068',
            ASC__c = '00',
            Index__c = '5001',
            FS__c = 'O',
            Current_Doc__c = 'DLSE2CWP-00',
            FM_Doc_Type__c = 'CWP',
            Description__c = 'BOFE CAR WASH WORKER FUND',
            RSC__c = '16300-03',
            Active__c = true,
            Labor_Code__c = 'IWC Orders Section 4(c)',
            RecordTypeId = Schema.SObjectType.Accounting_Code__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Account__c = '4173500',
            Alt_Account__c = '4173500003',
            Reporting_Structure__c = '73505001'
        );
        insert ac00209;
        
        Applicable_Accounting_Code__c acac006352 = new Applicable_Accounting_Code__c(
            Accounting_Code__c = ac00000.Id,
            Violation_Type__c = violationType.Id,
            Split_Percentage__c = 50.00,
            Active__c = true
        );
        insert acac006352;
        
        Violation_Accounting_Code__c vac0048637 = new Violation_Accounting_Code__c(
            Case_Violation__c = caseIssue.Id,
            Applicable_Accounting_Code__c = acac006352.Id
        );
        insert vac0048637;
        
        Applied_Accounting_Code__c aeac0177577 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110440.Id,
            Accounting_Code__c = ac00000.Id,
            Amount__c = 22.23,
            Payment_Type__c = 'Penalties',
            Violation_Accounting_Code__c = vac0048637.Id
        );
        insert aeac0177577;
        
        Applied_Accounting_Code__c aeac0177578 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110440.Id,
            Accounting_Code__c = ac00000.Id,
            Amount__c = 22.23,
            Payment_Type__c = 'Penalties'
        );
        insert aeac0177578;
        
        Applied_Accounting_Code__c aeac0177579 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110441.Id,
            Accounting_Code__c = ac00001.Id,
            Amount__c = 11.10,
            Payment_Type__c = 'Penalties',
            Violation_Accounting_Code__c = vac0048637.Id
        );
        insert aeac0177579;
        
        Applied_Accounting_Code__c aeac0177580 = new Applied_Accounting_Code__c(
            Liability_Payment__c = lp110441.Id,
            Accounting_Code__c = ac00209.Id,
            Amount__c = 11.11,
            Payment_Type__c = 'Interest'
        );
        insert aeac0177580;
        
        Key_Value_Store__c settings = new Key_Value_Store__c();
        settings.Name = 'AR018 Email Group';
        settings.Value__c = 'testing@dir.ca.gov';
        insert settings;
        
        //set the values for AR018
        
        TransmittalInterface.depositType = 'R';
        TransmittalInterface.depositId = 'DLSE20181205';
        TransmittalInterface.paymentMethod = 'EFT';
        
        TransmittalInterface tran  = new TransmittalInterface();
        tran.sendAR();
        test.stopTest();  
    }
}