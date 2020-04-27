@isTest
public class DIR_RCIOnlyTriggerHandlerTest {
    
    public static testMethod void method1(){
        
        Account objAccount1 = new Account(Name = 'Test',ShippingCity = 'Test1', BillingCity = 'Test1');
        Account objAccount2 = new Account(Name = 'Test',ShippingCity = 'Test2', BillingCity = 'Test2');
        
        insert new List<Account> {objAccount1,objAccount2};
            
            Id RecordTypeIdAdvocate = Schema.SObjectType.Associated_Party__c.getRecordTypeInfosByName().get('AP-Advocate').getRecordTypeId();
        Id RecordTypeIdEmployee = Schema.SObjectType.Associated_Party__c.getRecordTypeInfosByName().get('AP-Employee').getRecordTypeId();
        Id RecordTypeIdEmployer = Schema.SObjectType.Associated_Party__c.getRecordTypeInfosByName().get('AP-Employer').getRecordTypeId();
        
        System.debug(RecordTypeIdAdvocate);
        System.debug(RecordTypeIdEmployee);
        
        test.startTest();
        RCI_Only__c rci = new RCI_Only__c();
        insert rci;
        
        Associated_Party__c aParty1 = new Associated_Party__c();
        aParty1.First_Name__c ='test1 first';
        aParty1.Last_Name__c = 'test1 last';
        aParty1.Business_Name__c ='business 1';
        aParty1.RCI__c = rci.Id;
        aParty1.Number_of_Employees__c = 10;
        aParty1.Status__c ='Confirm';
        aParty1.Role__c='Advocate';
        aParty1.RecordTypeId=RecordTypeIdAdvocate;
        insert aParty1;
        
        Associated_Party__c aParty2 = new Associated_Party__c();
        aParty2.First_Name__c ='test2 first';
        aParty2.Last_Name__c = 'test2 last';
        aParty2.Business_Name__c ='business 2';
        aParty2.RCI__c = rci.Id;
        aParty2.Number_of_Employees__c = 10;
        aParty2.Status__c ='Confirm';
        aParty2.Role__c='Claimant';
        aParty2.RecordTypeId=RecordTypeIdEmployer;
        insert aParty2;
        
        Associated_Party__c aParty3 = new Associated_Party__c();
        aParty3.First_Name__c ='test3 first';
        aParty3.Last_Name__c = 'test3 last';
        aParty3.Business_Name__c ='business 3';
        aParty3.RCI__c = rci.Id;
        aParty3.Number_of_Employees__c = 10;
        aParty3.Status__c ='Confirm';
        aParty3.Role__c='Case Employer';
        aParty3.Found_Account_ID__c=objAccount1.Id;
        aParty3.RecordTypeId=RecordTypeIdEmployee;
        insert aParty3;
        
        rci.Status__c = 'Convert to Case';
        update rci;
        test.stopTest();
    }
 public static testMethod void method2(){
       Account objAccount1 = new Account(Name = 'Test',ShippingCity = 'Test1', BillingCity = 'Test1');
        Account objAccount2 = new Account(Name = 'Test',ShippingCity = 'Test2', BillingCity = 'Test2');
        
        insert new List<Account> {objAccount1,objAccount2};
            
            Id RecordTypeIdAdvocate = Schema.SObjectType.Associated_Party__c.getRecordTypeInfosByName().get('AP-Advocate').getRecordTypeId();
        Id RecordTypeIdEmployee = Schema.SObjectType.Associated_Party__c.getRecordTypeInfosByName().get('AP-Employee').getRecordTypeId();
        Id RecordTypeIdEmployer = Schema.SObjectType.Associated_Party__c.getRecordTypeInfosByName().get('AP-Employer').getRecordTypeId();
        
        System.debug(RecordTypeIdAdvocate);
        System.debug(RecordTypeIdEmployee);
        
        test.startTest();
        RCI_Only__c rci = new RCI_Only__c();
        insert rci;
        
        Associated_Party__c aParty1 = new Associated_Party__c();
        aParty1.Business_Name__c ='business 1';
        aParty1.RCI__c = rci.Id;
        aParty1.Number_of_Employees__c = 10;
        aParty1.Status__c ='Confirm';
        aParty1.Role__c='Advocate';
        aParty1.RecordTypeId=RecordTypeIdAdvocate;
        insert aParty1;
        
        Associated_Party__c aParty2 = new Associated_Party__c();
        aParty2.Business_Name__c ='business 2';
        aParty2.RCI__c = rci.Id;
        aParty2.Number_of_Employees__c = 10;
        aParty2.Status__c ='Confirm';
        aParty2.Role__c='Claimant';
        aParty2.RecordTypeId=RecordTypeIdEmployer;
        insert aParty2;
        
        Associated_Party__c aParty3 = new Associated_Party__c();
       
        aParty3.Business_Name__c ='business 3';
        aParty3.RCI__c = rci.Id;
        aParty3.Number_of_Employees__c = 10;
        aParty3.Status__c ='Confirm';
        aParty3.Role__c='Case Employer';
        aParty3.Found_Account_ID__c=objAccount1.Id;
        aParty3.RecordTypeId=RecordTypeIdEmployee;
        insert aParty3;
        
        rci.Status__c = 'Convert to Case';
        update rci;
        test.stopTest();
     
 }
    
}