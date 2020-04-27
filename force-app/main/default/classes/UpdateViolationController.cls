public with sharing class UpdateViolationController {
    
    public DIR_Violation__c viol {get;set;}
    public Violation_Type__c vType {get;set;}
    public decimal TotalAmount {get;set;}
    public decimal TotalWages {get;set;}
    public id cId {get;set;}
    public Integer indexCounter;
    public Map<Violation_Variable__c, violationTypeVarWrapper> vTypeMap {get;set;}
    public Map<Violation_Variable__c, Violation_Type_Variable__c> varMap {get;set;}
    public List<ViolationTypeWrapper> selectedTypes {get;set;}
    public String retURL {get;set;}
    public String baseURL {get;set;}
    
    private apexPages.standardController controller;
    private static Map<String,Map<String,Schema.SObjectField>> fieldMaps=  new Map<String,Map<String,Schema.SObjectField>> ();
    
    public UpdateViolationController(){
        
    }
    
    public UpdateViolationController(apexPages.standardController pageController){
        controller = pageController;
        indexCounter = 1;
        viol = (DIR_Violation__c)controller.getRecord();
        viol = (DIR_Violation__c)selectAllByID('DIR_Violation__c', viol.Id);
        cId = viol.Case__c;
        List<Id> idList = new List<Id>();
        for(Violation_Variable__c vv : viol.Violation_Variables__r){
            idList.add(vv.Violation_Type_Variable__c);
        }
        Map<Id, Violation_Type_Variable__c> vtvMap = new Map<Id, Violation_Type_Variable__c>([Select Id, Name, Value__c, Description__c, Data_Type__c, Violation_Type__c FROM Violation_Type_Variable__c WHERE Id IN: idList]);
        varMap = new Map<Violation_Variable__c, Violation_Type_Variable__c>();
        for(Violation_Variable__c vv : viol.Violation_Variables__r){
            varMap.put(vv, vtvMap.get(vv.Violation_Type_Variable__c));
        }
        Id vTypeId;
        for(Violation_Type_Variable__c vtv : vtvMap.values()){
            if(vtv.Violation_Type__c != null){
                vTypeId = vtv.Violation_Type__c;
                break;
            }
        }
        vType = (Violation_Type__c)selectAllByID('Violation_Type__c', vTypeId);
        selectedTypes = new List<ViolationTypeWrapper>();
        selectedTypes.add(new ViolationTypeWrapper(vType, varMap, indexCounter++));
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }
    
    public pageReference cancelViolation(){
        if(viol.Status__c != 'Canceled - Invalid'){
            viol.Status__c = 'Canceled - Invalid';
            update viol;
        }
        String returnPage = controller.cancel().getUrl();
        
        return new pageReference(returnPage);
    }
    
    public pageReference saveChanges() {
        //system.debug('*******************url: '+apexPages.currentPage().getParameters().get('retURL'));
        //system.debug('******************saveretURL: '+retURL);
        saveVarValues();
        
        Map<String, List<ViolationTypeWrapper>> vTypeMap = new Map<String, List<ViolationTypeWrapper>>();
        List<Violation_Variable__c> updateList = new List<Violation_Variable__c>();
        
        for(ViolationTypeWrapper vtw : SelectedTypes){
            for(violationTypeVarWrapper vtv : vtw.vtvWrapperList){
                if(vtv.varValue != vtv.currentVal){
                    vtv.vVar.Value__c = vtv.varValue;
                    updateList.add(vtv.vVar);
                }
            }
            viol.Penalty_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Penalty_Assessment_Description__c);
            viol.Wage_Assessment_Description__c = ParseExplanation(vtw, vtw.vType.Wage_Assessment_Description__c);
            viol.Original_Penalty_Assessment_Amount__c = vtw.subTotalA;
            viol.Citation_Amount__c = vtw.subTotalA == null ? 0 : vtw.subTotalA;
            viol.Original_Wage_Assessment_Amount__c = vtw.subTotalW == null ? 0 : vtw.subTotalW;
            viol.Wages_Due__c = vtw.subTotalW == null ? 0 : vtw.subTotalW;
            viol.Amount_Paid__c = vtw.amountPaid == null ? 0 : vtw.amountPaid;
            viol.Amount_Earned__c = vtw.amountEarned == null ? 0 : vtw.amountEarned;
        }
        if(!updateList.isEmpty()){
            update updateList;
        }
        update viol;
        //pageReference returnPage = new pageReference(retURL);
        //returnPage.setRedirect(true);
        
        String returnPage = controller.cancel().getUrl();
        
        return new pageReference(returnPage);
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

    public static SObject selectAllByID(String sObjectName, ID recordID){
        
        SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> fldObjMap;
        
        fldObjMap = sObjectType.getDescribe().fields.getMap();
        
        if (fieldMaps.containsKey(sObjectName)) {
            fldObjMap = fieldMaps.get(sObjectName);
        }
        else {
            fldObjMap = sObjectType.getDescribe().fields.getMap();
            fieldMaps.put(sObjectName, fldObjMap);
        }
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String queryStr = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues){
            Schema.DescribeFieldResult fieldResult= s.getDescribe();
           
            String fieldName = fieldResult.getName();
            if (fieldResult.isAccessible()) {
                queryStr += fieldName + ',';
                
            }
           
        }
        queryStr = queryStr.subString(0, queryStr.length() - 1);
        if(sObjectName == 'DIR_Violation__c'){
            queryStr += ', (SELECT Id, Name, Case_Violation__c, Value__c, Violation_Type_Variable__c,  Violation_Type_Variable__r.Value__c, Violation_Type_Variable__r.Violation_Type__c,'
            + 'Violation_Type_Variable__r.Data_Type__c, Violation_Type_Variable__r.Violation_Type__r.Assessment_Formula__c, Violation_Type_Variable__r.Violation_Type__r.Wage_Assessment_Formula__c,'
            + 'Violation_Type_Variable__r.Violation_Type__r.Wage_Assessment_Description__c, Violation_Type_Variable__r.Violation_Type__r.Penalty_Assessment_Description__c FROM Violation_Variables__r)';
        }
        if(sObjectName == 'Violation_Type__c'){
            queryStr += ', (SELECT Id, Name, Description__c, Data_Type__c, Value__c FROM Violation_Type_Variables__r ORDER BY Name asc)';
        }
        queryStr += ' FROM '+ sObjectName + ' WHERE Id = \''+recordID+'\'';
        System.debug(queryStr);
        return Database.query(queryStr);
    }
    
    public String valueString {get;set;}
    public void saveVarValues(){
        if(valueString != null && valueString.trim().length() != 0){
            List<String> strList = valueString.split('::');
            for(String s : strList){
                List<String> itemList = s.split(':');
                if(itemList[0].Contains('retURL')){
                    retURL = itemList[1];
                }
                else if(!itemList[0].Contains('TOTAL') && !itemList[0].Contains('AMT')){
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
    
   public class violationTypeVarWrapper{
        public Integer indexCounter { get; set; }
        public Violation_Type_Variable__c vTypeVar { get; set; }
        Violation_Variable__c vVar { get; set; }
        public String varValue { get; set; }
        public String currentVal { get; set; }
        public boolean isUserInput { get; set; }
        public String dataType { get; set; }
        public String vtvName { get; set; }
        public violationTypeVarWrapper(Violation_Variable__c vv, Violation_Type_Variable__c vtv, Integer wIndex){
            isUserInput = false;
            indexCounter = wIndex;
            vTypeVar = vtv;
            vVar = vv;
            vtvName = vtv.Name;
            dataType = vtv.Data_Type__c;
            if(vtv.Value__c == '{!Input}'){
                isUserInput = true;
                if(vv.Value__c != null){
                    varValue = String.valueOf(vv.Value__c);
                    currentVal = String.valueOf(vv.Value__c);
                }
            }
            else if(vtv.Value__c != null){
                varValue = vtv.Value__c;
            }
        }
    }

    public class ViolationTypeWrapper {
        public decimal subTotalA { get; set; }
        public decimal subTotalW { get; set; }
        public decimal amountPaid { get; set; }
        public decimal amountEarned { get; set; }
        public Integer indexCounter { get; set; }
        public Violation_Type__c vType { get; set; }
        public List<Violation_Type_Variable__c> vTypeVars { get; set; }
        public List<violationTypeVarWrapper> vtvWrapperList { get; set; }
        public boolean selected { get; set; }
        public decimal amount { get; set; }
        public decimal wage { get; set; }
        public Integer varWrapperIndex;
        
        public string wageformula {
            get {
                if (vType.Wage_Assessment_Formula__c == null)
                    return null;
                return vType.Wage_Assessment_Formula__c.replace('MAX', 'Math.max').replace('MIN', 'Math.min');
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
        
        public ViolationTypeWrapper(Violation_Type__c vT, Map<Violation_Variable__c, Violation_Type_Variable__c> varMap, Integer wIndex) {
            varWrapperIndex = 0;
            vType = vT;
            indexCounter = wIndex;
            if(vtvWrapperList == null) vtvWrapperList = new List<violationTypeVarWrapper>();
            for(Violation_Variable__c vv : varMap.keySet()){
                vtvWrapperList.add(new violationTypeVarWrapper(vv, varMap.get(vv), varWrapperIndex++));
            }
        }
    }
}