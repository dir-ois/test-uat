/*********************************************************************
Usage   : This class creates a Transaction from a list of Receipts.
            DepositReceiptsVFP calls this class.
*********************************************************************/

public class DepositReceiptsController {
    
    public List<Receipt__c> receiptList {get;set;}
    public Boolean showErrors {get;set;}
    
    public String[] ids {
        get {
            if (ids == null) {
                String s = ApexPages.currentPage().getParameters().get('ids');
                if (s != null) {
                    ids = s.split(',');
                } else {
                    ids = new String[] {};
                }
            }
            return ids;
        }
        set;
    }
    
    public String retURL {
        get{
            if(retURL == null){
                String s = ApexPages.currentPage().getParameters().get('retURL');
                if(s != null){
                    retURL = s;
                }
            }
            //return retURL;
            return '/a2r/o'; //hard coded Receipt list view - fix in Tier 2 - may need to update for PROD
        }
        set;
    }
    
    public DepositReceiptsController(){}
    
    public PageReference returnToList(){
        
        PageReference pr = new PageReference(retURL);
        pr.setRedirect(true);
        
        return pr;
    }
    
    
    public PageReference recordDeposits(){
        Id trnId;
        retURL = retURL;
        showErrors = false;
        receiptList = [SELECT Id, Name, Deposit_Account__c, Payment_Amount__c, Deduction_Amount__c, Office_Unit__c
                                            FROM Receipt__c
                                            WHERE Id IN :ids];
        
        List<Office_Account__c> officeAccountList = [SELECT Id, Name 
                                                        FROM Office_Account__c
                                                        WHERE Name = :receiptList[0].Deposit_Account__c];
        
        List<DIR_Employee__c> cashier = [SELECT Id, Position__c, User__c
                                            FROM DIR_Employee__c
                                            WHERE User__c = :UserInfo.getUserId()
                                                AND Position__c = 'Cashiering'
                                            LIMIT 1];
        
        Set<String> depositAccountNameSet = new Set<String>();
        Set<String> officeUnitNameSet = new Set<String>();
        
        for(Receipt__c rct : receiptList){ 
            if(rct.Deduction_Amount__c != null && rct.Deduction_Amount__c != 0.00){
                ApexPages.Message deducAmtErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on '+ rct.Name +': Deduction amount cannot be deposited.');
                ApexPages.addMessage(deducAmtErr);
            }
            
            if(rct.Deposit_Account__c == '108'){ 
                ApexPages.Message depAccNeedErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error on '+ rct.Name +': Deposit account 108 need not be deposited.'); 
                ApexPages.addMessage(depAccNeedErr);
            }
            
            depositAccountNameSet.add(rct.Deposit_Account__c); 
            officeUnitNameSet.add(rct.Office_Unit__c);
            //sumOfReceipts += rct.Payment_Amount__c; //Payment_Amount__c rollups tackled in ReceiptTrigger and receiptMethods
        }
        
        if(depositAccountNameSet.size() != 1){
            ApexPages.Message depAccErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Deposit accounts should be same on each Receipt.');
            ApexPages.addMessage(depAccErr);
        }
        
        if(officeUnitNameSet.size() != 1){
            ApexPages.Message unitErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Business units should be same on each Receipt.');
            ApexPages.addMessage(unitErr);
        }
        
        if(cashier == null || cashier.isEmpty()){
            ApexPages.Message employeeErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Internal Employee must have a Cashiering position to deposit a payment.');
            ApexPages.addMessage(employeeErr);
        }
        
        if(officeAccountList.size() != 1){ //This error message should never show up
            ApexPages.Message offAccErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Only one office account should exist for a selected deposit account.');
            ApexPages.addMessage(offAccErr);
        }
        
        if(ApexPages.getMessages().size() == 0){
            
            Decimal transactionSum = 0.00;
            for(Receipt__c rct : receiptList){
                transactionSum += rct.Payment_Amount__c;
            }
            
            Transaction__c trn = new Transaction__c(
                RecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('TRN Pending').getRecordTypeId(),
                //TRN.Office_Account__c m/d RCT.Deposit_Account__c
                Office_Account__c = officeAccountList[0].Id,
                Receipting_Cashier__c = cashier[0].Id,
                Transaction_Type__c = 'Deposit',
                Business_Unit__c = receiptList[0].Office_Unit__c,
                Transaction_Status__c = 'Pending',
                Transaction_Sum__c = transactionSum
            );
            insert trn;
            trnId = trn.Id;

            
            Id db = Database.executeBatch(new DepositBatch(ids, trnId), 50);
            
            PageReference pr = new PageReference(retURL);
            pr.setRedirect(true);
            system.debug(pr);
            return pr;
        }else{
            showErrors = true;
            return null;
        }
    }
    
}