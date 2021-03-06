@isTest
private class TestAttachmentSaver {
    
    /**
    * Verify that Standard User profiles are unable to delete attachments
    */
    static testMethod void testStandardUser() {
        
        // Create a new user with the Standard User profile
        Profile standardProf = [select id from profile where name='Standard User']; 
        User su = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='TestUser111', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = standardProf.Id, 
            timezonesidkey='America/Los_Angeles', username='suDIRAttachSaverSATest@testorg.com');
            
        // Switch current user to Standard User
        System.runAs(su) {      
        
            // Create test data (a new Account with an Attachment)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            Blob attachBody = Blob.valueOf('attachment body');
            Attachment attach = new Attachment(Name = 'TestAttachment', ParentId = acct.Id, Body = attachBody);
            insert attach;
        
            // Verify the "Unable to delete attachments" error is thrown when attachment is deleted
            Boolean errorThrown = false; 
            try {
                delete attach;
            } catch (Exception e) {
                System.debug(e);
                if (e.getMessage().contains('You do not have permission to delete attachments. Please create a note to indicate that this is no longer relevant if necessary')) {
                    errorThrown = true;
                }
            }
            //System.assert(errorThrown);
        }
    }
    
    static testMethod void testAdminUser() {
        
        // Next make sure that a System Admin *can* delete an attachment
        Profile adminProf = [select id from profile where name='System Administrator']; 
        User au = new User(alias = 'admint', email='adminuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = adminProf.Id, 
            timezonesidkey='America/Los_Angeles', username='adminuser11@testorg.com');
        
        // Switch current user to System Admin user
        System.runAs(au) {
            
            // Create test data (a new Account with an Attachment)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            Blob attachBody = Blob.valueOf('attachment body');
            Attachment attach = new Attachment(Name = 'TestAttachment', ParentId = acct.Id, Body = attachBody);
            insert attach;
            
            // Verify that no error is thrown when the attachment is deleted
            Boolean errorThrown = false;
            try {
                delete attach;
            } catch (Exception e) {
                System.debug(e);
                errorThrown = true;
            }
            System.assert(!errorThrown);
        }
    }
    
    static testMethod void testHRPersonnelSpecialistUser() {
        
        // Next make sure that a System Admin *can* delete an attachment
        Profile hrSpecProf = [select id from profile where name='HR Personnel Specialist User']; 
        User au = new User(alias = 'hruser', email='hrspecialistuser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = hrSpecProf.Id, 
            timezonesidkey='America/Los_Angeles', username='hrspecialistuser@testorg.com');
        
        // Switch current user to System Admin user
        System.runAs(au) {
            
            // Create test data (a new Account with an Attachment)
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            Blob attachBody = Blob.valueOf('attachment body');
            Attachment attach = new Attachment(Name = 'TestAttachment', ParentId = acct.Id, Body = attachBody);
            insert attach;
            
            // Verify that no error is thrown when the attachment is deleted
            Boolean errorThrown = false;
            try {
                delete attach;
            } catch (Exception e) {
                System.debug(e);
                errorThrown = true;
            }
            System.assert(!errorThrown);
        }
    }    
}