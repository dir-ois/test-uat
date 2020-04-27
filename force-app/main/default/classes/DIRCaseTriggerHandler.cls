public class DIRCaseTriggerHandler {
    
    public static boolean stopAffiliationCreation = false;
    public static boolean preventDuplicateHistoryCreations = true;
    
    // ldavala 06.20.2018 - added newMapIn parameter
    public static void triggerHandler(List<DIR_Case__c> newListIn, Map<Id, DIR_Case__c> oldMapIn, Map<Id, DIR_Case__c> newMapIn, Boolean isUpdate, Boolean isInsert, Boolean isBefore, Boolean isAfter){
        if(isInsert){
            if(isBefore){
                updateCase(newListIn);
                assignOffice(newListIn, null);
            }
            if(isAfter){
                createCaseRole(newListIn);
               // ldavala changes 06.20.2018
               // remove
                //createLinkedCases(newListIn);
               //add
               //createLinkedCasesFuture(new List<Id>(newMapIn.keySet()));
               //createLinkedCasesFuture(JSON.serialize(newListIn));
               // end ldavala changes 
                if(DIRCaseTriggerHandler.preventDuplicateHistoryCreations){
                    
                    createAssignmentHistory(newListIn,null);
                    DIRCaseTriggerHandler.preventDuplicateHistoryCreations = false;
                }
                
            }
        }
        if(isUpdate){
            // ldavala - added logic here to use a field set to determine a collection of fields that if changed  will not fire the "Update" trigger to reduce additional processing that does not
            // need to occur for Declare Rollups.
            Set<String> fieldsToMonitor = new Set<String>();
            //dynamically get the fields from the field set and then use the same for comparison in the trigger. 
            
            SObjectType sType = Schema.getGlobalDescribe().get('DIR_Case__c');
            for(Schema.FieldSetMember fields :sType.getDescribe().fieldSets.getMap().get('IgnoreChangesInTrigger').getFields()){
                fieldsToMonitor.add(fields.getFieldPath());
            }
            
            for(DIR_Case__c dc: newListIn) {
                
                Set<String> changedFieldSet = new Set<String>();
                for(string s: fieldsToMonitor){ 
                    if(dc.get(s) !=  oldMapIn.get(dc.Id).get(s)){
                        changedFieldSet.add(s);
                    }
                }
                if(changedFieldSet.isEmpty()){
                    if(isBefore){
                        AddErrorsToCase(newListIn, oldMapIn);
                        assignOffice(newListIn, oldMapIn);
                    }
                    if(isAfter){
                        updateLaborCodeViolations(newListIn, oldMapIn);
                        updateRLLV(newListIn, oldMapIn);
                        //updateFieldHistory(newListIn, oldMapIn);
                        //updateLinkedCases(newListIn, oldMapIn);
                        
                        if(DIRCaseTriggerHandler.preventDuplicateHistoryCreations){
                            createAssignmentHistory(newListIn,oldMapIn);
                            DIRCaseTriggerHandler.preventDuplicateHistoryCreations = false;
                        }
                        
                        List<DIR_Case__c> caseRolestoInsert = new List<DIR_Case__c>();
                        for(DIR_Case__c c : newListIn){
                            if(c.Employer__c != null && c.Employer__c != oldMapIn.get(c.id).Employer__c){
                                caseRolestoInsert.add(c);
                            }
                        }
                        if(GlobalFlagClass.preventDuplicateCaseRoles && caseRolestoInsert.size() > 0){
                            GlobalFlagClass.preventDuplicateCaseRoles = false;
                            createCaseRole(caseRolestoInsert);
                        }
                    }
                }
            }
        }
    }
    public static void createCaseRole(List<DIR_Case__c> newList) {
        List<DIR_Case__c> filteredList = new List<DIR_Case__c>();
        for(DIR_Case__c c : newList){
            if(!c.CreatedFromFA__c){
                filteredList.add(c);
            }
        }
        if(filteredList.isEmpty()){
            return;
        }
        List<Case_Role__c> roles = new List<Case_Role__c>();
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        //List<RecordType> crRTList = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case_Role__c'];
        Map<Id, RecordType> caseRTMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE sObjectType = 'DIR_Case__c']);
        for(RecordType r : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case_Role__c']){
            rtMap.put(r.Name, r);
        }
        
        for (DIR_Case__c cs : filteredList) {
            if (cs.Employer__c != null) {
                Case_Role__c cr = new Case_Role__c();
                cr.Case__c = cs.Id;
                cr.Entity__c = cs.Employer__c;
                cr.Role__c = 'Case employer';
                cr.IsPersonAccount__c = cs.Employer__r.IsPersonAccount == true ? true : false;
                String caseRTName = caseRTMap.get(cs.RecordTypeId).Name;
                if(caseRTName.contains('PAGA')){
                    return;
                }
                if(caseRTName.contains('BOFE')){
                    cr.RecordTypeId = rtMap.get('BOFE').Id;
                }
                else if(caseRTName.contains('WCA')){
                    cr.RecordTypeId = rtMap.get('WCA').Id;
                }
                else if(caseRTName.contains('Garment')){
                    cr.RecordTypeId = rtMap.get('Garment').Id;
                }
                if( caseRTName.contains('WCA') || caseRTName.contains('Garment')) {
                    cr.Role__c = 'Defendant';
                }
                roles.add(cr);
            }
        }
        
        stopAffiliationCreation = true;
        insert roles;
        stopAffiliationCreation = false;
    }
    
    public static void assignOffice(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        List<Record_Type_Mapping__c> rtMapping = Record_Type_Mapping__c.getall().values();
        List<DIR_Case__c> updateList = new List<DIR_Case__c>();
        for(DIR_Case__c c : newList){
            // Start with the work location first
            if(oldmap == null && c.Work_Location__c != null && c.Imported_From__c ==NULL){
                updateList.add(c);
            }
            else if (oldMap != NULL && c.Work_Location__c != null && c.Work_Location__c != oldmap.get(c.id).Work_Location__c && c.Imported_From__c == NULL){
                updateList.add(c);
            }
            else if(oldMap == null && c.Employer__c != null && c.Imported_From__c == NULL){
                updateList.add(c);
            }
            else if(oldMap != null && c.Employer__c != oldMap.get(c.Id).Employer__c && c.Imported_From__c == NULL){
                updateList.add(c);
            }
        }
        if(!updateList.isEmpty()){
            Record_Type_Mapping__c thisMapping;
            List<Office__c> officeList = [SELECT Id, Name, RecordType.DeveloperName, Address_1__c, Address_2__c, City__c, County__c, Fax__c, Office_Location__c, Phone__c, State__c, Zip_Code__c,
                                            (SELECT Id, Office__c, Zip_Code__c, Zip_Code__r.Name,County__c FROM Office_Zip_Code_Maps__r)
                                         FROM Office__c];
            if(officeList != null){
                Map<Office__c, List<Office_Zip_Code_Map__c>> zipMap = new Map<Office__c, List<Office_Zip_Code_Map__c>>();
                for(Office__c o : officeList){
                    if(!o.Office_Zip_Code_Maps__r.isEmpty()){
                        zipMap.put(o, o.Office_Zip_Code_Maps__r);
                    }
                }
                List<Id> acctIds = new List<Id>();
                List<Id> locIds = new List<Id>();
                for(DIR_Case__c c : updateList){
                    locIds.add(c.Work_Location__c);
                    acctIds.add(c.Employer__c);
                }
                Map<Id, Address__c> locMap = new Map<Id, Address__c>([SELECT Id, Zip_Code__c, Name FROM Address__c WHERE Id IN: locIds]);
                MAP<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, ShippingPostalCode, Name FROM Account WHERE Id IN: acctIds]);
                Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'DIR_Case__c']);           
                for(DIR_Case__c c : updateList){
                    for(Record_Type_Mapping__c r : rtMapping){
                        if(r.Case_Rec_Type__c == rtMap.get(c.RecordTypeId).DeveloperName){
                            thisMapping = r;
                            break;
                        }
                    }
                    if(thisMapping != null && c.recordtypeid!=Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId()){
                        for(Office__c o : zipMap.keySet()){
                            if(o.RecordType.DeveloperName == thisMapping.Office_Rec_Type__c){
                                String locId;
                                String acctId;
                                String county;
                                for(Office_Zip_Code_Map__c z : zipMap.get(o)){
                                    if(locMap != null && c.Work_Location__c != null && z.Zip_Code__r.Name == locMap.get(c.Work_Location__c).Zip_Code__c){
                                        locId = o.Id;
                                        county = z.County__c;
                                    }
                                    else if(z.Zip_Code__r.Name == accountMap.get(c.Employer__c).ShippingPostalCode){
                                        acctId = o.Id;
                                        county = z.County__c;
                                    }
                                }
                                if(locId != null){
                                    c.Office__c = locId;
                                    c.County__c = county;
                                }
                                else if(acctId != null){
                                    c.Office__c = acctId;
                                    c.County__c = county;
                                }
                                
                                system.debug('office is populated here '+c.county__c);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void updateRLLV(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        // get all DIR cases
        Id caseRecordType1Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        Id caseRecordType2Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();
        
        set<id> caseSet = new set<id>();
        //set<id>accountSet = new Set<id>();
        for (DIR_Case__c c : newList){
            if (((c.RecordTypeId == caseRecordType1Id) || (c.RecordTypeId == caseRecordType2Id)) && (c.Case_accepted__c == true) && (oldMap.get(c.Id).Case_accepted__c == false))
                caseSet.add(c.ID);
        }
        system.debug('caseSet: ' + caseSet);
        
        
        // get Cases that have been accepted
        //list<DIR_Case__c> caseList = [SELECT ID, Case_accepted__c FROM DIR_Case__c Where ID in :caseSet and Case_accepted__c = True ];
        //system.debug('caseList: ' + caseList);
        //Set<Id> acceptedCases = new Set<Id>();
        //for (DIR_Case__c dc  : caseList)
        //  acceptedCases.add(dc.Id);
        // Get RLLVs that belong to the accepted cases
        if(caseSet.size() > 0){
            list<Report_Of_Labor_Code_Violation__c> acceptedList = [SELECT ID, Case_accepted__c FROM Report_Of_Labor_Code_Violation__c Where DIR_Case__c in : caseSet];
            if(acceptedList.size() > 0){
                for(Report_Of_Labor_Code_Violation__c RLCV : acceptedList){
                    RLCV.Case_Accepted__c = true;
                }
                update acceptedList;
            }
        }
        
    }
    
    public static void updateCase(List<DIR_Case__c> newList){
        // updates case fields when a new case is created
        // caseRecortType1 and 2 define that these tasks only take place for BOFE cases
        Id caseRecordType1Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
        Id caseRecordType2Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();
        Id caseRecordType3Id = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Inspection Request').getRecordTypeId();
        Set<Id> accountSet = new Set<Id>();
        for (DIR_Case__c c : newList){
            if ((c.RecordTypeId == caseRecordType1Id) || (c.RecordTypeId == caseRecordType2Id) || (c.RecordTypeId == caseRecordType3Id)) 
                accountSet.add(c.Employer__c);
        }
        
        Map<Id, Account> accountList = new Map<Id, Account>([SELECT Id, ShippingPostalCode FROM Account WHERE Id IN : accountSet]);
        Set<String> postalCodes = new Set<String>();
        for (Account account : accountList.values())
            postalCodes.add(account.ShippingPostalCode);
        
        List<Office_Zip_Code_Map__c> junctions = [SELECT Zip_Code__r.Name, Office__c FROM Office_Zip_Code_Map__c WHERE Zip_Code__r.Name IN :postalCodes];
        Map<String, String> junctionMap = new Map<String, String>();
        for (Office_Zip_Code_Map__c junction : junctions) {
            junctionMap.put(junction.Zip_Code__r.Name, junction.Office__c);
        }
        //String RICRecTypeId=Schema.getGlobalDescribe().get('DIR_Case__c').getDescribe().getRecordTypeInfosByName().get('RIC').getRecordTypeId();
        for (DIR_Case__c c : newList) {
            if (accountList.containsKey(c.Employer__c) && junctionMap.containsKey(accountList.get(c.Employer__c).ShippingPostalCode)) {
                if(c.Office__c == null){
                    // only populate the office if the office is not set manually
                    c.Office__c = junctionMap.get(accountList.get(c.Employer__c).ShippingPostalCode);
                }
            }
        }

    }

    //method that handles the re-allocation of RLCVs in case the Employer on a case changes
    public static void updateLaborCodeViolations(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        
        //class with static variable is used to make sure the trigger does not run in an infinite loop
        if (checkRecursive.runOnce2()){
            
            //get record types
            String intakeRecordType = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
            String investigationRecordType = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();
            String closedRecordType = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Closed').getRecordTypeId();
            
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
            
            //create sets of Ids and Employers for the updated cases
            Set<Id> accountSet = new Set<Id>(); 
            Set<Id> caseSet = new Set<Id>();
            for (DIR_Case__c dc : newList){
                if(!test.isRunningTest() && GlobalFlagClass.preventBOFEEmployerChange && oldMap.get(dc.Id).Employer__c != dc.Employer__c && recordTypeSet.contains(dc.RecordTypeId)){
                    dc.addError('You cannot change Employer for BOFE cases.');
                }else if ((oldMap.get(dc.Id).Employer__c != dc.Employer__c) &&(dc.Employer__c != null)){
                    accountSet.add(dc.Employer__c);
                    caseSet.add(dc.Id);
                }
            }
            
            //put the updated cases in a list
            List<DIR_Case__c> caseList = new List<DIR_Case__c>();
            caseList = [SELECT Id, Related_Case__c, Status__c, Employer__c, RecordTypeId FROM DIR_Case__c WHERE Id IN : caseSet];
            
            //get a list of all cases: the updated ones and the ones found on the new employer
            List<DIR_Case__c> allCaseList = new List<DIR_Case__c>();
            allCaseList = [SELECT Id, Employer__c, RecordTypeId, Status__c, Related_Case__c FROM DIR_Case__c WHERE Employer__c IN : accountSet AND RecordTypeId IN :recordTypeSet];
            
            //create a map between the new employer and the existing cases
            Map<Id, List<DIR_Case__c>> accountToCase = new Map<Id, List<DIR_Case__c>>();
            Set<Id> foundCases = new Set<Id>();
            system.debug('allcases:' + allCaseList);
            system.debug('caseset:' + caseset);
            for (DIR_Case__c dc : allCaseList){
                if (!caseSet.contains(dc.Id)){
                    if (!accountToCase.containsKey(dc.Employer__c))
                        accountToCase.put(dc.Employer__c, new List<DIR_Case__c>{dc});
                    else
                        accountToCase.get(dc.Employer__c).add(dc);
                    foundCases.add(dc.Id);
                }
            }
            
            //get list of inspections for the existing cases
            List<DIR_Inspection__c> inspectionList = new List<DIR_Inspection__c>();
            inspectionList = [SELECT Id, DIR_Case__c FROM DIR_Inspection__c WHERE DIR_Case__c IN : foundCases];
            
            //get list of inspections for the updated cases
            List<DIR_Inspection__c> inspectionListForUpdatedCases = new List<DIR_Inspection__c>();
            inspectionListForUpdatedCases = [SELECT Id, DIR_Case__c FROM DIR_Inspection__c WHERE DIR_Case__c IN : caseSet];
            
            //if the existing cases have inspections, add them to a set
            Set<Id> caseWithInspections = new Set<Id>();
            for (DIR_Inspection__c insp : inspectionList)
                caseWithInspections.add(insp.DIR_Case__c);
            
            //if the updated cases have inspections, add them to a set  
            Set<Id> updatedCaseWithInspections = new Set<Id>();
            for (DIR_Inspection__c insp : inspectionListForUpdatedCases)
                updatedCaseWithInspections.add(insp.DIR_Case__c);
            
            //get list of RLCVs for both updated and existing cases
            List<Report_of_Labor_Code_Violation__c> rlcvList = new List<Report_of_Labor_Code_Violation__c>();
            rlcvList = [SELECT Id, DIR_Case__c, Account__c FROM Report_of_Labor_Code_Violation__c WHERE DIR_Case__c IN : caseSet OR DIR_Case__c IN : foundCases];
            
            //create two maps between the case and a list of the associated RLCVs, for both updated and existing cases
            Map<Id, List<Report_of_Labor_Code_Violation__c>> caseToRLCV = new Map<Id, List<Report_of_Labor_Code_Violation__c>>();
            Map<Id, List<Report_of_Labor_Code_Violation__c>> foundCaseToRLCV = new Map<Id, List<Report_of_Labor_Code_Violation__c>>();
            for (Report_of_Labor_Code_Violation__c rlcv : rlcvList){
                //create map for the updated cases
                if (caseSet.contains(rlcv.DIR_Case__c)){
                    if (!caseToRLCV.containsKey(rlcv.DIR_Case__c))
                        caseToRLCV.put(rlcv.DIR_Case__c, new List<Report_of_Labor_Code_Violation__c>{rlcv});
                    else
                        caseToRLCV.get(rlcv.DIR_Case__c).add(rlcv);
                }
                //create map for existing cases
                if (foundCases.contains(rlcv.DIR_Case__c)){
                    if (!foundCaseToRLCV.containsKey(rlcv.DIR_Case__c))
                        foundCaseToRLCV.put(rlcv.DIR_Case__c, new List<Report_of_Labor_Code_Violation__c>{rlcv});
                    else
                        foundCaseToRLCV.get(rlcv.DIR_Case__c).add(rlcv);
                }
            }
            
            //re-assign the RLCVs
            Set<Id> errorSet = new Set<Id>();
            List<Report_of_Labor_Code_Violation__c> rlcvToUpdate = new List<Report_of_Labor_Code_Violation__c>();
            List<DIR_Case__c> caseToUpdate = new List<DIR_Case__c>();
            system.debug('casemap:' + accountToCase);
            for (DIR_Case__c dc : caseList){
                //if the new Employer has existing cases
                if (accountToCase.containsKey(dc.Employer__c)) {
                    //if the new Employer has only one open case
                    if (accountToCase.get(dc.Employer__c).size() == 1){
                        //if the updated case is Intake and the existing cases are Intake or Investigation
                        if ((dc.RecordTypeId == intakeRecordType) && ((accountToCase.get(dc.Employer__c).get(0).RecordTypeId == intakeRecordType) || (accountToCase.get(dc.Employer__c).get(0).RecordTypeId == investigationRecordType))){
                            //if the case has RLCVs
                            if (caseToRLCV.containsKey(dc.Id)){
                                //re-assign the RLCvs
                                for (Report_of_Labor_Code_Violation__c rlcv : caseToRLCV.get(dc.Id)){
                                    rlcv.DIR_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                                    rlcvToUpdate.add(rlcv);
                                }
                            }
                            //update case
                            dc.Status__c = 'Duplicate Case';
                            dc.RecordTypeId = closedRecordType;
                            dc.Related_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                            caseToUpdate.add(dc);
                        }
                        //if the updated case is Investigation 
                        if (dc.RecordTypeId == investigationRecordType){
                            //if the existing case is Investigation 
                            if (accountToCase.get(dc.Employer__c).get(0).RecordTypeId == investigationRecordType){
                                //if the updated case has inspections
                                if (updatedCaseWithInspections.contains(dc.Id)){
                                    //if the existing case has RLCVs
                                    if (foundCaseToRLCV.containsKey(accountToCase.get(dc.Employer__c).get(0).Id)){
                                        //re-assign the RLCVs from existing case to the new case 
                                        for (Report_of_Labor_Code_Violation__c rlcv : foundCaseToRLCV.get(accountToCase.get(dc.Employer__c).get(0).Id)){
                                            rlcv.DIR_Case__c = dc.Id;
                                            rlcvToUpdate.add(rlcv);
                                        }
                                    }
                                    //update existing case
                                    accountToCase.get(dc.Employer__c).get(0).Status__c = 'Duplicate Case';
                                    accountToCase.get(dc.Employer__c).get(0).RecordTypeId = closedRecordType;
                                    accountToCase.get(dc.Employer__c).get(0).Related_Case__c = dc.Id;
                                    caseToUpdate.add(accountToCase.get(dc.Employer__c).get(0)); 
                                }
                                else{
                                    //if the existing case has inspections
                                    if (caseWithInspections.contains(accountToCase.get(dc.Employer__c).get(0).Id)){
                                        //if the case has RLCVs
                                        if (caseToRLCV.containsKey(dc.Id)){
                                            //re-assign the RLCvs
                                            for (Report_of_Labor_Code_Violation__c rlcv : caseToRLCV.get(dc.Id)){
                                                rlcv.DIR_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                                                rlcvToUpdate.add(rlcv);
                                            }
                                        }
                                        //update case
                                        dc.Status__c = 'Duplicate Case';
                                        dc.RecordTypeId = closedRecordType;
                                        dc.Related_Case__c = accountToCase.get(dc.Employer__c).get(0).Id;
                                        caseToUpdate.add(dc);
                                    }
                                    //if the existing case does not have inspections
                                    else{
                                        //if the existing case has RLCVs
                                        if (foundCaseToRLCV.containsKey(accountToCase.get(dc.Employer__c).get(0).Id)){
                                            //re-assign the RLCVs from existing case to the new case 
                                            for (Report_of_Labor_Code_Violation__c rlcv : foundCaseToRLCV.get(accountToCase.get(dc.Employer__c).get(0).Id)){
                                                rlcv.DIR_Case__c = dc.Id;
                                                rlcvToUpdate.add(rlcv);
                                            }
                                        }
                                        //update existing case
                                        accountToCase.get(dc.Employer__c).get(0).Status__c = 'Duplicate Case';
                                        accountToCase.get(dc.Employer__c).get(0).RecordTypeId = closedRecordType;
                                        accountToCase.get(dc.Employer__c).get(0).Related_Case__c = dc.Id;
                                        caseToUpdate.add(accountToCase.get(dc.Employer__c).get(0)); 
                                    }
                                }
                            }
                            //if the found case is intake
                            else{
                                //if the existing case has RLCVs
                                if (foundCaseToRLCV.containsKey(accountToCase.get(dc.Employer__c).get(0).Id)){
                                    //re-assign the RLCVs from existing case to the new case 
                                    for (Report_of_Labor_Code_Violation__c rlcv : foundCaseToRLCV.get(accountToCase.get(dc.Employer__c).get(0).Id)){
                                        rlcv.DIR_Case__c = dc.Id;
                                        rlcvToUpdate.add(rlcv);
                                    }
                                }
                                //update existing case
                                accountToCase.get(dc.Employer__c).get(0).Status__c = 'Duplicate Case';
                                accountToCase.get(dc.Employer__c).get(0).RecordTypeId = closedRecordType;
                                accountToCase.get(dc.Employer__c).get(0).Related_Case__c = dc.Id;
                                caseToUpdate.add(accountToCase.get(dc.Employer__c).get(0)); 
                            }
                        }
                    }
                    //if the new Employer has more than one open case, an error must be shown
                    /*else{
                        errorSet.add(dc.Id);
                    }*/
                }
                //if the new Employer does not have any existing cases, just update the RLCVs to the new Employer
                else{
                    if (caseToRLCV.containsKey(dc.Id)){
                        for (Report_of_Labor_Code_Violation__c rlcv : caseToRLCV.get(dc.Id)){
                            rlcv.Account__c = dc.Employer__c;
                            rlcvToUpdate.add(rlcv);
                        }
                    }
                }
            }
            system.debug('errset:' + errorset);
            //add error
            /*for (DIR_Case__c dc : newList){
                if (errorSet.contains(dc.Id))
                    dc.addError('More than one open case has been located for this employer. Please contact your Senior Deputy or a System Administrator for further instructions');
            }*/
            
            update rlcvToUpdate;
            
            update caseToUpdate;
            
        }
    }
    

    public static void AddErrorsToCase(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap) {
        
        Set<Id> caseIds = new Set<Id>();
        for (DIR_Case__c cs : newList) {
            if (cs.Refer_to_JEU__c == 'Referred') {
                caseIds.add(cs.Id);
            }
        }

        if(caseIds.isEmpty()) return;
        
        Map<Id, AggregateResult> PaymentPlans = new Map<Id, AggregateResult>([SELECT Case__c Id, COUNT(Id) Number FROM Payment_Plan__c WHERE Case__c IN :caseIds AND Payment_Plan_Status__c = 'Not Current' GROUP BY Case__c]);
        system.debug('PaymentPlans::: ' + PaymentPlans);
        
        //Map<Id, AggregateResult> Hearings = new Map<Id, AggregateResult>([SELECT Case__c Id, MAX(Hearing_Date__c) MaxDate FROM Hearing__c WHERE Case__c IN :caseIds  GROUP BY Case__c]);
        
        integer noDays = 0;
        List<Key_Value_Store__c> keyValueStoreList = [SELECT Id, Value__c FROM Key_Value_Store__c WHERE Name = 'BOFE JEU Referral Hearing Timeframe'];
        if (keyValueStoreList.size() != 0)
            noDays = integer.valueOf(keyValueStoreList.get(0).Value__c);
                
        for (DIR_Case__c cs : newList) {
            if (cs.Refer_to_JEU__c == 'Referred') {
                if (!PaymentPlans.containsKey(cs.Id) & PaymentPlans.size() > 0) {
                    cs.addError('All Payment Plans are current for this case, it cannot be referred to JEU');
                }
                /*
                // performing this via flow and standard valication rule now
                if (Hearings.containsKey(cs.Id)) {
                    if (Date.today().daysbetween(((DateTime)Hearings.get(cs.Id).get('MaxDate')).Date()) < noDays) {
                        cs.addError('A hearing has been scheduled too recently to refer this case to JEU.');
                    }
                }
                */
            }
        }
    }
    //@Future
    /*public static void createLinkedCasesFuture(Id[] caseIds) {
        //List<Dir_Case__c> dirCaseList = [SELECT Id, Employer__c FROM Dir_Case__c WHERE Id in :caseIds];
        //Map<String,Object> dirCaseMap = (Map<String,Object>)JSON.deserializeUntyped(jsonStr);
        //List<Dir_Case__c> dirCaseList = (List<Dir_Case__c>)JSON.deserializeStrict(jsonStr, Dir_Case__c.class);
        //List<Dir_Case__c> dirCaseList = (List<Dir_Case__c>)dirCaseMap.values();
        //createLinkedCases(dirCaseList);
        
        List<CreateLinkedCases__e> linkedCaseEvents = new List<CreateLinkedCases__e>();
        for(Id caseId : caseIds){
            linkedCaseEvents.add(new CreateLinkedCases__e(CaseId__c = caseId));
        }
    
    
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(linkedCaseEvents);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
    }*/
        
    //public static void createLinkedCases(List<DIR_Case__c> newList){
        /*Map<String,List<DIR_Case__c>> empMap = new Map<String,List<DIR_Case__c>>();
        List<Linked_Case__c> linkedCases = new List<Linked_Case__c>();
        for(DIR_Case__c c : newList){
            if(empMap.containsKey(c.Employer__c)){
                List<DIR_Case__c> tempLst = empMap.get(c.Employer__c);
                tempLst.add(c);
                empMap.put(c.Employer__c, tempLst);
            }else{
                empMap.put(c.Employer__c, new DIR_Case__c[]{c});
            }
        }*/
        
        //B-25243 changes
        /*EmailTemplate et = [Select Id, HtmlValue, Body, subject from EmailTemplate where DeveloperName = 'Linked_case_created' LIMIT 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        String baseURL = system.URL.getSalesforceBaseUrl().toExternalForm();
        
        Map<Id,List<String>> emailsMap = new Map<Id,List<String>>();
        for(Account acc : [select id, (select id, Assigned_Deputy_Email__c from DIR_Cases__r
                                        WHERE ID NOT IN :newList AND Open_Case__c = 'True' AND Assigned_Deputy_Email__c != null)
                                    from Account WHERE Id IN :empMap.keySet()]){
            if(acc.DIR_Cases__r != null && acc.DIR_Cases__r.size() > 0){
                List<String> emailList = new List<String>();
                for(DIR_Case__c dc : acc.DIR_Cases__r){
                    emailList.add(dc.Assigned_Deputy_Email__c);
                }
                emailsMap.put(acc.id, emailList);
            }
        }*/
        
        /*List<Task> tasks = new List<Task>();
        String standardTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Standard Task').getRecordTypeId();
        Set<Id> deputyIdSet = new Set<Id>();
        for(Account acc : [select id, (select id, Assigned_Deputy__c,Assigned_Deputy__r.name, Assigned_Deputy__r.User__c,
                                        Case_Number__c, Employer__c, Status__c, Record_Type_Name__c, Employer__r.name
                                        from DIR_Cases__r WHERE ID NOT IN :newList AND Open_Case__c = 'True' AND Employer__c != null AND Assigned_Deputy__c != null ORDER BY LastModifiedDate DESC)
                                    from Account WHERE Id IN :empMap.keySet()]){
            if(acc.DIR_Cases__r != null && acc.DIR_Cases__r.size() > 0){
                for(DIR_Case__c c : empMap.get(acc.id)){
                    for(DIR_Case__c cs : acc.DIR_Cases__r){
                        Linked_Case__c lc = new Linked_Case__c();
                        lc.Assigned_Deputy__c = cs.Assigned_Deputy__r.name;
                        lc.Case_Number__c = cs.Case_Number__c;
                        lc.CM_Case__c = c.id;
                        lc.Linked_Case__c = cs.id;
                        lc.Employer__c = acc.id;
                        linkedCases.add(lc);
                        
                        //if(cs.Assigned_Deputy__r.User__c != Null){
                            if(!deputyIdSet.contains(cs.Assigned_Deputy__r.User__c)){
                                deputyIdSet.add(cs.Assigned_Deputy__r.User__c);
                                tasks.add(new Task(OwnerId = cs.Assigned_Deputy__r.User__c, 
                                               WhatId = c.id,
                                               RecordTypeId = standardTaskRT,
                                               Subject = 'New Case Opened',
                                               Description = 'A new case has been opened for the same employer.\n Employer: '+cs.Employer__r.name,
                                               ActivityDate = Date.today(),
                                               Due_Date__c = Date.today(),
                                               Status = 'Not Started',
                                               Priority =  'Normal'));
                            }*/
                        //}
                        
                        /*if(emailsMap.containsKey(acc.id)){
                            Messaging.SingleEmailMessage emsg = new Messaging.SingleEmailMessage();
                            emsg.setTemplateId(et.Id);
                            emsg.setToAddresses(emailsMap.get(acc.id));
                            emsg.setTargetObjectId(cs.Assigned_Deputy__r.User__c);
                            emsg.saveAsActivity = false;
                            String htmlBody = et.htmlValue;
                            htmlBody = htmlBody.replace('{!DIR_Case__c.Employer__c}', cs.Employer__r.name);
                            htmlBody = htmlBody.replace('{!DIR_Case__c.Record_Type_Name__c}', cs.Record_Type_Name__c);
                            htmlBody = htmlBody.replace('{!DIR_Case__c.Link}',  + baseURL + '/' + cs.id);
                            htmlBody = htmlBody.replaceAll(']]>','');
                            emsg.setHtmlBody(htmlBody);
                            emsg.setSubject(et.Subject);
                            emails.add(emsg);
                        }*/
                   /* }
                }
            }
        }
        
        if(linkedCases.size() > 0){
            insert linkedCases;
        }
        
        if(tasks.size() > 0){
            insert tasks;
        }
        */
        
        /*if(emails.size() > 0){
            Messaging.sendEmail(emails);
        }*/
    //}
    
    /*public static void updateLinkedCases(List<DIR_Case__c> newList, Map<Id, DIR_Case__c> oldMap){
        Map<String,String> oldEmp = new Map<String,String>();
        Map<String,List<DIR_Case__c>> newEmp = new Map<String,List<DIR_Case__c>>();
        Set<ID> closedCaseIDs = new Set<ID>();
        List<Linked_Case__c> delLC = new List<Linked_Case__c>();
        List<Linked_Case__c> addLC = new List<Linked_Case__c>();
        for(DIR_Case__c c : newList){
            if(c.Employer__c != oldMap.get(c.id).Employer__c){
                if(newEmp.containsKey(c.Employer__c)){
                    List<DIR_Case__c> tempLst = newEmp.get(c.Employer__c);
                    tempLst.add(c);
                    newEmp.put(c.Employer__c, tempLst);
                }else{
                    newEmp.put(c.Employer__c, new DIR_Case__c[]{c});
                }
                
                oldEmp.put(c.id, oldMap.get(c.id).Employer__c);
            }
            
            if(c.Status__c != oldMap.get(c.id).Status__c && c.Closed__c){
                closedCaseIDs.add(c.id);
            }
        }
        
        for(Linked_Case__c lc : [select id,Employer__c,CM_Case__c,Linked_Case__c from Linked_Case__c WHERE Linked_Case__c IN :closedCaseIDs OR (CM_Case__c IN :oldEmp.keySet() AND Employer__c IN :oldEmp.values())]){
            if(lc.Employer__c == oldEmp.get(lc.CM_Case__c) || closedCaseIDs.contains(lc.Linked_Case__c)){
                delLC.add(lc);
            }
        }
        
        for(Account acc : [select id, (select id, Assigned_Deputy__c,Assigned_Deputy__r.name, Case_Number__c, Employer__c, Status__c from DIR_Cases__r WHERE ID NOT IN :newList AND Open_Case__c = 'True' AND Assigned_Deputy__c != null) from Account WHERE Id IN :newEmp.keySet()]){
            if(acc.DIR_Cases__r != null && acc.DIR_Cases__r.size() > 0){
                for(DIR_Case__c c : newEmp.get(acc.id)){
                    for(DIR_Case__c cs : acc.DIR_Cases__r){
                        Linked_Case__c lc = new Linked_Case__c();
                        lc.Assigned_Deputy__c = cs.Assigned_Deputy__r.name;
                        lc.Case_Number__c = cs.Case_Number__c;
                        lc.CM_Case__c = c.id;
                        lc.Linked_Case__c = cs.id;
                        lc.Employer__c = acc.id;
                        addLC.add(lc);
                    }
                }
            }
        }
        
        if(delLc.size() > 0){
            delete delLC;
        }
        
        if(addLc.size() > 0){
            insert addLC;
        }
    }*/
    
    private static void createAssignmentHistory(List<DIR_Case__c> newCases,Map<Id, DIR_Case__c> oldCases){

        List<Assignment_History__c> histories = new List<Assignment_History__c>();
        Set<String> setCaseIds = new Set<String>();
        Map<String, String> mapCaseIdToNewDeputy = new Map<String, String>();
        
        for(DIR_Case__c objCase : newCases){
            
            if(objCase.Assigned_Deputy__c != Null && 
               (oldCases == Null || (objCase.Assigned_Deputy__c != oldCases.get(objCase.Id).Assigned_Deputy__c || 
                                    (objCase.Status__c == 'Reopened with Senior Approval'  && objCase.Status__c != oldCases.get(objCase.Id).Status__c &&
                                     Boolean.valueOf(oldCases.get(objCase.Id).Closed__c))))){
                   

                   if(oldCases != Null && oldCases.get(objCase.Id).Assigned_Deputy__c != Null){
                       setCaseIds.add(objCase.Id);
                   }
                   
                   mapCaseIdToNewDeputy.put(objCase.Id,objCase.Assigned_Deputy__c);
              }
        }
        

        for(Assignment_History__c objAH : [SELECT Id,End_Date__c
                                           FROM Assignment_History__c
                                           WHERE End_Date__c = Null
                                           AND Case_Management__c =: setCaseIds]){
                                               
              objAH.End_Date__c = Date.today();
              histories.add(objAH);                                 
        }
        
        map<Id,DIR_Employee__c> mapEmployees =  new map<Id,DIR_Employee__c>([SELECT Id,User__c
                                                                             FROM DIR_Employee__c
                                                                             WHERE Id =: mapCaseIdToNewDeputy.values()
                                                                             AND User__c != Null]);
        for(String caseId : mapCaseIdToNewDeputy.keyset()){
            
            if(mapEmployees.containsKey(mapCaseIdToNewDeputy.get(caseId))){ 
                
                histories.add(new Assignment_History__c(Start_Date__c = Date.today(),
                                                        Case_Management__c = caseId,
                                                        OwnerId = mapEmployees.get(mapCaseIdToNewDeputy.get(caseId)).User__c));
            }
        }
        
        upsert histories;
    }
    //-----------------------------
    // @param: Map<Id, DIR_Case__c> cases
    // @description: Method to prevent non admins from deleting cases considering purge date
    // @return: void
    //-----------------------------
    public static void validateBeforeCaseDelete(Map<Id, DIR_Case__c> cases){
        
         Boolean isSystemAdmin = false;
         
         List<Profile> sysAdminList = [SELECT Id FROM Profile WHERE Name  like 'System Administrator%'];
         
         if (sysAdminList.size() > 1)
         {
             for (Integer i = 0; i < sysAdminList.size(); i++)
             {
                 if (Userinfo.getProfileId() == sysAdminList[i].Id)
                 {
                     isSystemAdmin = true;
                 }
             }
         }                
        
        if(!isSystemAdmin || Test.isRunningTest()){
            
            for(DIR_Case__c objCase : cases.values()){
                
                if(objCase.Purge_Date__c == Null || objCase.Purge_Date__c < Date.Today()){
                    
                    objCase.addError('Only system administrators can delete historical cases.');
                }
                
            }
        }
    }
    
    public static void updateClosedCaseAssignedHistory(List<DIR_Case__c> caseList){
        List<Assignment_History__c> ahList = new List<Assignment_History__c>();
        for(DIR_Case__c c : [SELECT id,(SELECT id, End_Date__c FROM Assignment_History__r WHERE End_Date__c = null ORDER BY LastModifiedDate DESC LIMIT 1) FROM DIR_Case__c WHERE id IN :caseList]){
            if(c.Assignment_History__r != null && c.Assignment_History__r.size() > 0){
                c.Assignment_History__r[0].End_Date__c = system.today();
                ahList.add(c.Assignment_History__r[0]);
            }
        }
        if(ahList.size() > 0){
            update ahList;
        }
    }
}