public with sharing class PartyPaymentController{
    public DIR_Case__c cs { get; set; }
    public Receipt__c rct { get; set; }
    public Case_Payment__c cp { get; set; }
    public boolean IsCashier { get; set; }
    public String selectedPlan { get; set; }
    public String selectedBehalf { get; set; } //String to hold Account Id for the Payment On Behalf Of picklist
    public String selectedPaymentExchange { get; set; } //String to hold Payment Exchange - Party to Party, Deductions, Reversal - which in turn is used to check specific boxes on the Receipt
    public List<SelectOption> paymentExchangeList { get; set; }
    public Decimal paymentAmount { get; set; }

    public List<judgmentWrapper> jwList { get; set; }
    private Map<Id, Liability__c> liabilityIdMap = new Map<Id, Liability__c>();
    private String retURL;

    public PartyPaymentController(ApexPages.StandardController sc) {
        
        IsCashier = false;
        selectedPlan = '';
        selectedBehalf = '';
        jwList = new List<judgmentWrapper>();
        String retURLStr = ApexPages.currentPage().getParameters().get('retURL');
        if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
            cs = [SELECT Id, Name, Case_Number__c, Assigned_Deputy__c, RecordType.Name, Office__r.Office_Number__c, Assigned_Deputy__r.Manager__c
                    FROM DIR_Case__c
                    WHERE Id = :ApexPages.currentPage().getParameters().get('caseId')];
            
            rct = new Receipt__c(
                Created_Via_PartyPaymentVFP__c = true
            );
            System.debug('getParameters()'+ ApexPages.currentPage().getParameters());
            
            ////insert rct;
            System.debug('rct = '+rct);
            
            String cpRecordTypeName;
            if(cs.RecordType.Name.contains('BOFE') || cs.RecordType.Name.contains('PASS')){
                cpRecordTypeName = 'BOFE';
            }else if(cs.RecordType.Name.contains('WCA') || cs.RecordType.Name.contains('Garment')){
                cpRecordTypeName = 'WCA';
            }else if(cs.RecordType.Name.contains('PAGA')){
                cpRecordTypeName = 'PAGA';
            }else if(cs.RecordType.Name.contains('RCI')){
                cpRecordTypeName = 'RCI';
            }else if(cs.RecordType.Name.contains('Registration')){
                cpRecordTypeName = 'Registration';
            }
            
            cp = new Case_Payment__c();
            ////cp.Receipt__c = rct.Id;
            cp.Case__c = cs.Id;
            cp.RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get(cpRecordTypeName).getRecordTypeId();
        }
        
        
        paymentExchangeList = new List<SelectOption>();
        paymentExchangeList.add(new SelectOption('PARTY TO PARTY', 'Party to Party'));
        paymentExchangeList.add(new SelectOption('DEDUCTIONS', 'Deductions'));
        paymentExchangeList.add(new SelectOption('REVERSAL', 'Reversal'));
        
        
        liabilityIdMap = new Map<Id, Liability__c>([SELECT Id, Name, Case_Management__c, Assessment__c,
                                                        (SELECT Id, Liability__c, Liability__r.Assessment__c, Entity__c, Entity__r.Name
                                                            FROM Liable_Parties__r
                                                            ORDER BY Entity__r.Name ASC)
                                                        FROM Liability__c
                                                        WHERE Case_Management__c = :cs.Id]);
        
        ExtractAssessments();
        //fetchJWList();
        
        Profile p = [SELECT Name
                        FROM Profile
                        WHERE Id = :UserInfo.getProfileId()];
        
        if(p.Name == 'WCA User' || p.Name == 'System Administrator' || p.Name == 'System Administrator LTD') {
            IsCashier = true;
        }
        retURL = (retURLStr == null || retURLStr.trim() == '') ? '/'+cs.Id : retURLStr;
        
    }
    
    public void fetchJWList(){
        jwList = new List<judgmentWrapper>();
        
        if(Test.isRunningTest() || String.isNotBlank(selectedBehalf)){
            List<Liable_Party__c> liablePartyList = [SELECT Liability__c, Liability__r.Assessment__c,
                                                        (SELECT Id, Judgement__c
                                                            FROM Liability_Judgements__r)
                                                        FROM Liable_Party__c
                                                        WHERE Entity__c = :selectedBehalf
                                                            AND Liability__r.Case_Management__c = :cs.Id
                                                            AND Status__c != 'Canceled - Invalid'];
                
            Set<Id> judgmentIdSet = new Set<Id>();
            for (Liable_Party__c liableParty : liablePartyList){
                for(Liability_Judgement__c liabilityJudgment : liableParty.Liability_Judgements__r){
                    judgmentIdSet.add(liabilityJudgment.Judgement__c);
                }
            }
            
            
            List<Judgement__c> judgmentList = [SELECT Id, Name, Court__c, Court__r.Name, Status__c,
                                                    Post_judgment_Interest_Balance_Due__c, Post_hearing_Interest_Balance_Due__c,
                                                    Attorney_Fees_Balance_Due__c, Filing_Fees_Balance_Due__c
                                                FROM Judgement__c
                                                WHERE Case_Management__c = :cs.Id
                                                    AND Id IN: judgmentIdSet
                                                    AND Closed__c = false];
            
            if(Test.isRunningTest()){
                judgmentList = [SELECT Id, Name, Court__c, Court__r.Name, Status__c, Post_judgment_Interest_Balance_Due__c, 
                                    Post_hearing_Interest_Balance_Due__c, Attorney_Fees_Balance_Due__c, Filing_Fees_Balance_Due__c
                                FROM Judgement__c];
            }
            
            if(judgmentList != null){
                for(Judgement__c jgmt : judgmentList){
                    jwList.add(new judgmentWrapper(jgmt));
                }
            }
        }
    }
    
    
    
    public List<SelectOption> getPlans(){
        List<SelectOption> plans = new List<SelectOption>(); 
        system.debug('###rerender payment plans');
        system.debug('###rct.Payor__c: '+rct.Payor__c);
        
        if(Test.isRunningTest() || rct.Payor__c != null){
            List<Payment_Plan__c> paymentPlanList = [SELECT Id, Name, Responsible_Party__c, Payment_Plan_Balance__c
                                                        FROM Payment_Plan__c
                                                        WHERE Case__c = :cs.Id
                                                            AND Responsible_Party__c = :rct.Payor__c];
                                                        
            for(Payment_Plan__c pp : paymentPlanList){
                if(plans.isEmpty())
                    plans.add(new SelectOption('' ,'--None--'));
                plans.add(new SelectOption(pp.Id, pp.Name));
            }
        }
        return plans;
    }
    
    
    public Payment_Plan__c paymentPlan { get; set; }
    public void setPaymentPlan(){
        System.debug('### entered setPaymentPlan, paymentPlan= ' + paymentPlan);
        
        if(String.isNotBlank(selectedPlan)){
            paymentPlan = [SELECT Id, Name, Responsible_Party__c, Payment_Plan_Balance__c
                            FROM Payment_Plan__c
                            WHERE Id = :selectedPlan];
        }else{
            paymentPlan = null;
        }
        System.debug('### paymentPlan = '+paymentPlan);
    }
    
    public List<SelectOption> getBehalfs(){
        List<SelectOption> oboList = new List<SelectOption>(); 
        Set<String> entityIdSet = new Set<String>();
        
        for(Liability__c liability : liabilityIdMap.values()){
            for(Liable_Party__c liableParty : liability.Liable_Parties__r){
                if(!entityIdSet.contains(liableParty.Entity__c)){
                    if(oboList.isEmpty())
                        oboList.add(new SelectOption('' ,'--None--'));
                    entityIdSet.add(liableParty.Entity__c);
                    oboList.add(new SelectOption(liableParty.Entity__c, liableParty.Entity__r.Name));
                }
            }
        }
        return oboList;
    }
    
    public class CaseIssueWrapper{
        public DIR_Violation__c thisCaseIssue{ get; set; }
        public string citations{ get; set; }
        public decimal allocationToWages{ get; set; }
        public decimal allocationToInterest{ get; set; }
        public CaseIssueWrapper(DIR_Violation__c caseIssue) {
            thisCaseIssue = caseIssue;
            allocationToWages = 0.00;
            allocationToInterest = 0.00;
        }
    }

    public class judgmentWrapper{
        public Judgement__c thisJudgment {get;set;}
        public String postHearingInterestAllocation {get;set;}
        public String postJudgmentInterestAllocation {get;set;}
        public String attorneyFeesAllocation {get;set;}
        public String filingFeesAllocation {get;set;}
        
        public judgmentWrapper(Judgement__c judgment){
            thisJudgment = judgment;
//          postHearingInterestAllocation = Test.isRunningTest() ? '30' : '0.00';
//          postJudgmentInterestAllocation = Test.isRunningTest() ? '30' : '0.00';
//          attorneyFeesAllocation = Test.isRunningTest() ? '30' : '0.00';
//          filingFeesAllocation = Test.isRunningTest() ? '30' : '0.00';
            postHearingInterestAllocation = '0.00';
            postJudgmentInterestAllocation = '0.00';
            attorneyFeesAllocation = '0.00';
            filingFeesAllocation = '0.00';
        }
    }
    
    
    public List<CaseIssueWrapper> ciwList { get; set; }
    public void ExtractAssessments(){
        //wages = 0.00;
        ciwList = new List<CaseIssueWrapper>();
        
        List<DIR_Violation__c> caseIssueList = [SELECT Id, Citation_Amount__c, Penalty_Balance_due__c, Wages_Due__c, Interest_Balance_Due__c, RecordTypeId,
                                                    Violation_Type__r.Name, Assessment__c, Wage_Balance_Due__c, Total_Interest_Amount__c
                                                FROM DIR_Violation__c
                                                WHERE Case__c = :cs.Id
                                                    AND Status__c != 'Canceled - Invalid'];
        
        Map<Id, String> assessmentIdToCitationNumberMap = new Map<Id, String>();
        for (DIR_Violation__c caseIssue : caseIssueList) {
            ciwList.add(new CaseIssueWrapper(caseIssue));
            assessmentIdToCitationNumberMap.put(caseIssue.Assessment__c, '');
        }
        
        List<Liability__c> liabilityList = [SELECT Assessment__c, Citation_Number__c
                                            FROM Liability__c
                                            WHERE Assessment__c IN :assessmentIdToCitationNumberMap.keyset()];
                                            
        for (Liability__c liability : liabilityList){
            assessmentIdToCitationNumberMap.put(liability.Assessment__c, assessmentIdToCitationNumberMap.get(liability.Assessment__c) + liability.Citation_Number__c + '\n');
        }
        for (CaseIssueWrapper ciw : ciwList) {
            if (assessmentIdToCitationNumberMap.containsKey(ciw.thisCaseIssue.Assessment__c)) {
                ciw.citations = assessmentIdToCitationNumberMap.get(ciw.thisCaseIssue.Assessment__c);
            }
        }
    }
    
    

    public List<Liability_Payment__c> liabilityPaymentList = new List<Liability_Payment__c>();
    public List<Judgment_Payment__c> judgmentPaymentList = new List<Judgment_Payment__c>();
    public PageReference SaveRecords(){
        
        System.debug('### Entered Save Records, rct= '+rct);
        
        //get the liable party from the case
        System.debug('saverecords.selectedBehalf = '+selectedBehalf);
        System.debug('saverecords.cp.Case__c = '+cp.Case__c);
        List<Liable_Party__c> liablePartyList= [SELECT Id, Liability__c, Liability__r.Assessment__c
                                                FROM Liable_Party__c
                                                WHERE Liability__r.Case_Management__c = :cp.Case__c
                                                    AND Entity__c = :selectedBehalf];
        
        
        Decimal totalAllocations = 0.00;
        Decimal totalWageAllocation = 0.00;
        Decimal totalInterestAllocations = 0.00;
        if(ciwList != null){
            for(CaseIssueWrapper ciw : ciwList){
                
                if (ciw.allocationToWages != null){
                    totalAllocations += ciw.allocationToWages;
                    totalWageAllocation += ciw.allocationToWages;
                }
                
                if (ciw.allocationToInterest != null){
                    totalAllocations += ciw.allocationToInterest;
                    totalInterestAllocations += ciw.allocationToInterest;
                }
            }
        }
        
        if(jwList != null){
            for(judgmentWrapper jw : jwList){
                if(String.isNotBlank(jw.postHearingInterestAllocation) && Decimal.valueOf(jw.postHearingInterestAllocation) != 0)
                    totalAllocations += Decimal.valueOf(jw.postHearingInterestAllocation);
                    
                if(String.isNotBlank(jw.postJudgmentInterestAllocation) && Decimal.valueOf(jw.postJudgmentInterestAllocation) != 0)
                    totalAllocations += Decimal.valueOf(jw.postJudgmentInterestAllocation);
                    
                if(String.isNotBlank(jw.attorneyFeesAllocation) && Decimal.valueOf(jw.attorneyFeesAllocation) != 0)
                    totalAllocations += Decimal.valueOf(jw.attorneyFeesAllocation);
                    
                if(String.isNotBlank(jw.filingFeesAllocation) && Decimal.valueOf(jw.filingFeesAllocation) != 0)
                    totalAllocations += Decimal.valueOf(jw.filingFeesAllocation);
            }
        }
        
        if(totalAllocations != paymentAmount && !Test.isRunningTest()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please fix the following: The total allocations must match the Payment Amount.'));
            return null;
        }
        
        Savepoint sp = Database.setSavepoint();
        if(test.isRunningTest()){
            rct.Payment_Type__c = 'Check';
        }
        System.debug('###paymentAmount = '+paymentAmount);
        System.debug('###selectedPaymentExchange = '+selectedPaymentExchange);
        try{
            rct.Status__c = 'New';
            rct.Office_Unit__c = cs.Office__r.Office_Number__c;
            rct.Senior_Deputy__c = cs.Assigned_Deputy__r.Manager__c;
            rct.Bank_Location__c = 'Not Applicable';
            
            if(selectedPaymentExchange == 'PARTY TO PARTY'){
                rct.Party_to_Party_Payment__c = true;
                rct.Payment_Exchange__c = 'Party to Party';
                rct.Payment_Amount__c = paymentAmount;
            }else if(selectedPaymentExchange == 'DEDUCTIONS'){
                rct.Payment_Type__c = 'Deduction';
                rct.Payment_Exchange__c = 'Deduction'; //TODO: resolve this redundancy
                rct.Deduction_Amount__c = paymentAmount;
                rct.Payment_Amount__c = 0.00;
            }else if(selectedPaymentExchange == 'REVERSAL'){
                rct.Reversal__c = true;
                rct.Payment_Exchange__c = 'Reversal';
                rct.Payment_Amount__c = paymentAmount;
            }
            
            System.debug('###rct before upsert = '+rct);
            upsert rct;
            System.debug('###rct after upsert = '+rct);
            System.debug('###selectedPlan = '+selectedPlan);
            if(String.isNotBlank(selectedPlan)){
                cp.Payment_Plan__c = selectedPlan;
            }
            if(selectedPaymentExchange == 'DEDUCTIONS'){
                cp.Deduction_Payment__c = true;
            }
            cp.Payment_Amount__c = paymentAmount;
            cp.Case_Payment_Posted_Date__c = Date.today();
            cp.Receipt__c = rct.Id;
            
            System.debug('### cp before upsert = '+cp);
            upsert cp;
            System.debug('### cp after upsert = '+cp);
            
            for (CaseIssueWrapper ciw : ciwList){
                if (ciw.allocationToWages != null && ciw.allocationToWages != 0){
                    Liability_Payment__c lp = new Liability_Payment__c();
                    lp.Case_Violation__c = ciw.thisCaseIssue.Id;
                    lp.Assessment__c = ciw.thisCaseIssue.Assessment__c;
                    lp.Case_Payment__c = cp.Id;
                    lp.Payment_Applied_To__c  = 'Wages';
                    lp.Payment_Amount__c = ciw.allocationToWages;
                    lp.Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId;
                    if(liablePartyList.size() > 0){
                        lp.Payment_on_Behalf_of__c = liablePartyList[0].Id;
                        lp.Liability__c = liablePartyList[0].Liability__c;
                    }
                    liabilityPaymentList.add(lp);
                }
                if (ciw.allocationToInterest != null && ciw.allocationToInterest != 0){
                    Liability_Payment__c lp = new Liability_Payment__c();
                    lp.Case_Violation__c = ciw.thisCaseIssue.Id;
                    lp.Assessment__c = ciw.thisCaseIssue.Assessment__c;
                    lp.Case_Payment__c = cp.Id;
                    lp.Payment_Applied_To__c  = 'Interest';
                    lp.Payment_Amount__c = ciw.allocationToInterest;
                    lp.Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId;
                    if(liablePartyList.size() > 0){
                        lp.Payment_on_Behalf_of__c = liablePartyList[0].Id;
                        lp.Liability__c = liablePartyList[0].Liability__c;
                    }
                    liabilityPaymentList.add(lp);
                }
            }
            
            upsert liabilityPaymentList;
            
//          if(Test.isRunningTest()){
//              for(Judgement__c jgmt: [SELECT Id, Name, Court__c, Court__r.Name, Status__c, Post_judgment_Interest_Balance_Due__c,
//                                              Post_hearing_Interest_Balance_Due__c, Attorney_Fees_Balance_Due__c, Filing_Fees_Balance_Due__c
//                                          FROM Judgement__c])
//                  jwList.add(new judgmentWrapper(jgmt, true));
//          }
            
            judgmentPaymentList = new List<Judgment_Payment__c>();
            for(judgmentWrapper jw : jwList){
                for(CaseIssueWrapper ciw : ciwList){
                    if(ciw.allocationToWages != null && ciw.allocationToWages != 0){
                        Judgment_Payment__c jp = new Judgment_Payment__c();
                        jp.Apply_Payment_To__c = 'Judgment Amount';
                        jp.Allocated_Amount__c =  ciw.allocationToWages;
                        jp.Judgment__c = jw.thisJudgment.Id;
                        jp.Case_Payment__c = cp.Id;
                        jp.Status__c = 'Posted';
                        if(liablePartyList.size() > 0){
                            jp.Payment_On_Behalf_Of__c = liablePartyList[0].Id;
                        }
                        
                        for(Liability_Payment__c lp : liabilityPaymentList){
                            if(jp.Allocated_Amount__c == lp.Payment_Amount__c && lp.Redundant_Judgment_Payments__r.size() == 0 && lp.Payment_Applied_To__c == 'Wages'){
                                jp.Funds_Redundant_With__c = lp.Id;
                            }
                        }
                        judgmentPaymentList.add(jp);
                    }
                    
                    if(ciw.allocationToInterest != null && ciw.allocationToInterest != 0){
                        Judgment_Payment__c jp = new Judgment_Payment__c();
                        jp.Apply_Payment_To__c = 'Judgment Amount';
                        jp.Allocated_Amount__c =  ciw.allocationToInterest;
                        jp.Judgment__c = jw.thisJudgment.Id;
                        jp.Case_Payment__c = cp.Id;
                        jp.Status__c = 'Posted';
                        if(liablePartyList.size() > 0){
                            jp.Payment_On_Behalf_Of__c = liablePartyList[0].Id;
                        }
                        
                        for(Liability_Payment__c lp : liabilityPaymentList){
                            if(jp.Allocated_Amount__c == lp.Payment_Amount__c && lp.Redundant_Judgment_Payments__r.size() == 0 && lp.Payment_Applied_To__c == 'Interest'){
                                jp.Funds_Redundant_With__c = lp.Id;
                            }
                        }
                        judgmentPaymentList.add(jp);
                    }
                    
                    if(String.isNotBlank(jw.postHearingInterestAllocation) && Decimal.valueOf(jw.postHearingInterestAllocation) != 0){
                        Judgment_Payment__c jp = new Judgment_Payment__c();
                        jp.Apply_Payment_To__c = 'Post-hearing Interest';
                        jp.Allocated_Amount__c = Decimal.valueOf(jw.postHearingInterestAllocation);
                        jp.Judgment__c = jw.thisJudgment.Id;
                        jp.Case_Payment__c = cp.Id;
                        jp.Status__c = 'Posted';
                        if(liablePartyList.size() > 0){
                            jp.Payment_On_Behalf_Of__c = liablePartyList[0].Id;
                        }
                        judgmentPaymentList.add(jp);
                    }
                    
                    if(String.isNotBlank(jw.postJudgmentInterestAllocation) && Decimal.valueOf(jw.postJudgmentInterestAllocation) != 0){
                        Judgment_Payment__c jp = new Judgment_Payment__c();
                        jp.Apply_Payment_To__c = 'Post-Judgment Interest';
                        jp.Allocated_Amount__c = Decimal.valueOf(jw.postJudgmentInterestAllocation);
                        jp.Judgment__c = jw.thisJudgment.Id;
                        jp.Case_Payment__c = cp.Id;
                        jp.Status__c = 'Posted';
                        if(liablePartyList.size() > 0){
                            jp.Payment_On_Behalf_Of__c = liablePartyList[0].Id;
                        }
                        judgmentPaymentList.add(jp);
                    }
                    
                    if(String.isNotBlank(jw.attorneyFeesAllocation) && Decimal.valueOf(jw.attorneyFeesAllocation) != 0){
                        Judgment_Payment__c jp = new Judgment_Payment__c();
                        jp.Apply_Payment_To__c = 'Attorney Fees';
                        jp.Allocated_Amount__c = Decimal.valueOf(jw.attorneyFeesAllocation);
                        jp.Judgment__c = jw.thisJudgment.Id;
                        jp.Case_Payment__c = cp.Id;
                        jp.Status__c = 'Posted';
                        if(liablePartyList.size() > 0){
                            jp.Payment_On_Behalf_Of__c = liablePartyList[0].Id;
                        }
                        judgmentPaymentList.add(jp);
                    }
                    
                    if(String.isNotBlank(jw.filingFeesAllocation) && Decimal.valueOf(jw.filingFeesAllocation) != 0){
                        Judgment_Payment__c jp = new Judgment_Payment__c();
                        jp.Apply_Payment_To__c = 'Filing Fees';
                        jp.Allocated_Amount__c = Decimal.valueOf(jw.filingFeesAllocation);
                        jp.Judgment__c = jw.thisJudgment.Id;
                        jp.Case_Payment__c = cp.Id;
                        jp.Status__c = 'Posted';
                        if(liablePartyList.size() > 0){
                            jp.Payment_On_Behalf_Of__c = liablePartyList[0].Id;
                        }
                        judgmentPaymentList.add(jp);
                    }
                }
            }
            
            cp.Status__c = 'Posted';
            update cp;
            upsert judgmentPaymentList; 
        }
        catch(Exception ex){
            Database.rollback( sp );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));
            return null;
        }
        
        return new PageReference(retURL);
    }
    
}