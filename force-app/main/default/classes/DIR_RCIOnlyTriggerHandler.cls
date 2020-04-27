public with sharing class DIR_RCIOnlyTriggerHandler {
    
    public static void onAfterUpdate(Map<Id,RCI_Only__c> oldRCIOnly,Map<Id,RCI_Only__c> newRCIOnly){
        
        Map<Id,RCI_Only__c> filteredRCI = new Map<Id,RCI_Only__c>();
        Id rtImmigrationThreatId = Schema.SObjectType.RCI_Only__c.getRecordTypeInfosByName().get('Immigration Threat').getRecordTypeId();
        
        for(RCI_Only__c objRCI : newRCIOnly.values()){
            
            if(String.isNotBlank(objRCI.Status__c) && objRCI.Status__c != oldRCIOnly.get(objRCI.Id).Status__c 
                && objRCI.Status__c == 'Convert to Case' && objRCI.RecordTypeId == rtImmigrationThreatId){
                    
                   filteredRCI.put(objRCI.Id,objRCI); 
            }
        }
        
        if(!filteredRCI.isEmpty()){
            
            createRCICase(filteredRCI);
        }

    }
    
    private static void createRCICase(Map<Id,RCI_Only__c> filteredRCI){
        
        set<String> setRoles = new set<String>{'Advocate','Primary Witness','Case Employer'};
        set<String> setAccountIds = new set<String>();
        List<RCI_Only__c> lstRCIToUpdate = new List<RCI_Only__c>();
        
        Map<String,Associated_Party__c> filteredAP = new Map<String,Associated_Party__c>();
        Map<String,Case_Role__c> mapRCIIdToCaseRole = new Map<String,Case_Role__c>();
        Map<String,Map<String,Account>> mapRCIIdToAccountInfo = new Map<String,Map<String,Account>>();
        Map<String,Account> mapAccountsToUpsert = new Map<String,Account>();
        Map<String,DIR_Case__c> mapRCIToCase = new Map<String,DIR_Case__c>();
        
        //Fetching the appropriate Case Role and Account record types
        Id recordTypeId_RC = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Id recordTypeId_CR = Schema.SObjectType.Case_Role__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
        Map<String,Schema.RecordTypeInfo> accountTRMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id recordTypeId_PA = accountTRMapByName.get('Person Account').getRecordTypeId();
        Id recordTypeId_BA = accountTRMapByName.get('Business Account').getRecordTypeId();
        
        set<Id> setRCIOnlyIds = filteredRCI.keyset();
        set<Id> setExcludeRCI = new set<Id>();
        
        List<String> associatedPartyFields = new List<String>(Associated_Party__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = 'SELECT '+String.join(associatedPartyFields, ',')+ ' FROM Associated_Party__c WHERE RCI__c =: setRCIOnlyIds AND Role__c =: setRoles';
        
        for(Associated_Party__c objAP : Database.query(soql)){
             
             if(String.isBlank(objAP.Found_Account_ID__c) || (objAP.Found_Account_ID__c InstanceOf Id && 
                    String.valueof(Id.valueof(objAP.Found_Account_ID__c).getSobjectType()) == 'Account')){
                    
                    setAccountIds.add(objAP.Found_Account_ID__c);
                    filteredAP.put(objAP.Id,objAP);
               }
               else{
                   
                   filteredRCI.get(objAP.RCI__c).addError('Enter valid Account Id in Found_Account_ID field for Associated Party having role '+objAP.Role__c);
                   setExcludeRCI.add(objAP.RCI__c);
               }                                
        }
        

        
        Map<String,Account> accounts = new Map<String,Account>();
        
        for(Account objAccount : ([SELECT Id
                                  FROM Account
                                  WHERE Id =: setAccountIds])){
                                      
              accounts.put(objAccount.Id,objAccount);
              accounts.put(String.valueOf(objAccount.Id).left(15),objAccount); 
        }
        
                                                                

        for(Associated_Party__c objAP : filteredAP.values()){
            
            if(!setExcludeRCI.contains(objAP.RCI__c)){
                
                if(!mapRCIIdToAccountInfo.containsKey(objAP.RCI__c)){
                    
                    mapRCIIdToAccountInfo.put(objAP.RCI__c, new Map<String, Account>());
                }
                
                //Case 1: When Account Id is entered in Found_Account_ID__c                                                    
                if(String.isNotBlank(objAP.Found_Account_ID__c)){
                    
                    //Case 2: When valid Account Id is entered in Found_Account_ID__c
                    if(accounts.containsKey(objAP.Found_Account_ID__c)){
                        
                        mapRCIIdToAccountInfo.get(objAP.RCI__c).put(objAP.Role__c,accounts.get(objAP.Found_Account_ID__c));

                    }
                    //Case 3: When  Account entered in Found_Account_ID__c is not valid
                    else{
                        
                        filteredRCI.get(objAP.RCI__c).addError('No matching Account found for the Account ID entered in Found_Account_ID field for Associated Party having role '+objAP.Role__c);
                        setExcludeRCI.add(objAP.RCI__c);
                   
                    }
                }
                else{
                
                 //Case 5: Creation of Person Account fetching first name and last Name    
                    if(String.isNotBlank(objAP.First_Name__c) && String.isNotBlank(objAP.Last_Name__c)){
                        
                        RCI_Only__c objRCI = filteredRCI.get(objAP.RCI__c);
                        
                        Account objAccount = new Account(FirstName = objAP.First_Name__c, 
                                                         LastName = objAP.Last_Name__c,
                                                         RecordTypeId = recordTypeId_PA,
                                                         BillingCity = objAP.City__c,
                                                         BillingPostalCode = objAP.Zip_Code__c,
                                                         BillingStreet = objAP.Street_Address__c,
                                                         ShippingCity = objAP.City__c,
                                                         ShippingPostalCode = objAP.Zip_Code__c,
                                                         ShippingStreet = objAP.Street_Address__c,
                                                         PersonMailingCity = objAP.City__c,
                                                         PersonMailingPostalCode = objAP.Zip_Code__c,
                                                         PersonMailingStreet = objAP.Street_Address__c,
                                                         PersonOtherCity = objAP.Other_City__c,
                                                         PersonOtherState = objAP.OtherState__c,
                                                         PersonOtherStreet = objAP.Other_Street_Address__c,
                                                         PersonOtherPostalCode = objAP.Other_Zip_Code__c,
                                                         PersonEmail = objAP.Email__c,
                                                         Email__c = objAP.Email__c,
                                                         Type = objAP.Type_of_Work__c,
                                                         PersonTitle = objAP.Title__c,
                                                         Phone = objAP.Phone__c,
                                                         PersonHomePhone = objAP.Phone__c,
                                                         PersonOtherPhone = objAP.OtherPhone__c,
                                                         NumberOfEmployees = objAP.Number_of_employees__c != null ? Integer.valueOf(objAP.Number_of_employees__c) : null);
                        
                        
                        mapRCIIdToAccountInfo.get(objAP.RCI__c).put(objAP.Role__c,objAccount);
                        mapAccountsToUpsert.put(objAP.Id, objAccount);
                    }
                    //Case 6: Creation of Business Account fetching Business name
                    else if(String.isNotBlank(objAP.Business_Name__c)){
                        
                        RCI_Only__c objRCI = filteredRCI.get(objAP.RCI__c);
                        Account objAccount = new Account(Name = objAP.Business_Name__c,
                                                     RecordTypeId = recordTypeId_BA,
                                                     ShippingCity = objAP.City__c,
                                                     ShippingPostalCode = objAP.Zip_Code__c,
                                                     ShippingStreet = objAP.Street_Address__c,
                                                     BillingCity = objAP.Other_City__c,
                                                     BillingState = objAP.OtherState__c,
                                                     BillingStreet = objAP.Other_Street_Address__c,
                                                     BillingPostalCode = objAP.Other_Zip_Code__c,
                                                     Email__c = objAP.Email__c,
                                                     Type = objAP.Type_of_Work__c,
                                                     Phone = objAP.Phone__c,
                                                     Phone1__c = objAP.OtherPhone__c,
                                                     NumberOfEmployees = objAP.Number_of_employees__c != null ? Integer.valueOf(objAP.Number_of_employees__c) : null);
                                                     
                        mapRCIIdToAccountInfo.get(objAP.RCI__c).put(objAP.Role__c,objAccount);
                        mapAccountsToUpsert.put(objAP.Id, objAccount);
                                                     
                   }
                }
            }
        }
        
        upsert mapAccountsToUpsert.values();
        
        for(String rcId : mapRCIIdToAccountInfo.keyset()){
            
            if(!mapRCIIdToAccountInfo.get(rcId).isEmpty()){
                
                RCI_Only__c objRCI = filteredRCI.get(rcId);
                
                DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = recordTypeId_RC,
                                                      Referring_Case_Number__c = objRCI.Case_Number__c ,
                                                      ITF_Has_Claimant_Filed_Wage_Claim__c  = objRCI.Employer_Has_Additional_Claims__c,
                                                      Additional_Case_Number__c  = objRCI.Additional_Case_Number__c,
                                                      Threat_Next_Scheduled_Meeting__c  = objRCI.Threat_Next_Scheduled_Meeting__c,
                                                      Threat_Next_Scheduled_Meeting_Date__c  = objRCI.Threat_Next_Scheduled_Meeting_Date__c,
                                                      Threat_Next_Scheduled_Meeting_Date_2__c  = objRCI.Threat_Next_Scheduled_Meeting_Date_2__c);
                
                if(mapRCIIdToAccountInfo.get(rcId).containsKey('Case Employer')){
                    objCase.Employer__c = mapRCIIdToAccountInfo.get(rcId).get('Case Employer').Id;
                }
                
                if(mapRCIIdToAccountInfo.get(rcId).containsKey('Primary Witness')){
                    objCase.Claimant__c = mapRCIIdToAccountInfo.get(rcId).get('Primary Witness').Id;
                    
                }
                
                if(mapRCIIdToAccountInfo.get(rcId).containsKey('Advocate')){
                    
                    mapRCIIdToCaseRole.put(rcId, new Case_Role__c(Entity__c = mapRCIIdToAccountInfo.get(rcId).get('Advocate').Id,
                                                                  RecordTypeId = recordTypeId_CR,
                                                                  Case_Role_Status__c = 'Active',
                                                                  Role__c = 'Advocate'));
                    
                }
                
                mapRCIToCase.put(rcId,objCase);
                
            }
        }
        
        insert mapRCIToCase.values();
        
        for(String rcId : mapRCIToCase.keyset()){
            
            lstRCIToUpdate.add(new RCI_Only__c(Id = rcId, Case_Management__c = mapRCIToCase.get(rcId).Id));
            
            if(mapRCIIdToCaseRole.containsKey(rcId)){
                
                mapRCIIdToCaseRole.get(rcId).Case__c = mapRCIToCase.get(rcId).Id;
            }
        }
        
        insert mapRCIIdToCaseRole.values();
        update lstRCIToUpdate;
    }
}