@istest 
private class scheduleHearingTests {


    // Single Record Test
    static testMethod void singleRecordTest() {
    
        // Set up BOFE User 
        List<User> user_list = [Select Id, isActive from User where isActive=True and Profile.Name='BOFE User'];
        User u1 = user_list[0];

    
        // Run as BOFE User 
        System.RunAs(u1){ 
        
            System.debug('Current User: '+UserInfo.getUserName());

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

            Assessments__c assesment = new Assessments__c();
            assesment.Appeal_Deadline_Selector__c = 'Business Days';
            assesment.Appeal_Deadline_Days__c = 15;
            assesment.Case_Management__c = c.Id;
            insert assesment;

            
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
            
/*    
            hearing__c newHearing = new hearing__c();
            newHearing.Appeal__c = appeal1.Id;
            newHearing.Office__c = appeal1.Case__r.BoFE_Office_Location_City__c;
*/            
               

            test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(appeal1);
            ScheduleHearing schedHrg = new ScheduleHearing(sc);      
            
            Appeal__c app = [SELECT Id, Status__c FROM Appeal__c WHERE Id =: appeal1.Id];

            DIR_Case__c  dir = [SELECT Id, Employer__c, Employer__r.Name, Employer__r.Phone FROM DIR_Case__c WHERE Id =: c.Id LIMIT 1];
        
        
            PageReference pageRef = Page.AddAppeal;
            pageRef.getParameters().put('id', String.valueOf(dir.Id));
            Test.setCurrentPage(pageRef);
            
 
            List<ScheduleHearing.CitationWrapper> localList = new List<ScheduleHearing.CitationWrapper>();
                        
            schedHrg.Schedule();
                 
            queryUnavailabilityDates = appeal1.Unavailable_dates__c;
            
            //Validate
            System.assertEquals(queryUnavailabilityDates, testUnavailabilityDates);
                 
            test.stopTest();
           
        }
     } // End of Single Record Test

/*
    // Bulk Record Test    
    static testMethod void bulkRecordTest() {
  

    }

    // Negative Test    
    static testMethod void negativeTest() {
  

    }
*/
    
}