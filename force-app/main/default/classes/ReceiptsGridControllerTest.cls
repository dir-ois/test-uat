@isTest
public class ReceiptsGridControllerTest {
    
    static testmethod void testSaveRctCaseServer(){
        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id,
            Position__c = 'Cashiering'
        );
        insert mgr;
        
        DIR_Employee__c emp = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id,
            Manager__c = mgr.Id
        );
        insert emp;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        acc.Bankruptcy_Status_Date__c = Date.today();
        insert acc;
        
        DIR_Case__c c1 = new DIR_Case__c();
        c1.Employer__c = acc.Id;
        c1.Assigned_Deputy__c = emp.Id;
        insert c1;
        
        DIR_Case__c c2 = new DIR_Case__c();
        c2.Employer__c = acc.Id;
        c2.Assigned_Deputy__c = emp.Id;
        insert c2;

        Map<String,Object> receipt1 = new Map<String,Object>();
        receipt1.put('"Receipt_Index__c"', 0);
        receipt1.put('"Payment_Type__c"', '"Check"');
        receipt1.put('"Instrument_Number__c"', '"TestCheck1"');
        receipt1.put('"Date_Received__c"', '"'+String.valueOf(Date.today()).removeEnd(' 00:00:00')+'"');
        receipt1.put('"Bank_Location__c"', '"CA Bank"');
        receipt1.put('"Payment_Exchange__c"', '"Division Payment"');
        receipt1.put('"Payment_Amount__c"', '"250"');
        receipt1.put('"Office_Unit__c"', '"CCU 32"');
        receipt1.put('"Payment_Can_Be_Processed__c"', true);
        System.debug('----------------------------------------receipt1------------------------------------------');
        System.debug(receipt1);
        
        Map<String,Object> receipt2 = new Map<String,Object>();
        receipt2.put('"Receipt_Index__c"', 1);
        receipt2.put('"Payment_Type__c"', '"Check"');
        receipt2.put('"Instrument_Number__c"', '"TestCheck2"');
        receipt2.put('"Date_Received__c"', '"'+String.valueOf(Date.today()).removeEnd(' 00:00:00')+'"');
        receipt2.put('"Bank_Location__c"', '"CA Bank"');
        receipt2.put('"Payment_Exchange__c"', '"Division Payment"');
        //receipt2.put('"Add_Deduction__c"', true);
        //receipt2.put('"Gross_Amount__c"', '"350"');
        receipt2.put('"Payment_Amount__c"', '"250"');
        //receipt2.put('"Deduction_Amount__c"', '"100"');
        receipt2.put('"Office_Unit__c"', '"CCU 32"');
        receipt2.put('"Payment_Can_Be_Processed__c"', true);
        System.debug('----------------------------------------receipt2------------------------------------------');
        System.debug(receipt2);
       
        List<Object> listRct = new List<Object>();
        listRct.add(receipt1);
        listRct.add(receipt2);
        System.debug('----------------------------------------Receipt List-------------------------------');
        System.debug(listRct);
        
        Map<String,Object> casePayment1 = new Map<String,Object>();
        casePayment1.put('"CP_Index__c"', 0);
        casePayment1.put('"Case__c"' , '"'+c1.id+'"'); 
        casePayment1.put('"Payment_Amount__c"', '"150"');
        casePayment1.put('"Receipt__c"', '""');
        casePayment1.put('"Status__c"' , '"New"');
        casePayment1.put('"Deduction_Payment__c"' , '""');
        System.debug('----------------------------------------Case Payment1------------------------------------------');
        System.debug(casePayment1);
        
        List<Object> listCase = new List<Object>();
        listCase.add(casePayment1);
        System.debug('----------------------------------------Case Payment List-------------------------------------');
        System.debug(listCase);
        
        System.runAs(ADMIN_USER){
            String rctList = string.valueOf(listRct).replace('=', ':').replace('(', '[').replace(')',']');
            String caseList = string.valueOf(listCase).replace('=', ':').replace('(', '[').replace(')',']');
            System.debug('----------------------------------------STRING-------------------------------------');
            System.debug(rctList);
            System.debug(caseList);
            
            ReceiptsGridController.saveReceiptCaseServer(rctList, caseList, false);
            ReceiptsGridController.getRecTypeIds();
        }
        
    }
    
}