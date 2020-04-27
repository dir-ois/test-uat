@isTest
public with sharing class DIRCaseAllTest {
    
    private static testMethod void testUpdateCase(){
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        test.startTest();
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.RecordTypeId = caseRecordTypeId;
        insert c;
        
        DIR_Case__c c2 = [SELECT Id, Office__c FROM DIR_Case__c WHERE Id =: c.Id];
        system.assertEquals(office.Id, c2.Office__c);
        
        test.stopTest();
    }

    private static testMethod void testUpdateCaseReferToJEU(){
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        test.startTest();
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.RecordTypeId = caseRecordTypeId;
        c.Refer_to_JEU__c = 'Referred';
        insert c;
        
        DIR_Case__c c2 = [SELECT Id, Office__c FROM DIR_Case__c WHERE Id =: c.Id];
        system.assertEquals(office.Id, c2.Office__c);
        
        test.stopTest();
    }

    private static testMethod void testUpdateCaseExistingEmployer(){
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        
        Office__c office = new Office__c();
        office.Name = 'Lucian832474';
        insert office;
        
        Zip_Code__c zip = new Zip_Code__c();
        zip.Name = '234889';
        insert zip;
        
        Office_Zip_Code_Map__c map1 = new Office_Zip_Code_Map__c();
        map1.Zip_Code__c = zip.Id;
        map1.Office__c = office.Id;
        insert map1;
        
        Account acc1 = new Account();
        acc1.Name = 'name';
        acc1.ShippingPostalCode = '234889';
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'name2';
        acc2.ShippingPostalCode = '234889';
        insert acc2;
        
        DIR_Case__c existingCase = new DIR_Case__c();
        existingCase.Employer__c = acc1.Id;
        existingCase.RecordTypeId = caseRecordTypeId;
        insert existingCase;
        
        Report_of_Labor_Code_Violation__c rllv = new Report_of_Labor_Code_Violation__c();
        rllv.DIR_Case__c = existingCase.Id;
        rllv.Account__c = acc1.Id;
        insert rllv;

        test.startTest();
        
        existingCase.Employer__c = acc2.Id;
        update existingCase;
        
        rllv.Account__c = acc2.Id;
        update rllv;

        DIR_Case__c newCase = new DIR_Case__c();
        newCase.Employer__c = acc2.Id;
        newCase.RecordTypeId = caseRecordTypeId;
        insert newCase;
        

        existingCase = [SELECT Id, Employer__c, Office__c FROM DIR_Case__c WHERE Id =: existingCase.Id];
        newCase = [SELECT Id, Employer__c, Office__c FROM DIR_Case__c WHERE Id =: newCase.Id];
        
        system.debug('existingCase: ' + existingCase);
        system.debug('newCase: ' + newCase);
        system.assertEquals(existingCase.Employer__c, newCase.Employer__c);
        system.assertEquals(existingCase.Office__c, newCase.Office__c);
        
        test.stopTest();
    }
    
    /*
    private static testMethod void testUpdateCaseOwner(){
                
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alex@testorg.com');
        insert u;
        
        User u2 = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alexa@testorg.com');
        insert u2;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        insert de;
        
        DIR_Employee__c de2 = new DIR_Employee__c();
        de2.Name = 'name';
        de2.Position__c = 'Deputy';
        de2.User__c = u2.Id;
        de2.Manager__c = ma.Id;
        insert de2;
        
        DIR_Case__c c = new DIR_Case__c();
        c.RecordTypeId = caseRecordTypeId;
        c.Assigned_Deputy__c = de.Id;
        insert c;
        
        c.Assigned_Deputy__c = de2.Id;
        update c;
        
        //DIR_Case__c c2 = [SELECT Id, OwnerId FROM DIR_Case__c WHERE Id =: c.Id];
        //DIR_Employee__c de3 = [SELECT Id, User__c FROM DIR_Employee__c WHERE Id =: de.Id];
        
        
    }
    */
    
    private static testMethod void testUpdateLaborCodeViolations(){
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        Id caseRecordTypeId2 = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();

        Id caseRecordTypeId3 = RecordTypeUtil.getRecordTypeIDByName('DIR_Case__c', 'BOFE Investigation');
        Id caseRecordTypeId4 = RecordTypeUtil.getRecordTypeIDByName('DIR_Case__c', 'Lorem Ipsum');

        
        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE Intake, BOFE Investigation';
        insert kvs;
        
        Profile p = [select id from profile where name='BOFE User'];
        
         User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testuser@ca-dir.com');
        insert u;

        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        
        
        DIR_Employee__c de2 = de.clone();
        insert de2;
        insert de;

        Account acc = new Account();
        acc.Name = 'name';
        Account acc2 = new Account();
        acc2.Name = 'name2';
        Account acc3 = new Account();
        acc3.Name = 'name3';
        insert new List<Account> { acc, acc2, acc3 };
        
        
        DIR_Case__c c1 = new DIR_Case__c();
        c1.RecordTypeId = caseRecordTypeId;
        c1.Employer__c = acc.Id;
        c1.Assigned_Deputy__c = de.Id;
        insert c1;
        
        DIR_Case__c c = new DIR_Case__c();
        c.RecordTypeId = caseRecordTypeId;
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.Id;
        DIR_Case__c c2 = new DIR_Case__c();
        c2.RecordTypeId = caseRecordTypeId;
        c2.Employer__c = acc2.Id;
        c2.Assigned_Deputy__c = de.Id;
        DIR_Case__c c3 = new DIR_Case__c();
        c3.RecordTypeId = caseRecordTypeId2;
        c3.Employer__c = acc3.Id;
        c3.Assigned_Deputy__c = de.id;
        insert new List<DIR_Case__c> { c, c2, c3 };
        
        
        Report_of_Labor_Code_Violation__c v = new Report_of_Labor_Code_Violation__c();
        v.DIR_Case__c = c.Id;
        v.Account__c = acc.Id;
        v.Source__c = 'Community Group Referral';
        v.Child_Labor_Violations__c = 'No valid work permit(s)';
        v.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v2 = new Report_of_Labor_Code_Violation__c();
        v2.DIR_Case__c = c2.Id;
        v2.Account__c = acc2.Id;
        v2.Source__c = 'Community Group Referral';
        v2.Child_Labor_Violations__c = 'No valid work permit(s)';
        v2.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v3 = new Report_of_Labor_Code_Violation__c();
        v3.DIR_Case__c = c3.Id;
        v3.Account__c = acc3.Id;
        v3.Source__c = 'Community Group Referral';
        v3.Child_Labor_Violations__c = 'No valid work permit(s)';
        v3.No_number_of_minors_affected__c = 5;
        insert new List<Report_of_Labor_Code_Violation__c> { v, v2, v3 };
        
        test.startTest();
        
        checkRecursive.run2 = true;
        c.Employer__c = acc2.Id;
        update c;
        
        insert new Assignment_History__c(Case_Management__c = c1.id);
        c1.Status__c = 'Closed - No further action';
        update c1;
        
        DIRCaseTriggerHandler.preventDuplicateHistoryCreations = true;
        c1.Status__c = 'Reopened with Senior Approval';
        update c1;

        DIR_Case__c c4 = [SELECT Id FROM DIR_Case__c WHERE Id =: c2.Id];
        Report_of_Labor_Code_Violation__c v4 = [SELECT Id, DIR_Case__c FROM Report_of_Labor_Code_Violation__c WHERE Id =: v.Id];
        //system.assertEquals(v4.DIR_Case__c, c4.Id);

        c3.Employer__c = acc2.Id;
        update c3;
        
        test.stopTest();
    }

    private static testMethod void testUpdateLaborCodeViolations2(){
        
        Id caseRecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        Id caseRecordTypeId2 = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();
        
        Key_Value_Store__c kvs = new Key_Value_Store__c();
        kvs.Name = 'BOFE Open Case RT';
        kvs.Value__c = 'BOFE Intake, BOFE Investigation';
        insert kvs;
        
        Profile p = [select id from profile where name='BOFE User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='testuser1@ca-dir.com');
        insert u;

        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.Name = 'name';
        de.Position__c = 'Deputy';
        de.User__c = u.Id;
        de.Manager__c = ma.Id;
        insert de;
        
        DIR_Employee__c de2 = de.clone();
        insert de2;

        Account acc = new Account();
        acc.Name = 'name';
        Account acc2 = new Account();
        acc2.Name = 'name2';
        Account acc3 = new Account();
        acc3.Name = 'name3';
        insert new List<Account> { acc, acc2, acc3 };
        
        DIR_Case__c c = new DIR_Case__c();
        c.RecordTypeId = caseRecordTypeId;
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.Id;
        DIR_Case__c c2 = new DIR_Case__c();
        c2.RecordTypeId = caseRecordTypeId2;
        c2.Employer__c = acc2.Id;
        c2.Assigned_Deputy__c = de.id;
        DIR_Case__c c3 = new DIR_Case__c();
        c3.RecordTypeId = caseRecordTypeId2;
        c3.Employer__c = acc3.Id;
        c3.Assigned_Deputy__c = de.id;
        DIRCaseTriggerHandler.preventDuplicateHistoryCreations = true;
        insert new List<DIR_Case__c> { c, c2, c3 };
        
        Report_of_Labor_Code_Violation__c v = new Report_of_Labor_Code_Violation__c();
        v.DIR_Case__c = c.Id;
        v.Account__c = acc.Id;
        v.Source__c = 'Community Group Referral';
        v.Child_Labor_Violations__c = 'No valid work permit(s)';
        v.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v2 = new Report_of_Labor_Code_Violation__c();
        v2.DIR_Case__c = c2.Id;
        v2.Account__c = acc2.Id;
        v2.Source__c = 'Community Group Referral';
        v2.Child_Labor_Violations__c = 'No valid work permit(s)';
        v2.No_number_of_minors_affected__c = 5;
        Report_of_Labor_Code_Violation__c v3 = new Report_of_Labor_Code_Violation__c();
        v3.DIR_Case__c = c3.Id;
        v3.Account__c = acc3.Id;
        v3.Source__c = 'Community Group Referral';
        v3.Child_Labor_Violations__c = 'No valid work permit(s)';
        v3.No_number_of_minors_affected__c = 5;
        insert new List<Report_of_Labor_Code_Violation__c> { v, v2, v3 };

        DIR_Inspection__c insp = new DIR_Inspection__c();
        insp.DIR_Case__c = c3.Id;
        insert insp;
        
        test.startTest();
        
        checkRecursive.run2 = true;
        c2.Employer__c = acc3.Id;
        c2.Assigned_Deputy__c = de2.id;
        DIRCaseTriggerHandler.preventDuplicateHistoryCreations = true;
        update c2;
        
        DIR_Case__c c4 = [SELECT Id FROM DIR_Case__c WHERE Id =: c2.Id];
        Report_of_Labor_Code_Violation__c v4 = [SELECT Id, DIR_Case__c FROM Report_of_Labor_Code_Violation__c WHERE Id =: v.Id];
        //system.assertEquals(v4.DIR_Case__c, c4.Id);
        
        
        test.stopTest();
        
        try{
            delete c;
        }
        catch(exception ex){
            
        }
    }
    
    public void testUpdateCaseOwnerManager(){
        
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='alex@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alex@testorg.com');
        insert u;
        User u2 = new User(alias = 'standt', email='alex2@vertiba.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='alex2@testorg.com', ManagerId = u.Id);
        insert u2;
        
        Account acc = new Account();
        acc.Name = 'name';
        insert acc;
        
        test.startTest();
        
        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.OwnerId = u2.Id;
        insert c;
        
        DIR_Case__c c2 = [SELECT Id, Owner_s_Manager__c FROM DIR_Case__c WHERE Id =: c.Id];
        system.assertEquals(c2.Owner_s_Manager__c, u.Id);
        
        test.stopTest();
    }

}