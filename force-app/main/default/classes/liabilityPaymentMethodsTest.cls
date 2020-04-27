@IsTest
public class liabilityPaymentMethodsTest{
    static List<DIR_Violation__c> viols = new List<DIR_Violation__c>();
    static Id bofeRT = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();
    static Id violationTypeRT = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
    static Id cpRT = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
    static Id payeeAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    static Id payeeCaseRoleRT = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
    //static Key_Value_Store__c vtcwKVS = Key_Value_Store__c.getInstance('Violation Type Car Wash');

    static testMethod void testMethod1(){
        
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

        
        Account a = new Account(
            Name = 'Test Account',
            Low_wage_Industry_Selection__c = 'Car Wash'
        );
        insert a;
        
        Account payeeAccount = new Account(
            FirstName = 'Payee',
            LastName = 'Account',
            RecordTypeId = payeeAccountRT,
            Owner = [SELECT Id, Name 
                        FROM User
                        WHERE Name = 'Integration User'][0]
        );
        insert payeeAccount;
         
        DIR_Employee__c employeeMgr = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert employeeMgr;
        
        DIR_Employee__c employee = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Manager__c = employeeMgr.Id
        );
        insert employee;

        DIR_Case__c cm= new DIR_Case__c(
            Employer__c = a.Id,
            Assigned_Deputy__c = employee.Id, 
            RecordTypeId = bofeRT,
            Status__c = 'Judgment Issued',
            Case_Closed_Date__c = date.today(),
            Purge_Date__c = date.today() + 1,
            Case_Number__c = '123'
        );
        insert cm;
        cm.recalculateFormulas();
        
        Case_Role__c payeeCaseRole = new Case_Role__c(
            Entity__c = payeeAccount.Id,
            Case__c = cm.Id,
            Role__c = 'Payee - Employee',
            Case_Role_Status__c = 'Active',
            RecordTypeId = payeeCaseRoleRT,
            IsPersonAccount__c = true
        );
        insert payeeCaseRole;
        
        Payee__c payee = new Payee__c(
            Case_Role__c = payeeCaseRole.Id,
            Case_Management__c = cm.Id,
            Payee_Type__c = 'Employee',
            Factor__c = 100.00,
            Status__c = 'Verified'
        );
        insert payee;
        
        Violation_Type__c vt = new Violation_Type__c(
            RecordTypeId = violationTypeRT,
            Appeal_Deadline_Days__c = 15,
            Active__c = true,
            Accounting_Payment_Type__c = 'Penalty', 
            Appeal_Deadline_Selector__c = 'Business Days'
        );
        insert vt;

        Key_Value_Store__c vtcwKVS = new Key_Value_Store__c(
            Name = 'Violation Type Car Wash',
            Value__c = vt.Id
        );
        insert vtcwKVS;

        Assessments__c assess = new Assessments__c(
            Case_Management__c = cm.Id
        );
        insert assess;
        
        Liability__c liab = new Liability__c(
            Assessment__c = assess.Id,
            Case_Management__c = cm.Id,
            Imported_From__c = 'FM-TIPP'
        );
        insert liab;
        
        Liable_Party__c liabParty = new Liable_Party__c(
            Liability__c = liab.Id,
            Entity__c = a.Id
        );
        insert liabParty;
        
        Accounting_Code__c ac = new Accounting_Code__c(
            Fund__c = '123.23',
            Program__c = 'BOFE',
            Payment_Type__c = 'Penalty',
            Industry__c = 'Car Wash',
            Active__c = true
        );
        insert ac; 
        
        Applicable_Accounting_Code__c aac1 = new Applicable_Accounting_Code__c(
            Accounting_Code__c = ac.Id,
            Violation_Type__c = vt.Id,
            Split_Percentage__c = 50,
            Active__c = true
        );
        
        insert aac1; 
        aac1.recalculateFormulas();
        
        // get accounting codes that apply the the violation type of each violation
        Applicable_Accounting_Code__c applicableAccountingCode =
            [SELECT Id, Accounting_Code__c,Accounting_Code__r.Payment_Type__c, Violation_Type__c, Active__c, Payment_Type__c, Program__c, Industry__c
                FROM Applicable_Accounting_Code__c 
                WHERE Accounting_Code__c =:ac.Id LIMIT 1];

        System.assertEquals('Penalty', applicableAccountingCode.Payment_Type__c);
        
        Test.startTest();
        List<DIR_Violation__c> vioList = new List<DIR_Violation__c>();
        
        DIR_Violation__c vio1 = new DIR_Violation__c(
            Violation_Type__c = vt.Id,
            Case__c = cm.Id,
            Assessment__c = assess.Id,
            Citation_Amount__c = 12,
            Penalty_Payments_Received__c = 12
        );
        vioList.add(vio1);
        
        DIR_Violation__c vio2 = new DIR_Violation__c(
            Violation_Type__c = vt.Id,
            Case__c = cm.Id,
            Assessment__c = assess.Id,
            Citation_Amount__c = 12,
            Penalty_Payments_Received__c = 12
        );
        vioList.add(vio2);
        
        DIR_Violation__c vio3 = new DIR_Violation__c(
            Violation_Type__c = vt.Id,
            Case__c = cm.Id,
            Assessment__c = assess.Id,
            Citation_Amount__c = 12,
            Penalty_Payments_Received__c = 12
        );
        vioList.add(vio3);
        
        insert vioList;

        viols = vioList;

        Payment_Plan__c pp = new Payment_Plan__c(
            Case__c = cm.Id,
            Responsible_Party__c = a.Id,
            Payment_Plan_Total_Amount_Due__c = 1000.00
        );
        insert pp;
        
        Receipt__c rct = new Receipt__c(
            Date_Received__c = Date.today(),
            Payor__c = a.Id,
            Payment_Amount__c = 69.03,
            Instrument_Number__c = 'zxc',
            Payment_Type__c = 'Check',
            Hold_Date__c = date.today(),
            Bank_Location__c = 'CA Bank',
            Payment_Can_Be_Processed__c = true,
            Deposit_Account__c = '32-117',
            Payment_Exchange__c = 'Division Payment',
            Office_Unit__c = 'CCU 32'
        );
        insert rct;
        
        Case_Payment__c cp1 = new Case_Payment__c(
            Receipt__c = rct.Id,
            Payment_Plan__c = pp.Id,
            Payment_Amount__c = 69.03,
            Case__c = cm.Id,
            RecordTypeId = cpRT,
            Status__c = 'New'
        );
        insert cp1;
        
        Judgement__c jgmt = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA'
        );
        insert jgmt;
        
        List<Liability_Payment__c> liabPmtList = new List<Liability_Payment__c>();
        
        Liability_Payment__c liabPmt1 = new Liability_Payment__c(
            Case_Violation__c = vio1.Id,
            Case_Payment__c = cp1.Id,
            Payment_Amount__c = 22.01,
            Payment_Applied_To__c = 'Wages',
            Recommended_Allocation__c = 22.01,
            Payment_on_Behalf_of__c = liabParty.Id
        );
        liabPmtList.add(liabPmt1);
        
        Liability_Payment__c liabPmt2 = new Liability_Payment__c(
            Case_Violation__c = vio2.Id,
            Case_Payment__c = cp1.Id,
            Payment_Amount__c = 23.01,
            Payment_Applied_To__c = 'Penalties',
            Recommended_Allocation__c = 23.01,
            Payment_on_Behalf_of__c = liabParty.Id
        );
        liabPmtList.add(liabPmt2);
        
        Liability_Payment__c liabPmt3 = new Liability_Payment__c(
            Case_Violation__c = vio3.Id,
            Case_Payment__c = cp1.Id,
            Payment_Amount__c = 24.01,
            Payment_Applied_To__c = 'Interest',
            Recommended_Allocation__c = 24.01,
            Payment_on_Behalf_of__c = liabParty.Id
        );
        liabPmtList.add(liabPmt3);
        
        System.debug('liabPmtList = '+liabPmtList);
        
        insert liabPmtList;

        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();

        Judgment_Payment__c jgmtPmt1 = new Judgment_Payment__c(
            Apply_Payment_To__c = 'Judgment Amount',
            Allocated_Amount__c = 22.01,
            Judgment__c = jgmt.Id,
            Case_Payment__c = cp1.Id,
            Payment_on_Behalf_of__c = liabParty.Id,
            Funds_Redundant_With__c = liabPmt1.Id
        );
        jpList.add(jgmtPmt1);
        
        Judgment_Payment__c jgmtPmt2 = new Judgment_Payment__c(
            Apply_Payment_To__c = 'Judgment Amount',
            Allocated_Amount__c = 23.01,
            Judgment__c = jgmt.Id,
            Case_Payment__c = cp1.Id,
            Payment_on_Behalf_of__c = liabParty.Id,
            Funds_Redundant_With__c = liabPmt2.Id
        );
        jpList.add(jgmtPmt2);
        
        Judgment_Payment__c jgmtPmt3 = new Judgment_Payment__c(
            Apply_Payment_To__c = 'Judgment Amount',
            Allocated_Amount__c = 24.01,
            Judgment__c = jgmt.Id,
            Case_Payment__c = cp1.Id,
            Payment_on_Behalf_of__c = liabParty.Id,
            Funds_Redundant_With__c = liabPmt3.Id
        );
        jpList.add(jgmtPmt3);
        
        insert jpList;
        
        Liability_Judgement__c lj = new Liability_Judgement__c(
            Judgement__c = jgmt.Id,
            Liable_Party__c = liabParty.Id
        );
        insert lj;
        
 
         Applied_Accounting_Code__c AppliedAccountingCode = new Applied_Accounting_Code__c(
            Liability_Payment__c = liabPmtList[1].Id, 
            Amount__c  = 555.55, 
            Accounting_Code__c = ac.Id, 
            Added_Manually__c = false
        );
        insert AppliedAccountingCode; 
           
        Set<Id> ids = (new Map<Id,Liability_Payment__c >(liabPmtList)).keySet().clone();
                  
        liabilityPaymentMethods testAccPlan = new liabilityPaymentMethods();
        testAccPlan.CreateAppliedAccountingCode(ids); 
        testAccPlan.CaseIssueRollups(ids);
        
        //test liabilityPaymentTrigger:if(trigger.isUpdate)
        liabPmt1.Payment_Amount__c = 22.02;
        update liabPmt1;
        
        Liability_Payment__c updateLP = [SELECT Id, Name, Payment_Amount__c
                                            FROM Liability_Payment__c
                                            WHERE Id =: liabPmt1.Id];
        
        System.assertEquals(updateLP.Payment_Amount__c, 22.02);

        Test.stopTest();
    }
}