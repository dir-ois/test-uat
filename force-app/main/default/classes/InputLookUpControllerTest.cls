@isTest
public class InputLookUpControllerTest { 

    static testmethod void testInputLookupVal(){
        
        String strSearchVal = '%tes%';
        String objectType = 'Account';


        List<Account> compList = [Select Id, Name from Account where Name like :strSearchVal Limit 5];

        List<SObject> firstList1 = InputLookUpController.getCurrentValue(strSearchVal, objectType);

        strSearchVal = '%cr%';
        objectType = 'DIR_Employee__c';

        List<DIR_Employee__c> emplList = [Select Id, Name, Position__c from DIR_Employee__c where Name like :strSearchVal Limit 5];

        List<SObject> firstList2 = InputLookUpController.getCurrentValue(strSearchVal, objectType);
        System.assertEquals(emplList, firstList2);
        System.assertEquals(compList, firstList1);
    }

}