@isTest
private class UpdateViolationControllerTEST {
    
    private static Id gRT = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('Garment').getRecordTypeId();
    
    public static testMethod void TestNewViolation1() {
        
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
        cm.recordTypeId = gRT;
        cm.Assigned_Deputy__c = de.Id;
        insert cm;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - New').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        insert vt;
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
        vtv.Violation_Type__c = vt.Id;
        vtv.Data_Type__c = 'Integer';
        vtv.Description__c = 'test';
        vtv.value__c = '{!input}';
        insert vtv;
        vtv = [SELECT Id, Name, Description__c, value__c, Data_Type__c, Violation_Type__c FROM Violation_Type_Variable__c WHERE Id =: vtv.Id];
        
        vt.Penalty_Assessment_Description__c = 'this is a test {~'+vtv.Name+'~*~'+vtv.Name+'~}';
        update vt;
        
        DIR_Violation__c viol = new DIR_Violation__c();
        viol.Original_Penalty_Assessment_Amount__c = 10;
        viol.Original_Wage_Assessment_Amount__c = 10;
        viol.Wages_Due__c = 10;
        viol.Citation_Amount__c = 10;
        viol.Case__c = cm.Id;
        insert viol;
        
        Violation_Variable__c vv = new Violation_Variable__c();
        vv.Case_Violation__c = viol.Id;
        vv.Value__c = '10';
        vv.Violation_Type_Variable__c = vtv.Id;
        insert vv;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(viol);
        UpdateViolationController controller = new UpdateViolationController(sc);
        controller.retURL = 'http://www.salesforce.com';
        controller.valueString = ''
        + String.valueOf(controller.SelectedTypes[0].indexCounter) + String.valueOf(controller.SelectedTypes[0].vtvWrapperList[0].indexCounter) + ':' + '12' 
        + '::'+String.valueOf(controller.SelectedTypes[0].indexCounter)+'TOTALA:12' 
        + '::'+String.valueOf(controller.SelectedTypes[0].indexCounter)+'TOTALW:12';
        
        vt.Assessment_Formula__c = controller.SelectedTypes[0].vtvWrapperList[0].vTypeVar.Name + '*' + controller.SelectedTypes[0].vtvWrapperList[0].vTypeVar.Name;
        update vt;
        
        controller.saveVarValues();
        controller.saveChanges();
        
    }
}