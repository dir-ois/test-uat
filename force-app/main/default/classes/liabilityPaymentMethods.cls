public class liabilityPaymentMethods {
    
    public liabilityPaymentMethods(){
        
    }

    // create the applied accounting codes on the liability payment
    public void CreateAppliedAccountingCode(Set<Id> lpIds) {
        System.debug('### Entered CreateAppliedAccountingCode');

        //Key_Value_Store__c vtcwKVS = Key_Value_Store__c.getInstance('Violation Type Car Wash');
        List<Liability_Payment__c> LiabilityPayments = [SELECT Id, Payment_Applied_To__c, Payment_Amount__c,
                                                            Case_Violation__c, Case_Violation__r.Id, Case_Violation__r.Violation_Type__c,
                                                            Case_Violation__r.Case__r.Employer__r.Low_wage_Industry_Selection__c,
                                                            Case_Violation__r.Case__r.DIR_Accounting_Program__c,
                                                            Case_Payment__r.Transmittal_Unit__c
                                                        FROM Liability_Payment__c
                                                        WHERE Id IN: lpIds];
        
        Set<Id> CaseIssueIds = new Set<Id>();
        Set<Id> ViolationTypeIds = new Set<Id>();
        list<string> AccountIndustry = new list<string>();
        list<string> DLSEProgram = new list<string>();
        
        System.debug('### LiabilityPayments = '+LiabilityPayments);
        
        for(Liability_Payment__c lp: LiabilityPayments){
            if(lp.Payment_Amount__c != null && 
                    (lp.Case_Payment__r.Transmittal_Unit__c == 'CCU 32' || lp.Case_Payment__r.Transmittal_Unit__c == 'JEU' || lp.Case_Payment__r.Transmittal_Unit__c == 'RCI')){
                CaseIssueIds.add(lp.Case_Violation__r.Id);
                ViolationTypeIds.add(lp.Case_Violation__r.Violation_Type__c);
                AccountIndustry.add(lp.Case_Violation__r.Case__r.Employer__r.Low_wage_Industry_Selection__c);
                DLSEProgram.add(lp.Case_Violation__r.Case__r.DIR_Accounting_Program__c);
            }
        }
        System.debug('CaseIssueIds = '+CaseIssueIds);
        System.debug('ViolationTypeIds = '+ViolationTypeIds);
        System.debug('AccountIndustry = '+AccountIndustry);
        System.debug('DLSEProgram = '+DLSEProgram);
        // get accounting codes that apply the the violation type of each violation
        List<Applicable_Accounting_Code__c> AcACList = [SELECT Id, Violation_Type__c, Split_Percentage__c, Active__c,
                                                            Accounting_Code__c, Accounting_Code__r.Payment_Type__c, Accounting_Code__r.Fund__c
                                                        FROM Applicable_Accounting_Code__c
                                                        WHERE Active__c = true
                                                            AND Industry__c IN :AccountIndustry
                                                            AND Program__c IN :DLSEProgram
                                                            AND Violation_Type__c IN :ViolationTypeIds];
        
        System.debug('AcACList = '+AcACList);
        
        Set<String> fundCodes = new Set<String>();
        
        for(Applicable_Accounting_Code__c AcAC : AcACList){
            fundCodes.add(AcAC.Accounting_Code__r.Fund__c);
        }
        System.debug('fundCodes = '+fundCodes);
        
        List<Violation_Accounting_Code__c> VACList = [SELECT Id, Fund_Code__c, Case_Violation__c, Case_Violation__r.Id
                                                        FROM Violation_Accounting_Code__c
                                                        WHERE Fund_Code__c IN :fundCodes
                                                            AND Case_Violation__r.Id IN :CaseIssueIds];
        
        System.debug('VACList = '+VACList);

        //@TestVisible
        Map<String, List<Applicable_Accounting_Code__c>> AcACMap = new Map<String, List<Applicable_Accounting_Code__c>>();
        for(Applicable_Accounting_Code__c AcAC: AcACList) {
        
            //System.debug('************ Applicable Accounting Code ID: ' + AcAC.Id + ' ************ ');
            
            if(!AcACMap.containsKey(AcAC.Accounting_Code__r.Payment_Type__c)) {
                List<Applicable_Accounting_Code__c> newAcACList = new List<Applicable_Accounting_Code__c>();
                newAcACList.add(AcAC);
                AcACMap.put(AcAC.Accounting_Code__r.Payment_Type__c, newAcACList);

            }else{
                List<Applicable_Accounting_Code__c> existingAcACList = AcACMap.get(AcAC.Accounting_Code__r.Payment_Type__c);
                existingAcACList.add(AcAC);
                AcACMap.put(AcAC.Accounting_Code__r.Payment_Type__c, existingAcACList);
            }
        }
        
        List<Applied_Accounting_code__c> AeACsToInsert = new List<Applied_Accounting_code__c>();
        string pmtType; //Penalty or Interest
        string lastCP; //Populates AeAC.Check_Count__c field. Only 1 AeAC under a CP will have a "1" in this field, all other AeACs will have null in this field.
        Decimal firstAeACAmount = 0; //For amounts not divisible by 2
        
        for(Liability_Payment__c lp: LiabilityPayments) {
            if(lp.Payment_Applied_To__c == 'Penalties'){
                pmtType = 'Penalty';
            }
            else {
                pmtType = lp.Payment_Applied_To__c;
            }
            
            System.debug('pmtType = '+pmtType);
            System.debug('AcACMap = '+AcACMap);
            
            if(AcACMap.containsKey(pmtType)) {
                
                List<Applicable_Accounting_Code__c> AcACListByPaymentType = AcACMap.get(pmtType);
                if(AcACListByPaymentType.size() > 0){
                    for(Applicable_Accounting_Code__c AcAC: AcACListByPaymentType){
                        System.debug('AcACListByPaymentType = '+AcACListByPaymentType);
                        
                        //Only add an Applied Accounting Code to the LP if the Violation Type is a match.
                        if(AcAC.Violation_Type__c == lp.Case_Violation__r.Violation_Type__c) {
                            Applied_Accounting_Code__c newAeAC = new Applied_Accounting_Code__c();
                            newAeAC.Liability_Payment__c = lp.Id;
                            newAeAC.Accounting_Code__c = AcAC.Accounting_Code__c;
                            newAeAC.Amount__c = lp.Payment_Amount__c * AcAC.Split_Percentage__c * .01;
                            
                            
                            for(Violation_Accounting_Code__c vac : VACList){
                                if(pmtType == 'Penalty' && vac.Case_Violation__c == lp.Case_Violation__c && vac.Fund_Code__c == AcAC.Accounting_Code__r.Fund__c){
                                    newAeAC.Violation_Accounting_Code__c = vac.Id;
                                    System.debug('vac = '+vac);
                                }
                            }
                            
                            
                            //Fix computation when split percentage is 50% and amount is not divisible by 2 
                            if(AcAC.Split_Percentage__c == 50){
                                //if (firstAeACAmount == 0 && lp.Case_Violation__r.Violation_Type__c == vtcwKVS.Value__c) {
                                if(firstAeACAmount == 0){
                                    firstAeACAmount = newAeAC.Amount__c.setScale(2, RoundingMode.HALF_UP);
                                    newAeAC.Amount__c = firstAeACAmount;
                                }else{
                                    //if (firstAeACAmount != 0 && lp.Case_Violation__r.Violation_Type__c == vtcwKVS.Value__c) {
                                    if(firstAeACAmount != 0){
                                        if(lp.Payment_Amount__c < (firstAeACAmount + newAeAC.Amount__c)){
                                            newAeAC.Amount__c = lp.Payment_Amount__c - firstAeACAmount;
                                        }
                                        firstAeACAmount = 0;
                                    }
                                }
                            }
                            AeACsToInsert.add(newAeAC);
                            
                            //Need payment type on the Applied Accounting Code object for reporting penalties and interest in separate columns on the collections report.
                            newAeAC.Payment_Type__c = lp.Payment_Applied_To__c;
                            if(lp.Case_Payment__c != lastCP){
                                newAeAC.Check_Count__c = 1;
                            }
                            lastCP = lp.Case_Payment__c;
                        }
                    }
                }
            }
        }
        if(AeACsToInsert.size() > 0){
            insert AeACsToInsert;
        }
    }
    
    
    public void CaseIssueRollups(Set<Id> lpIds) {
        
        //Map of CI.Id to a map of LP.Payment_Applied_To__c (Wages, Interest, or Penalties) to Payment_Amount__c
        Map<String, Map<String, Decimal>> ciToLPMap = new Map<String, Map<String, Decimal>>();
        
        //Just the LPs from the trigger
        List<Liability_Payment__c> triggerLPList = [SELECT Id, Case_Violation__c, Payment_Applied_To__c, Payment_Amount__c, Case_Payment__c, Case_Payment__r.Voided_Item__c
                                                        FROM Liability_Payment__c
                                                        WHERE Id IN :lpIds];
        
        Set<Id> ciIds = new Set<Id>();
        for(Liability_Payment__c triggerLP : triggerLPList){
            ciIds.add(triggerLP.Case_Violation__c);
        }
        
        //The LPs from the trigger will not contain all the LPs under a CI, so we query them here
        List<DIR_Violation__c> ciList = [SELECT Id, Penalty_Payments_Received__c, Wage_Payments_Received__c, Interest_Payments_Received__c,
                                            (SELECT Id, Case_Violation__c, Case_Payment__c, Case_Payment__r.Voided_Item__c, Payment_Amount__c, Payment_Applied_To__c
                                                FROM Liability_Payments__r)
                                            FROM DIR_Violation__c
                                            WHERE Id IN: ciIds];
        
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        for(DIR_Violation__c ci : ciList){
            lpList.addAll(ci.Liability_Payments__r);
        }
        
        
        for(Liability_Payment__c lp : lpList){
            //if(lp.Case_Payment__r.Voided_Item__c != TRUE){ //Voided LPs do not roll up to the CI
                if(!ciToLPMap.containsKey(lp.Case_Violation__c)) {
                    Map<String, Decimal> newMap = new Map<String, Decimal>();
                    newMap.put('Penalties', 0.00);
                    newMap.put('Wages', 0.00);
                    newMap.put('Interest', 0.00);
                    if(lp.Payment_Amount__c != null){
                        newMap.put(lp.Payment_Applied_To__c, lp.Payment_Amount__c);
                    }
                    ciToLPMap.put(lp.Case_Violation__c, newMap);
                }else{
                    if(lp.Payment_Amount__c != null){
                        Map<String, Decimal> retrievedMap = ciToLPMap.get(lp.Case_Violation__c);
                        retrievedMap.put(lp.Payment_Applied_To__c, retrievedMap.get(lp.Payment_Applied_To__c) + lp.Payment_Amount__c);
                        ciToLPMap.put(lp.Case_Violation__c, retrievedMap);
                    }
                }
            //}
        }
        
        Boolean updateCIs = false; //if any amount is not different, don't update
        for(DIR_Violation__c ci: ciList) {
            if(ciToLPMap.containsKey(ci.Id)) {
                Map<String, Decimal> lpToAmountMap = ciToLPMap.get(ci.Id);
                if(lpToAmountMap.containsKey('Penalties') && ci.Penalty_Payments_Received__c != lpToAmountMap.get('Penalties')){
                    ci.Penalty_Payments_Received__c = lpToAmountMap.get('Penalties');
                    updateCIs = true;
                }
                if(lpToAmountMap.containsKey('Wages') && ci.Wage_Payments_Received__c != lpToAmountMap.get('Wages')){
                    ci.Wage_Payments_Received__c = lpToAmountMap.get('Wages');
                    updateCIs = true;
                }
                if(lpToAmountMap.containsKey('Interest') && ci.Interest_Payments_Received__c != lpToAmountMap.get('Interest')){
                    ci.Interest_Payments_Received__c = lpToAmountMap.get('Interest');
                    updateCIs = true;
                }
            }
        }
        
        if(updateCIs) {
            update ciList;
        }
    }
}