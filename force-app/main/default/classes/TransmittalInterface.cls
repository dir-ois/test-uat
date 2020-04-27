public class TransmittalInterface {


    //public static String transName {get;set;}
    public static String depositId {get;set;}
    public static String depositSlipNumber {get;set;}
    public static String depositType {get;set;}
    public static String paymentMethod {get;set;}
    public static Date bankDepositDate1 {get;set;}
    
    public static Integer currentFiscalYear = getCurrentFY();
    public static Integer twoFiscalYear = currentFiscalYear- 2;

    //public Date startDate {get;set;}
    //public Date endDate {get;set;}

    //create lists for the receipt 
    public List<Receipt__c> receipts = new List<Receipt__c>();
    public List<Liability_Payment__c> liabilityPayments = new List<Liability_Payment__c>();
    public List<Applied_Accounting_Code__c> appliedAccountingCodes = new List<Applied_Accounting_Code__c>();
    public List<DIR_Violation__c> caseIssues = new List<DIR_Violation__c>();
    public List<Violation_Accounting_Code__c> violationAccountingCodes = new List<Violation_Accounting_Code__c>();
    
    //create maps for the receipt
    public Map<Id,Map<Liability_Payment__c,List<Applied_Accounting_Code__c>>> mapLiabilityPayments = new Map<Id,Map<Liability_Payment__c,List<Applied_Accounting_Code__c>>>();
    Map<ID,DIR_Violation__c> mapCaseViolation= new Map<ID, DIR_Violation__c>();
     
    //Deposit ID
    Integer countCheck = 0;
    
    //Payment Seq
    Integer count = 1;
    Integer countPaymentSequence = 0;
   
    //Deposit Control
    Decimal controlAmount1 = 0.000;
    
    //AR018 Interface String
    List<String> ar018 = new List<String>();
    
    public void sendAR(){
        
         //Check for required fields
        boolean checkRequiredFields = checkRequiredFields(bankDepositDate1, depositId);
        if(!checkRequiredFields){
            return;
        }
                
        //Create if else statement to filter the receipt(payment log) depending on the deposit type
        if(paymentMethod.equalsIgnoreCase('CHK')){
            receipts = [SELECT Id, Name, Bank_Deposit_Date__c, Payment_Type__c, Payment_Amount__c, 
                            (SELECT Id, Name, Date_Payment_Received__c, Payment_Amount__c, Transmittal__r.Name from Case_Payments__r 
                            WHERE Id in (Select Case_Payment__c from Liability_Payment__c)
                            AND Transmittal__r.id != null)
                            FROM Receipt__c
                            WHERE ID in (Select Receipt__c from Case_Payment__c where Transmittal__c !=null  )
                        		AND Bank_Deposit_Date__c = :bankDepositDate1
                                AND Payment_Type__c IN ('Check', 'Cashier\'s Check', 'Money Order', 'State Warrant', 'State Warrant - Returned by USPS')
                                AND Payment_Amount__c != 0.00
                            ORDER BY Payment_Type__c ASC];
        }else{ //get the list of payment logs based on bank deposit date and payment type
            receipts = [SELECT Id, Name, Bank_Deposit_Date__c, Payment_Type__c, Payment_Amount__c,
                        (SELECT Id, Name, Date_Payment_Received__c, Payment_Amount__c, Transmittal__r.Name from Case_Payments__r 
                         WHERE Id in (Select Case_Payment__c from Liability_Payment__c)
                         AND Transmittal__r.id != null)    
                         FROM Receipt__c
                            WHERE ID in (Select Receipt__c from Case_Payment__c where Transmittal__c !=null  )
                        		AND Bank_Deposit_Date__c = :bankDepositDate1
                                AND Payment_Type__c = 'EFT'
                                AND Payment_Amount__c != 0.00];
        }
        
        System.debug('Receipt List:' + receipts);
        
        // get the child liability of bofe case payment and have Applied Accounting Code
        liabilityPayments = [SELECT Id, Name, Case_Payment__r.id, Case_Violation__r.id, Case_Violation__r.Customer_ID__c, 
                             Case_Violation__r.Fiscal_Year__c, Case_Violation__r.Citation_Date__c, Payment_Applied_To__c
                             FROM Liability_Payment__c 
                             WHERE Case_Payment__r.receipt__c in : receipts
                             AND Id in (SELECT Liability_Payment__c FROM Applied_Accounting_Code__c)
                             AND Payment_Applied_To__c !='Wages' ];
        
        System.debug('liability payments:' + liabilityPayments);
        
        //get the case issues look up by casePayments
        caseIssues = [SELECT Id, Name, (SELECT Id,Name, Item__c, Payment_Type__c, Applicable_Accounting_Code__r.Accounting_code__c FROM Violation_Accounting_Codes__r),
                      (SELECT Id, Name FROM Liability_Payments__r), Fiscal_Year__c, Citation_Date__c 
                      FROM DIR_Violation__c  
                      WHERE id in(SELECT Case_Violation__c FROM Liability_Payment__c WHERE id in: liabilityPayments )];
        System.debug('caseIssues:' + caseIssues);
        
        //get the child violation accounting code of case issues
        violationAccountingCodes = [SELECT id, Name, Case_Violation__r.id FROM Violation_Accounting_Code__c 
                                    WHERE Case_Violation__c in (SELECT Case_Violation__c FROM Liability_Payment__c WHERE Case_Violation__r.id =: caseIssues )];
        
        //Map<Id,List<Violation_Accounting_Code__c>> prodInvMap = new Map<Id,List<Violation_Accounting_Code__c>();
        
        
        //get the child applied accounting code
        appliedAccountingCodes = [SELECT Id,Name, Amount__c, Liability_Payment__r.id, Liability_Payment__r.Case_Payment__r.id, Accounting_code__c,
                                  Accounting_Code__r.Account__c, Accounting_Code__r.Current_Doc__c, Accounting_Code__r.PCA__c, Accounting_Code__r.Fund__c, Accounting_Code__r.Agency_Use__c,
                                  Accounting_Code__r.Alt_Account__c, Accounting_Code__r.Reporting_Structure__c, Accounting_Code__r.Labor_Code__c
                                  FROM Applied_Accounting_Code__c WHERE Liability_Payment__r.id =: liabilityPayments /*and Liability_Payment__r.Case_Payment__r.Transmittal__r.id =: trans*/];
        
        System.debug('appliedAccountingCode: ' + 'records count: ' + appliedAccountingCodes.size() );
        
        //if receipts,liability payments, or applied accounting code is empty, don't generate the file
        if(receipts.isEmpty() || liabilityPayments.isEmpty() || appliedAccountingCodes.isEmpty() ){
             ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'No records found to generate AR018 Interface file'))  ;  
        }
        
        //Assign mapCaseViolation to Liability Payment List
        for(Liability_Payment__c li: liabilityPayments){
            mapCaseViolation.put(li.id, li.case_violation__r);
        }
        
        //create a top down approach data set starting from Receipt__c Object
       for(Receipt__c receipt: receipts ){
           
           for(Case_Payment__c casePayment : receipt.Case_Payments__r){
               
               //new list of Liability Payments
               List<Liability_Payment__c> lLiabilityPayments = new List<Liability_Payment__c>();
               
               //inner map
               Map<Liability_Payment__c,List<Applied_Accounting_Code__c>> mapAppliedAccountingCodes = new Map<Liability_Payment__c,List<Applied_Accounting_Code__c>>();
               
               for(Liability_Payment__c liabilityPayment : liabilityPayments){
                   
                   //matches Liability payments with one Case Payment
                   if(casePayment.Id == liabilityPayment.Case_Payment__r.Id){
                       lLiabilityPayments.add(liabilityPayment);
                       
                       //new list of Applied Accounting Codes
                       List<Applied_Accounting_Code__c> lAppliedAccountingCodes = new List<Applied_Accounting_Code__c>();
                       
                       for(Applied_Accounting_Code__c appliedAccountingCode : appliedAccountingCodes){
                           if(liabilityPayment.Id == appliedAccountingCode.Liability_Payment__r.id){
                               lAppliedAccountingCodes.add(appliedAccountingCode);
                           }
                       }
                       //add key and values to innermap
                       mapAppliedAccountingCodes.put(liabilityPayment, lAppliedAccountingCodes);
                   }
               }
               //add key and values to outer map
               mapLiabilityPayments.put(casePayment.Id,mapAppliedAccountingCodes);
               
           }
           
           //addd key and values to outer map
           
       }
        
        //loop through the list of receipts
        for(Receipt__c receipt: receipts ){
            
            for(Case_Payment__c casePayment : receipt.case_payments__r){
                System.debug('casePayment loop:' + casePayment);
                //count Liability related to the case payment
                Integer countLiability = 0;
                for(Liability_Payment__c liabilityPayment: mapLiabilityPayments.get(casePayment.id).keyset()){
                    System.debug('Liability Payment loop:' + liabilityPayment);
                    countLiability++;
                    Integer countAppliedAccountingCode = 0;
                    for(Applied_Accounting_Code__c appliedAccountingCode: mapLiabilityPayments.get(casePayment.id).get(liabilityPayment)){
                        System.debug('Applied Accounting Code loop:' + appliedAccountingCode.Liability_Payment__c);
                        countAppliedAccountingCode++;
                        countPaymentSequence++; //PaymentSequence Counter
                        
                        //error message if there's no Bank Deposit Date on Payment log
                        if(receipt.Bank_Deposit_Date__c == null){
                            System.debug('Bank Deposit Date is Required');
                            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Bank Deposit Date is required for Receipt: ' + receipt.Name));        
                        }
                        
                        if(receipt.Payment_Type__c.equalsIgnorecase('Check') || receipt.Payment_Type__c.equalsIgnorecase('State Warrant')) //need to account State Warrant
                            countCheck++;
                        
                        //get the Case Issue tied to the Liability Payment
                        DIR_Violation__c caseIssue = mapCaseViolation.get(liabilityPayment.id);
                     
                        //002 Line                        
                        wrapTransmittal wrapT = new wrapTransmittal();
                        wrapT.paymentSeqNum = String.valueOf(countPaymentSequence).rightPad(6);
                        wrapT.idSeqNum = String.valueOf(countAppliedAccountingCode).rightPad(6);
                        wrapT.idSeqNumCustomer = String.valueOf(countAppliedAccountingCode).rightPad(5); //IDSEQ Number for customer has a diff padding value
                        wrapT.paymentId = appliedAccountingCode.Name.rightPad(15);
                        wrapT.check_Dt = formatDate(receipt.Bank_Deposit_Date__c).rightPad(10); // changed from Recieve_Payment_Date__c
                        wrapT.PaymentAmt = String.valueOf(ifnull(appliedAccountingCode.Amount__c,0.000)).rightPad(28);
                        wrapT.zzPaymentMethod = paymentMethod(receipt.Payment_Type__c).rightPad(3);
                        
                        //004 Line
                        wrapT.customerId = getCustomerID(caseIssue.Citation_Date__c, wrapT.determintationDate);
                        
                        
                        //wrapT.accountingcode = ifnull(appliedAccountingCode.Accounting_Code__c,'');
                        wrapT.ppSw = getPpsw(liabilityPayment, appliedAccountingCode);
                        wrapT.miscPayment = getMiscPayment(liabilityPayment, appliedAccountingCode);
                        wrapT.montetaryAmount = getMonetaryValueSign(String.valueOf(ifnull(appliedAccountingCode.Amount__c,0.000)));
                        wrapT.account =  ifnull(appliedAccountingCode.Accounting_Code__r.Account__c,'').rightPad(10);
                        wrapT.programCode = getProgram(wrapT.account); // PrgoramCode is 6105005 when Account equals 4840000. Else programCode is blank.
                        wrapT.budgetRef = getbudgetRef(wrapT.account);
                        wrapT.fundCode = ifnull(appliedAccountingCode.Accounting_Code__r.Fund__c,'').rightPad(9);
                        wrapT.chartField1 = ifnull(appliedAccountingCode.Accounting_Code__r.Agency_Use__c,'').rightPad(10); //fix assigning previous chartfield
                        wrapT.altAcct = ifnull(appliedAccountingCode.Accounting_Code__r.Alt_Account__c,'').rightPad(10);
                        wrapT.deptId = ifnull(appliedAccountingCode.Accounting_Code__r.Reporting_Structure__c,'').rightPad(10);
                        wrapT.lineNoteText = ifnull(liabilityPayment.Payment_Applied_To__c,'') + casePayment.Transmittal__r.name + liabilityPayment.Name + ' ' + appliedAccountingCode.Accounting_Code__r.Labor_Code__c ; //added labor code
                        wrapT.product = getProduct(ifnull(liabilityPayment.Case_Violation__r.Fiscal_Year__c,'0'));
                        
                        //Added on 4/12/2019-If the Product is the prior fiscal year, then the value should be June 30 of the previous state fiscal year. Line005
                        //only applies when Account equals 4840000
                        wrapT.budgetDt = getBudgetDate(wrapT.product,wrapT.account);
                        
                        //offset Amt
                        controlAmount1 += ifnull(appliedAccountingCode.Amount__c, 0.000); 
                        
                        ar018.add(printWrapTransmittal(wrapT));
                        
                           
                        //last payment log
                        if(count == receipts.size() && countLiability == mapLiabilityPayments.get(casePayment.id).keyset().size() 
                           && countAppliedAccountingCode == mapLiabilityPayments.get(casePayment.id).get(liabilityPayment).size()){
                               System.debug('Liability size' + countLiability);
                               System.debug('mapLiability size' + mapLiabilityPayments.get(casePayment.id).keyset().size());
                               wrapTransmittalHeader wrapH = new wrapTransmittalHeader();
                               wrapTransmittalControl wrapC = new wrapTransmittalControl();
                               wrapTransmittalOffset wrapOffset = new wrapTransmittalOffset();
                               
                               wrapOffset.paymentSeqNum = String.valueOf(countPaymentSequence + 1).rightPad(6);
                               wrapOffset.OffsetAtmt = getMonetaryValueSign(String.valueOf(controlAmount1)).rightPad(28);
                               wrapOffset.OffsetAtmt2 = getMonetaryValueSign(wrapOffset.OffsetAtmt).rightPad(28);
                               
                               wrapC.control_cnt = String.valueOf(countPaymentSequence + 1).rightpad(6);
                               wrapC.totalChecks = String.valueOf(countCheck).rightPad(5);
                               wrapC.received_Dt = formatDate(bankDepositDate1).rightPad(10);
                               wrapC.zzLegDepId = getZzLegDepId(bankDepositDate1).rightPad(15);
                               
                               
                                   
                               ar018.add(0,printwrapTransmittalHeader(wrapH));
                               ar018.add(1,printWrapTransmittalControl(wrapC));
                               ar018.add(printWrapTransmittalOffset(wrapOffset));
                        }     
                    }
                }                 
            }
         
            count++; //payment log counter
        }
        
        //Return error messages
        if (ApexPages.hasMessages(ApexPages.Severity.INFO)){
            return;
        }
           
        
        //convert the list to AR018 String to generate the file
        String allstring = string.join(ar018, '');
        
        sendJobCompleteEmail(allstring);
        
    }

    public class wrapTransmittalHeader{

        String fileHeaderRowId = '000'.rightPad(3);
        String createdDate  = getDate().rightPad(26);
        String depositBu = '7350'.rightPad(5);
        String depositCnt = '1'.rightPad(4);//default value starts 1 and increment by 1 for every different bank deposit date
        String TotalAmt = '0.000'.rightPad(28); //TotalAmt must match the controlAmt on line01. Refer to AR018 Spec sheet.
        Decimal TotalAmt1 = 0.000;
        Decimal TotalAmt2 = 0.000;

    }
    
    public class wrapTransmittalControl{
        
        String depositControlRowId = '001'.rightPad(3);
        String depositBu = '7350'.rightPad(5);
        String depositId = TransmittalInterface.depositId.rightPad(15); // Change to User Input from AR018 Generate Screen.
        String accountingDate = formatDate(System.today()).rightPad(10);
        String bankCd = 'STATE'.rightPad(5);
        String bankAcctkey = '108'.rightPad(4);
        String Deposit_type = TransmittalInterface.depositType.rightPad(1); // There could be different deposit type.
        String controlCurrency = 'USD'.rightPad(3);
        String zzBnkDepositNum = ifnull(TransmittalInterface.depositSlipNumber,'').rightPad(10); // Using Deposit Slip Number from Fiscal for testing purpose
        String zzIdentifier = 'DLS'.rightPad(10); //Changed to DLS. Refer to AR018 Temp Config values.
        String controlAmount = ''.rightPad(28);
        String controlAmount2 = '0.000'.rightPad(28);//This control Amount is a place holder for 001 line per Fiscal Requirement. The amount is 0.000 for every 001 line.
        String control_cnt = ''.rightPad(6);
        String received_Dt;
        //AR0018 Fields
        String totalChecks = ''.rightPad(5);
        String flag = setFlag(TransmittalInterface.depositSlipNumber,'Y').rightPad(1); // Previous was Y. Changed to Blank.
        String bankOperNum = ''.rightPad(2); // Previous was 11. Changed To blank
        String zzLegDepId = ''.rightPad(15);
        
    }
    
    public class wrapTransmittalOffset{
        
        //offset payment information
        String paymentInformationRowId = '002'.rightPad(3);
        String depositBu = '7350'.rightPad(5);
        String offsetDepositId = TransmittalInterface.depositId.rightPad(15); 
        String paymentSeqNum;
        String control_cnt = ''.rightPad(6);
        String offsetId = 'AA-OFF'+ String.valueOf(bankDepositDate1).replace('-', '').replaceFirst('20',''); 
        String accountingDate = formatDate(System.today()).rightPad(10);
        String paymentCurrency = 'USD'.rightPad(3);
        String ppSw = 'N'.rightPad(1);
        String miscPayment = 'Y'.rightPad(1);
        String Check_Dt = ''.rightPad(10); //Populate the Check_dt with CalAtlas Bandeposit Date 
        String zzReceivedBySco = ''.rightPad(1);
        String zzCashType = ''.rightPad(3);
        String descr50Mixed = ''.rightPad(50);
        String document = 'CTS TO STATE FUND TC-47'.rightPad(30);
        String city = ''.rightPad(30);
        String county = ''.rightPad(30);
        String taxDesc = ''.rightPad(28);
        
        //offset distribution line
        String distributionLineRowid = '005'.rightPad(3);
        String businessUnitGl = '7350'.rightPad(5);
        String speedChartKey = ''.rightPad(10);
        String businessUnitPc = ''.rightPad(5);
        String projectId = ''.rightPad(15);
        String activityId = ''.rightPad(15);
        String resourceType = ''.rightPad(5);
        String resourceCategory = ''.rightPad(5);
        String resourceSubCat = ''.rightPad(5);
        String analysisType = ''.rightPad(3);
        String operatingUnit = ''.rightPad(8);
        String product = ''.rightPad(6);
        String fundCode = ''.rightPad(9);
        String classFld = ''.rightPad(5);
        String programCode = ''.rightPad(10);
        String budgetRef = ''.rightPad(8); 
        String affiliate = ''.rightPad(5);
        String affiliateIntra1 = ''.rightPad(10);
        String affiliateIntra2 = ''.rightPad(10);
        String chartField1 = ''.rightPad(10);
        String chartField2 = ''.rightPad(10);
        String chartFiled3 = ''.rightPad(10);
        
        String offsetzzPaymentMethod = ''.rightPad(3); // will be blank for offsetline
        String OffsetAtmt = ''.rightPad(28);
        String OffsetAtmt2 = ''.rightPad(28);
        String offsetProduct = String.valueOf(getCurrentFY(bankDepositDate1)).rightPad(6);// this is the fiscal year of the bank deposit date
        String offsetBudgetRef = ''.rightPad(8);
        String offsetLineNoteText = 'ORIGINAL DEPOSIT ID: OFFSET UNCLEARED COLLECTIONS FOR DEPOSIT DATE ' + bankDepositDate1.format() +' PAYMENT IDS:';
        String offsetProgramCode = ''.rightPad(10); // will always be blank for offset line
        String tempOffset = '';
    }
    
    public String printWrapTransmittalOffset(wrapTransmittalOffset wrapTransmittalOffset ){
        
        String offset = wrapTransmittalOffset.paymentInformationRowId + wrapTransmittalOffset.depositBu + wrapTransmittalOffset.offsetDepositId.rightPad(15) + wrapTransmittalOffset.paymentSeqNum + /*wrapTransmittalOffset.control_cnt*/
            + wrapTransmittalOffset.OffsetId.rightPad(15) + wrapTransmittalOffset.accountingDate + wrapTransmittalOffset.OffsetAtmt + wrapTransmittalOffset.paymentCurrency +
            + wrapTransmittalOffset.ppSw + wrapTransmittalOffset.miscPayment + wrapTransmittalOffset.Check_Dt + wrapTransmittalOffset.offsetzzPaymentMethod + wrapTransmittalOffset.zzReceivedBySco + 
            + wrapTransmittalOffset.zzCashType + wrapTransmittalOffset.descr50Mixed + wrapTransmittalOffset.document + wrapTransmittalOffset.city + wrapTransmittalOffset.county + wrapTransmittalOffset.taxDesc + wrapTransmittalOffset.offsetLineNoteText + '\n';
        
        String offsetDist = wrapTransmittalOffset.distributionLineRowid + wrapTransmittalOffset.depositBu + wrapTransmittalOffset.offsetDepositId.rightPad(15) + wrapTransmittalOffset.paymentSeqNum + /*wrapTransmittalOffset.control_cnt*/
            + '1'.rightPad(6) + wrapTransmittalOffset.businessUnitGl + wrapTransmittalOffset.speedChartKey + wrapTransmittalOffset.OffsetAtmt2
            + /*account*/'2090100'.rightPad(10) + wrapTransmittalOffset.businessUnitPc + wrapTransmittalOffset.projectId + wrapTransmittalOffset.activityId + wrapTransmittalOffset.resourceType + wrapTransmittalOffset.resourceCategory +
            + wrapTransmittalOffset.resourceSubCat + wrapTransmittalOffset.analysisType + wrapTransmittalOffset.operatingUnit + wrapTransmittalOffset.offsetProduct + /*fundCode*/ '000000108'.rightPad(9)  + wrapTransmittalOffset.classFld 
            + wrapTransmittalOffset.offsetProgramCode + wrapTransmittalOffset.offsetBudgetRef + wrapTransmittalOffset.affiliate + wrapTransmittalOffset.affiliateIntra1 + wrapTransmittalOffset.affiliateIntra2 + /*chartField1*/ ''.rightPad(10)
            + wrapTransmittalOffset.chartField2 + wrapTransmittalOffset.chartFiled3 + /*altAcct*/ '0000000000' + /*deptId*/ ''.rightPad(10) + '\n' ;
        
        return offset + offsetDist;

    }
    

    public class wrapTransmittal{
        
        String depositBu = '7350'.rightPad(5);
        String depositId = TransmittalInterface.depositId.rightPad(15); // Change to User Input from AR018 Generate Screen.
        
        String paymentInformationRowId = '002'.rightPad(3);
        String paymentSeqNum;
        String paymentId;
        String accountingDate = formatDate(System.today()).rightPad(10);
        String paymentAmt;
        String paymentCurrency = 'USD'.rightPad(3);
        String ppSw = ''.rightPad(1);
        String miscPayment = ''.rightPad(1);
        String Check_Dt = ''.rightPad(10);
        String zzPaymentMethod = ''.rightPad(3);
        String zzReceivedBySco = ''.rightPad(1);
        String zzCashType = ''.rightPad(3);
        String descr50Mixed = ''.rightPad(50);
        String document = 'CTS TO STATE FUND TC-47'.rightPad(30);
        String city = ''.rightPad(30);
        String county = ''.rightPad(30);
        String taxDesc = ''.rightPad(28);
        String lineNoteText = ''.rightPad(254);
        
        String itemReferenceRowId = '003'.rightPad(3);
        String idSeqNum;
        String idSeqNumCustomer;
        String reqQualifierCode = 'I'.rightPad(2);
        String refValue = ''.rightPad(30);
       
        String customerInformationRowid = '004'.rightPad(3);
        String customerId;
        
        String distributionLineRowid = '005'.rightPad(3);
        String businessUnitGl = '7350'.rightPad(5);
        String speedChartKey = ''.rightPad(10);
        String montetaryAmount = ''.rightPad(28);
        String account = ''.rightPad(10);
        String businessUnitPc = ''.rightPad(5);
        String projectId = ''.rightPad(15);
        String activityId = ''.rightPad(15);
        String resourceType = ''.rightPad(5);
        String resourceCategory = ''.rightPad(5);
        String resourceSubCat = ''.rightPad(5);
        String analysisType = ''.rightPad(3);
        String operatingUnit = ''.rightPad(8);
        String product = ''.rightPad(6);
        String fundCode = ''.rightPad(9);
        String classFld = ''.rightPad(5);
        String programCode = ''.rightPad(10);
        String budgetRef = ''.rightPad(8); //Todo need to remove 001 from all account except 4840000
        String affiliate = ''.rightPad(5);
        String affiliateIntra1 = ''.rightPad(10);
        String affiliateIntra2 = ''.rightPad(10);
        String chartField1 = ''.rightPad(10);
        String chartField2 = ''.rightPad(10);
        String chartFiled3 = ''.rightPad(10);
        String altAcct = ''.rightPad(10);
        String deptId = ''.rightPad(10);
        String padder = ''.rightPad(216); //padding include all the legacy fields before budgetDT
        String budgetDt = ''.rightPad(10);
        
        String itemDeatilsRowId = '006'.rightPad(3);
        String itemLine = '1'.rightPad(6);
        
        Integer currentFiscalYear = TransmittalInterface.currentFiscalYear;
        Integer twoFiscalYear = currentFiscalYear - 2;
        
        Date determintationDate = date.newInstance(2018,7,01);
             
    }

    
    public String printwrapTransmittalHeader(wrapTransmittalHeader wrapTransmittalHeader ){
        String header = wrapTransmittalHeader.fileHeaderRowId + wrapTransmittalHeader.createdDate + wrapTransmittalHeader.depositBu + wrapTransmittalHeader.depositCnt + wrapTransmittalHeader.TotalAmt + '\n';
        return header;

    }
    
    public String printWrapTransmittalControl(wrapTransmittalControl wrapTransmittalControl){
        String depositControl = wrapTransmittalControl.depositControlRowId + wrapTransmittalControl.depositBu + wrapTransmittalControl.depositId.rightPad(15) 
                        + wrapTransmittalControl.accountingDate + wrapTransmittalControl.bankCd + wrapTransmittalControl.bankAcctkey 
                        + wrapTransmittalControl.Deposit_type + wrapTransmittalControl.controlCurrency + wrapTransmittalControl.zzBnkDepositNum + wrapTransmittalControl.zzIdentifier 
                        + wrapTransmittalControl.controlAmount2 +  wrapTransmittalControl.control_cnt + wrapTransmittalControl.received_Dt 
                        + wrapTransmittalControl.totalChecks + wrapTransmittalControl.flag + wrapTransmittalControl.bankOperNum + wrapTransmittalControl.zzLegDepId + '\n' ;
        
        return depositControl;
    }
    
    public String printWrapTransmittal(wrapTransmittal wrapTransmittal ){
        
        String paymentInformation = wrapTransmittal.paymentInformationRowId + wrapTransmittal.depositBu + wrapTransmittal.depositId.rightPad(15) + wrapTransmittal.paymentSeqNum
            + wrapTransmittal.paymentId + wrapTransmittal.accountingDate + wrapTransmittal.paymentAmt + wrapTransmittal.paymentCurrency +
            + wrapTransmittal.ppSw + wrapTransmittal.miscPayment + wrapTransmittal.Check_Dt + wrapTransmittal.zzPaymentMethod + wrapTransmittal.zzReceivedBySco + 
            + wrapTransmittal.zzCashType + wrapTransmittal.descr50Mixed + wrapTransmittal.document + wrapTransmittal.city + wrapTransmittal.county + wrapTransmittal.taxDesc + wrapTransmittal.lineNoteText.rightPad(254) + '\n';
        
        String customerId =  wrapTransmittal.customerInformationRowid + wrapTransmittal.depositBu + wrapTransmittal.depositId.rightPad(15) + wrapTransmittal.paymentSeqNum + 
            + wrapTransmittal.idSeqNumCustomer + /*l.Case_Violation__r.Customer_ID__c.rightPad(15)*/ + wrapTransmittal.customerId + '\n';
        
        String dist = wrapTransmittal.distributionLineRowid + wrapTransmittal.depositBu + wrapTransmittal.depositId.rightPad(15) + wrapTransmittal.paymentSeqNum + 
            + wrapTransmittal.idSeqNum + wrapTransmittal.businessUnitGl + wrapTransmittal.speedChartKey + wrapTransmittal.montetaryAmount.rightPad(28)
            + wrapTransmittal.account + wrapTransmittal.businessUnitPc + wrapTransmittal.projectId + wrapTransmittal.activityId + wrapTransmittal.resourceType + wrapTransmittal.resourceCategory +
            + wrapTransmittal.resourceSubCat + wrapTransmittal.analysisType + wrapTransmittal.operatingUnit + wrapTransmittal.Product + wrapTransmittal.fundCode + wrapTransmittal.classFld + wrapTransmittal.programCode 
            + wrapTransmittal.budgetRef + wrapTransmittal.affiliate + wrapTransmittal.affiliateIntra1 + wrapTransmittal.affiliateIntra2 + wrapTransmittal.chartField1 + wrapTransmittal.chartField2 
            + wrapTransmittal.chartField2 + wrapTransmittal.altAcct + wrapTransmittal.deptId + wrapTransmittal.padder + wrapTransmittal.budgetDT + '\n' ;
        
        return paymentInformation + customerId + dist;
    }
    
    
    public static String getDate() {
        Datetime cDT = System.now();
        String formattedDate = cdT.format('MMddyyyyHHmmss');
        return formattedDate;
    }
    
    public static String formatDate(Date d){
        Datetime cDT = DateTime.newInstance(d.year(), d.month(),d.day());
        String formattedDate = cdT.format('MMddyyyy');
        return formattedDate;
    }
    
    public static String formatDate1(Date d){
        Datetime cDT = DateTime.newInstance(d.year(), d.month(),d.day());
        String formattedDate = cdT.format('YYMMdd');
        return formattedDate;
    }
    
    public static String paymentMethod(String s1){
        if (s1.equalsIgnoreCase('OTHER'))
        {
            s1 = 'CSH';
        }
        else if(s1.equalsIgnoreCase('Check') || s1.equalsIgnoreCase('State Warrant'))
        {
            s1 = 'CHK';           
        }
        else if(s1.equalsIgnoreCase('Credit Card'))
        {
            s1= 'CC';
        }
        else if(s1.equalsIgnoreCase('EFT'))
        {
            s1 = 'EFT';             
        }
        else if(s1.equalsIgnoreCase('Money Order'))
        {
            s1 = 'MO';
        }
        else if(s1.equalsIgnoreCase('Cashier\'s Check'))
        {
            s1 = 'CCK';             
        }
        else if(s1.equalsIgnoreCase('Party to Party'))
        {
            s1 = '';
        }
        else if (s1.equalsIgnoreCase('Direct Payment'))
        {
            s1 = '';
        }
        else if (s1.equalsIgnoreCase('Deductions'))
        {
            s1 = '';
        }
        else{
            s1 = '';
        }
            
        return s1;
    }
    
    public static String getProgram(String accountingCode){
        String programCode = accountingCode.trim();
        
        //set program code to 6105005 for line005 when Account field form Accounting Code equals 4840000
        if(programCode.equalsIgnoreCase('4840000')){
            programCode = '6105005'.rightPad(10);
        }else{
            programCode = ''.rightPad(10);
        }
        return programCode;
    }
    
    public static String getBudgetRef(String accountingCode){
        String programCode = accountingCode.trim();
        
        //set BudgetRef(Appropriation Reference) to '001' for Reimbursement Account(4840000)
        if(programCode.equalsIgnoreCase('4840000')){
            programCode = '001'.rightPad(8);
        }else{
            programCode = ''.rightPad(8);
        }
        return programCode;
    }
    
    public static String getMonetaryValueSign(String PaymentAmt){
        String monetaryAmount = PaymentAmt;
        //if Payament amount is positive, Monetary Amount in line005 will be negataive and vice versa.
        if(monetaryAmount.contains('-')){
            monetaryAmount = monetaryAmount.replace('-', '');
        }else{
            monetaryAmount = '-' + monetaryAmount;
        }
        return monetaryAmount;
    }
    
    public static String getBudgetDate(String product, String accountingCode){
        String programCode = accountingCode.trim();
        String budgetDt = ''.rightPad(10);
        if(programCode.equalsIgnoreCase('4840000')){
            //if the enactmentYear(product) is the prior fiscal year, then the value should be June 30 of the previous fiscal year.
            if(Integer.valueOf(product.trim()) < currentFiscalYear){
                budgetDt = '0630' + String.valueOf((currentFiscalYear));
                budgetDt.rightPad(10);
            }else if(Integer.valueOf(product.trim()) == currentFiscalYear){
                budgetDt = '0630' + String.valueOf((currentFiscalYear + 1));
                budgetDt.rightPad(10);
            }
        }
        return budgetDt;
    }
    
    public static String getProduct(String fiscalYear){
        String product;
        if (Integer.valueOf(ifnull(fiscalYear,'0')) == currentFiscalYear){
            product = String.valueOf(currentFiscalYear).rightPad(6);
        }else{
            product = String.valueOf(currentFiscalYear - 1).rightPad(6);
        }
        
        return product;
    }
    
    //determine if customerId should be CSTARDLSEROLLUP or FISCALDLSEACCT
    public static String getCustomerID(Date citationDate, Date determinationDate){
        String customerId = 'CSTARDLSEROLLUP'.rightPad(15);
        if(citationDate >= determinationDate)
            customerId = 'FISCALDLSEACCT'.rightPad(15);
        return customerId;
    }
    
    public static String getZzLegDepId(Date bankDepositDate){
        String zzLegDepId;
        
        if(depositType.equalsIgnoreCase('R') && paymentMethod.equalsIgnoreCase('CHK')){
            zzLegDepId = 'BX' +  formatDate1(bankDepositDate) + '00'   ; //US Bank LockBox Naming convention for Legacy Deposit Slip Number
        }else if(depositType.equalsIgnoreCase('R') && paymentMethod.equalsIgnoreCase('EFT')){
            zzLegDepId = 'ST' +  formatDate1(bankDepositDate) + '01'   ; //Zero Balance Account Naming convention for Legacy Deposit Slip Number
        }else if(depositType.equalsIgnoreCase('Z')){
            zzLegDepId = 'ZB' +  formatDate1(bankDepositDate) + '00'   ; //Zero Balance Account Naming convention for Legacy Deposit Slip Number
        }

        return zzLegDepId;
    }
    
    public static String getPpsw(Liability_Payment__c lp, Applied_Accounting_Code__c aac){
        String ppSW = 'N'.rightPad(1);
        if(ifnull(lp.Payment_Applied_To__c,'').equalsIgnoreCase('Penalties')  && !ifnull(aac.Accounting_Code__r.current_doc__c,'').equalsIgnoreCase('NANA') 
           && Integer.valueOf(ifnull(lp.Case_Violation__r.Fiscal_Year__c,'0')) >  twoFiscalYear)
        {
            ppSW = 'N'.rightPad(1); //changed to N since all the lines will be countes as 005 temporarily. May change later          
        }
        
        return ppSW;
    }
    
     public static String getMiscPayment(Liability_Payment__c lp, Applied_Accounting_Code__c aac){
        String miscPayment = 'Y'.rightPad(1);
        if(ifnull(lp.Payment_Applied_To__c,'').equalsIgnoreCase('Penalties')  && !ifnull(aac.Accounting_Code__r.current_doc__c,'').equalsIgnoreCase('NANA') 
           && Integer.valueOf(ifnull(lp.Case_Violation__r.Fiscal_Year__c,'0')) >  twoFiscalYear)
        {
            miscPayment = 'Y'.rightPad(1);//changed to Y since all the lines will be countes as 005 temporarily. May change later          
        }
         
        return miscPayment;
    }
    
    public static String setFlag(String depositSlipNumber, String flag ){
        if(depositSlipNumber == null || String.isEmpty(depositSlipNumber) ) {flag = 'N';}
        return flag;
    }
    
    public static String setBankOperNum(String flag, String assignedBankNumber){
        if(!flag.equalsIgnoreCase('Y')) {assignedBankNumber = '';}
        return assignedBankNumber;   
    }
    
    public static integer ifnull(integer s1,integer s2) {
        integer result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }
    
    public static decimal ifnull(decimal s1,decimal s2) {
        decimal result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }
    
    public static String ifnull(String s1,String s2) {
        String result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }
       
    public static boolean ifnull(boolean s1,boolean s2) {
        boolean result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }
    
    private static boolean checkRequiredFields(Date bankDepositDate1, String depositId){
        Boolean checkRequiredFields = true;
        
        if(bankDepositDate1 == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Bank Deposit Date is required.'));
            checkRequiredFields = false; 
        }
        
        if(String.isEmpty(depositId)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Deposit ID is required.'));
            checkRequiredFields = false;
        }
        
        return checkRequiredFields;
        
    }
    
    private static integer getCurrentFY() {
        Organization orgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName
                                FROM Organization
                                WHERE id=:Userinfo.getOrganizationId()];
        Date today = system.today();
        Integer currentFY;
        if (today.month() >= orgInfo.FiscalYearStartMonth) {
            if (orgInfo.UsesStartDateAsFiscalYearName) {
                currentFY = today.year();
            } else {
                currentFY = today.year() + 1;
            }
        } else {
            if (orgInfo.UsesStartDateAsFiscalYearName) {
                currentFY = today.year() - 1;
            } else {
                currentFY = today.year();
            }
        }
        return currentFY;
    }
    
    private static integer getCurrentFY(Date fyBankDepositDate) {
        Organization orgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName
                                FROM Organization
                                WHERE id=:Userinfo.getOrganizationId()];
        
        Integer currentFY;
        if (fyBankDepositDate.month() >= orgInfo.FiscalYearStartMonth) {
            if (orgInfo.UsesStartDateAsFiscalYearName) {
                currentFY = fyBankDepositDate.year();
            } else {
                currentFY = fyBankDepositDate.year() + 1;
            }
        } else {
            if (orgInfo.UsesStartDateAsFiscalYearName) {
                currentFY = fyBankDepositDate.year() - 1;
            } else {
                currentFY = fyBankDepositDate.year();
            }
        }
        return currentFY;
    }
    
    /*
    private static List<Case_Payment__c> sortByChildDate(List<Case_Payment__c> parents) {
        Map<Id, Case_Payment__c> parentMap = new Map<Id, Case_Payment__c>(parents);
        List<Case_Payment__c> retList = new List<Case_Payment__c>();
        
        for (AggregateResult aggRes : [
            SELECT MAX(Receipt__r.Payment_group__r.createdDate), Case_Payment__c parentId
            FROM Receipt__c
            WHERE Case_Payment__c IN :parentMap.keySet()
            GROUP BY Case_Payment__c
            ORDER BY MAX(Receipt__r.Payment_group__r.createdDate) DESC
        ]) {
            Id parentId = (Id) aggRes.get('parentId');
            retList.add(parentMap.get(parentId));
        }
        return retList;
        
    }
    
    private static List<Payment_Group__c> sortByChildDate1(List<Payment_Group__c> parents) {
        Map<Id, Payment_Group__c> parentMap = new Map<Id, Payment_Group__c>(parents);
        List<Payment_Group__c> retList = new List<Payment_Group__c>();
        
        for (AggregateResult aggRes : [
            SELECT MAX(Bank_Deposit_Date__c), Payment_Group__c parentId
            FROM Payment_Log__c
            WHERE Payment_Group__c IN :parentMap.keySet()
            GROUP BY Payment_Group__c
            ORDER BY MAX(Bank_Deposit_Date__c) DESC
        ]) {
            Id parentId = (Id) aggRes.get('parentId');
            retList.add(parentMap.get(parentId));
        }
        return retList;
        
    }
    */
    
    private static void sendJobCompleteEmail(String AR){
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(AR);
        string csvname= '7350_AR018_DLSE_' + getDate() + '_' + depositId + '.txt' ;
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        // Grab your Custom Setting values
        Key_Value_Store__c settings = Key_Value_Store__c.getInstance('AR018 Email Group');
        String emailGroup = settings.Value__c;
        String[] toAddresses = emailGroup.split(',');
        String subject ='Bank Deposit Date: ' + bankDepositDate1.format()  ;
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Attached is AR018 interface for Bank Deposit Date ' + bankDepositDate1.format() );
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'AR018 Interface is sent to' + toAddresses));
    }
}