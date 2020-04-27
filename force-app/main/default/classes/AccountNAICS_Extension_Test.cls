@isTest
(SeeAllData = true)
public with sharing class AccountNAICS_Extension_Test {

    public static testMethod void wageClaim_Extension_Test() {
        Id defendantBusinessRTID = null;
        for(RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Account']) {
            if(rt.Name == 'Defendant Business') {
                defendantBusinessRTID = rt.Id;
            }
        }
        
        NAICS_Code__c level1 = new NAICS_Code__c();
        level1.Name = '11';
        level1.NAICS_Title__c = 'TEST1';
        level1.Level__c = 'Level 1';
        insert level1;
        
        NAICS_Code__c level2 = new NAICS_Code__c();
        level2.Name = '111';
        level2.NAICS_Title__c = 'TEST2';
        level2.Level__c = 'Level 2';
        level2.Supersector__c = level1.Id;
        insert level2;
        
        NAICS_Code__c level3 = new NAICS_Code__c();
        level3.Name = '1111';
        level3.NAICS_Title__c = 'TEST3';
        level3.Level__c = 'Level 3';
        level3.Supersector__c = level2.Id;
        insert level3;
        
        NAICS_Code__c level4 = new NAICS_Code__c();
        level4.Name = '11111';
        level4.NAICS_Title__c = 'TEST4';
        level4.Level__c = 'Level 4';
        level4.Supersector__c = level3.Id;
        insert level4;
        
        NAICS_Code__c level5 = new NAICS_Code__c();
        level5.Name = '111111';
        level5.NAICS_Title__c = 'TEST5';
        level5.Level__c = 'Level 5';
        level5.Supersector__c = level4.Id;
        insert level5;
        
        Account someBusiness = new Account();
        someBusiness.Name = 'Some Business';
        someBusiness.RecordTypeId = defendantBusinessRTID;
        insert someBusiness;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(someBusiness);
        AccountNAICS_Extension ane = new AccountNAICS_Extension(sc);
        
        ane.level1ToOpen = level1.Id;
        ane.level2ToOpen = level2.Id;
        ane.level3ToOpen = level3.Id;
        ane.level4ToOpen = level4.Id;
        
        ane.level1ToClose = level1.Id;
        ane.level2ToClose = level2.Id;
        ane.level3ToClose = level3.Id;
        ane.level4ToClose = level4.Id;
        
        ane.openLevel1();
        ane.openLevel2();
        ane.openLevel3();
        ane.openLevel4();
        
        ane.closeLevel1();
        ane.closeLevel2();
        ane.closeLevel3();
        ane.closeLevel4();
        
        ane.cancel();
        ane.save();
    }
}