/*********************************************************************

Usage   : This class is used to produce a batch of checks from payees that have been cleared so that that a user can request approval for printing the checks

Dependencies : Caffeine and an occasional slice of pecan pie.

Modified Date : 
Comment : 

*********************************************************************/

public class RequestChecksController {
    /*TODO: "payee.Case_Management__r.Employer__r.Subject_to_Garnishment__c == true || payee.Case_Management__r.Employer__r.Subject_to_Lien__c == true" was at one time
     * attempted to prevent check approval and/or check creation */
    private ApexPages.StandardSetController sc;
    private List<Id> payeeIds = new List<Id>();
    private Set<Id> oaIds = new Set<Id>();
    private Set<Id> caseIds = new Set<Id>();
    
    public Integer numberOfOfficeAccounts {get; set;}
    public List<Payee__c> payeeList {get; set;}
    public Integer numberOfPayees {get; set;}
    public Integer numberOfCases {get; set;}
    public Map<Id, Boolean> payeeIdToGarnishmentLien {get; set;}
    public Map<Id, Decimal> payeeIdToCheckAmount {get; set;}
    public Map<Id, String> payeeIdToLatestReceiptHoldDateText {get; set;}
    public Boolean showErrors {get;set;} 
    

    public RequestChecksController(ApexPages.StandardSetController sc){
        this.sc = sc;
        showErrors = false; 
        List<Payment_Record__c> prList = new List<Payment_Record__c>();
        payeeList = new List<Payee__c>();
        
        for(Payee__c payee : (List<Payee__c>)sc.getSelected()){
            payeeIds.add(payee.Id);
        }
        
        
        payeeList = [SELECT Id, Name, Payee_Name__c, Case_Role__c, Factor__c, Payee_Type__c, Status__c, DIR_Office__c,
                            Wage_Payable_Balance__c, Penalty_Payable_Balance__c, Other_Payable_Balance__c, Case_Management__c,
                            Case_Management__r.Office__r.Office_Account__c,
                            Case_Management__r.Employer__r.Subject_to_Garnishment__c,
                            Case_Management__r.Employer__r.Subject_to_Lien__c, 
                        
                        (SELECT Id, Receipt_Hold_Date__c, Liability_Payment__c, Payee__c, Payee__r.Id, Payee_Name__c,
                                Check__c, Payment_Amount__c, Liability_Payment__r.Case_Payment__c, Liability_Payment__r.Case_Payment__r.Id,
                                Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c,
                                Judgment_Payment__c, Judgment_Payment__r.Case_Payment__c, Judgment_Payment__r.Case_Payment__r.Id,
                                Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c
                            FROM Payment_Records__r
                            WHERE Check__c = null
                                AND Check_Issued__c = false)

                        FROM Payee__c
                        WHERE Id IN :payeeIds];
                        
        if(payeeList.size() == 0){
            showErrors = true;
            ApexPages.Message receiptErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Payees found.');
            ApexPages.addMessage(receiptErr);
        }
        
        numberOfPayees = payeeList.size();        
        
        prList = new List<Payment_Record__c>();
        payeeIdToCheckAmount = new Map<Id, Decimal>();
        payeeIdToLatestReceiptHoldDateText = new Map<Id, String>();
        payeeIdToGarnishmentLien = new Map<Id, Boolean>();
        
        for(Payee__c payee : payeeList){
            Decimal checkAmount = 0.00;
            Date latestReceiptHoldDate = Date.newInstance(1,1,1);
            
            caseIds.add(payee.Case_Management__c);
            
            prList.addAll(payee.Payment_Records__r);
            
            for(Payment_Record__c pr : payee.Payment_Records__r){
                
                if(pr.Payment_Amount__c != null){ //TODO: PR.Payment_Amount__c shouldn't be null, but in PROD ¯\_(ツ)_/¯
                    checkAmount += pr.Payment_Amount__c;
                }
                
                if(pr.Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c != NULL){
                    oaIds.add(pr.Liability_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c);
                }else if(pr.Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c != NULL){ //both LP and JP should not be null, but in PROD ¯\_(ツ)_/¯
                    oaIds.add(pr.Judgment_Payment__r.Case_Payment__r.Receipt__r.Transaction__r.Office_Account__c);
                }else{ //if the PR has no LP nor JP, such as funds in the CP CU-1 fields, we take the OA of the Payee. TODO: Phase 3(?) should prevent LPs or JPs from NOT being created from these types of funds.
                    oaIds.add(payee.Case_Management__r.Office__r.Office_Account__c);
                }
                
                if(pr.Receipt_Hold_Date__c != NULL && pr.Receipt_Hold_Date__c > latestReceiptHoldDate){
                    latestReceiptHoldDate = pr.Receipt_Hold_Date__c;
                }
                
                System.debug('latestReceiptHoldDate: ' + latestReceiptHoldDate);
            }
            
            if(checkAmount > 0.00){
                payeeIdToCheckAmount.put(payee.Id, checkAmount);
            }else{
                showErrors = true;
                ApexPages.Message checkAmountErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The Check amount for Payee ' + payee.Payee_Name__c + ' is $' + checkAmount +'. Please request these Checks again without this Payee.');
                ApexPages.addMessage(checkAmountErr);
            }
            
            if(payee.Case_Management__r.Employer__r.Subject_to_Garnishment__c || payee.Case_Management__r.Employer__r.Subject_to_Lien__c){
                payeeIdToGarnishmentLien.put(payee.Id, TRUE);
            }else{
                payeeIdToGarnishmentLien.put(payee.Id, FALSE);
            }
            
            if(latestReceiptHoldDate > Date.newInstance(1,1,1)){
                payeeIdToLatestReceiptHoldDateText.put(payee.Id, latestReceiptHoldDate.format());
            }else{
                payeeIdToLatestReceiptHoldDateText.put(payee.Id, ' ');
            }
            
            System.debug('payeeIdToLatestReceiptHoldDateText: ' + payeeIdToLatestReceiptHoldDateText);
            
            if(latestReceiptHoldDate > Date.today()){
                showErrors = true;
                ApexPages.Message holdDateErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Payee ' + payee.Payee_Name__c + ' has a Receipt with a Hold Date in the future.');
                ApexPages.addMessage(holdDateErr);
            }
            
        }
        
        if(prList.size() == 0){
            showErrors = true;
            ApexPages.Message noPrErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Payment Records found for selected Payees, or Checks have already been created for these Payees.');
            ApexPages.addMessage(noPrErr);
        }
        
        System.debug('oaIds: ' + oaIds);
        
        numberOfOfficeAccounts = oaIds.size();

        if(numberOfOfficeAccounts == 0){ //This shouldn't happen, but in PROD it will the data's so messy ¯\_(ツ)_/¯
            showErrors = true;
            ApexPages.Message noOaErr = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Office Accounts found. A Payment Record likely has no parent Liability Payment nor Judgment Payment.');
            ApexPages.addMessage(noOaErr);
        }
        
        numberOfCases = caseIds.size();
        
        
        system.debug('**** messages size: ' + ApexPages.getMessages().size());
    }
    
    public PageReference requestChecks(){
        
        system.debug('**** messages ' + ApexPages.getMessages());
        if(ApexPages.getMessages().size() == 0){
            List<Check_Batch__c> checkBatchList = new List<Check_Batch__c>();
            List<Id> checkBatchIds = new List<Id>();
            
            DIR_Employee__c currentDIREmployee = [SELECT Id, Name, User__c
                                                    FROM DIR_Employee__c
                                                    WHERE User__c = :UserInfo.getUserId()
                                                    LIMIT 1];
                                                    
            for(Id oaId : oaIds){
                Check_Batch__c checkBatch = new Check_Batch__c(
                    Requested_By__c = currentDIREmployee.Id,
                    Status__c = 'New',
                    Office_Account__c = oaId
                );
                
                checkBatchList.add(checkBatch);
            }
            
            insert checkBatchList;
            
            for(Check_Batch__c cb : checkBatchList){
                checkBatchIds.add(cb.Id);
            }
            

            Id db = Database.executeBatch(new RequestChecksBatch(payeeIds, checkBatchIds), 20);
            
            //PageReference pageRef = new PageReference('/' + 'a2j'); //'a2j' = Check Batch tab
            PageReference pageRef = new PageReference('/' + 'a2n'); //'a2n' = Payee tab
            pageRef.setRedirect(true);
            
            return pageRef;
            
        }else{
            showErrors = true;
            return null;
        }
        
    }
    
    public PageReference returnToList(){
        
        PageReference pageRef = new PageReference('/' + 'a2n'); //'a2n' = Payee tab
        pageRef.setRedirect(true);
        
        return pageRef;
        
    }
}