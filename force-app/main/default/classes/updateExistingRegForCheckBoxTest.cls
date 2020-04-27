@istest
public class updateExistingRegForCheckBoxTest {
      public static testMethod void testupdateExistingRegForCheckBox(){
        
        VIPForm__VIP_Template__c temp = new VIPForm__VIP_Template__c();
        temp.Name = 'Registration Services';
        temp.VIPForm__Object_Record_Type__c = 'Car Wash';
        //temp.VIPForm__Form_Style__c = 'Vertical Navigation';
        insert temp;       
        
        
        VIPForm__VIP_Category__c section = new VIPForm__VIP_Category__c();
        section.VIPForm__Name_Displayed__c = 'WCI Documentation - External';
        section.Name = 'WCI Documentation - External';
        section.VIPForm__Object_API__c = 'License_Registration__c';
        section.VIPForm__Order__c = 300;
        section.VIPForm__Template__c = temp.id;
        section.RecordtypeId = Schema.SObjectType.VIPForm__VIP_Category__c.getRecordTypeInfosByName().get('VIP Form Section').getRecordTypeId();
        insert section;
        
        Account a = new Account();
        a.Name = 'test account'+system.now();
        insert a;
        
        Contact con = new Contact();
        con.AccountId = a.id;
        con.LastName = 'lastName';
        insert con;
        
        License_Registration__c lr = new License_Registration__c();
        lr.Account__c = a.id;
        lr.Applicant__c = con.id;
        lr.RecordtypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId();
        insert lr;
        
        Attachments_Plus__c attPlus = new Attachments_Plus__c(
        Attachment_Name__c = 'test att name', 
        Registration__c = lr.id,
        Description__c = 'test desc', 
        Type__c = '', 
        Attorney_Client_Privilege__c = true, 
        Confidential__c = true, 
        Not_Subject_to_PRA__c = true,
        VIP_Form_Section__c = section.id,
        Attachment_Required__c = true
        );
        insert attPlus;
                
        test.startTest();
            updateExistingRegForCheckBox obj = new updateExistingRegForCheckBox ();
            DataBase.executeBatch(obj);
        test.stopTest();
    }
}