@isTest
private class TestActivityHistorySaver
{
    
    /**
    * Verify that Standard User profiles are unable to delete tasks in the Activity History
    */
    static testMethod void testStandardUser() 
    {
        
        // Create a new user with the Standard User profile
        Profile standardProf = [select id from profile where name='Standard User']; 
        User su = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestUser111', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = standardProf.Id, 
            timezonesidkey='America/Los_Angeles', username='suDIRAttachSaverSATest@testorg.com');
            
        // Switch current user to Standard User
        System.runAs(su) 
        {      
        
            // Create test data (a new Account with a task)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            
            
        
            Task task = new Task();
            
            task.WhatID = acct.Id;
            task.OwnerID = UserInfo.getUserID();
            task.Type = 'Call';
            task.Subject = 'Test';
            task.ActivityDate = date.today();
            task.Description = 'Testing';
            task.Priority = 'Normal';
            
            insert task;
            
            Boolean errorThrown = false; 
            
            try {
                  delete task;
                } 
            catch (Exception e) 
            {
                System.debug(e);
                if (e.getMessage().contains('You do not have permission to delete tasks in Activity History.')) 
                {
                    errorThrown = true;
                }
            }
            
           
       }
   }
   
   static testMethod void testAdminUser() {
        
        // Next make sure that a System Admin *can* delete a task in Activity History
        Profile adminProf = [select id from profile where name='System Administrator']; 
        User au = new User(alias = 'admint', email='adminuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = adminProf.Id, 
            timezonesidkey='America/Los_Angeles', username='adminuser11@testorg.com');
        
        // Switch current user to System Admin user
        System.runAs(au) {
            
            // Create test data (a new Account with a task for Activity History)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
     
      Task task = new Task();
            
            task.WhatID = acct.Id;
            task.OwnerID = UserInfo.getUserID();
            task.Type = 'Call';
            task.Subject = 'Test';
            task.ActivityDate = date.today();
            task.Description = 'Testing';
            task.Priority = 'Normal';
            
            insert task;
            
            Boolean errorThrown = false; 
     
            // Verify that no error is thrown when the task is deleted in Activity History
       
            
            try {
                  delete task;
                } 
            catch (Exception e) 
            {
                System.debug(e);
                if (e.getMessage().contains('You do not have permission to delete tasks in Activity History.')) 
                {
                    errorThrown = true;
                }
                System.assert(!errorThrown);
            }
            
        }
    }
}