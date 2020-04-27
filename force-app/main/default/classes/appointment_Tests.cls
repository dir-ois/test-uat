@isTest
(SeeAllData = true)
public class appointment_Tests {

    static testMethod void appointment_Methods_UnitTest() {
        test.startTest();
        Employee__c emp = new Employee__c();
        emp.First_Name__c = 'Test';
        emp.Last_Name__c = 'Last';
        insert emp;
        
        Position__c p1 = new Position__c();
        p1.Serial_Number__c = '111';
        p1.Manual_Entry__c = false;
        insert p1;
        Contact c1 = new Contact();
        c1.LastName = 'Test';
        insert c1;
        
        Appointment__c a1 = new Appointment__c();
        a1.Position__c = p1.Id;
        a1.Employee_Contact__c = c1.Id;
        a1.Supervisor_Contact__c = c1.Id;
        a1.Start_Date__c = System.today().addDays(-3);
        a1.Employee__c = emp.Id;
        a1.Type__c = 'xyz';
        a1.Hiring_Type__c = 'zyz';
        insert a1;
        
        a1.End_Date__c = System.today();
        a1.Type_of_Separation__c = 'a';
        update a1;
        
        Appointment__c a2 = new Appointment__c();
        a2.Position__c = p1.Id;
        a2.Employee_Contact__c = c1.Id;
        a2.Start_Date__c = System.today().addDays(1);
        a2.End_Date__c = System.today().addDays(2);
        a2.Employee__c = emp.Id;
        a2.Type__c = 'xyz';
        a2.Hiring_Type__c = 'zyz';
        a2.Type_of_Separation__c = 'x';
        insert a2;
        
        Appointment__c a3 = new Appointment__c();
        a3.Position__c = p1.Id;
        a3.Employee_Contact__c = c1.Id;
        a3.Supervisor_Contact__c = c1.Id;
        a3.Start_Date__c = System.today().addDays(3);
        a3.Employee__c = emp.Id;
        a3.Type__c = 'xyz';
        a3.Hiring_Type__c = 'zyz';
        insert a3;
        
        delete new List<Appointment__c>{a1, a2};
        delete a3;
        
        Form_1__c f1 = new Form_1__c();
        insert f1;
        
        Appointment__c a4 = new Appointment__c();
        a4.Form_1__c = f1.Id;
        a4.Position__c = p1.Id;
        a4.Employee_Contact__c = c1.Id;
        a4.Supervisor_Contact__c = c1.Id;
        a4.Start_Date__c = System.today().addDays(5);
        a4.Employee__c = emp.Id;
        a4.Type__c = 'xyz';
        a4.Hiring_Type__c = 'zyz';
        insert a4;
        
        test.stopTest();
    }
}