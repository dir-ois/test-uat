// CSK - 4/10 - Did my best to update this class 
// Based on my understanding the logic has 4 major scenarios
// Create an affiliation b/t 
// 1. A Person Account and Person Account
// 2. A Person Account and an Account
// 3. An Account and a Person Account
// 4. A Person Account and and Account 
// There is also some logic to associate plain old contacts but doesn't seem to be used 


@isTest
public with sharing class ABTActViewExtensionTest {
    
    
    public static testMethod void TestABTActViewExtension1a() {

        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Affiliation__c newAff = new Affiliation__c();
        newAff.Affiliated_Account__c = acc.Id;
        newAff.Affiliated_Contact__c = con.Id;
        newAff.Name = 'New Aff';
        insert newAff;
        
        Affiliation_Pair__c newAffPair = new Affiliation_Pair__c();
        newAffPair.Name = 'Accountant';
        newAffPair.Relationship__c = 'Accounting Client';
        insert newAffPair;
        
        PageReference pageRef = Page.Affiliations;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);
        
        ABTView.accountName = 'Acc Name';
        ABTView.firstName = 'ContactFN';
        ABTView.lastName = 'ContactLN';
        ABTView.isPersonAccount = true;
        ABTView.firstNameInd = 'fName';
        ABTView.lastNameInd = 'lName';
        ABTView.emailInd = 'lName@email.com';
        ABTView.phoneInd = '2223334444';
        ABTView.titleInd = 'Mr';
        ABTView.newContact.AccountId = acc.Id;
        ABTView.affPair = 'Accountant';
        ABTView.affType = 'Look up Existing C/P';
        ABTView.type = 'Account';
        ABTView.aff1 = newAff;
        
        
        ABTView.createSearchAffNew();
        
    }
    
    public static testMethod void TestABTActViewExtension1b() {

        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
         
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Affiliation__c newAff = new Affiliation__c();
        newAff.Affiliated_Account__c = acc.Id;
        newAff.Affiliated_Contact__c = con.Id;
        newAff.Name = 'New Aff';
        insert newAff;
        
        Affiliation_Pair__c newAffPair = new Affiliation_Pair__c();
        newAffPair.Name = 'Accountant';
        newAffPair.Relationship__c = 'Accounting Client';
        insert newAffPair;
        
        PageReference pageRef = Page.Affiliations;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);
        
        ABTView.accountName = 'Acc Name';
        ABTView.firstName = 'ContactFN';
        ABTView.lastName = 'ContactLN';
        ABTView.isPersonAccount = true;
        ABTView.firstNameInd = 'fName';
        ABTView.lastNameInd = 'lName';
        ABTView.emailInd = 'lName@email.com';
        ABTView.phoneInd = '2223334444';
        ABTView.titleInd = 'Mr';
        ABTView.newContact.AccountId = acc.Id;
        ABTView.affPair = 'Accountant';
        ABTView.affType = 'Create New Account';
        ABTView.type = 'Account';
        ABTView.aff1 = newAff; 
               
        ABTView.getAccOrContItems();
        ABTView.getItems();
        ABTView.getAffs();
        ABTView.getPairs();
        ABTView.getTypes();

        ABTView.createIndNew();
        
    }
    
    public static testMethod void TestABTActViewExtension1c() {
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
         
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Affiliation__c newAff = new Affiliation__c();
        newAff.Affiliated_Account__c = acc.Id;
        newAff.Affiliated_Contact__c = con.Id;
        newAff.Name = 'New Aff';
        insert newAff;
        
        Affiliation_Pair__c newAffPair = new Affiliation_Pair__c();
        newAffPair.Name = 'Accountant';
        newAffPair.Relationship__c = 'Accounting Client';
        insert newAffPair;
        
        PageReference pageRef = Page.Affiliations;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);
        
        ABTView.accountName = 'Acc Name';
        ABTView.firstName = 'ContactFN';
        ABTView.lastName = 'ContactLN';
        ABTView.isPersonAccount = true;
        ABTView.firstNameInd = 'fName';
        ABTView.lastNameInd = 'lName';
        ABTView.emailInd = 'lName@email.com';
        ABTView.phoneInd = '2223334444';
        ABTView.titleInd = 'Mr';
        ABTView.newContact.AccountId = acc.Id;
        ABTView.affPair = 'Accountant';
        ABTView.affType = 'Create New Account';
        ABTView.type = 'Account';
        ABTView.aff1 = newAff;
        
        
        ABTView.getAccOrContItems();
        ABTView.getItems();
        ABTView.createBusNew();
        ABTView.getAffs();
        ABTView.getPairs();
        ABTView.getTypes();

        
    }
    
    public static testMethod void TestABTActViewExtension2() {
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Affiliation__c newAff = new Affiliation__c();
        newAff.Affiliated_Account__c = acc.Id;
        newAff.Affiliated_Contact__c = con.Id;
        newAff.Name = 'New Aff';
        insert newAff;
        
        Affiliation_Pair__c newAffPair = new Affiliation_Pair__c();
        newAffPair.Name = 'Accountant';
        newAffPair.Relationship__c = 'Accounting Client';
        insert newAffPair;
        
        PageReference pageRef = Page.Affiliations;
        pageRef.getParameters().put('id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);
        
        ABTView.accountName = 'Acc Name';
        ABTView.firstName = 'ContactFN';
        ABTView.lastName = 'ContactLN';
        ABTView.isPersonAccount = true;
        ABTView.firstNameInd = 'fName';
        ABTView.lastNameInd = 'lName';
        ABTView.emailInd = 'lName@email.com';
        ABTView.phoneInd = '2223334444';
        ABTView.titleInd = 'Mr';
        ABTView.newContact.AccountId = acc.Id;
        ABTView.affPair = 'Accountant';
        ABTView.affType = 'Business Account';
        ABTView.type = 'Account';
        
        ABTView.aff1 = newAff;
        ABTView.createIndNew();
        ABTView.createBusNew(); 
        ABTView.createSearchAffNew();
    }
    
    
    public static testMethod void TestABTActViewExtension3() {
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;
        
        Affiliation__c newAff = new Affiliation__c();
        newAff.Affiliated_Account__c = acc.Id;
        newAff.Affiliated_Contact__c = con.Id;
        newAff.Name = 'New Aff';
        insert newAff;
        
        Affiliation_Pair__c newAffPair = new Affiliation_Pair__c();
        newAffPair.Name = 'Accountant';
        newAffPair.Relationship__c = 'Accounting Client';
        insert newAffPair;
        
        PageReference pageRef = Page.Affiliations;
        pageRef.getParameters().put('id', String.valueOf(con.Id));
        pageRef.getParameters().put('affid', String.valueOf(newAff.Id));
        
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);

        
        ABTView.getAccOrContItems();
        ABTView.getItems();
        ABTView.getAffs();
        ABTView.getPairs();
        ABTView.getTypes();
        ABTView.typeSelect();
        ABTView.deleteAff();
        ABTView.doNothing();

    }



      public static testMethod void TestcreateIndNew1() {
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
        
        // Create Account
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;

        
        
        // Create Affiliation Pair 
        //Affiliation_Pair__c newAffPair = new Affiliation_Pair__c();
        //newAffPair.Name = 'Accountant';
        //newAffPair.Relationship__c = 'Accounting Client';
        //insert newAffPair;
        
        // Load Page with Contact ID
        PageReference pageRef = Page.Affiliations;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        
        // Set Values of Standard Controller
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);

        ABTView.affPair='Accountant';
        ABTView.newContact.firstName='Test FName';
        ABTView.newContact.Email='test@yahoo.com';
        ABTView.newContact.Title='Accountant';
        ABTView.newContact.lastName='Test LName';
        ABTView.newContact.Phone='12345678';        
        
        ABTView.accountName = 'Acc Name';
        ABTView.firstName = 'ContactFN';
        ABTView.lastName = 'ContactLN';
        ABTView.isPersonAccount = true;
        ABTView.firstNameInd = 'fName';
        ABTView.lastNameInd = 'lName';
        ABTView.emailInd = 'lName@email.com';
        ABTView.phoneInd = '2223334444';
        ABTView.titleInd = 'Mr';
        ABTView.newContact.AccountId = acc.Id;
        ABTView.affPair = 'Accountant';
        ABTView.affType = 'Business Account';
        ABTView.type = 'Account';
        
        //ABTView.aff1 = newAff;
        
        // Execute Method to Create New Contact 
        ABTView.createIndNew();
    } 




     public static testMethod void TestcreateSearchAffNew1() {
        
        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Business Account'].id;
        
        // Create Account
        Account acc = new Account();
        acc.Name = 'name';
        acc.RecordTypeId = rtid;
        acc.ShippingPostalCode = '234889';
        insert acc;

        
        
        // Create Affiliation Pair 
        Affiliation_Pair__c newAffPair = new Affiliation_Pair__c();
        newAffPair.Name = 'Accountant';
        newAffPair.Relationship__c = 'Accounting Client';
        insert newAffPair;
        
        // Load Page with Contact ID
        PageReference pageRef = Page.Affiliations;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        
        // Set Values of Standard Controller
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);

//        ABTView.affPair='Accountant';
        ABTView.newContact.firstName='Test FName';
        ABTView.newContact.Email='test@yahoo.com';
        ABTView.newContact.Title='Accountant';
        ABTView.newContact.lastName='Test LName';
        ABTView.newContact.Phone='12345678';        
        
        ABTView.accountName = 'Acc Name';
        ABTView.firstName = 'ContactFN';
        ABTView.lastName = 'ContactLN';
        ABTView.isPersonAccount = true;
        ABTView.firstNameInd = 'fName';
        ABTView.lastNameInd = 'lName';
        ABTView.emailInd = 'lName@email.com';
        ABTView.phoneInd = '2223334444';
        ABTView.titleInd = 'Mr';
        ABTView.newContact.AccountId = acc.Id;
        
        ABTView.affType = 'Business Account';
        ABTView.type = 'Account';

        //
        
        ABTView.affPair = newAffPair.Id;

        //ABTView.aff1 = newAff;
        
        // Execute Method to Create New Contact 
        ABTView.createIndNew();
    } 

    public static testMethod void TestgetaffType() {


        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name = 'Person Account'].id;

                // Create Account
        Account acc = new Account();
        acc.FirstName='Test FName';
        acc.LastName='Test LName';
        acc.PersonMailingStreet='test@yahoo.com';
        acc.PersonMailingPostalCode='12345';
        acc.PersonMailingCity='SFO';
        acc.PersonEmail='test@yahoo.com';
        acc.PersonHomePhone='1234567';
        acc.PersonMobilePhone='12345678' ;

        acc.RecordTypeId = rtid;
        insert acc;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        
        ABTActViewExtension ABTView = new ABTActViewExtension(sc);

           ABTView.accountName = 'Acc Name';
        ABTView.firstName = 'ContactFN';
        ABTView.lastName = 'ContactLN';
        ABTView.isPersonAccount = true;
        ABTView.firstNameInd = 'fName';
        ABTView.lastNameInd = 'lName';
        ABTView.emailInd = 'lName@email.com';
        ABTView.phoneInd = '2223334444';
        ABTView.titleInd = 'Mr';
        ABTView.newContact.AccountId = acc.Id;
        ABTView.affPair = 'Accountant';
        ABTView.affType = 'Business Account';
        ABTView.type = 'Contact';      
        ABTView.getaffType();
        ABTView.setaffType('test');
         ABTView.createIndNew();
        
        ABTView.rtype = 'Person Account';

        ABTView.createBusNew();

        Contact con = new Contact();
        con.LastName = 'Test';
        insert con;

        Affiliation__c newAff = new Affiliation__c();
        newAff.Affiliated_Account__c = acc.Id;
        newAff.Affiliated_Contact__c = con.Id;
        newAff.Name = 'New Aff';
        insert newAff;        

        ABTView.aff1 = newAff; 

        ABTView.createSearchAffNew();
    }

   

     
    
    
}