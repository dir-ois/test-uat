//Controller for both CashOnHandVFP and CashOnHandOtherVFP
public with sharing class CashOnHandReportController{
    public Integer count {get; set;}
    public Decimal sum {get; set;}
    public String officeAccountName {get; set;}
    public String officeName {get; set;}
    public List<DIR_Case__c> cases {get; set;}
    public String sectionHeaderSubtitle {get; set;}
    
    public CashOnHandReportController(){ //constructor/controller for "Other" reports - CashOnHandReportOtherVFP - (Cases with no or invalid Office or Office Account, not BOFE, WCA or CCU)
        System.debug('Entered \'Other\' constructor');
        
        sum = 0.00;
        
        List<Id> ourOfficeRTIDs = new List<Id>();
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('WCA').getRecordTypeId());
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('Garment').getRecordTypeId());
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId());
        ourOfficeRTIDs.add(Schema.SObjectType.Office__c.getRecordTypeInfosByName().get('CCU').getRecordTypeId());
            
        cases = [SELECT Id, Name, Case_Number__c, Cash_Balance_on_Case__c, 
                    Office__c, Office__r.RecordTypeID, Office__r.Office_Account__c, Office__r.Office_Account__r.Name, Office__r.Office_Account__r.Id, Employer__c, Employer__r.Name
                                FROM DIR_Case__c
                                WHERE Cash_Balance_on_Case__c != 0.00
                                    AND (Office__c = NULL
                                    OR Office__r.RecordTypeID NOT IN :ourOfficeRTIDs)]; //assumes all pertinent Offices have an Office Account and is of a WCA, BOFE, or CCU record type
        
        System.debug('cases.size(): '+cases.size());
        System.debug('other cases: '+cases);
        
        count = cases.size();
        
        for(DIR_Case__c DIRCase : cases){
            sum += DIRCase.Cash_Balance_on_Case__c;
        }
        
        sectionHeaderSubtitle = 'Other or No Office Accounts ' + Datetime.now().format('MMM d, yyyy HH:mm z');
        
    }
    
    
    
    public CashOnHandReportController(ApexPages.StandardController sc){ //constructor/controller for most CoH reports - CashOnHandReportVFP - one for each Office Account
        
        System.debug('Entered regular constructor');
        String officeAccountId = ApexPages.CurrentPage().getParameters().get('Id');
        sum = 0.00;
        
        cases = [SELECT Id, Name, Case_Number__c, Cash_Balance_on_Case__c, 
                    Office__c, Office__r.Name, Office__r.Office_Account__c, Office__r.Office_Account__r.Id, Office__r.Office_Account__r.Name, Employer__c, Employer__r.Name
                                    FROM DIR_Case__c
                                    WHERE Cash_Balance_on_Case__c != 0.00
                                        AND Office__r.Office_Account__r.Id = :officeAccountId];
        
        System.debug('cases.size(): '+cases.size());
        count = cases.size();
        System.debug('cases: '+ cases);
        
        if(!cases.isEmpty()){
            officeAccountName = cases[0].Office__r.Office_Account__r.Name; //All cases will have the same Office Account on each report.
            officeName = cases[0].Office__r.Name;
        }else{
            Office_Account__c officeAccount = [SELECT Id, Name, Office__c, Office__r.Name
                                                FROM Office_Account__c
                                                WHERE Id = :officeAccountId][0];
            officeAccountName = officeAccount.Name;
            officeName = officeAccount.Office__r.Name;
        }
        
        for(DIR_Case__c DIRCase : cases){
            sum += DIRCase.Cash_Balance_on_Case__c;
        }
        
        sectionHeaderSubtitle = officeAccountName + ' ' + officeName + ' ' + Datetime.now().format('MMM d, yyyy HH:mm z');
    }
    
}