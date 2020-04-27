/*************************************************************************************************
Class     :  ScheduleCoHReportsTest.cls
Created   :  Mar 9, 2020
Modified  :  
Objective :  Obvious test class is obvious.

*************************************************************************************************/
@isTest
public class ScheduleCoHReportsTest{
    
    static testmethod void test(){
        SchedulableContext sc;
        ScheduleCoHReports scr = new ScheduleCoHReports();
        scr.execute(sc);
    }
}