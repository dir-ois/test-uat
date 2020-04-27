@isTest
public class form607_Tests {
    static testMethod void form607_Controller_UnitTest() {
        test.startTest();
        Position__c p = new Position__c();
        p.Name = '400-152-1441-888';
        p.Serial_Number__c = '888';
        p.Manual_Entry__c = false;
        p.IsActive__c = true;
        //p.Location__c = 'Van Nuys';
        
        Position__c p1 = new Position__c();
        p1.Name = '400-152-1441-889';
        p1.Serial_Number__c = '889';
        p1.Manual_Entry__c = false;
        p1.IsActive__c = true;
        p1.Department__c = '400';
        p1.Reporting_Unit_CodeNo__c = '152';
        p1.Class_Title_CodeNo__c = '1441';
        //p1.Location__c = 'Van Nuys';
        
        Position__c p2 = new Position__c();
        p2.Name = '400-152-1441-890';
        p2.Serial_Number__c = '890';
        p2.Manual_Entry__c = false;
        p2.IsActive__c = true;
        p2.Department__c = '400';
        p2.Reporting_Unit_CodeNo__c = '152';
        p2.Class_Title_CodeNo__c = '1441';
        //p2.Location__c = 'Van Nuys';
        insert new List<Position__c>{p, p1, p2};
        
        X607__c form607 = new X607__c();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(form607);
        form607_Controller f607c = new form607_Controller(sc);
        
        f607c.fillDepartment5();
        f607c.fillDepartment8();
        f607c.searchUnit5();
        f607c.searchUnit8();
        f607c.searchClassification5();
        f607c.searchClassification8();
        
        f607c.departmentAndOrganizationalUnit_5a = 'DIR';
        f607c.departmentAndOrganizationalUnit_8a = 'DIR';
        
        f607c.saveForm();
        
        f607c.effectiveDate_4a = '06-10-2013';
        f607c.expirationDate_4b = '07-10-2013';
        
        f607c.saveForm();
        f607c.transactionType = 'Reclassification';
        
        f607c.fiscalYear = '12/13';
        f607c.documentNo = '123432';
        
        f607c.codeNo_5a = '400';
        f607c.reportingUnitOrFunction_5b = 'asdf';
        f607c.codeNo_5b = '152';
        f607c.classTitle_5c = 'fdsa';
        f607c.codeNo_5c = '1548';
        f607c.numberOfpositions_5d = '1';
        f607c.positionSerialNumbers_5e = '888';
        f607c.typeOfPosition_5f = '1';
        
        f607c.timeBasis_6a = 'Full-Time';
        f607c.partTimeFraction_6a = '';
        
        f607c.salary_6b = '1234.12';
        f607c.rate_6b = 'Month';
        
        f607c.effectiveDate_7a = '06-10-2013';
        f607c.disencumberTo_7b = '07-20-2013';
        f607c.codeNo_8a = '400';
        f607c.reportingUnitOrFunction_8b = 'fdsa';
        f607c.codeNo_8b = '152';
        f607c.classTitle_8c = 'fdsa';
        f607c.codeNo_8c = '1441';
        f607c.numberOfpositions_8d = '1';
        f607c.positionSerialNumbers_8e = '888';
        f607c.typeOfPosition_8f = '1';
        
        f607c.saveForm();
        f607c.timeBasis_9a = 'Full-Time';
        f607c.partTimeFraction_9a = '';
        
        f607c.salary_9b = '4321.12';
        f607c.rate_9b = 'Month';
        
        f607c.docNo_9c = '';
        f607c.presentStatus_9c = '';
        
        f607c.descriptionOfDuties = 'asdfasdf';
        f607c.standardDescription = '';
        
        f607c.initials = 'AA';
        f607c.accountingOfficerDate = '06-10-2013';
        
        f607c.contactPerson_12 = 'TEST';
        f607c.saveForm();
        f607c.saveForm();
        
        form607 = f607c.form607;
        system.debug(form607.Id);
        
        PageReference pr = Page.form607;
        pr.getParameters().put('id', form607.Id);
        pr.getParameters().put('pdf', 'true');
        Test.setCurrentPage(pr);
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        pr = Page.form607;
        pr.getParameters().put('id', form607.Id);
        Test.setCurrentPage(pr);
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        f607c.viewAsPDF();
        
        form607 = new X607__c();
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        f607c.departmentAndOrganizationalUnit_5a = 'DIR';
        f607c.departmentAndOrganizationalUnit_8a = 'DIR';
        
        f607c.effectiveDate_4a = '06-10-2013';
        f607c.expirationDate_4b = '07-10-2013';
        
        f607c.transactionType = 'Reclassification';
        
        f607c.fiscalYear = '12/13';
        f607c.documentNo = '123432';
        
        f607c.codeNo_5a = '400';
        f607c.reportingUnitOrFunction_5b = 'asdf';
        f607c.codeNo_5b = '152';
        f607c.classTitle_5c = 'Various';
        f607c.codeNo_5c = 'various';
        f607c.numberOfpositions_5d = '2';
        f607c.positionSerialNumbers_5e = 'various';
        f607c.typeOfPosition_5f = '1';
        
        f607c.timeBasis_6a = 'Full-Time';
        f607c.partTimeFraction_6a = '';
        
        f607c.salary_6b = 'various';
        f607c.rate_6b = 'Month';
        
        f607c.effectiveDate_7a = '06-10-2013';
        f607c.disencumberTo_7b = 'PERM';
        f607c.codeNo_8a = '400';
        f607c.reportingUnitOrFunction_8b = 'fdsa';
        f607c.codeNo_8b = '152';
        f607c.classTitle_8c = 'various';
        f607c.codeNo_8c = 'various';
        f607c.numberOfpositions_8d = '2';
        f607c.positionSerialNumbers_8e = 'various';
        f607c.typeOfPosition_8f = '1';
        
        f607c.timeBasis_9a = 'Full-Time';
        f607c.partTimeFraction_9a = '';
        
        f607c.salary_9b = 'various';
        f607c.rate_9b = 'Month';
        
        f607c.docNo_9c = '';
        f607c.presentStatus_9c = '';
        
        f607c.descriptionOfDuties = 'asdfasdf';
        f607c.standardDescription = '';
        
        f607c.initials = 'AA';
        f607c.accountingOfficerDate = '06-10-2013';
        
        f607c.contactPerson_12 = 'TEST';
        f607c.saveForm();
        form607 = f607c.form607;
        system.debug(form607.Id);
        
        pr = Page.addPositionModifications;
        pr.getParameters().put('id', form607.Id);
        pr.getParameters().put('posmod', 'true');
        Test.setCurrentPage(pr);
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        f607c.newAddPos.Class_Title_CodeNo__c = '1582';
        f607c.newAddPos.Serial_Number__c = '777';
        f607c.addAddition();
        
        f607c.newAddPos.Class_Title_CodeNo__c = '1582';
        f607c.newAddPos.Serial_Number__c = '778';
        f607c.addAddition();
        
        f607c.deletedAdditionIndex = 0;
        f607c.deleteAddition();
        
        f607c.newAddPos.Class_Title_CodeNo__c = '1582';
        f607c.newAddPos.Serial_Number__c = '777';
        f607c.addAddition();
        
        f607c.newDelPos.Class_Title_CodeNo__c = '1441';
        f607c.newDelPos.Serial_Number__c = '889';
        f607c.addDeletion();
        
        f607c.newDelPos.Class_Title_CodeNo__c = '1441';
        f607c.newDelPos.Serial_Number__c = '890';
        f607c.addDeletion();
        
        f607c.deletedDeletionIndex = 4;
        f607c.deleteDeletion();
        
        f607c.newDelPos.Class_Title_CodeNo__c = '1441';
        f607c.newDelPos.Serial_Number__c = '890';
        f607c.addDeletion();
        
        f607c.savePositionModifications();
        f607c.form607.Status__c = 'Submitted to Budget';
        update f607c.form607;
        
        pr = Page.addPositionModifications;
        pr.getParameters().put('id', form607.Id);
        pr.getParameters().put('posmod', 'true');
        Test.setCurrentPage(pr);
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        pr = Page.addPositionModifications;
        pr.getParameters().put('id', form607.Id);
        pr.getParameters().put('pdf', 'true');
        pr.getParameters().put('posmod', 'true');
        Test.setCurrentPage(pr);
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);

        f607c.submitForApproval();
        f607c.addPositionModifications();
        f607c.viewAttachment();
        f607c.detailPage();

        form607 = new X607__c();
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        f607c.departmentAndOrganizationalUnit_5a = '';
        f607c.departmentAndOrganizationalUnit_8a = '';
        f607c.effectiveDate_4a = '';
        f607c.expirationDate_4b = '';
        f607c.effectiveDate_7a = '';
        f607c.disencumberTo_7b = '';
        f607c.accountingOfficerDate = '';
        f607c.contactDate_12 = '';
        f607c.WFD_accountingOfficerDate = true;
        f607c.WFD_contactDate_12 = true;
        f607c.WFD_disencumberTo_7b = true;
        f607c.WFD_effectiveDate_4a = true;
        f607c.WFD_effectiveDate_7a = true;
        f607c.WFD_expirationDate_4b = true;
        
        f607c.saveForm();
        
        form607 = f607c.form607;
        system.debug(form607);
        form607.X607_Position_Primary_Addition__c = null;
        form607.X607_Position_Primary_Deletion__c = null;
        update form607;
        pr = Page.form607;
        pr.getParameters().put('id', form607.Id);
        Test.setCurrentPage(pr);
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        
        form607 = f607c.form607;
        form607.X607_Position_Primary_Addition__c = null;
        form607.X607_Position_Primary_Deletion__c = null;
        pr = Page.form607;
        pr.getParameters().put('id', form607.Id);
        pr.getParameters().put('pdf', 'true');
        Test.setCurrentPage(pr);
        sc = new ApexPages.Standardcontroller(form607);
        f607c = new form607_Controller(sc);
        
        system.debug(f607c.form607.X607_Position_Primary_Addition__c);
        
        test.stopTest();
    }
}