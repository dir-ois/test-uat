@isTest
public class TransmittalAndCaseIssueBatchTest{
    
    @testSetup static void setup(){
        Id bofeRT = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        
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
        
        // Implement test code
        Account a = new Account(
            Name = 'test Account'+system.now()
        );
        insert a;
        
        DIR_Employee__c ma = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = ma.Id
        );
        insert de; 
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = de.Id,
            Employer__c = a.Id
        );
        insert cm; 
        
        Violation_Type__c vt = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Appeal_Deadline_Days__c = 12,
            Active__c = true,
            Appeal_Deadline_Selector__c = 'Business Days'  
        );
        insert vt;
        
        /*
        Assessments__c assess = new Assessments__c(
            Case_Management__c = cm.Id
        );
        insert assess;
        */
        
        /*
        Hearing__c mtg = new Hearing__c(
            Case__c = cm.Id,
            Status__c = 'New',
            Meeting_Start_Date_Time__c = date.today(),
            Meeting_End_Date_Time__c = date.today() + 10,
            Effective_Date__c = date.today() + 10,
            Imported_From__c = 'test',
            RecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('BOFE Hearing').getRecordTypeId()
        );
        insert mtg;
        */
        
        List<DIR_Violation__c> viols = new List<DIR_Violation__c>();
        
        DIR_Violation__c vio = new DIR_Violation__c(
            Violation_Type__c = vt.Id,
            Case__c = cm.Id,
            Citation_Amount__c = 2000,
            RecordTypeId = bofeRT,
            //Decided_at_Meeting__c = mtg.Id,
            Wages_Due_Date__c = date.today()
        );
        viols.add(vio);
        
        /*
        DIR_Violation__c vio2 = new DIR_Violation__c(
            Violation_Type__c = vt.Id,
            Case__c = cm.Id,
            Citation_Amount__c = 2000,
            RecordTypeId = bofeRT,
            //Decided_at_Meeting__c = mtg.Id,
            Wages_Due_Date__c = date.today()
        );
        viols.add(vio2);
        */
     
        insert viols;
        System.debug('inserted case violation');
        
        Accounting_Code__c ac = new Accounting_Code__c(
            Account__c = '000102',
            Fund__c = '0001',
            Program__c = 'BOFE',
            Payment_Type__c = 'Penalty',
            Industry__c = 'Car Wash',
            Active__c = true
        );
        insert ac; 
        
        Applicable_Accounting_Code__c acac1 = new Applicable_Accounting_Code__c(
            Accounting_Code__c = ac.Id,
            Violation_Type__c = vt.Id,
            Split_Percentage__c = 100,
            Active__c = true
        );
        insert acac1; 
        
        Violation_Accounting_Code__c vac = new Violation_Accounting_Code__c(
            Applicable_Accounting_Code__c = acac1.Id,
            Case_Violation__c = vio.id
        );
        insert vac;
        //vac.recalculateFormulas();
        
        System.debug('VAC Payment Type: ' + vac.Payment_Type__c);
        
        /*
        //Payment for the transmitttal
        Transmittal__c transmittal = new Transmittal__c(
            RecordTypeId = Schema.SObjectType.Transmittal__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId()
          
        );
        
        insert transmittal;
        //test.setCreatedDate(transmittal.id, System.now());
        
        transmittal = [select id, name, createdDate from Transmittal__c where id =: transmittal.id];
        
        System.debug('transmittal name: ' + transmittal.Id + ' '+ transmittal.name + ' ' + transmittal.createdDate);
        */
        Office__c office = new Office__c(
            RecordTypeId = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId(),
            Name = 'Sacramento CCU'
        );
        insert office;
        
        Office_Account__c oa = new Office_Account__c(
            Name = '32-117',
            Office__c = office.Id
        );
        insert oa;
        
        Transaction__c trn = new Transaction__c(
            Office_Account__c = oa.Id,
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 1000,
            Deposit_Date__c = Date.today(),
            ///Business_Unit__c = 'CCU',
            Check_Count__c = 1,
            Checks_Amount__c = 1000,
            Treasury_Deposit_Number__c = 'shoobedoobedoo'
        );
        insert trn;
        
        Receipt__c rct = new Receipt__c(
            Transaction__c = trn.Id,
            Payment_Amount__c = 1000,
            Payment_Type__c = 'Check',
            Bank_Location__c = 'CA Bank',
            Instrument_Number__c = 'whoyoulookinat',
            Payment_Exchange__c = 'Division Payment',
            Date_Received__c = Date.today(),
            Payor__c = a.Id,
            Status__c = 'Deposited'
        );
        insert rct;
        
        
        Case_Payment__c cp = new Case_Payment__c(
            //Need to be 'BOFE'
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('Posted').getRecordTypeId(),
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 1000,
            Status__c = 'Posted',
            Transmittal__c = null
            //Transmittal_Unit__c = 'CCU'
        );
        insert cp;
        
        cp = [select Transmittal_Unit__c, RecordTypeId, Transmittal__c from Case_Payment__c where id =: cp.id ];
        System.debug('case payment test: ' + cp.Transmittal_Unit__c + ' ' + cp.Transmittal__c + ' ' + cp.RecordTypeId);
        
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        
        Liability_Payment__c lp = new Liability_Payment__c(
            Case_Violation__c = vio.Id,
            Case_Payment__c = cp.Id,
            Payment_Amount__c = 12,
            Payment_Applied_To__c = 'Penalties',
            Recommended_Allocation__c = 12
        );
        lpList.add(lp);
        
        insert lpList;
        
        
        Applied_Accounting_Code__c aeac = new Applied_Accounting_Code__c(
            Liability_Payment__c =lp.Id, 
            Amount__c  = 550.00, 
            Accounting_Code__c = ac.Id, 
            Added_Manually__c = false);
        insert aeac; 
    }


    @isTest static void testTransmittalBatchController() {
        Date today = Date.today();
    
        Receipt__c receipt = [SELECT Office_Unit__c, Date_Received__c
                                FROM Receipt__c
                                WHERE Date_Received__c =: today
                                LIMIT 1];
        
        Case_Payment__c casepayment = [SELECT Transmittal_Unit__c, RecordTypeId, Transmittal__c, Date_Payment_Received__c
                                        FROM Case_Payment__c
                                        WHERE Date_Payment_Received__c =: today
                                        LIMIT 1];
        
        System.debug('static case payment: ' + casepayment);
        receipt.Office_Unit__c = 'CCU 32';
        update receipt;
        
        test.startTest();
        //generate the batch for CCU case payments
        TransmittalBatchController controller = new TransmittalBatchController();
        update casepayment;
        controller.runTransmittalBatch();

        //generate AR0whatever
        TransmittalInterface transmittalInterface = new TransmittalInterface();
        transmittalInterface.sendAR();
        test.stopTest();

        Case_Payment__c updatedCP = [SELECT Transmittal_Unit__c, RecordTypeId, Transmittal__c, Date_Payment_Received__c
                                        FROM Case_Payment__c
                                        WHERE Date_Payment_Received__c =: today
                                        LIMIT 1];
        
        System.debug('static case payment: ' + updatedCP);

        System.assertNotEquals(updatedCP.Transmittal_Unit__c, NULL);

    }
    
    @isTest static void testCaseIssueBatch() {
      // Implement test code
        test.startTest();
        Id tb = Database.executeBatch(new CaseIssueBatch(), 100);
        test.stopTest();
    }
    
    @isTest static void testScheduleCaseIssueReclass() {
        test.startTest();
        //Schedule the test Job
        String jobId = System.schedule('testCaseIssureReclass', ScheduleCaseIssueReclass.CRON_SCHEDULE, new ScheduleCaseIssueReclass());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        //verify the expression are the same
        System.assertEquals(ScheduleCaseIssueReclass.CRON_SCHEDULE, ct.CronExpression);
        
        //verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        test.stopTest();
    }
}