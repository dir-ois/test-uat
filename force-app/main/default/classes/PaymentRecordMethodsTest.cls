/********************************************************************

Author  :   DIR Salesforce Support Team 
Date    :   May 2019

Usage   :   Tests the various methods on the Payment Record object.

Comment :   As of this date, for other Apex code that messes with the Payment Records,
                see "requestChecks_Controller" and "CreateUWFCheckController" classes

*********************************************************************/

@isTest(SeeAllData=false)
public class PaymentRecordMethodsTest{
    
    @isTest
    public static void testPaymentRecordMethods() {
        Trigger_Settings__c rctTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        insert rctTriggerSetting;
        
        Trigger_Settings__c cpTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        insert cpTriggerSetting; 
        
        Account employerAccount = new Account(
            Name = 'employerAccount'
        );
        insert employerAccount;
        
        Account payorAccount = new Account(
            Name = 'payorAccount'
        );
        insert payorAccount;
        
        Account payeeAccount = new Account(
            Name = 'payeeAccount'
        );
        insert payeeAccount;
        
        Office__c office = new Office__c(
            Name = 'Bakersfield WCA',
            Office_Number__c = 'WCA 1',
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId()
        );
        insert office;
                
        DIR_Employee__c srDep = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert srDep;
        
        DIR_Employee__c deputy = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = srDep.Id
        );
        insert deputy;
        
        DIR_Case__c CM = new DIR_Case__c(
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId(),
            Office__c = office.Id,
            Assigned_Deputy__c = deputy.Id,
            Employer__c = employerAccount.Id,
            Funds_Drawn_on_Deposits__c = 0.00,
            Wage_Payable_Balance1__c = 0.00,
            Wage_Balance_Due__c = 0.00,
            Penalty_Balance_Due__c = 0.00,
            Total_Amount_Paid__c = 0.00,
            Gross_Settlement_Amount__c = 0.00,
            Gross_Penalty_Amount__c = 0.00,
            Deposited_Funds__c = 0.00,
            Number_of_Open_Judgments__c = 0,
            Number_of_RP_Work_Locaton__c = 0,
            Number_of_Claimants__c = 1,
            Number_of_CR_with_PRA_Request__c = 0,
            Garment_Fund_JEU_Referrals_cnt__c = 0,
            Penalty_Payable_Balance1__c = 0.00
        );
        insert CM;
        System.debug('###CM: '+CM);
        
        
        Case_Role__c caseRole = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = CM.Id,
            IsPersonAccount__c = true,
            Role__c = 'Claimant'
        );
        insert caseRole;
        
        Payee__c payee = new Payee__c(
            Case_Management__c = CM.Id,
            Case_Role__c = caseRole.Id
        );
        insert payee;
        
        Receipt__c rctlp = new Receipt__c(
            Payment_Amount__c = 2.22,
            Payment_Type__c = 'Check',
            Bank_Location__c = 'CA Bank',
            Instrument_Number__c = 'doIlooklikeaclowntoyou',
            Payment_Exchange__c = 'Division Payment',
            Date_Received__c = Date.today(),
            Payor__c = payorAccount.Id,
            Status__c = 'New'
        );
        insert rctlp;
        
        Receipt__c rctjp = new Receipt__c(
            Payment_Amount__c = 4.44,
            Payment_Type__c = 'Check',
            Bank_Location__c = 'CA Bank',
            Instrument_Number__c = 'doIamuseyou',
            Payment_Exchange__c = 'Division Payment',
            Date_Received__c = Date.today(),
            Payor__c = payorAccount.Id,
            Status__c = 'New'
        );
        insert rctjp;
        
        Case_Payment__c cplp = new Case_Payment__c(
            Case__c = CM.Id,
            Receipt__c = rctlp.Id,
            Payment_Amount__c = 2.22
        );
        insert cplp;
        
        Case_Payment__c cpjp = new Case_Payment__c(
            Case__c = CM.Id,
            Receipt__c = rctjp.Id,
            Payment_Amount__c = 4.44
        );
        insert cpjp;
        
        Judgement__c judgment = new Judgement__c(
            Case_Management__c = CM.Id,
            Type__c = 'ODA');
        
        insert judgment;
        
        Liability_Payment__c LP = new Liability_Payment__c(
            Case_Payment__c = cplp.Id,
            Payment_Amount__c = 2.22);
        
        insert LP;
        
        Judgment_Payment__c JP = new Judgment_Payment__c(
            Case_Payment__c = cpjp.Id,
            Judgment__c = judgment.Id,
            Allocated_Amount__c = 4.44);
        
        insert JP;
        
        Office_Account__c OA = new Office_Account__c(
            Name = '01-112',
            Account__c = 'test',
            Office__c = office.Id);
        
        insert OA;
        
        Check_Batch__c LPCB = new Check_Batch__c(
            Status__c = 'Review Complete');
        
        insert LPCB;
        
        Check_Batch__c JPCB = new Check_Batch__c(
            Status__c = 'Printed');
        
        insert JPCB;
        
        Check__c LPcheck = new Check__c(
            Check_Batch__c = LPCB.Id,
            Check_Number__c = '777',
            Amount__c = 2.22,
            Case__c = CM.Id,
            Payee__c = payee.Id,
            Status__c = 'Approved',
            Office_Account__c = OA.Id);
        
        insert LPcheck;
        
        Check__c JPcheck = new Check__c(
            Check_Batch__c = JPCB.Id,
            Check_Number__c = '888',
            Amount__c = 4.44,
            Case__c = CM.Id,
            Payee__c = payee.Id,
            Status__c = 'Printed',
            Office_Account__c = OA.Id);
        
        insert JPcheck;
        
        Payment_Record__c PRLP = new Payment_Record__c(
            Payee__c = payee.Id,
            Liability_Payment__c = LP.Id,
            Payment_Amount__c = 2.22,
            Check_Issued__c = TRUE,
            Check__c = LPcheck.Id);
        
        insert PRLP;
        
        Payment_Record__c PRJP = new Payment_Record__c(
            Payee__c = payee.Id,
            Judgment_Payment__c = JP.Id,
            Payment_Amount__c = 4.44,
            Check_Issued__c = TRUE,
            Check__c = JPcheck.Id);
        
        insert PRJP;
        
        test.startTest();
        
        CM = [SELECT Id, Name, RecordTypeId, Employer__c, Employer__r.Id, Assigned_Deputy__r.Manager__r.Id, Wage_Payable_Balance1__c, Wage_Balance_Due__c,
                                    Total_Interest_Balance_Due__c, Penalty_Balance_Due__c, Cash_Balance_on_Case__c, Total_Penalties_Balance_Due__c,
                                    Total_Wages_Balance_Due__c, Total_Wage_Penalties__c, Total_Amount_Paid__c, Total_Amount_Claimed__c, Gross_Settlement_Amount__c,
                                    Gross_Penalty_Amount__c, Insufficient_funds_count__c, Total_Penalties_Assessed__c, Funds_Drawn_on_Deposits__c,
                                    Deposited_Funds__c, Number_of_Open_Judgments__c, Number_of_RP_Work_Locaton__c, Number_of_Claimants__c, Number_of_Successors__c,
                                    Number_of_Successors1__c, Number_of_CR_with_PRA_Request__c, Garment_Fund_JEU_Referrals_cnt__c, Penalty_Payable_Balance1__c,
                                    ODA_Decision_Date__c, Latest_Settlement_Date__c, First_Hearing_Start_Date_Time__c, First_Conference_Start_Date_Time__c
                                FROM DIR_Case__c
                                WHERE Id = :CM.Id];

        System.debug('###CM: '+CM);
        
        system.assertEquals(PRLP.Payment_Amount__c + PRJP.Payment_Amount__c, CM.Funds_Drawn_on_Deposits__c, 'PR roll up to Case.Funds_Drawn_on_Deposits__c not equal');
        
        delete PRLP;
        delete PRJP;
        
        test.stopTest();
    }
}