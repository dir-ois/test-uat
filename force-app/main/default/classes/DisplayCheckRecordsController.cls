/**
 * Class: DisplayCheckRecordsController.cls
 * Developer: Marian Iovi (marian.iovi@vertiba.com)
 * Created: Octomber 12, 2016
 * Modified: -
 * Objective This class provides methods for DisplayCheckRecords.page
 *
 *
 **/ 
public class DisplayCheckRecordsController {
    
    public String checkBatchId {get;set;}
    public Integer count {get;set;}
    public Decimal csscount {get;set;}
    public List<Check__c> chkList {get;set;}
    public Date today {
                        set;
                        get{ return Date.today();}
                        }

    public void DisplayCheckRecordsController(){}

    public void runMethod(){
        checkBatchId = ApexPages.currentPage().getParameters().get('Id'); 
        System.debug('checkBatchId');

        chkList = [Select Id, Amount__c, Check_Number__c, Case__r.Case_Number__c, Case__r.Employer__r.Name, Office_Account__r.Name, 
                                Payee__r.Case_Role__r.Account_Name__c, Payee__r.Case_Role__r.Entity__r.ShippingStreet, Payee__r.Case_Role__r.Entity__r.ShippingCity, 
                                Payee__r.Case_Role__r.Entity__r.ShippingState, Payee__r.Case_Role__r.Entity__r.ShippingPostalCode, Payee__r.Payee_Name__c, Care_Of__c, Payment_Full_or_Partial__c
                                    FROM Check__c WHERE Check_Batch__c =: checkBatchId AND Status__c = 'Approved'];
                                    
       count= database.countQuery('select count() FROM Check__c WHERE Check_Batch__c =: checkBatchId');
       csscount=count * 3.5;
      

    }
}