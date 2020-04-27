/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class CommunityForgotPasswordController {
    public String username {get; set;}   
     
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    
    public CommunityForgotPasswordController () {
        errormessage = '';
        errortype = '';
        errorDisplay = 'none';
    }
 
    
    public PageReference forgotPassword() {
      if(!String.isEmpty(username)) {
        
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
          
          List<User> existingUser = [SELECT Id FROM User WHERE username =: userName];
          if( existingUser.size() == 0 ) {
              String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
              errortype = 'alert alert-danger';
              errorDisplay = 'block'; 
              //errormessage = ' An account cannot be found with that email address. Please ' +  '<a href=\"https://mycadir.force.com/registrations/CommunityRegister"> create a new login account </a>' + 'to register or renew your registration.';
              errormessage = ' An account cannot be found with that email address. Please ' +  '<a href=\"' + sfdcBaseURL + '/registrations/CommunityRegister">' +  'create a new login account </a>' + 'to register or renew your registration.';
              return null;  
          }
          
          boolean success = Site.forgotPassword(username);
          PageReference pr = Page.CommunityForgotPasswordConfirm;
          pr.setRedirect(true);
          
          if (success) {        
              return pr;
          }
          
          }
          
       else {
          errortype = 'alert alert-danger';
          errorDisplay = 'block'; 
          errormessage = 'Username is required.';
          return null;
      }

      return null;
    }
}