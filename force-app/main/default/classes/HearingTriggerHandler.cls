public class HearingTriggerHandler{
    public static void updateMeetingParticipants(List<Hearing__c> newList){
        Map<Id,Id> caseIdMap = new Map<Id,Id>();
        Map<Id,String> recordTypeIdMap = new Map<Id,String>();
        for(Hearing__c h : newList){
            caseIdMap.put(h.Case__c, h.id);
            recordTypeIdMap.put(h.id,h.Record_Type_Name__c);
        }
        
        List<Meeting_Participant__c> mps = new List<Meeting_Participant__c>();
        for(DIR_Case__c c : [select id, (select id from Case_Roles__r where Case_Role_Status__c = 'Active') from DIR_Case__c where Id IN :caseIdMap.keySet()]){
            if(c.Case_Roles__r != null){
                for(Case_Role__c cr : c.Case_Roles__r){
                    Meeting_Participant__c mp = new Meeting_Participant__c();
                    if(recordTypeIdMap.get(caseIdMap.get(c.Id)).contains('Conference'))
                       mp.RecordTypeId = Schema.SObjectType.Meeting_Participant__c.getRecordTypeInfosByName().get('Conference').getRecordTypeId(); 
                       mp.Attendance__c = 'Invited';
                       mp.Case__c = c.id;
                       mp.Case_Role__c = cr.id;
                       mp.Meeting__c = caseIdMap.get(c.id);
                       mps.add(mp);
                    
                }
            }
        }
        if(mps.size() > 0){
            insert mps;
        }
    }
    
    public static void sendEmailToDeputy(List<Hearing__c> newList){
        Map<Id,List<Hearing__c>> caseIdMap = new Map<Id,List<Hearing__c>>();
        for(Hearing__c h : newList){
            if(h.Status__c == 'Scheduled' && h.Meeting_Start_Date_Time__c != null && h.Meeting_Type__c != null){
                if(caseIdMap.containsKey(h.Case__c)){
                    List<Hearing__c> hs = caseIdMap.get(h.Case__c);
                    hs.add(h);
                    caseIdMap.put(h.Case__c, hs);
                }else{
                    caseIdMap.put(h.Case__c, new Hearing__c[]{h});
                }
            }
        }
        
        EmailTemplate et = [Select Id, HtmlValue, Body, subject from EmailTemplate where DeveloperName = 'Linked_Case_Meeting_Notification' LIMIT 1];
        
        Map<Id,List<String>> emailsMap = new Map<Id,List<String>>();
        for(DIR_Case__c c : [select id, (select id,Linked_Case__r.Assigned_Deputy_Email__c from Linked_Cases1__r WHERE Linked_Case__r.Assigned_Deputy_Email__c != null) from DIR_Case__c where Id IN :caseIdMap.keySet() AND Assigned_Deputy__r.User__r.Profile.Name = 'RCI User']){
            if(c.Linked_Cases1__r != null){
                List<String> emailList = new List<String>();
                for(Linked_Case__c lc : c.Linked_Cases1__r){
                    emailList.add(lc.Linked_Case__r.Assigned_Deputy_Email__c);
                }
                emailsMap.put(c.id, emailList);
            }
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String baseURL = system.URL.getSalesforceBaseUrl().toExternalForm();
        for(DIR_Case__c c : [select id, Name, Assigned_Deputy__r.User__c, Case_Number__c from DIR_Case__c where Id IN :caseIdMap.keySet() AND Assigned_Deputy__r.User__r.Profile.Name = 'RCI User']){
            if(emailsMap.containsKey(c.id)){
                for(Hearing__c h : caseIdMap.get(c.id)){
                    Messaging.SingleEmailMessage emsg = new Messaging.SingleEmailMessage();
                    emsg.setTemplateId(et.Id);
                    emsg.setToAddresses(emailsMap.get(c.id));
                    emsg.setTargetObjectId(c.Assigned_Deputy__r.User__c);
                    //emsg.setWhatId(h.id);
                    emsg.saveAsActivity = false;
                    String htmlBody = String.isNotBlank(et.htmlValue) ? et.htmlValue : et.Body;
                    htmlBody = htmlBody.replace('{!Hearing__c.Meeting_Type__c}', h.Meeting_Type__c);
                    htmlBody = htmlBody.replace('{!Hearing__c.Meeting_Start_Date_Time__c}', h.Meeting_Start_Date_Time__c.format());
                    htmlBody = htmlBody.replace('{!DIR_Case__c.Case_Number__c}', c.Case_Number__c);
                    htmlBody = htmlBody.replace('{!DIR_Case__c.Name}', c.Name);
                    htmlBody = htmlBody.replace('{!Hearing__c.Link}',  + baseURL + '/' + h.id);
                    htmlBody = htmlBody.replaceAll(']]>','');
                    emsg.setHtmlBody(htmlBody);
                    emsg.setSubject(et.Subject);
                    emails.add(emsg);
                }
            }
        }
        if(emails.size() > 0){
            Messaging.sendEmail(emails);
        }
    }
}