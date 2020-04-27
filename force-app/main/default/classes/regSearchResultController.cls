public class regSearchResultController {
    
    public Id regId {get;set;}
    public License_Registration__c newReg{get;set;}
    public List<License_Registration__c> regHistory{get;set;}
    
    public regSearchResultController(){
        regId = apexpages.currentpage().getparameters().get('id');
        newReg = [SELECT id,Legal_Entity_Name__c,status__c,Company_Type__c,License_Registration_Number__c,Effective_Date__c,Expiration_Date__c,
        Mailing_Address_Line_1__c,Mailing_Address_Line_2__c,Mailing_City__c,Mailing_Postal_Code__c,Mailing_State__c,Mailing_Country__c,County__c,
        Physical_Business_Address_Line_1__c,Physical_Business_Address_Line_2__c,Physical_Business_City__c,Physical_Business_Postal_Code__c,Physical_Business_State__c,
        Physical_Business_Country__c,Account_Email__c,PEO_Name__c,PEO_Phone__c,PEO_Email__c,Lease_Through_PEO__c,Workers_Comp_Selection__c,
        Workers_Compensation_Carrier__c,Insurance_Carrier__c,WCI_Cert_Number__c,WCI_Initial_Certification_Date__c,WCI_Expiration_Date__c,
        Exempt_Reason__c,EntityNumber__c,Federal_Employer_Identification_Number__c,
        (select id,Name from DBAS__r),
        (select id,License_Number__c,License_Type__c from Registrations__r ),
        (select id,Corp_or_LLC_ID__c,Federal_Employer_Identification_Number__c,PresidentsName__c,VicePresidentName__c,TreasurerName__c,SecretaryName__c,
                CEOName__c,AgentofServiceFirstName__c,AgentofServiceLastName__c,Mailing_Street__c,AgentofServiceName__c,Mailing_Address_Line_2__c,Mailing_City__c,Mailing_Zip_Code__c,Mailing_State__c,
                Mailing_Country__c,First_Name__c,Last_Name__c,recordtype.developername,toLabel(Joint_Venture_Company_Type__c),Legal_Entity_Name__c,Corp_or_LLC_Name__c,MemberLegalName__c
                from Registration_Accounts__r)
        
            FROM License_Registration__c where id= :regId];
                    
        System.debug('newReg--'+newReg);          
        System.debug('size--'+newReg.DBAS__r.size());
        
        regHistory = [Select id,Effective_Date__c,Expiration_Date__c
                                               FROM License_Registration__c 
                                               WHERE License_Registration_Number__c = :newReg.License_Registration_Number__c
                                                     AND (status__c='Active' OR status__c='Expired' OR status__c='Disqualified') ];
        
        System.debug('regHistory--'+regHistory);                                             
    }

}