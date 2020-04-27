public class CreateUWFCheckController {
    
    public Check_Batch__c shellObject {get;set;}
    public List<Payment_Record__c> paymentRecords {get;set;}
    public Decimal pmtTotal {get;set;}
    public boolean disableCreate {get;set;}
    public boolean updateList {get;set;}
    @testVisible
    private Key_Value_Store__c payeeKVS = Key_Value_Store__c.getInstance('UWF Payee');
    @testVisible
    private DIR_Employee__c intUser;
    
    public CreateUWFCheckController(){
        disableCreate = true;
        updatelist = false;
        if(payeeKVS == null || payeeKVS.Value__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no values for the Key_Value_Store__c Custom Settings table. Please update the Custom Settings to include a "UWF Payee" record'));
            disableCreate = true;
            return;
        }
        
        try{
            intUser = [SELECT id, name, User__c, Office_Name__c FROM DIR_Employee__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Could not locate a DIR Employee record for your user account. Please contact a System Administrator'));
            disableCreate = true;
            return;
        }
        shellObject = new Check_Batch__c();
        Date pmtRecDateRange = Date.today().addMonths(-6);
        pmtTotal = 0;
        paymentRecords = new List<Payment_Record__c>([SELECT Id, Name, Check__c, DIR_Office__c, UWF_Payee_Office__c, Payee__r.case_number__c, Payment_Amount__c ,
                                                            Payment_applies_to__c, Payee__r.Payee_Type__c, Payee__r.Name, Payee__r.Status__c, Payee__r.Case_management__c,
                                                            Liability_Payment__r.Case_Payment__r.Date_Payment_Received__c, Judgment_Payment__r.Case_Payment__r.Date_Payment_Received__c,
                                                            Check__r.Status__c, Payee__r.Include__c, Payee__r.Payee_Name__c
                                                        FROM Payment_Record__c
                                                        WHERE (Payee__r.Payee_Type__c = 'Employee'
                                                            AND Payee__r.Status__c = 'Unverified' 
                                                            AND Check__c = null
                                                            AND Payment_Amount__c > 0
                                                            AND Payee__r.Include__c = False
                                                            AND ((Liability_Payment__r.Case_Payment__r.Date_Payment_Received__c < :pmtRecDateRange) OR (Judgment_Payment__r.Case_Payment__r.Date_Payment_Received__c < :pmtRecDateRange))
                                                            AND UWF_Payee_Office__c = :intUser.Office_Name__c)
                                                        OR (Payee__r.Payee_Type__c = 'Employee' 
                                                            AND Payee__r.Status__c = 'Unverified' 
                                                            AND Check__c != null
                                                            AND (Check__r.Status__c = 'Voided' OR Check__r.Status__c = 'Canceled')
                                                            AND Payment_Amount__c > 0
                                                            AND Payee__r.Include__c = False
                                                            AND ((Liability_Payment__r.Case_Payment__r.Date_Payment_Received__c < :pmtRecDateRange) OR (Judgment_Payment__r.Case_Payment__r.Date_Payment_Received__c < :pmtRecDateRange))
                                                            AND UWF_Payee_Office__c = :intUser.Office_Name__c)]);
        
        if(paymentRecords == null || paymentRecords.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No payment records were returned. Please contact a System Administrator for assitance'));
            disableCreate = true;
            return;
        }
        
        for(Payment_Record__c pr : paymentRecords){
            Decimal amt = pr.Payment_Amount__c == null ? 0 : pr.Payment_Amount__c;
            pmtTotal += amt;
            pr.Payee__r.Include__c = True;
        }
        }
        
        public void updateList(){
            disableCreate = false;
            Integer j = 0;
        while (j<paymentRecords.size()){
            if(paymentRecords.get(j).Payee__r.Include__c==false){
                pmtTotal -=paymentRecords.get(j).Payment_Amount__c;
                paymentRecords.remove(j);
            }else{
                j++;
            }
        }
        
        if(paymentRecords == null || paymentRecords.isEmpty()){
            disableCreate = true;
            updateList = true;
            return;
        }
    }
    
    
    public void createCheckBatchRecords(){
        if(shellObject.Office_Account__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You must select an Office Account in order to continue'));
            return;
        }
        
        Check_Batch__c newCheckBatch = new Check_Batch__c(
            Requested_By__c = intUser.Id,
            Status__c = 'New',
            Office_Account__c = shellObject.Office_Account__c
        );
        insert newCheckBatch;
        
        Check__c newCheck = new Check__c(
            Payee__c = payeeKVS.Value__c,
            Status__c = 'Pending Approval',
            Check_Batch__c = newCheckBatch.Id,
            Office_Account__c = shellObject.Office_Account__c,
            Amount__c = pmtTotal
        );
        insert newCheck;
        
        for(Payment_Record__c pr : paymentRecords){
            pr.Check__c = newCheck.Id;
        }
        update paymentRecords;
        disableCreate = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success! Click<a href="/'+newCheckBatch.Id+'">Here</a>to view the Check Batch'));
    }
    
    public pageReference returnHome(){
        return new pageReference('/home/home.jsp');
    }
}