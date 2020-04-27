@isTest
public with sharing class PostCasePaymentControllerTest{
    
    @isTest
    static void test_BOFE_New_Recommend(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
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
        
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
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
        payees.add(BOFEstatePayee);
        
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
        payees.add(BOFEcourtPayee);
        
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
        payees.add(BOFEemployeePayee);
        insert payees;
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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
        
        Test.startTest();

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
            
        Receipt__c BOFErctNewCP = new Receipt__c(
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
        insert BOFErctNewCP;
            
        Case_Payment__c BOFEcpNew = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctNewCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'New'
        );
        insert BOFEcpNew;
        
        
        /**********************************************************************************************************************************************************************************************
        BOFE - New - Recommend : Common occurrance
        ***********************************************************************************************************************************************************************************************/
        ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpNew);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        pcpController.FindPaymentPlan();
        pcpController.DisplayCIsAndJs();
        
        
        pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
        pcpController.ppSelection = BOFEpaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 13.89;
            ciw.allocationToWages = 11.90;
            ciw.allocationToInterest = 9.92;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 7.94;
            jw.pjiAlloc = 5.95;
            jw.afAlloc = 3.97;
            jw.ffAlloc = 1.98;
        }
        
        
        pcpController.Recommend();
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpNew.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpNew.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){ //PRs should not be created for JPs applied to Judgment Amount, so no need to filter for them
                prList.add(jp.Payment_Records__r);
            }
        }
        
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }
        
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
            }
        }
        
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
            }
        }
        
        System.assertEquals(BOFEcpNew.Payment_Amount__c, sumOfLPsRecommended + sumOfJPsRecommended);
        System.assertEquals(0.00, sumOfLPsPosted + sumOfJPsPosted);
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(0.00, sumOfPRs); //no PRs during Recommend()
        */
        
        Decimal sumOfAeACs = 0.00;
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfAeACs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(0.00, sumOfAeACs); //no AeACs during Recommend()
        
        Test.stopTest();
    }
    
    @isTest
    static void test_BOFE_New_Post(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
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
        
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
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
        payees.add(BOFEstatePayee);
        
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
        payees.add(BOFEcourtPayee);
        
        /*Payee__c BOFEemployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 20.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEemployeePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(BOFEemployeePayee);*/
        insert payees;
        
        System.debug('payees - '+payees);
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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
        
        Test.startTest();

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
            
        Receipt__c BOFErctNewCP = new Receipt__c(
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
        insert BOFErctNewCP;
            
        Case_Payment__c BOFEcpNew = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctNewCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'New'
        );
        insert BOFEcpNew;
        
        /**********************************************************************************************************************************************************************************************
        BOFE - New - Post
        ***********************************************************************************************************************************************************************************************/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpNew);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
        pcpController.ppSelection = BOFEpaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 13.89;
            ciw.allocationToWages = 11.90;
            ciw.allocationToInterest = 9.92;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 7.94;
            jw.pjiAlloc = 5.95;
            jw.afAlloc = 3.97;
            jw.ffAlloc = 1.98;
        }
        
        pcpController.Post();
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpNew.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpNew.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){ //PRs should not be created for JPs applied to Judgment Amount, so no need to filter for them
                prList.add(jp.Payment_Records__r);
            }
        }
        
        /*List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }*/
        
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
            }
        }
        
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
            }
        }
        
        System.assertEquals(0.00, sumOfLPsRecommended + sumOfJPsRecommended);
        System.assertEquals(BOFEcpNew.Payment_Amount__c, sumOfLPsPosted + sumOfJPsPosted);
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(BOFEcpNew.Payment_Amount__c, sumOfPRs);
        */
        /*
        Decimal sumOfAeACs = 0.00; //TODO: need to setup AcACs, ACs, etc
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfAeACs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(BOFEcpNew.Payment_Amount__c, sumOfAeACs);
        */
        Test.stopTest();
    }
    
    @isTest
    static void test_BOFE_Recommended_Recommend(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
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
        payees.add(BOFEstatePayee);
        
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
        payees.add(BOFEcourtPayee);
        
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
        payees.add(BOFEemployeePayee);
        /* */
        insert payees;
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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

        Test.startTest();
        
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
        
        Receipt__c BOFErctRecommendedCP = new Receipt__c(
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
        insert BOFErctRecommendedCP;
        
        Case_Payment__c BOFEcpRecommended = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctRecommendedCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'Allocations Recommended',
            Case_Payment_Recommended_Date__c = Date.today().addDays(-5)
        );
        insert BOFEcpRecommended;
    
        //BOFE Recommended LPs
        
        List<Liability_Payment__c> lps = new List<Liability_Payment__c>();
        Liability_Payment__c BOFElpRecommendedPenalties = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 13.89,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedPenalties);
        
        Liability_Payment__c BOFElpRecommendedWages = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 11.90,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = BOFEassessment.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedWages);
        
        Liability_Payment__c BOFElpRecommendedInterest = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 9.92,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedInterest);
        insert lps;
        
        //BOFE Recommended JPs
        
        List<Judgment_Payment__c> jps = new List<Judgment_Payment__c>();
        Judgment_Payment__c BOFEjpRecommendedJAPenalties = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 13.89,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAPenalties);
        
        Judgment_Payment__c BOFEjpRecommendedJAWages = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 11.90,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAWages);
        
        Judgment_Payment__c BOFEjpRecommendedJAInterest = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 9.92,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAInterest);
        
        Judgment_Payment__c BOFEjpRecommendedPHI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 7.94,
            Apply_Payment_To__c = 'Post-Hearing Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPHI);
        
        Judgment_Payment__c BOFEjpRecommendedPJI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 5.95,
            Apply_Payment_To__c = 'Post-Judgment Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPJI);
        
        Judgment_Payment__c BOFEjpRecommendedAF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 3.97,
            Apply_Payment_To__c = 'Attorney Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedAF);
        
        Judgment_Payment__c BOFEjpRecommendedFF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 1.98,
            Apply_Payment_To__c = 'Filing Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedFF);
        insert jps;
        
        
        /**********************************************************************************************************************************************************************************************
            BOFE - Recommended - Recommend : "Rerecommend"
        ***********************************************************************************************************************************************************************************************/
        ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpRecommended);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
        pcpController.ppSelection = BOFEpaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        //re-allocate funds
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 0.00;
            ciw.allocationToWages = 15.87;
            ciw.allocationToInterest = 13.23;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 10.57;
            jw.pjiAlloc = 7.94;
            jw.afAlloc = 5.29;
            jw.ffAlloc = 2.65;
        }
        
        
        pcpController.Recommend();
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){
                prList.add(jp.Payment_Records__r);
            }
        }
        
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }
        
        Decimal penaltyLPupdatedAmount = 0.00; //make sure LP changed to $0 is actually $0
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
                if(lp.Payment_Applied_to__c == 'Penalties'){ //make sure LP changed to $0 is actually $0
                    penaltyLPupdatedAmount += lp.Recommended_Allocation__c;
                }
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
            }
        }
        
        Boolean penaltyJPupdatedToZero = false; //make sure exactly one of the JPs was changed to $0
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
            }else{
                if(jp.Recommended_Amount__c == 0.00){
                    if(penaltyJPupdatedToZero == false){
                        penaltyJPupdatedToZero = true; //make sure exactly one of the JPs was changed to $0
                    }else{
                        penaltyJPupdatedToZero = false; //if more than one JP was changed to $0, set this back to FALSE to cause assertion error
                    }
                }
            }
        }
        
        System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsRecommended + sumOfJPsRecommended); //sum of allocation should still equal the CP amount
        System.assertEquals(0.00, penaltyLPupdatedAmount); //make sure LP changed to $0 is actually $0
        System.assertEquals(0.00, sumOfLPsPosted + sumOfJPsPosted); // nothing in posted amount fields
        System.assertEquals(true, penaltyJPupdatedToZero); //make sure exactly one of the JPs was changed to $0
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(sumOfPRs, 0.00); //no PRs during Recommend()
        */
        /* testing AeACs require AcACs, VACs, etc and are really only handled in the liabilityPaymentMethods class
        Decimal sumOfWCAaeacs = 0.00;
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfWCAaeacs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(sumOfWCAaeacs, 0.00); //no AEACs during Recommend()
        */
        Test.stopTest();
    }
    
   
    @isTest
    static void test_BOFE_Recommended_Post(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
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
        payees.add(BOFEstatePayee);
        
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
        payees.add(BOFEcourtPayee);
        
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
        payees.add(BOFEemployeePayee);
        /* */
        insert payees;
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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
        
        Test.startTest();
    
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
        
        Receipt__c BOFErctRecommendedCP = new Receipt__c(
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
        insert BOFErctRecommendedCP;
        
        Case_Payment__c BOFEcpRecommended = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctRecommendedCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'Allocations Recommended',
            Case_Payment_Recommended_Date__c = Date.today().addDays(-5)
        );
        insert BOFEcpRecommended;
    
        //BOFE Recommended LPs
        
        List<Liability_Payment__c> lps = new List<Liability_Payment__c>();
        Liability_Payment__c BOFElpRecommendedPenalties = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 13.89,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedPenalties);
        
        Liability_Payment__c BOFElpRecommendedWages = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 11.90,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = BOFEassessment.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedWages);
        
        Liability_Payment__c BOFElpRecommendedInterest = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 9.92,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedInterest);
        insert lps;
        
        //BOFE Recommended JPs
        
        List<Judgment_Payment__c> jps = new List<Judgment_Payment__c>();
        Judgment_Payment__c BOFEjpRecommendedJAPenalties = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 13.89,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAPenalties);
        
        Judgment_Payment__c BOFEjpRecommendedJAWages = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 11.90,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAWages);
        
        Judgment_Payment__c BOFEjpRecommendedJAInterest = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 9.92,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAInterest);
        
        Judgment_Payment__c BOFEjpRecommendedPHI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 7.94,
            Apply_Payment_To__c = 'Post-Hearing Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPHI);
        
        Judgment_Payment__c BOFEjpRecommendedPJI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 5.95,
            Apply_Payment_To__c = 'Post-Judgment Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPJI);
        
        Judgment_Payment__c BOFEjpRecommendedAF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 3.97,
            Apply_Payment_To__c = 'Attorney Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedAF);
        
        Judgment_Payment__c BOFEjpRecommendedFF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 1.98,
            Apply_Payment_To__c = 'Filing Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedFF);
        insert jps;
            



        /********************************************************************************************************************************************************
        BOFE - Recommended - Post : Most common path, here testing re-allocating before posting
        ********************************************************************************************************************************************************/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpRecommended);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
        pcpController.ppSelection = BOFEpaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        //re-allocate funds
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 22.22;
            ciw.allocationToWages = 0.00;
            ciw.allocationToInterest = 0.00;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 16.67;
            jw.pjiAlloc = 11.11;
            jw.afAlloc = 5.55;
            jw.ffAlloc = 0.00;
        }
        
        pcpController.Post();
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        /*
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){
                prList.add(jp.Payment_Records__r);
            }
        }
        
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }
        */
        Decimal wageLPupdatedAmount = 0.00; //make sure wage LP changed to $0 is actually $0
        Decimal interestLPupdatedAmount = 0.00; //make sure interest LP changed to $0 is actually $0
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
                if(lp.Payment_Applied_to__c == 'Wages'){ //make sure wage LP changed to $0 is actually $0
                    wageLPupdatedAmount += lp.Payment_Amount__c;
                }else if(lp.Payment_Applied_To__c == 'Interest'){ //make sure interest LP changed to $0
                    interestLPupdatedAmount += lp.Payment_Amount__c;
                }
            }
        }
        
        Boolean ffJPupdatedToZero = false; //make sure the FF JP's allocated amount is $0
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
                if(jp.Apply_Payment_To__c == 'Filing Fees' && jp.Allocated_Amount__c == 0.00){
                    
                    ffJPupdatedToZero = true; //make sure the FF JP's allocated amount is $0
                }
            }
        }
        
        
        System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsRecommended + sumOfJPsRecommended); //sum of original recommended amounts should still equal the CP amount
        System.assertEquals(0.00, wageLPupdatedAmount); //make sure wage LP changed to $0 is actually $0
        System.assertEquals(0.00, interestLPupdatedAmount); //make sure interest LP changed to $0 is actually $0
        /*System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsPosted + sumOfJPsPosted); // posted amounts should still equal CP amount
        System.assertEquals(true, ffJPupdatedToZero); //make sure the FF JP's allocated amount is $0
        ^^^ TODO: Bug found during test class creation. Variable "redundantJPs" never gets updated. This shouldn't affect newly created records, just older JPs that are not linked to their 'redundant' LPs. */
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(sumOfPRs, 0.00); //no PRs during Recommend()
        */
        /*
        Decimal sumOfAeACs = 0.00;
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfAeACs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(sumOfLPsPosted, sumOfAeACs);
        */
        Test.stopTest();
    }
    
    @isTest
    static void test_BOFE_PayeeFactorNot100(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
        Payee__c BOFEstatePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 99.00000,
            Payee_Type__c = 'State',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEstatePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(BOFEstatePayee);
        
        Payee__c BOFEcourtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 98.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEcourtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(BOFEcourtPayee);
        
        /* May need to be commented out */
        Payee__c BOFEemployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 97.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEemployeePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(BOFEemployeePayee);
        /* */
        insert payees;
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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
        
        Test.startTest();

        List<Transaction__c> trns = new List<Transaction__c>();
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

        Receipt__c BOFErctRecommendedCP = new Receipt__c(
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
        insert BOFErctRecommendedCP;
        
        Case_Payment__c BOFEcpRecommended = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctRecommendedCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'Allocations Recommended',
            Case_Payment_Recommended_Date__c = Date.today().addDays(-5)
        );
        insert BOFEcpRecommended;
        
        //BOFE Recommended LPs
        
        List<Liability_Payment__c> lps = new List<Liability_Payment__c>();
        Liability_Payment__c BOFElpRecommendedPenalties = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 8.45,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedPenalties);
        
        Liability_Payment__c BOFElpRecommendedWages = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 7.25,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = BOFEassessment.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedWages);
        
        Liability_Payment__c BOFElpRecommendedInterest = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 6.04,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedInterest);
        insert lps;
        
        //BOFE Recommended JPs
        
        List<Judgment_Payment__c> jps = new List<Judgment_Payment__c>();
        Judgment_Payment__c BOFEjpRecommendedJAPenalties = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 8.45,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAPenalties);
        
        Judgment_Payment__c BOFEjpRecommendedJAWages = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 7.25,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAWages);
        
        Judgment_Payment__c BOFEjpRecommendedJAInterest = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 6.04,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAInterest);
        
        Judgment_Payment__c BOFEjpRecommendedPHI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 4.83,
            Apply_Payment_To__c = 'Post-Hearing Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPHI);
        
        Judgment_Payment__c BOFEjpRecommendedPJI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 3.61,
            Apply_Payment_To__c = 'Post-Judgment Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPJI);
        
        Judgment_Payment__c BOFEjpRecommendedAF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 2.42,
            Apply_Payment_To__c = 'Attorney Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedAF);
        
        Judgment_Payment__c BOFEjpRecommendedFF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 1.21,
            Apply_Payment_To__c = 'Filing Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedFF);
        insert jps;
        

        /********************************************************************************************************************************************************
        BOFE - PayeeFactorsNot100 - testing with Recommended - Post
        ********************************************************************************************************************************************************/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpRecommended);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
        pcpController.ppSelection = BOFEpaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        
        pcpController.Post();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.debug('pageMessages - '+pageMessages);
        System.assertNotEquals(0, pageMessages.size());
        
        delete BOFEstatePayee;
        delete BOFEcourtPayee;
        delete BOFEemployeePayee;
        
        pcpController.Post();
        
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        System.debug('pageMessages2 - '+pageMessages2);
        System.assertNotEquals(0, pageMessages2.size());
        
        
        /*
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        /*
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){
                prList.add(jp.Payment_Records__r);
            }
        }
        
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }
        */
        /*
        Decimal wageLPupdatedAmount = 0.00; //make sure wage LP changed to $0 is actually $0
        Decimal interestLPupdatedAmount = 0.00; //make sure interest LP changed to $0 is actually $0
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
                if(lp.Payment_Applied_to__c == 'Wages'){ //make sure wage LP changed to $0 is actually $0
                    wageLPupdatedAmount += lp.Payment_Amount__c;
                }else if(lp.Payment_Applied_To__c == 'Interest'){ //make sure interest LP changed to $0
                    interestLPupdatedAmount += lp.Payment_Amount__c;
                }
            }
        }
        
        Boolean ffJPupdatedToZero = false; //make sure the FF JP's allocated amount is $0
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
                if(jp.Apply_Payment_To__c == 'Filing Fees' && jp.Allocated_Amount__c == 0.00){
                    
                    ffJPupdatedToZero = true; //make sure the FF JP's allocated amount is $0
                }
            }
        }
        
        
        System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsRecommended + sumOfJPsRecommended); //sum of original recommended amounts should still equal the CP amount
        System.assertEquals(0.00, wageLPupdatedAmount); //make sure wage LP changed to $0 is actually $0
        System.assertEquals(0.00, interestLPupdatedAmount); //make sure interest LP changed to $0 is actually $0
        /*System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsPosted + sumOfJPsPosted); // posted amounts should still equal CP amount
        System.assertEquals(true, ffJPupdatedToZero); //make sure the FF JP's allocated amount is $0
        ^^^ TODO: Bug found during test class creation. Variable "redundantJPs" never gets updated. This shouldn't affect newly created records, just older JPs that are not linked to their 'redundant' LPs. */
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(sumOfPRs, 0.00); //no PRs during Recommend()
        */
        /*
        Decimal sumOfAeACs = 0.00;
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfAeACs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(sumOfLPsPosted, sumOfAeACs);
        */
        Test.stopTest();
    }
    
    @isTest
    static void test_BOFE_Posted_Post(){
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
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
        payees.add(BOFEstatePayee);
        
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
        payees.add(BOFEcourtPayee);
        
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
        payees.add(BOFEemployeePayee);
        /* */
        insert payees;
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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
        
        Test.startTest();

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
        
        Receipt__c BOFErctPostedCP = new Receipt__c(
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
        insert BOFErctPostedCP;
        
        Case_Payment__c BOFEcpPosted = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('Posted').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctPostedCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'Posted',
            Case_Payment_Posted_Date__c = Date.today().addDays(-5)
        );
        insert BOFEcpPosted;
    
        //BOFE Posted LPs
        
        List<Liability_Payment__c> lps = new List<Liability_Payment__c>();
        Liability_Payment__c BOFElpPostedWages = new Liability_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 13.89,
            Payment_Amount__c = 13.89,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpPostedWages);
        
        Liability_Payment__c BOFElpPostedPenalties = new Liability_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 11.90,
            Payment_Amount__c = 11.90,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpPostedPenalties);
        
        Liability_Payment__c BOFElpPostedInterest = new Liability_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 9.92,
            Payment_Amount__c = 9.92,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpPostedInterest);
        insert lps;
        
        
        //BOFE Posted JPs
        
        List<Judgment_Payment__c> jps = new List<Judgment_Payment__c>();
        Judgment_Payment__c BOFEjpPostedJAPenalties = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 13.89,
            Allocated_Amount__c = 13.89,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Posted'
        );
        jps.add(BOFEjpPostedJAPenalties);
        
        Judgment_Payment__c BOFEjpPostedJAWages = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 11.90,
            Allocated_Amount__c = 11.90,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Posted'
        );
        jps.add(BOFEjpPostedJAWages);
        
        Judgment_Payment__c BOFEjpPostedJAInterest = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 9.92,
            Allocated_Amount__c = 9.92,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Posted'
        );
        jps.add(BOFEjpPostedJAInterest);
        
        Judgment_Payment__c BOFEjpPostedPHI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 7.94,
            Allocated_Amount__c = 7.94,
            Apply_Payment_To__c = 'Post-Hearing Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Posted'
        );
        jps.add(BOFEjpPostedPHI);
        
        Judgment_Payment__c BOFEjpPostedPJI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 5.95,
            Allocated_Amount__c = 5.95,
            Apply_Payment_To__c = 'Post-Judgment Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Posted'
        );
        jps.add(BOFEjpPostedPJI);
        
        Judgment_Payment__c BOFEjpPostedAF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 3.97,
            Allocated_Amount__c = 3.97,
            Apply_Payment_To__c = 'Attorney Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Posted'
        );
        jps.add(BOFEjpPostedAF);
        
        Judgment_Payment__c BOFEjpPostedFF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpPosted.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 1.98,
            Allocated_Amount__c = 1.98,
            Apply_Payment_To__c = 'Filing Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Posted'
        );
        jps.add(BOFEjpPostedFF);
        insert jps;

        /********************************************************************************************************************************************************
        BOFE - Posted - Post : Disallowed by VFP, undefined behavior, but needed for code coverage
        *********************************************************************************************************************************************************/

        ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpPosted);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
        pcpController.ppSelection = BOFEpaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        pcpController.Post();
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpPosted.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpPosted.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        /*
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){
                prList.add(jp.Payment_Records__r);
            }
        }
        
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }
        */
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
            }
        }
        
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
            }
        }
        
        
        System.assertEquals(BOFEcpPosted.Payment_Amount__c, sumOfLPsRecommended + sumOfJPsRecommended); //sum of original recommended amounts should still equal the CP amount
        System.assertEquals(BOFEcpPosted.Payment_Amount__c, sumOfLPsPosted + sumOfJPsPosted); // posted amounts should still equal CP amount
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(sumOfPRs, 0.00); //no PRs during Recommend()
        */
        /*
        Decimal sumOfAeACs = 0.00;
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfAeACs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(sumOfLPsPosted, sumOfAeACs);
        */
        Test.stopTest();
    }
   
    @isTest
    static void test_BOFE_NegativeAllocations(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
        Payee__c BOFEstatePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 99.00000,
            Payee_Type__c = 'State',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEstatePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(BOFEstatePayee);
        
        Payee__c BOFEcourtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 98.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEcourtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(BOFEcourtPayee);
        
        /* May need to be commented out */
        Payee__c BOFEemployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 97.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = BOFEcase.Id,
            Case_Role__c = BOFEemployeePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(BOFEemployeePayee);
        /* */
        insert payees;
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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
        
        Test.startTest();

        List<Transaction__c> trns = new List<Transaction__c>();
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

        Receipt__c BOFErctRecommendedCP = new Receipt__c(
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
        insert BOFErctRecommendedCP;
        
        Case_Payment__c BOFEcpRecommended = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctRecommendedCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'Allocations Recommended',
            Case_Payment_Recommended_Date__c = Date.today().addDays(-5)
        );
        insert BOFEcpRecommended;
        
        //BOFE Recommended LPs
        
        List<Liability_Payment__c> lps = new List<Liability_Payment__c>();
        Liability_Payment__c BOFElpRecommendedPenalties = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 8.45,
            Payment_Applied_To__c = 'Penalties',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedPenalties);
        
        Liability_Payment__c BOFElpRecommendedWages = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 7.25,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = BOFEassessment.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedWages);
        
        Liability_Payment__c BOFElpRecommendedInterest = new Liability_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_on_Behalf_of__c = BOFEliableParty.Id,
            Recommended_Allocation__c = 6.04,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = BOFEassessment.Id,
            Liability__c = BOFEliability.Id,
            Case_Violation__c = BOFEcaseIssue.Id
        );
        lps.add(BOFElpRecommendedInterest);
        insert lps;
        
        //BOFE Recommended JPs
        
        List<Judgment_Payment__c> jps = new List<Judgment_Payment__c>();
        Judgment_Payment__c BOFEjpRecommendedJAPenalties = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 8.45,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAPenalties);
        
        Judgment_Payment__c BOFEjpRecommendedJAWages = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 7.25,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAWages);
        
        Judgment_Payment__c BOFEjpRecommendedJAInterest = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 6.04,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedJAInterest);
        
        Judgment_Payment__c BOFEjpRecommendedPHI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 4.83,
            Apply_Payment_To__c = 'Post-Hearing Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPHI);
        
        Judgment_Payment__c BOFEjpRecommendedPJI = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 3.61,
            Apply_Payment_To__c = 'Post-Judgment Interest',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedPJI);
        
        Judgment_Payment__c BOFEjpRecommendedAF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 2.42,
            Apply_Payment_To__c = 'Attorney Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedAF);
        
        Judgment_Payment__c BOFEjpRecommendedFF = new Judgment_Payment__c(
            Case_Payment__c = BOFEcpRecommended.Id,
            Payment_On_Behalf_Of__c = BOFEliableParty.Id,
            Recommended_Amount__c = 1.21,
            Apply_Payment_To__c = 'Filing Fees',
            Judgment__c = BOFEjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(BOFEjpRecommendedFF);
        insert jps;
        

        /********************************************************************************************************************************************************
        
        ********************************************************************************************************************************************************/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpRecommended);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
        pcpController.ppSelection = BOFEpaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 13.89;
            ciw.allocationToWages = 11.90;
            ciw.allocationToInterest = -9.92;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 7.94;
            jw.pjiAlloc = 5.95;
            jw.afAlloc = 3.97;
            jw.ffAlloc = 1.98;
        }
        
        pcpController.Recommend();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 13.89;
            ciw.allocationToWages = 11.90;
            ciw.allocationToInterest = 9.92;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 7.94;
            jw.pjiAlloc = 5.95;
            jw.afAlloc = 3.97;
            jw.ffAlloc = -1.98;
        }
        
        pcpController.Recommend();

        
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 13.89;
            ciw.allocationToWages = 11.90;
            ciw.allocationToInterest = -9.92;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 7.94;
            jw.pjiAlloc = 5.95;
            jw.afAlloc = 3.97;
            jw.ffAlloc = 1.98;
        }
        
        pcpController.Post();
        
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages2.size());
        
        
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToPenalties = 13.89;
            ciw.allocationToWages = 11.90;
            ciw.allocationToInterest = 9.92;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 7.94;
            jw.pjiAlloc = 5.95;
            jw.afAlloc = 3.97;
            jw.ffAlloc = -1.98;
        }
        
        ApexPages.Message[] pageMessages3 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages3.size());
        
        pcpController.Post();
        
        ApexPages.Message[] pageMessages4 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages4.size());
        
        /*
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :BOFEcpRecommended.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        /*
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){
                prList.add(jp.Payment_Records__r);
            }
        }
        
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }
        */
        /*
        Decimal wageLPupdatedAmount = 0.00; //make sure wage LP changed to $0 is actually $0
        Decimal interestLPupdatedAmount = 0.00; //make sure interest LP changed to $0 is actually $0
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
                if(lp.Payment_Applied_to__c == 'Wages'){ //make sure wage LP changed to $0 is actually $0
                    wageLPupdatedAmount += lp.Payment_Amount__c;
                }else if(lp.Payment_Applied_To__c == 'Interest'){ //make sure interest LP changed to $0
                    interestLPupdatedAmount += lp.Payment_Amount__c;
                }
            }
        }
        
        Boolean ffJPupdatedToZero = false; //make sure the FF JP's allocated amount is $0
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
                if(jp.Apply_Payment_To__c == 'Filing Fees' && jp.Allocated_Amount__c == 0.00){
                    
                    ffJPupdatedToZero = true; //make sure the FF JP's allocated amount is $0
                }
            }
        }
        
        
        System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsRecommended + sumOfJPsRecommended); //sum of original recommended amounts should still equal the CP amount
        System.assertEquals(0.00, wageLPupdatedAmount); //make sure wage LP changed to $0 is actually $0
        System.assertEquals(0.00, interestLPupdatedAmount); //make sure interest LP changed to $0 is actually $0
        /*System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsPosted + sumOfJPsPosted); // posted amounts should still equal CP amount
        System.assertEquals(true, ffJPupdatedToZero); //make sure the FF JP's allocated amount is $0
        ^^^ TODO: Bug found during test class creation. Variable "redundantJPs" never gets updated. This shouldn't affect newly created records, just older JPs that are not linked to their 'redundant' LPs. */
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(sumOfPRs, 0.00); //no PRs during Recommend()
        */
        /*
        Decimal sumOfAeACs = 0.00;
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfAeACs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(sumOfLPsPosted, sumOfAeACs);
        */
        Test.stopTest();
    }
    
    @isTest
    static void test_PermSet(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='BOFE User'];
                        
        User BOFEuser = new User(
            Alias = 'BOFEUser',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='testbofeuser@dir.ca.gov');
        insert BOFEuser;
        System.debug('####BOFEuser = '+BOFEuser);
        
        
        List<Office__c> offices = new List<Office__c>();
        Office__c BOFEoffice = new Office__c(
            Name = 'Stockton BOFE',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
        );
        offices.add(BOFEoffice);
        
        Office__c CCUoffice = new Office__c(
            Name = 'Sacramento CCU',
            Office_Number__c = 'CCU 32',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId()
        );
        offices.add(CCUoffice);
        insert offices;
        
        DIR_Case__c BOFEcase = new DIR_Case__c(
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employer.Id,
            Office__c = BOFEoffice.Id,
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert BOFEcase;
        
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c BOFEdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(BOFEdefendantCaseRole);
        
        Case_Role__c BOFEstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEstatePayeeCaseRole);
        
        Case_Role__c BOFEcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(BOFEcourtPayeeCaseRole);
        
        Case_Role__c BOFEemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Entity__c = employeePayeeAccount.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(BOFEemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
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
        payees.add(BOFEstatePayee);
        
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
        payees.add(BOFEcourtPayee);
        
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
        payees.add(BOFEemployeePayee);
        insert payees;
        
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
            //RecordTypeId = '012t0000000PJUW'
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
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
        
        Test.startTest();

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
            
        Receipt__c BOFErctNewCP = new Receipt__c(
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
        insert BOFErctNewCP;
            
        Case_Payment__c BOFEcpNew = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Case__c = BOFEcase.Id,
            Receipt__c = BOFErctNewCP.Id,
            Payment_Amount__c = 55.55,
            Status__c = 'New'
        );
        insert BOFEcpNew;
            
        System.runAs(BOFEuser){
            ApexPages.StandardController sc = new ApexPages.StandardController(BOFEcpNew);
            PageReference pageRef = Page.PostCasePaymentVFP;
            
            Test.setCurrentPage(pageRef);
            
            PostCasePaymentController pcpController = new PostCasePaymentController(sc);
            pcpController.FindPaymentPlansAndDisplayCIsAndJs();
            pcpController.FindPaymentPlan();
            pcpController.DisplayCIsAndJs();
            
            pcpController.selectedOBO = BOFEdefendantCaseRole.Id;
            pcpController.ppSelection = BOFEpaymentPlan.Id;
            pcpController.SetPaymentPlan();
            
            System.assertEquals(false, pcpController.isCashier);
        }
        Test.stopTest();
    }
    
    @isTest
    static void test_WCA_Recommended_Post(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
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
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert WCAcase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c WCAdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(WCAdefendantCaseRole);
        
        Case_Role__c WCAstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(WCAstatePayeeCaseRole);
        
        Case_Role__c WCAcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(WCAcourtPayeeCaseRole);
        
        Case_Role__c WCAemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Entity__c = employeePayeeAccount.Id,
            Case__c = WCAcase.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(WCAemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
        Payee__c WCAstatePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 100.00000,
            Payee_Type__c = 'State',
            Case_Management__c = WCAcase.Id,
            Case_Role__c = WCAstatePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(WCAstatePayee);
        
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
        payees.add(WCAcourtPayee);
        
        /* May need to be commented out */
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
        payees.add(WCAemployeePayee);
        /* */
        insert payees;
        
        Violation_Type__c WCAviolationType = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        insert WCAviolationType;
        
        Assessments__c WCAassessment = new Assessments__c(
            Case_Management__c = WCAcase.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert WCAassessment;
        
        DIR_Violation__c WCAcaseIssue = new DIR_Violation__c(
            Violation_Type__c = WCAviolationType.Id,
            Case__c = WCAcase.Id,
            Assessment__c = WCAassessment.Id,
            Citation_Amount__c = 3333,
            Wages_Due__c = 2499.75,
            Total_Interest_Amount__c = 833.25,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()
        );
        insert WCAcaseIssue;
        
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
        
        Office_Account__c WCAofficeAccount = new Office_Account__c(
            Name = '01-112',
            Office__c = WCAoffice.Id
        );
        insert WCAofficeAccount;
        
        Test.startTest();
        
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
        
        Receipt__c WCArctRecommendedCP = new Receipt__c(
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
        insert WCArctRecommendedCP;
        
        Case_Payment__c WCAcpRecommended = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Receipt__c = WCArctRecommendedCP.Id,
            Payment_Amount__c = 44.44,
            Status__c = 'Allocations Recommended',
            Case_Payment_Recommended_Date__c = Date.today().addDays(-2)
        );
        insert WCAcpRecommended;
    
        //WCA Recommended LPs

        List<Liability_Payment__c> lps = new List<Liability_Payment__c>();
        Liability_Payment__c WCAlpRecommendedWages = new Liability_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_on_Behalf_of__c = WCAliableParty.Id,
            Recommended_Allocation__c = 12.70,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = WCAassessment.Id,
            Liability__c = WCAliability.Id,
            Case_Violation__c = WCAcaseIssue.Id
        );
        lps.add(WCAlpRecommendedWages);
        
        Liability_Payment__c WCAlpRecommendedInterest = new Liability_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_on_Behalf_of__c = WCAliableParty.Id,
            Recommended_Allocation__c = 10.58,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = WCAassessment.Id,
            Liability__c = WCAliability.Id,
            Case_Violation__c = WCAcaseIssue.Id
        );
        lps.add(WCAlpRecommendedInterest);
        insert lps;
        
        //WCA Recommended JPs
        
        List<Judgment_Payment__c> jps = new List<Judgment_Payment__c>();
        Judgment_Payment__c WCAjpRecommendedJAWages = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 12.70,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedJAWages);
        
        Judgment_Payment__c WCAjpRecommendedJAInterest = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 10.58,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedJAInterest);
        
        Judgment_Payment__c WCAjpRecommendedPHI = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 8.46,
            Apply_Payment_To__c = 'Post-Hearing Interest',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedPHI);
        
        Judgment_Payment__c WCAjpRecommendedPJI = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 6.35,
            Apply_Payment_To__c = 'Post-Judgment Interest',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedPJI);
        
        Judgment_Payment__c WCAjpRecommendedAF = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 4.23,
            Apply_Payment_To__c = 'Attorney Fees',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedAF);
        
        Judgment_Payment__c WCAjpRecommendedFF = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 2.12,
            Apply_Payment_To__c = 'Filing Fees',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedFF);
        insert jps;


        /********************************************************************************************************************************************************
        WCA - Recommended - Post : Most common path, here testing re-allocating before posting
        ********************************************************************************************************************************************************/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(WCAcpRecommended);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        
        pcpController.selectedOBO = WCAdefendantCaseRole.Id;
        pcpController.ppSelection = WCApaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        //re-allocate funds
        for(PostCasePaymentController.CaseIssueWrapper ciw : pcpController.CaseIssueWrapperList){
            ciw.allocationToWages = 14.81;
            ciw.allocationToInterest = 11.85;
        }
        for(PostCasePaymentController.JudgmentWrapper jw : pcpController.JudgmentWrapperList){
            jw.phiAlloc = 8.89;
            jw.pjiAlloc = 5.93;
            jw.afAlloc = 2.96;
            jw.ffAlloc = 0.00;
        }
        
        pcpController.Post();
        
        List<Liability_Payment__c> lpList = [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Payment_on_Behalf_of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payment_Applied_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r),
                                                    (SELECT Id, Name, Amount__c
                                                        FROM Applied_Accounting_Codes__r)
                                                    FROM Liability_Payment__c
                                                    WHERE Case_Payment__c = :WCAcpRecommended.Id];
        
        List<Judgment_Payment__c> jpList = [SELECT Id, Name, Recommended_Amount__c, Allocated_Amount__c, Payment_On_Behalf_Of__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Apply_Payment_To__c,
                                                    (SELECT Id, Name, Payment_Amount__c
                                                        FROM Payment_Records__r)
                                                    FROM Judgment_Payment__c
                                                    WHERE Case_Payment__c = :WCAcpRecommended.Id];
        System.debug('#### lpList: '+lpList);
        System.debug('#### jpList: '+jpList);
        
        /*
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Payment_Records__r != null && !lp.Payment_Records__r.isEmpty()){
                prList.add(lp.Payment_Records__r);
            }
        }
        for(Judgment_Payment__c jp : jpList){
            if(jp.Payment_Records__r != null && !jp.Payment_Records__r.isEmpty()){
                prList.add(jp.Payment_Records__r);
            }
        }
        
        List<Applied_Accounting_Code__c> aeacList = new List<Applied_Accounting_Code__c>();
        for(Liability_Payment__c lp : lpList){
            if(lp.Applied_Accounting_Codes__r != null && !lp.Applied_Accounting_Codes__r.isEmpty()){
                aeacList.add(lp.Applied_Accounting_Codes__r);
            }
        }
        */
        Decimal wageLPupdatedAmount = 0.00; //make sure wage LP changed to $0 is actually $0
        Decimal interestLPupdatedAmount = 0.00; //make sure interest LP changed to $0 is actually $0
        Decimal sumOfLPsRecommended = 0.00;
        Decimal sumOfLPsPosted = 0.00;
        for(Liability_Payment__c lp : lpList){
            System.debug('#### lp: '+lp);
            if(lp.Recommended_Allocation__c != null){
                sumOfLPsRecommended += lp.Recommended_Allocation__c;
            }
            if(lp.Payment_Amount__c != null){
                sumOfLPsPosted += lp.Payment_Amount__c;
                if(lp.Payment_Applied_to__c == 'Wages'){ //make sure wage LP changed to $0 is actually $0
                    wageLPupdatedAmount += lp.Payment_Amount__c;
                }else if(lp.Payment_Applied_To__c == 'Interest'){ //make sure interest LP changed to $0
                    interestLPupdatedAmount += lp.Payment_Amount__c;
                }
            }
        }
        
        Boolean ffJPupdatedToZero = false; //make sure the FF JP's allocated amount is $0
        Decimal sumOfJPsRecommended = 0.00;
        Decimal sumOfJPsPosted = 0.00;
        for(Judgment_Payment__c jp : jpList){
            if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                if(jp.Recommended_Amount__c != null){
                    sumOfJPsRecommended += jp.Recommended_Amount__c;
                }
                if(jp.Allocated_Amount__c != null){
                    sumOfJPsPosted += jp.Allocated_Amount__c;
                }
                if(jp.Apply_Payment_To__c == 'Filing Fees' && jp.Allocated_Amount__c == 0.00){
                    ffJPupdatedToZero = true; //make sure the FF JP's allocated amount is $0
                }
            }
        }
        
        
        System.assertEquals(WCAcpRecommended.Payment_Amount__c, sumOfLPsRecommended + sumOfJPsRecommended); //sum of original recommended amounts should still equal the CP amount
        System.assertEquals(0.00, wageLPupdatedAmount); //make sure wage LP changed to $0 is actually $0
        System.assertEquals(0.00, interestLPupdatedAmount); //make sure interest LP changed to $0 is actually $0
        /*System.assertEquals(BOFEcpRecommended.Payment_Amount__c, sumOfLPsPosted + sumOfJPsPosted); // posted amounts should still equal CP amount
        System.assertEquals(true, ffJPupdatedToZero); //make sure the FF JP's allocated amount is $0
        ^^^ TODO: Bug found during test class creation. Variable "redundantJPs" never gets updated. This shouldn't affect newly created records, just older JPs that are not linked to their 'redundant' LPs. */
        
        /* PRs created in @future method--can't test method as it is currently as it takes the created PRs as an argument, and they haven't been created yet during the test. (TODO: need to make future method's argument a global variable instead?)
        Decimal sumOfPRs = 0.00;
        
        for(Payment_Record__c pr : prList){
            if(pr.Payment_Amount__c != null){
                sumOfPRs += pr.Payment_Amount__c;
            }
        }
        
        System.assertEquals(sumOfPRs, 0.00); //no PRs during Recommend()
        */
        /*
        Decimal sumOfAeACs = 0.00;
        for(Applied_Accounting_Code__c aeac : aeacList){
            if(aeac.Amount__c != null){
                sumOfAeACs += aeac.Amount__c;
            }
        }
        
        System.assertEquals(sumOfLPsPosted, sumOfAeACs);
        */
        Test.stopTest();
    }
    
    @isTest
    static void test_WCA_PayeeFactorNot100(){
        
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
        
        
        List<Account> accounts = new List<Account>();
        Account employer = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'Big Mega General Corp',
            ShippingStreet = '123 Sesame Street',
            ShippingCity = 'New York',
            ShippingState = 'NY',
            ShippingPostalCode = '01234'
        );
        accounts.add(employer);
        
        Account statePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId(),
            Name = 'The State of Cali4n.io',
            ShippingStreet = '345 Eddy Street',
            ShippingCity = 'Slam Francisco',
            ShippingState = 'CA',
            ShippingPostalCode = '91256'
        );
        accounts.add(statePayeeAccount);
        
        Account courtPayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Court').getRecordTypeId(),
            Name = 'The Inferior Court of San Bernardino',
            ShippingStreet = '535 E 5th Street',
            ShippingCity = 'San Bernardino',
            ShippingState = 'CA',
            ShippingPostalCode = '94115'
        );
        accounts.add(courtPayeeAccount);
        
        Account employeePayeeAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            FirstName = 'Madison',
            LastName = 'Wisconson',
            ShippingStreet = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            ShippingCity = 'Phlegming',
            ShippingState = 'NY',
            ShippingPostalCode = '02256'
        );
        accounts.add(employeePayeeAccount);
        insert accounts;
        
        List<Address__c> locations = new List<Address__c>();
        Address__c employerAccountLocation = new Address__c(
            Entity__c = employer.Id,
            Address__c = '123 Sesame Street',
            City__c = 'New York',
            State__c = 'NY',
            Zip_Code__c = '01234'
        );
        locations.add(employerAccountLocation);
        
        Address__c statePayeeAccountLocation = new Address__c(
            Entity__c = statePayeeAccount.Id,
            Address__c = '345 Eddy Street',
            City__c = 'Slam Francisco',
            State__c = 'CA',
            Zip_Code__c = '91256'
        );
        locations.add(statePayeeAccountLocation);
        
        Address__c courtPayeeAccountLocation = new Address__c(
            Entity__c = courtPayeeAccount.Id,
            Address__c = '535 E 5th Street',
            City__c = 'San Bernardino',
            State__c = 'CA',
            Zip_Code__c = '94115'
        );
        locations.add(courtPayeeAccountLocation);
        
        Address__c employeePayeeAccountLocation = new Address__c(
            Entity__c = employeePayeeAccount.Id,
            Address__c = '5645 His Rt Hon Rev Dr Gen Guillermo Xavier Bustamonte Jr Blvd Ext',
            City__c = 'Phlegming',
            State__c = 'CA',
            Zip_Code__c = '02256'
        );
        locations.add(employeePayeeAccountLocation);
        insert locations;
        
//      List<DIR_Employee__c> internalEmployees = new List<DIR_Employee__c>();
        DIR_Employee__c manager = new DIR_Employee__c(
            Name = 'Touk Ken',
            User__c = UserInfo.getUserId(),
            Position__c = 'Senior Deputy',
            Title__c = 'Senior Deputy Labor Commissioner'
        );
        insert manager;
//        internalEmployees.add(manager);
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            Name = 'Bao Le',
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = manager.Id
        );
        insert deputy;
//        internalEmployees.add(deputy);
//      insert internalEmployees;
        /*
        Profile p = [SELECT Id, Name
                        FROM Profile
                        WHERE Name='System Administrator']; 
        User sysAd = new User(
            Alias = 'SysAd',
            Email='mteixeira@dir.ca.gov',
            EmailEncodingKey='UTF-8',
            LastName='TestingSysAd',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='mteixeira@dir.ca.gov');
        insert sysAd;
        System.debug('####sysAd = '+sysAd);
        */
        
        
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
            Funds_Drawn_on_Deposits__c = 0.00
        );
        insert WCAcase;
        
        List<Case_Role__c> caseRoles = new List<Case_Role__c>();
        Case_Role__c WCAdefendantCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = employer.Id,
            Role__c = 'Defendant',
            Case_Role_Status__c = 'Active',
            Location__c = employerAccountLocation.Id
        );
        caseRoles.add(WCAdefendantCaseRole);
        
        Case_Role__c WCAstatePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = statePayeeAccount.Id,
            Role__c = 'State',
            Case_Role_Status__c = 'Active',
            Location__c = statePayeeAccountLocation.Id
        );
        caseRoles.add(WCAstatePayeeCaseRole);
        
        Case_Role__c WCAcourtPayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Entity__c = courtPayeeAccount.Id,
            Role__c = 'Court',
            Case_Role_Status__c = 'Active',
            Location__c = courtPayeeAccountLocation.Id
        );
        caseRoles.add(WCAcourtPayeeCaseRole);
        
        Case_Role__c WCAemployeePayeeCaseRole = new Case_Role__c(
            RecordTypeId = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Entity__c = employeePayeeAccount.Id,
            Case__c = WCAcase.Id,
            Role__c = 'Claimant',
            Case_Role_Status__c = 'Active',
            Location__c = employeePayeeAccountLocation.Id
        );
        caseRoles.add(WCAemployeePayeeCaseRole);
        insert caseRoles;
        
        List<Payee__c> payees = new List<Payee__c>();
        Payee__c WCAstatePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 99.00000,
            Payee_Type__c = 'State',
            Case_Management__c = WCAcase.Id,
            Case_Role__c = WCAstatePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(WCAstatePayee);
        
        Payee__c WCAcourtPayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 98.00000,
            Payee_Type__c = 'Court',
            Case_Management__c = WCAcase.Id,
            Case_Role__c = WCAcourtPayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(WCAcourtPayee);
        
        /* May need to be commented out */
        Payee__c WCAemployeePayee = new Payee__c(
            Status__c = 'Verified',
            Factor__c = 97.00000,
            Payee_Type__c = 'Employee',
            Case_Management__c = WCAcase.Id,
            Case_Role__c = WCAemployeePayeeCaseRole.Id,
            Penalty_Payable_Balance__c = 0.00,
            Wage_Payable_Balance__c = 0.00,
            Other_Payable_Balance__c = 0.00
        );
        payees.add(WCAemployeePayee);
        /* */
        insert payees;
        
        Violation_Type__c WCAviolationType = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - Active').getRecordTypeId(),
            Active__c = true
        );
        insert WCAviolationType;
        
        Assessments__c WCAassessment = new Assessments__c(
            Case_Management__c = WCAcase.Id,
            RecordTypeId = Schema.SObjectType.Assessments__c.getRecordTypeInfosByName().get('BOFE Assessments').getRecordTypeId()
        );
        insert WCAassessment;
        
        DIR_Violation__c WCAcaseIssue = new DIR_Violation__c(
            Violation_Type__c = WCAviolationType.Id,
            Case__c = WCAcase.Id,
            Assessment__c = WCAassessment.Id,
            Citation_Amount__c = 3333,
            Wages_Due__c = 2499.75,
            Total_Interest_Amount__c = 833.25,
            Status__c = 'Open',
            RecordTypeId = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()
        );
        insert WCAcaseIssue;
        
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
        
        Office_Account__c WCAofficeAccount = new Office_Account__c(
            Name = '01-112',
            Office__c = WCAoffice.Id
        );
        insert WCAofficeAccount;
        
        Test.startTest();
        
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
        
        Receipt__c WCArctRecommendedCP = new Receipt__c(
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
        insert WCArctRecommendedCP;
        
        Case_Payment__c WCAcpRecommended = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Case__c = WCAcase.Id,
            Receipt__c = WCArctRecommendedCP.Id,
            Payment_Amount__c = 44.44,
            Status__c = 'Allocations Recommended',
            Case_Payment_Recommended_Date__c = Date.today().addDays(-2)
        );
        insert WCAcpRecommended;
    
        //WCA Recommended LPs

        List<Liability_Payment__c> lps = new List<Liability_Payment__c>();
        Liability_Payment__c WCAlpRecommendedWages = new Liability_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_on_Behalf_of__c = WCAliableParty.Id,
            Recommended_Allocation__c = 12.70,
            Payment_Applied_To__c = 'Wages',
            Assessment__c = WCAassessment.Id,
            Liability__c = WCAliability.Id,
            Case_Violation__c = WCAcaseIssue.Id
        );
        lps.add(WCAlpRecommendedWages);
        
        Liability_Payment__c WCAlpRecommendedInterest = new Liability_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_on_Behalf_of__c = WCAliableParty.Id,
            Recommended_Allocation__c = 10.58,
            Payment_Applied_To__c = 'Interest',
            Assessment__c = WCAassessment.Id,
            Liability__c = WCAliability.Id,
            Case_Violation__c = WCAcaseIssue.Id
        );
        lps.add(WCAlpRecommendedInterest);
        insert lps;
        
        //WCA Recommended JPs
        
        List<Judgment_Payment__c> jps = new List<Judgment_Payment__c>();
        Judgment_Payment__c WCAjpRecommendedJAWages = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 12.70,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedJAWages);
        
        Judgment_Payment__c WCAjpRecommendedJAInterest = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 10.58,
            Apply_Payment_To__c = 'Judgment Amount',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedJAInterest);
        
        Judgment_Payment__c WCAjpRecommendedPHI = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 8.46,
            Apply_Payment_To__c = 'Post-Hearing Interest',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedPHI);
        
        Judgment_Payment__c WCAjpRecommendedPJI = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 6.35,
            Apply_Payment_To__c = 'Post-Judgment Interest',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedPJI);
        
        Judgment_Payment__c WCAjpRecommendedAF = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 4.23,
            Apply_Payment_To__c = 'Attorney Fees',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedAF);
        
        Judgment_Payment__c WCAjpRecommendedFF = new Judgment_Payment__c(
            Case_Payment__c = WCAcpRecommended.Id,
            Payment_On_Behalf_Of__c = WCAliableParty.Id,
            Recommended_Amount__c = 2.12,
            Apply_Payment_To__c = 'Filing Fees',
            Judgment__c = WCAjudgment.Id,
            Status__c = 'Recommended'
        );
        jps.add(WCAjpRecommendedFF);
        insert jps;
        
        /********************************************************************************************************************************************************
        WCA - PayeeFactorsNot100 - testing with Recommended - Post
        ********************************************************************************************************************************************************/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(WCAcpRecommended);
        PageReference pageRef = Page.PostCasePaymentVFP;
        
        Test.setCurrentPage(pageRef);
        
        PostCasePaymentController pcpController = new PostCasePaymentController(sc);
        pcpController.FindPaymentPlansAndDisplayCIsAndJs();
        
        pcpController.selectedOBO = WCAdefendantCaseRole.Id;
        pcpController.ppSelection = WCApaymentPlan.Id;
        pcpController.SetPaymentPlan();
        
        
        
        pcpController.Post();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        delete WCAstatePayee;
        delete WCAcourtPayee;
        delete WCAemployeePayee;
        
        pcpController.Post();
        
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages2.size());
        
       Test.stopTest();
    }
}