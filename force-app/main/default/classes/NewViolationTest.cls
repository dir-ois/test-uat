@isTest(SeeAllData=true)
public with sharing class NewViolationTest {
    
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
        //cm.recordTypeId = gRT;
        cm.Employer__c = a.Id;
        cm.Status__c = 'Open';
        cm.Assigned_Deputy__c = de.Id;
        cm.RecordtypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert cm;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('WCA Issues - New').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        insert vt;
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
        vtv.Violation_Type__c = vt.Id;
        vtv.Data_Type__c = 'Text';
        vtv.Description__c = 'test';
        vtv.value__c = '100';
        insert vtv;
        
        vtv = [SELECT Id, Name, Violation_Type__c, Data_Type__c, Description__c, value__c FROM Violation_Type_Variable__c WHERE Id =: vtv.Id];
        
        vt.Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Penalty_Assessment_Description__c = 'test Assess desc {~'+vtv.Name +'~+~'+vtv.Name + '~}';
        vt.Wage_Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Wage_Assessment_Description__c = 'test Wage desc ~'+vtv.Name + '~';
        
        update vt;
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', cm.Id);
        NewViolation newV = new NewViolation ();
        newV.LoadCase();
        newV.violationId = vt.Id;
        newV.selectedTypes.add(new NewViolation.ViolationTypeWrapper(vt, newV.wrapperIndex++));
        newV.selectedTypes[0].vtvWrapperList = new List<NewViolation.violationTypeVarWrapper>();
        newV.selectedTypes[0].vtvWrapperList.add(new NewViolation.violationTypeVarWrapper(vtv, newV.wrapperIndex++));
        newV.addViolation();
        
        ApexPages.currentPage().getParameters().put('id', cm.Id);
        newViolation newV2 = new newViolation ();
        newV2.LoadCase();
        newV2.violationId = vt.Id;
        newV2.addViolation();
        
        newV2.selectedTypes.clear();
        newV2.selectedTypes.add(new NewViolation.ViolationTypeWrapper(vt, newV2.wrapperIndex++));
        newV2.selectedTypes[0].vtvWrapperList = new List<NewViolation.violationTypeVarWrapper>();
        newV2.selectedTypes[0].vtvWrapperList.add(new NewViolation.violationTypeVarWrapper(vtv, newV2.wrapperIndex++));
        
        String s1 = newV2.selectedTypes[0].wageFormula;
        String s2 = newV2.selectedTypes[0].formula;
        String s3 = newV2.selectedTypes[0].amountPaidFormula;
        String s4 = newV2.selectedTypes[0].amountEarnedFormula;
        
        newV2.GoToSecondStep();
        
        newV2.Liabilities[0].selected = true;
        newV2.Liabilities[0].propShare = '100';
        newV2.Liabilities[0].acc = a;
        newV2.valueString = ''
            + String.valueOf(newV2.SelectedTypes[0].indexCounter) + String.valueOf(newV2.SelectedTypes[0].vtvWrapperList[0].indexCounter) + ':' + '100' 
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'TOTALA:10' 
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'TOTALW:20'
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'TOTALIW:30'
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'AMTP:40'
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'AMTE:50';
        newV2.SelectedCitation = 'Single';
        newV2.Finalize();
        newV2.SelectedCitation = 'Multiple';
        newV2.Finalize();
        
        newV2.violationIndex = string.valueOf(newV2.SelectedTypes[0].indexCounter);
        newV2.removeViolation();
        newV2.BackTo1stStep();
        newV2.getCitationItems();
        newV2.SearchEmployee();
        newV2.SelectEmployee();
        boolean testb = newV2.getRTError;
        integer testInt = newV2.SelectedSize;
        newV2.emptyMethod();
        
        test.stopTest();
    }
    
    /////////////////////////////////
    public static testMethod void TestNewViolation2() {
        
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
        //cm.recordTypeId = gRT;
        cm.Employer__c = a.Id;
        cm.Status__c = 'Open';
        cm.Assigned_Deputy__c = de.Id;
        cm.RecordtypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        insert cm;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        vt.Civil_Penalty_Section__c = '';
        vt.Wizard_Search_Text__c = 'any text';
        vt.Name = 'L.C. 238(f) – Subsequent Violations';
        insert vt;
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
        vtv.Violation_Type__c = vt.Id;
        vtv.Data_Type__c = 'Text';
        vtv.Description__c = 'test';
        vtv.value__c = '100';
        insert vtv;
        
        vtv = [SELECT Id, Name, Violation_Type__c, Data_Type__c, Description__c, value__c FROM Violation_Type_Variable__c WHERE Id =: vtv.Id];
        
        vt.Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Penalty_Assessment_Description__c = 'test Assess desc {~'+vtv.Name +'~+~'+vtv.Name + '~}';
        vt.Wage_Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Wage_Assessment_Description__c = 'test Wage desc ~'+vtv.Name + '~';
        
        update vt;
        
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', cm.Id);
        NewViolation newV = new NewViolation ();
        newV.LoadCase();
        newV.violationId = vt.Id;
        newV.selectedTypes.add(new NewViolation.ViolationTypeWrapper(vt, newV.wrapperIndex++));
        newV.selectedTypes[0].vtvWrapperList = new List<NewViolation.violationTypeVarWrapper>();
        newV.selectedTypes[0].vtvWrapperList.add(new NewViolation.violationTypeVarWrapper(vtv, newV.wrapperIndex++));
        newV.addViolation();
        
        ApexPages.currentPage().getParameters().put('id', cm.Id);
        newViolation newV2 = new newViolation ();
        newV2.LoadCase();
        newV2.violationId = vt.Id;
        newV2.addViolation();
        
        newV2.selectedTypes.clear();
        newV2.selectedTypes.add(new NewViolation.ViolationTypeWrapper(vt, newV2.wrapperIndex++));
        newV2.selectedTypes[0].vtvWrapperList = new List<NewViolation.violationTypeVarWrapper>();
        newV2.selectedTypes[0].vtvWrapperList.add(new NewViolation.violationTypeVarWrapper(vtv, newV2.wrapperIndex++));
        
        String s1 = newV2.selectedTypes[0].wageFormula;
        String s2 = newV2.selectedTypes[0].formula;
        String s3 = newV2.selectedTypes[0].amountPaidFormula;
        String s4 = newV2.selectedTypes[0].amountEarnedFormula;
        
        newV2.GoToSecondStep();
        
        newV2.Liabilities[0].selected = true;
        newV2.Liabilities[0].propShare = '100';
        newV2.Liabilities[0].acc = a;
        newV2.valueString = ''
            + String.valueOf(newV2.SelectedTypes[0].indexCounter) + String.valueOf(newV2.SelectedTypes[0].vtvWrapperList[0].indexCounter) + ':' + '100' 
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'TOTALA:10' 
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'TOTALW:20'
            + '::'+String.valueOf(newV2.SelectedTypes[0].indexCounter)+'TOTALIW:30';
        newV2.SelectedCitation = 'Single';
        newV2.Finalize();
        newV2.SelectedCitation = 'Multiple';
        newV2.Finalize();
        
        newV2.violationIndex = string.valueOf(newV2.SelectedTypes[0].indexCounter);
        newV2.removeViolation();
        newV2.BackTo1stStep();
        newV2.getCitationItems();
        newV2.SearchEmployee();
        newV2.SelectEmployee();
        boolean testb = newV2.getRTError;
        integer testInt = newV2.SelectedSize;
        newV2.emptyMethod();
        
        test.stopTest();
    }
    
    /////////////////////////////////
    public static testMethod void TestNewViolation3() {
        
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
        //cm.recordTypeId = gRT;
        cm.Employer__c = a.Id;
        cm.Status__c = 'Open';
        cm.Assigned_Deputy__c = de.Id;
        cm.RecordtypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        insert cm;
        
        Violation_Type__c vt = new Violation_Type__c();
        vt.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        vt.Appeal_Deadline_Days__c = 12;
        vt.Active__c = true;
        vt.Appeal_Deadline_Selector__c = 'Business Days';
        vt.Civil_Penalty_Section__c = 'L.C. 3722(a)';
        vt.Wizard_Search_Text__c = 'BOFE 335';
        insert vt;
        
        Violation_Type__c vt2 = new Violation_Type__c();
        vt2.RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        vt2.Appeal_Deadline_Days__c = 12;
        vt2.Active__c = true;
        vt2.Appeal_Deadline_Selector__c = 'Business Days';
        vt2.Civil_Penalty_Section__c = 'L.C. 3710.1';
        vt2.Wizard_Search_Text__c = 'BOFE 335';
        insert vt2;
        
        Violation_Type_Variable__c vtv = new Violation_Type_Variable__c();
        vtv.Violation_Type__c = vt.Id;
        vtv.Data_Type__c = 'Text';
        vtv.Description__c = 'test';
        vtv.value__c = '100';
        insert vtv;
        
        vtv = [SELECT Id, Name, Violation_Type__c, Data_Type__c, Description__c, value__c FROM Violation_Type_Variable__c WHERE Id =: vtv.Id];
        
        vt.Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Penalty_Assessment_Description__c = 'test Assess desc {~'+vtv.Name +'~+~'+vtv.Name + '~}';
        vt.Wage_Assessment_Formula__c = vtv.Name + '+' + vtv.Name;
        vt.Wage_Assessment_Description__c = 'test Wage desc ~'+vtv.Name + '~';
        
        update vt;
        
        
  
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', cm.Id);
        NewViolation newV = new NewViolation ();
        newV.LoadCase();
        newV.violationId = vt.Id;
        newV.selectedTypes.add(new NewViolation.ViolationTypeWrapper(vt, newV.wrapperIndex++));
        newV.selectedTypes[0].vtvWrapperList = new List<NewViolation.violationTypeVarWrapper>();
        newV.selectedTypes[0].vtvWrapperList.add(new NewViolation.violationTypeVarWrapper(vtv, newV.wrapperIndex++));
        newV.addViolation();
        
    
        test.stopTest();
    }
}