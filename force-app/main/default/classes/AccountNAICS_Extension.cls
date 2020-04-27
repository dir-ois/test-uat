public with sharing class AccountNAICS_Extension {
    public Account thisAccount {get; set;}
    public String buttonOrLink {get;set;}
    public String linkValue {get;set;}
    public String buttonValue {get;set;}
    
    public AccountNAICS_Extension(ApexPages.StandardController sc) {
        
        //refresh account layout or refresh only inline page, depending on the user profile
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if (profileName == 'BOFE Deputy'){
            buttonOrLink = 'link';
            linkValue = 'Save';
        }
        else{
            if (profileName.contains('System Administrator')){
                buttonOrLink = 'button';
                linkValue = 'Save BOFE';
                buttonValue = 'Save Other';
            }
            else{
                buttonOrLink = 'other';
                buttonValue = 'Save';
            }
        }
        
        if(sc.getId() != null) {
            thisAccount = [Select Id, NAICS_Code__c From Account Where Id = :sc.getId()];
        }
        initializeCodes();
    }
    
    public PageReference save() {
        update thisAccount;
        
        return cancel();
    }
    
    public PageReference cancel() {
        return new PageReference('/' + thisAccount.Id);
    }
    
////////////////////////////////////////////
////        NAICS Code Selector         ////
////////////////////////////////////////////

    // Level 1 -> Level 2 -> Level 3 -> Level 4 -> Level 5
    public Map<NAICS_Code__c, Map<NAICS_Code__c, Map<NAICS_Code__c, Map<NAICS_Code__c, List<NAICS_Code__c>>>>> level1 {get; set;}
    public Map<NAICS_Code__c, Boolean> level1Opened {get; set;}
    public String level1ToOpen {get; set;}
    public String level1ToClose {get; set;}
    public Map<NAICS_Code__c, Boolean> level2Opened {get; set;}
    public String level2ToOpen {get; set;}
    public String level2ToClose {get; set;}
    public Map<NAICS_Code__c, Boolean> level3Opened {get; set;}
    public String level3ToOpen {get; set;}
    public String level3ToClose {get; set;}
    public Map<NAICS_Code__c, Boolean> level4Opened {get; set;}
    public String level4ToOpen {get; set;}
    public String level4ToClose {get; set;}
    public Map<Id, Boolean> isChecked {get; set;}
    public Id levelToCheck {get; set;}
    public Id selectedCodeId {get; set;}
    
    public void initializeCodes() {     
        level1 = new Map<NAICS_Code__c, Map<NAICS_Code__c, Map<NAICS_Code__c, Map<NAICS_Code__c, List<NAICS_Code__c>>>>>();
        level1Opened = new Map<NAICS_Code__c, Boolean>();
        level2Opened = new Map<NAICS_Code__c, Boolean>();
        level3Opened = new Map<NAICS_Code__c, Boolean>();
        level4Opened = new Map<NAICS_Code__c, Boolean>();
        
        isChecked = new Map<Id, Boolean>();
        
        for(NAICS_Code__c lvl1 : [select Id, Name, NAICS_Title__c from NAICS_Code__c where Level__c = 'Level 1']) {
            level1.put(lvl1, new Map<NAICS_Code__c, Map<NAICS_Code__c, Map<NAICS_Code__c, List<NAICS_Code__c>>>>());
            level1Opened.put(lvl1, false);
            isChecked.put(lvl1.Id, false);
        }
    }
    
    public PageReference openLevel1() {
        System.debug(level1ToOpen);
        System.debug('Inside Open Level1');
        if(level1ToOpen != null) {
            NAICS_Code__c tempLvl1 = [select Id, Name, NAICS_Title__c from NAICS_Code__c where Id = :level1ToOpen];
            level1Opened.put(tempLvl1, true);
            for(NAICS_Code__c lvl2 : [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 2' and Supersector__c = :tempLvl1.Id]) {
                if(level1.get(tempLvl1).get(lvl2) == null) {
                    level1.get(tempLvl1).put(lvl2, new Map<NAICS_Code__c, Map<NAICS_Code__c, List<NAICS_Code__c>>>());
                    isChecked.put(lvl2.Id, false);
                }
                level2Opened.put(lvl2, false);
            }
        }
        return null;
    }
    
    public PageReference closeLevel1() {
        System.debug(level1ToClose);
        if(level1ToClose != null) {
            NAICS_Code__c tempLvl1 = [select Id, Name, NAICS_Title__c from NAICS_Code__c where Id = :level1ToClose];
            level1Opened.put(tempLvl1, false);
        }
        return null;
    }
    
    public PageReference openLevel2() {
        System.debug(level2ToOpen);
        if(level2ToOpen != null) {
            NAICS_Code__c tempLvl2 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 2' and Id = :level2ToOpen];
            NAICS_Code__c tempLvl1 = [select Id, Name, NAICS_Title__c from NAICS_Code__c where Level__c = 'Level 1' and Id = :templvl2.Supersector__c];
            level2Opened.put(tempLvl2, true);
            for(NAICS_Code__c lvl3 : [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 3' and Supersector__c = :tempLvl2.Id]) {
                if(level1.get(tempLvl1).get(tempLvl2).get(lvl3) == null) {
                    level1.get(tempLvl1).get(tempLvl2).put(lvl3, new Map<NAICS_Code__c, List<NAICS_Code__c>>());
                    isChecked.put(lvl3.Id, false);
                }
                level3Opened.put(lvl3, false);
            }
        }
        return null;
    }
    
    public PageReference closeLevel2() {
        System.debug(level2ToClose);
        if(level2ToClose != null) {
            NAICS_Code__c tempLvl2 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 2' and Id = :level2ToClose];
            level2Opened.put(tempLvl2, false);
        }
        return null;
    }
    
    public PageReference openLevel3() {
        System.debug(level3ToOpen);
        if(level3ToOpen != null) {
            NAICS_Code__c tempLvl3 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 3' and Id = :level3ToOpen];
            NAICS_Code__c tempLvl2 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 2' and Id = :tempLvl3.Supersector__c];
            NAICS_Code__c tempLvl1 = [select Id, Name, NAICS_Title__c from NAICS_Code__c where Level__c = 'Level 1' and Id = :tempLvl2.Supersector__c];
            level3Opened.put(tempLvl3, true);
            for(NAICS_Code__c lvl4 : [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 4' and Supersector__c = :tempLvl3.Id]) {
                if(level1.get(tempLvl1).get(tempLvl2).get(tempLvl3).get(lvl4) == null) {
                    level1.get(tempLvl1).get(tempLvl2).get(tempLvl3).put(lvl4, new List<NAICS_Code__c>());
                    isChecked.put(lvl4.Id, false);
                }
                level4Opened.put(lvl4, false);
            }
        }
        return null;
    }
    
    public PageReference closeLevel3() {
        System.debug(level3ToClose);
        if(level3ToClose != null) {
            NAICS_Code__c tempLvl3 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 3' and Id = :level3ToClose];
            level3Opened.put(tempLvl3, false);
        }
        return null;
    }
    
    public PageReference openLevel4() {
        System.debug(level4ToOpen);
        if(level4ToOpen != null) {
            NAICS_Code__c tempLvl4 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 4' and Id = :level4ToOpen];
            NAICS_Code__c tempLvl3 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 3' and Id = :tempLvl4.Supersector__c];
            NAICS_Code__c tempLvl2 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 2' and Id = :tempLvl3.Supersector__c];
            NAICS_Code__c tempLvl1 = [select Id, Name, NAICS_Title__c from NAICS_Code__c where Level__c = 'Level 1' and Id = :tempLvl2.Supersector__c];
            level4Opened.put(tempLvl4, true);
            List<NAICS_Code__c> tempLvl5 = level1.get(tempLvl1).get(tempLvl2).get(tempLvl3).get(tempLvl4);
            if(tempLvl5.size() == 0) { 
                for(NAICS_Code__c lvl5 : [select Id, Name, NAICS_Title__c from NAICS_Code__c where Level__c = 'Level 5' and Supersector__c = :tempLvl4.Id]) {
                    tempLvl5.add(lvl5);
                    isChecked.put(lvl5.Id, false);
                }
                level1.get(tempLvl1).get(tempLvl2).get(tempLvl3).put(tempLvl4, tempLvl5);
            }
        }
        return null;
    }
    
    public PageReference closeLevel4() {
        System.debug(level4ToClose);
        if(level4ToClose != null) {
            NAICS_Code__c tempLvl4 = [select Id, Name, NAICS_Title__c, Supersector__c from NAICS_Code__c where Level__c = 'Level 4' and Id = :level4ToClose];
            level4Opened.put(tempLvl4, false);
        }
        return null;
    }
    
    public PageReference selectCode() {
        thisAccount.NAICS_Code__c = selectedCodeId;
        return null;
    }    
}