/*************************************************************************************************
Class     :  SchedulePRRollupToCMHackTest.cls
Created   :  Jan 9, 2020
Modified  :  
Objective :  Obvious test class is obvious.

*************************************************************************************************/
@isTest
public class SchedulePRRollupToCMHackTest{
    
    static testmethod void test(){
        SchedulableContext sc;
        SchedulePRRollupToCMHack sprtch = new SchedulePRRollupToCMHack();
        sprtch.execute(sc);
    }
}