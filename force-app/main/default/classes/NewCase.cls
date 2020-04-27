public class NewCase {

    public integer step { get; set; }
    
    public string caseURL { get; set; }
    
    public DIR_Case__c cs { get; set; }
    
    public recordType rt {get; set;}
    
    public String rtString {get; set;}
    
    public boolean dup {get; set;}

    public NewCase(ApexPages.StandardController sc) {
        cs = (DIR_Case__c)sc.getRecord();
        //cs = new DIR_Case__c();
        cs.Employer__c = ApexPages.currentPage().getParameters().get('CF00Nm0000000Q6jJ_lkid');
    
        rtString = ApexPages.currentPage().getParameters().get('RecordType');
        
        
        if(rtString != null){
            rt = [SELECT ID, Name from RecordType WHERE ID = :rtString LIMIT 1];
            system.debug('********RT Name: ' + rt.Name);
        }
        
        step = (cs.Employer__c == null ? 1 : 2);


        //RedirectOrMessage();
        
    }
    
    public PageReference RedirectOrMessage() {
        User objUser = [Select Id,Profile.Name From User where Id =: UserInfo.getUserId()];
        
        if(objUser.Profile.Name == 'RCI User'){  
        
            Schema.DescribeSObjectResult dsr = DIR_Case__c.SObjectType.getDescribe();
            String defaultRecordTypeId = '';
            
            for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordTypeId = rti.getRecordTypeId();
                }
            }
            
            if(string.isNotBlank(defaultRecordTypeId)){
                
                return new PageReference('/' + DIR_Case__c.sObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1' +
                                        '&RecordType=' + defaultRecordTypeId + 
                                        (ApexPages.currentPage().getParameters().get('retURL') != null  ? '&retURL=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('retURL'), 'UTF-8') : '')); 
            }
            
        }
        
        
        
        if (rt!= null && rt.Name != 'BOFE Intake' && rt.Name != 'BOFE Investigation'){
           system.debug('***RecordType***' + ApexPages.currentPage().getParameters().get('RecordType'));
           system.debug('***retURL***' + ApexPages.currentPage().getParameters().get('retURL'));
           string retURL = ApexPages.currentPage().getParameters().get('retURL');
           if(retURL != null){
               return new PageReference('/' + DIR_Case__c.sObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1' +
                                    '&RecordType=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('RecordType'), 'UTF-8') +
                                    '&retURL=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('retURL'), 'UTF-8')
                                    ); 
           }else{
               return new PageReference('/' + DIR_Case__c.sObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1' +
                                    '&RecordType=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('RecordType'), 'UTF-8')
                                    ); 
           }
        }
        
        Account acc = new Account();
        if (cs.Employer__c == null) {
            return null;
        }
       /*
        if (rt.Name != 'BOFE Intake' && rt.Name != 'BOFE Investigation'){
            acc = [SELECT ID, Name FROM Account WHERE Id = :cs.Employer__c];
            return new PageReference('/' + DIR_Case__c.sObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1' +
                                    '&RecordType=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('RecordType'), 'UTF-8') +
                                    '&retURL=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('retURL'), 'UTF-8') +
                                    '&CF00Nm0000000Q6jJ_lkid=' + EncodingUtil.UrlEncode(acc.Id, 'UTF-8') +
                                    '&CF00Nm0000000Q6jJ=' + EncodingUtil.UrlEncode(acc.Name, 'UTF-8')
                                );
        }
        */
        list<DIR_Case__c> caseNr = [SELECT Id FROM DIR_Case__c WHERE Employer__c = :cs.Employer__c AND (RecordType.Name = 'BOFE Intake' OR RecordType.Name = 'BOFE Investigation')];
        if ((rt!= null && caseNr.size() == 0) || dup==true) {
            acc = [SELECT ID, Name FROM Account WHERE Id = :cs.Employer__c];
            return new PageReference('/' + DIR_Case__c.sObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1' +
                                    '&RecordType=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('RecordType'), 'UTF-8') +
                                    '&retURL=' + EncodingUtil.UrlEncode(ApexPages.currentPage().getParameters().get('retURL'), 'UTF-8') +
                                    '&CF00Nm0000000Q6jJ_lkid=' + EncodingUtil.UrlEncode(acc.Id, 'UTF-8') +
                                    '&CF00Nm0000000Q6jJ=' + EncodingUtil.UrlEncode(acc.Name, 'UTF-8')
                                );
        } else {
            step = 3;
            caseURL = URL.getSalesforceBaseURL().toExternalForm() + '/' + caseNr.get(0).Id;
            return null;
        }
        //return null;
    }
    
    public PageReference validateCase(){
        cs = [select id,name,RecordTypeId,NAICS_Code__c,DLSE_Program__c,Employer_Industry__c from DIR_Case__c where id = :cs.id];
        string naicsCode = cs.NAICS_Code__c;
        string dlseProgram = cs.DLSE_Program__c;
        string employerIndustry = cs.Employer_Industry__c;
        //string recordTypeText = cs.Record_Type_Text__c;
        string recTypeName = Schema.getGlobalDescribe().get('DIR_Case__c').getDescribe().getRecordTypeInfosById().get(cs.RecordTypeId).getName();
        
        if (recTypeName.contains('BOFE')) {
            if(employerIndustry != 'Not Specified' && !String.isBlank(dlseProgram) && String.isBlank(naicsCode)) {
                return new PageReference('/apex/NewViolation?id=' + cs.id);
            }else {
                if (String.isBlank(dlseProgram)){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please set the DLSE Program on the case record before adding any Case Issues.');
                    ApexPages.addMessage(myMsg);
                }
                if (employerIndustry == 'Not Specified' || String.isBlank(naicsCode)){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please add the appropriate NAICS code to the employer’s account and verify that industry has been set correctly before adding any Case Issues.');
                    ApexPages.addMessage(myMsg);
                }
            }
        }else{
            return new PageReference('/apex/NewViolation?id=' + cs.id);
        }
        return null;
    }
}