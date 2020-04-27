public with sharing class GenerateDailyCheckLogController {
    
    public Check__c check {get;set;}
    public Id userId {get;set;}
    public String docURL {get;set;}
    //public String selectedRT {get;set;}
    public List<SelectOption> rtList {get;set;}
    //public Map<string, string> ctMap {get;set;}
    public List<Conga_Template_Mapping__c> objCTMapping {get;set;}
    
    public GenerateDailyCheckLogController(){
        check = new Check__c();
        userId = userInfo.getUserId();

        
        // get mapping settings from Conga Template Mapping custom setting
        objCTMapping = [Select Name, RecordID__c FROM Conga_Template_Mapping__c WHERE Mapping_Group__c = 'DailyCheckLog'];
        system.debug('objCTMapping:::: ' +objCTMapping);
        
    }
    
    
    public void setURL(){
        Map<string, string> ctMap = new Map<string, string>();
        system.debug('objCTMapping:::: ' + objCTMapping);
        for (Conga_Template_Mapping__c c : objCTMapping){
            system.debug('c.Name: ' + c.Name + ' & c.RecordID__c: ' + c.RecordID__c);
            ctMap.put(c.Name, c.RecordID__c); 
        }
    DateTime newTimestamp = DateTime.newInstance(check.Issue_Date__c.year(), check.Issue_Date__c.month(), check.Issue_Date__c.day());
    //newTimestamp.format('yyyy-MM-dd');
        if(ctMap.isEmpty())
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'CTMap is empty'));
        system.debug('ctMAP::::: ' + ctmap);
        docURL += ''
            +'&id=' + userId
            //+'&queryid=[Calendar]a0md00000064cjs?'
            //+'&queryid=a0m63000000J4rC?'
            +'&queryid='+ctMap.get('DailyCheckLogQuery')+'?'
            //+'pv0=2016-07-13'
            +'pv0='+newTimestamp.format('yyyy-MM-dd')
            +'~pv1='+check.Office_Account__c
            //+'&templateId=a0n63000000KJh3'
            +'&templateid='+ctMap.get('DailyCheckLogTemplate')
            +'&DS7=3';
        system.debug('******************URL: '+docURL);
    }
    
}