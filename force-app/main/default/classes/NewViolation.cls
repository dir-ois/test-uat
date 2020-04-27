public with sharing class NewViolation {

    public Integer wrapperIndex {get;set;}
    public Boolean selectAll {get;set;}
    public boolean rtError {get;set;}
    
    private List<Record_Type_Mapping__c> vtMapping;
    private Record_Type_Mapping__c thisMapping;
    private Map<String, RecordType> rtMap = new Map<String, RecordType>();
    //public ApexPages.StandardController controller;

        
    public NewViolation() {
        selectAll = false;
        rtError = false;
        wrapperIndex = 1;
        SelectedTypes = new List<ViolationTypeWrapper>();
        secondStep = false;
        SelectedCitation = 'Single'; 
        ShowEmployeeDialog = false;
        vtMapping = Record_Type_Mapping__c.getall().values();
    }
    
   
    public PageReference LoadCase() {
        string caseId = ApexPages.currentPage().getParameters().get('id');
        if (caseId == null || caseId == '')
            return new PageReference('/' + DIR_Case__c.sObjectType.getDescribe().getKeyPrefix());
        try { 
            c = [SELECT Employer__c, Case_Number__c, Employer__r.Name, RecordType.DeveloperName FROM DIR_Case__c WHERE Id = :caseId];
            return null;
        } catch (Exception ex) {
            return new PageReference('/' + DIR_Case__c.sObjectType.getDescribe().getKeyPrefix());
        }
    }
    
    public boolean getRTError{
        get{
            return rtError;
        }
        set;
    }
    
    public boolean secondStep { get; set; }

    public DIR_Case__c c { get; set; }
        
    private List<ViolationTypeWrapper> violationTypesP;
    public List<ViolationTypeWrapper> ViolationsTypes {
        get {
            if (violationTypesP == null) {
                for(Record_Type_Mapping__c v : vtMapping){
                    if(v.Case_Rec_Type__c == c.RecordType.DeveloperName){
                            thisMapping = v;
                            break;
                    }
                }
                if(thisMapping == null){
                    rtError = true;
                    return null;
                }
                violationTypesP = new List<ViolationTypeWrapper>();
                List<Violation_Type__c> vTypes = [SELECT Id, Name, Violation_Text__c, Assessment_Formula__c, Violation_Type__c, Help_Text__c, Penalty_Assessment_Description__c, 
                                                        Civil_Penalty_Section__c, Wage_Assessment_Formula__c, Wage_Assessment_Description__c, RecordType.DeveloperName, Short_Description__c,
                                                        Amount_Paid_Formula__c, Amount_Earned_Formula__c, Wizard_Search_Text__c, Wage_Interest_Assessment_Formula__c, Wage_Interest_Assessment_Description__c,
                                                        Assessment_Variable_A__c, Variable_A_Description__c, Assessment_Variable_B__c, Variable_B_Description__c,
                                                        Assessment_Variable_C__c, Variable_C_Description__c, Assessment_Variable_D__c, Variable_D_Description__c,
                                                        Assessment_Variable_E__c, Variable_E_Description__c, Assessment_Variable_F__c, Variable_F_Description__c,
                                                        Assessment_Variable_G__c, Variable_G_Description__c, Assessment_Variable_H__c, Variable_H_Description__c,
                                                        Assessment_Variable_I__c, Variable_I_Description__c, Assessment_Variable_J__c, Variable_J_Description__c,
                                                    (SELECT Id, Name, Description__c, Data_Type__c, Value__c FROM Violation_Type_Variables__r ORDER BY Name asc)
                                                    FROM Violation_Type__c WHERE Active__c = true ORDER BY Help_text__c];
                for (Violation_Type__c vT : vTypes){
                    if(vT.RecordType.DeveloperName == thisMapping.Violation_Type_Rec_Type__c){
                        //Changes made as per SR-005885
                        if(vt.Name.contains('L.C. 238(f)')){
                            if(vt.Name.contains('L.C. 238(f) – Subsequent Violations')){
                                violationTypesP.add(new ViolationTypeWrapper(vT, wrapperIndex++));
                            }
                        }
                        else{
                            violationTypesP.add(new ViolationTypeWrapper(vT, wrapperIndex++));
                        }
                    }
                }
            }
            
            //determine LIA RT based on CM RT
            List<String> rtIdentifier = new List<String>();
            if(c.RecordType.DeveloperName.contains('BOFE')){
                rtIdentifier.add('BOFE');
            }
            else if(c.RecordType.DeveloperName.contains('WCA')){
                rtIdentifier.add('WCA');
            }
            else if(c.RecordType.DeveloperName.contains('Garment')){
                rtIdentifier.add('Garment');
            }
            else if(c.RecordType.DeveloperName.contains('PASS')){
                rtIdentifier.add('BOFE');
            }
            else if(c.RecordType.DeveloperName.contains('RCI')){
                rtIdentifier.add('RCI');
            }
            else if(c.RecordType.DeveloperName.contains('JEU')){
                rtIdentifier.add('JEU');
                rtIdentifier.add('BOFE');
            }
          else if(c.RecordType.DeveloperName.contains('Registration')){
               rtIdentifier.add('Registration');
            }
           
            else{
                system.debug('***** case RT not found');
            }

            List<RecordType> rtList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType IN ('Liability__c', 'Liable_Party__c') AND DeveloperName IN :rtIdentifier];
            system.debug('******* rtList::::: ' + rtList);
            for(RecordType rt : rtList){
                if(!rtMap.containsKey(rt.SobjectType)){
                    rtMap.put(rt.SobjectType, rt);
                    system.debug('***** Put into rtMap:::: ' + rt);
                }
            }
            return violationTypesP;
        }
        set;
    }
    
    private List<LiabilityWrapper> liabilitiesP;
    public List<LiabilityWrapper> Liabilities {
        get {
            if (liabilitiesP == null) {
                
                liabilitiesP = new List<LiabilityWrapper>();

                List<Case_Role__c> liabs = [SELECT Id, Name, Role__c, Entity__c, Entity__r.Name, Case__c, Case__r.Name
                                                   FROM Case_Role__c 
                                                   WHERE Case__c = :c.Id AND Eligible_for_Liability__c = True];
                for (Case_Role__c lb : liabs) {
                    if (lb.Entity__c != null)
                        liabilitiesP.add(new LiabilityWrapper(lb, rtMap));
                }
            }
            return liabilitiesP;
        }
    }
    
    public List<ViolationTypeWrapper> SelectedTypes { get; set; }
    public integer SelectedSize {
        get {
            return SelectedTypes.size();
        }
    }
    
    public String violationId {get;set;}
    public Boolean SelectTypeExist {get;set;}
    public void addViolation(){
       saveVarValues();
       system.debug('START Violation Types'); 
       //SelectTypeExist = False; 
       system.debug(ViolationsTypes);
       for(ViolationTypeWrapper vtw : ViolationsTypes){
           /*
           if (SelectedSize >= 1 && violationId == vtw.vType.Id){
                for(Integer i=0; i<SelectedSize; i++){
                    if(selectedTypes[i].vType.id == vtw.vType.Id){
                        SelectTypeExist = True;
                        break;
                    }
                }
            }
            else {
                SelectTypeExist = False;
            }*/
            system.debug('ViolationId = '+violationId);
            system.debug('vtw.vType.Id = '+vtw.vType.Id);
            if(violationId == vtw.vType.Id && vtw.vType.RecordType.DeveloperName.contains('BOFE') && (vtw.vType.Civil_Penalty_Section__c == 'L.C. 3722(a)' || vtw.vType.Civil_Penalty_Section__c == 'L.C. 3722(b)')){
                selectedTypes.add(new ViolationTypeWrapper(vtw.vType, wrapperIndex++));
                
                if(!vtw.vType.Wizard_Search_Text__c.containsIgnoreCase('BOFE 335')){
                        for(ViolationTypeWrapper Reqvtw : ViolationsTypes){
                            if(Reqvtw.vType.Civil_Penalty_Section__c == 'L.C. 3710.1'){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Reqvtw.vType.Civil_Penalty_Section__c+' is added automatically since '+vtw.vType.Civil_Penalty_Section__c+' is included'));
                                selectedTypes.add(new ViolationTypeWrapper(Reqvtw.vType, wrapperIndex++));
                            }   
                        }  
                    }     
           }
            else if(violationId == vtw.vType.Id && vtw.vType.RecordType.DeveloperName.contains('BOFE') && (vtw.vType.Name.contains('L.C. 1197') || vtw.vType.Name.contains('L.C. 1197.1 City or County'))){
                selectedTypes.add(new ViolationTypeWrapper(vtw.vType, wrapperIndex++));
                
                for(ViolationTypeWrapper Reqvtw : ViolationsTypes){
                    if(Reqvtw.vType.Name.contains('L.C. 1194.2')){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Reqvtw.vType.Name+' is added automatically since '+vtw.vType.Name+' is included'));
                        selectedTypes.add(new ViolationTypeWrapper(Reqvtw.vType, wrapperIndex++));
                    }   
                }  
            }
            else if(violationId == vtw.vType.Id){
                selectedTypes.add(new ViolationTypeWrapper(vtw.vType, wrapperIndex++));
            } 
        }
        system.debug('END Violation Types');
    }
    
    public String violationIndex {get;set;}
    public Boolean requiredVio {get;set;}
    public void removeViolation(){
        saveVarValues();
        system.debug('Remove Violation');
        system.debug('Violation Index'+ violationIndex);
        
        for(Integer i=0; i<SelectedSize; i++){
            if(selectedTypes[i].indexCounter == Integer.valueOf(violationIndex)){
                if(selectedTypes[i].vType.Name == 'L.C. 1194.2'){
                    requiredVio = False;
                    for(ViolationTypeWrapper vtw : selectedTypes){
                        if(vtw.vType.RecordType.DeveloperName == 'BOFE_Violations' && (vtw.vType.Name == 'L.C. 1197' || vtw.vType.Name == 'L.C. 1197.1 City or County')){
                            requiredVio = True;
                        }
                    }
                    if(requiredVio == True){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, selectedTypes[i].vType.Name+' cannot be deleted as it is required for L.C. 1197 or L.C. 1197.1 City or County'));
                    }
                    else{
                        selectedTypes.remove(i);
                    }
                }
                else if(selectedTypes[i].vType.Civil_Penalty_Section__c == 'L.C. 3710.1'){
                    requiredVio = False;
                    for(ViolationTypeWrapper vtw : selectedTypes){
                        if(vtw.vType.RecordType.DeveloperName == 'BOFE_Violations' && (vtw.vType.Civil_Penalty_Section__c == 'L.C. 3722(a)' || vtw.vType.Civil_Penalty_Section__c == 'L.C. 3722(b)')){
                            requiredVio = True;
                        }
                    }
                    if(requiredVio == True){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, selectedTypes[i].vType.Civil_Penalty_Section__c+' cannot be deleted as it is required for L.C. 3722(a) or L.C. 3722(b)'));
                    }
                    else{
                        selectedTypes.remove(i);
                    }
                }
                else{
                    selectedTypes.remove(i);
                }    
            }
        }
    }
    
    public void GoToSecondStep() {
        secondStep = true;
    }
    
    public void BackTo1stStep() {
        saveVarValues();
        secondStep = false;
    }
    
    public decimal TotalAmount { get; set; }
    public decimal TotalInterestWages { get; set; }

    public decimal TotalWages { 
        get; 
        set{
            TotalWages = value.setScale(2, system.RoundingMode.HALF_UP);
        } 
    }
    
    public String SelectedCitation { get; set; }
    
    public List<SelectOption> getCitationItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Single','Single Citation One Number')); 
        options.add(new SelectOption('Multi','Separate Citations Multiple Citation Numbers'));
        return options; 
    }
    
    public Pagereference Finalize() {
        try{
            saveVarValues();
            RecordType violRT = [SELECT Id FROM RecordType WHERE sObjectType = 'DIR_Violation__c' AND DeveloperName =: thisMapping.Case_Violation_Rec_Type__c LIMIT 1];
            if (LegalConsultVisible && (EmployeeId == null || EmployeeId == '')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Legal Consult'));
                return null;
            }
            Integer counter = 0;
            for(LiabilityWrapper lw : Liabilities){
                if(lw.selected){
                        counter++;
                }
            }
            if(counter == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Select Individual(s) Liable for these violation(s)'));
                return null;
            }
            system.debug('SelectedTypes::::: ' + SelectedTypes);
            Map<String, List<ViolationTypeWrapper>> vTypeMap = new Map<String, List<ViolationTypeWrapper>>();
            for (ViolationTypeWrapper vTypeW : SelectedTypes) {
                if (!vTypeMap.containsKey(vTypeW.vType.Violation_Type__c))
                    vTypeMap.put(vTypeW.vType.Violation_Type__c, new List<ViolationTypeWrapper>());
                vTypeMap.get(vTypeW.vType.Violation_Type__c).add(vTypeW);
            }
            List<Assessments__c> assessList = new List<Assessments__c>();
            List<DIR_Violation__c> violList = new List<DIR_Violation__c>();
            List<Violation_Variable__c> vvList = new List<Violation_Variable__c>();
            List<DIR_Employee__c> employees = [SELECT Id FROM DIR_Employee__c WHERE User__c = :UserInfo.getUserId() AND (Position__c = 'Deputy' OR Position__c = 'Senior Deputy')];
            for (String key : vTypeMap.keySet()) {
                Assessments__c assess = new Assessments__c(
                        Case_Management__c = c.Id,
                        Appeal_Deadline_Selector__c = 'Business Days',
                        Citation_Form__c = key,
                        Total_Wages_assessed__c = 0
                );
                assessList.add(assess);
                decimal assessTotal = 0;
                for(ViolationTypeWrapper vtw : vTypeMap.get(key)){
                    DIR_Violation__c viol = new DIR_Violation__c(
                        Assessment__r = assess,
                        //Assessment__r = assessMap.get(vt.Citation_Form__c),
                        RecordTypeId = violRT.Id,
                        Case__c = c.Id,
                        Violation_Type__c = vtw.vType.Id,
                        Penalty_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Penalty_Assessment_Description__c),
                        Wage_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Wage_Assessment_Description__c),
                        Original_Penalty_Assessment_Amount__c = vtw.subTotalA == null ? 0 : vtw.subTotalA,
                        //viol.Citation_Amount__c = vtw.amount,
                        //viol.Original_Penalty_Assessment_Amount__c = vtw.amount
                        Citation_Amount__c = vtw.subTotalA == null ? 0 : vtw.subTotalA,
                        Original_Wage_Assessment_Amount__c = vtw.subTotalW == null ? 0 : vtw.subTotalW,
                        Wages_Due__c = vtw.subTotalW == null ? 0 : vtw.subTotalW,
                        Amount_Paid__c = vtw.amountPaid == null ? 0 : vtw.amountPaid,
                        Amount_Earned__c = vtw.amountEarned == null ? 0 : vtw.amountEarned,
                        Total_Wage_Interest_Amount__c = vtw.subTotalIW == null ? 0 : vtw.subTotalIW
                    );
                    if(employees.size() == 1){
                        viol.DIR_Employee__c = employees[0].Id;
                    }
                    for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
                        Violation_Variable__c vv = new Violation_Variable__c(
                            Case_Violation__r = viol,
                            Violation_Type_Variable__c = vtv.vTypeVar.Id,
                            Value__c = vtv.varValue
                        );
                        vvList.add(vv);
                    }
                    violList.add(viol);
                }
            }
            insert assessList;
            for (DIR_Violation__c viol : violList) {
                viol.Assessment__c = viol.Assessment__r.Id;
            }
            insert violList;
            
            for (Violation_Variable__c vv : vvList) {
                vv.Case_Violation__c = vv.Case_Violation__r.Id;
            }
            insert vvList;
        
            if(SelectedCitation == 'Single'){
                List<Liability__c> liabList = new List<Liability__c>();
                for (Assessments__c assess : assessList) {
                    Liability__c liab = new Liability__c();
                    liab.Assessment__c = assess.Id;
                    liab.Case_Management__c = c.Id;
                    liab.Legal_Consult__c = EmployeeId;
                    liab.RecordTypeId = rtMap.get('Liability__c').Id;
                    liabList.add(liab);
                }
                insert liabList;
                List<Liable_Party__c> partyList = new List<Liable_Party__c>();
                for (Liability__c liab : liabList) {
                    for (LiabilityWrapper lw : Liabilities) {
                        if (lw.selected) {
                            Liable_Party__c party = new Liable_Party__c();
                            party.RecordTypeId = lw.thisLiabParty.RecordTypeId;
                            party.Basis_for_Liability__c = lw.thisLiabParty.Basis_for_Liability__c;
                            party.Liability__c = liab.Id;
                            party.Proportionate_Share__c = lw.propShare == null ? 100 : Decimal.valueOf(lw.propShare);
                            party.Entity__c = lw.AccountId;
                            party.Case_Role__c = lw.thisCR.Id;
                            partyList.add(party);
                        }
                    }
                }
                insert partyList;
            } 
            else{
                List<Liability__c> liabList = new List<Liability__c>();
                List<Liable_Party__c> partyList = new List<Liable_Party__c>();
                for (Assessments__c assess : assessList) {
                    for (LiabilityWrapper lw : Liabilities) {
                        if (lw.selected) {
                            Liability__c liab = new Liability__c();
                            liab.RecordTypeId = lw.thisLiab.RecordTypeId;
                            liab.Assessment__c = assess.Id;
                            liab.Case_Management__c = c.Id;
                            liab.Legal_Consult__c = EmployeeId;
                            liabList.add(liab);
                            Liable_Party__c party = new Liable_Party__c();
                            party.RecordTypeId = lw.thisLiabParty.RecordTypeId;
                            party.Basis_for_Liability__c = lw.thisLiabParty.Basis_for_Liability__c;
                            party.Liability__r = liab;
                            party.Entity__c = lw.AccountId;
                            party.Case_Role__c = lw.thisCR.Id;
                            party.Proportionate_Share__c = lw.propShare == null ? 100 : Decimal.valueOf(lw.propShare);
                            partyList.add(party);
                        }
                    }
                }
                insert liabList;
                for (Liable_Party__c party : partyList) {
                    party.Liability__c = party.Liability__r.Id;
                }
                insert partyList;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }        
        return new PageReference('/' + c.Id);
    }
    
    public string ParseExplanation(ViolationTypeWrapper vtw, String assessDesc) {
        string retValue = assessDesc;
        if (retValue == null)
            return null;
            
        while (retValue.contains('{') && retValue.contains('}')) {
            
            System.debug('retValue:' + retValue);
            
            string toCalculate = retValue.subString(retValue.indexOf('{') + 1, retValue.indexOf('}'));
            
            System.debug('toCalculate:' + toCalculate);
            
            decimal valuesofar;
            
            decimal operand;
            string operator;
            
            integer position = 0;
            
            while (position < toCalculate.length()) {
                if(toCalculate.subString(position, position + 1) == '~'){
                    string var = toCalculate.subString(position, position + 9);
                    for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
                        var = var.replace('~', '');
                        if(var == vtv.vtvName){
                            if(vtv.varValue == null ){
                                    vtv.varValue = '0';
                            }
                            operand = Decimal.valueOf(vtv.varValue);
                            String identifier = String.valueOf(vtw.indexCounter) + String.valueOf(vtv.indexCounter);
                            
                            if (valuesofar == null) {
                                valuesofar = operand;
                            } 
                            else {
                                if (operator == '*')
                                    valuesofar *= operand;
                                if (operator == '-')
                                    valuesofar -= operand;
                                if (operator == '+')
                                    valuesofar += operand;
                                if (operator == '/')
                                    valuesofar /= operand;
                            }
                            position += 9;
                        }
                    }
                } 
                else {
                    operator = toCalculate.subString(position, position + 1);
                    position += 1;
                }
            }
            retValue = retValue.substring(0, retValue.indexOf('{')) + valuesofar.setScale(2, system.RoundingMode.HALF_UP).format() + retValue.substring(retValue.indexOf('}') + 1);
        }
        for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
            String var = '~'+vtv.vtvName+'~';
            retValue = retValue.Replace(var, string.valueOf(vtv.varValue));
        }
        return retValue;
    
    }

    public class LiabilityWrapper {
        public Contact cnt { get; set; }
        public Account acc { get; set; }
        public boolean selected { get; set; }
        public string Affiliation { get; set; }
        public string propShare { get; set; }
        public Liability__c thisLiab { get; set; }
        public Liable_Party__c thisLiabParty { get; set; }
        public Case_Role__c thisCR {get;set;}
        
        public Id AccountId {
            get {
                if (acc != null)
                    return acc.Id;
                if (cnt != null)
                    return cnt.AccountId;
                return null;
            }
        }
        public string Name {
            get {
                if (acc != null)
                    return acc.Name;
                if (cnt != null)
                    return cnt.Name;
                return null;
            }
        }
        
        public LiabilityWrapper(Contact cnt1, string aff, Map<String, RecordType> rtMap) {
            propShare = '100';
            cnt = cnt1;
            if(Test.isRunningTest())
                selected = true;
            else
                selected = false;
            Affiliation = aff;
            thisLiab = new Liability__c(
                recordTypeId = rtMap.get('Liability__c').Id
            );
            thisLiabParty = new Liable_Party__c(
                recordTypeId = rtMap.get('Liable_Party__c').Id
            );
        }
        public LiabilityWrapper(Case_Role__c cr, Map<String, RecordType> rtMap) {
            propShare = '100';
            thisCR = cr;
            acc = cr.Entity__r;
            if(Test.isRunningTest())
                selected = true;
            else
                selected = false;
            Affiliation = cr.Role__c;
            thisLiab = new Liability__c(
                recordTypeId = rtMap.get('Liability__c').Id
            );
            thisLiabParty = new Liable_Party__c(
                recordTypeId = rtMap.get('Liable_Party__c').Id
            );
        }
    }
    
    public class violationTypeVarWrapper{
        public Integer indexCounter { get; set; }
        public Violation_Type_Variable__c vTypeVar { get; set; }
        public String varValue { get; set; }
        public boolean isUserInput { get; set; }
        public String dataType { get; set; }
        public String vtvName { get; set; }
        public violationTypeVarWrapper(Violation_Type_Variable__c vtv, Integer wIndex){
                isUserInput = false;
                indexCounter = wIndex;
                vTypeVar = vtv;
                vtvName = vtv.Name;
                dataType = vtv.Data_Type__c;
                if(vtv.Value__c == '{!Input}'){
                        isUserInput = true;
                }
                else if(vtv.Value__c != null){
                        varValue = vtv.Value__c;
                }
        }
    }

    public class ViolationTypeWrapper {
        public decimal subTotalA { get; set; }
        public decimal subTotalW { get; set; }
        public decimal subTotalIW { get; set; }
        public decimal amountPaid { get; set; }
        public decimal amountEarned { get; set; }
        public Integer indexCounter { get; set; }
        public Violation_Type__c vType { get; set; }
        public List<Violation_Type_Variable__c> vTypeVars { get; set; }
        public List<violationTypeVarWrapper> vtvWrapperList { get; set; }
        public boolean selected { get; set; }
        public decimal amount { get; set; }
        public decimal wage { get; set; }
        public decimal wageinterest { get; set; }
        public Integer varWrapperIndex;
                
        public string wageformula {
            get {
                if (vType.Wage_Assessment_Formula__c == null)
                    return null;
                return vType.Wage_Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }

        public string wageinterestformula {
            get {
                if (vType.Wage_Interest_Assessment_Formula__c == null)
                    return null;
                return vType.Wage_Interest_Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }
       
        public string formula {
            get {
                if (vType.Assessment_Formula__c == null)
                    return null;
                return vType.Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }
        
        public string amountPaidFormula {
            get {
                if (vType.Amount_Paid_Formula__c == null)
                    return null;
                return vType.Amount_Paid_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }
        
        public string amountEarnedFormula {
            get {
                if (vType.Amount_Earned_Formula__c == null)
                    return null;
                return vType.Amount_Earned_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
            }
        }
        
        public ViolationTypeWrapper(Violation_Type__c vT, Integer wIndex) {
            varWrapperIndex = 1;
            vType = vT;
            indexCounter = wIndex;
            if(!vT.Violation_Type_Variables__r.isEmpty()){
                vTypeVars = vT.Violation_Type_Variables__r;
                if(vtvWrapperList == null) vtvWrapperList = new List<violationTypeVarWrapper>();
                    for(Violation_Type_Variable__c v : vTypeVars){
                        vtvWrapperList.add(new violationTypeVarWrapper(v, varWrapperIndex++));
                    }
                }
            if(Test.isRunningTest())
                selected = true;
            else
                selected = false;
        }
    }
    
    // Employee selection code
    public boolean LegalConsultVisible { 
        get {
            if (SelectedCitation == 'Multi') {
                integer selectedNr = 0;
                for (LiabilityWrapper lw : Liabilities) {
                    if (lw.selected) {
                        selectedNr ++;
                        if (selectedNr > 1) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }
    }
    public boolean ShowEmployeeDialog { get; set; }
    public string EmployeeName { get; set; }
    public string EmployeeId { get; set; }
    public string EmployeeSearchKey { get; set; }
    
    public List<DIR_Employee__c> EmployeeSearchResults { get; set; }
    
    public void SearchEmployee() {
        system.debug(EmployeeSearchKey);
        string searchKey = '%' + EmployeeSearchKey + '%';
        EmployeeSearchResults = [SELECT Id, Name FROM DIR_Employee__c WHERE Name LIKE :searchKey AND Position__c = 'Legal' ORDER BY Name LIMIT 10];
        ShowEmployeeDialog = true;
    }
    
    public void SelectEmployee() {
        EmployeeId = ApexPages.currentPage().getParameters().get('employeeId');
        EmployeeName = ApexPages.currentPage().getParameters().get('employeeName');
        ShowEmployeeDialog = false;
        EmployeeSearchKey = null;
        EmployeeSearchResults = new List<DIR_Employee__c>();
    }
    
    public String valueString {get;set;}
    public void saveVarValues(){
        system.debug('Inside Save Var Values - valueString');
        system.debug(valueString);
        if(valueString != null && valueString.trim().length() != 0){
            List<String> strList = valueString.split('::');
            for(String s : strList){
                List<String> itemList = s.split(':');
                if(!itemList[0].Contains('TOTAL') && !itemList[0].Contains('AMT')){
                    String pString;
                    String cString;
                    for(ViolationTypeWrapper vt  : selectedTypes){
                        Integer counterLength = string.valueOf(vt.indexCounter).length();
                        pString = itemList[0].subString(0,counterLength);
                        cString = itemList[0].subString(counterLength,itemList[0].length());
                        if(vt.indexCounter == integer.valueOf(pString)){
                            for(violationTypeVarWrapper vtv : vt.vtvWrapperList){
                                if(vtv.indexCounter == integer.valueOf(cString)){
                                    vtv.varValue = (itemList[1] == null || itemList[1].trim() == '') ? '0' : itemList[1] != vtv.varValue ? itemList[1] : vtv.varValue;
                                }
                            }
                        }
                    }
                }
                else{
                    String n;
                    boolean isW = false;
                    boolean isIW = false;
                    boolean isA = false;
                    boolean isAP = false;
                    boolean isAE = false;
                    if(itemList[0].Contains('TOTALA')){
                        n = itemList[0].replace('TOTALA', '');
                        isA = true;
                    }
                    else if(itemList[0].Contains('TOTALW')){
                        n = itemList[0].replace('TOTALW', '');
                        isW = true;
                    }
                    else if(itemList[0].Contains('TOTALIW')){
                        n = itemList[0].replace('TOTALIW', '');
                        isIW = true;
                    }
                    else if(itemList[0].Contains('AMTP')){
                        n = itemList[0].replace('AMTP', '');
                        isAP = true;
                    }
                    else if(itemList[0].Contains('AMTE')){
                        n = itemList[0].replace('AMTE', '');
                        isAE = true;
                    }
                    for(ViolationTypeWrapper vt  : selectedTypes){
                        if(vt.indexCounter == integer.valueOf(n)){
                            Decimal amt;
                            try{
                                amt = Decimal.valueOf(itemList[1]);
                            }
                            catch(exception e){ //isNaN or Infinity
                                amt = 0;
                            }
                            if(isA){
                                vt.subTotalA = amt;
                            }
                            else if(isW){
                                vt.subTotalW = amt;
                            }
                            else if(isIW){
                                vt.subTotalIW = amt;
                            }
                            else if(isAP){
                                vt.amountPaid = amt;
                            }
                            else if(isAE){
                                vt.amountEarned = amt;
                            }
                        }
                    }
                }
            }
        }
    }
          
    public void emptyMethod() {
        
    }
}