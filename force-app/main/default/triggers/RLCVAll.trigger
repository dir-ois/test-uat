/********************************************************************************************************
Name:  RLCVAll
Author:  Alex Dumitrache(Vertiba) 
Last Modified : 09.16.2014

Behavior:

1. updateRLCV : the method will fire upon changing the Employer(Account__c) lookup for a Report of Labor Code Vialotion(RLCV) record. It will search the Key Value Store custom setting
                for the allowed DIR case record types.The it will search the cases associated with the new Employer that have those record types.
                If a match is found, it will reparent the RLCV to the new DIR Case. If the case has inspections, the case status, owner and record type are updated.
                       
2. updateCase : the method will change the status and the record type for the cases that are left without any Reports of Labor Code Vialotion(RLCVs).
    
********************************************************************************************************/
trigger RLCVAll on Report_of_Labor_Code_Violation__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {  
    
    if ((trigger.isAfter) && (trigger.isUpdate)){
        updateRLCV();
        updateCaseAfterMovingRLCV();
    }
    
    if ((trigger.isAfter) && ((trigger.isUpdate) || (trigger.isInsert))) {
        updateCaseFields();
    }
    
    if ((trigger.isbefore) && (trigger.isInsert)) {
        WageReferralFieldUpdate();
        addCasePriority();
    }
    
    public void WageReferralFieldUpdate() {
        
        Set<Id> wageIds = new Set<Id>();
        for (Report_of_Labor_Code_Violation__c RLCV : Trigger.new) {
            if (RLCV.Wage_Claim__c != null) {
                wageIds.add(RLCV.Wage_Claim__c);
            }
        }
        
        Map<Id, Wage_Claim__c> wageMap = new Map<Id, Wage_Claim__c>([SELECT Union_contract_covering_your_employment__c, Employer_s_Vehicle_License_Plate__c, Date_of_Hire__c, Discharged_On_Date__c,
                                                                            Quit_On_Date__c, Were_You_An_Hourly_Employee__c, Yes_I_Was_Paid_This_Amount_Hourly__c, Were_you_paid_fixed_a_wage__c,
                                                                            Yes_I_was_Paid__c, Yes_Paid_Per__c, Were_you_paid_by_PIECE_RATE__c, How_were_your_wages_paid__c, If_yes_what_language__c,
                                                                            Total_Number_of_Employees__c FROM Wage_Claim__c WHERE Id IN :wageIds]);
        
        for (Report_of_Labor_Code_Violation__c RLCV : Trigger.new) {
            if (RLCV.Wage_Claim__c != null && wageMap.containsKey(RLCV.Wage_Claim__c)) {
                Wage_Claim__c wc = wageMap.get(RLCV.Wage_Claim__c);
                RLCV.Public_Works__c = 'No';
                RLCV.Union_Contract__c = wc.Union_contract_covering_your_employment__c;
                RLCV.Employer_s_Vehicle_License_Plate_Number__c = wc.Employer_s_Vehicle_License_Plate__c;
                RLCV.Do_Did_Work_For_the_Employer__c = 'Yes';
                RLCV.Date_of_Hire__c = wc.Date_of_Hire__c;
                RLCV.Last_Day_of_Work__c = wc.Discharged_On_Date__c == null ? wc.Quit_On_Date__c : wc.Discharged_On_Date__c;
                RLCV.Are_Employees_Paid_by_the_hour__c = wc.Were_You_An_Hourly_Employee__c;
                try {
                    RLCV.How_Much_Employees_are_Paid_per_Hour__c = Decimal.valueOf(wc.Yes_I_Was_Paid_This_Amount_Hourly__c);
                } catch (Exception ex) {}
                RLCV.Paid_Fixed_Amount_Regardless_of_Hours__c = wc.Were_you_paid_fixed_a_wage__c;
                try {
                    RLCV.Fixed_Amount_paid_to_Employees__c = Decimal.valueOf(wc.Yes_I_was_Paid__c);
                } catch (Exception ex) {}
                RLCV.Interval_for_Fixed_Amount_Payments__c = wc.Yes_Paid_Per__c;
                RLCV.Are_Employees_Paid_by_Piece_Rate__c = wc.Were_you_paid_by_PIECE_RATE__c;
                RLCV.How_are_Employees_Paid__c = wc.How_were_your_wages_paid__c;
                RLCV.What_Languages_are_Spoken_by_Employees__c = wc.If_yes_what_language__c;
                RLCV.No_of_employees_affected_other_wage__c = wc.Total_Number_of_Employees__c;
            }
        }
        
    }
        
    public void updateRLCV(){
        system.debug('*** running RLCVAll.updateRLCV');
        //class with static variable is used to make sure the trigger does not run in an infinite loop
        if (checkRecursive.runOnce()){
            //get record types and current user
            String investigationRecordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and DeveloperName = 'BOFE_Investigation'].Id;
            String intakeRecordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and DeveloperName = 'BOFE_Intake'].Id;
            String pagaRecordType = [Select Id From RecordType  Where SobjectType = 'Report_of_Labor_Code_Violation__c' and DeveloperName = 'PAGA_Notice'].Id;
            String userId = UserInfo.getUserId();
            
            //if the employer of a RLCv has changed, add the new employer and the rlcv to a set, create a map between the RLCV and the employer, use a set for the current case
            Set<Id> accountSet = new Set<Id>();
            Map<Id, Id> RLCVtoAccount = new Map<Id, Id>();
            Set<Id> rlcvSet = new Set<Id>();
            Set<Id> caseSetOld = new Set<Id>();
            for (Report_of_Labor_Code_Violation__c rlcv : trigger.new){
               if(rlcv.RecordTypeId != pagaRecordType){
                if (trigger.oldmap.get(rlcv.Id).Account__c != rlcv.Account__c){
                    accountSet.add(rlcv.Account__c);
                    RLCVToAccount.put(rlcv.Id, rlcv.Account__c);
                    rlcvSet.add(rlcv.Id);
                    caseSetOld.add(trigger.oldmap.get(rlcv.Id).DIR_Case__c);
                }
              }
            } 
            //get the cases for the new employers that match the record types from the custom setting
            List<DIR_Case__c> caseList = new List<DIR_Case__c>();
            List<DIR_Case__c> caseListOld = new List<DIR_Case__c>();
            caseList = [SELECT Id, Employer__c, RecordTypeId FROM DIR_Case__c WHERE Employer__c IN : accountSet AND (RecordTypeId =: investigationRecordType OR RecordTypeId =: intakeRecordType)];
            caseListOld = [SELECT Id, Employer__c, RecordTypeId FROM DIR_Case__c WHERE Id IN : caseSetOld AND (RecordTypeId =: investigationRecordType OR RecordTypeId =: intakeRecordType)];
            
            //create map between the current case and it's record type
            Map<Id, Id> caseOldToRecordType = new Map<Id, Id>();
            for (DIR_Case__c dc : caseListOld)
                caseOldToRecordType.put(dc.Id, dc.RecordTypeId);
            
            //add the cases to a set
            Set<Id> caseSet = new Set<Id>();
            for (DIR_Case__c dc : caseList)
                caseSet.add(dc.Id);
            
            //get inspections related to the cases  
            List<DIR_Inspection__c> inspectionList = new List<DIR_Inspection__c>();
            inspectionList = [SELECT Id, DIR_Case__c FROM DIR_Inspection__c WHERE DIR_Case__c IN : caseSet];
            
            //add the cases that have inspections associated to a set
            Set<Id> caseWithInspectionSet = new Set<Id>();
            for (DIR_Inspection__c insp : inspectionList)
                caseWithInspectionSet.add(insp.DIR_Case__c);
            
            //create a map between the employer and the cases that do not have any inspections associated   
            Map<Id, List<DIR_Case__c>> accountToCase = new Map<Id, List<DIR_Case__c>>();
            for (DIR_Case__c dc : caseList){
                if (!accountToCase.containsKey(dc.Employer__c))
                    accountToCase.put(dc.Employer__c, new List<DIR_Case__c>{dc});
                else
                    accountToCase.get(dc.Employer__c).add(dc);
            }
            
            //get RLCV list
            List<Report_of_Labor_Code_Violation__c> rlcvList = new List<Report_of_Labor_Code_Violation__c>();
            rlcvList = [SELECT Id, DIR_Case__c, Account__c FROM Report_of_Labor_Code_Violation__c WHERE Id In : rlcvSet];
            
            //reparent the RLCV
            Set<Id> errorSet = new Set<Id>();
            Set<Id> caseToUpdateSet = new Set<Id>();
            List<DIR_Case__c> newCaseList = new List<DIR_Case__c>();
            Set<Id> accountForNewCase = new Set<Id>();
            for (Report_of_Labor_Code_Violation__c rlcv : rlcvList){
                if (RLCVToAccount.containsKey(rlcv.Id)){
                    if  (accountToCase.containsKey(RLCVToAccount.get(rlcv.Id))){
                        //if there is one case that matches record types in the custom setting
                        if (accountToCase.get(RLCVToAccount.get(rlcv.Id)).size() == 1){
                            //if case does not have inspections
                            if (!caseWithInspectionSet.contains(accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).Id)){
                                //current case = intake, new case = intake or investigation
                                if ((caseOldToRecordType.containsKey(rlcv.DIR_Case__c)) && (caseOldToRecordType.get(rlcv.DIR_Case__c) == intakeRecordType))
                                    rlcv.DIR_Case__c = accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).Id;
                                //current case = investigation, new case = intake
                                if ((caseOldToRecordType.containsKey(rlcv.DIR_Case__c)) && (caseOldToRecordType.get(rlcv.DIR_Case__c) == investigationRecordType) && (accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).RecordTypeId == intakeRecordType))
                                    rlcv.DIR_Case__c = accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).Id;
                                //current case = investigation, new case = investigation
                                if ((caseOldToRecordType.containsKey(rlcv.DIR_Case__c)) && (caseOldToRecordType.get(rlcv.DIR_Case__c) == investigationRecordType) && (accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).RecordTypeId == investigationRecordType)){
                                    rlcv.DIR_Case__c = accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).Id;
                                    caseToUpdateSet.add(accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).Id);
                                }
                            }
                            else{
                                //current case = investigation, new case = investigation
                                if ((caseOldToRecordType.containsKey(rlcv.DIR_Case__c)) && (caseOldToRecordType.get(rlcv.DIR_Case__c) == investigationRecordType) && (accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).RecordTypeId == investigationRecordType))
                                    rlcv.DIR_Case__c = accountToCase.get(RLCVToAccount.get(rlcv.Id)).get(0).Id;
                            }
                        }
                        //if there are several cases that match the record types in the custom setting, error is thrown
                        else
                            errorSet.add(rlcv.Id);
                    }
                    else{
                        //if no cases exist on the new employer, create a new one
                        if (!accountForNewCase.contains(rlcv.Account__c)){
                            DIR_Case__c dc = new DIR_Case__c(RecordTypeId = intakeRecordType, Status__c = 'New', OwnerId = userId, Employer__c = rlcv.Account__c);
                            newCaseList.add(dc);
                            accountForNewCase.add(rlcv.Account__c);
                        }
                    }
                  }
            }
            
            //add error
            for (Report_of_Labor_Code_Violation__c rlcv : trigger.new){
                if (errorSet.contains(rlcv.Id))
                    rlcv.addError('There is more than one open case for this employer, please contact your Senior Deputy or a System Administrator for assistance');
            }
            
            insert newCaseList;
            
            //get the newly created cases
            Map<Id, Id> newCaseToAccount = new Map<Id, Id>();
            for (DIR_Case__c dc : newCaseList)
                newCaseToAccount.put(dc.Employer__c, dc.Id);
            
            //if a case was created for one of the updated rlcvs, assign it to that case
            for (Report_of_Labor_Code_Violation__c rlcv : rlcvList){
                if ((accountForNewCase.contains(rlcv.Account__c)) && (newCaseToAccount.containsKey(rlcv.Account__c)))
                    rlcv.DIR_Case__c = newCaseToAccount.get(rlcv.Account__c);
            }
            
            update rlcvList;
            
            //get case list
            List<DIR_Case__c> caseToUpdateList = new List<DIR_Case__c>();
            caseToUpdateList = [SELECT Id FROM DIR_Case__c WHERE Id IN : caseToUpdateSet];
            
            //update the cases that have inspections
            for (DIR_Case__c dc : caseToUpdateList){
                dc.RecordTypeId = investigationRecordType;
                dc.OwnerId = userId;
                dc.Status__c = 'Under Investigation';
            }
            
            update caseToUpdateList;
    
        }
        
    }
    
    private void addCasePriority(){
    	List<Id> caseIds = new List<Id>();
    	List<Id> accountIds = new List<Id>();
    	for(Report_of_Labor_Code_Violation__c rlcv : trigger.new){
    		if(rlcv.DIR_Case__c != null){
    			caseIds.add(rlcv.DIR_Case__c);
    			accountIds.add(rlcv.Account__c);
    		}
    	}
    	if(!caseIds.isEmpty() && !accountIds.isEmpty()){
    		Map<Id, DIR_Case__c> caseMap = new Map<Id, DIR_Case__c>([
    			SELECT Id, Case_Closed_Date__c, Status__c, RecordType.Name, Low_wage_Industry__c
    			FROM DIR_Case__c
    			WHERE Id IN: caseIds
    		]);
    		
    		Map<Id, Account> accountMap = new Map<Id, Account>([
    			SELECT Id, Name, Low_wage_Industry__c,
    				(SELECT Id, Case_Closed_Date__c, Status__c, RecordType.Name 
    				 FROM DIR_Cases__r)
    			FROM Account
    			WHERE Id IN: accountIds
    		]);
    		List<DIR_Case__c> casesToUpdate = new List<DIR_Case__c>();
    		for(Report_of_Labor_Code_Violation__c rlcv : trigger.new){
    			Integer priority = 0;
    			Account employer;
    			DIR_Case__c rlcvCase;
    			if(accountMap.containsKey(rlcv.Account__c)){
    				employer = accountMap.get(rlcv.Account__c);
    				for(DIR_Case__c dc : employer.DIR_Cases__r){
    					if((dc.Status__c == 'Under Investigation' || dc.Case_Closed_Date__c >= date.today() - 365)
    						&& dc.RecordType.Name.ContainsIgnoreCase('BOFE')){
    						priority = 1;
    					}
    				}
    			}
    			if(caseMap.containsKey(rlcv.DIR_Case__c)){
    				rlcvCase = caseMap.get(rlcv.DIR_Case__c);
    			}
    			if(priority == 0 && rlcvCase != null && employer != null){
    				if((rlcv.PAGA_Minimum_Wage__c || rlcv.PAGA_Overtime__c || rlcv.PAGA_Improper_form_incl_NSF_check__c || rlcv.PAGA_Child_Labor__c)){
    					if(('Yes'.equalsIgnoreCase(rlcvCase.Low_wage_Industry__c) || rlcv.PAGA_No_Workers_Compensation__c) 
    						&& rlcv.PAGA_Impacted_Employees__c >= 50){
    						priority = 1;
    					}
    					else if(rlcv.PAGA_Impacted_Employees__c >= 25 && rlcv.PAGA_Impacted_Employees__c <= 49){
    						priority = 2;
    					}
    				}
    				if(priority > 0 && rlcvCase != null){
	    				rlcvCase.PAGA_Priority__c = priority;
	    				casesToUpdate.add(rlcvCase);
	    				continue;
	    			}
    				else if(rlcv.PAGA_No_Workers_Compensation__c && rlcv.PAGA_Impacted_Employees__c >= 50){
    					priority = 3;
    				}
    				else  if((rlcv.PAGA_Meal_and_Rest_Breaks__c && 'Yes'.equalsIgnoreCase(rlcvCase.Low_wage_Industry__c))
    					&& rlcv.PAGA_Impacted_Employees__c >= 50){
    					priority = 4;
    				}
    				else if(rlcv.PAGA_Independent_Contractor__c && rlcv.PAGA_Impacted_Employees__c >= 50){
    					priority = 4;
    				}
    				else if(rlcv.PAGA_Improper_or_Inc_Wage_Statements__c && 'Yes'.equalsIgnoreCase(rlcvCase.Low_wage_Industry__c)){
    					if(rlcv.PAGA_Impacted_Employees__c >= 50){
    						priority = 3;
    					}
    					else if(rlcv.PAGA_Impacted_Employees__c >= 25 && rlcv.PAGA_Impacted_Employees__c <= 49){
    						priority = 5;
    					}
    				}
    				else if((rlcv.PAGA_No_Workers_Compensation__c || rlcv.PAGA_Meal_and_Rest_Breaks__c)
    					&& 'Yes'.equalsIgnoreCase(rlcvCase.Low_wage_Industry__c) && rlcv.PAGA_Impacted_Employees__c >= 25 && rlcv.PAGA_Impacted_Employees__c <= 49){
    					priority = 5;
    				}
    				else if(rlcv.PAGA_Overtime__c && 'No'.equalsIgnoreCase(rlcvCase.Low_wage_Industry__c) && rlcv.PAGA_Impacted_Employees__c >= 50){
    					priority = 6;
    				}
    				else if(rlcv.PAGA_Improper_form_incl_NSF_check__c && 'No'.equalsIgnoreCase(rlcvCase.Low_wage_Industry__c) && rlcv.PAGA_Impacted_Employees__c >= 50){
    					priority = 7;
    				}
    				else  if((rlcv.PAGA_Meal_and_Rest_Breaks__c && 'No'.equalsIgnoreCase(rlcvCase.Low_wage_Industry__c))
    					&& rlcv.PAGA_Impacted_Employees__c >= 50){
    					priority = 8;
    				}
    			}
    			system.debug('@@@priority: '+priority);
    			if(priority > 0 && rlcvCase != null){
    				rlcvCase.PAGA_Priority__c = priority;
    				casesToUpdate.add(rlcvCase);
    			}
    		}
    		system.debug('@@@casesToUpdate: '+casesToUpdate);
    		if(!casesToUpdate.isEmpty()){
    			update casesToUpdate;
    		}
    	}
    } 
    
    public void updateCaseAfterMovingRLCV(){
        system.debug('**** Running RLCVAll.updateCaseAfterMovingRLCV');
        
        String closedRecordType = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and DeveloperName = 'BOFE_Closed'].Id;
        
        //get the BOFE Open Case RT record from the Key Value Store custom setting
        List<String> recordTypeNameList = new List<String>();
        List<Key_Value_Store__c> keyValueStoreList = new List<Key_Value_Store__c>();
        keyValueStoreList = [SELECT Id, Value__c FROM Key_Value_Store__c WHERE Name = 'BOFE Open Case RT'];
        //split the values from the Value__c field and add them to a list
        if (keyValueStoreList.size() != 0)
            recordTypeNameList = keyValueStoreList.get(0).Value__c.split(',', 0);
        
        //add values from list to a set 
        Set<String> recordTypeNameSet = new Set<String>();
        for (String s : recordTypeNameList)
            recordTypeNameSet.add(s.trim());
        
        //get the record types based on the values found in the Key Value Store custom setting
        List<RecordType> recordTypeList = new List<RecordType>();
        recordTypeList = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name IN : recordTypeNameSet];
        
        //add the record types to a set
        Set<Id> recordTypeSet = new Set<Id>();
        for (RecordType rt : recordTypeList)
            recordTypeSet.add(rt.Id);
        
        //get the cases that had a RLCV reparented to another case
        Set<Id> caseSet = new Set<Id>();
        for (Report_of_Labor_Code_Violation__c rlcv : trigger.new){
            if (trigger.oldmap.get(rlcv.Id).DIR_Case__c != rlcv.DIR_Case__c)
                caseSet.add(trigger.oldmap.get(rlcv.Id).DIR_Case__c);
        }
        
        //get case list, filter by the record types from the custom setting
        List<DIR_Case__c> caseList = new List<DIR_Case__c>();
        caseList = [SELECT Id, Status__c, RecordTypeId, Worker_s_Comp_Violation__c, Minimum_Wage_Violations__c, NSF_Low_Wage__c, Child_Labor__c, Pay_stub_violation__c, Meal_Rest_Break_Violation__c,
                    Trusted_Org_Referral__c, Cash_Pay_226__c, Overtime_Violations__c, X2699_Case__c, SB_869_RLLV_Source__c, IWC_Excemption_Request__c, WCA_Referral__c FROM DIR_Case__c WHERE Id IN : caseSet AND RecordTypeId IN : recordTypeSet];
        
        //get existing RLCVs for the cases
        List<Report_of_Labor_Code_Violation__c> rlcvList = new List<Report_of_Labor_Code_Violation__c>();
        rlcvList = [SELECT Id, DIR_Case__c, No_Workers_Compensation_Insurance__c, Minimum_Wage_Violations__c, Unpaid_Overtime_Violations__c, Child_Labor_Violations__c, Pay_Stub_Violations__c,
                    Meal_Period_Violations__c, Rest_Break_Violations__c, Advocate_Name__c, Advocate__c, Violation_No_valid_work_permit_s__c, Violation_No_valid_entertainment__c, Violation_Minor_s_work_excessive__c,
                    Violation_Minor_s_work_in_hazardous__c, How_are_Employees_Paid__c, Violation_Paid_check_cash_WO_itemize__c, Itemized_wage_deduction_statement_provid__c, Violation_Itemized_deduction_statement__c,
                    Violation_30_minute_off_duty_meal_period__c, Violation_Second_30_minute_off_duty_meal__c, Violation_Meal_period_less_than_30__c, Violation_For_work_days_between_35_and_6__c,
                    Violation_For_workdays_between_6_and_10__c, Violation_For_work_days_between_10_and14__c, Violation_No_premium_pay_for_missing_mea__c, Violation_Paycheck_issued_with_ISF__c, Violation_Paid_below_minimum_wage__c,
                    Violation_Not_paid_for_all_hours_worked__c, Violation_Asked_employee_to_pay_back__c, Violation_No_split_shift_premium_pay__c, Violation_Not_Paid_OT_Over_8_hours__c,
                    Violation_Not_Paid_OT_Over_40_Hours__c, Violation_Not_paid_double_time_over_12__c, Violation_Not_paid_OT_for_working_7th__c, Source__c FROM Report_of_Labor_Code_Violation__c WHERE DIR_Case__c IN : caseSet];
        
        //save the cases that still have RLCVs associated
        Map<Id, List<Report_of_Labor_Code_Violation__c>> caseToRLCV = new Map<Id, List<Report_of_Labor_Code_Violation__c>>();
        for (Report_of_Labor_Code_Violation__c rlcv : rlcvList){
            if (!caseToRLCV.containsKey(rlcv.DIR_Case__c))
                caseToRLCV.put(rlcv.DIR_Case__c, new List<Report_of_Labor_Code_Violation__c>{rlcv});
            else
                caseToRLCV.get(rlcv.DIR_Case__c).add(rlcv);
        }
        
        //change the status, checkboxes and record type 
        for (DIR_Case__c dc : caseList){
            dc.Worker_s_Comp_Violation__c = false;
            dc.Minimum_Wage_Violations__c = false;
            dc.Overtime_Violations__c = false;
            dc.NSF_Low_Wage__c = false;
            dc.Child_Labor__c = false;
            dc.Pay_stub_violation__c = false;
            dc.Meal_Rest_Break_Violation__c = false;
           
            //if the old case does not have any RLCVs left
            if (!caseToRLCV.containsKey(dc.Id)){
                dc.Status__c = 'No Citations or Other Issues';
                dc.RecordTypeId = closedRecordType;
            }
            //if RLCVs still exist on the old case
            else{
                //loop through the RLCVs
                for (Report_of_Labor_Code_Violation__c rlcv : caseToRLCV.get(dc.Id)){
                    if (rlcv.No_Workers_Compensation_Insurance__c == true)
                        dc.Worker_s_Comp_Violation__c = true;
                    if ((rlcv.Violation_No_valid_work_permit_s__c == true) || (rlcv.Violation_No_valid_entertainment__c == true) || (rlcv.Violation_Minor_s_work_excessive__c == true) || (rlcv.Violation_Minor_s_work_in_hazardous__c == true))
                        dc.Child_Labor__c = true;
                    if ((rlcv.How_are_Employees_Paid__c == 'Cash') || (rlcv.How_are_Employees_Paid__c == 'Both Check & Cash'))
                        dc.Cash_Pay_226__c = true;
                    if ((rlcv.Violation_Paid_check_cash_WO_itemize__c == true) || (rlcv.Itemized_wage_deduction_statement_provid__c == true) || (rlcv.Violation_Itemized_deduction_statement__c == true))
                        dc.Pay_stub_violation__c = true;
                    if ((rlcv.Violation_30_minute_off_duty_meal_period__c == true) || (rlcv.Violation_Second_30_minute_off_duty_meal__c == true) || (rlcv.Violation_Meal_period_less_than_30__c == true) ||
                       (rlcv.Violation_For_work_days_between_35_and_6__c == true) || (rlcv.Violation_For_workdays_between_6_and_10__c == true) || (rlcv.Violation_For_work_days_between_10_and14__c == true) ||
                       (rlcv.Violation_No_premium_pay_for_missing_mea__c == true))
                       dc.Meal_Rest_Break_Violation__c = true;
                    if (rlcv.Violation_Paycheck_issued_with_ISF__c == true)
                        dc.NSF_Low_Wage__c = true;
                    if ((rlcv.Violation_Paid_below_minimum_wage__c == true) || (rlcv.Violation_Not_paid_for_all_hours_worked__c == true) || (rlcv.Violation_Paycheck_issued_with_ISF__c == true) || (rlcv.Violation_Asked_employee_to_pay_back__c == true) ||
                       (rlcv.Violation_No_split_shift_premium_pay__c == true))
                        dc.Minimum_Wage_Violations__c = true;
                    if ((rlcv.Violation_Not_Paid_OT_Over_8_hours__c == true) || (rlcv.Violation_Not_Paid_OT_Over_40_Hours__c == true) || (rlcv.Violation_Not_paid_double_time_over_12__c == true) || (rlcv.Violation_Not_paid_OT_for_working_7th__c == true))
                        dc.Overtime_Violations__c = true;
                    if ((rlcv.Advocate_Name__c != null) || (rlcv.Advocate__c != null))
                        dc.Trusted_Org_Referral__c = true;
                    if (rlcv.Source__c == 'LC 2699')
                        dc.X2699_Case__c = true;
                    if (rlcv.Source__c == 'SB 869')
                        dc.SB_869_RLLV_Source__c = true;
                    if (rlcv.Source__c == 'IWC Exemption Request')
                        dc.IWC_Excemption_Request__c = true;
                    if (rlcv.Source__c == 'WCA')
                        dc.WCA_Referral__c = true;
                }
            }
        }
        
        update caseList;
        
    }
    
    public void updateCaseFields(){
        system.debug('**** Running RLCVAll.UpdateCaseFields');
        //get the BOFE Open Case RT record from the Key Value Store custom setting
        List<String> recordTypeNameList = new List<String>();
        List<Key_Value_Store__c> keyValueStoreList = new List<Key_Value_Store__c>();
        keyValueStoreList = [SELECT Id, Value__c FROM Key_Value_Store__c WHERE Name = 'BOFE Open Case RT'];
        system.debug('****** KV Store RT list:::: ' + keyValueStoreList);
        //split the values from the Value__c field and add them to a list
        if (keyValueStoreList.size() != 0)
            recordTypeNameList = keyValueStoreList.get(0).Value__c.split(',', 0);
        
        //add values from list to a set 
        Set<String> recordTypeNameSet = new Set<String>();
        for (String s : recordTypeNameList)
            recordTypeNameSet.add(s.trim());
        
        //get the record types based on the values found in the Key Value Store custom setting
        List<RecordType> recordTypeList = new List<RecordType>();
        recordTypeList = [Select Id From RecordType  Where SobjectType = 'DIR_Case__c' and Name IN : recordTypeNameSet];
        system.debug('*** RecordTypeList:::: ' + recordTypeList);
        
        //add the record types to a set
        Set<Id> recordTypeSet = new Set<Id>();
        for (RecordType rt : recordTypeList)
            recordTypeSet.add(rt.Id);
        
        //create a set with the case for updated or inserted RLCVs and a map between the case and RLCV
        Set<Id> caseSet = new Set<Id>();
        Map<Id, Report_of_Labor_Code_Violation__c> caseToRLCV = new Map<Id, Report_of_Labor_Code_Violation__c>();
        for (Report_of_Labor_Code_Violation__c rlcv : trigger.new){
            caseSet.add(rlcv.DIR_Case__c);
            caseToRlcv.put(rlcv.DIR_Case__c, rlcv);
        }
        system.debug('***** caseToRLCV map::: ' + caseToRLCV);
        
        //get the open case list
        List<DIR_Case__c> caseList = new List<DIR_Case__c>();
        caseList = [SELECT Id, Worker_s_Comp_Violation__c, Minimum_Wage_Violations__c, NSF_Low_Wage__c, Child_Labor__c, Pay_stub_violation__c, Meal_Rest_Break_Violation__c,
                    Trusted_Org_Referral__c, Cash_Pay_226__c, Overtime_Violations__c, X2699_Case__c, SB_869_RLLV_Source__c, IWC_Excemption_Request__c, WCA_Referral__c FROM DIR_Case__c WHERE Id IN : caseSet ];//AND RecordTypeId IN : recordTypeSet];
        
        //update the fields
        for (DIR_Case__c dc : caseList){
            if (caseToRLCV.get(dc.Id).No_Workers_Compensation_Insurance__c == true)
                dc.Worker_s_Comp_Violation__c = true;
            if ((caseToRLCV.get(dc.Id).Violation_No_valid_work_permit_s__c == true) || (caseToRLCV.get(dc.Id).Violation_No_valid_entertainment__c == true) || (caseToRLCV.get(dc.Id).Violation_Minor_s_work_excessive__c) || 
               (caseToRLCV.get(dc.Id).Violation_Minor_s_work_in_hazardous__c == true))
                dc.Child_Labor__c = true;
            if ((caseToRLCV.get(dc.Id).How_are_Employees_Paid__c == 'Cash') || (caseToRLCV.get(dc.Id).How_are_Employees_Paid__c == 'Both Check & Cash'))
                dc.Cash_Pay_226__c = true;
            if ((caseToRLCV.get(dc.Id).Violation_Paid_check_cash_WO_itemize__c == true) || (caseToRLCV.get(dc.Id).Itemized_wage_deduction_statement_provid__c == true) || (caseToRLCV.get(dc.Id).Violation_Itemized_deduction_statement__c == true))
                dc.Pay_stub_violation__c = true;
            if ((caseToRLCV.get(dc.Id).Violation_30_minute_off_duty_meal_period__c == true) || (caseToRLCV.get(dc.Id).Violation_Second_30_minute_off_duty_meal__c == true) || (caseToRLCV.get(dc.Id).Violation_Meal_period_less_than_30__c == true) ||
               (caseToRLCV.get(dc.Id).Violation_For_work_days_between_35_and_6__c == true) || (caseToRLCV.get(dc.Id).Violation_For_workdays_between_6_and_10__c == true) || (caseToRLCV.get(dc.Id).Violation_For_work_days_between_10_and14__c == true) ||
               (caseToRLCV.get(dc.Id).Violation_No_premium_pay_for_missing_mea__c == true))
                dc.Meal_Rest_Break_Violation__c = true;
            if (caseToRLCV.get(dc.Id).Violation_Paycheck_issued_with_ISF__c == true)
                dc.NSF_Low_Wage__c = true;
            if ((caseToRLCV.get(dc.Id).Violation_Paid_below_minimum_wage__c == true) || (caseToRLCV.get(dc.Id).Violation_Not_paid_for_all_hours_worked__c == true) || (caseToRLCV.get(dc.Id).Violation_Paycheck_issued_with_ISF__c == true) || 
               (caseToRLCV.get(dc.Id).Violation_Asked_employee_to_pay_back__c == true) || (caseToRLCV.get(dc.Id).Violation_No_split_shift_premium_pay__c == true))
                dc.Minimum_Wage_Violations__c = true;
            if ((caseToRLCV.get(dc.Id).Violation_Not_Paid_OT_Over_8_hours__c == true) || (caseToRLCV.get(dc.Id).Violation_Not_Paid_OT_Over_40_Hours__c == true) || (caseToRLCV.get(dc.Id).Violation_Not_paid_double_time_over_12__c == true) || 
               (caseToRLCV.get(dc.Id).Violation_Not_paid_OT_for_working_7th__c == true))
                dc.Overtime_Violations__c = true;
            if ((caseToRLCV.get(dc.Id).Advocate_Name__c != null) || (caseToRLCV.get(dc.Id).Advocate__c != null))
                dc.Trusted_Org_Referral__c = true;
            if (caseToRLCV.get(dc.Id).Source__c == 'LC 2699')
                dc.X2699_Case__c = true;
            if (caseToRLCV.get(dc.Id).Source__c == 'SB 869')
                dc.SB_869_RLLV_Source__c = true;
            if (caseToRLCV.get(dc.Id).Source__c == 'IWC Exemption Request')
                dc.IWC_Excemption_Request__c = true;
            if (caseToRLCV.get(dc.Id).Source__c == 'WCA'){
                dc.WCA_Referral__c = true;
                dc.case_source__c ='WCA';
            }
                
        }
        system.debug('**** caseList:::: ' + caseList);
        
        update caseList;
        
    }

}