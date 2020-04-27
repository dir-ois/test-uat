@istest (SeeAllData=true)
public class exportRegDetailsControllerTest {

    public static testMethod void testExportRegDetailsController(){

        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       
        account a = new Account(
          RecordTypeID=personAccountRTId,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678'
        );
        insert a;
               
        system.debug('##### A: ' + a);
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(contactId = acc.PersonContactId, Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p, isActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert u;
        system.debug('##### u: ' + u);
        
        List<User> communityUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ProfileId =: p AND isActive = true LIMIT 1];
        system.debug('##### CommunityUser: ' + communityUser);
        
        Id publicWorksRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Public Works').getRecordTypeId();
        
        License_Registration__c  newLR2 = new License_Registration__c();
        newLR2.Account__c = communityUser[0].Contact.AccountId;
        newLR2.RecordTypeId = publicWorksRecordTypeId;
        newLR2.License_Registration_Number__c = '222';
        newLR2.License_Registration_Type__c = 'Public Works';
        newLR2.Status__c = 'Incomplete'; 
        newLR2.Expiration_Date__c = Date.today() - 365; 
        newLR2.Amount_Paid__c = 100; 
        newLR2.Applicant__c = communityUser[0].ContactId;
        newLR2.License_Registration_Type__c = 'Public Works';
        newLR2.Boilermaker_Blacksmith__c = true;
        newLR2.Bricklayer_Brick_Tender__c = true;
        newLR2.Carpet_Linoleum_Resilient_Tile_Layer__c = true;
        newLR2.Drywall_Installer_Lather_Finisher__c = true;
        newLR2.Electrician__c = true;
        newLR2.Field_Surveyor__c = true;
        newLR2.Glazier__c = true;
        newLR2.Marble_Mason_Finisher__c = true;
        newLR2.Painter__c = true;
        newLR2.Plasterer_Tender__c = true;
        
        newLR2.Plumber__c = true;
        newLR2.Roofing__c = true;
        newLR2.Sheet_Metal_Worker__c = true;
        newLR2.Terrazzo_Worker_Finisher__c = true;
        newLR2.Tile_Setter_Finisher__c = true;  
        newLR2.Water_Well_Drinker__c = true;
        newLR2.Iron_Worker__c = true;
        newLR2.Electrical_Utility__c = true;
        newLR2.Landscape__c = true;
        newLR2.Stator_Rewinder__c = true;   
        newLR2.Driver_On_Off_Hauling__c = true;
        newLR2.Teamster__c = true;
        newLR2.Abestos__c = true;
        newLR2.Inspector_Field_Soils_Material_Tester__c = true;
        newLR2.Carpenter__c = true;      
        
        newLR2.Cement_Mason__c = true;   
        newLR2.Elevator_Constructor__c = true;
        newLR2.Laborer__c = true;
        newLR2.Parking_Highway_Improvement__c = true;
        newLR2.Operating_Engineer__c= true;
        
        newLR2.General_Engineering__c = true;
        newLR2.General_Building__c = true;
        
        insert newLR2;
        system.debug('##### newLR2: ' + newLR2);  

        
        apexpages.currentpage().getparameters().put('myList',newLR2.id);
        exportRegDetailsController reg =  new exportRegDetailsController();

    }
    
}