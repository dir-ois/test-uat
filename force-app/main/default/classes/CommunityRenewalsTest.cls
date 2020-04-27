@isTest
private class CommunityRenewalsTest {

     private  static testMethod void communityRenewalsTest() {
         
        Account objAccount = new Account(
                                    Name = 'test acct 123',
                                    Legal_Entity_Name__c = 'test acct 123',
                                    ShippingStreet = '123 fake st\r\nBldg A\r\nUnit A',
                                    ShippingCity = 'Denver',
                                    ShippingState = 'CO',
                                    ShippingPostalCode = '80212' 
                                );
        insert objAccount;
        
        Contact objContact = new Contact(LastName ='testCon',AccountId = objAccount.Id,Email = 'test@test.com');
        insert objContact;  
        
        License_Registration__c objLR = new License_Registration__c(
                                                                    Account__c = objAccount.Id,
                                                                    License_Registration_Number__c = '222',
                                                                    License_Registration_Type__c = 'Car Wash',
                                                                    Status__c = 'Incomplete',
                                                                    Expiration_Date__c = Date.today(), 
                                                                    Mailing_Country__c = 'United States of America',
                                                                    Physical_Business_Country__c = 'United States of America',
                                                                    Effective_Date__c = Date.today(),
                                                                    Amount_Paid__c = 100, 
                                                                    Applicant__c = objContact.Id,
                                                                    RecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByName().get('Car Wash').getRecordTypeId()
                                                                    );
                                                                    
        insert objLR;
        
        
         Id personRecordTypeId = Schema.SObjectType.Registration_Account__c.getRecordTypeInfosByName().get('Partnership').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Registration_Account__c .getRecordTypeInfosByName().get('Management Individual').getRecordTypeId();
            
        Registration_Account__c racc2 = new Registration_Account__c();
        racc2.RecordTypeId = businessRecordTypeId;
        racc2.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc2.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc2.First_Name__c = 'FirstName';
        racc2.Last_Name__c = 'LastName';
        racc2.Email_Address__c = 'test@asdadad.com';
        racc2.Legal_Entity_Name__c = 'Legal Entity Name';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_State__c = 'CA';
        racc2.Mailing_City__c = 'San Francisco';
        racc2.Mailing_Street__c = 'Street ';
        racc2.Mailing_Zip_Code__c = '54434';
        racc2.Business_Phone__c = '4445553434';
        racc2.Mobile_Phone__c = '5445445555';
        racc2.Registration__c = objLR.Id;
        racc2.Account__c = objAccount.Id;
        racc2.Email_Address__c = 'test@test.com';
        //racc2.Name = '12345678';
        racc2.Federal_Employer_Identification_Number__c = '123456789';
        racc2.Legal_Entity_Name__c  = 'test namr';
        racc2.Business_Phone__c = '4234564565';
        racc2.Daytime_Phone_Ext__c = '4234';
        racc2.SSN__c = '423111222';
        racc2.Re_type_SSN__c = '423111222';
        racc2.Last_Name__c = 'dsdds';
        racc2.Joint_Venture_Company_Type__c = 'Partnership';
        racc2.Title__c = 'Manager';
        racc2.Mobile_Phone__c = '4445556666';
        racc2.State_of_Incorporation__c = 'CA';
        racc2.Good_standing_with_CA_Secretary_of_State__c = 'Yes';
        racc2.Driver_s_License_State__c = 'CA';
        racc2.Driver_s_License__c = '456677';
        insert racc2;
        
        /*Registration_Account__c racc1 = new Registration_Account__c();
        racc1.RecordTypeId = personRecordTypeId;
        racc1.Corp_or_LLC_ID__c = 'Corp or LLC ID';
        racc1.Corp_or_LLC_Name__c = 'Corp or LLC Name';
        racc1.First_Name__c = 'FirstName';
        racc1.Last_Name__c = 'LastName';
        racc1.Email_Address__c = 'test@asdadad.com';
        racc1.Legal_Entity_Name__c = 'Legal Entity Name';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_State__c = 'CA';
        racc1.Mailing_City__c = 'San Francisco';
        racc1.Mailing_Street__c = 'Street ';
        racc1.Mailing_Zip_Code__c = '54434';
        racc1.Business_Phone__c = '4445553434';
        racc1.Mobile_Phone__c = '5445445555';
        racc1.Registration__c = objLR.Id;
        racc1.Account__c = objAccount.Id;
        racc1.Email_Address__c = 'test@test.com';
        racc1.Name = '12345679';
        racc1.Federal_Employer_Identification_Number__c = '123456798';
        racc1.Legal_Entity_Name__c  = 'test namr';
        racc1.Business_Phone__c = '4234564565';
        racc1.Daytime_Phone_Ext__c = '4234';
        racc1.SSN__c = '423111221';
        racc1.Re_type_SSN__c = '423111221';
        racc1.Last_Name__c = 'dsdds';
        racc1.First_Name__c = 'dsddddds';
        racc1.Joint_Venture_Company_Type__c = 'Partnership';
        racc1.Title__c = 'Manager';
        racc1.Mobile_Phone__c = '4445556666';
        racc1.State_of_Incorporation__c = 'CA';
        racc1.Good_standing_with_CA_Secretary_of_State__c = 'Yes';
        racc1.Driver_s_License_State__c = 'CA';
        racc1.Driver_s_License__c = '454545';
        insert racc1;*/
        
        
        
        
        /*Registration_Location__c rloc = new Registration_Location__c();
        rloc.Address__c = 'address';
        rloc.City__c = 'San Francisco';
        rloc.DBA_Name__c = 'DBA Name';
        rloc.FBNS__c = 'FBNS';
        rloc.Foreign_Address__c = 'Foreign Address';
        rloc.Mobile_Business__c = true;
        rloc.Phone__c = '4445553434';
        rloc.Registration__c = objLR.Id;
        rloc.Account__c = objAccount.Id;
        rloc.Zip_Code__c = '12343';
        insert rloc;*/
        
        
        Bond__c objBond = new Bond__c(Registration__c = objLR.Id);
        insert objBond;
        


        Fee_Summary__c objFS = new Fee_Summary__c(Registration__c = objLR.Id);
        insert objFS;
      
                
        Fee__c objFee = new Fee__c(
                                    Fee__c = 100,
                                    Registration__c = objLR.Id,
                                    Fee_Summary__c = objFS.Id,
                                    Description__c = 'Fee description'
                                   );
        insert objFee;

        Rejection__c objRejection = new Rejection__c(Registration__c = objLR.Id,
                                        Applicant__c = objAccount.Id);
        insert objRejection;
        
        insert new Ownership__c(Registration__c = objLR.Id,Last_Name__c  ='test');
        insert new Registration_Education__c(Registration__c = objLR.Id);
        insert new Manual_Fee_Payment__c(Registration__c = objLR.Id);
        insert new Rejection__c(Registration__c = objLR.Id);
        
        Defect__c objDefect = new Defect__c(
                                            Active__c = true,
                                            Description__c = 'Description test',
                                            Registration_Type__c = 'Car Wash',
                                            Section__c = 'Company Information',
                                            Sub_Section__c = 'Documents',
                                            Object__c = 'Business Account'
                                            );
        insert objDefect;
        
        Rejection_Defect__c rdef = new Rejection_Defect__c(Defect__c = objDefect.Id,
                                                    Registration__c = objLR.Id,
                                                    Rejection__c = objRejection.Id,
                                                    Resolved__c = true,
                                                    Applies__c = true);
        
        Question_Bank__c objQB = new Question_Bank__c(RecordTypeId = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByName().get('Simple').getRecordTypeId());
        insert objQB;
        
        

        
        
        Test.startTest();

        Test.setCurrentPage(new PageReference('/CommunityRenewals?id=' + objLR.id));
        CommunityRenewals controllerCR = new CommunityRenewals();
        controllerCR.cloneWithItems();
        
        Test.stopTest();

     }

}