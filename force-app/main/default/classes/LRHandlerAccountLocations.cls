public without sharing class LRHandlerAccountLocations {
    private static LRHandlerAccountLocations  classInstance = null;
    private LRHandlerAccountLocations () {
        
    }

    public static LRHandlerAccountLocations  getInstance(){
        if (null == classInstance) {
            classInstance = new LRHandlerAccountLocations ();
        }
        return classInstance;
    }
    
    //Method creates "real" accounts and locations from the cache records when the registration is approved or closed
    public static void CreateAccountsAndLocations(list<License_Registration__c> newList/*, map<id, License_Registration__c> oldMap*/) {
        Logger.push('CreateAccountsAndLocations','LicenseRegistrationAllHandler');
        Logger.debug('######## Entering CreateAccountsAndLocations Method');
        
        /* 
        for(License_Registration__c l: newList) {
            License_Registration__c oldLicenseRegistration = oldMap.get(l.ID);
            if((oldLicenseRegistration.Status__c != 'Approved' && l.Status__c == 'Approved') || 
            (!(oldLicenseRegistration.Status__c).contains('Closed') && (l.Status__c).contains('Closed')) ||
            (oldLicenseRegistration.Status__c != 'Renewed' && l.Status__c == 'Renewed'))
                LicenseRegistrationIds.add(l.Id);
        }
        */
        if(!newList.isEmpty()) {     
            Map<Id, License_Registration__c> lrMap = new Map<Id, License_Registration__c>([SELECT Id, Account__c, Applicant__r.AccountId, Company_Type__c FROM License_Registration__c WHERE ID IN: newList]);
            
            //get all registration accounts for the registration that do not already have accounts
            List<Registration_Account__c> allRegistrationAccount = [SELECT Id, Name, RecordTypeId, RecordType.Name, I_Am_this_Manager__c,
            Account__c, Business_Phone__c, Corp_or_LLC_ID__c, Corp_or_LLC_Name__c, Date_Formed__c, First_Name__c, 
            Foreign_Address__c, Good_standing_with_CA_Secretary_of_State__c, Last_Name__c, Legal_Entity_Name__c, 
            Email_Address__c, Mailing_Address_Same_as_Physical__c, Mailing_City__c, Mailing_State__c, Mailing_Street__c,
            Mailing_Zip_Code__c, Mobile_Phone__c, Not_in_good_standing_explanation__c,  Registration__c, isPerson__c, 
            SSN__c, State_of_Incorporation__c, Title__c, Daytime_Phone_Ext__c, Driver_s_License__c, Driver_s_License_State__c,
            State_Employer_Identification_Number_c__c, Physical_Business_Street__c, Physical_Business_Line_2__c,
            Physical_Business_City__c, Physical_Business_Country__c, Physical_Business_Zip_Code__c, Physical_Business_State__c,
            Mailing_Country__c, Mailing_Address_Line_2__c, Middle_Name__c, Residential_Street__c, Residential_City__c,
            Residential_State__c, Residential_Zip_Code__c, Residential_Country__c, Residential_Address_Line_2__c, Federal_Employer_Identification_Number__c,
            Registration__r.Sole_prop_for_myself__c, Registration__r.Applicant__r.AccountId, Registration__r.Account__c, DBA__c                                                    
            FROM Registration_Account__c 
            WHERE Registration__c IN :newList /*AND Account__c = NULL*/];
            Logger.debug('##### registration accounts that need accounts created::: ' + allRegistrationAccount);
            
            //get all registration locations for the registration that do not have locations already
            List<Registration_Location__c> allRegistrationLocation = [SELECT Id, Name, Account__c, Address__c, City__c, 
            DBA_Name__c, FBNS__c, Foreign_Address__c, Latitude__c, Location__c, Longitude__c, Mobile_Business__c, 
            Phone__c, Registration__c, State__c, Zip_Code__c, Address_Line_2__c, Phone_Extension__c, Registration__r.Account__c 
            FROM Registration_Location__c 
            WHERE Registration__c IN :newList AND Location__c = NULL];
            Logger.debug('##### Registration locations that need locations created::: ' + allRegistrationLocation);
            
            // get all ownership records for the registration that do not have owner records already
            List<Ownership__c> allOwnership = [SELECT Id, Name, I_am_this_owner__c, Company__c, Driver_s_License__c, Driver_s_License_State__c, Daytime_Phone__c, Daytime_Phone_Ext__c, 
            Email__c, First_Name__c, Joint_Venture_Company__c, Last_Name__c, Mailing_Street__c, Mailing_Address_Line_2__c, Mailing_Address_Line_3__c, 
            Mailing_Address_Same_as_Residential__c, Mailing_City__c, Mailing_Country__c, Mailing_Zip_Code__c, Mailing_State__c, Middle_Name__c, Owner__c,
            Ownership_Percentage__c, Registration__c, Street__c, Residential_Address_Line_2__c, Residential_Address_Line_3__c, City__c,
            Residential_Country__c, Residential_Zip_Code__c, State__c, Re_type_SSN__c, SSN__c, Title__c
            FROM Ownership__c 
            WHERE Registration__c IN :newList AND Owner__c = NULL];
            Logger.debug('##### Ownership that need accounts created::: ' + allOwnership);
            
            // get record type ids
            Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            Id solePropRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Sole Proprietorship').getRecordTypeId();
            
            // Create Accounts
            //List<Account> AccountsToInsert = new List<Account>();
            Map<Id, Account> AccountsToInsert = new Map<Id, Account>();
            // Create DBAs
            Map<Integer,DBA__c> dbasToInsert = new Map<Integer,DBA__c>();
            // dbas to update
            map<Integer, DBA__c> dbasToUpdate = new Map<Integer,DBA__c>();
            //applicant account list to set registration on
            list<Account> spAccountToUpdate = new list<account>();
            //Registration accounts to update
            list<Registration_Account__c> raToUpdate = new list<Registration_Account__c>();
            
            //iterate over reg accounts
            Integer index = 0;
            Logger.debug('##### Creating accounts and dbas as needed');
            for(Registration_Account__c ra: allRegistrationAccount) {
                Logger.debug('##### RA being worked on: ' + ra);
                Logger.debug('##### Checking to see if DBA is needed - RA: ' + ra.Id + ' , sole prop: ' 
                + ra.Registration__r.Sole_prop_for_myself__c + ' , RT: ' + ra.RecordTypeID + ' , sole prop rt: ' + solePropRecordTypeId );    
                // new dba is needed
                if(ra.Registration__r.Sole_prop_for_myself__c == 'Yes' && ra.RecordTypeID == solePropRecordTypeId && ra.Account__c != NULL){
                    Logger.debug('##### working on sole prop reg account to see if DBA is needed: ' + ra.Id);
                    
                    DBA__c dba = new DBA__c();
                    // create dba for sole prop
                    if(ra.DBA__c == null){   
                        dba.name = ra.Legal_Entity_Name__c;
                        dba.Account__c = ra.Registration__r.Account__c;
                        dba.Registration__c = ra.Registration__c;
                        dba.Active__c = 'Yes';
                        Logger.debug('##### staging new dba:: ' + dba);
                        dbasToInsert.put(index,dba);
                        index = index + 1; 
                        
                    }
                    // if the DBA is already set, update the registration to show the new registration replacing the original
                    else{
                        Logger.debug('##### Dba is already set on RA ' + ra.Id + ' staging the update of the registration on the DBA');
                        dba.Registration__c = ra.Registration__c;
                        dbasToUpdate.put(index,dba);
                    }
                    // Update the registration the account is tied to. Replace the original.
                    // for sole props, there is no need to set the registration on the account. DBAs serve as the business.
                    /*
                Account a = new Account();
                Logger.debug('##### Staging update of registration for account ' + a.Id);
                a.Id = ra.Account__c;
                a.Registration__c = ra.Registration__c;
                spAccountToUpdate.Add(a);
                    */
                }
                
                /*
                //update account setting registration
                account a = new account();
                a.Id = ra.Registration__r.Account__c;
                //a.Registration__c = ra.Registration__c;
Logger.debug('##### adding spAccountToUpdate:: ' + a);
spAccountToUpdate.add(a);
*/
                
                // create person accounts for all management and agent records
                //             Else{  
                Logger.debug('##### RA is NOT applicant and sole prop business');                       
                if(ra.I_Am_this_Manager__c == 'Yes')
                {
                    System.Debug('######## rlrMap.get(ra.Registration__c): ' + lrMap.get(ra.Registration__c));
                    System.Debug('########  ra.Registration__c: ' + ra.Registration__c);
                    if(lrMap.ContainsKey(ra.Registration__c)){
                        //for(License_Registration__c lr2 : allLicReg){
                            ra.Account__c = lrMap.get(ra.Registration__c).Applicant__r.AccountId;
                            //                                raToUpdate.add(ra);
                            System.debug('##### staging new raToUpdate:: ' + raToUpdate);
                            raToUpdate.add(ra);
                        //}
                    }                
                }
                Else{
                    Account newAccount = new Account();
                    Logger.debug('##### Account populated on this RA - RA: ' + ra.Id + ' Account: ' + ra.Account__c);
                    // if account is set, update the registration on the account to the new one.
//                    if(ra.Account__c != NULL){                       
                        // if this is a business RA, set the registration on the account
//                        If(!ra.IsPerson__c){
//                            Logger.debug('##### account is set on ra: ' + ra.Name + ' Updating registration on account');
//                            newAccount.Id = ra.Account__c;
//                            newAccount.Registration__c = ra.Registration__c;
//                            spAccountToUpdate.Add(newAccount); 
//                        }
                        
//                    }
                    
                    // account is not set, so create
                    if( ra.Account__c == NULL){
                        Logger.debug('##### No account is set on RA. Creating and setting');
                        if(ra.isPerson__c ) {
                            if(ra.RecordTypeID == solePropRecordTypeId){
                                newAccount.RecordTypeId = personRecordTypeId;
                                newAccount.LastName = ra.Legal_Entity_Name__c;                          
                            }else{
                                newAccount.RecordTypeId = personRecordTypeId;
                                newAccount.FirstName = ra.First_Name__c;
                                newAccount.LastName = ra.Last_Name__c;
                                newAccount.MiddleName = ra.Middle_Name__c;
                                newAccount.SSN__pc = ra.SSN__c;
                                newAccount.PersonMobilePhone = ra.Mobile_Phone__c;
                                newAccount.Registration__c = ra.Registration__c;
                                newAccount.PersonMailingStreet = ra.Residential_Street__c + ' ' + ra.Residential_Address_Line_2__c;
                                newAccount.PersonMailingCity = ra.Residential_City__c;
                                newAccount.PersonMailingState = ra.Residential_State__c;
                                newAccount.PersonMailingCountry = ra.Residential_Country__c;
                                newAccount.PersonMailingPostalCode = ra.Residential_Zip_Code__c;
                                
                                newAccount.PersonTitle = ra.Title__c;
                            }
                        }       
                        // create business account for the actual business
                        if(!ra.isPerson__c ) {
                            Logger.debug('##### ra is Business. Creating business account for ' + ra.Id + ' ' +ra.Name);
                            newAccount.Name = ra.Legal_Entity_Name__c;
                            newAccount.RecordTypeId = businessRecordTypeId;
                            
                        }
                        newAccount.Type_of_Business__c = ra.RecordType.Name;
                        newAccount.Corp_or_LLC_ID__c = ra.Corp_or_LLC_ID__c;
                        newAccount.Corp_or_LLC_Name__c = ra.Corp_or_LLC_Name__c;
                        newAccount.Phone = ra.Business_Phone__c;
                        newAccount.Registration_Account__c = ra.Id;
                        newAccount.Registration__c = ra.Registration__c;
                        newAccount.Date_Formed__c = ra.Date_Formed__c;
                        newAccount.Foreign_Address__c = ra.Foreign_Address__c;
                        newAccount.Email__c = ra.Email_Address__c;
                        newAccount.Good_standing_with_CA_Secretary_of_State__c = ra.Good_standing_with_CA_Secretary_of_State__c;
                        newAccount.Legal_Entity_Name__c = ra.Legal_Entity_Name__c;
                        newAccount.Not_in_good_standing_explanation__c = ra.Not_in_good_standing_explanation__c;
                        newAccount.ShippingCity = ra.Physical_Business_City__c;
                        newAccount.ShippingCountry = ra.Physical_Business_Country__c;
                        newAccount.ShippingState = ra.Physical_Business_State__c;
                        newAccount.ShippingStreet = ra.Physical_Business_Street__c;
                        newAccount.ShippingStreet += ra.Physical_Business_Line_2__c == null ? ' ' : ra.Physical_Business_Line_2__c;
                        newAccount.ShippingPostalCode = ra.Physical_Business_Zip_Code__c;
                        newAccount.Federal_Employer_Identification_Number__c = ra.Federal_Employer_Identification_Number__c;
                        
                        newAccount.Primary_City_Placeholder__c = ra.Physical_Business_City__c;
                        newAccount.Primary_State_Placeholder__c = ra.Physical_Business_State__c;
                        newAccount.Primary_Street_Placeholder__c = ra.Physical_Business_Street__c;
                        newAccount.Primary_Zip_Placeholder__c = ra.Physical_Business_Zip_Code__c;
                        newAccount.State_of_Incorporation__c = ra.State_of_Incorporation__c;
                        
                        newAccount.Phone_Ext__c = ra.Daytime_Phone_Ext__c;
                        newAccount.Driver_s_License__c = ra.Driver_s_License__c;
                        newAccount.Driver_s_License_State__c = ra.Driver_s_License_State__c;
                        newAccount.State_Employer_Identification_Number__c = ra.State_Employer_Identification_Number_c__c;
                        newAccount.Physical_Business_Address_Line_1__c = ra.Physical_Business_Street__c;
                        newAccount.Physical_Business_Address_Line_2__c = ra.Physical_Business_Line_2__c;
                        newAccount.Physical_Business_City_Province__c = ra.Physical_Business_City__c;
                        newAccount.Physical_Business_Country__c = ra.Physical_Business_Country__c;
                        newAccount.Physical_Business_Postal_Code__c = ra.Physical_Business_Zip_Code__c;
                        newAccount.Physical_Business_State__c = ra.Physical_Business_State__c;
                        //AccountsToInsert.add(newAccount);
                        AccountsToInsert.put(ra.Id, newAccount);
                        Logger.debug('######## Added the account to insert: ' + newAccount);
                    }    
                    
                }
                
            }
            
            if(AccountsToInsert.size() > 0) {
                Logger.debug('##### inserting accounts: ' + AccountsToInsert);
                //insert AccountsToInsert;
                insert AccountsToInsert.values();
                //System.debug('##### Inserted Account : ' + AccountsToInsert[0].Id);
            }
            
            if(dbasToInsert.size() > 0){
                Logger.debug('##### inserting dbas: ' + dbasToInsert);
                insert dbasToInsert.values();
                Integer i = 0;
                for(Registration_Account__c ra: allRegistrationAccount) {
                    if(ra.Registration__r.Sole_prop_for_myself__c == 'Yes' && ra.RecordTypeID == solePropRecordTypeId && ra.DBA__c == null){
                        if(dbasToInsert.containsKey(i)){
                            Logger.debug('##### Setting DBA on reg account ' + ra.Id);
                            Registration_Account__c regAcct = new Registration_Account__c();
                            regAcct.Id = ra.Id;
                            regAcct.Dba__c = dbasToInsert.get(i).Id;
                            raToUpdate.add(regAcct);
                        }
                        i = i + 1;
                    }
                }
            }
            
            // add dbas to update code
            if(dbasToUpdate.size() > 0){
                Logger.debug('##### Updating DBAs: ' + dbasToUpdate);
                update dbasToUpdate.values();                
            }
            
            if(spAccountToUpdate.size() > 0){
                Logger.debug('##### updating sp accounts' + spAccountToUpdate);
                update spAccountToUpdate;
            }
            
            if(raToUpdate.size() > 0){
                Logger.debug('##### Updating Reg account ' + raToUpdate);
                update raToUpdate;
            }
            
            // Set the account on the registration for business accounts. For Sole props, this is skipped because the SP is already the account on the reg.             
            // replace the query with interation over AccountsToInsert
            //List<Account> BusinessAccounts = [SELECT Id, Registration__c FROM Account WHERE RecordTypeId =: businessRecordTypeId AND Registration__c IN: LicenseRegistrationIds];
            //Logger.debug('##### list of business accounts: ' + BusinessAccounts);
            Logger.debug('##### Preparing to update account on registration');
            Map<Id, Id> BusinessAccountsMap = new Map<Id, Id>();
            List<License_Registration__c> lregtoUpdate = new List<License_Registration__c>();
            //for(Account ba: BusinessAccounts) {
//            for(Account ba : AccountsToInsert){
            for(id ba : AccountsToInsert.keySet()){
                Logger.debug('##### Looping over inserted accounts. Current record: ' + AccountsToInsert.get(ba).Id);
                if(!BusinessAccountsMap.containsKey(AccountsToInsert.get(ba).Registration__c)){
                    BusinessAccountsMap.put(AccountsToInsert.get(ba).Registration__c, AccountsToInsert.get(ba).Id);
                    Logger.debug('##### put registration and business in map');
                }
//                if(lrMap.containsKey(ba.Registration__c)){
                if(lrMap.containsKey(AccountsToInsert.get(ba).Registration__c)){
                    Logger.debug('##### registration already set on business account');
                    // insert new logic here to only set the account on registration if the inserted account is a business account
//                    if(ba.RecordTypeID == businessRecordTypeID){
                    if(AccountsToInsert.get(ba).RecordTypeID == businessRecordTypeID){
                        Logger.debug('##### Inserted account is the business account. Setting the account on the registration');
                        License_Registration__c lreg = lrMap.get(AccountsToInsert.get(ba).Registration__c);
                        lreg.Account__c = AccountsToInsert.get(ba).Id;
                        lregtoUpdate.add(lreg); 
                    }
                    
                }
            }
            Logger.debug('BusinessAccountsMap ====> ' + BusinessAccountsMap);
            Logger.debug('##### lregtoUpdate: ' + lregtoUpdate);
            
            // Create Person Accounts for owners, but not if the applicant is the owner or manager
            List<Account> PersonAccountsToInsert = new List<Account>();
            Logger.debug('##### Creating Person Accounts from Ownership #####');
            for(Ownership__c o: allOwnership) {
                if(o.I_am_this_owner__c == 'No'){
                    //if(BusinessAccountsMap.containsKey(o.Registration__c)) {
                    Account newPersonAccount = new Account();
                    newPersonAccount.RecordTypeId = personRecordTypeId;
                    //newPersonAccount.Company__c = BusinessAccountsMap.get(o.Registration__c);//rl.Account__c;
                    newPersonAccount.Driver_s_License__c = o.Driver_s_License__c;
                    newPersonAccount.Driver_s_License_State__c = o.Driver_s_License_State__c;
                    newPersonAccount.PersonEmail = o.Email__c; 
                    newPersonAccount.FirstName = o.First_Name__c;
                    newPersonAccount.LastName = o.Last_Name__c;
                    newPersonAccount.PersonMailingStreet = o.Mailing_Street__c;
                    newPersonAccount.PersonMailingStreet += o.Mailing_Address_Line_2__c == null ? ' ' : o.Mailing_Address_Line_2__c;
                    newPersonAccount.PersonMailingCity = o.Mailing_City__c;
                    newPersonAccount.PersonMailingCountry = o.Mailing_Country__c;
                    newPersonAccount.PersonMailingPostalCode = o.Mailing_Zip_Code__c;
                    newPersonAccount.PersonMailingState = o.Mailing_State__c;
                    newPersonAccount.MiddleName = o.Middle_Name__c;
                    newPersonAccount.Registration__c = o.Registration__c;
                    newPersonAccount.PersonOtherStreet = o.Street__c;
                    newPersonAccount.PersonOtherStreet += o.Residential_Address_Line_2__c == null ? ' ' : o.Residential_Address_Line_2__c;
                    newPersonAccount.PersonOtherCity = o.City__c;
                    newPersonAccount.PersonOtherCountry = o.Residential_Country__c;
                    newPersonAccount.PersonOtherPostalCode = o.Residential_Zip_Code__c;
                    newPersonAccount.PersonOtherState = o.State__c;
                    newPersonAccount.SSN__pc = o.SSN__c;
                    newPersonAccount.PersonTitle = o.Title__c;
                    newPersonAccount.Ownership__c = o.Id;
                    newPersonAccount.Phone = o.Daytime_Phone__c;
                    newPersonAccount.Phone_Ext__c = o.Daytime_Phone_Ext__c;
                    PersonAccountsToInsert.add(newPersonAccount);
                    Logger.debug('##### will create person account from ownership: ' + newPersonAccount);
                    //}
                }
            }
            if(PersonAccountsToInsert.size() > 0) {
                insert PersonAccountsToInsert;
            }
            
            Logger.debug('##### updating reg accounts to set the account.');
            //List<Account> AccountsToUpdate = [SELECT Id, Registration_Account__c FROM Account WHERE Id IN: AccountsToInsert];
            //System.debug('##### AccountsToUpdate list: ' + AccountsToUpdate); 
            Map<Id, Id> AccountMap = new Map<Id, Id>();
            //            for(Account a: AccountsToInsert)
            for(Id a: AccountsToInsert.keySet())
                if(!AccountMap.containsKey(AccountsToInsert.get(a).Registration_Account__c)){
                    Logger.debug('##### adding to accountMap: ' + AccountsToInsert.get(a).Registration_Account__c + ' ' + AccountsToInsert.get(a).Id);
                    AccountMap.put(AccountsToInsert.get(a).Registration_Account__c, AccountsToInsert.get(a).Id);
                }
            
            List<Registration_Account__c> raUpdate = new List<Registration_Account__c>();
            for(Registration_Account__c ra: allRegistrationAccount) {
                if(AccountMap.containsKey(ra.Id)) {
                    ra.Account__c = AccountMap.get(ra.Id);
                    raUpdate.add(ra);
                }
            }
            if(raUpdate.size() > 0)
                update raUpdate;
            
            Logger.debug('##### Updating ownership to set the account');
            List<Account> PersonAccountsToUpdate = [SELECT Id, PersonContactId, Registration_Account__c, Ownership__c FROM Account WHERE Id IN:PersonAccountsToInsert];
            //System.debug('##### PersonAccounts related to ownership records: ' + PersonAccountsToUpdate);
            Map<Id, Id> PersonAccountMap = new Map<Id, Id>();
            for(Account pa: PersonAccountsToUpdate) {
                //for(Account pa: PersonAccountsToInsert) {
                Logger.debug('##### Iterating over accounts to set ownership. Account: ' + pa.Id + ' PersonContactID for account: ' +pa.PersonContactId);
                if(!PersonAccountMap.containsKey(pa.Registration_Account__c))
                    PersonAccountMap.put(pa.Registration_Account__c, pa.Id);
                if(!PersonAccountMap.containsKey(pa.Ownership__c))
                    PersonAccountMap.put(pa.Ownership__c, pa.PersonContactId);
            }
            Logger.debug('##### PersonAccountMap: ' + PersonAccountMap);
            List<Ownership__c> oUpdate = new List<Ownership__c>();
            for(Ownership__c o: allOwnership) {
                if(PersonAccountMap.containsKey(o.Id)) {
                    if(o.I_am_this_owner__c == 'No'){
                        Logger.debug('##### Setting account on ownership, No: ' + o.Id + ' to: ' + PersonAccountMap.get(o.Id));
                        o.Owner__c = PersonAccountMap.get(o.Id);
                        //oUpdate.add(o);
                    }
                }               
                if(o.I_am_this_owner__c == 'Yes'){
                    if(lrMap.containsKey(o.Registration__c)){
                        Logger.debug('##### Setting account on ownership, Yes: ' + o.Id + ' to: ' + lrMap.get(o.Registration__c));                                                                                     
                        // for(id lr2: lrMap) {
                        o.Owner__c = lrMap.get(o.Registration__c).Applicant__c;
                        //}
                        //o.Owner__c = lreg;
                    }
                }
                oUpdate.add(o);
            }
            
            if(oUpdate.size() > 0)
                update oUpdate;
            
            // Last, but not least, update the registration for sole props.
            //            for(License_Registration__c lr2: allreg) {
            for(id lr2 : lrMap.keySet()){
                if(lrMap.get(lr2).Company_Type__c == 'Sole Proprietorship'){
                    
                    //set the registration's account to the sole prop person account
                    // get the ra with the sole prop record type, match that to the real account, then use that id to attach to the registration
                    
                    for(Registration_Account__c regAccounts:allRegistrationAccount){
                        System.debug('##### regAccounts: ' + regAccounts);
                        if(AccountsToInsert.containsKey(regAccounts.Id)){
                            if(regAccounts.RecordTypeId == '012t00000008WSz'){
                                lrMap.get(lr2).Account__c = AccountsToInsert.get(regAccounts.Id).id;
                                lregtoUpdate.add(lrMap.get(lr2));
                            }
                        }     
                    }  
                }
            }
            
            // SR-004949 - creating addresses and assign Accounts last since Entity__c is not reparentable
            Id licenseAccount = null;
            
            if(lregtoUpdate.size() > 0){
                licenseAccount = lregtoUpdate[0].Account__c;
            }
            
            // Create Locations
            List<Address__c> LocationsToInsert = new List<Address__c>();
            Logger.debug('##### Creating Locations #####');
            for(Registration_Location__c rl: allRegistrationLocation) {
                //if(BusinessAccountsMap.containsKey(rl.Registration__c)) {
                If(rl.Location__c == NULL){
                    Address__c newLocation = new Address__c();
                    // newLocation.Entity__c = BusinessAccountsMap.get(rl.Registration__c);//rl.Account__c;
                    if( licenseAccount != null){
                        newLocation.Entity__c = licenseAccount;
                    }
                    else{
                        newLocation.Entity__c = rl.Registration__r.Account__c;
                    }
                    newLocation.Address__c = rl.Address__c;
                    newLocation.City__c = rl.City__c;
                    newLocation.DBA__c = rl.DBA_Name__c;
                    newLocation.FBNS__c = rl.FBNS__c;
                    newLocation.Foreign_Address__c = rl.Foreign_Address__c;
                    newLocation.Latitude__c = rl.Latitude__c;
                    newLocation.Registration_Location__c = rl.Id;
                    newLocation.Longitude__c = rl.Longitude__c;
                    newLocation.Mobile_Business__c = rl.Mobile_Business__c;
                    newLocation.State__c = rl.State__c;
                    newLocation.Zip_Code__c = rl.Zip_Code__c;
                    newLocation.Address_2__c = rl.Address_Line_2__c;
                    newLocation.Phone_Extension__c = rl.Phone_Extension__c;
                    LocationsToInsert.add(newLocation);
                    Logger.debug('##### will insert location: ' + newLocation);
                }
            }
            
            if(LocationsToInsert.size() > 0) {
                insert LocationsToInsert;
            }
            
            //List<Address__c> LocationsToUpdate = [SELECT Id, Registration_Location__c FROM Address__c WHERE Id IN: LocationsToInsert];
            Map<Id, Id> LocationsMap = new Map<Id, Id>();
            Logger.debug('##### preparing to update registration locations with the location ID'); 
            //for(Address__c a: LocationsToUpdate ){
            for(Address__c a: LocationsToInsert ){
                if(!LocationsMap.containsKey(a.Registration_Location__c)){
                    LocationsMap.put(a.Registration_Location__c, a.Id);
                    Logger.debug('##### Added to LocationsMap: ' + a.Registration_Location__c + ' , ' + a.Id);
                }
                
            }
            
            
            List<Registration_Location__c> rlUpdate = new List<Registration_Location__c>();
            for(Registration_Location__c rl: allRegistrationLocation) {
                if(LocationsMap.containsKey(rl.Id)) {
                    rl.Location__c = LocationsMap.get(rl.Id);
                    Logger.debug('##### Updating registration location: ' + rl.Id + ' setting location to ' + LocationsMap.get(rl.Id));
                    rlUpdate.add(rl);
                }
            }
            if(rlUpdate.size() > 0)
            update rlUpdate;
            
            if(lregtoUpdate.size() > 0) {
                Set<License_Registration__c> regSet = new Set<License_Registration__c>();
                regSet.addAll(lregtoUpdate);
                lregtoUpdate.clear();
                lregtoUpdate.addAll(regSet);
                update lregtoUpdate;
            }
        }
        Logger.debug('##### Finished creating accounts and locations from registration accounts, ownership and registration locations');
        Logger.pop();
    }
    
}