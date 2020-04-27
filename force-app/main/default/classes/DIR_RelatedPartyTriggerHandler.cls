//-----------------------------
// @author: Oswin Correa
// @date: 18/4/2018
// @description: Trigger Handler of DIR_RelatedParty Trigger on Related_Party__c object
//-----------------------------
// @modified by: Daniel Chu
// @deploy date: 1/31/2019
// @description: Fix issue with confirming employer related party whose other zip code is out of California  
//-----------------------------
public with sharing class DIR_RelatedPartyTriggerHandler {
    public static Boolean preventReccursion = true;
    
    //-----------------------------
    // @param: Map<Id,Related_Party__c> oldRelatedParties,Map<Id,Related_Party__c> newRelatedParties
    // @description: Method called on After Update of  Related_Party__c records
    // @return: void
    //-----------------------------
    
    public static void onAfterUpdate(Map<Id,Related_Party__c> oldRelatedParties,Map<Id,Related_Party__c> newRelatedParties){
        
        Map<Id,Related_Party__c> filteredRelatedParties = new Map<Id,Related_Party__c>();
        Map<Id,Related_Party__c> mapRPs = new Map<Id,Related_Party__c>();
        Set<String> setAccountIds =  new Set<String>();
        Set<String> setcaseIds =  new Set<String>();
        List<Account> accounts =  new List<Account>();
        
        for(Related_Party__c objnewRP : newRelatedParties.values()){
            
            Related_Party__c objoldRP = oldRelatedParties.get(objnewRP.Id);
            
            if(objnewRP.Status__c == 'Confirm' && objnewRP.Status__c != objoldRP.Status__c && objnewRP.Role__c != 'Employer Address'){
                
                if(String.isBlank(objnewRP.Found_Account_ID__c) || (objnewRP.Found_Account_ID__c InstanceOf Id && String.valueof(Id.valueof(objnewRP.Found_Account_ID__c).getSobjectType()) == 'Account')){
                    
                    setAccountIds.add(objnewRP.Found_Account_ID__c);
                    setcaseIds.add(objnewRP.Case_Management__c);
                    filteredRelatedParties.put(objnewRP.id,objnewRP);
                }
                
                else{
                    
                    objnewRP.addError('Enter valid Account Id in Found_Account_ID field');
                }
            }
        }
        
        if(!filteredRelatedParties.isEmpty()){
            
            matchPersonAccountAndCreateCaseRole(filteredRelatedParties,setAccountIds,setcaseIds);
        }
    }
    
    //-----------------------------
    // @param: Map<Id,Related_Party__c> filteredRelatedParties,Set<String> setAccountIds,Set<String> setcaseIds
    // @description: Method called to create Case Roles and match Account by fetching the value entered in Found_Account_ID__c
    // @return: void
    //-----------------------------
    
    private static void matchPersonAccountAndCreateCaseRole(Map<Id,Related_Party__c> filteredRelatedParties,Set<String> setAccountIds,Set<String> setcaseIds){
        
        Map<String,Schema.RecordTypeInfo> accountTRMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        
        //Fetching the appropriate Case Role and Account record types
        String recordTypeName_Office = Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('RCI').getname();
        Id recordTypeId_RC = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_PA = accountTRMapByName.get('Person Account').getRecordTypeId();
        Id recordTypeId_BA = accountTRMapByName.get('Business Account').getRecordTypeId();
        
        List<Case_Role__c> caseRolesToUpsert = new List<Case_Role__c>();
        Set<String> caseIds =  new Set<String>();
        Map<String,DIR_Case__c> casesToUpdate = new Map<String,DIR_Case__c>();
        Map<String,Case_Role__c> mapExistingCaseRoles = new Map<String,Case_Role__c>();
        Map<String,Case_Role__c> mapCaseRoles = new Map<String,Case_Role__c>();
        Map<String,Related_Party__c> mapFilteredRelatedParties = new Map<String,Related_Party__c>();
        Map<String,Account> mapAccountsToInsert = new Map<String,Account>();
        Map<String,Office__c> mapNewDIROffice = new Map<String,Office__c>();
        Map<String,Address__c> mapCaseToLocation = new Map<String,Address__c>();
        Map<String,Account> accounts = new Map<String,Account>();
        Map<String,Id> zipCodes = new Map<String,Id>();

        Id officePrimaryId;
        Id officeSecondId;
        String countyPrimary;
        String countySecond;
        Id zipCode00000Id;
        
        for(Zip_Code__c zcode: [Select Id, Name from Zip_Code__c]){
            zipCodes.put(zcode.Name,zcode.Id);
        }        
        
        zipCode00000Id = zipCodes.get('00000'); 
        //System.debug('zipCode00000Id: '+zipCode00000Id);
        
        //Fetching existing Case Roles
        for(Case_Role__c objCR : [SELECT Id,Case__c,Entity__c
                                  FROM Case_Role__c
                                  WHERE Entity__c =: setAccountIds  
                                  AND Case__c =: setcaseIds]){      
                                      
                                      mapExistingCaseRoles.put(objCR.Case__c +'_'+ objCR.Entity__c,objCR); 
                                  }
        
        for(Account objAccount : [SELECT Id
                                  FROM Account
                                  WHERE Id =: setAccountIds]){
                                      
                                      accounts.put(objAccount.Id,objAccount);
                                      accounts.put(String.valueOf(objAccount.Id).left(15),objAccount);
                                  }  
        
        for(Related_Party__c objnewRP : filteredRelatedParties.values()){
            
            //Creating Case role instance
            Case_Role__c objCaseRole =  new Case_Role__c(Case__c = objnewRP.Case_Management__c,
                                                         RecordTypeId = recordTypeId_RC,
                                                         Case_Role_Status__c = 'Active',
                                                         Role__c = objnewRP.Role__c);
            
            //B-27763 Fix
            if(String.isNotBlank(objnewRP.Role__c) && (objnewRP.Role__c == 'Case Employer' || objnewRP.Role__c == 'Advocate' || objnewRP.Role__c == 'Claimant')){
                
                mapFilteredRelatedParties.put(objnewRP.Id,objnewRP);
            }
            
            //Case 1: When Account Id is entered in Found_Account_ID__c                                                    
            if(String.isNotBlank(objnewRP.Found_Account_ID__c)){
                
                
                //Case 2: When valid Account Id is entered in Found_Account_ID__c
                if(accounts.containsKey(objnewRP.Found_Account_ID__c)){
                    
                    objCaseRole.Entity__c = objnewRP.Found_Account_ID__c;
                    
                    //Appending Id if already Case Role exists to prevent duplicate creation
                    if(mapExistingCaseRoles.containsKey(objnewRP.Case_Management__c  +'_'+ objnewRP.Found_Account_ID__c)){
                        
                        objCaseRole.id = mapExistingCaseRoles.get(objnewRP.Case_Management__c  +'_'+ objnewRP.Found_Account_ID__c).Id;
                    }
                    
                    //B-24891 Fix
                    if(objnewRP.Role__c != 'Claimant' || objCaseRole.id != null){
                        
                        caseRolesToUpsert.add(objCaseRole);
                    }
                }
                //Case 3: When  Account entered in Found_Account_ID__c is not valid
                else{
                    if(mapFilteredRelatedParties.containsKey(objnewRP.Id)){
                        
                        mapFilteredRelatedParties.remove(objnewRP.Id);
                    }
                    
                    objnewRP.addError('No matching Account found for the Account ID entered in Found_Account_ID field');
                    
                }
            }
            //Case 4: When  no Account Id is entered in Found_Account_ID__c field
            else{
                
                //Case 5: Creation of Person Account fetching first name and last Name    
                if(String.isNotBlank(objnewRP.First_Name__c) && String.isNotBlank(objnewRP.Last_Name__c)){
                    
                    mapAccountsToInsert.put(objnewRP.Id, new Account(FirstName = objnewRP.First_Name__c, 
                                                                     LastName = objnewRP.Last_Name__c,
                                                                     RecordTypeId = recordTypeId_PA,
                                                                     BillingCity = objnewRP.City__c,
                                                                     BillingState = objnewRP.State__c,
                                                                     BillingPostalCode = objnewRP.Zip_Code__c,
                                                                     BillingStreet = objnewRP.Street_Address__c,
                                                                     ShippingCity = objnewRP.City__c,
                                                                     ShippingState = objnewRP.State__c,
                                                                     ShippingPostalCode = objnewRP.Zip_Code__c,
                                                                     ShippingStreet = objnewRP.Street_Address__c,
                                                                     PersonMailingCity = objnewRP.City__c,
                                                                     PersonMailingPostalCode = objnewRP.Zip_Code__c,
                                                                     PersonMailingStreet = objnewRP.Street_Address__c,
                                                                     PersonOtherCity = objnewRP.Other_City__c,
                                                                     PersonOtherState = objnewRP.Other_State__c,
                                                                     PersonOtherStreet = objnewRP.Other_Street_Address__c,
                                                                     PersonOtherPostalCode = objnewRP.Other_Zip_Code__c,
                                                                     PersonEmail = objnewRP.Email__c,
                                                                     Email__c = objnewRP.Email__c,
                                                                     Type = objnewRP.Type_of_Work__c,
                                                                     PersonTitle = objnewRP.Title__c,
                                                                     Phone = objnewRP.Phone__c,
                                                                     PersonHomePhone = objnewRP.Phone__c,
                                                                     PersonOtherPhone = objnewRP.Employer_Contact__c,
                                                                     NumberOfEmployees = objnewRP.Number_of_employees__c != null ? Integer.valueOf(objnewRP.Number_of_employees__c) : null));
                    //B-24891 Fix
                    if(objnewRP.Role__c != 'Claimant'){
                        
                        mapCaseRoles.put(objnewRP.Id,objCaseRole);
                    }
                    
                }
                //Case 6: Creation of Business Account fetching Business name
                else if(String.isNotBlank(objnewRP.Business_Name__c)){
                    
                    mapAccountsToInsert.put(objnewRP.Id, new Account(Name = objnewRP.Business_Name__c,
                                                                     RecordTypeId = recordTypeId_BA,
                                                                     ShippingCity = objnewRP.City__c,
                                                                     ShippingState = objnewRP.State__c,
                                                                     ShippingPostalCode = objnewRP.Zip_Code__c,
                                                                     ShippingStreet = objnewRP.Street_Address__c,
                                                                     BillingCity = objnewRP.Other_City__c,
                                                                     BillingState = objnewRP.Other_State__c,
                                                                     BillingStreet = objnewRP.Other_Street_Address__c,
                                                                     BillingPostalCode = objnewRP.Other_Zip_Code__c,
                                                                     Email__c = objnewRP.Email__c,
                                                                     Type = objnewRP.Type_of_Work__c,
                                                                     Phone = objnewRP.Phone__c,
                                                                     Phone1__c = objnewRP.Employer_Contact__c,
                                                                     NumberOfEmployees = objnewRP.Number_of_employees__c != null ? Integer.valueOf(objnewRP.Number_of_employees__c) : null)); 
                    //B-24891 Fix                                                 
                    if(objnewRP.Role__c != 'Claimant'){
                        
                        mapCaseRoles.put(objnewRP.Id,objCaseRole);
                    }                                                  
                }
            }
        }
        
        insert mapAccountsToInsert.values();
        
        for(Account objAccount : [SELECT Id,Employer_No_Longer_Operating__c,Imported_From__c,Fax,DBA__c,Attention_To1__c
                                  FROM Account
                                  WHERE Id =: setAccountIds OR Id =: mapAccountsToInsert.values()]){
                                      
                                      accounts.put(objAccount.Id,objAccount);
                                      accounts.put(String.valueOf(objAccount.Id).left(15),objAccount);
                                  }                                                        
        
        List<Address__c> locations =  new List<Address__c>();        
        
        for(Related_Party__c objRP : [SELECT Id,Case_Management__c,Case_Management__r.Advocate__c,Case_Management__r.Assigned_Screener__c,Case_Management__r.Assigned_Screener__r.Office__c,Case_Management__r.Employer__c,Case_Management__r.Claimant__c,Case_Management__r.Work_Location__c,Still_in_business__c,Case_Management__r.Office__c, Zip_Code__c
                                      FROM Related_Party__c
                                      WHERE (Case_Management__r.Employer__c = Null OR Case_Management__r.Claimant__c = Null OR Case_Management__r.Work_Location__c = Null)
                                      AND Id =: mapFilteredRelatedParties.keyset()]){
                                          
                                          Account objAccount;
                                          
                                          if(mapAccountsToInsert.containsKey(objRP.Id)){
                                              
                                              objAccount = accounts.get(mapAccountsToInsert.get(objRP.Id).Id); 
                                          }
                                          else if(String.isNotBlank(mapFilteredRelatedParties.get(objRP.Id).Found_Account_ID__c) && accounts.containsKey(mapFilteredRelatedParties.get(objRP.Id).Found_Account_ID__c)){
                                              
                                              objAccount = accounts.get(mapFilteredRelatedParties.get(objRP.Id).Found_Account_ID__c);
                                              
                                          }
                                          
                                          if(objAccount != Null){
                                              
                                              Related_Party__c objnewRP = mapFilteredRelatedParties.get(objRP.Id);
                                              
                                              //B-27763 Fix 
                                              if(objnewRP.Status__c == 'Confirm' && objnewRP.Role__c == 'Case Employer'){
                                                  
                                                  caseIds.add(objRP.Case_Management__c);
                                                  
                                              }
                                              
                                              for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Zip_Code__c =: zipCodes.get(objnewRP.Zip_Code__c)]){
                                                  
                                                  
                                                  if(zcode.Office__r.RecordType.Name.equals(recordTypeName_Office)){
                                                      
                                                      officePrimaryId = zcode.Office__c;
                                                      countyPrimary = zcode.County__c;
                                                      
                                                      
                                                  }
                                              }
                                              
                                              //B-27763 Fix 
                                              if((objRP.Case_Management__r.Employer__c == Null || objRP.Case_Management__r.Office__c == Null) && mapFilteredRelatedParties.get(objRP.id).Role__c == 'Case Employer'){
                    
                    if(objRP.Case_Management__r.Employer__c == Null && objRP.Case_Management__r.Office__c == Null){
                        casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c, Employer__c = objAccount.Id, County__c = countyPrimary, Office__c = officePrimaryId));
                    }
                    
                    else if(objRP.Case_Management__r.Employer__c == Null){
                        casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c, Employer__c = objAccount.Id));
                    }
                    
                    else if(objRP.Case_Management__r.Office__c == Null){
                        casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c,County__c = countyPrimary, Office__c = officePrimaryId));
                    }
                    
                }
                                              
                                              //B-27763 Fix 
                                              else if(objRP.Case_Management__r.Advocate__c == Null && mapFilteredRelatedParties.get(objRP.id).Role__c == 'Advocate'){
                                                  
                                                  casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c, Advocate__c = objAccount.Id));
                                              }
                                              
                                              else if(objRP.Case_Management__r.Claimant__c == Null && mapFilteredRelatedParties.get(objRP.id).Role__c == 'Claimant'){
                                                  
                                                  casesToUpdate.put(objRP.Case_Management__c,new DIR_Case__c(Id = objRP.Case_Management__c,Claimant__c = objAccount.Id));
                                              }
                                              
                                          }
                                          
                                      }
        
        update casesToUpdate.values();
        
        //Linking newly created accounts to Case Roles
        for(String rpId : mapCaseRoles.keyset()){
            
            Case_Role__c objCaseRole = mapCaseRoles.get(rpId);
            objCaseRole.Entity__c = mapAccountsToInsert.get(rpId).Id;
            caseRolesToUpsert.add(objCaseRole);
        }
        
        upsert caseRolesToUpsert;
        
        List<Related_Party__c> parties =  new List<Related_Party__c>();
        Map<Id,String> zipCode =  new Map<Id,String>();
        
        accounts.clear();
        
        Address__c location;
        
        for(Related_Party__c objRP : [   SELECT Id,Other_Zip_Code__c,Other_State__c,Other_City__c,Other_Street_Address__c,
                                      Number_of_employees__c,Still_in_business__c,Phone__c,Case_Management__c,Case_Management__r.Employer__r.IsPersonAccount,
                                      Case_Management__r.Employer__c,Case_Management__r.Employer__r.Employer_No_Longer_Operating__c,
                                      Case_Management__r.Employer__r.Attention_To1__c,Case_Management__r.Employer__r.Imported_From__c,
                                      Case_Management__r.Employer__r.Fax,Case_Management__r.Employer__r.DBA__c
                                      FROM Related_Party__c
                                      WHERE Case_Management__c =: caseIds
                                      AND Role__c = 'Employer Address'
                                      AND Status__c != 'Confirm'
                                      AND Case_Management__r.Employer__c != Null
                                      AND Other_Zip_Code__c != Null]){
                                          
                                          //System.debug('objRP -------------- '+objRP);
                                          //System.debug('objRP.Other_Zip_Code__c ------------ '+objRP.Other_Zip_Code__c);
                                          
                                          if(zipCodes.containsKey(objRP.Other_Zip_Code__c)){
                                          
                                              zipCode.put(zipCodes.get(objRP.Other_Zip_Code__c),objRP.Other_Zip_Code__c);
                                          }
                                          //SR-005287: fixes the issue with confirming out of CA zip codes
                                          //Zip Code: 00000 is an arbitrary zip code to hold employer with out of CA address zip codes
                                          else{
                                          
                                              zipCode.put(zipCode00000Id,'00000');     
                                          }
                                          
                                          
                                          location = new Address__c(Entity__c = objRP.Case_Management__r.Employer__c,
                                                                    Work_Performed_at_this_Location__c = !objRP.Case_Management__r.Employer__r.Employer_No_Longer_Operating__c,
                                                                    Type__c = 'Business Location',
                                                                    Active_Location__c = true,
                                                                    Total_Employees__c = objRP.Number_of_employees__c != null ? Integer.valueOf(objRP.Number_of_employees__c) : null,
                                                                    Phone__c = objRP.Phone__c,
                                                                    Imported_From__c = objRP.Case_Management__r.Employer__r.Imported_From__c,
                                                                    Fax__c = objRP.Case_Management__r.Employer__r.Fax,
                                                                    Employer_Still_Operating_Here__c = objRP.Still_in_business__c,
                                                                    DBA__c = objRP.Case_Management__r.Employer__r.DBA__c,  
                                                                    Attention_To__c = objRP.Case_Management__r.Employer__r.Attention_To1__c);
                                          
                                          
                                          location.City__c = objRP.Other_City__c;
                                          location.State__c = objRP.Other_State__c;
                                          location.Zip_Code__c = objRP.Other_Zip_Code__c;
                                          location.Address__c = String.isNotBlank(objRP.Other_Street_Address__c) ? objRP.Other_Street_Address__c : '';
                                          location.Address__c = location.Address__c.removeEnd(',');  
                                          objRP.Status__c = 'Confirm';
                                          parties.add(objRP);
                                          mapCaseToLocation.put(objRP.Case_Management__c,  location);
                                          locations.add(location);
                                          
                                      }
        
        insert locations;            
        
        casesToUpdate.clear();
        
        //System.debug('zipCode ---- '+zipCode);
        //System.debug(' query zipcode ---- '+[Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Zip_Code__c = :zipCode.keyset()]);
        
        for(Office_Zip_Code_Map__c zcode: [Select Id, Office__c,Office__r.RecordType.Name, Zip_Code__c, County__c from Office_Zip_Code_Map__c where Zip_Code__c =: zipCode.keyset()]){
            
            //System.debug('zcode ---------- '+zcode);
 
            if(zcode.Office__r.RecordType.Name.equals(recordTypeName_Office)){
                
                officeSecondId = zcode.Office__c;
                countySecond = zcode.County__c;
                
            }
        }
        
        //System.debug('officeSecondId ----- '+officeSecondId);
        //System.debug('countySecond ----- '+countySecond);
        
        for(String caseId :  mapCaseToLocation.keyset()){
            casesToUpdate.put(caseId, new DIR_Case__c(Work_Location__c = mapCaseToLocation.get(caseId).Id, Id = caseId, Office__c = officeSecondId, County__c = countySecond)); 
        }
        
        update casesToUpdate.values();
        //System.debug('casesToUpdate ----- '+casesToUpdate);
        update parties;
        
    }
    
}