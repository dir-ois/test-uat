@istest
public class RegistrationDetailsTest {

    public static testMethod void testRegistrationDetails(){
    
        Account a = new Account();
        a.Name = 'test account'+system.now();
        insert a;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.Email = 'testLNRDEV@testdir.com';
        insert con;
        
        DIR_Employee__c ma = new DIR_Employee__c();
        ma.User__c = UserInfo.getUserId();
        insert ma;
        
        Id devRecordTypeId = Schema.getGlobalDescribe().get('License_Registration__c').getDescribe().getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();

        License_Registration__c lreg = new License_Registration__c();
        lreg.RecordTypeId = devRecordTypeId;
        lreg.Account__c = a.Id;
        lreg.Applicant__c = con.Id;
        lreg.License_Registration_Number__c = '00023568500';
        insert lreg; 
        
        DIR_Employee__c de = new DIR_Employee__c();
        de.User__c = UserInfo.getUserId();
        de.Position__c = 'Deputy';
        de.Manager__c = ma.Id;
        insert de;
        
        DIR_Case__c cm = new DIR_Case__c();
        cm.Employer__c = a.Id;
        cm.Status__c = 'Open';
        cm.Assigned_Deputy__c = de.Id;
        cm.RecordtypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
        insert cm;

        Attachment att = new Attachment(
          Body = blob.valueOf('test body'),
          Name = 'test name',
          isPrivate = false,
          ParentId = cm.Id
        );
        insert att;
    
        Attachments_Plus__c attPlus = new Attachments_Plus__c(
          Attachment_ID__c = att.Id, 
          Attachment_Name__c = 'test att name', 
          //Attachment_URL__c, 
          Description__c = 'test desc', 
          //Object__c, 
          Record_ID__c = cm.Id,
          Registration__c = lreg.Id,
          Registration_Document_Category__c = 'Education', 
          Type__c = '', 
          Attorney_Client_Privilege__c = true, 
          Confidential__c = true, 
          Not_Subject_to_PRA__c = true
        );
        insert attPlus;

        

        Attachments_Plus__c attPlus1 = new Attachments_Plus__c(
          Attachment_ID__c = att.Id, 
          Attachment_Name__c = 'test att name', 
          //Attachment_URL__c, 
          Description__c = 'test desc', 
          //Object__c, 
          Record_ID__c = cm.Id, 
          Registration__c = lreg.Id,
          Registration_Document_Category__c = 'Education', 
          Type__c = 'Unknown', 
          Attorney_Client_Privilege__c = true, 
          Confidential__c = true, 
          Not_Subject_to_PRA__c = true
        );
        insert attPlus1;
         
       
        Attachments_Plus__c attPlus2 = new Attachments_Plus__c(
          Attachment_ID__c = att.Id, 
          Attachment_Name__c = 'test att name', 
          //Attachment_URL__c, 
          Description__c = 'test desc', 
          //Object__c, 
          Record_ID__c = cm.Id,
          Registration__c = lreg.Id,
          Registration_Document_Category__c = 'Education',  
          Type__c = 'Subpoena', 
          Attorney_Client_Privilege__c = true, 
          Confidential__c = true, 
          Not_Subject_to_PRA__c = true
        );

        test.startTest();

        pageReference pageRef = Page.RegistrationDetails;
        system.Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', lreg.Id);
        
        //ApexPages.StandardController sc = new ApexPages.StandardController(lreg);
       // RegistrationDetailsController  controller = new RegistrationDetailsController (sc);
       
         RegistrationDetailsController  controller = new RegistrationDetailsController ();
        
        controller.getBonds();
        controller.getRegistrationLocation();
        //controller.getRegistrationDBAs();
        
        
    }
}