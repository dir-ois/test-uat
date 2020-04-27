@isTest(SeeAllData=false)
private class CreateODAControllerTEST {

    static testMethod void testJointLiability() {
        
        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1 ];
        
        Account a = new Account(
            Name = 'name',
            ShippingPostalCode = '234889'
        );
        insert a;
        
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
        
        DIR_Case__c c = new DIR_Case__c(
            Employer__c = a.Id,
            Assigned_Deputy__c = de.Id
        );
        insert c;

        List<Case_Role__c> crList = new List<Case_Role__c>();
        
        Case_Role__c cr = new Case_Role__c(
            Case__c = c.Id,
            Entity__c = a.Id,
            Role__c = 'Employer'
        );
        crList.add(cr);

        Case_Role__c cr2 = new Case_Role__c(
            Case__c = c.Id,
            Entity__c = a.Id,
            Role__c = 'Employer'
        );
        crList.add(cr2);

        insert crList;
        
        Appeal__c appeal = new Appeal__c(
            Status__c = 'New',
            Case__c = c.Id,
            X2810_3_Case__c = 'Yes',
            Citation_Selected__c = true,
            Estimated_Length_of_Hearing_In_Minutes__c = 60
        );
        insert appeal;
        
        List<Hearing__c> mtgList = new List<Hearing__c>();

        Hearing__c mtg = new Hearing__c(
            Appeal__c = appeal.Id,
            Case__c = c.Id,
            Status__c = 'New',
            Meeting_Start_Date_Time__c = date.today(),
            Meeting_End_Date_Time__c = date.today() + 10
        );
        mtgList.add(mtg);

        insert mtgList;

        List<Meeting_Participant__c> mpList = new List<Meeting_Participant__c>();
        
        Meeting_Participant__c mp = new Meeting_Participant__c(
            Case__c = c.Id,
            Case_Role__c = cr.Id,
            Meeting__c = mtg.Id
        );
        mpList.add(mp);
        
        insert mpList;

        Assessments__c assess = new Assessments__c(
            Case_Management__c = c.Id,
            Appeal_Deadline_Selector__c = 'Business Days'
        );
        insert assess;

        List<Liability__c> lList = new List<Liability__c>();
        
        Liability__c l = new Liability__c(
            Case_Management__c = c.Id,
            Assessment__c = assess.Id,
            Joint_Liability__c = true
        );
        lList.add(l);

        insert lList;
        
        List<Liable_Party__c> lpList = new List<Liable_Party__c>();

        Liable_Party__c lp = new Liable_Party__c(
            Entity__c = a.Id,
            Case_Role__c = cr.Id,
            Liability__c = l.Id,
            Basis_for_Liability__c = 'Joint Liability'
        );
        lpList.add(lp);

        Liable_Party__c lp2 = new Liable_Party__c(
            Entity__c = a.Id,
            Case_Role__c = cr2.Id,
            Liability__c = l.Id,
            Basis_for_Liability__c = 'Joint Liability'
        );
        lpList.add(lp2);

        insert lpList;
        
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(mtg);
        CreateODAController ctrlr = new CreateODAController(sc); 
        
        PageReference pageRef = Page.CreateODA;
        Test.setCurrentPage(pageRef);
        
        ctrlr.oda.Decision_Date__c = date.today();
        
        ctrlr.createODA();//catch errors
        
        ctrlr.selectedRole = ctrlr.caseRoleList[0].getValue();
        
        ctrlr.createODA();
        
        ODAS__c oda = [SELECT Id FROM ODAS__c WHERE Id =: ctrlr.oda.Id];
        
        Liable_Party__c newLP = [SELECT Id, ODA__c FROM Liable_Party__c WHERE Id =: lp.Id];
        
        system.assertEquals(newLP.ODA__c , oda.Id);

        test.stopTest();
        
    }

    static testMethod void testSingleLiability() {

        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1 ];

        Account a = new Account(
            Name = 'name',
            ShippingPostalCode = '234889'
        );
        insert a;
        
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
        
        DIR_Case__c c = new DIR_Case__c(
            Employer__c = a.Id,
            Assigned_Deputy__c = de.Id
        );
        insert c;

        Case_Role__c cr = new Case_Role__c(
            Case__c = c.Id,
            Entity__c = a.Id,
            Role__c = 'Employer'
        );
        insert cr;
 test.startTest();
        Appeal__c appeal = new Appeal__c(
            Status__c = 'New',
            Case__c = c.Id,
            X2810_3_Case__c = 'Yes',
            Citation_Selected__c = true,
            Estimated_Length_of_Hearing_In_Minutes__c = 60
        );
        insert appeal;

        Hearing__c mtg = new Hearing__c(
            Appeal__c = appeal.Id,
            Case__c = c.Id,
            Status__c = 'New',
            Meeting_Start_Date_Time__c = date.today(),
            Meeting_End_Date_Time__c = date.today() + 10
        );
        insert mtg;

        Meeting_Participant__c mp = new Meeting_Participant__c(
            Case__c = c.Id,
            Case_Role__c = cr.Id,
            Meeting__c = mtg.Id
        );
        insert mp;

        Assessments__c assess = new Assessments__c(
            Case_Management__c = c.Id,
            Appeal_Deadline_Selector__c = 'Business Days'
        );
        insert assess;

        DIR_Violation__c viol = new DIR_Violation__c(
            Case__c = c.Id,
            Assessment__c = assess.Id
        );
        insert viol;

        Liability__c l = new Liability__c(
            Case_Management__c = c.Id,
            Assessment__c = assess.Id,
            Joint_Liability__c = false
        );
        insert l;

        Liable_Party__c lp = new Liable_Party__c(
            Entity__c = a.Id,
            Case_Role__c = cr.Id,
            Liability__c = l.Id,
            Basis_for_Liability__c = 'Other'
        );
        insert lp;

       
        
        ApexPages.StandardController sc = new ApexPages.StandardController(mtg);
        CreateODAController ctrlr = new CreateODAController(sc); 
        
        PageReference pageRef = Page.CreateODA;
        Test.setCurrentPage(pageRef);
        
        ctrlr.oda.Decision_Date__c = date.today();
        
        ctrlr.createODA();//catch errors
        
        ctrlr.selectedRole = ctrlr.caseRoleList[0].getValue();
        
        ctrlr.createODA();
        
        ODAS__c oda = [SELECT Id FROM ODAS__c WHERE Id =: ctrlr.oda.Id];
        
        Liable_Party__c newLP = [SELECT Id, ODA__c FROM Liable_Party__c WHERE Id =: lp.Id];
        
        system.assertEquals(newLP.ODA__c , oda.Id);

        test.stopTest();
    }
}