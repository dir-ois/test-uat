@isTest(SeeAllData = true) //need set to 'true' so Custom Settings are visible
private class caseViolationActionsTest {
    
    static testMethod void testRollupAndIntCalcs() {

        Id wcaRT = Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId();

        Account a = new Account(
            Name = 'test Account'+system.now()
        );
        insert a;
        
        DIR_Employee__c ma = new DIR_Employee__c(
            User__c = UserInfo.getUserId()
        );
        insert ma; 
        
        DIR_Employee__c de = new DIR_Employee__c(
            User__c = UserInfo.getUserId(),
            Position__c = 'Deputy',
            Manager__c = ma.Id
        );
        insert de; 
        
        DIR_Case__c cm = new DIR_Case__c(
            Assigned_Deputy__c = de.Id,
            Employer__c = a.Id
        );
        insert cm;
        
        Violation_Type__c vt = new Violation_Type__c(
            RecordTypeId = Schema.SObjectType.Violation_Type__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId(),
            Appeal_Deadline_Days__c = 12,
            Active__c = true,
            Appeal_Deadline_Selector__c = 'Business Days',
            Interest_Type__c = '98.1(c)'
        );
        insert vt;
        
        Assessments__c assess = new Assessments__c(
            Case_Management__c = cm.Id
        );
        insert assess;

        Appeal__c appeal = new Appeal__c(
            Status__c = 'New',
            Case__c = cm.Id,
            X2810_3_Case__c = 'Yes',
            Citation_Selected__c = true,
            Estimated_Length_of_Hearing_In_Minutes__c = 60
        );
        insert appeal;
        
        Hearing__c mtg = new Hearing__c(
            Appeal__c = appeal.Id,
            Case__c = cm.Id,
            Status__c = 'New',
            Meeting_Start_Date_Time__c = date.today(),
            Meeting_End_Date_Time__c = date.today() + 10,
            Effective_Date__c = date.today() + 10,
            Imported_From__c = 'test',
            RecordTypeId = Schema.SObjectType.Hearing__c.getRecordTypeInfosByName().get('BOFE Hearing').getRecordTypeId()
        );
        insert mtg;
        

        List<DIR_Violation__c> viols = new List<DIR_Violation__c>();

        DIR_Violation__c vio = new DIR_Violation__c(
            Violation_Type__c = vt.Id,
            Case__c = cm.Id,
            Assessment__c = assess.Id,
            Citation_Amount__c = 2000,
            RecordTypeId = wcaRT,
            Decided_at_Meeting__c = mtg.Id,
            Wages_Due_Date__c = date.today()
        );
        viols.add(vio);

        DIR_Violation__c vio2 = new DIR_Violation__c(
            Violation_Type__c = vt.Id,
            Case__c = cm.Id,
            Assessment__c = assess.Id,
            Citation_Amount__c = 2000,
            RecordTypeId = wcaRT,
            Decided_at_Meeting__c = mtg.Id,
            Wages_Due_Date__c = date.today()
        );
        viols.add(vio2);

        insert viols;

        Interest__c i = new Interest__c(
            Name = 'testRate',
            Object__c = 'DIR_Violation__c',
            Record_Type__c = 'WCA',
            Interest_Rate__c = 10.000000000000
            );

        insert i;

        test.startTest();

        vio.Wages_Due__c = 100;
        vio.Citation_Amount__c = 110;
        vio.Penalty_Payments_Received__c = 120;
        vio.Wage_Payments_Received__c = 130;
        vio.Total_Interest_Amount__c = 0;
        vio.Interest_Payments_Received__c = 150;

        vio2.Wages_Due__c = 200;
        vio2.Citation_Amount__c = 210;
        vio2.Penalty_Payments_Received__c = 220;
        vio2.Wage_Payments_Received__c = 230;
        vio2.Total_Interest_Amount__c = 0;
        vio2.Interest_Payments_Received__c = 250;

        update viols;

        Interest__c interest = Interest__c.getInstance('WCA Violations');
        Decimal interestRate = interest.Interest_Rate__c;

        Assessments__c newAssess = [
                                    SELECT Id, Total_Citation_Penalties_Assessed__c, Total_Citations_Penalties_Paid__c, 
                                           Total_Interest_Assessed__c, Total_Interest_Paid__c, Total_Wages_Assessed__c, Total_Wages_Paid__c 
                                    FROM Assessments__c 
                                    WHERE Id =: assess.Id
                                   ];                            

        system.assertEquals(newAssess.Total_Citation_Penalties_Assessed__c, vio.Citation_Amount__c + vio2.Citation_Amount__c);
        system.assertEquals(newAssess.Total_Citations_Penalties_Paid__c, vio.Penalty_Payments_Received__c + vio2.Penalty_Payments_Received__c);
        system.assertEquals(newAssess.Total_Interest_Assessed__c, vio.Total_Interest_Amount__c + vio2.Total_Interest_Amount__c);
        system.assertEquals(newAssess.Total_Interest_Paid__c, vio.Interest_Payments_Received__c + vio2.Interest_Payments_Received__c);
        system.assertEquals(newAssess.Total_Wages_Assessed__c, vio.Wages_Due__c + vio2.Wages_Due__c);
        system.assertEquals(newAssess.Total_Wages_Paid__c, vio.Wage_Payments_Received__c + vio2.Wage_Payments_Received__c);

        vio.Wages_Due_Date__c = date.today() + 1;
        vio2.Wages_Due_Date__c = date.today() + 1;
        update viols;

        DIR_Violation__c newViol1 = [
                                     SELECT Id, Citation_Amount__c, Meeting_Date__c, Wages_Due_Date__c, Wages_Due__c, Penalty_Payments_Received__c, 
                                            Wage_Payments_Received__c, Total_Interest_Amount__c, Interest_Payments_Received__c 
                                     FROM DIR_Violation__c 
                                     WHERE Id =: vio.Id
                                    ];

        DIR_Violation__c newViol2 = [
                                     SELECT Id, Citation_Amount__c, Meeting_Date__c, Wages_Due_Date__c, Wages_Due__c, Penalty_Payments_Received__c, 
                                            Wage_Payments_Received__c, Total_Interest_Amount__c, Interest_Payments_Received__c 
                                     FROM DIR_Violation__c 
                                     WHERE Id =: vio2.Id
                                    ];

        Decimal intAmt1 = ( (newViol1.Wages_Due__c == null ? 0 : newViol1.Wages_Due__c) * interestRate * 0.01 * math.abs(newViol1.Wages_Due_Date__c.daysBetween(newViol1.Meeting_Date__c)) ) / 365;
        Decimal intAmt2 = ( (newViol2.Wages_Due__c == null ? 0 : newViol2.Wages_Due__c) * interestRate * 0.01 * math.abs(newViol2.Wages_Due_Date__c.daysBetween(newViol2.Meeting_Date__c)) ) / 365;

        system.assertEquals(newViol1.Total_Interest_Amount__c, intAmt1);
        system.assertEquals(newViol2.Total_Interest_Amount__c, intAmt2);

        test.stopTest();
    }
    
}