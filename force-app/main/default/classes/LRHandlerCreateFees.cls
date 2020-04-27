/******************************************************************************
* @author         Sapient
* @date           December 2018
* @description    
********************************************************************************************************/
@SuppressWarnings('sf:ClassWithOnlyPrivateConstructorsShouldBeFinal')
public without sharing class LRHandlerCreateFees {
	private static LRHandlerCreateFees classInstance = null;
      public boolean stopRecursion {get; set;}
	private LRHandlerCreateFees() {
		stopRecursion = false;
	}

	public static LRHandlerCreateFees getInstance(){
		if (null == classInstance) {
			classInstance = new LRHandlerCreateFees();
		}
		return classInstance;
	}


      public void createFees(list<License_Registration__c> newList, map<id, License_Registration__c> newmap, map<id,License_Registration__c> oldMap) {
		Logger.push('CreateFees','LicenseRegistrationAllHandler');
		Logger.debug('##### Entering Createfees');
		Logger.debug('##### Entering Createfees');
		if(stopRecursion == null || !stopRecursion)
            {
                  
                  Set<Id> LicenseRegistrationIds = new Set<Id>();
                  for(License_Registration__c l: newList) {
                        License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
                        //if(oldLicenseRegistration.Fee_Calculation_Ready__c == false && l.Fee_Calculation_Ready__c == true)
                        if((oldLicenseRegistration.Status__c != 'Fee Calculation Ready' && l.Status__c == 'Fee Calculation Ready') 
                                    || (oldLicenseRegistration.Ready_to_Submit__c != 'Yes' 
                                          && l.Ready_To_Submit__c == 'Yes' && l.Submission_Type__c == 'Paper'))
                        LicenseRegistrationIds.add(l.Id);
                  }
                  
                  Logger.debug('######## There are ' + LicenseRegistrationIds.size() + ' Registrations that need fees created');
                  if(LicenseRegistrationIds.size() > 0) {
                        
                        //BEGIN Deactivate existing Fees and Fee Summaries  CBINOVI 1-29-2018     
                        List<Fee__c> existingFees = [SELECT Id, Registration__c, Fee_Schedule__c, Active__c FROM Fee__c WHERE Registration__c IN :LicenseRegistrationIds 
                        AND Active__c = true];  //CBINOVI Added Active = false         
                        for(Fee__c existingFeeObj: existingFees){
                              existingFeeObj.Active__c = false; 
                        }
                        update existingFees;
                        
                        List<Fee_Summary__c> existingFeedSummary = [SELECT Id, Name, Status__c FROM Fee_Summary__c WHERE Registration__c IN :LicenseRegistrationIds AND Active__c = true];
                        for(Fee_Summary__c feeSummaryObj: existingFeedSummary){
                              feeSummaryObj.Active__c = false; 
                        }           
                        update existingFeedSummary;
                        
                        //END Deactivate existing Fees and Fee Summaries  CBINOVI 1-29-2018

                        existingFees = [SELECT Id, Registration__c, Fee_Schedule__c, Active__c FROM Fee__c WHERE Registration__c IN :LicenseRegistrationIds AND Active__c = true];  
                        //CBINOVI Added Active = true
                        Map<String, Fee__c> existingFeeMap = new Map<String, Fee__c>();
                        Set<Id> RegistrationSet = new Set<Id>();
                        for(Fee__c fee: existingFees) {
                              if(!existingFeeMap.containsKey(fee.Registration__c + '/' + fee.Fee_Schedule__c)) {
                                    existingFeeMap.put(fee.Registration__c + '/' + fee.Fee_Schedule__c, fee);
                              }
                              if(!RegistrationSet.contains(fee.Registration__c))
                              RegistrationSet.add(fee.Registration__c);
                        }
                        
                        // for each License_Registration__c record created populate the map
                        // RecordTypeNames - map to keep License_Registration__c RecordType.Name (key) and Id (value)
                        List<License_Registration__c> allLR = [SELECT Id, RecordTypeId, RecordType.DeveloperName, No_of_Locations__c, Fee_Calculation_Ready__c, 
                        RecordType.Name FROM License_Registration__c WHERE Id IN:LicenseRegistrationIds];
                        Map<String, List<License_Registration__c>> RecordTypeNames = new Map<String, List<License_Registration__c>>();
                        List<Fee_Summary__c> FeeSummariesToInsert = new List<Fee_Summary__c>();
                        for(License_Registration__c l: allLR) {
                              if(!RegistrationSet.contains(l.Id)) {
                                    if(!RecordTypeNames.containsKey(l.RecordType.Name)) {
                                          List<License_Registration__c> nList = new List<License_Registration__c>();
                                          nList.add(l);
                                          RecordTypeNames.put(l.RecordType.Name, nList);
                                    } else {
                                          List<License_Registration__c> existingList = RecordTypeNames.get(l.RecordType.Name);
                                          existingList.add(l);
                                          RecordTypeNames.put(l.RecordType.Name, existingList);
                                    }
                                    Fee_Summary__c newFeeSummary = new Fee_Summary__c();
                                    newFeeSummary.Registration__c = l.Id;
                                    newFeeSummary.Status__c = 'Not Paid';
                                    newFeeSummary.Active__c = true;     //CBINOVI 1-29-2018
                                    FeeSummariesToInsert.add(newFeeSummary);
                              }
                        }
                        
                        
                        
                        if(RecordTypeNames.size() > 0) {
                              
                              if(FeeSummariesToInsert.size() > 0)
                              insert FeeSummariesToInsert;
                              
                              List<Fee_Summary__c> allFeeSummaries = [SELECT Id, Registration__c FROM Fee_Summary__c WHERE Id IN: FeeSummariesToInsert AND Active__c = true]; 
                              //CBINOVI Added Active = true
                              Map<Id, Id> FeeSummariesMap = new Map<Id, Id>();
                              for(Fee_Summary__c fs: allFeeSummaries) {
                                    if(!FeeSummariesMap.containsKey(fs.Registration__c))
                                    FeeSummariesMap.put(fs.Registration__c, fs.Id);
                              }
                              
                              // Map of Fee_Schedule__c for each the record type
                              Map<String, List<Fee_Schedule__c>> FeeScheduleMap = new Map<String, List<Fee_Schedule__c>>();
                              Date todayDate = Date.today();
                              List<Fee_Schedule__c> allRegistrationFeeSchedule = [SELECT Id, RecordTypeId, RecordType.DeveloperName, RecordType.Name, 
                              Calculation_Formula__c, Description__c, Expiration_Date__c, 
                              Fee_Cap__c, Initiation_Date__c, Range_Ceiling__c, Range_Floor__c, Reference_Field__c, Registration_Type__c, Fee_Type__c
                              FROM Fee_Schedule__c 
                              WHERE Active__c = TRUE AND Registration_Type__c IN: RecordTypeNames.keySet() AND Initiation_Date__c <= :todayDate 
                              AND (Expiration_Date__c >= :todayDate OR Expiration_Date__c = Null)];

                              Set<String> FormulaFields = new Set<String>();
                              for(Fee_Schedule__c fsch: allRegistrationFeeSchedule) {
                                    String calculationFromula = fsch.Calculation_Formula__c;
                                    while(calculationFromula.contains('{')) {
                                          String fieldName = calculationFromula.substring(calculationFromula.indexOf('{') + 1, calculationFromula.indexOf('}') );
                                          if(!FormulaFields.contains(fieldName))
                                          FormulaFields.add(fieldName);
                                          calculationFromula = calculationFromula.substring(calculationFromula.indexOf('}')+ 1);
                                    }
                                    if(fsch.RecordType.DeveloperName == 'Range' && fsch.Reference_Field__c != null)
                                    FormulaFields.add(fsch.Reference_Field__c);
                              }
                              
                              
                              String queryStr = ' SELECT Id, RecordTypeId, RecordType.DeveloperName, Fee_Calculation_Ready__c, RecordType.Name, ' +
                              'Amount_Paid_Online__c, Amount_Paid_Manually__c, Amount_Due__c,Penalty_II__c,Penalty_I__c ';
                              if(FormulaFields.size() > 0)
                              for(String sfieldName: FormulaFields) {
                                    queryStr += ', ' + sfieldName + ' ';
                              }
                              queryStr += ' FROM License_Registration__c WHERE Id IN: LicenseRegistrationIds'; 
                              List<License_Registration__c> allRegistrations = Database.query(queryStr);

                              for( Fee_Schedule__c fs: allRegistrationFeeSchedule ) {
                                    if(!FeeScheduleMap.containsKey(fs.Registration_Type__c)) {
                                          List<Fee_Schedule__c> fsList = new List<Fee_Schedule__c>();
                                          fsList.add(fs);
                                          FeeScheduleMap.put(fs.Registration_Type__c, fsList);
                                    } else {
                                          List<Fee_Schedule__c> existingList = FeeScheduleMap.get(fs.Registration_Type__c);
                                          existingList.add(fs);
                                          FeeScheduleMap.put(fs.Registration_Type__c, existingList);
                                    }
                              }
                              
                              List<Fee__c> FeeToInsert = new List<Fee__c>();
                              List<License_Registration__c> LRegToUpdate = new List<License_Registration__c>();
                              
                              for(String s: RecordTypeNames.keySet()) {
                                    if(FeeScheduleMap.containsKey(s)) {
                                          List<Fee_Schedule__c> FeeSchedules = FeeScheduleMap.get(s);
                                          List<License_Registration__c> allLRegs = RecordTypeNames.get(s);
                                          
                                          for(License_Registration__c lr: allRegistrations) {
                                                Boolean hasErrors = false;
                                                Id FeeSummaryId = FeeSummariesMap.get(lr.Id);
                                                for(Fee_Schedule__c fs: FeeSchedules) {
                                                      
                                                      if(!existingFeeMap.containsKey(String.valueOf(lr.Id) + '/' + String.valueOf(fs.Id))) {
                                                            
                                                            if(fs.RecordType.Name == 'Flat Fee') {
                                                                  Logger.debug('fs.Calculation_Formula__c***'+fs.Calculation_Formula__c);
                                                                  Logger.debug('fs.Calculation_Formula__c***'+fs.Calculation_Formula__c.isNumeric());
                                                                  
                                                                  if(fs.Registration_Type__c=='Public Works' && lr.get(fs.Reference_Field__c)!='' && lr.get(fs.Reference_Field__c) == false){
                                                                      System.debug('inside if--');
                                                                      System.debug('reference field--'+fs.Reference_Field__c);
                                                                      System.debug('reference field value--'+lr.get(fs.Reference_Field__c));
                                                                      continue;
                                                                  }
                                                                  
                                                                  if((fs.Calculation_Formula__c).isNumeric() || (fs.Calculation_Formula__c).contains('.')) {
                                                                        // Create new Fee__c record
                                                                        Fee__c newFee = new Fee__c();
                                                                        newFee.Fee_Summary__c = FeeSummaryId;
                                                                        newFee.Fee_Schedule__c = fs.Id;
                                                                        newFee.Registration__c = lr.Id;
                                                                        newFee.Description__c = fs.Description__c;
                                                                        newFee.Fee_Type__c = fs.Fee_Type__c;
                                                                        newFee.Active__c = true;     //CBINOVI 1-29-2018
                                                                        newFee.Fee__c = Decimal.valueOf((fs.Calculation_Formula__c).trim());
                                                                        // add each new record to the list
                                                                        FeeToInsert.add(newFee);
                                                                  } else {
                                                                        newmap.get(lr.Id).addError('Calculation Formula should have a numeric value');
                                                                        hasErrors = true;
                                                                  }
                                                            }
                                                            String feeFormulaString = '';
                                                            if(fs.RecordType.Name == 'Per x') {
                                                                  Logger.debug('Found Per X fee schedule for this regustration');
                                                                  feeFormulaString = fs.Calculation_Formula__c;
                                                                  if(feeFormulaString.contains('*')) {
                                                                        List<String> feeFormulaList = feeFormulaString.split('\\*');
                                                                        
                                                                        Decimal totalResult = 0;
                                                                        for(String ss: feeFormulaList) {
                                                                              Logger.debug('working on FeeFormulaList: ' + ss);
                                                                              if(ss.contains('[')) {
                                                                                    ss = ss.replace('[', '');
                                                                                    ss = ss.replace(']', '');
                                                                                    if(totalResult == 0)
                                                                                    {
                                                                                          totalResult = Decimal.valueOf(ss.trim());
                                                                                          Logger.debug('in If totalResult: ' + totalResult);
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                          totalResult = totalResult * Decimal.valueOf(ss.trim());
                                                                                          Logger.debug('in Else - totalResult: ' + totalResult);
                                                                                    }
                                                                              } else {
                                                                                    ss = ss.replace('{', '');
                                                                                    ss = ss.replace('}', '');
                                                                                    if(totalResult == 0) {
                                                                                          totalResult = (Decimal)lr.get(ss);
                                                                                    } else {
                                                                                          totalResult = totalResult * (Decimal)lr.get(ss);
                                                                                          
                                                                                    }
                                                                              }
                                                                        }
                                                                        Fee__c newFee = new Fee__c();
                                                                        newFee.Fee_Summary__c = FeeSummaryId;
                                                                        newFee.Fee_Schedule__c = fs.Id;
                                                                        newFee.Registration__c = lr.Id;
                                                                        newFee.Description__c = fs.Description__c;
                                                                        newFee.Fee__c = totalResult;
                                                                        newFee.Fee_Type__c = fs.Fee_Type__c;
                                                                        newFee.Active__c = true;     //CBINOVI 1-29-2018
                                                                        // add each new record to the list
                                                                        FeeToInsert.add(newFee);
                                                                  } else {
                                                                        hasErrors = true;
                                                                  } 
                                                            } 
                                                            if(fs.RecordType.Name == 'Range') {
                                                                  Decimal RegistrationReferenceField = (Decimal)lr.get(fs.Reference_Field__c);
                                                                  if(RegistrationReferenceField <= fs.Range_Ceiling__c && RegistrationReferenceField >= fs.Range_Floor__c) {
                                                                        Fee__c newFee = new Fee__c();
                                                                        newFee.Fee_Summary__c = FeeSummaryId;
                                                                        newFee.Fee_Schedule__c = fs.Id;
                                                                        newFee.Registration__c = lr.Id;
                                                                        newFee.Description__c = fs.Description__c;
                                                                        newFee.Fee__c = Decimal.valueOf((fs.Calculation_Formula__c).trim());
                                                                        newFee.Active__c = true;     //CBINOVI 1-29-2018
                                                                        newFee.Fee_Type__c = fs.Fee_Type__c;
                                                                        // add each new record to the list
                                                                        FeeToInsert.add(newFee);
                                                                  } 
                                                            }
                                                            Logger.debug('fs.RecordType.Name***'+fs.RecordType.Name);
                                                            if(fs.RecordType.Name == 'Percent') {
                                                                  feeFormulaString = fs.Calculation_Formula__c;
                                                                  Logger.debug('feeFormulaString.contains()***'+feeFormulaString.contains('*'));
                                                                  if(feeFormulaString.contains('*')) {
                                                                        List<String> feeFormulaList = feeFormulaString.split('\\*');
                                                                        Decimal totalResult = 0;
                                                                        for(String ss: feeFormulaList) {
                                                                              if(ss.contains('[')) {
                                                                                    ss = ss.replace('[', '');
                                                                                    ss = ss.replace(']', '');
                                                                                    List<String> feePercentList = ss.split('/');
                                                                                    Logger.debug('feePercentList ****'+feePercentList );
                                                                                    Decimal percentResult = Decimal.valueOf(feePercentList[0])/Decimal.valueOf(feePercentList[1]);
                                                                                    if(totalResult == 0)
                                                                                    totalResult = percentResult;
                                                                                    else
                                                                                    totalResult = totalResult * percentResult;
                                                                              } else {
                                                                                    ss = ss.replace('{', '');
                                                                                    ss = ss.replace('}', '');
                                                                                    if(totalResult == 0) {
                                                                                          totalResult = (Decimal)lr.get(ss);
                                                                                    } else {
                                                                                          totalResult = totalResult * (Decimal)lr.get(ss);
                                                                                    }
                                                                              }
                                                                        }
                                                                        Fee__c newFee = new Fee__c();
                                                                        newFee.Fee_Summary__c = FeeSummaryId;
                                                                        newFee.Fee_Schedule__c = fs.Id;
                                                                        newFee.Registration__c = lr.Id;
                                                                        newFee.Description__c = fs.Description__c;
                                                                        newFee.Fee__c = totalResult;
                                                                        newFee.Active__c = true;     //CBINOVI 1-29-2018
                                                                        newFee.Fee_Type__c = fs.Fee_Type__c;
                                                                        // add each new record to the list
                                                                        FeeToInsert.add(newFee);
                                                                  } else {
                                                                        lr.addError('Calculation Formula format should be {!Custom_Registration_Field__c}*[30/100]');
                                                                        hasErrors = true;
                                                                  }
                                                            }
                                                      }
                                                      
                                                      
                                                }
                                                if(hasErrors == true)
                                                lr.Fee_calculation_error__c = true;
                                                else
                                                
                                                lr.Fee_calculation_error__c = false;
                                                lr.Fee_Calculation_Ready__c = false;
                                                //lr.Status__c = 'Pending Payment';
                                                LRegToUpdate.add(lr);
                                          }
                                    }
                              }
                              
                              if(FeeToInsert.size() > 0){
                                    insert FeeToInsert;
                              }
                              else{
                                    for (License_Registration__c l : LRegToUpdate){
                                          // if(l.Renewal__c == false || l.Submission_Type__c == 'Paper')
                                          l.Status__c = 'Submitted';
                                    }
                              }
                              stopRecursion = true;
                              update LRegToUpdate; 
                              stopRecursion = false;
                              // compare the amount due to amount paid and set status appropriately    
                              Logger.debug('##### Create fees: Check balance');
                              List<License_Registration__c> LRtoUpdateStatus = new list<License_Registration__c>();
                              List<License_Registration__c> LRtoCheck = new List<License_Registration__c>([SELECT Id, Amount_Due__c, 
                              Amount_Paid_Online__c, Amount_Paid_Manually__c, VIP_Date_Time_Submitted__c, Submitted__c, Status__c FROM License_Registration__c WHERE Id IN: LRegtoUpdate]);
                              For(License_Registration__c l : LRtoCheck){
                                    double AmtOnline = l.Amount_Paid_Online__c == NULL ? 0 : l.Amount_Paid_Online__c;
                                    double AmtManual = l.Amount_Paid_Manually__c == NULL ? 0 : l.Amount_Paid_Manually__c;
                                    double AmtDue = l.Amount_Due__c == NULL ? 0 : l.Amount_Due__c;
                                    double Balance = AmtDue - AmtOnline - AmtManual;                    
                                    License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
                                    Logger.debug('##### Balace: ' + Balance);
                                    Logger.debug('##### time submitted: ' + l.VIP_Date_Time_Submitted__c);
                                    Logger.debug('##### Time submitted priorvalue: ' + oldLicenseRegistration.VIP_Date_Time_Submitted__c);
                                    Logger.debug('##### l.Submitted__c: ' + l.Submitted__c);
                                    Logger.debug('##### Balace: ' + Balance);
                                    
                                    if(Balance <= 0){
                                          // check if resubmitted
                                          
                                          if(oldLicenseRegistration.VIP_Date_Time_Submitted__c <> l.VIP_Date_Time_Submitted__c || l.Submitted__c == True ){
                                                l.Status__c = 'Resubmitted';
                                                LRtoUpdateStatus.Add(l);
                                          }
                                          Else{
                                                if(l.Status__c != 'Submitted'){
                                                      l.Status__c = 'Submitted'; 
                                                      LRtoUpdateStatus.Add(l);
                                                }
                                                
                                          }
                                          
                                    }
                                    else{
                                          if(l.Status__c != 'Pending Payment'){
                                                l.Status__c = 'Pending Payment';
                                                LRtoUpdateStatus.Add(l);
                                          }
                                          
                                    }
                                    
                              }    
                              if(LRtoUpdateStatus.Size() > 0) {
                                     stopRecursion = true;
                                    update LRtoUpdateStatus;
                                     stopRecursion = false;
                              }                              
                              
                        }

                  }
            }
		Logger.pop();
	}


}