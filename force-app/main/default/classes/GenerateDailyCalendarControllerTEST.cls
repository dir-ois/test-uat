@isTest(SeeAllData=false)
private class GenerateDailyCalendarControllerTEST {

    static testMethod void testSetURL() {
        Office__c office = new Office__c();
        insert office;
        
        test.startTest();
        
        GenerateDailyCalendarController controller = new GenerateDailyCalendarController();
        controller.hearing.Meeting_Start_Date_Time__c = date.today() - 30;
        controller.hearing.Meeting_End_Date_Time__c = date.today();
        controller.hearing.WCA_Office__c = office.Id;
        controller.setURL();
        
        test.stopTest();
    }
}