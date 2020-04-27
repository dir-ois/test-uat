/*************************************************************************************************
Class     :  ScheduleCreateOAMTRecordsTest.cls
Created   :  July 30, 2019
Modified  :  
Objective :  Obvious test class is obvious.

*************************************************************************************************/
@isTest
public class ScheduleCreateOAMTRecordsTest{
    
    static testmethod void test(){
        SchedulableContext sc;
        ScheduleCreateOAMTRecords scoamtr = new ScheduleCreateOAMTRecords();
        scoamtr.execute(sc);
    }
}