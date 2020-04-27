global class ProcessImportRecords implements Database.Batchable<sObject>, Database.Stateful
{
    global String caseId {get; set;}
    global List<String> errorMessages {get; set;}
    global List<recordWrapper> failedDMLRecords {get; set;}

    public ProcessImportRecords()
    {
        errorMessages = new List<String>();
        failedDMLRecords = new List<recordWrapper>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(
            [
                SELECT Name, Case_Management__c, Deductions_Federal_Withholding__c, Deductions_Medicare__c, Deductions_Social_Security__c, Deductions_State_Disability_Insurance__c, Deductions_State_Withholding__c, Deductions_Total__c, Employee_City__c, Employee_First_Name__c, Employee_Last_Name__c, Employee_State__c, Employee_Street__c, Employee_Zip__c, Factor__c, Gross_Wages_Paid__c, Net_Wages_Paid__c, Period_Covered_by_Adjustment__c, SSN__c, Total_Wage_Assessment__c 
                FROM Import__c
                WHERE Case_Management__c = :caseId
            ]
        );
    }
     
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //Iterate through every line and create an Account and Payee record for each row
        List<Account> accsToUpload = new List<Account>();
        List<Payee__c> payeesToUpload = new List<Payee__c>(); 
        List<recordWrapper> accPayeeList = new List<recordWrapper>();
        Map<String, recordWrapper> accPayeeMap = new Map<String, recordWrapper>();

        try
        {   
            for(sObject line : scope)
            {
                Import__c record = (Import__c)line;
                Account acct = new Account();                    
                
                acct.FirstName = record.Employee_First_Name__c;
                acct.LastName = record.Employee_Last_Name__c;                   
                acct.ShippingStreet = record.Employee_Street__c;
                acct.ShippingCity = record.Employee_City__c;
                acct.ShippingState = record.Employee_State__c;
                acct.ShippingPostalCode = record.Employee_Zip__c;
                acct.SSN__pc = record.SSN__c;
                    
                accsToUpload.add(acct);

                recordWrapper accPayee = new recordWrapper();

                accPayee.key = acct.LastName + 
                            ',' + acct.FirstName +
                            ',' + record.Employee_Street__c +
                            ',' + record.Employee_Zip__c;

                accPayee.firstname = record.Employee_First_Name__c;
                accPayee.lastName = record.Employee_Last_Name__c;
                accPayee.shippingStreet = record.Employee_Street__c;
                accPayee.shippingCity = record.Employee_City__c;
                accPayee.shippingState = record.Employee_State__c;
                accPayee.shippingPostalCode = record.Employee_Zip__c;
                accPayee.SSN = record.SSN__c;
                accPayee.periodCovered = record.Period_Covered_by_Adjustment__c;
                accPayee.wageAsssesment = String.valueOf(record.Total_Wage_Assessment__c);
                accPayee.grossWages = String.valueOf(record.Gross_Wages_Paid__c);
                accPayee.disabilityInsurance = String.valueOf(record.Deductions_State_Disability_Insurance__c);
                accPayee.socialSecurity = String.valueOf(record.Deductions_Social_Security__c);
                accPayee.medicare = String.valueOf(record.Deductions_Medicare__c);
                accPayee.stateWitholding = String.valueOf(record.Deductions_State_Withholding__c);
                accPayee.federalWitholding = String.valueOf(record.Deductions_Federal_Withholding__c);
                accPayee.totalDeductions = String.valueOf(record.Deductions_Total__c);
                accPayee.netWages = String.valueOf(record.Net_Wages_Paid__c);
                accPayee.factor = String.valueOf(record.Factor__c);
                accPayee.caseManagment = caseId;

                accPayeeList.add(accPayee);
                accPayeeMap.put(accPayee.key,accPayee);                
            }
         }
         catch(Exception e)
         {
             errorMessages.add('An error has occured processing the file: ' + e.getMessage());
         } 

        Map<String, Account> matchAccountMap = new Map<String,Account>();
        
        for(Account acc : accsToUpload){
            String nameAddressKey = (acc.LastName == null ? '' : acc.LastName) + 
                                ',' + (acc.FirstName == null ? '' : acc.FirstName) +
                                ',' + (acc.ShippingStreet == null ? '' : acc.ShippingStreet) +
                                ',' + (acc.ShippingPostalCode == null ? '' : acc.ShippingPostalCode);
            system.debug('**** nameAddressKey::: ' + nameAddressKey);

            matchAccountMap.put(nameAddressKey, acc);
        }
  
        try{
            //Find all accounts that match.
            List<Account> accountList = [SELECT SSN__pc, ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, LastName, FirstName, id, AccountMatch__c FROM Account WHERE AccountMatch__c IN :matchAccountMap.keySet()];

            //find any duplicate accounts in database            
            Map<String, Account> duplicateAccountMap = new Map<String, Account>();
            List<Account> duplicateAccountList = new List<Account>();
            for(Account acc : accountList)
            {
                if(duplicateAccountMap.get(acc.AccountMatch__c) == null)
                {
                    duplicateAccountMap.put(acc.AccountMatch__c, acc);
                }
                else
                {
                    duplicateAccountList.add(acc);
                    errorMessages.add('Duplicate account match for: ' + acc.AccountMatch__c);
                }
            }

            //remove those csv lines that have the same info with the duplicate accounts. 
            for(Account acc : duplicateAccountList)
            {
                if(matchAccountMap.get(acc.AccountMatch__c) != null)
                {
                    matchAccountMap.remove(acc.AccountMatch__c);

                    //add a record in the failedDMLRecords so in the end we won't delete the Import__c record containing that information.
                    setWrapperInfo(acc, 'Existing duplicate account.');                    
                }
            }

            Set<String> updatedAccounts = new Set<String>();
            
            //Update existing accounts
            for(Account acc : accountList)
            {
                if(matchAccountMap.get(acc.AccountMatch__c) != null)
                { 
                    Account existingAcc = matchAccountMap.get(acc.AccountMatch__c);

                    acc.SSN__pc = existingAcc.SSN__pc;

                    updatedAccounts.add(acc.AccountMatch__c);
                }
            }

            List<Database.SaveResult> updateResults = Database.Update(accountList, false);

            for(Integer i = 0; i < updateResults.size(); i++)
            {                
                // DML operation failed
                if(!updateResults.get(i).isSuccess())
                {
                    Database.Error error = updateResults.get(i).getErrors().get(0);

                    setWrapperInfo(accountList.get(i), error.getMessage());
                }
            }
            
            Id personAccRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            //[SELECT Name, SobjectType,IsPersonType FROM RecordType WHERE SobjectType='Account' AND Name ='PersonAccount' AND IsPersonType=True].id

            //Remove updated accounts from list to create
            for(String ua : updatedAccounts){
                matchAccountMap.remove(ua);
            }

            //Create new accounts
            List<Account> accountsToCreate = new List<Account>();
            for(String mam : matchAccountMap.keySet()){
                Account acc = matchAccountMap.get(mam);

                acc.recordTypeID = personAccRTID;
                acc.Imported_From__c = 'Form40';

                accountsToCreate.add(acc);
            }

            List<Database.SaveResult> insertResults = Database.Insert(accountsToCreate, false);

            for(Integer i = 0; i < insertResults.size(); i++)
            {                
                // DML operation failed
                if(!insertResults.get(i).isSuccess())
                {
                    Database.Error error = insertResults.get(i).getErrors().get(0);

                    setWrapperInfo(accountsToCreate.get(i), error.getMessage()); 

                }
            }

            List<Account> newAccountList = [SELECT id, name, AccountMatch__c FROM Account WHERE id IN :accountsToCreate OR id IN :accountList];
            
            List<Case_Role__c> createCaseRoleList = new List<Case_Role__c>();
            
            //Insert new case roles.
            for(Account acc : newAccountList){

                Case_Role__c cRole = new Case_Role__c();
                cRole.Account_Name__c = acc.Name;
                cRole.Case__c = caseId;
                cRole.Role__c = 'Payee - Employee';
                cRole.Entity__c = acc.Id;
            
                createCaseRoleList.add(cRole);
            }

            List<Database.SaveResult> insertCaseRoleResults = Database.Insert(createCaseRoleList, false);

            for(Integer i = 0; i < insertCaseRoleResults.size(); i++)
            {                
                // DML operation failed
                if(!insertCaseRoleResults.get(i).isSuccess())
                {
                    Account dummyAccount = new Account();

                    //get the account that the case role is linked to. 
                    for(Account acc : newAccountList)
                    {
                        if(acc.Id == createCaseRoleList.get(i).Entity__c)
                        {
                            dummyAccount = acc;
                            break;
                        }
                    }

                    Database.Error error = insertCaseRoleResults.get(i).getErrors().get(0);

                    setWrapperInfo(dummyAccount, error.getMessage()); 
                }
            }

            List<Case_Role__c> caseRoleList = [SELECT id, name, Entity__r.SSN__pc, Entity__r.ShippingPostalCode, Entity__r.ShippingState, Entity__r.ShippingCity, Entity__r.ShippingStreet, Entity__r.LastName, Entity__r.FirstName, Entity__r.AccountMatch__c FROM Case_Role__c WHERE Id IN :createCaseRoleList];

            //Create Payees
            List<Payee__c> createPayeeList = new List<Payee__c>();
            for(Case_Role__c cr : caseRoleList)
            {
                recordWrapper accP = accPayeeMap.get(cr.Entity__r.AccountMatch__c);

                if(accP != null)
                {
                    Payee__c payee = new Payee__c();
                    payee.PeriodCovered__c = accP.periodCovered; 
                    if(!String.isEmpty(accP.wageAsssesment))
                        payee.WageAssessment__c = toDecimal(accP.wageAsssesment);
                    if(!String.isEmpty(accP.grossWages))
                        payee.GrossWages__c = toDecimal(accP.grossWages);
                    if(!String.isEmpty(accP.disabilityInsurance))
                        payee.DisabilityInsurance__c = toDecimal(accP.disabilityInsurance);
                    if(!String.isEmpty(accP.socialSecurity))
                        payee.SocialSecurity__c = toDecimal(accP.socialSecurity);
                    if(!String.isEmpty(accP.medicare))
                        payee.Medicare__c = toDecimal(accP.medicare);
                    if(!String.isEmpty(accP.stateWitholding))
                        payee.StateWithholding__c = toDecimal(accP.stateWitholding);
                    if(!String.isEmpty(accP.federalWitholding))
                        payee.FederalWithholding__c = toDecimal(accP.federalWitholding);
                    if(!String.isEmpty(accP.totalDeductions))
                        payee.TotalDeductions__c = toDecimal(accP.totalDeductions);
                    if(!String.isEmpty(accP.netWages))
                        payee.NetWages__c = toDecimal(accP.netWages);
                    if(!String.isEmpty(accP.factor))
                        payee.Factor__c = toDecimal(accP.factor);
                    payee.Case_Management__c = caseId;
                    payee.Case_Role__c = cr.id;
                    payee.Payee_Type__c = 'Employee';
                    payee.Status__c = 'Unverified';
        
                    createPayeeList.add(payee);
                }
                else
                { 
                    //errorMessages.add('Could not find match on: ' + cr.Entity__r.AccountMatch__c);

                    //add a record in the failedDMLRecords so in the end we won't delete the Import__c record containing that information.
                    recordWrapper noMatchAccount = new recordWrapper();
                    noMatchAccount.errorMessage = 'Could not find match on: ' + cr.Entity__r.AccountMatch__c;  
                    noMatchAccount.firstname = cr.Entity__r.FirstName;
                    noMatchAccount.lastName = cr.Entity__r.LastName;
                    noMatchAccount.shippingStreet = cr.Entity__r.ShippingStreet;
                    noMatchAccount.shippingCity = cr.Entity__r.ShippingCity;
                    noMatchAccount.shippingState = cr.Entity__r.ShippingState;
                    noMatchAccount.shippingPostalCode = cr.Entity__r.ShippingPostalCode;
                    noMatchAccount.SSN = cr.Entity__r.SSN__pc;
                    noMatchAccount.caseManagment = caseId;

                    failedDMLRecords.add(noMatchAccount);
                }
                
            }
            
            List<Database.SaveResult> insertPayeeResults = Database.Insert(createPayeeList, false);

            for(Integer i = 0; i < insertPayeeResults.size(); i++)
            {                
                // DML operation failed
                if(!insertPayeeResults.get(i).isSuccess())
                {
                    Account dummyAccount = new Account();
 
                    for(Account acc : newAccountList)
                    {
                        if(acc.Id == createPayeeList.get(i).Case_Role__r.Entity__c)
                        {
                            dummyAccount = acc;
                            break;
                        }
                    }

                    Database.Error error = insertPayeeResults.get(i).getErrors().get(0);

                    setWrapperInfo(dummyAccount, error.getMessage());                    
                }
            }
        }
        catch (Exception e)
        {
            errorMessages.add('An error has occured processing the file: ' + e.getMessage());
        }      
    }
     
    global void setWrapperInfo(Account dummyAccount, String errorMessage)
    {
        recordWrapper failedInsert = new recordWrapper();

        failedInsert.errorMessage = errorMessage;  
        failedInsert.firstname = dummyAccount.FirstName;
        failedInsert.lastName = dummyAccount.LastName;
        failedInsert.shippingStreet = dummyAccount.ShippingStreet;
        failedInsert.shippingCity = dummyAccount.ShippingCity;
        failedInsert.shippingState = dummyAccount.ShippingState;
        failedInsert.shippingPostalCode = dummyAccount.ShippingPostalCode;
        failedInsert.SSN = dummyAccount.SSN__pc;
        failedInsert.caseManagment = caseId;

        failedDMLRecords.add(failedInsert);
    }

    global Decimal toDecimal(String s){
        String str = string.valueof(s);
        return decimal.valueof(str);
    }

    global void finish(Database.BatchableContext BC)
    {
        String userId = UserInfo.getUserId();
        User activeUser = [Select Email From User where Id = : userId limit 1];
        String userEmail = activeUser.Email;        
        List<import__c> importsToDelete = new List<import__c>();   
        String errorMessage = '';             
        String nonDMLErrorMessages = '';

        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Batch Job is done');
        
        String mailMessage = 'The file processing have been completed!' + '\n';

        List<import__c> csvRecords =
        [
            SELECT Name, Case_Management__c, Deductions_Federal_Withholding__c, Deductions_Medicare__c, Deductions_Social_Security__c, Deductions_State_Disability_Insurance__c, Deductions_State_Withholding__c, Deductions_Total__c, Employee_City__c, Employee_First_Name__c, Employee_Last_Name__c, Employee_State__c, Employee_Street__c, Employee_Zip__c, Factor__c, Gross_Wages_Paid__c, Net_Wages_Paid__c, Period_Covered_by_Adjustment__c, SSN__c, Total_Wage_Assessment__c
            FROM Import__c
            WHERE Case_Management__c = :caseId
        ];

        for(import__c importRecord : csvRecords)
        {            
            Boolean deleteRecord = true;

            for(recordWrapper failedDMLRecord : failedDMLRecords)
            {
                if(
                    importRecord.Employee_First_Name__c == failedDMLRecord.firstname &&
                    importRecord.Employee_Last_Name__c == failedDMLRecord.lastName &&
                    importRecord.Employee_Street__c == failedDMLRecord.shippingStreet &&
                    importRecord.Employee_State__c == failedDMLRecord.shippingState &&
                    importRecord.Employee_City__c == failedDMLRecord.shippingCity &&
                    importRecord.Employee_Zip__c == failedDMLRecord.shippingPostalCode &&
                    importRecord.SSN__c == failedDMLRecord.SSN &&
                    importRecord.Case_Management__c == failedDMLRecord.caseManagment
                )
                {
                    deleteRecord = false;
                    errorMessage += 'An error occurred while processing the following record: ' + importRecord.Employee_First_Name__c + ', ' + importRecord.Employee_Last_Name__c + ', ' + importRecord.Employee_Street__c + ', ' + importRecord.Employee_State__c + ', ' + importRecord.Employee_City__c + ', ' + importRecord.Employee_Zip__c + ', ' + importRecord.SSN__c + '. Error message: ' + failedDMLRecord.errorMessage + '. \n';
                    break;
                }
            }

            if(deleteRecord == true)
            {
                importsToDelete.add(importRecord);
            }
        }

        delete importsToDelete;

        if(errorMessages.size() > 0)
        {
            for(String message : errorMessages)
            {
                nonDMLErrorMessages += message + '\n';
            }
        }
        
        mail.setPlainTextBody(mailMessage + '\n' + nonDMLErrorMessages + '\n' + errorMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public class recordWrapper{

        public String key;

        public String firstname;
        public String lastName;
        public String shippingStreet;
        public String shippingCity;
        public String shippingState;
        public String shippingPostalCode;
        public String SSN;
        public String periodCovered;
        public String wageAsssesment;
        public String grossWages;
        public String disabilityInsurance;
        public String socialSecurity;
        public String medicare;
        public String stateWitholding;
        public String federalWitholding;
        public String totalDeductions;
        public String netWages;
        public String factor;
        public String caseManagment;
        public String errorMessage;
    } 
}