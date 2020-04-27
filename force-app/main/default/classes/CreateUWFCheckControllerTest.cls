@isTest(SeeAllData=false)
public class CreateUWFCheckControllerTest {
    
    @isTest static void testCreateUWFCheckController(){
        
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
        

        PageReference createUWFCheck = Page.CreateUWFCheck;
        
        Test.setCurrentPage(createUWFCheck);
        
        Trigger_Settings__c triggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        insert triggerSetting;
        
        Account employerAccount = new Account(
            Name = 'Test Account'
        );
        insert employerAccount;
        
        Office__c office = new Office__c(
            Name = 'test office'
        );
        insert office;
        
        Office_Account__c officeAccount = new Office_Account__c(
            Name = 'test office account',
            Office__c = office.id
        );
        insert officeAccount;
        
        DIR_Employee__c employeeMgr = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert employeeMgr;
        
        DIR_Employee__c employee = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Manager__c = employeeMgr.Id
        );
        insert employee;
        
        DIR_Case__c caseMgmt = new DIR_Case__c(
            Employer__c = employerAccount.Id,
            Assigned_Deputy__c = employee.Id
        );
        insert caseMgmt;
        
        Case_Role__c caseRole = new Case_Role__c(
            Case_Role_Status__c = 'Active',
            Case__c = caseMgmt.Id,
            IsPersonAccount__c = false,
            Entity__c = employerAccount.Id
        );
        insert caseRole;
        
        Payee__c payee = new Payee__c(
            Case_Management__c = caseMgmt.Id,
            Case_Role__c = caseRole.Id,
            Factor__c = 100,
            Payee_Type__c = 'Employee',
            Status__c = 'Unverified'
        );
        insert payee;
        test.startTest();
        
        CreateUWFCheckController controller = new CreateUWFCheckController();
        
         
        system.assert(ApexPages.getMessages().size() > 0); //no KVS
        
        ApexPages.getMessages().clear();
        
        Key_Value_Store__c payeeKVS = new Key_Value_Store__c(
            Name = 'UWF Payee',
            Value__c = payee.Id
        );
        insert payeeKVS;
        
        controller = new CreateUWFCheckController();
        
        system.assert(ApexPages.getMessages().size() > 0); //no Payment_Record__c records
        
        ApexPages.getMessages().clear();
        
        Transaction__c trn = new Transaction__c(
            Office_Account__c = officeAccount.Id,
            Deposit_Date__c = Date.today().addMonths(-7),
            Business_Unit__c = 'CCU',
            Transaction_Type__c = 'Deposit',
            Transaction_Status__c = 'Deposited',
            Transaction_Sum__c = 100,
            Check_Count__c = 1,
            Checks_Amount__c = 100,
            Treasury_Deposit_Number__c = 'franksinatra'
        );
        insert trn;
        
        
        Receipt__c rct = new Receipt__c(
            Payment_Amount__c = 100,
            Instrument_Number__c = 'sonnyandcher',
            Date_Received__c = Date.today().addMonths(-7),
            Transaction__c = trn.Id,
            Payment_Type__c = 'Check',
            Payment_Exchange__c = 'Division Payment',
            Bank_Location__c = 'CA Bank',
            Payor__c = employerAccount.Id
        );
        insert rct;
        
        Case_Payment__c cp = new Case_Payment__c(
            Case__c = caseMgmt.Id,
            Receipt__c = rct.Id,
            Payment_Amount__c = 100
        );
        insert cp;
        
        Liability_Payment__c lp = new Liability_Payment__c(
            Case_Payment__c = cp.Id
        );
        insert lp;
        
        Payment_Record__c pr = new Payment_Record__c(
            Payee__c = payee.Id,
            Payment_Amount__c = 100,
            Liability_Payment__c = lp.Id
        );
        insert pr;
        
        
        controller = new CreateUWFCheckController();
        
        system.assertEquals(1, controller.paymentRecords.size());
        
        system.assertEquals(pr.Id, controller.paymentRecords[0].Id);
        
        system.assertNotEquals(controller.intUser.Id, null);
        
        controller.createCheckBatchRecords();
        
        system.assert(ApexPages.getMessages().size() > 0);
        
        controller.shellObject.Office_Account__c = officeAccount.Id;
        
        controller.updateList();
        
        controller.createCheckBatchRecords();
        
        Check_Batch__c newCheckBatch = [
            SELECT Id, Requested_By__c, Office_Account__c 
            FROM Check_Batch__c 
            LIMIT 1
        ];
        
        system.assertNotEquals(newCheckBatch.Requested_By__c, null);
                
        system.assertEquals(controller.shellObject.Office_Account__c, newCheckBatch.Office_Account__c);
        
        Check__c newCheck = [
            SELECT Id, Name, Payee__c, Check_Batch__c, Office_Account__c, Amount__c
            FROM Check__c
            WHERE Check_Batch__c =: newCheckBatch.Id
            LIMIT 1
        ];
        
        system.assertEquals(payeeKVS.Value__c, newCheck.Payee__c);
                
        system.assertEquals(controller.shellObject.Office_Account__c, newCheck.Office_Account__c);
        
        system.assertEquals(pr.Payment_Amount__c, newCheck.Amount__c);
        
        pr = [
            SELECT Id, Check__c
            FROM Payment_Record__c
            WHERE Id =: pr.Id
        ];
        
        system.assertEquals(newCheck.Id, pr.Check__c);
        
        controller.returnHome();
        test.stopTest();
    }
}