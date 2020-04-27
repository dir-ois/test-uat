/* There is a systemic issue elsewhere (code? user error?) where Liable Party Case Issue records are being
    created without a parent Liable Party. 
    Amended this code to ignore LPCIs with those null values to prevent a 'de-reference null object' apex
    error, (search for "LPCI fix": just 2 conditonal tests).
    However, this may cause
        certain POBOs from appearing in the VFP dropdown
        certain Case Issues or Judgments from appearing on the VFP
        some of the "redundant" Judgment Payments may not be created
        some of the "redundant" Judgment Payments may not be linked to their "redundant" Liability Payment */
        
public with sharing class PostCasePaymentController{ //TODO: transient variables. prs? wrapperMaps?
    
    public Case_Payment__c casePayment{get; set;}
    public DIR_Case__c DIRcase{get; set;}
    public Receipt__c receipt{get;set;}
    public List<Payee__c> allPayeeList{get;set;}

    public Decimal allocToPenalties{get;set;}
    public Decimal allocToWages{get;set;}
    public Decimal allocToInterest{get;set;}
    public Decimal allocToPostHearingInt{get;set;}
    public Decimal allocToPostJudgmentInt{get;set;}
    public Decimal allocToAttorneyFees{get;set;}
    public Decimal allocToFilingFees{get;set;}
    public Decimal holdAmount{get;set;}
    public Decimal otherRefund{get;set;}
    public Decimal DIRAttorneyFees{get;set;}
    public Decimal amtRemain{get;set;}

    public boolean isDeposited{get;set;}
    public boolean isCashier{get; set;}
    public String selectedOBO{get;set;} ////string to hold Case Role Ids, or 'ALL' - used to filter Case Issues and Judgments on VFP
    public List<SelectOption> oboList{get;set;}
    public boolean isBOFECase{get;set;}
    public boolean isRCICase{get;set;}
    public boolean printView{get;set;}
    public boolean renderPostBtn{get;set;}
    public boolean renderRecommendBtn{get;set;}
    public boolean renderThirdBtn{get;set;}
    public boolean thirdButtonClicked{get;set;}
    //public string whichCIsAndJsToDisplay{get; set;}

    public boolean hasBeenRecommended{get; set;}
    public boolean hasBeenPosted{get; set;}
    
    private List<DIR_Violation__c> allCaseIssueList = new List<DIR_Violation__c>();
    private List<Judgement__c> allJudgmentList = new List<Judgement__c>();
    private List<Case_Role__c> allCaseRoleList = new List<Case_Role__c>();
    //private List<Liability__c> allLiabilityList = new List<Liability__c>();
    public List<Liable_Party__c> allLiablePartyList = new List<Liable_Party__c>();

    private List<Liability_Payment__c> allLPList = new List<Liability_Payment__c>();
    private List<Judgment_Payment__c> allJPList = new List<Judgment_Payment__c>();
    //private List<Liable_Party_Case_Issue__c> allLPCIList = new List<Liable_Party_Case_Issue__c>();
    
    private Id bofeRT = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId();
    private Id wcaRT = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId();
    private Id rciRT = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
    
    private String retURL;


    public PostCasePaymentController(ApexPages.StandardController sc){
        System.debug('### entering PostCasePayment.PostCasePayment: sc.getId() = ' + sc.getId());
        printView = String.isBlank(ApexPages.currentPage().getParameters().get('printView')) ? false : true;
        hasBeenRecommended = false;
        hasBeenPosted = false; 
        isBOFECase = false;
        isRCICase = false;
        isCashier = false;
        thirdButtonClicked = false;
        //amtRemain = 0.00;
        selectedOBO = 'ALL';
        String retURLStr = ApexPages.currentPage().getParameters().get('retURL');
        
        casePayment = [SELECT Id, Name, Status__c, Case_Payment_Recommended_Date__c, Case_Payment_Posted_Date__c, Payor__c,
                            Payment_Classification__c, Date_Funds_Mailed_to_Employee__c, Deposited__c,
                            Hold_Amount__c, Hold_Review_Date__c, Hold_For__c, Hold_For_Other__c, Hold_Explanation__c,
                            Other_Refund__c, Other_Refund_Specify__c,
                            Payment_Amount__c, Payment_Terms__c, Payment_Terms_Other__c,
                            Mailing_Instructions__c, Receipt_Hold_Date__c, Public_Works_Penalties__c, Apprenticeship_Penalties__c,
                            California_Apprenticeship_Council__c, Special_Instructions__c, CA_Apprenticeship_Council_Craft__c,
                            CA_Apprenticeship_County__c, CPR_only__c, CPR_Refund__c, 
                            DIR_Attorney_Fees__c, DIR_Attorney_Fees_Explanation__c,
                            CMU_Reimbursement__c, Returned_Item__c, Voided_Item__c,
                            
                            Case__c, Case__r.Name, Case__r.Case_Number__c, Case__r.RecordType.DeveloperName, Case__r.RecordType.Name,
                            Case__r.Assigned_Deputy__c, Case__r.Closed__c, Case__r.Reason_For_Closing__c, Case__r.Case_Closed_Date__c, Case__r.Purge_Date__c,
                            
                            Receipt__c, Receipt__r.Id, Receipt__r.Deposit_Account__c, Receipt__r.Status__c, Receipt__r.Payor__c, Receipt__r.Payor__r.Id, Receipt__r.Instrument_Number__c, Receipt__r.Date_Received__c,
                            
                            Payment_Plan__c, Payment_Plan__r.Id, Payment_Plan__r.Payment_Plan_Balance__c,
                            
                            (SELECT Id, Name, Payment_Amount__c, Payment_Applied_To__c, Payment_on_Behalf_of__c, Payment_on_Behalf_of__r.Case_Role__c, Recommended_Allocation__c, Case_Issue_RecordTypeId__c,
                                    Case_Violation__c, Case_Violation__r.Id, Case_Violation__r.Name, Case_Violation__r.Assessment__c, Case_Violation__r.Assessment__r.Citation_Number__c, Case_Violation__r.Assessment__r.JEU_Case_number__c,
                                    Case_Violation__r.Case__c, Case_Violation__r.Case__r.Id, Case_Violation__r.Violation_Type__c,
                                    Case_Violation__r.Violation_Type__r.Name,
                                    Case_Violation__r.Citation_Amount__c, Case_Violation__r.Wages_Due__c,
                                    Case_Violation__r.Wage_Balance_Due__c, Case_Violation__r.Total_Interest_Amount__c,
                                    Case_Violation__r.Interest_Balance_Due__c, Case_Violation__r.Penalty_Balance_Due__c, Case_Violation__r.RecordTypeId,
                                    Case_Payment__c, Case_Payment__r.Receipt__c, Case_Payment__r.Receipt__r.Deposit_Account__c
                                FROM Liability_Payments__r),
                            
                            (SELECT Id, Name, Allocated_Amount__c, Apply_Payment_To__c, Payment_On_Behalf_Of__c, Recommended_Amount__c, Funds_Redundant_With__c, Funds_Redundant_With__r.Id,
                                Judgment__c, Judgment__r.Id, Judgment__r.Name
                                FROM Judgment_Payments__r)
                            
                        FROM Case_Payment__c
                        WHERE Id = :sc.getId()];
        // System.debug('###casePayment = ' + casePayment);
        
        
        // System.debug('### allocToPenalties = '+allocToPenalties);
        // System.debug('### allocToWages = '+allocToWages);
        // System.debug('### allocToInterest = '+allocToInterest);
        // System.debug('### allocToPostHearingInt = '+allocToPostHearingInt);
        // System.debug('### allocToPostJudgmentInt = '+allocToPostJudgmentInt);
        // System.debug('### allocToAttorneyFees = '+allocToAttorneyFees);
        // System.debug('### allocToFilingFees = '+allocToFilingFees);
        // System.debug('### holdAmount = '+holdAmount);
        // System.debug('### otherRefund = '+otherRefund);
        // System.debug('### DIRAttorneyFees = '+DIRAttorneyFees);
        // System.debug('### amtRemain = ' + amtRemain);
        
        allocToPenalties = allocToPenalties == null ? 0.00 : allocToPenalties;
        allocToWages = allocToWages == null ? 0.00 : allocToWages;
        allocToInterest = allocToInterest == null ? 0.00 : allocToInterest;
        allocToPostHearingInt = allocToPostHearingInt == null ? 0.00 : allocToPostHearingInt;
        allocToPostJudgmentInt = allocToPostJudgmentInt == null ? 0.00 : allocToPostJudgmentInt;
        allocToAttorneyFees = allocToAttorneyFees == null ? 0.00 : allocToAttorneyFees;
        allocToFilingFees = allocToFilingFees == null ? 0.00 : allocToFilingFees;
        holdAmount = holdAmount == null ? 0.00 : holdAmount;
        otherRefund = otherRefund == null ? 0.00 : otherRefund;
        DIRAttorneyFees = DIRAttorneyFees == null ? 0.00 : DIRAttorneyFees;
        
        amtRemain = casePayment.Payment_Amount__c - allocToPenalties - allocToWages - allocToInterest -
                allocToPostHearingInt - allocToPostJudgmentInt - allocToAttorneyFees - allocToFilingFees -
                holdAmount - otherRefund - DIRAttorneyFees;
        if(casePayment.Status__c == 'Allocations Recommended'){
            hasBeenRecommended = true;
        }
        if(casePayment.Status__c == 'Posted'){
            hasBeenRecommended = true;
            hasBeenPosted = true;
        }
        isDeposited = casePayment.Deposited__c;
        
        casePayment.Hold_Amount__c = casePayment.Hold_Amount__c == null ? 0.00 : casePayment.Hold_Amount__c;
        casePayment.Other_Refund__c = casePayment.Other_Refund__c == null ? 0.00 : casePayment.Other_Refund__c;
        casePayment.DIR_Attorney_Fees__c = casePayment.DIR_Attorney_Fees__c == null ? 0.00 : casePayment.DIR_Attorney_Fees__c;
        
        receipt = casePayment.Receipt__r;
        // System.debug('###casePayment.Receipt__c = ' + casePayment.Receipt__c + ' receipt = ' + receipt + ' DIRcase = ' + DIRcase);

        DIRcase = casePayment.Case__r;
        // System.debug('###DIRcase = '+DIRcase+' RecordType = '+DIRcase.RecordType);
        // System.debug('###DIRcase.Name = ' + DIRcase.Name);
        
        
        if(!isValid){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This record is locked and no further changes can be made due to the following validation error: ' + invalidReason + '\nClick your browser\'s BACK button twice ⬅️⬅️ to continue.'));
        }
        
        
        if(DIRcase.RecordType.Name.containsIgnoreCase('BOFE') || DIRcase.RecordType.Name.containsIgnoreCase('PASS') || DIRcase.RecordType.Name.containsIgnoreCase('RCI') || DIRcase.RecordType.Name.containsIgnoreCase('Registration')){
            isBOFECase = true;
            
            if(DIRcase.RecordType.Name.containsIgnoreCase('RCI')){
                isRCICase = true;
            }
        }
        
        System.debug('###isBOFECase:'+isBOFECase+', isRCICase:'+isRCICase);
        
        allLPList = casePayment.Liability_Payments__r;
        allJPList = casePayment.Judgment_Payments__r;
        
        getCustomMetadataPermissions();
        
        system.debug('###renderRecommendBtn: '+renderRecommendBtn);
        system.debug('###renderPostBtn: '+renderPostBtn);
        system.debug('###renderThirdBtn: '+renderThirdBtn);

        //TODO: These next 2 queries could probably be combined
        allLiablePartyList = [SELECT Id, Name, Case_Role__c, Case_Role__r.Id, Case_Role__r.Case__c, Case_Role__r.Case_Role_Account_Name__c, Liability__c, Liability__r.Id,
                                (SELECT Id, Name, Judgement__c, Judgement__r.Id, Liable_Party__c, Liable_Party__r.Id, Liable_Party__r.Case_Role__c
                                    FROM Liability_Judgements__r),
                                (SELECT Id, Name, Case_Issue__c, Liable_Party__c, Liable_Party__r.Id, Liable_Party__r.Case_Role__c, Liable_Party__r.Case_Role__r.Id
                                    FROM Liable_Party_Case_Issues__r)
                                FROM Liable_Party__c
                                WHERE Case_Role__r.Case__c = :DIRcase.Id];
        
        allCaseRoleList = [SELECT Id, Name, Role__c, Case__c, Case__r.Id, Case_Role_Account_Name__c, Entity__c, Entity__r.Name,
                            (SELECT Id, Name, Case_Role__c, Liability__c, Liability__r.Assessment__c
                                FROM Liable_Parties__r)
                            FROM Case_Role__c
                            WHERE Case__r.Id = :DIRcase.Id
                            ORDER By Role__c ASC];
        // System.debug('### allLiablePartyList: '+allLiablePartyList);
        // System.debug('### allCaseRoleList= ' + allCaseRoleList);
        
        ////populate oboList (case roles on case) list if not already
        if(oboList == null){
            oboList = new List<SelectOption>();
            //SelectOption allAmountsDue = new SelectOption('ALL', '<option value="ALL" style="color:magenta;">--All Amounts Due--</option>', true);
            //allAmountsDue.setEscapeItem(false);
            oboList.add(new SelectOption('ALL', '--All Amounts Due--', true));
            
            for(Case_Role__c caseRole : allCaseRoleList){
                if(  ////TODO: add other conditions to filter on other liable-type case roles.
                        caseRole.Role__c.equals('Business') ||
                        caseRole.Role__c.equals('Case Employer') ||
                        caseRole.Role__c.equals('CEO') ||
                        caseRole.Role__c.equals('CFO') ||
                        caseRole.Role__c.equals('Chief') ||
                        caseRole.Role__c.equals('Contractor Successor') ||
                        caseRole.Role__c.equals('Corporate Officer') ||
                        caseRole.Role__c.equals('Defendant') ||
                        caseRole.Role__c.equals('Defendant - Joint Employer') ||
                        caseRole.Role__c.equals('Defendant - Guarantor') ||
                        caseRole.Role__c.equals('Defendant - Successor') ||
                        caseRole.Role__c.equals('Director') ||
                        caseRole.Role__c.equals('Joint Employer') ||
                        caseRole.Role__c.equals('Manager') ||
                        caseRole.Role__c.equals('Managing Member') ||
                        caseRole.Role__c.equals('Member') ||
                        caseRole.Role__c.equals('Owner') ||
                        caseRole.Role__c.equals('Partner') ||
                        caseRole.Role__c.equals('Partnership') ||
                        caseRole.Role__c.equals('President') ||
                        caseRole.Role__c.equals('Subsidiary') ||
                        caseRole.Role__c.equals('Successor') ||
                        caseRole.Role__c.equals('Vice President')
                    ){
                    oboList.add(new SelectOption(caseRole.Id, caseRole.Case_Role_Account_Name__c));
                }
            }
        }
        if(hasBeenRecommended || hasBeenPosted){
            for(Liability_Payment__c lp : allLPList){
                if(lp.Payment_on_Behalf_of__c != null){
                    selectedOBO = lp.Payment_on_Behalf_of__r.Case_Role__c;
                    break; 
                }
            }
        }
        
        allPayeeList = [SELECT Id, Case_Management__c, Case_Management__r.Id, Case_Role__c, Case_Role__r.Entity__c, Name, Factor__c, Role__c, Payee_Type__c
                            FROM Payee__c
                            WHERE Case_Management__r.Id = :DIRcase.Id];
        
        System.debug('### allPayeeList= ' + allPayeeList);
        
        FindPaymentPlan();
        
        
        ////TODO: filter by status--closed, etc
        ////TODO: sort? by Bal Due EE(s)?
        allCaseIssueList = [SELECT Id, Name, RecordTypeId, Assessment__c, Assessment__r.Citation_Number__c, Assessment__r.JEU_Case_number__c, Case__c, Case__r.Id, Violation_Type__c, Violation_Type__r.Name, Citation_Amount__c,
                                Wages_Due__c, Wage_Balance_Due__c, Total_Interest_Amount__c, Interest_Balance_Due__c, Penalty_Balance_Due__c, Status__c,
                                (SELECT Id, Name, Case_Issue__c, Liable_Party__c, Liable_Party__r.Id
                                    FROM Liable_Party_Case_Issues__r),
                                (SELECT Id, Name, Case_Violation__c, Liability_Judgement__c
                                    FROM Judgement_Case_Violations__r)
                                FROM DIR_Violation__c
                                WHERE Case__c = :DIRcase.Id
                                
                                    //AND Status__c != 'Canceled'
                                    AND Status__c != 'Canceled - Invalid'
                                    AND Status__c != 'Canceled/Invalid'
                                    //AND Status__c != 'Dismissed'
                                    //AND Status__c != 'Administrative Dismissal'
                                    //AND Status__c != 'Dismissed at Conference'
                                    //AND Status__c != 'Dismissed at Hearing'
                                    
                                ORDER BY Violation_Type__r.Name ASC];
                                
        // System.debug('### allCaseIssueList-> '+ allCaseIssueList);
                            
        ////TODO: filter by? status?
        ////TODO: sort?
        allJudgmentList = [SELECT Id, Name, Case_Management__c, Case_Management__r.Id, Court__c, Court__r.Name, Status__c,
                            Post_hearing_Interest_Balance_Due__c, Post_judgment_Interest_Balance_Due__c, Attorney_Fees_Balance_Due__c, Filing_Fees_Balance_Due__c,
                            (SELECT Id, Name, Liable_Party__c, Liable_Party__r.Case_Role__c, Liable_Party__r.Case_Role__r.Id
                                FROM Liability_Judgements__r) //Liability_Judgements__r aka Judgment Parties
                            FROM Judgement__c
                            WHERE Case_Management__c = :DIRcase.Id
                            ORDER BY Post_judgment_Interest_Balance_Due__c DESC];
        
        DisplayCIsAndJs();
        
        Profile profile = [SELECT Name 
                            FROM Profile 
                            WHERE Id = :UserInfo.getProfileId()];
        
        if(profile.Name == 'WCA User' || profile.Name.contains('System Administrator') || profile.Name == 'RCI User'){
            isCashier = true;
        }else{
            List<CustomPermission> customPerms = [SELECT Id
                                                    FROM CustomPermission
                                                    WHERE DeveloperName LIKE '%Cashiering%'];
            if(customPerms.size() > 0){
                List<SetupEntityAccess> setupEntityAccessList = [SELECT Id, ParentId
                                                                    FROM SetupEntityAccess
                                                                    WHERE SetupEntityId = :customPerms[0].Id];
                if(setupEntityAccessList.size() > 0){
                    Set<id> parentIds = new Set<Id>();
                    for (SetupEntityAccess sea : setupEntityAccessList){
                        parentIds.add(sea.ParentId);
                    }
                    integer permissionSetAssignmentCount = [SELECT COUNT()
                                                            FROM PermissionSetAssignment
                                                            WHERE AssigneeId = :UserInfo.getUserId()
                                                                AND PermissionSetId IN :parentIds];
                    isCashier = permissionSetAssignmentCount > 0;
                }
            }
        }
        // System.debug('### allocToPenalties = '+allocToPenalties);
        // System.debug('### allocToWages = '+allocToWages);
        // System.debug('### allocToInterest = '+allocToInterest);
        // System.debug('### allocToPostHearingInt = '+allocToPostHearingInt);
        // System.debug('### allocToPostJudgmentInt = '+allocToPostJudgmentInt);
        // System.debug('### allocToAttorneyFees = '+allocToAttorneyFees);
        // System.debug('### allocToFilingFees = '+allocToFilingFees);
        // System.debug('### holdAmount = '+holdAmount);
        // System.debug('### otherRefund = '+otherRefund);
        // System.debug('### DIRAttorneyFees = '+DIRAttorneyFees);
        // System.debug('### amtRemain = ' + amtRemain);

        retURL = (retURLStr == null || retURLStr.trim() == '') ? '/' + casePayment.Id : retURLStr;
    }
    
    //Called from PostCasePaymentVFP only
    public void FindPaymentPlansAndDisplayCIsAndJs(){
        FindPaymentPlan();
        DisplayCIsAndJs();
    }
    
    public Payment_Plan__c paymentPlan{get; set;}
    public List<SelectOption> ppOptionsList{get; set;}
    public String ppSelection{get;set;}
    private Map<Id, Payment_Plan__c> payPlansOnCaseMap{get;set;}
    public void FindPaymentPlan(){
        System.debug('### Finding Payment Plan');
        ////paymentPlan = null;
        ppOptionsList = new List<SelectOption>();
        
        if(selectedOBO == 'ALL'){
            payPlansOnCaseMap = new Map<Id, Payment_Plan__c>([SELECT Id, Name, Responsible_Party__c, Payment_Plan_Balance__c
                                                    FROM Payment_Plan__c
                                                    WHERE Case__c = :DIRcase.Id]);
        }else{
            payPlansOnCaseMap = new Map<Id, Payment_Plan__c>([SELECT Id, Name, Responsible_Party__c, Payment_Plan_Balance__c
                                                                FROM Payment_Plan__c
                                                                WHERE Case__c = :DIRcase.Id
                                                                    AND Responsible_Party__c IN (SELECT Entity__c FROM Case_Role__c WHERE Id = :selectedOBO)]);
        }
        System.debug('### PaymentPlan list: ' + payPlansOnCaseMap);
        System.debug('### ppOptionsList = ' + ppOptionsList);
        
        ppOptionsList.add(new SelectOption('NONE', '--None--'));
        
        for(Payment_Plan__c pp : payPlansOnCaseMap.values()){
            ppOptionsList.add(new SelectOption(pp.Id, pp.Name));
        }

        if(casePayment.Payment_Plan__c == null){
            ppSelection = 'NONE';
        }else{
            ppSelection = casePayment.Payment_Plan__c;
            paymentPlan = payPlansOnCaseMap.get(ppSelection);
        }
    }


    public void SetPaymentPlan(){
        if(ppSelection == 'NONE'){
            paymentPlan = null;
            return;
        }
        paymentPlan = payPlansOnCaseMap.get(ppSelection);
    }
    
    
    public Map<Id, CaseIssueWrapper> caseIssueWrapperMap{get; set;}
    public List<CaseIssueWrapper> caseIssueWrapperList{get; set;}
    public Map<Id, JudgmentWrapper> judgmentWrapperMap{get; set;}
    public List<JudgmentWrapper> judgmentWrapperList{get;set;}
    
    public void DisplayCIsAndJs(){
        caseIssueWrapperMap = new Map<Id, CaseIssueWrapper>(); ////map for deduping--possible to have Case Role with multiple Liable Parties pointing to the same CIs
        caseIssueWrapperList = new List<CaseIssueWrapper>();
        judgmentWrapperMap = new Map<Id, JudgmentWrapper>(); ////map for deduping--possible to have Case Role with multiple Judgment Parties pointing to the same Judgment
        judgmentWrapperList = new List<JudgmentWrapper>();
        
        ////1-bring in CIs and Judgments:
        //// if we're displaying Payments On Behalf Of: ALL, build wrappers off of all CIs and Judgments extracted from the Case
        if(selectedOBO == 'ALL'){
            for(DIR_Violation__c ci : allCaseIssueList){
                caseIssueWrapperMap.put(ci.Id, new CaseIssueWrapper(ci));
            }
            for(Judgement__c judgment : allJudgmentList){
                judgmentWrapperMap.put(judgment.Id, new JudgmentWrapper(judgment));
            }
        }else{ //// filter CIs and Judgments through Liable Parties and Judgment Parties (Liability_Judgement__c)
            
            System.debug('### allCaseIssueList='+allCaseIssueList);
            for(DIR_Violation__c ci : allCaseIssueList){
                System.debug('### ci='+ci);
                System.debug('### allLiablePartyList='+allLiablePartyList);
                
                for(Liable_Party__c liableParty : allLiablePartyList){
                    System.debug('### liableParty='+liableParty);
                    System.debug('### liableParty.Liable_Party_Case_Issues__r='+liableParty.Liable_Party_Case_Issues__r);
                    
                    for(Liable_Party_Case_Issue__c lpci : liableParty.Liable_Party_Case_Issues__r){
                        System.debug('### lpci='+lpci);
                        System.debug('### selectedOBO='+selectedOBO+'==liableParty.Case_Role__r.Id='+liableParty.Case_Role__r.Id+' && lpci.Case_Issue__c='+lpci.Case_Issue__c+'==ci.Id='+ci.Id);
                        if(selectedOBO == liableParty.Case_Role__r.Id && lpci.Case_Issue__c == ci.Id){
                            if(!caseIssueWrapperMap.containsKey(ci.Id)){
                                caseIssueWrapperMap.put(ci.Id, new CaseIssueWrapper(ci));
                            }
                        }
                    }
                }
            }
            
            
            for(Judgement__c judgment : allJudgmentList){
                for(Liability_Judgement__c judgmentParty : judgment.Liability_Judgements__r){
                    if(judgmentParty.Liable_Party__r.Case_Role__r.Id == selectedOBO){
                        judgmentWrapperMap.put(judgment.Id, new JudgmentWrapper(judgment));
                    }
                }
            }
        }
        caseIssueWrapperList = caseIssueWrapperMap.values();
        judgmentWrapperList = judgmentWrapperMap.values();
        
        ////2-match the child LPs and JPs, if any, with their parent CIs and Judgments so we can populate
        //// the amount input fields
        for(Liability_Payment__c lp : allLPList){
            for(CaseIssueWrapper ciw : caseIssueWrapperList){
                if(lp.Case_Violation__c == ciw.thisCaseIssue.Id){
                    ciw.citationNums = lp.Case_Violation__r.Assessment__r.Citation_Number__c;
                    ciw.jeuCaseNum = lp.Case_Violation__r.Assessment__r.JEU_Case_number__c;
                    
                    if(lp.Payment_Applied_To__c == 'Wages'){
                        if(casePayment.Status__c == 'Allocations Recommended'){
                            ciw.allocationToWages = lp.Recommended_Allocation__c == null ? 0.00 : lp.Recommended_Allocation__c;
                            
                        }else if(casePayment.Status__c == 'Posted'){ ////this if statement may not be necessary - if an LP exists, the CP Status should be either Allocations Recommended or Posted, never New
                            ciw.allocationToWages = lp.Payment_Amount__c;
                        }
                    }else if(lp.Payment_Applied_To__c == 'Penalties'){
                        if(casePayment.Status__c == 'Allocations Recommended'){
                            ciw.allocationToPenalties = lp.Recommended_Allocation__c == null ? 0.00 : lp.Recommended_Allocation__c;
                        }else if(casePayment.Status__c == 'Posted'){
                            ciw.allocationToPenalties = lp.Payment_Amount__c;
                        }
                    }else{ //// lp.Payment_Applied_To__c == 'Interest'
                        if(casePayment.Status__c == 'Allocations Recommended'){
                            ciw.allocationToInterest = lp.Recommended_Allocation__c == null ? 0.00 : lp.Recommended_Allocation__c;
                        }else if(casePayment.Status__c == 'Posted'){
                            ciw.allocationToInterest = lp.Payment_Amount__c;
                        }
                    }
                }
            }
        }
        System.debug('### allJPList = '+allJPList);
        for(Judgment_Payment__c jp : allJPList){
            for(JudgmentWrapper jw : judgmentWrapperList){
                if(jp.Judgment__c == jw.thisJudgment.Id){
                    if(jp.Apply_Payment_To__c == 'Post-Judgment Interest'){
                        if(casePayment.Status__c == 'Allocations Recommended'){
                            jw.pjiAlloc = jp.Recommended_Amount__c == null ? 0.00 : jp.Recommended_Amount__c;
                        }else if(casePayment.Status__c == 'Posted'){
                            jw.pjiAlloc = jp.Allocated_Amount__c;
                        }
                    }else if(jp.Apply_Payment_To__c == 'Post-Hearing Interest'){
                        if(casePayment.Status__c == 'Allocations Recommended'){
                            jw.phiAlloc = jp.Recommended_Amount__c == null ? 0.00 : jp.Recommended_Amount__c;
                        }else if(casePayment.Status__c == 'Posted'){
                            jw.phiAlloc = jp.Allocated_Amount__c;
                        }
                    }else if(jp.Apply_Payment_To__c == 'Attorney Fees'){
                        if(casePayment.Status__c == 'Allocations Recommended'){
                            jw.afAlloc = jp.Recommended_Amount__c == null ? 0.00 : jp.Recommended_Amount__c;
                        }else if(casePayment.Status__c == 'Posted'){
                            jw.afAlloc = jp.Allocated_Amount__c;
                        }
                    }else if(jp.Apply_Payment_To__c == 'Filing Fees'){
                        if(casePayment.Status__c == 'Allocations Recommended'){
                            jw.ffAlloc = jp.Recommended_Amount__c == null ? 0.00 : jp.Recommended_Amount__c;
                        }else if(casePayment.Status__c == 'Posted'){
                            jw.ffAlloc = jp.Allocated_Amount__c;
                        }
                    } //// jp.Apply_Payment_To__c == 'Judgment Amount' means this JP is redundant with one of the LPs
                }
            }
        }
    }
    
    
    /* Recommend() has to do 2 things:
        I) match the CIW allocations made on the VFP with any existing LPs and any 'redundant,' 'Judgment Amount' JPs, (iow, we're 're-recommending') and update any changes.
            If an allocation exists without an existing LP (iow, we're recommending a CP for the first time), create a new LP and new 'redundant,' 'Judgment Amount' JPs if needed.
            There should be a separate 'redundant' JP created for each Liable Party on a Case Issue where each Liable Party has a Judgment. IOW, if a Case has multiple Judgments, there'll probably
            be a 'redundant' JP created for each Judgment, each for the same amount.
        II) match the JW allocations with any existing JPs and update any changes. If an allocation exists without a JP, create a new JP for it. 
    TODO: LP and JP record types - set from parent violation or Judgment? */
    public PageReference Recommend(){
        System.debug('### Entered Recommend(), retURL = ' + retURL);
        hasBeenRecommended = true;
        
        //validate recommendations are non-negative
        for(CaseIssueWrapper ciw : caseIssueWrapperList){
            if(ciw.allocationToWages < 0 || ciw.allocationToInterest < 0 || ciw.allocationToPenalties < 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Negative allocations are not allowed.'));
                return null;
            }
        }
        for(JudgmentWrapper jw : judgmentWrapperList){
            if(jw.phiAlloc < 0 || jw.pjiAlloc < 0 || jw.afAlloc < 0 || jw.ffAlloc < 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Negative allocations are not allowed.'));
                return null;
            }
        }

        /*Recommending or Posting with selectedOBO == ALL is disallowed on the VFP
        System.debug('###selectedOBO = '+selectedOBO);
        if(selectedOBO == 'ALL'){
            for(Case_Role__c caseRole : allCaseRoleList){
                if(caseRole.Role__c == 'Defendant'){
                    selectedOBO = caseRole.Id;
                }
            }
        }*/
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            casePayment.Status__c = 'Allocations Recommended';
            casePayment.Case_Payment_Recommended_Date__c = Date.today();
            if(ppSelection == 'NONE'){
                casePayment.Payment_Plan__c = null;
            }else{
                casePayment.Payment_Plan__c = ppSelection;
            }
            update casePayment;

            //  I) Try to match the CIW allocations to existing LPs, if any.
            List<Liability_Payment__c> LPsToInsert = new List<Liability_Payment__c>();
            List<Judgment_Payment__c> JPsToInsert = new List<Judgment_Payment__c>();
            
            for(CaseIssueWrapper ciw : caseIssueWrapperList){
                
                //  Determine correct Liability and Payment_on_Behalf_of__c the LP should look up to.
                //    TODO: verify this works for CIs with multiple Liable Parties (through LPCIs) and Case Roles with multiple Liable Parties. This may be where we need to bring in LPCI.Proportionate_Share__c
                Liability__c relevantLiability;
                Liable_Party__c relevantPOBO;
                System.debug('### allLiablePartyList = '+allLiablePartyList);
                for(Liable_Party__c liableParty : allLiablePartyList){
                    System.debug('### liableParty = '+liableParty);
                    System.debug('### liableParty.Liable_Party_Case_Issues__r = '+liableParty.Liable_Party_Case_Issues__r);
                    for(Liable_Party_Case_Issue__c lpci : liableParty.Liable_Party_Case_Issues__r){
                        System.debug('### lpci.Case_Issue__c = '+lpci.Case_Issue__c+' == ciw.thisCaseIssue.Id = '+ciw.thisCaseIssue.Id+' | lpci.Liable_Party__r.Case_Role__c = '+lpci.Liable_Party__r.Case_Role__c+' == selectedOBO = '+selectedOBO);
                        if(lpci.Case_Issue__c == ciw.thisCaseIssue.Id && lpci.Liable_Party__r.Case_Role__c == selectedOBO){
                            relevantLiability = liableParty.Liability__r;
                            relevantPOBO = liableParty;
                        }
                    }
                }
                
                boolean wageLPfound = false;
                boolean interestLPfound = false;
                boolean penaltyLPfound = false;
                System.debug('### allLPList = ' + allLPList);
                for(Liability_Payment__c lp : allLPList){
                    //  If the recommended amounts or Payment_on_Behalf_of__c are different, update the LP and any 'redundant' JPs, even if $0 (meaning a previous recommended amount has been removed, but we're still keeping 
                    //    the record for historical purposes).
                    if(lp.Case_Violation__c == ciw.thisCaseIssue.Id){ // LPs not tied to a CI really shouldn't exist in the first place, but some do in PROD. This will have to be a manual correction.
                        System.debug('### case issue match: lp = ' + lp + ' , ciw = ' + ciw);
                        
                        lp.Assessment__c = ciw.thisCaseIssue.Assessment__c; // Updating this field here because a lot of the records in PROD have this field blank
                        
                        lp.Liability__c = relevantLiability.Id;  // Updating this field here because a lot of the records in PROD have this field blank

                        if(lp.Payment_Applied_To__c == 'Wages'){
                            wageLPfound = true;
                            if(lp.Recommended_Allocation__c != ciw.allocationToWages){
                                // Find 'redundant' JPs. We need to do this before we update any amounts and POBOs on the LP and JPs because we're using those amounts to match.
                                Set<Judgment_Payment__c> redundantJPs = findRedundantJPs(lp, ciw);
                                System.debug('### wage rJPs = ' + redundantJPs);
                                
                                lp.Recommended_Allocation__c = ciw.allocationToWages;
                                lp.Payment_on_Behalf_of__c = relevantPOBO.Id;
                                for(Judgment_Payment__c jp : redundantJPs){
                                    jp.Recommended_Amount__c = ciw.allocationToWages;
                                    jp.Payment_On_Behalf_Of__c = relevantPOBO.Id; //TODO: should this be the LP's POBO, or the Judgment Party?
                                    jp.Status__c = 'Recommended';
                                }
                            }
                        }else if(lp.Payment_Applied_To__c == 'Interest'){
                            interestLPfound = true;
                            if(lp.Recommended_Allocation__c != ciw.allocationToInterest){
                                // Find 'redundant' JPs. We need to do this before we update any amounts and POBOs on the LP and JPs because we're using those amounts to match.
                                Set<Judgment_Payment__c> redundantJPs = findRedundantJPs(lp, ciw);
                                System.debug('### interest rJPs = ' + redundantJPs);
                                
                                lp.Recommended_Allocation__c = ciw.allocationToInterest;
                                lp.Payment_on_Behalf_of__c = relevantPOBO.Id;
                                for(Judgment_Payment__c jp : redundantJPs){
                                    jp.Recommended_Amount__c = ciw.allocationToInterest;
                                    jp.Payment_On_Behalf_Of__c = relevantPOBO.Id;
                                    jp.Status__c = 'Recommended';
                                }
                            }
                        }else if(lp.Payment_Applied_To__c == 'Penalties'){
                            penaltyLPfound = true;
                            if(lp.Recommended_Allocation__c != ciw.allocationToPenalties){
                                 // Find 'redundant' JPs. We need to do this before we update any amounts and POBOs on the LP and JPs because we're using those amounts to match.
                                Set<Judgment_Payment__c> redundantJPs = findRedundantJPs(lp, ciw);
                                System.debug('### penalty rJPs = ' + redundantJPs);
                                
                                lp.Recommended_Allocation__c = ciw.allocationToPenalties;
                                lp.Payment_on_Behalf_of__c = relevantPOBO.Id;
                                for(Judgment_Payment__c jp : redundantJPs){
                                    jp.Recommended_Amount__c = ciw.allocationToPenalties;
                                    jp.Payment_On_Behalf_Of__c = relevantPOBO.Id;
                                    jp.Status__c = 'Recommended';
                                }
                            }
                        }
                    }
                }
                
                //  No matching LP found, so we may need to create new one(s), along with 'redundant' 'Judgment Amount' JPs if needed.
                if(!wageLPfound && ciw.allocationToWages > 0){
                    Liability_Payment__c newWageLP = new Liability_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        Recommended_Allocation__c = ciw.allocationToWages,
                        Payment_Applied_To__c = 'Wages',
                        Assessment__c = ciw.thisCaseIssue.Assessment__c,
                        Liability__c = relevantLiability.Id,
                        Case_Violation__c = ciw.thisCaseIssue.Id,
                        Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId,
                        Payment_on_Behalf_of__c = relevantPOBO.Id
                    );
                    LPsToInsert.add(newWageLP);
                }
                if(!interestLPfound && ciw.allocationToInterest > 0){
                    Liability_Payment__c newInterestLP = new Liability_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        Recommended_Allocation__c = ciw.allocationToInterest,
                        Payment_Applied_To__c = 'Interest',
                        Assessment__c = ciw.thisCaseIssue.Assessment__c,
                        Liability__c = relevantLiability.Id,
                        Case_Violation__c = ciw.thisCaseIssue.Id,
                        Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId,
                        Payment_on_Behalf_of__c = relevantPOBO.Id
                    );
                    LPsToInsert.add(newInterestLP);
                }
                if(!penaltyLPfound && ciw.allocationToPenalties > 0){
                    Liability_Payment__c newPenaltyLP = new Liability_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        Recommended_Allocation__c = ciw.allocationToPenalties,
                        Payment_Applied_To__c = 'Penalties',
                        Assessment__c = ciw.thisCaseIssue.Assessment__c,
                        Liability__c = relevantLiability.Id,
                        Case_Violation__c = ciw.thisCaseIssue.Id,
                        Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId,
                        Payment_on_Behalf_of__c = relevantPOBO.Id
                    );
                    LPsToInsert.add(newPenaltyLP);
                }
            }
            
            insert LPsToInsert; // Need to do this here to get LP Ids so we can parent redundant JPs to these LPs
            JPsToInsert.addAll(createRedundantJPs(LPsToInsert, 'Recommended'));
            
            
            //  II) try to match the JW allocations to existing non-'Judgment Amount' JPs, create if needed.
            //    Essentially the same algorithm as with matching CIW allocations to LPs, above
            for(JudgmentWrapper jw : judgmentWrapperList){
                
                // determine correct Judgment and POBO the JP should look up to
                Judgement__c relevantJudgment;
                Liable_Party__c relevantPOBO;
                System.debug('### allLiablePartyList = ' + allLiablePartyList);
                for(Liable_Party__c liableParty : allLiablePartyList){
                    System.debug('### liableParty = '+liableParty);
                    System.debug('### liableParty.Liability_Judgements__r = '+liableParty.Liability_Judgements__r);
                    for(Liability_Judgement__c judgmentParty : liableParty.Liability_Judgements__r){
                        System.debug('### judgmentParty.Judgement__c = '+judgmentParty.Judgement__c +', jw.thisJudgment.Id = '+jw.thisJudgment.Id);
                        System.debug('### judgmentParty.Liable_Party__r.Case_Role__c = '+judgmentParty.Liable_Party__r.Case_Role__c+', selectedOBO = '+selectedOBO);
                        if(judgmentParty.Judgement__c == jw.thisJudgment.Id){
                            relevantJudgment = judgmentParty.Judgement__r;
                            if(judgmentParty.Liable_Party__r.Case_Role__c == selectedOBO){
                                relevantPOBO = liableParty;
                            }
                            
                            /*Recommending or Posting with selectedOBO == ALL is disallowed on the VFP
                            //when relevantPOBO is null, which can happen when filtering the Judgments on the VFP by 'ALL' and the Judgment Party is not the Defendant, default to that Judgment's Judgment Party.
                            if(relevantPOBO == null){
                                relevantPOBO = judgmentParty.Liable_Party__r;
                            }*/
                        }
                    }
                }
                System.debug('### relevantPOBO = ' + relevantPOBO);
                boolean phiJPfound = false;
                boolean pjiJPfound = false;
                boolean afJPfound = false;
                boolean ffJPfound = false;
                for(Judgment_Payment__c jp : allJPList){
                    //  If the recommended amounts or Payment_on_Behalf_of__c are different, update the JP, even if $0 (meaning a previous recommended amount has been removed, but we're still keeping 
                    //    the record for historical purposes).
                    if(jp.Apply_Payment_To__c != 'Judgment Amount' && jp.Judgment__c == jw.thisJudgment.Id){
                        jp.Payment_On_Behalf_Of__c = relevantPOBO.Id;
                        jp.Status__c = 'Recommended';

                        if(jp.Apply_Payment_To__c == 'Post-Hearing Interest' && jp.Recommended_Amount__c != jw.phiAlloc){
                            jp.Recommended_Amount__c = jw.phiAlloc;
                            phiJPfound = true;
                        }else if(jp.Apply_Payment_To__c == 'Post-Judgment Interest' && jp.Recommended_Amount__c != jw.pjiAlloc){
                            jp.Recommended_Amount__c = jw.pjiAlloc;
                            pjiJPfound = true;
                        }else if(jp.Apply_Payment_To__c == 'Attorney Fees' && jp.Recommended_Amount__c != jw.afAlloc){
                            jp.Recommended_Amount__c = jw.afAlloc;
                            afJPfound = true;
                        }else if(jp.Apply_Payment_To__c == 'Filing Fees' && jp.Recommended_Amount__c != jw.ffAlloc){
                            jp.Recommended_Amount__c = jw.ffAlloc;
                            ffJPfound = true;
                        }
                    }
                }
                
                //No matching JPs found, so we need to create new one(s) if needed
                if(!phiJPfound && jw.phiAlloc > 0){
                    Judgment_Payment__c newPHIJP = new Judgment_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        Recommended_Amount__c = jw.phiAlloc,
                        Apply_Payment_To__c = 'Post-Hearing Interest',
                        Judgment__c = jw.thisJudgment.Id,
                        Payment_On_Behalf_Of__c = relevantPOBO.Id,
                        Status__c = 'Recommended'
                    );
                    JPsToInsert.add(newPHIJP);
                }
                if(!pjiJPfound && jw.pjiAlloc > 0){
                    Judgment_Payment__c newPJIJP = new Judgment_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        Recommended_Amount__c = jw.pjiAlloc,
                        Apply_Payment_To__c = 'Post-Judgment Interest',
                        Judgment__c = jw.thisJudgment.Id,
                        Payment_On_Behalf_Of__c = relevantPOBO.Id,
                        Status__c = 'Recommended'
                    );
                    JPsToInsert.add(newPJIJP);
                }
                if(!afJPfound && jw.afAlloc > 0){
                    Judgment_Payment__c newAFJP = new Judgment_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        Recommended_Amount__c = jw.afAlloc,
                        Apply_Payment_To__c = 'Attorney Fees',
                        Judgment__c = jw.thisJudgment.Id,
                        Payment_On_Behalf_Of__c = relevantPOBO.Id,
                        Status__c = 'Recommended'
                    );
                    JPsToInsert.add(newAFJP);
                }
                if(!ffJPfound && jw.ffAlloc > 0){
                    Judgment_Payment__c newFFJP = new Judgment_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        Recommended_Amount__c = jw.ffAlloc,
                        Apply_Payment_To__c = 'Filing Fees',
                        Judgment__c = jw.thisJudgment.Id,
                        Payment_On_Behalf_Of__c = relevantPOBO.Id,
                        Status__c = 'Recommended'
                    );
                    JPsToInsert.add(newFFJP);
                }
            }
            
            System.debug('### JPsToInsert = ' + JPsToInsert);
            System.debug('### allJPList = ' + allJPList);
            
            if(!LPsToInsert.isEmpty()){
            }
            if(!JPsToInsert.isEmpty()){
                allJPList.addAll(JPsToInsert);
            }
            System.debug('### allLPList = '+allLPList);

            upsert allJPList;
            upsert allLPList;
            //update casePayment;
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PostCasePaymentController.Recommend(): DML or malformed data error:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + ex + '<br/>Screenshot this error page, then Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
            Database.rollback(sp);
            return null;
        }
        return new PageReference(retURL);
    }


    /* Post() pretty much is exactly like Recommend() above (~90% cut and paste) in that it has to do the same 2 things:
        I) match the CIW allocations made on the VFP with any existing LPs and any 'redundant,' 'Judgment Amount' JPs and update any changes 
            (It's possible that recommended allocations are changed after a Recommend() but before a Post()). If an allocation exists without an LP, create a new LP, and any necessary JPs.
        II) match the JW allocations with any existing JPs and update any changes. If an allocation exists without a JP, create a new JP for it. 
        ...but also needs to do:
            1) CP.Status updated to Posted
            2) CP.Record Type updated to Locked. TODO: remove record type updating in Flow or Process
            3) LP.Payment_Amount__c and the JP.Allocated_Amount__c fields are populated instead of(?) LP.Recommended_Allocation__c and JP.Recommended_Amount__c
                (TODO: or do we update those too? ask business. here, for now, we're only updating the Payment Amount fields.)
            4) Payment Records are created for LPs and non-'Judgment Amount' JPs, if (1) the RCT has been deposited with regular Post Payment button on the VFP, or 
                (2) just create PRs through limited access 'third button' on VFP. (Not all LPs and JPs though, ask business.)
            5) TODO: Tier 2: Applied Accounting Code records are created in the Liability Payment flow. Maybe it would make more sense to create them here?
        TODO: LP and JP record types - set from parent violation or Judgment? */
    
    public PageReference Post(){
        System.debug('### Entered Post()');
        hasBeenRecommended = true;
        hasBeenPosted = true;
        List<Payment_Record__c> prsToInsert = new List<Payment_Record__c>();
        List<Payee__c> employeePayees = new List<Payee__c>();
        Decimal employeePayeesFactorSum = 0.00000;
        List<Payee__c> statePayees = new List<Payee__c>();
        Decimal statePayeesFactorSum = 0.00000;
        List<Payee__c> courtPayees = new List<Payee__c>();
        Decimal courtPayeesFactorSum = 0.00000;
        
        
        //validate non-negative recommendations
        for(CaseIssueWrapper ciw : caseIssueWrapperList){
            if(ciw.allocationToWages < 0 || ciw.allocationToInterest < 0 || ciw.allocationToPenalties < 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Negative allocations are not allowed.'));
                return null;
            }
        }
        for(JudgmentWrapper jw : judgmentWrapperList){  
            if(jw.phiAlloc < 0 || jw.pjiAlloc < 0 || jw.afAlloc < 0 || jw.ffAlloc < 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Negative allocations are not allowed.'));
                return null;
            }
        }
        
        //prep Payees for validation
        System.debug('### allPayeeList: '+allPayeeList);
        for(Payee__c payee : allPayeeList){
            if(payee.Payee_Type__c == 'Employee'){
                employeePayees.add(payee);
                employeePayeesFactorSum += payee.Factor__c;
            }else if(payee.Payee_Type__c == 'State'){
                statePayees.add(payee);
                statePayeesFactorSum += payee.Factor__c;
            }else if(payee.Payee_Type__c == 'Court'){
                courtPayees.add(payee);
                courtPayeesFactorSum += payee.Factor__c;
            }
        }
        
        /*Recommending or Posting with selectedOBO == ALL is disallowed on the VFP
        if(selectedOBO == 'ALL'){
            for(Case_Role__c caseRole : allCaseRoleList){
                if(caseRole.Role__c == 'Defendant'){
                    selectedOBO = caseRole.Id;
                }
            }
        }*/
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            casePayment.Status__c = 'Posted';
            casePayment.Case_Payment_Posted_Date__c = Date.today();
            casePayment.RecordTypeId = Schema.SObjectType.Case_Payment__c.getRecordTypeInfosByName().get('Posted').getRecordTypeId();
            if(ppSelection == 'NONE'){
                casePayment.Payment_Plan__c = null;
            }else{
                casePayment.Payment_Plan__c = ppSelection;
            }
            update casePayment;

            //  I) Try to match the CIW allocations to existing LPs, if any.
            List<Liability_Payment__c> LPsToInsert = new List<Liability_Payment__c>();
            List<Judgment_Payment__c> JPsToInsert = new List<Judgment_Payment__c>();
            
            for(CaseIssueWrapper ciw : caseIssueWrapperList){
                
                //  Determine correct Liability and Payment_on_Behalf_of__c the LP should look up to.
                //    TODO: verify this works for CIs with multiple Liable Parties (through LPCIs) and Case Roles with multiple Liable Parties. This may be where we need to bring in LPCI.Proportionate_Share__c
                Liability__c relevantLiability;
                Liable_Party__c relevantPOBO;
                System.debug('### allLiablePartyList = '+allLiablePartyList);
                for(Liable_Party__c liableParty : allLiablePartyList){
                    System.debug('### liableParty = '+liableParty);
                    System.debug('### liableParty.Liable_Party_Case_Issues__r = '+liableParty.Liable_Party_Case_Issues__r);
                    for(Liable_Party_Case_Issue__c lpci : liableParty.Liable_Party_Case_Issues__r){
                        System.debug('### lpci.Case_Issue__c = '+lpci.Case_Issue__c+' == ciw.thisCaseIssue.Id = '+ciw.thisCaseIssue.Id+' | lpci.Liable_Party__r.Case_Role__c = '+lpci.Liable_Party__r.Case_Role__c+' == selectedOBO = '+selectedOBO);
                        if(lpci.Case_Issue__c == ciw.thisCaseIssue.Id && lpci.Liable_Party__r.Case_Role__r.Id == selectedOBO){
                            relevantLiability = liableParty.Liability__r;
                            relevantPOBO = liableParty;
                        }
                    }
                }
                
                boolean wageLPfound = false;
                boolean interestLPfound = false;
                boolean penaltyLPfound = false;
                for(Liability_Payment__c lp : allLPList){
                    //  If the Payment Amounts or Payment_on_Behalf_of__c are different, update the LP and any 'redundant' JPs, even if $0 (meaning a previous recommended amount has been removed, but we're still keeping 
                    //    the record for historical purposes).
                    if(lp.Case_Violation__c == ciw.thisCaseIssue.Id){ // LPs not tied to a CI really shouldn't exist in the first place, but some do in PROD. This will have to be a manual correction.
                        lp.Assessment__c = ciw.thisCaseIssue.Assessment__c; // Updating this field here because a lot of the records in PROD have this field blank
                        if(relevantLiability != NULL){
                            lp.Liability__c = relevantLiability.Id;  // Updating this field here because a lot of the records in PROD have this field blank
                        }
                        if(lp.Payment_Applied_To__c == 'Wages'){
                            
                            //validate Payees
                            if(employeePayees.isEmpty()){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records on the Case to post to Wages. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                Database.rollback(sp);
                                return null;
                            }else if(employeePayeesFactorSum != 100.00000){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                Database.rollback(sp);
                                return null;
                            }
                            
                            wageLPfound = true;
                            if(lp.Payment_Amount__c != ciw.allocationToWages){
                                // Find 'redundant' JPs. We need to do this before we update any amounts and POBOs on the LP and JPs because we're using those amounts to match.
                                Set<Judgment_Payment__c> redundantJPs = findRedundantJPs(lp, ciw);
                                
                                lp.Payment_Amount__c = ciw.allocationToWages;
                                lp.Payment_on_Behalf_of__c = relevantPOBO.Id;
                                for(Judgment_Payment__c jp : redundantJPs){
                                    jp.Allocated_Amount__c = ciw.allocationToWages;
                                    jp.Payment_On_Behalf_Of__c = relevantPOBO.Id;
                                    jp.Status__c = 'Posted';
                                }
                            }
                        }else if(lp.Payment_Applied_To__c == 'Interest'){
                            
                            //validate Payees
                            if(lp.Case_Violation__r.RecordTypeId == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                                if(employeePayees.isEmpty()){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records on the Case to post to WCA Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else if(employeePayeesFactorSum != 100.00000){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }
                            }else if(lp.Case_Violation__r.RecordTypeId == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                                if(statePayees.isEmpty()){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State of California must have Case Role and Payee records on the Case to post to BOFE Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else if(statePayeesFactorSum != 100.00000){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State Payees\' factors equal ' + statePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }
                            }
                            
                            interestLPfound = true;
                            if(lp.Payment_Amount__c != ciw.allocationToInterest){
                                // Find 'redundant' JPs. We need to do this before we update any amounts and POBOs on the LP and JPs because we're using those amounts to match.
                                Set<Judgment_Payment__c> redundantJPs = findRedundantJPs(lp, ciw);
                                
                                lp.Payment_Amount__c = ciw.allocationToInterest;
                                lp.Payment_on_Behalf_of__c = relevantPOBO.Id;
                                for(Judgment_Payment__c jp : redundantJPs){
                                    jp.Allocated_Amount__c = ciw.allocationToInterest;
                                    jp.Payment_On_Behalf_Of__c = relevantPOBO.Id;
                                    jp.Status__c = 'Posted';
                                }
                            }
                        }else if(lp.Payment_Applied_To__c == 'Penalties'){
                            
                            //validate Payees
                            //Penalty funds deposited to 32-117 need State Payees. Penalty funds deposited to other Office Accounts do not need State Payees since no Payment Records are needed.
                            if(lp.Case_Payment__r.Receipt__r.Deposit_Account__c == '32-117'){
                                if(statePayees.isEmpty()){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State of California must have Case Role and Payee records on the Case to post 32-117 funds to Penalties. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else if(statePayeesFactorSum != 100.00000){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State Payees\' factors equal ' + statePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }
                            }
                            
                            penaltyLPfound = true;
                            if(lp.Payment_Amount__c != ciw.allocationToPenalties){
                                 // Find 'redundant' JPs. We need to do this before we update any amounts and POBOs on the LP and JPs because we're using those amounts to match.
                                Set<Judgment_Payment__c> redundantJPs = findRedundantJPs(lp, ciw);
                                
                                lp.Payment_Amount__c = ciw.allocationToPenalties;
                                lp.Payment_on_Behalf_of__c = relevantPOBO.Id;
                                for(Judgment_Payment__c jp : redundantJPs){
                                    jp.Allocated_Amount__c = ciw.allocationToPenalties;
                                    jp.Payment_On_Behalf_Of__c = relevantPOBO.Id;
                                    jp.Status__c = 'Posted';
                                }
                            }
                        }
                    }
                }
                
                //  No matching LP found, so we may need to create new one(s), along with 'redundant' 'Judgment Amount' JPs if needed.
                if(!wageLPfound && ciw.allocationToWages > 0){
                    
                    //validate Payees
                    if(employeePayees.isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records on the Case to post to Wages. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else if(employeePayeesFactorSum != 100.00000){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else{
                        Liability_Payment__c newWageLP = new Liability_Payment__c(
                            Case_Payment__c = casePayment.Id,
                            ////Recommended_Allocation__c = ciw.allocationToWages,
                            Payment_Amount__c = ciw.allocationToWages,
                            Payment_Applied_To__c = 'Wages',
                            Assessment__c = ciw.thisCaseIssue.Assessment__r.Id,
                            Liability__c = relevantLiability.Id,
                            Case_Violation__c = ciw.thisCaseIssue.Id,
                            Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId,
                            Payment_on_Behalf_of__c = relevantPOBO.Id
                        );
                        
                        LPsToInsert.add(newWageLP);
                    }
                }
                if(!interestLPfound && ciw.allocationToInterest > 0){
                    
                    //validate Payees
                    if(ciw.thisCaseIssue.RecordTypeId == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){
                        if(employeePayees.isEmpty()){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records on the Case to post to WCA Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                            Database.rollback(sp);
                            return null;
                        }else if(employeePayeesFactorSum != 100.00000){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                            Database.rollback(sp);
                            return null;
                        }else{
                            Liability_Payment__c newInterestLP = new Liability_Payment__c(
                                Case_Payment__c = casePayment.Id,
                                ////Recommended_Allocation__c = ciw.allocationToInterest,
                                Payment_Amount__c = ciw.allocationToInterest,
                                Payment_Applied_To__c = 'Interest',
                                Liability__c = relevantLiability.Id,
                                Assessment__c = ciw.thisCaseIssue.Assessment__r.Id,
                                Case_Violation__c = ciw.thisCaseIssue.Id,
                                Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId,
                                Payment_on_Behalf_of__c = relevantPOBO.Id
                            );
                            LPsToInsert.add(newInterestLP);
                        }
                    }else if(ciw.thisCaseIssue.RecordTypeId == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                        if(statePayees.isEmpty()){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State of California must have Case Role and Payee records on the Case to post to BOFE Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                            Database.rollback(sp);
                            return null;
                        }else if(statePayeesFactorSum != 100.00000){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State Payees\' factors equal ' + statePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                            Database.rollback(sp);
                            return null;
                        }else{
                            Liability_Payment__c newInterestLP = new Liability_Payment__c(
                                Case_Payment__c = casePayment.Id,
                                ////Recommended_Allocation__c = ciw.allocationToInterest,
                                Payment_Amount__c = ciw.allocationToInterest,
                                Payment_Applied_To__c = 'Interest',
                                Assessment__c = ciw.thisCaseIssue.Assessment__r.Id,
                                Liability__c = relevantLiability.Id,
                                Case_Violation__c = ciw.thisCaseIssue.Id,
                                Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId,
                                Payment_on_Behalf_of__c = relevantPOBO.Id
                            );
                            LPsToInsert.add(newInterestLP);
                        }
                    }
                }
                if(!penaltyLPfound && ciw.allocationToPenalties > 0){
                    
                    //validate Payees
                    //Penalty funds deposited to 32-117 need State Payees. Penalty funds deposited to other Office Accounts do not need State Payees since no Payment Records are needed.
                    if(casePayment.Receipt__r.Deposit_Account__c == '32-117'){
                        if(statePayees.isEmpty()){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State of California must have Case Role and Payee records on the Case to post 32-117 funds to Penalties. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                            Database.rollback(sp);
                            return null;
                        }else if(statePayeesFactorSum != 100.00000){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State Payees\' factors equal ' + statePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                            Database.rollback(sp);
                            return null;
                        }
                    }
                    
                    Liability_Payment__c newPenaltyLP = new Liability_Payment__c(
                        Case_Payment__c = casePayment.Id,
                        ////Recommended_Allocation__c = ciw.allocationToPenalties,
                        Payment_Amount__c = ciw.allocationToPenalties,
                        Payment_Applied_To__c = 'Penalties',
                        Assessment__c = ciw.thisCaseIssue.Assessment__r.Id,
                        Liability__c = relevantLiability.Id,
                        Case_Violation__c = ciw.thisCaseIssue.Id,
                        Case_Issue_RecordTypeId__c = ciw.thisCaseIssue.RecordTypeId,
                        Payment_on_Behalf_of__c = relevantPOBO.Id
                    );
                    LPsToInsert.add(newPenaltyLP);
                }
            }
            
            if(!LPsToInsert.isEmpty()){
                insert LPsToInsert; // Need to do this here to get LP Ids so we can parent redundant JPs to these LPs
                System.debug('LPsToInsert = '+LPsToInsert);
                JPsToInsert.addAll(createRedundantJPs(LPsToInsert, 'Posted'));
            }
            
            //  II) try to match the JW allocations to existing non-'Judgment Amount' JPs, create if needed.
            //    Essentially the same algorithm as with matching CIW allocations to LPs, above
            for(JudgmentWrapper jw : judgmentWrapperList){
                
                // determine correct Judgment and POBO the JP should look up to
                Judgement__c relevantJudgment;
                Liable_Party__c relevantPOBO;
                System.debug('### allLiablePartyList = ' + allLiablePartyList);
                for(Liable_Party__c liableParty : allLiablePartyList){
                    System.debug('### liableParty = '+liableParty);
                    System.debug('### liableParty.Liability_Judgements__r = '+liableParty.Liability_Judgements__r);
                    for(Liability_Judgement__c judgmentParty : liableParty.Liability_Judgements__r){
                        System.debug('### judgmentParty.Judgement__c = '+judgmentParty.Judgement__c +', jw.thisJudgment.Id = '+jw.thisJudgment.Id);
                        System.debug('### judgmentParty.Liable_Party__r.Case_Role__c = '+judgmentParty.Liable_Party__r.Case_Role__c+', selectedOBO = '+selectedOBO);
                        if(judgmentParty.Judgement__c == jw.thisJudgment.Id && judgmentParty.Liable_Party__r.Case_Role__c == selectedOBO){
                            relevantJudgment = judgmentParty.Judgement__r;
                            relevantPOBO = liableParty;
                        }
                    }
                }
                
                boolean phiJPfound = false;
                boolean pjiJPfound = false;
                boolean afJPfound = false;
                boolean ffJPfound = false;
                for(Judgment_Payment__c jp : allJPList){
                    //  If the Allocated Amounts or Payment_on_Behalf_of__c are different, update the JP, even if $0 (meaning a previous recommended amount has been removed, but we're still keeping 
                    //    the record for historical purposes).
                    if(jp.Apply_Payment_To__c != 'Judgment Amount' && jp.Judgment__c == jw.thisJudgment.Id){
                        jp.Payment_On_Behalf_Of__c = relevantPOBO.Id;
                        jp.Status__c = 'Posted';

                        if(jp.Apply_Payment_To__c == 'Post-Hearing Interest'){
                            phiJPfound = true;
                            if(jp.Allocated_Amount__c != jw.phiAlloc){
                                //validate Payees
                                if(employeePayees.isEmpty()){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records on the Case to post to Post-Hearing Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else if(employeePayeesFactorSum != 100.00000){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else{
                                    jp.Allocated_Amount__c = jw.phiAlloc;
                                }
                            }
                        }else if(jp.Apply_Payment_To__c == 'Post-Judgment Interest'){
                            pjiJPfound = true;
                            if(jp.Allocated_Amount__c != jw.pjiAlloc){
                                //validate Payees
                                if(employeePayees.isEmpty()){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records to post to Post-Judgment Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else if(employeePayeesFactorSum != 100.00000){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else{
                                    jp.Allocated_Amount__c = jw.pjiAlloc;
                                }
                            }
                        }else if(jp.Apply_Payment_To__c == 'Attorney Fees'){
                            afJPfound = true;
                            if(jp.Allocated_Amount__c != jw.afAlloc){
                                //validate Payees
                                if(statePayees.isEmpty()){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State of California must have Case Role and Payee records on the Case to post to Attorney Fees. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else if(statePayeesFactorSum != 100.00000){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'State Payees\' factors equal ' + statePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else{
                                    jp.Allocated_Amount__c = jw.afAlloc;
                                }
                            }
                        }else if(jp.Apply_Payment_To__c == 'Filing Fees'){
                            ffJPfound = true;
                            if(jp.Allocated_Amount__c != jw.ffAlloc){
                                //validate Payees
                                if(isDeposited && courtPayees.isEmpty()){ //Direct Payments are never deposited, no checks will ever be cut, not PRs needed, not court Payeess needed
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be a Court Case Role and Payee record on the Case to post to Filing Fees. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else if(isDeposited && courtPayeesFactorSum != 100.00000){ //Direct Payments are never deposited, no checks will ever be cut, not PRs needed, not court Payeess needed
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Court Payees\' factors equal ' + courtPayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                                    Database.rollback(sp);
                                    return null;
                                }else{
                                    jp.Allocated_Amount__c = jw.ffAlloc;
                                }
                            }
                        }
                    }
                }
                
                //No matching JPs found, so we need to create new one(s) if needed
                if(!phiJPfound && jw.phiAlloc > 0){

                    //validate Payees
                    if(employeePayees.isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records on the Case to post to Post-Hearing Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else if(employeePayeesFactorSum != 100.00000){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else{
                        Judgment_Payment__c newPHIJP = new Judgment_Payment__c(
                            Case_Payment__c = casePayment.Id,
                            Allocated_Amount__c = jw.phiAlloc,
                            Apply_Payment_To__c = 'Post-Hearing Interest',
                            Judgment__c = jw.thisJudgment.Id,
                            Payment_On_Behalf_Of__c = relevantPOBO.Id,
                            Status__c = 'Posted'
                        );
                        JPsToInsert.add(newPHIJP);
                    }
                }
                if(!pjiJPfound && jw.pjiAlloc > 0){
                    
                    //validate Payees
                    if(employeePayees.isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Employee Case Role and Payee records on the Case to post to Post-Judgment Interest. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else if(employeePayeesFactorSum != 100.00000){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Employee Payees\' factors equal ' + employeePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else{
                        Judgment_Payment__c newPJIJP = new Judgment_Payment__c(
                            Case_Payment__c = casePayment.Id,
                            Allocated_Amount__c = jw.pjiAlloc,
                            Apply_Payment_To__c = 'Post-Judgment Interest',
                            Judgment__c = jw.thisJudgment.Id,
                            Payment_On_Behalf_Of__c = relevantPOBO.Id,
                            Status__c = 'Posted'
                        );
                        JPsToInsert.add(newPJIJP);
                    }
                }
                if(!afJPfound && jw.afAlloc > 0){
                    
                    //validate Payees
                    if(statePayees.isEmpty()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The State of California must have Case Role and Payee records on the Case to post to Attorney Fees. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else if(statePayeesFactorSum != 100.00000){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'State Payees\' factors equal ' + statePayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else{
                        Judgment_Payment__c newAFJP = new Judgment_Payment__c(
                            Case_Payment__c = casePayment.Id,
                            Allocated_Amount__c = jw.afAlloc,
                            Apply_Payment_To__c = 'Attorney Fees',
                            Judgment__c = jw.thisJudgment.Id,
                            Payment_On_Behalf_Of__c = relevantPOBO.Id,
                            Status__c = 'Posted'
                        );
                        JPsToInsert.add(newAFJP);
                    }
                }
                if(!ffJPfound && jw.ffAlloc > 0){
                    
                    //validate Payees
                    if(isDeposited && courtPayees.isEmpty()){ //Direct Payments are never deposited, no checks will ever be cut, not PRs needed, not court Payeess needed
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There must be Court Case Role and Payee records on the Case to post to Filing Fees. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else if(isDeposited && courtPayeesFactorSum != 100.00000){ //Direct Payments are never deposited, no checks will ever be cut, not PRs needed, not court Payeess needed
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Court Payees\' factors equal ' + courtPayeesFactorSum + ', not 100.00000. Please adjust factors. Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
                        Database.rollback(sp);
                        return null;
                    }else{
                        Judgment_Payment__c newFFJP = new Judgment_Payment__c(
                            Case_Payment__c = casePayment.Id,
                            Allocated_Amount__c = jw.ffAlloc,
                            Apply_Payment_To__c = 'Filing Fees',
                            Judgment__c = jw.thisJudgment.Id,
                            Payment_On_Behalf_Of__c = relevantPOBO.Id,
                            Status__c = 'Posted'
                        );
                        JPsToInsert.add(newFFJP);
                    }
                }
            }
            
            if(!LPsToInsert.isEmpty()){
                allLPList.addAll(LPsToInsert);
            }
            if(!JPsToInsert.isEmpty()){
                allJPList.addAll(JPsToInsert);
            }
            upsert allLPList;
            upsert allJPList;
            //update casePayment;
            
            
            //create PRs, only if Receipt has been deposited, or we're clicking the 'third button'. Assumes that no PRs exist currently.
            if(isDeposited || thirdButtonClicked){
                for(Liability_Payment__c lp : allLPList){
                    Decimal prPaymentAmount = 0.00;
                    System.debug('### Entered createPRs section');
                    if(lp.Payment_Applied_To__c == 'Wages'){
                        
                        //Create Payment Records for each Payee.
                        Map<Id, Decimal> prAmounts = CalculatePRAmounts(employeePayees, lp.Payment_Amount__c);

                        for(Payee__c payee : employeePayees){
                            prPaymentAmount = prAmounts.get(payee.Id);
                            if(prPaymentAmount != 0.00){
                                Payment_Record__c pr = new Payment_Record__c(
                                    Liability_Payment__c = lp.Id,
                                    Payee__c = payee.Id,
                                    Payment_Amount__c = prPaymentAmount
                                );
                                prsToInsert.add(pr); 
                            }
                        }
                    }else if(lp.Payment_Applied_To__c == 'Interest'){
                        System.debug('### lp.Case_Issue_RecordTypeId__c = '+lp.Case_Issue_RecordTypeId__c);
                        if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('WCA Violations').getRecordTypeId()){

                            //Create Payment Records for each Payee.
                            Map<Id, Decimal> prAmounts = CalculatePRAmounts(employeePayees, lp.Payment_Amount__c);
                            
                            for(Payee__c payee : employeePayees){
                                prPaymentAmount = prAmounts.get(payee.Id);
                                if(prPaymentAmount != 0.00){
                                    Payment_Record__c pr = new Payment_Record__c(
                                        Liability_Payment__c = lp.Id,
                                        Payee__c = payee.Id,
                                        Payment_Amount__c = prPaymentAmount
                                    );
                                    prsToInsert.add(pr); 
                                }
                            }
                        }else if(lp.Case_Issue_RecordTypeId__c == Schema.SObjectType.DIR_Violation__c.getRecordTypeInfosByName().get('BOFE Violations').getRecordTypeId()){
                            
                            //Create Payment Records for each Payee.
                            Map<Id, Decimal> prAmounts = CalculatePRAmounts(statePayees, lp.Payment_Amount__c);
                            
                            for(Payee__c payee : statePayees){
                                prPaymentAmount = prAmounts.get(payee.Id);
                                if(prPaymentAmount != 0.00){
                                    Payment_Record__c pr = new Payment_Record__c(
                                        Liability_Payment__c = lp.Id,
                                        Payee__c = payee.Id,
                                        Payment_Amount__c = prPaymentAmount
                                    );
                                    prsToInsert.add(pr); 
                                }
                            }
                        }
                    }else if(lp.Payment_Applied_To__c == 'Penalties'){
                        
                        //Only CP funds applied to Penalties and deposited to 32-117 need State Payees, so statePayees could be null here.
                        if(!statePayees.isEmpty()){
                            //Create Payment Records for each Payee.
                            Map<Id, Decimal> prAmounts = CalculatePRAmounts(statePayees, lp.Payment_Amount__c);
                            
                            for(Payee__c payee : statePayees){
                                prPaymentAmount = prAmounts.get(payee.Id);
                                if(prPaymentAmount != 0.00){
                                    Payment_Record__c pr = new Payment_Record__c(
                                        Liability_Payment__c = lp.Id,
                                        Payee__c = payee.Id,
                                        Payment_Amount__c = prPaymentAmount
                                    );
                                    prsToInsert.add(pr);
                                }
                            }
                        }
                    }
                }
                
                for(Judgment_Payment__c jp : allJPList){
                    Decimal prPaymentAmount = 0.00;
                    if(jp.Apply_Payment_To__c != 'Judgment Amount'){
                        if(jp.Apply_Payment_To__c == 'Post-Hearing Interest' || jp.Apply_Payment_To__c == 'Post-Judgment Interest'){
                            //Create Payment Records for each Payee.
                            Map<Id, Decimal> prAmounts = CalculatePRAmounts(employeePayees, jp.Allocated_Amount__c);
                            
                            for(Payee__c payee : employeePayees){
                                prPaymentAmount = prAmounts.get(payee.Id);
                                if(prPaymentAmount != 0.00){
                                    Payment_Record__c pr = new Payment_Record__c(
                                        Judgment_Payment__c = jp.Id,
                                        Payee__c = payee.Id,
                                        Payment_Amount__c = prPaymentAmount
                                    );
                                    prsToInsert.add(pr);
                                }
                            }
                        }else if(jp.Apply_Payment_To__c == 'Attorney Fees'){
                            //Create Payment Records for each Payee.
                            Map<Id, Decimal> prAmounts = CalculatePRAmounts(statePayees, jp.Allocated_Amount__c);
                            
                            for(Payee__c payee : statePayees){
                                prPaymentAmount = prAmounts.get(payee.Id);
                                if(prPaymentAmount != 0.00){
                                    Payment_Record__c pr = new Payment_Record__c(
                                        Judgment_Payment__c = jp.Id,
                                        Payee__c = payee.Id,
                                        Payment_Amount__c = prPaymentAmount
                                    );
                                    prsToInsert.add(pr);
                                }
                            }
                        }else if(jp.Apply_Payment_To__c == 'Filing Fees'){
                            //Create Payment Records for each Payee.
                            Map<Id, Decimal> prAmounts = CalculatePRAmounts(courtPayees, jp.Allocated_Amount__c);
                            
                            for(Payee__c payee : courtPayees){
                                prPaymentAmount = prAmounts.get(payee.Id);
                                if(prPaymentAmount != 0.00){
                                    Payment_Record__c pr = new Payment_Record__c(
                                        Judgment_Payment__c = jp.Id,
                                        Payee__c = payee.Id,
                                        Payment_Amount__c = prPaymentAmount
                                    );
                                    prsToInsert.add(pr);
                                }
                            }
                        }
                    }
                }
                System.debug('prsToInsert = ' + prsToInsert);
                if(!prsToInsert.isEmpty()){
                    //call the @Future method to insert paymentRecords
                    insertPaymentRecords(JSON.serialize(prsToInsert));
                }
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'PostCasePaymentController.Post(): DML or malformed data error:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + ex + '<br/>Screenshot this error page, then Click your browser\'s BACK button twice ⬅️⬅️ to continue.'));
            Database.rollback(sp);
            return null;
        }
        return new PageReference(retURL);
    }


    
    public Set<Judgment_Payment__c> findRedundantJPs(Liability_Payment__c lp, CaseIssueWrapper ciw){
        Set<Judgment_Payment__c> redundantJPs = new Set<Judgment_Payment__c>();
        Set<Liable_Party__c> targetLiableParties = new Set<Liable_Party__c>();
        Set<Judgement__c> targetJudgments = new Set<Judgement__c>();
        
        //If the redundant JPs are linked to the LP through the JP.Funds_Redundant_With__c field, find and add those to the set.
        for(Judgment_Payment__c jp : allJPList){
            if(jp.Funds_Redundant_With__c == lp.Id){
                redundantJPs.add(jp);
            }
        }
        
        //If the redundant JP is NOT linked to the LP (iow, Funds_Redundant_With__c is null), find them by matching Amounts (not completely unique)
        //  and their connection through CI <- LPCI -> Liable Party <- Judgment Party(Liability_Judgment__c) -> Judgment -> JP
        for(DIR_Violation__c ci : allCaseIssueList){
            for(Liable_Party_Case_Issue__c lpci : ci.Liable_Party_Case_Issues__r){
                if(lpci.Case_Issue__c == ciw.thisCaseIssue.Id 
                        && lpci.Liable_Party__c != null){  // LPCI fix
                    targetLiableParties.add(lpci.Liable_Party__r);
                }
            }
        }
        for(Liable_Party__c liableParty : targetLiableParties){
            for(Judgement__c judgment : allJudgmentList){
                for(Liability_Judgement__c judgmentParty : judgment.Liability_Judgements__r){
                    if(judgmentParty.Liable_Party__c == liableParty.Id){
                        targetJudgments.add(judgment);
                    }
                }
            }
        }
        for(Judgement__c judgment : targetJudgments){
            for(Judgment_Payment__c jp : allJPList){
                if(jp.Judgment__c == judgment.Id &&
                   jp.Recommended_Amount__c == lp.Recommended_Allocation__c &&
                   jp.Allocated_Amount__c == lp.Payment_Amount__c &&
                //   jp.Payment_On_Behalf_Of__c == lp.Payment_on_Behalf_of__c && //// TODO: the JP.POBO could be different if there are multiple Judgments and Judgment Parties on the case
                   jp.Funds_Redundant_With__c == null){ ////JP.FRW should at least not be already linked to an LP
                    redundantJPs.add(jp);
                }
            }
        }
        
        return redundantJPs;
    }
    
    public List<Judgment_Payment__c> createRedundantJPs(List<Liability_Payment__c> lps, String status){
        List<Judgment_Payment__c> redundantJPs = new List<Judgment_Payment__c>();
        for(Liability_Payment__c lp : lps){
            Set<Liable_Party__c> targetLiableParties = new Set<Liable_Party__c>();
            
            for(DIR_Violation__c ci : allCaseIssueList){
                for(Liable_Party_Case_Issue__c lpci : ci.Liable_Party_Case_Issues__r){
                    if(lpci.Case_Issue__c == lp.Case_Violation__c
                            && lpci.Liable_Party__c != null){ // LPCI fix
                        targetLiableParties.add(lpci.Liable_Party__r);
                    }
                }
            }
            System.debug('targetLiableParties = '+targetLiableParties);
            for(Liable_Party__c liableParty : targetLiableParties){
                System.debug('allJudgmentList = '+allJudgmentList);
                for(Judgement__c judgment : allJudgmentList){
                    for(Liability_Judgement__c judgmentParty : judgment.Liability_Judgements__r){
                        System.debug('judgment.Liability_Judgements__r = '+judgment.Liability_Judgements__r);
                        System.debug('judgmentParty.Liable_Party__c = '+judgmentParty.Liable_Party__c);
                        System.debug('liableParty.Id = '+liableParty.Id);
                        if(judgmentParty.Liable_Party__c == liableParty.Id){
                            Judgment_Payment__c jp = new Judgment_Payment__c(
                                Apply_Payment_To__c = 'Judgment Amount',
                                Case_Payment__c = casePayment.Id,
                                Funds_Redundant_With__c = lp.Id,
                                Judgment__c = judgment.Id,
                                Payment_On_Behalf_Of__c = liableParty.Id,
                                Status__c = status
                            );
                            if(status == 'Posted'){
                                jp.Allocated_Amount__c = lp.Payment_Amount__c;
                            }else{
                                jp.Recommended_Amount__c = lp.Recommended_Allocation__c;
                            }
                            redundantJPs.add(jp);
                        }
                    }
                }
            }
        }
        return redundantJPs;
    }
    
    
    // Method Name: CalculatePRAmounts
    // Created: Jan 29, 2018
    // Author: Daniel Chu
    // Description: This method calculates the payment amount for each payee according to their factor and incoming payment amount. 
    // Assumption: Payees' factors sum to 100.00000. If not, this method will give an Apex CPU time limit error.
    
    public Map<Id, Decimal> CalculatePRAmounts(List<Payee__c> payeeList, Decimal amtToBeDivided){
        
        Decimal remainingLiabAmt = amtToBeDivided;
        Map<Id, Decimal> payeeTempPayAmt = new Map<Id, Decimal>();
        System.debug('### payeeList size = ' + payeeList.size());
        Integer debugCounter = 1;
        for(Payee__c payee : payeeList){
            Decimal beforeRoundingPaymentAmt; 
            Decimal afterRoundingPaymentAmt; 
            
            Decimal factor = payee.Factor__c == null ? 0 : payee.Factor__c / 100;
            System.debug('### payee.Factor__c = ' + payee.Factor__c + ' factor = ' + factor);
            
            beforeRoundingPaymentAmt = amtToBeDivided * factor;
            System.debug('### beforeRoundingPaymentAmt = ' + beforeRoundingPaymentAmt);
            afterRoundingPaymentAmt = beforeRoundingPaymentAmt.setScale(2, RoundingMode.DOWN);  
            System.debug('### afterRoundingPaymentAmt = ' + afterRoundingPaymentAmt);

            payeeTempPayAmt.put(payee.Id, afterRoundingPaymentAmt);  
            remainingLiabAmt -= afterRoundingPaymentAmt;
            System.debug('### for loop iteration #' + debugCounter + ' afterRoundingPaymentAmt = ' + afterRoundingPaymentAmt + ' remainingLiabAmt = ' + remainingLiabAmt);

            debugCounter++;
        }

        //If there is a remaining amount due to rounding, disperse randomly even among the payees.
        while(remainingLiabAmt > 0.00){
            System.debug('### Inside rounding correction, remainingLiabAmt = ' + remainingLiabAmt);
            for(Payee__c payee : payeeList){
                Decimal getPayeeTempPayAmt = payeeTempPayAmt.get(payee.Id);
                getPayeeTempPayAmt += 0.01;
                payeeTempPayAmt.put(payee.Id,getPayeeTempPayAmt);
                remainingLiabAmt -= 0.01;
                System.debug('### After random application to a Payee, remainingLiabAmt = ' + remainingLiabAmt);
            }
        }
        return payeeTempPayAmt;
    }
    
    @future
    private static void insertPaymentRecords(String serializePrCollection){
        List<Payment_Record__c> paymentRecord = (List<Payment_Record__c>)JSON.deserializeStrict(serializePrCollection, List<Payment_Record__c>.class);
        System.debug('### paymentRecord list size = ' + paymentRecord);
        insert paymentRecord;
    }
    
    public pageReference showPrintView(){
        pageReference PostCasePaymentPrint = Page.PostCasePaymentVFP;
        PostCasePaymentPrint.getParameters().put('id',casePayment.Id);
        if(printView == false){
            PostCasePaymentPrint.getParameters().put('printView','true');
            printView = true;
        }else{
            printView = false;
        }
        PostCasePaymentPrint.setRedirect(true);
        return PostCasePaymentPrint;
    }
    
    public class CaseIssueWrapper{
        public DIR_Violation__c thisCaseIssue{get; set;}
        public Liability_Payment__c paymentPenalties{get; set;}
        public Liability_Payment__c paymentWages{get; set;}
        public Liability_Payment__c paymentInterest{get; set;}
        
        public String citationNums{get; set;}
        public String jeuCaseNum{get; set;}
        public Decimal allocationToPenalties{get; set;}
        public Decimal allocationToWages{get; set;}
        public Decimal allocationToInterest{get; set;}
        public CaseIssueWrapper(DIR_Violation__c caseIssue){
            thisCaseIssue = caseIssue;
            citationNums = thisCaseIssue.Assessment__r.Citation_Number__c;
            jeuCaseNum = thisCaseIssue.Assessment__r.JEU_Case_number__c;
            allocationToPenalties = 0.00;
            allocationToWages = 0.00;
            allocationToInterest = 0.00;
        }
    }
    
    public class JudgmentWrapper{
        public Judgement__c thisJudgment{get;set;}
        public Decimal phiAlloc{get;set;}
        public Decimal pjiAlloc{get;set;}
        public Decimal afAlloc{get;set;}
        public Decimal ffAlloc{get;set;}
        
        public JudgmentWrapper(Judgement__c judgment){
            thisJudgment = judgment;
            phiAlloc = 0.00;
            pjiAlloc = 0.00;
            afAlloc = 0.00;
            ffAlloc = 0.00;
            
            for(Judgment_Payment__c judgmentPayment : thisJudgment.Judgment_Payments__r){
                if(judgmentPayment.Recommended_Amount__c != null && judgmentPayment.Recommended_Amount__c != 0){
                    if(judgmentPayment.Apply_Payment_To__c == 'Post-hearing Interest'){
                    phiAlloc = judgmentPayment.Recommended_Amount__c;
                    }else if(judgmentPayment.Apply_Payment_To__c == 'Post-Judgment Interest'){
                        pjiAlloc = judgmentPayment.Recommended_Amount__c;
                    }else if(judgmentPayment.Apply_Payment_To__c == 'Filing Fees'){
                         ffAlloc = judgmentPayment.Recommended_Amount__c;
                    }else if(judgmentPayment.Apply_Payment_To__c == 'Attorney Fees'){
                        afAlloc = judgmentPayment.Recommended_Amount__c;
                    }
                }
            }
        }
    }
    
    private String invalidReason = '';
    private boolean warningIssued = false;
    public boolean isValid{ ////TODO: why are we validating Case Management closure stuff here? Maybe we can get rid of this.
        get{
            isValid = true;
            
            if(DIRcase == null){  ////This will never happen: Master-Detail. I wonder why Vertiba put this here originally...
                isValid = false;
                invalidReason = 'There is no valid Case Management related to this Payment. I\'ll bet you $100 this error message never displays on the VFP.';
            }
            
            if(casePayment.Returned_Item__c || casePayment.Voided_Item__c){
                isValid = false;
                invalidReason = 'This Case Payment\'s related Receipt was returned or voided. Recommending or Posting is not allowed. Haha.';
            }
            
            return isValid;
        }
        private set;
    }
    
    private void getCustomMetadataPermissions(){
        
        List<Post_Case_Payment_Button_Setting__mdt> allPCPbuttonMDTs = [SELECT Id, DIR_Case_Recordtype_Name__c, User_Profile__c, Permission_Set__c, Condition_Field__c, Condition_Field_Value__c,
                                                                                Recommend_Button_Rendering__c, Post_Button_Rendering__c, Third_Button_Rendering__c, Message__c
                                                                            FROM Post_Case_Payment_Button_Setting__mdt];
        
        List<Post_Case_Payment_Button_Setting__mdt> applicablePCPbuttonMDTs = new List<Post_Case_Payment_Button_Setting__mdt>();
        
        User runningUser = [SELECT Id, Name, Profile.Name
                                FROM User
                                WHERE Id = :userInfo.getUserId()];
        
        List<PermissionSetAssignment> userPermissionSetAssignments = [SELECT Id, PermissionSetId
                                                                        FROM PermissionSetAssignment
                                                                        WHERE AssigneeId = :runningUser.Id];
        
        List<Id> userPermissionSetIds = new List<Id>();
        
        for(PermissionSetAssignment userPermissionSetAssignment : userPermissionSetAssignments){
            userPermissionSetIds.add(userPermissionSetAssignment.PermissionSetId);
        }
        
        List<PermissionSet> userPermissionSets = [SELECT Id, Name
                                                FROM PermissionSet
                                                WHERE Id IN :userPermissionSetIds];
        
        List<String> userPermissionSetNames = new List<String>();
        for(PermissionSet userPermissionSet : userPermissionSets){
            userPermissionSetNames.add(userPermissionSet.Name);
        }
        
        System.debug('allPCPbuttonMDTs = ' + allPCPbuttonMDTs);
        
        for(Post_Case_Payment_Button_Setting__mdt PCPbuttonMDT : allPCPbuttonMDTs){
            System.debug('####PCPbuttonMDT: ' + PCPbuttonMDT);
            //PCP button MDTs have 3 criteria fields. A null field indicates a wild card on that field--except when all 3 fields are null, then that MDT is ignored.
            
            //filter for MDTs with only one criteria specified
            if((PCPbuttonMDT.User_Profile__c == runningUser.Profile.Name && PCPbuttonMDT.DIR_Case_Recordtype_Name__c == null && PCPbuttonMDT.Permission_Set__c == null) ||
                (PCPbuttonMDT.User_Profile__c == null && PCPbuttonMDT.DIR_Case_Recordtype_Name__c == DIRcase.RecordType.DeveloperName && PCPbuttonMDT.Permission_Set__c == null)){
                    System.debug('####Just one-Profile, RT: ' + PCPbuttonMDT.User_Profile__c+', '+DIRcase.RecordType.DeveloperName);
                    applicablePCPbuttonMDTs.add(PCPbuttonMDT);
            }
            for(String userPermissionSetName : userPermissionSetNames){
                if(PCPbuttonMDT.User_Profile__c == null && PCPbuttonMDT.DIR_Case_Recordtype_Name__c == null && PCPbuttonMDT.Permission_Set__c == userPermissionSetName){
                    System.debug('###Just one PermSet: = ' + userPermissionSetName);
                    applicablePCPbuttonMDTs.add(PCPbuttonMDT);
                }
            }
            
            //filter for MDTs with 2 criterion specified
            if(PCPbuttonMDT.User_Profile__c == runningUser.Profile.Name && PCPbuttonMDT.DIR_Case_Recordtype_Name__c == DIRcase.RecordType.DeveloperName && PCPbuttonMDT.Permission_Set__c == null){
                applicablePCPbuttonMDTs.add(PCPbuttonMDT);
                System.debug('####2-Profile, RT: ' + PCPbuttonMDT.User_Profile__c+', '+DIRcase.RecordType.DeveloperName);
            }
            for(String userPermissionSetName : userPermissionSetNames){
                if((PCPbuttonMDT.User_Profile__c == runningUser.Profile.Name && PCPbuttonMDT.DIR_Case_Recordtype_Name__c == null && PCPbuttonMDT.Permission_Set__c == userPermissionSetName) ||
                    (PCPbuttonMDT.User_Profile__c == null && PCPbuttonMDT.DIR_Case_Recordtype_Name__c == DIRcase.RecordType.DeveloperName && PCPbuttonMDT.Permission_Set__c == userPermissionSetName)){
                        System.debug('####2-Profile, RT or PermSet: ' + PCPbuttonMDT.User_Profile__c+', '+DIRcase.RecordType.DeveloperName+', '+userPermissionSetName);
                        applicablePCPbuttonMDTs.add(PCPbuttonMDT);
                }
            }
            
            //filter for MDTs with all 3 criterion specified
            for(String userPermissionSetName : userPermissionSetNames){
                if(PCPbuttonMDT.User_Profile__c == runningUser.Profile.Name && PCPbuttonMDT.DIR_Case_Recordtype_Name__c == DIRcase.RecordType.DeveloperName && PCPbuttonMDT.Permission_Set__c == userPermissionSetName){
                    System.debug('####All 3-Profile, RT, PermSet: ' + PCPbuttonMDT.User_Profile__c+', '+DIRcase.RecordType.DeveloperName+', '+userPermissionSetName);
                    applicablePCPbuttonMDTs.add(PCPbuttonMDT);
                }
            }
        }
        
        System.debug('applicablePCPbuttonMDTs = ' + applicablePCPbuttonMDTs);
        renderRecommendBtn = false;
        renderPostBtn = false;
        renderThirdBtn = false;
        
        if(applicablePCPbuttonMDTs.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No permissions were found based on your profile settings and the configured permissions for this page. Please contact a System Administrator for assistance. Click your browser\'s BACK button twice ⬅️⬅️ to continue.\n[Custom Metadata Type: Post_Case_Payment_Button_Setting__mdt]'));
        
        }else{
            for(Post_Case_Payment_Button_Setting__mdt applicableMDT : applicablePCPbuttonMDTs){
                if(applicableMDT.Recommend_Button_Rendering__c == 'Active'){
                    renderRecommendBtn = true;
                }
                if(applicableMDT.Post_Button_Rendering__c == 'Active'){
                    renderPostBtn = true;
                }
                if(applicableMDT.Third_Button_Rendering__c == 'Active'){
                    renderThirdBtn = true;
                }
            }
        }
    }
}