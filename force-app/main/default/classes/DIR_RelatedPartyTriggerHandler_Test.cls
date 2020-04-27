//-----------------------------
// @author: Oswin Correa
// @date: 18/4/2018
// @description: Test Class of  DIR_RelatedPartyTriggerHandler
//-----------------------------
// @modified by: Daniel Chu
// @deploy date: 1/31/2019
// @description: As part of the fix to confirming employer related party whose other zip code is out of California
// @note: This test class is a work in progress, and needs to be redesign. It was revised quickly to deploy the fixes for SR-005287.
//-----------------------------
@isTest
private class DIR_RelatedPartyTriggerHandler_Test {

    //Test 1 
    //Testing for 1 Employer, 1 Claimant.
    private static testMethod void test_DIR_RelatedPartyTriggerHandler1() {
 
        Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
        Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
        insert new List<Account> {objAcct1,objAcct2}; 
         
        DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
        insert objCase;
    
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Claimant',
                                                  Street_Address__c = '123 Praire City Drive, Apt B',
                                                  City__c = 'Whittier',
                                                  State__c = 'CA',
                                                  Zip_Code__c = '90607',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                  );
    
        Related_Party__c objRL2 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Case Employer',
                                                  First_Name__c = 'John',
                                                  Last_Name__c = 'Smith',
                                                  Zip_Code__c = '94105',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer').getRecordTypeId()
                                                  );               
                                                                                          

        insert new List<Related_Party__c> {objRL1,objRL2};
    
        objRL1.Status__c = 'Confirm';  
        update new List<Related_Party__c> {objRL1};
    
        objRL2.Status__c = 'Confirm';
        update new List<Related_Party__c> {objRL2};
    
        system.assertEquals(true, [SELECT Id From Account where Id !=: objAcct1.Id].size() != 0);

  }

    //Test 2
    //Testing for 1 Employer with different work address, 1 Claimant. Account ID found for both claimant and employer.
    private static testMethod void test_DIR_RelatedPartyTriggerHandler2() {
      
    Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
    Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
    insert new List<Account> {objAcct1,objAcct2}; 
      
    DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
    objCase.WorkAddressDifferent__c = 'Yes';
    
    insert objCase;

    Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Claimant',
                                                  Zip_Code__c = '94105',
                                                  Email__c = 'test@dir.ca.gov.test',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                  );
    
    Related_Party__c objRL2 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Case Employer',
                                                  First_Name__c = 'John',
                                                  Last_Name__c = 'Smith',
                                                  Zip_Code__c = '94105',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer').getRecordTypeId()
                                                  );               
                                                  
    Related_Party__c objRL3 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Employer Address',
                                                  Other_Zip_Code__c = '78751',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer DWA').getRecordTypeId()
                                                  );                                              

    Related_Party__c objRL4 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Witness',
                                                  Zip_Code__c = '94134',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Witness').getRecordTypeId()
                                                  );  
                                                  
    Related_Party__c objRL5 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Advocate',
                                                  Zip_Code__c = '94133',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Advocate').getRecordTypeId()
                                                  );                                                   
                                                  

    insert new List<Related_Party__c> {objRL1,objRL2,objRL3,objRL4,objRL5};
   
    objRL1.Status__c = 'Confirm';
    objRL1.Found_Account_ID__c = objAcct1.Id;
    update objRL1;
    
    objRL2.Status__c = 'Confirm';
    objRL2.Found_Account_ID__c = objAcct2.Id;  
    update objRL2; 
 
    objRL5.Status__c = 'Confirm';
    update objRL5;
  
    
    system.assertEquals(true, [SELECT Id From Account where Id !=: objAcct1.Id].size() != 0);
    
  }
  
    //Test 3
    //Testing for 1 Employer, 1 Claimant with invalid Account ID. 
    private static testMethod void test_DIR_RelatedPartyTriggerHandler3() {
 
        Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
        Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
        insert new List<Account> {objAcct1,objAcct2}; 
         
        DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
        insert objCase;
    
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Claimant',
                                                  Zip_Code__c = '95691',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                  );
    
        Related_Party__c objRL2 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Case Employer',
                                                  First_Name__c = 'John',
                                                  Last_Name__c = 'Smith',
                                                  Zip_Code__c = '94105',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer').getRecordTypeId()
                                                  );               
                                                                                          

        insert new List<Related_Party__c> {objRL1,objRL2};
    

        try
        {
            objRL1.Status__c = objRL2.Status__c = 'Confirm';
            objRL2.Found_Account_ID__c = 'ABC123';
            update new List<Related_Party__c> {objRL1,objRL2};
            
        }
    
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Enter valid Account Id in Found_Account_ID field') ? True : False;
            system.assertEquals(expectedExceptionThrown, True);
        } 
    }

    //Test 4
    //Testing for 1 Employer with different work address, 1 Claimant. Account ID found for both claimant and employer.
    private static testMethod void test_DIR_RelatedPartyTriggerHandler4() {

        Map<String,Schema.RecordTypeInfo> accountTRMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id recordTypeId_PA = accountTRMapByName.get('Person Account').getRecordTypeId();
        Id recordTypeId_BA = accountTRMapByName.get('Business Account').getRecordTypeId(); 

        Account objAcct1 = new Account(FirstName = 'Joe', 
                                       LastName = 'Smith',
                                       RecordTypeId = recordTypeId_PA,
                                       BillingCity = 'San Francisco',
                                       BillingState = 'CA',
                                       BillingPostalCode = '94105',
                                       BillingStreet = '123 Bay St',
                                       ShippingCity = 'San Francisco',
                                       ShippingState = 'CA',
                                       ShippingPostalCode = '94105',
                                       ShippingStreet = '123 Bay St',
                                       Email__c = 'test@dir.ca.gov.test');
    
        Account objAcct2 = new Account(Name = 'Company XYZ',
                                       RecordTypeId = recordTypeId_BA,
                                       ShippingCity = 'Austin',
                                       ShippingState = 'CA',
                                       ShippingPostalCode = '78751',
                                       ShippingStreet = '321 Industrial Drive'); 
      
        insert new List<Account> {objAcct1,objAcct2}; 
      
        DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
        objCase.WorkAddressDifferent__c = 'Yes';
    
        insert objCase;

        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Claimant',
                                                  Zip_Code__c = '94105',
                                                  Email__c = 'test@dir.ca.gov.test',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                  );
    
        Related_Party__c objRL2 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Case Employer',
                                                  Business_Name__c = 'Company XYZ',
                                                  Street_Address__c = '1234 Mission St',
                                                  City__c = 'San Francisco',
                                                  Zip_Code__c = '94105',
                                                  Still_in_business__c = 'Yes',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer').getRecordTypeId()
                                                  );               
                                                  
        Related_Party__c objRL3 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Employer Address',
                                                  Other_Street_Address__c = '321 Industrial Drive',
                                                  Other_City__c = 'Austin',
                                                  Other_State__c = 'TX',
                                                  Other_Zip_Code__c = '78751',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer DWA').getRecordTypeId()
                                                  );                                              

        Related_Party__c objRL4 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Witness',
                                                  Zip_Code__c = '94134',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Witness').getRecordTypeId()
                                                  );  
                                                  
        Related_Party__c objRL5 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Advocate',
                                                  Zip_Code__c = '94133',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Advocate').getRecordTypeId()
                                                  );                                                   
                                                  

        insert new List<Related_Party__c> {objRL1,objRL2,objRL3,objRL4,objRL5};

    
        objRL1.Status__c = objRL2.Status__c = objRL5.Status__c = 'Confirm';

        update new List<Related_Party__c> {objRL1,objRL2,objRL5};
 
        system.assertEquals(true, [SELECT Id From Account where Id !=: objAcct1.Id].size() != 0);

    }
 
    //Test 5
    private static testMethod void test_DIR_RelatedPartyTriggerHandler5() {
    
        Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
        Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
        insert new List<Account> {objAcct1,objAcct2}; 
   
     
        DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
        objCase.WorkAddressDifferent__c = 'Yes';
    
        insert objCase;

        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Claimant',
                                                  Zip_Code__c = '94105',
                                                  Email__c = 'test@dir.ca.gov.test',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                  );
    
        Related_Party__c objRL2 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Case Employer',
                                                  Business_Name__c = 'Company XYZ',
                                                  Street_Address__c = '1234 Mission St',
                                                  City__c = 'San Francisco',
                                                  Zip_Code__c = '94105',
                                                  Still_in_business__c = 'Yes',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer').getRecordTypeId()
                                                  );               
                                                  
        Related_Party__c objRL3 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Employer Address',
                                                  Other_Street_Address__c = '321 Industrial Drive',
                                                  Other_City__c = 'Austin',
                                                  Other_State__c = 'TX',
                                                  Other_Zip_Code__c = '78751',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer DWA').getRecordTypeId()
                                                  );                                              

        Related_Party__c objRL4 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Witness',
                                                  Zip_Code__c = '94134',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Witness').getRecordTypeId()
                                                  );  
                                                  
        Related_Party__c objRL5 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Advocate',
                                                  Zip_Code__c = '94133',
                                                  Status__c = 'Pending',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Advocate').getRecordTypeId()
                                                  );                                                   
                                                  

        insert new List<Related_Party__c> {objRL1,objRL2,objRL3,objRL4,objRL5};

    
        objRL1.Status__c = objRL2.Status__c = objRL3.Status__c = objRL5.Status__c = 'Confirm';

        update new List<Related_Party__c> {objRL1,objRL2,objRL3,objRL5};
  
        system.assertEquals(true, [SELECT Id From Account where Id !=: objAcct1.Id].size() != 0);

    }

    //Test 6
    //Testing for 1 Employer, 1 Claimant.
    private static testMethod void test_DIR_RelatedPartyTriggerHandler6() {
 
        Account objAcct1 = new Account(Name = 'Acct1', ShippingCity = 'ShippingCity1', BillingCity = 'BillingCity1');
        Account objAcct2 = new Account(Name = 'Acct2', ShippingCity = 'ShippingCity2', BillingCity = 'BillingCity2');
        insert new List<Account> {objAcct1,objAcct2}; 
         
        DIR_Case__c objCase = new DIR_Case__c(RecordTypeId = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId());
        insert objCase;
    
        Related_Party__c objRL1 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Claimant',
                                                  Street_Address__c = '123 Praire City Drive, Apt B',
                                                  City__c = 'Whittier',
                                                  State__c = 'CA',
                                                  Zip_Code__c = '90607',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employee').getRecordTypeId()
                                                  );
    
        Related_Party__c objRL2 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Case Employer',
                                                  First_Name__c = 'John',
                                                  Last_Name__c = 'Smith',
                                                  Zip_Code__c = '94105',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Employer').getRecordTypeId()
                                                  );               

        Related_Party__c objRL5 = new Related_Party__c(Case_Management__c = objCase.Id,
                                                  Role__c = 'Advocate',
                                                  Zip_Code__c = '94133',
                                                  RecordTypeId = Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get('Advocate').getRecordTypeId()
                                                  ); 
                                                                                          

        insert new List<Related_Party__c> {objRL1,objRL2,objRL5};
    
        objRL1.Status__c = objRL2.Status__c = objRL5.Status__c = 'Confirm';  
        update new List<Related_Party__c> {objRL1,objRL2,objRL5};
    
    
        system.assertEquals(true, [SELECT Id From Account where Id !=: objAcct1.Id].size() != 0);

    }
  
}