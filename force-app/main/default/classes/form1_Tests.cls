@isTest
public class form1_Tests {
    static testMethod void form1_Controller_UnitTest() {
        test.startTest();
        Position__c p = new Position__c();
        p.Name = '400-152-1441-888';
        p.Serial_Number__c = '888';
        p.Manual_Entry__c = false;
        insert p;
        
        Form_1__c f1 = new Form_1__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(f1);
        form1_Controller fc = new form1_controller(sc);
        fc.saveForm1();
        f1 = fc.fw1.form1;
        PageReference pr = Page.form1;
        system.debug(f1.Id);
        pr.getParameters().put('id', f1.Id);
        Test.setCurrentPage(pr);
        
        sc = new ApexPages.Standardcontroller(f1);
        fc = new form1_controller(sc);
        
        sc = new ApexPages.Standardcontroller(f1);
        form1_extension fec = new form1_extension(sc);
        fec.create607OnLoad();
        test.stopTest();
    }
}