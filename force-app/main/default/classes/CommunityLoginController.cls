/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunityLoginController {

    public Boolean isMaintenanceMsg { get; set; }

    public String maintenanceMsg { get; set; }
    global String username{get;set;}
    global String password{get;set;}
    global Boolean isIE {get; set;} 
    global String userAgent {get; set;}

    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    public String errormessage {get; set;}
    public String errormessage2 {get; set;}
    
    global CommunityLoginController () {
        userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        isIE = true;
        //if(userAgent.contains('internet explorer'))
            //isIE = true;
        if(!Label.Reg_Maintenance_Msg.equalsIgnorecase('off')){
            isMaintenanceMsg = true;
        } 
        errorDisplay = 'none';
    }
    global PageReference forwardToCustomAuthPage() {
        return new PageReference( '/CommunityLogin');
    }
    global PageReference login() {
        // get profile details for user
        list <Key_Value_Store__c> kvs = new list<Key_Value_Store__c>([SELECT Name, Value__c from Key_Value_Store__c]);
        map<String, String> values = new map<string,string>();
        String profileID;
        for ( Key_Value_Store__c k : kvs ){
            values.put(k.name, k.Value__c);
        }
        String CommunitySuffix = '';
        //Organization myOrg = [SELECT ID, NamespacePrefix FROM Organization];
        if ( values.ContainsKey('Community UserID Suffix')){
            CommunitySuffix = values.get('Community UserID Suffix');
        }
        
        if(!String.isEmpty(CommunitySuffix) && !username.contains(CommunitySuffix)) {
            username = username + CommunitySuffix;
        }
         
        PageReference pf = Site.login(username, password, null);
        if (pf==null)
        {
            errortype = 'alert alert-danger';
            errorDisplay = 'block'; 
            errormessage = 'The Username and Password combination entered does not match our records.';
            errormessage2 = 'After 3 unsuccessful login attempts, the account is locked for 30 minutes.';
        }
        return pf;
    }
    
    global PageReference SignIn() {
        return new PageReference( '/CommunityRegister');
    }
    global PageReference ForgotPassword() {
        return new PageReference( '/CommunityForgotPassword');
    }
}