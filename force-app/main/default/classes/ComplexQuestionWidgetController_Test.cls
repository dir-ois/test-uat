@isTest
private class ComplexQuestionWidgetController_Test{
    static testmethod void testPrimaryQuestion(){
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
        
        Question_Bank__c qb = new Question_Bank__c();
        qb.Answer_Type__c = 'Picklist';
        qb.Button_Text__c = 'Button';
        qb.Question_Text__c = 'Questions';
        //qb.Controlling_Question__c
        qb.Disqualified_Answer__c = 'Yes';
        qb.Follow_up_Criteria__c = 'Yes';
        qb.Picklist_Values__c = 'yes,No';
        qb.Registration_Type__c = 'Car Wash';
        qb.Short_Text__c = 'short text';
        insert qb; 
        
        Question_Bank__c qb1 = new Question_Bank__c();
        qb1.RecordtypeId = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByName().get('Simple').getRecordTypeId();
        qb1.Answer_Type__c = 'Text';
        qb1.Button_Text__c = 'Button';
        qb1.Question_Text__c = 'Questions';
        //qb.Controlling_Question__c
        qb1.Disqualified_Answer__c = 'Yes';
        qb1.Follow_up_Criteria__c = 'Blue';
        //qb1.Picklist_Values__c = 'yes,No';
        qb1.Registration_Type__c = 'Car Wash';
        qb1.Short_Text__c = 'short text';
        insert qb1; 
        
        Question_Bank__c qb2 = new Question_Bank__c();
        qb2.RecordtypeId = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByName().get('Complex').getRecordTypeId();
        //qb2.Answer_Type__c = 'Text';
        qb2.Button_Text__c = 'Button';
        qb2.Question_Text__c = 'Questions';
        //qb.Controlling_Question__c
        qb2.Disqualified_Answer__c = 'Yes';
        qb2.Follow_up_Criteria__c = 'Blue';
        //qb1.Picklist_Values__c = 'yes,No';
        qb2.Registration_Type__c = 'Car Wash';
        qb2.Short_Text__c = 'short text';
        insert qb2; 
        
        Registration_Question__c rq = new Registration_Question__c();
        rq.Question_ID__c = qb.id;
        rq.Registration_ID__c = lr.id;
        rq.RecordTypeId = Schema.SObjectType.Registration_Question__c.getRecordTypeInfosByName().get('Text').getRecordTypeId();
        rq.Question_Text__c = 'Test Question';
        rq.Sort_Order__c = 10;
        insert rq;
        
        Follow_Up_Question__c fq = new Follow_Up_Question__c();
        fq.Question_ID__c = qb1.id;
        fq.Registration_Question_ID__c = lr.id;
        insert fq;
        
        Follow_Up_Question__c fq1 = new Follow_Up_Question__c();
        fq1.Question_ID__c = qb2.id;
        fq1.Registration_Question_ID__c = lr.id;
        insert fq1;
        
        Follow_Up_Detail_Config__c fdg = new Follow_Up_Detail_Config__c();
        fdg.Active__c = true;
        fdg.Answer_Type__c = 'Picklist';
        fdg.Field_Name__c = 'fieldname';
        fdg.Picklist_Values__c = 'yes,no';
        fdg.Question_Bank__c = qb2.id;
        fdg.Required__c = true;
        fdg.Show_on_summary_table__c = true;
        fdg.Sort_Order__c = 10;
        insert fdg;
        
        Follow_Up_Detail_Config__c fdg1 = new Follow_Up_Detail_Config__c();
        fdg1.Active__c = true;
        fdg1.Answer_Type__c = 'Text';
        fdg1.Field_Name__c = 'fieldname';
        //fdg1.Picklist_Values__c = 'yes,no';
        fdg1.Question_Bank__c = qb2.id;
        fdg1.Required__c = true;
        fdg1.Show_on_summary_table__c = true;
        fdg1.Sort_Order__c = 10;
        insert fdg1;
        
        Follow_Up_Question_Detail__c fqdt = new Follow_Up_Question_Detail__c();
        fqdt.Follow_Up_Question__c = fq1.id;
        insert fqdt;
        
        Follow_Up_Question_Data__c fqd = new Follow_Up_Question_Data__c();
        fqd.Follow_Up_Detail_Config__c = fdg1.id;
        fqd.Follow_Up_Question_Detail__c = fqdt.id;
        fqd.Value__c = 'value';
        insert fqd;
        
        test.startTest();
        PageReference pageRef = Page.ComplexQuestionWidget;
        pageRef.getParameters().put('id',lr.id);
        Test.setCurrentPageReference(pageRef);
        ComplexQuestionWidgetController controller = new ComplexQuestionWidgetController();
        controller.savePrimaryQuestions();
        controller.checkFollowUpQuestionsAndRefresh();
        pageRef.getParameters().put('QuesBankID',qb2.id);
        pageRef.getParameters().put('FollowQuesID',fq1.id);
        controller.addComplexQuestionData();
        controller.saveComplexQuestions();
        pageRef.getParameters().put('fDetailID',fqdt.id);
        controller.deleteQuestionData();
        test.stopTest();

    }
}