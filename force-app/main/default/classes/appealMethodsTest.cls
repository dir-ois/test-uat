/**
*
* @author       Daniel Chu
* @created      2018-10-25
* @description  This class tests the tasks pertaining to the operation of creating a new or updating an appeal. Related class is appealMethods. 
* 
**/

@istest
private class appealMethodsTest {

    // Single Record Test
    static testMethod void singleRecordTest() {
    
        // Set up BOFE User 
        List<User> user_list = [Select Id, isActive from User where isActive=True and Profile.Name='BOFE User'];
        User u1 = user_list[0];

    
        // Run as BOFE User 
        System.RunAs(u1){ 
        
            //System.debug('Current User: '+UserInfo.getUserName()); //For debugging
 
            final date requestCitationAppHrDate = date.newInstance(2017, 7, 1);
            final String testUnavailabilityDates = 'No Hearings on Tuesdays.';
            String queryUnavailabilityDates;
            
            Account acc = new Account();
            acc.Name = 'New Account Name';
            insert acc;
            
            Affiliation__c aff = new Affiliation__c();
            aff.Affiliated_Account__c = acc.Id;
            aff.Main_Account__c = acc.Id;
            insert aff;
            
            DIR_Case__c c = new DIR_Case__c();
            c.Employer__c = acc.Id;
            insert c;

            
            Appeal__c appeal1 = new Appeal__c();
            appeal1.Status__c = 'New';
            appeal1.Case__c = c.Id;
            appeal1.Estimated_Length_of_Hearing_In_Minutes__c = 60;
            appeal1.Request_Receipt_Date__c = requestCitationAppHrDate;
            appeal1.Unavailable_dates__c = testUnavailabilityDates;
            Id BOFERecordTypeId = Schema.SObjectType.Appeal__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
            appeal1.recordtypeID = BOFERecordTypeID;
            appeal1.X2810_3_Case__c = 'Yes';
            appeal1.Citation_Selected__c = true;
            insert appeal1;

            Appeal__c appeal2 = new Appeal__c();
            appeal2.Status__c = 'New';
            appeal2.Case__c = c.Id;
            appeal2.Estimated_Length_of_Hearing_In_Minutes__c = 60;
            appeal2.Request_Receipt_Date__c = requestCitationAppHrDate;
            appeal2.Unavailable_dates__c = testUnavailabilityDates;
            appeal2.recordtypeID = BOFERecordTypeID;
            appeal2.X2810_3_Case__c = 'Yes';
            appeal2.Citation_Selected__c = true;
            insert appeal2;

            Appeal__c appeal3 = new Appeal__c();
            appeal3.Status__c = 'New';
            appeal3.Case__c = c.Id;
            appeal3.Estimated_Length_of_Hearing_In_Minutes__c = 60;
            appeal3.Request_Receipt_Date__c = requestCitationAppHrDate;
            appeal3.Unavailable_dates__c = testUnavailabilityDates;
            appeal3.recordtypeID = BOFERecordTypeID;
            appeal3.X2810_3_Case__c = 'Yes';
            appeal3.Citation_Selected__c = true;
            insert appeal3;

            Assessments__c assesment = new Assessments__c();
            assesment.Appeal_Deadline_Selector__c = 'Business Days';
            assesment.Appeal_Deadline_Days__c = 15;
            assesment.Case_Management__c = c.Id;
            insert assesment;

            DIR_Violation__c ci = new DIR_Violation__c();
            ci.Case__c = c.Id;
            insert ci;

            Liability__c liability1 = new Liability__c();
            liability1.Assessment__c = assesment.Id;
            liability1.Case_Management__c = c.Id;
            liability1.Status__c = 'new';
            liability1.Appeal_Deadline__c = Date.today();
            insert liability1;

            Liability_Appeal__c la = new Liability_Appeal__c();
            la.Appeal__c = appeal1.Id;
            la.Liability__c = liability1.Id;
            insert la;
        
            Liable_Party__c lp = new Liable_Party__c();
            lp.Liability__c = liability1.Id;
            lp.Entity__c = acc.id;
            
            Appealed_Violation__c appVio1 = new Appealed_Violation__c();
            appVio1.Case_Violation__c = ci.Id;
            appVio1.Liability_Appeal__c = la.Id;
            insert appVio1;           

            
          
               

            test.startTest();
 
                         
            appeal1.Status__c = 'Received';
            update appeal1;
            
            appeal1.Status__c = 'Withdrawn';
            update appeal1;
            
            appeal2.Status__c = 'Withdrawn';
            update appeal2;

            appeal3.Status__c = 'Received - Timely';
            update appeal3;

            appeal3.Status__c = 'Under Appeal';
            update appeal3;

            //Validate
            System.assertEquals(appeal2.Status__c, 'Withdrawn');   
         
                 
            test.stopTest();

           
        }
     } // End of Single Record Test


/*
    //Work in progress. This test class is incomplete without bulk record test and negative test. 

    // Bulk Record Test    
    static testMethod void bulkRecordTest() {
    
    }

    // Negative Test    
    static testMethod void negativeTest() {

    }
*/

}