public with sharing class GenerateDailyCalendarController {
    
    public Hearing__c hearing {get;set;}
    public Id userId {get;set;}
    public String docURL {get;set;}
    public String selectedRT {get;set;}
    public List<SelectOption> rtList {get;set;}
    //public Map<string, string> ctMap {get;set;}
    public List<Conga_Template_Mapping__c> objCTMapping {get;set;}
    
    public GenerateDailyCalendarController(){
        hearing = new Hearing__c();
        userId = userInfo.getUserId();
        rtList = new List<SelectOption>();
        List<RecordType> tempList = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Hearing__c' ORDER BY Name asc];
        for(RecordType rt : tempList){
            rtList.add(new SelectOption(rt.Id, rt.Name));
        }
        selectedRT = rtList[0].getValue();
        
        // get mapping settings from Conga Template Mapping custom setting
        objCTMapping = [Select Name, RecordID__c FROM Conga_Template_Mapping__c WHERE Mapping_Group__c = 'WCA Daily Calendar'];
        system.debug('objCTMapping:::: ' +objCTMapping);
        
    }
    
    
    public void setURL(){
        Map<string, string> ctMap = new Map<string, string>();
        system.debug('objCTMapping:::: ' + objCTMapping);
        for (Conga_Template_Mapping__c c : objCTMapping){
            system.debug('c.Name: ' + c.Name + ' & c.RecordID__c: ' + c.RecordID__c);
            ctMap.put(c.Name, c.RecordID__c); 
        }

        if(ctMap.isEmpty())
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'CTMap is empty'));
        
        system.debug('ctMAP::::: ' + ctmap);
        docURL += ''
            +'&id=' + userId
            //+'&queryid=[Calendar]a0md00000064cjs?'
            +'&queryid=[Calendar]'+ctMap.get('Calendar')+'?'
            +'pv0='+hearing.Meeting_Start_Date_Time__c.format('yyyy-MM-dd')
            +'~pv1='+hearing.Meeting_End_Date_Time__c.format('yyyy-MM-dd')
            +'~pv2='+hearing.WCA_Office__c
            +'~pv3='+selectedRT
            //+',[Office]a0md00000064cjc?pv0='+hearing.WCA_Office__c
            +',[Office]'+ctMap.get('Office')+'?pv0='+hearing.WCA_Office__c
            //+'&templateid=a0nd0000005OStj'
            +'&templateid='+ctMap.get('TemplateID')
            +'&ofn=Calendar'
            +'&DS7=3';
        system.debug('******************URL: '+docURL);
    }
    
}