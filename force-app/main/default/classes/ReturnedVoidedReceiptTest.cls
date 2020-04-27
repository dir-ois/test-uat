/*************************************************************************************************
Class     :  ReturnedVoidedReceiptTest.cls
Created   :  June 11, 2019
Modified  :  
Objective :  Obvious test class is obvious.

*************************************************************************************************/

@isTest
public class ReturnedVoidedReceiptTest {/*

    @isTest(SeeAllData=true)
    public static void testReturnedReceipt(){
        User AdminUser = [SELECT Id
                            FROM User
                            WHERE Profile.Name LIKE '%System Administrator%'
                            AND IsActive = true
                            LIMIT 1];
                            
        System.debug('### AdminUser = '+AdminUser);
        System.runAs(AdminUser){
            
            Liability_Payment__c testLP =
                    [SELECT Id, Name, Recommended_Allocation__c, Payment_Amount__c, Case_Payment__c,
                            Case_Payment__r.Receipt__c, Case_Payment__r.Receipt__r.Id, Case_Payment__r.Receipt__r.Name,
                            Case_Payment__r.Receipt__r.Transaction__c, Case_Payment__r.Receipt__r.Transaction__r.Other_Amount__c,
                            Case_Payment__r.Receipt__r.Returned_Item__c
                        FROM Liability_Payment__c
                        WHERE (Payment_Amount__c > 0
                                OR Recommended_Allocation__c > 0)
                            AND Case_Payment__c != NULL
                            AND Case_Payment__r.Receipt__c != NULL
                            AND Case_Payment__r.Receipt__r.Returned_Item__c = FALSE
                            AND (NOT Case_Payment__r.Receipt__r.Name LIKE '%RCT-000000%')
                        LIMIT 1];
            
            System.debug('###testLP= '+ testLP);
            System.debug('###testLP.Case_Payment__c = '+testLP.Case_Payment__c);
            System.debug('###testLP.Case_Payment__r.Receipt__r.Id = '+testLP.Case_Payment__r.Receipt__r.Id);
            
            Receipt__c testLPRCT = testLP.Case_Payment__r.Receipt__r;
            
            System.debug('###testLPRCT= '+testLPRCT);
            
            Test.startTest();
            
            testLPRCT.Status__c = 'Deposited';
            testLPRCT.Returned_Item__c = true;
            testLPRCT.Returned_Reason__c = 'NSF';
            update testLPRCT;
            
            Liability_Payment__c negatingTestLP =
                    [SELECT Id, Name, Payment_Amount__c, Recommended_Allocation__c, Returned_Voided_Liability_Payment__c,
                            Case_Payment__c, Case_Payment__r.Receipt__c, Case_Payment__r.Receipt__r.Transaction__c,
                            Case_Payment__r.Receipt__r.Returned_Item__c
                        FROM Liability_Payment__c
                        WHERE Returned_Voided_Liability_Payment__c = :testLP.Id
                        LIMIT 1];
            
            System.assertEquals(negatingTestLP.Payment_Amount__c + negatingTestLP.Recommended_Allocation__c, -testLP.Payment_Amount__c - testLP.Recommended_Allocation__c);
            
            Test.stopTest();
        }
    }
    
    @isTest(SeeAllData=true)
    public static void testVoidedReceipt(){
        User AdminUser = [SELECT Id
                            FROM User
                            WHERE Profile.Name LIKE '%System Administrator%'
                            AND IsActive = true
                            LIMIT 1];
                            
        System.debug('### AdminUser = '+AdminUser);
        System.runAs(AdminUser){
            Judgment_Payment__c testJP =
                    [SELECT Id, Name, Allocated_Amount__c, Recommended_Amount__c, Voided_Item__c, Case_Payment__c,
                            Case_Payment__r.Receipt__c, Case_Payment__r.Receipt__r.Id, Case_Payment__r.Receipt__r.Name,
                            Case_Payment__r.Receipt__r.Transaction__c, Case_Payment__r.Receipt__r.Transaction__r.Other_Amount__c,
                            Case_Payment__r.Receipt__r.Returned_Item__c, Case_Payment__r.Receipt__r.Voided_Item__c
                        FROM Judgment_Payment__c
                        WHERE (Allocated_Amount__c > 0
                                OR Recommended_Amount__c > 0)
                            AND Case_Payment__c != NULL
                            AND Case_Payment__r.Receipt__c != NULL
                            AND Case_Payment__r.Receipt__r.Returned_Item__c = FALSE
                            AND (NOT Case_Payment__r.Receipt__r.Name LIKE '%RCT-000000%')
                        LIMIT 1];

            System.debug('###testJP= '+testJP);
            System.debug('###testJP.Case_Payment__c = '+testJP.Case_Payment__c);
            System.debug('###testJP.Case_Payment__r.Receipt__r.Id = '+testJP.Case_Payment__r.Receipt__r.Id);
            
            Receipt__c testJPRCT = testJP.Case_Payment__r.Receipt__r;
            System.debug('###testJPRCT ='+testJPRCT);
            
            Test.startTest();
            testJPRCT.Voided_Item__c = true;
            update testJPRCT;
            
            Judgment_Payment__c updatedTestJP =
                    [SELECT Id, Name, Allocated_Amount__c, Recommended_Amount__c, Voided_Item__c, Case_Payment__c,
                            Case_Payment__r.Receipt__c, Case_Payment__r.Receipt__r.Id, Case_Payment__r.Receipt__r.Name,
                            Case_Payment__r.Receipt__r.Transaction__c, Case_Payment__r.Receipt__r.Transaction__r.Other_Amount__c,
                            Case_Payment__r.Receipt__r.Returned_Item__c, Case_Payment__r.Receipt__r.Voided_Item__c
                        FROM Judgment_Payment__c
                        WHERE Id = :testJP.Id
                        LIMIT 1];
            
            System.assertEquals(updatedTestJP.Voided_Item__c, TRUE);
            
            Test.stopTest();
        }
    }*/
    
    @isTest
    public static void testReturnedReceipt(){
        User ADMIN_USER = [SELECT Id
                            FROM User
                            WHERE Profile.Name = 'System Administrator'
                            AND IsActive = true LIMIT 1 ];
        
        List<Trigger_Settings__c> triggerSettingsList = new List<Trigger_Settings__c>();
        Trigger_Settings__c CPTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettingsList.add(CPTriggerSetting);
        
        Trigger_Settings__c RCTTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettingsList.add(RCTTriggerSetting);
        
        insert triggerSettingsList;
        
        Receipt__c rct = new Receipt__c(
            Payment_Type__c = 'Check',
            Instrument_Number__c = 'asf',
            Date_Received__c = Date.today(),
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 12,
            Payment_Can_Be_Processed__c = true,
            Office_Unit__c = 'CCU 32',
            Status__c = 'Deposited',
            Payment_Exchange__c = 'Division Payment'
        );
        insert rct;
        
        Account employer = new Account(
            Name = 'Employer',
            ShippingPostalCode = '92345',
            Bankruptcy_Status_Date__c = Date.today()
        );
        insert employer;
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id
        );
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id,
            Manager__c = mgr.Id
        );
        insert de;

        DIR_Case__c cm = new DIR_Case__c(
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Employer__c = employer.Id,
            Assigned_Deputy__c = de.Id
        );
        insert cm;
        
        Case_Payment__c cp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Payment_Amount__c = rct.Payment_Amount__c,
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Status__c = 'Posted'
        );
        insert cp;

        Liability_Payment__c lp = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_Amount__c = cp.Payment_Amount__c * 0.75
        );
        insert lp;
        
        Judgement__c jmt = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
        );
        insert jmt;
        
        Judgment_Payment__c jp = new Judgment_Payment__c(
            Case_Payment__c = cp.Id,
            Allocated_Amount__c = cp.Payment_Amount__c * 0.25,
            Judgment__c = jmt.Id
        );
        insert jp;
        
        /* for Tier 2:
        Account payeeAccount1 = new Account(
            Name = 'payee1',
            ShippingPostalCode = '90001'
        );
        insert payeeAccount1;

        Account payeeAccount2 = new Account(
            Name = 'payee2',
            ShippingPostalCode = '90002'
        );
        insert payeeAccount2;
        
        Case_Role__c caseRole1 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount1.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole1;
        
        Case_Role__c caseRole2 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount2.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole2;
        
        Payee__c payee1 = new Payee__c(
            Factor__c = 75,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole1.Id
        );
        insert payee1;
        
        Payee__c payee2 = new Payee__c(
            Factor__c = 25,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole2.Id
        );
        insert payee2;
        
        Payment_Record__c prlp = new Payment_Record__c(
            Liability_Payment__c = lp.Id,
            Payment_Amount__c = lp.Payment_Amount__c,
            Payee__c = payee1.Id
        );
        insert prlp;
        
        Payment_Record__c prjp = new Payment_Record__c(
            Judgment_Payment__c = jp.Id,
            Payment_Amount__c = jp.Allocated_Amount__c,
            Payee__c = payee2.Id
        );
        insert prjp;
        */
        
        Test.startTest();
        rct.Returned_Item__c = true;
        rct.Returned_Reason__c = 'NSF';
        update rct;
        
        List<Id> rctIdList = new List<Id>();
        rctIdList.add(rct.Id);
        
        ReturnedVoidedReceipt.returnReceipts(rctIdList);
        Test.stopTest();
        
        Receipt__c testRCT = [SELECT Id, Name, Returned_Item__c
                                FROM Receipt__c
                                WHERE Id = :rct.Id];
        System.debug('testRCT = '+testRCT);
        
        Liability_Payment__c testNegatedLP = [SELECT Id, Name, Payment_Amount__c
                                                FROM Liability_Payment__c
                                                WHERE Returned_Voided_Liability_Payment__c = :lp.Id][0];
        
        System.assertEquals(testNegatedLP.Payment_Amount__c, -lp.Payment_Amount__c);
        
        Judgment_Payment__c testNegatedJP = [SELECT Id, Name, Allocated_Amount__c
                                                FROM Judgment_Payment__c
                                                WHERE Returned_Voided_Judgment_Payment__c = :jp.Id][0];
        
        System.assertEquals(testNegatedJP.Allocated_Amount__c, -jp.Allocated_Amount__c);
        
        /* for Tier 2:
        Payment_Record__c negatedPrLp = [SELECT Id, Name, Payment_Amount__c, Returned_Voided_Payment_Record__c
                                            FROM Payment_Record__c
                                            WHERE Returned_Voided_Payment_Record__c = :prlp.Id][0];
                                            
        system.assertEquals(negatedPrLp.Payment_Amount__c, -prlp.Payment_Amount__c);
        
        Payment_Record__c negatedPrJp = [SELECT Id, Name, Payment_Amount__c, Returned_Voided_Payment_Record__c
                                            FROM Payment_Record__c
                                            WHERE Returned_Voided_Payment_Record__c = :prjp.Id][0];
                                            
        system.assertEquals(negatedPrJp.Payment_Amount__c, -prjp.Payment_Amount__c);
        */
    }
    
    @isTest
    public static void testVoidedReceipt(){
        User ADMIN_USER = [SELECT Id
                            FROM User
                            WHERE Profile.Name = 'System Administrator'
                            AND IsActive = true LIMIT 1 ];
        
        List<Trigger_Settings__c> triggerSettingsList = new List<Trigger_Settings__c>();
        Trigger_Settings__c CPTriggerSetting = new Trigger_Settings__c(
            Name = 'CasePaymentAll',
            Is_Active__c = true
        );
        triggerSettingsList.add(CPTriggerSetting);
        
        Trigger_Settings__c RCTTriggerSetting = new Trigger_Settings__c(
            Name = 'Receipt Trigger',
            Is_Active__c = true
        );
        triggerSettingsList.add(RCTTriggerSetting);
        
        insert triggerSettingsList;
        
        Receipt__c rct = new Receipt__c(
            Payment_Type__c = 'Check',
            Instrument_Number__c = 'asf',
            Date_Received__c = Date.today(),
            Bank_Location__c = 'CA Bank',
            Payment_Amount__c = 12,
            Payment_Can_Be_Processed__c = true,
            Office_Unit__c = 'CCU 32',
            Status__c = 'New',
            Payment_Exchange__c = 'Division Payment'
        );
        insert rct;
        
        Account employer = new Account(
            Name = 'Employer',
            ShippingPostalCode = '92345',
            Bankruptcy_Status_Date__c = Date.today()
        );
        insert employer;
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id
        );
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id,
            Manager__c = mgr.Id
        );
        insert de;

        DIR_Case__c cm = new DIR_Case__c(
            RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId(),
            Employer__c = employer.Id,
            Assigned_Deputy__c = de.Id
        );
        insert cm;
        
        Case_Payment__c cp = new Case_Payment__c(
            RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(),
            Payment_Amount__c = rct.Payment_Amount__c,
            Case__c = cm.Id,
            Receipt__c = rct.Id,
            Status__c = 'Posted'
        );
        insert cp;

        Liability_Payment__c lp = new Liability_Payment__c(
            Case_Payment__c = cp.Id,
            Payment_Amount__c = cp.Payment_Amount__c * 0.75
        );
        insert lp;
        
        Judgement__c jmt = new Judgement__c(
            Case_Management__c = cm.Id,
            Type__c = 'ODA',
            RecordTypeId = Schema.SObjectType.Judgement__c.getRecordTypeInfosByName().get('JEU').getRecordTypeId()
        );
        insert jmt;
        
        Judgment_Payment__c jp = new Judgment_Payment__c(
            Case_Payment__c = cp.Id,
            Allocated_Amount__c = cp.Payment_Amount__c * 0.25,
            Judgment__c = jmt.Id
        );
        insert jp;
        
        /* for Tier 2:
        Account payeeAccount1 = new Account(
            Name = 'payee1',
            ShippingPostalCode = '90001'
        );
        insert payeeAccount1;

        Account payeeAccount2 = new Account(
            Name = 'payee2',
            ShippingPostalCode = '90002'
        );
        insert payeeAccount2;
        
        Case_Role__c caseRole1 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount1.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole1;
        
        Case_Role__c caseRole2 = new Case_Role__c(
            Case__c = cm.Id,
            Entity__c = payeeAccount2.Id,
            Case_Role_Status__c = 'Active'
        );
        insert caseRole2;
        
        Payee__c payee1 = new Payee__c(
            Factor__c = 75,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole1.Id
        );
        insert payee1;
        
        Payee__c payee2 = new Payee__c(
            Factor__c = 25,
            Payee_Type__c = 'Employee',
            Case_Management__c = cm.Id,
            Case_Role__c = caseRole2.Id
        );
        insert payee2;
        
        Payment_Record__c prlp = new Payment_Record__c(
            Liability_Payment__c = lp.Id,
            Payment_Amount__c = lp.Payment_Amount__c,
            Payee__c = payee1.Id
        );
        insert prlp;
        
        Payment_Record__c prjp = new Payment_Record__c(
            Judgment_Payment__c = jp.Id,
            Payment_Amount__c = jp.Allocated_Amount__c,
            Payee__c = payee2.Id
        );
        insert prjp;
        */
        
        
        Test.startTest();
        rct.Voided_Item__c = true;
        update rct;
        
        List<Id> rctIdList = new List<Id>();
        rctIdList.add(rct.Id);
        
        ReturnedVoidedReceipt.returnReceipts(rctIdList);
        Test.stopTest();
        
        Receipt__c testRCT = [SELECT Id, Name, Voided_Item__c
                                FROM Receipt__c
                                WHERE Id = :rct.Id];
        System.debug('testRCT = '+testRCT);
        
        Liability_Payment__c testNegatedLP = [SELECT Id, Name, Payment_Amount__c
                                                FROM Liability_Payment__c
                                                WHERE Returned_Voided_Liability_Payment__c = :lp.Id][0];
        
        System.assertEquals(testNegatedLP.Payment_Amount__c, -lp.Payment_Amount__c);
        
        Judgment_Payment__c testNegatedJP = [SELECT Id, Name, Allocated_Amount__c
                                                FROM Judgment_Payment__c
                                                WHERE Returned_Voided_Judgment_Payment__c = :jp.Id][0];
        
        System.assertEquals(testNegatedJP.Allocated_Amount__c, -jp.Allocated_Amount__c);
        
        /* for Tier 2:
        Payment_Record__c negatedPrLp = [SELECT Id, Name, Payment_Amount__c, Returned_Voided_Payment_Record__c
                                            FROM Payment_Record__c
                                            WHERE Returned_Voided_Payment_Record__c = :prlp.Id][0];
                                            
        system.assertEquals(negatedPrLp.Payment_Amount__c, -prlp.Payment_Amount__c);
        
        Payment_Record__c negatedPrJp = [SELECT Id, Name, Payment_Amount__c, Returned_Voided_Payment_Record__c
                                            FROM Payment_Record__c
                                            WHERE Returned_Voided_Payment_Record__c = :prjp.Id][0];
                                            
        system.assertEquals(negatedPrJp.Payment_Amount__c, -prjp.Payment_Amount__c);
        */
    }
}