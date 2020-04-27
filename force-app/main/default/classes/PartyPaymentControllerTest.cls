/* Tests the PartyPaymentController apex class, which drives the PartyPaymentVFP. Any other 'PartyPayment' tests or classes should be deleted. */
@isTest
public with sharing class PartyPaymentControllerTest{
    
    @testSetup
    static void setup(){
        
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
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        insert courtPayeeAccount;
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        insert courtPayeeAccountLocation;
        
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
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        insert employeePayeeAccountLocation;
        
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
        
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert BOFEoffice;
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        insert CCUoffice;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        insert BOFEdefendantCaseRole;
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        insert BOFEstatePayeeCaseRole;
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        insert BOFEcourtPayeeCaseRole;
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        insert BOFEemployeePayeeCaseRole;
        System.debug('####BOFEemployeePayeeCaseRole = '+BOFEemployeePayeeCaseRole);
        
        Payee__c BOFEstatePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEstatePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert BOFEstatePayee;
        
        Payee__c BOFEcourtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEcourtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert BOFEcourtPayee;
        
        /* May need to be commented out */
        Payee__c BOFEemployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEemployeePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        insert BOFEemployeePayee;
        /* */
        
        Violation_Type__c BOFEviolationType = new Violation_Type__c(
            Appeal_Deadline_Days__c = 15,
            Appeal_Deadline_Selector__c = 'Business Days',
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Active__c = true
        );
        insert BOFEviolationType;
        
        Assessments__c BOFEassessment = new Assessments__c(
            Case_Management__c = BOFEcase.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert BOFEassessment;
        
        DIR_Violation__c BOFEcaseIssue = new DIR_Violation__c(
            Violation_Type__c = BOFEviolationType.Id,
            Case__c = BOFEcase.Id,
            Assessment__c = BOFEassessment.Id,
            Citation_Amount__c = 6666,
            Wages_Due__c = 4999.50,
            Total_Interest_Amount__c = 1666.50,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()
        );
        insert BOFEcaseIssue;
        
        Liability__c BOFEliability = new Liability__c(
            Assessment__c = BOFEassessment.Id,
            RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        insert BOFEliability;
        
        Liable_Party__c BOFEliableParty = new Liable_Party__c(
            Liability__c = BOFEliability.Id,
            Entity__c = employer.Id,
            Case_Role__c = BOFEdefendantCaseRole.Id
        );
        insert BOFEliableParty;
        
        Liable_Party_Case_Issue__c BOFElpci = new Liable_Party_Case_Issue__c(
            Liable_Party__c = BOFEliableParty.Id,
            Case_Issue__c = BOFEcaseIssue.Id
        );
        insert BOFElpci;
        
        Payment_Plan__c BOFEpaymentPlan = new Payment_Plan__c(
            Case__c = BOFEcase.Id
        );
        insert BOFEpaymentPlan;
        
        Judgement__c BOFEjudgment = new Judgement__c(
            Case_Management__c = BOFEcase.Id,
            Type__c = 'JEU',
            RecordTypeId = '012t0000000PJUW'
            ///RecordTypeId = Schema.SObjectType.Liability__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
        );
        insert BOFEjudgment;
        
        Liability_Judgement__c BOFEjudgmentParty = new Liability_Judgement__c(
            Judgement__c = BOFEjudgment.Id,
            Liable_Party__c = BOFEliableParty.Id
        );
        insert BOFEjudgmentParty;
        
        Office_Account__c CCUofficeAccount = new Office_Account__c(
            Name = '32-117',
            Office__c = CCUoffice.Id
        );
        insert CCUofficeAccount;
        /*
        Transaction__c BOFEtrn = new Transaction__c(
            Office_Account__c = CCUofficeAccount.Id,
            Deposit_Date__c = Date.today().addDays(-7),
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 55.55,
            Check_Count__c = 1,
            Checks_Amount__c = 55.55,
            Treasury_Deposit_Number__c = '😜😲😅'
        );
        insert BOFEtrn;
        
        Receipt__c BOFErct = new Receipt__c(
            Payor__c = employer.Id,
            Deposit_Account__c = '32-117',
            Date_Received__c = Date.today().addDays(-14),
            Status__c = 'Deposited',
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 55.55,
            Transaction__c = BOFEtrn.Id,
            Instrument_Number__c = '🍺🍻🍸🍹🍷',
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32',
            Senior_Deputy__c = manager.Id
        );
        insert BOFErct;
        
        Case_Payment__c BOFEcp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErct.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'New'
        );
        insert BOFEcp;
        */
        
    }
    
    public static testMethod void TestPartyPaymentController(){
        
        test.startTest();
        
        DIR_Case__c cm = [SELECT Id, Name, Employer__c, Employer__r.Id, Assigned_Deputy__r.Manager__r.Id,
                            (SELECT Id, Name, Payment_Amount__c
                                FROM Case_Payments__r),
                            (SELECT Id, Name
                                FROM Payment_Plans__r)
                            FROM DIR_Case__c];
        List<Case_Payment__c> casePaymentList = cm.Case_Payments__r;
        System.debug('### 1stcasePaymentList, should be null at this point: '+casePaymentList);
        List<Payment_Plan__c> paymentPlanList = cm.Payment_Plans__r;
        System.debug('### 1stpaymentPlanList, should be 1: '+paymentPlanList);
        
        
        Payment_Plan__c pp = [SELECT Id, Name, Case__c FROM Payment_Plan__c WHERE Case__c = :cm.Id];
        System.debug('### pp = '+pp);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cm);
        PageReference pageRef = Page.PartyPaymentVFP;
        pageRef.getParameters().put('caseId', String.valueOf(cm.Id));
        Test.setCurrentPage(pageRef);
        
        PartyPaymentController ppController = new PartyPaymentController(sc);
        ppController.getPlans();
        ppController.getBehalfs();
        ppController.fetchJWList();
        ppController.paymentAmount = 6.66;
        ppController.selectedPaymentExchange = 'PARTY TO PARTY';
        ppController.rct.Instrument_Number__c = 'Decamethylcyclopentasiloxane';
        ppController.rct.Payment_Type__c = 'Check';
        ppController.rct.Bank_Location__c = 'CA Bank';
        ppController.rct.Date_Received__c = Date.today();
        ppController.rct.Senior_Deputy__c = cm.Assigned_Deputy__r.Manager__r.Id;
        ppController.rct.Payor__c = cm.Employer__r.Id;
        ppController.selectedBehalf = cm.Employer__r.Id;
        ppController.ExtractAssessments();
        ppController.selectedPlan = pp.Id;
        ppController.setPaymentPlan();
        ppController.ciwList[0].allocationToWages = 3.35;
        ppController.ciwList[0].allocationToInterest = 0.11;
        ppController.jwList[0].postHearingInterestAllocation = '1.33';
        ppController.jwList[0].postJudgmentInterestAllocation = '0.33';
        ppController.jwList[0].attorneyFeesAllocation = '0.75';
        ppController.jwList[0].filingFeesAllocation = '0.79';
        ppController.SaveRecords();

        DIR_Case__c cm2 = [SELECT Id, Name, Employer__c, Employer__r.Id,
                            (SELECT Id, Name, Payment_Amount__c
                                FROM Case_Payments__r),
                            (SELECT Id, Name
                                FROM Payment_Plans__r)
                            FROM DIR_Case__c];
        List<Case_Payment__c> casePaymentList2 = cm2.Case_Payments__r;
        System.debug('### 2ndcasePaymentList, should be 1: '+casePaymentList2);
        List<Payment_Plan__c> paymentPlanList2 = cm2.Payment_Plans__r;
        System.debug('### 2ndpaymentPlanList, should be 1: '+paymentPlanList2);
        
        System.debug('###ppController.rct.Payment_Amount__c = '+ppController.rct.Payment_Amount__c);
        System.debug('###ppController.cs.Id = '+ppController.cs.Id);
        
        /*
        List<DIR_Employee__c> empList = [SELECT Id, Name FROM DIR_Employee__c];
        System.debug('###empList = '+empList);
        */
        
        List<Receipt__c> testRCTs = [SELECT Id, Name, Payment_Amount__c
                                        FROM Receipt__c];
        System.debug('testRCTs: '+testRCTs);
        
        List<Case_Payment__c> testCPs = [SELECT Id, Name, Payment_Amount__c,
                                                (SELECT Id, Name, Payment_Amount__c
                                                    FROM Liability_Payments__r),
                                                (SELECT Id, Name, Allocated_Amount__c
                                                    FROM Judgment_Payments__r)
                                            FROM Case_Payment__c];
        System.debug('testCPs: '+testCPs);
        
        List<Liability_Payment__c> testLPs = new List<Liability_Payment__c>();
        List<Judgment_Payment__c> testJPs = new List<Judgment_Payment__c>();
        
        for(Case_Payment__c cp : testCPs){
            testLPs.addAll(cp.Liability_Payments__r);
            testJPs.addAll(cp.Judgment_Payments__r);
        }
        
        System.debug('testLPs: '+testLPs);
        System.debug('testJPs: '+testJPs);
        
        Decimal sumOfLPs = 0.00;
        
        for(Liability_Payment__c lp : testLPs){
            sumOfLPs += lp.Payment_Amount__c;
        }
        
        System.assertEquals(3.35 + 0.11, sumOfLPs);
        
        Decimal sumOfJPs = 0.00;
        
        for(Judgment_Payment__c jp : testJPs){
            sumOfJPs += jp.Allocated_Amount__c;
        }
        
        System.assertEquals(3.35 + 0.11 + 1.33 + 0.33 + 0.75 + 0.79, sumOfJPs);
        
        test.stopTest();
    }
}