@isTest
public with sharing class InspectionsTest {
    
    public static testMethod void TestInspections1() {
        User ADMIN_USER = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1 ];
        
        DIR_Employee__c mgr = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id
        );
        insert mgr;
        
        DIR_Employee__c de = new DIR_Employee__c(
            Active__c = true,
            User__c = ADMIN_USER.Id,
            Manager__c = mgr.Id
        );
        insert de;
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        Affiliation__c aff = new Affiliation__c();
        aff.Affiliated_Account__c = acc.Id;
        aff.Main_Account__c = acc.Id;
        insert aff;

        DIR_Case__c c = new DIR_Case__c();
        c.Employer__c = acc.Id;
        c.Assigned_Deputy__c = de.Id;
        insert c;
        
        DIR_Inspection__c inspection = new DIR_Inspection__c();
        inspection.DIR_Case__c = c.Id;
        insert inspection;
        
        /*
         Survey__c survey = new Survey__c();
        survey.Functional_Area__c = 'Field Service';
        survey.Industry__c = 'Consulting';
        survey.Submit_Response__c = 'Blah blah';
        insert survey;
        
        
        Inspection__c insp = new Inspection__c();
        insp.Case_Management__c = c.Id;
        insp.Inspection_Template__c = survey.Id;
        insp.Inspection_Type__c = 'Fire Suppression';
        insp.Region__c = 'SE';
        insert insp;
        
        
        Category__c categ = new Category__c();
        categ.Name = 'TestCateg';
        categ.Order__c = 1;
        insert categ;
        
        
        Category_Button__c cb = new Category_Button__c();
        cb.Category__c = categ.Id;
        cb.Button_Label__c = 'testBtt';
        insert cb;

        Template_Category__c tc = new Template_Category__c();
        tc.Category__c = categ.Id;
        tc.Survey__c = survey.Id;
        insert tc;

        SubCategory__c sc1 = new SubCategory__c();
        sc1.Name = 'TestSubCateg';
        sc1.Category__c = categ.Id;
        sc1.Order__c = 1;
        insert sc1;
        
        Template_SubCategory__c tsc = new Template_SubCategory__c();
        tsc.Survey__c = survey.Id;
        tsc.SubCategory__c = sc1.Id;
        insert tsc;

        Category_Complete__c cc = new Category_Complete__c();
        cc.Category__c = categ.Id;
        cc.Inspection__c = insp.Id;
        cc.Completion_Date__c = Date.today();
        insert cc;
        
        Survey_Question__c sq1 = new Survey_Question__c();
        sq1.Name = 'question1';
        sq1.Question__c = 'data';
        sq1.Type__c = 'text';
        sq1.Choices__c = null;
        sq1.SubCategory__c = sc1.Id;
        sq1.OrderNumber__c = 1;
        sq1.Category__c = categ.Id;
        sq1.Survey__c = survey.Id;
        insert sq1;
        
        SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
        sqr.Inspection__c = insp.Id;
        sqr.Survey_Question__c = sq1.Id;
        sqr.Response__c = 'response text';
        insert sqr;
        */
        
        Inspection_Questions__c iq1 = new Inspection_Questions__c();
        iq1.Inspection_Section__c = 'Wage Information';
        iq1.Active__c = true;
        iq1.Response_Type__c = 'Text';
        iq1.Response_Options__c = '';
        iq1.Source_Data__c = 'Employer_Pay_Day__c';
        iq1.Update_Parent_Record__c = false;
        iq1.Inspection_Question__c = 'Pay Day';
        iq1.Sort_Order__c = 1;
        insert iq1;
        
        Inspection_Questions__c iq2 = new Inspection_Questions__c();
        iq2.Inspection_Section__c = 'Worker\'s Compensation Insurance Information';
        iq2.Active__c = true;
        iq2.Response_Type__c = 'Number';
        iq2.Response_Options__c = '';
        iq2.Source_Data__c = 'Employer_Pay_Day__c';
        iq2.Update_Parent_Record__c = false;
        iq2.Inspection_Question__c = 'Pay Day';
        iq2.Sort_Order__c = 1;
        insert iq2;
        
        Inspection_Questions__c iq3 = new Inspection_Questions__c();
        iq3.Inspection_Section__c = 'IWC Order';
        iq3.Active__c = true;
        iq3.Response_Type__c = 'Checkbox';
        iq3.Response_Options__c = '';
        iq3.Source_Data__c = 'Employer_Pay_Day__c';
        iq3.Update_Parent_Record__c = false;
        iq3.Inspection_Question__c = 'Pay Day';
        iq3.Sort_Order__c = 1;
        insert iq3;
        
        
        
        PageReference pageRef = Page.Inspections;
        pageRef.getParameters().put('CaseID', String.valueOf(c.Id));
        Test.setCurrentPage(pageRef);
        //ApexPages.StandardController sc = new ApexPages.StandardController(insp);
        Inspections ip = new Inspections();
        ip.getstatusValue();
        ip.gettypeValue();
        //ip.getStatusItems();
        ip.gettypeItems();   
        ip.save();
        ip.cancel();  
    }
}