@istest
public class ConfiscationBagAllTest {
    
    public static testMethod void testUpdateConfBags(){
        
        Account a = new Account();
        a.Name = 'Lucian395274';
        insert a;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de; 
        
        DIR_Case__c cm = new DIR_Case__c();
        cm.Assigned_Deputy__c = de.Id;
        insert cm;
        
        Assessments__c assess = new Assessments__c();
        assess.Case_Management__c = cm.Id;
        insert assess;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        insert vt;
        
        DIR_Violation__c vio = new DIR_Violation__c();
        vio.Violation_Type__c = vt.Id;
        vio.Case__c = cm.Id;
        vio.Assessment__c = assess.Id;
        insert vio;
        
        liability__c lia = new liability__c();
        lia.assessment__c = assess.id;
        lia.Case_Management__c = cm.ID;
        insert lia;
        
        Confiscation_Bag__c bag = new Confiscation_Bag__c();
        bag.recordTypeID = Schema.SObjectType.Confiscation_Bag__c.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        bag.Liability__c = lia.Id;
        bag.Assessment__c = assess.id;
        bag.Returned__c = false;
        insert bag;
        
        Confiscated_item__c item1 = new Confiscated_Item__c();
        item1.recordTypeID = Schema.SObjectType.Confiscated_Item__c.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        item1.Confiscation_Bag__c = bag.Id;
        item1.Item_description__c = 'desc';
        item1.Quantity__c = 1;
        item1.Returned__c = false;
        insert item1;
        
        Confiscated_item__c item2 = new Confiscated_Item__c();
        item2.recordTypeID = Schema.SObjectType.Confiscated_Item__c.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        item2.Confiscation_Bag__c = bag.Id;
        item2.Item_description__c = 'desc';
        item2.Quantity__c = 1;
        item2.Returned__c = true;
        insert item2;
        
        test.startTest();
        bag.Returned__c = true;
        update bag;
        test.stopTest();
        
        system.Assert(item1.Returned__c = true);
        system.assert(item2.Returned__c = true);
        
        
    }
}