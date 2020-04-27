@isTest
public with sharing class AddAppealTest {
    
    public static testMethod void TestAddAppeal1() {
        
        NAICS_Code__c nc = new NAICS_Code__c();
        nc.Name = '11';
        nc.NAICS_Title__c = 'Agriculture, Forestry, Fishing and Hunting';
        nc.Level__c = 'Level 1';
        
        Account acc = new Account();
        acc.Name = 'Emplpoyer name';
        acc.ShippingPostalCode = '234889';
        acc.Phone1__c = '5103334444';
        acc.NAICS_Code__c = nc.Id;
        insert acc;

        User user1 = new User();
        //profile p = [SELECT Id FROM profile WHERE name='RCI User'];
        profile p = [SELECT Id FROM profile WHERE name='BOFE User'];
        user1.ProfileId = p.Id;
        user1.Phone = '5103334444';
        user1.FirstName = 'firstname';
        user1.LastName = 'lastname';
        user1.Username = 'firstname.lastname@dir.ca.gov.test';
        user1.Email = 'firstname.lastname@dir.ca.gov.test';
        user1.Alias = 'flname';
        user1.TimeZoneSidKey = 'America/Denver';
        user1.LocaleSidKey = 'en_US';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LanguageLocaleKey = 'en_US';
        insert user1;

        User user2 = new User();
        user2.ProfileId = p.Id;
        user2.Phone = '5103334444';
        user2.FirstName = 'firstname';
        user2.LastName = 'lastname';
        user2.Username = 'firstname2.lastname2@dir.ca.gov.test';
        user2.Email = 'firstname2.lastname2@dir.ca.gov.test';
        user2.Alias = 'flname';
        user2.TimeZoneSidKey = 'America/Denver';
        user2.LocaleSidKey = 'en_US';
        user2.EmailEncodingKey = 'UTF-8';
        user2.LanguageLocaleKey = 'en_US';
        insert user2;        
 
        DIR_Employee__c assignedDep2 = new DIR_Employee__c(User__c = user2.Id);
        assignedDep2.Active__c = True;
        insert assignedDep2;
        
        DIR_Employee__c assignedDep = new DIR_Employee__c(User__c = user1.Id);
        assignedDep.Active__c = True;
        assignedDep.Manager__c = assignedDep2.Id;
        insert assignedDep;   
        
        Affiliation__c aff = new Affiliation__c();
        aff.Affiliated_Account__c = acc.Id;
        aff.Main_Account__c = acc.Id;
        insert aff;
        
        DIR_Case__c c = new DIR_Case__c();
        //Id caseRecTypeId_RCI = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id caseRecTypeId_BOFE = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();
        //c.RecordTypeId = caseRecTypeId_RCI;
        c.RecordTypeId = caseRecTypeId_BOFE;
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = assignedDep.Id;
        insert c;
                 
		Case_Role__c crEmplyr = new Case_Role__c();
        crEmplyr.Entity__c = acc.Id;
        crEmplyr.Case__c = c.Id;
        crEmplyr.Case_Role_Status__c = 'Active';
        crEmplyr.Role__c = 'Case Employer';
        insert crEmplyr;
        
        Appeal__c appeal1 = new Appeal__c();
        appeal1.Status__c = 'New';
        //Id RCIRecordTypeId = Schema.SObjectType.Appeal__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id BOFEAppealRecTypeId = Schema.SObjectType.Appeal__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
        //appeal1.recordtypeID = RCIRecordTypeID;
        appeal1.recordtypeID = BOFEAppealRecTypeID;
        appeal1.Case__c = c.Id;
        appeal1.Estimated_Length_of_Hearing_In_Minutes__c = 30;
        appeal1.Citation_Selected__c = True;
        appeal1.Unavailable_dates__c = 'February 10, 2019';
        //date newDate = date.newInstance(2001, 3, 21);
        appeal1.Request_Receipt_Date__c = Date.today()+1;
        appeal1.X2810_3_Case__c = 'No';
        insert appeal1;
        
        
        Assessments__c assesment = new Assessments__c();
        assesment.Appeal_Deadline_Selector__c = 'Business Days';
        assesment.Appeal_Deadline_Days__c = 15;
        assesment.Case_Management__c = c.Id;
        insert assesment;

        Violation_Type__c vt1 = new Violation_Type__c();
        //Id RCIVTRecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('RCI Violations').getRecordTypeId();
        Id BOFEVTRecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId();
        //vt1.RecordTypeId = RCIVTRecordTypeId;
        vt1.RecordTypeId = BOFEVTRecordTypeId;
        vt1.Name = 'L.C. 1030';
        vt1.Active__c = True;
        vt1.Assessment_Formula__c = '100';
        vt1.Appeal_Deadline_Selector__c = 'Business Days';
        vt1.Appeal_Deadline_Days__c = 15;
        vt1.Accounting_Payment_Type__c = 'Penalty';
        insert vt1;
                
        
        //Case Issue
        DIR_Violation__c dv = new DIR_Violation__c();
        dv.Case__c = c.Id;
        dv.Assessment__c = assesment.Id;
        dv.Violation_Type__c = vt1.Id;
        insert dv;
     
        Liability__c liability1 = new Liability__c();
        liability1.Assessment__c = assesment.Id;
        liability1.Case_Management__c = c.Id;
        liability1.Status__c = 'new';
        liability1.Appeal_Deadline__c = Date.today();
        insert liability1;

        
        Liable_Party__c lp = new Liable_Party__c();
        lp.Liability__c = liability1.Id;
        lp.Entity__c = acc.id;
        
        Appeal__c app = [SELECT Id, Status__c FROM Appeal__c WHERE Id =: appeal1.Id];
        //app.Status__c = 'Withdrawn';
        //update app;
        
        
        DIR_Case__c  dir = [SELECT Id, Employer__c, Employer__r.Name, Employer__r.Phone FROM DIR_Case__c WHERE Id =: c.Id LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(dir);
        AddAppeal aa = new AddAppeal(sc);
        
        //system.assertequals(aa.Citations.size(),0);
        PageReference pageRef = Page.AddAppeal;
        pageRef.getParameters().put('id', String.valueOf(dir.Id));
        Test.setCurrentPage(pageRef);
        
        aa.appeal.recordtypeID = BOFEAppealRecTypeID;
        //aa.appeal.recordtypeID = RCIRecordTypeID;
        aa.appeal.Case__c = c.Id;
        aa.appeal.X2810_3_Case__c = 'No';
        aa.appeal.Estimated_Length_of_Hearing_In_Minutes__c = 30;
        aa.appeal.Citation_Selected__c = True;
        aa.appeal.Request_Receipt_Date__c = Date.today()+1;
        aa.appeal.Unavailable_dates__c = 'No Mondays';
        aa.SaveAppeal();

        List<AddAppeal.CitationWrapper> localList = new List<AddAppeal.CitationWrapper>();
        aa.Citations = new List<AddAppeal.CitationWrapper>();
        (aa.Citations).add(new AddAppeal.CitationWrapper(liability1, true));
        aa.SaveAppeal();
        
    }
    

}