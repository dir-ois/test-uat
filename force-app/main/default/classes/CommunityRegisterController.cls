/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public class CommunityRegisterController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String middleName {get; set;}
    public String title {get; set;}
    public String email {get; set;}
    public String confirmemail {get; set;}
    public String phone {get; set;}
    public String country {get; set;}
    public String address {get; set;}
    public String address2 {get; set;}
    public String city {get; set;}
    public String state {get; set;}
    public String zip {get; set;}
   // public String answer {get; set;}
   // public String secretQuestion {get; set;}
    //public String businessOwner {get; set;}
    //public String affilationType {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    //public String profileID {get;set;}
    public String ownerID {get;set;}
    public User cUser {get; set;}
    public String userName {get; set;}    
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    private map<String, String> values;
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    private String privateKey;
    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
    
    public CommunityRegisterController() {
        errormessage = '';
        errortype = '';
        errorDisplay = 'none';
        country  = 'USA';
        cUser = new User();
        // reCaptcha
        this.verified = false;
        
        // get profile details for user
        list <Key_Value_Store__c> kvs = new list<Key_Value_Store__c>([SELECT Name, Value__c from Key_Value_Store__c]);
        values = new map<string,string>();
        
        for ( Key_Value_Store__c k : kvs ){
            values.put(k.name, k.Value__c);
        }
        if ( values.ContainsKey('Recaptcha private key')){
            privateKey = values.get('Recaptcha private key');
        }
        
        
    }
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public List<SelectOption> getBussinesItems() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        
        return options;
    }
    
    public List<SelectOption> getAffiliationItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',' --Select--'));  
        options.add(new SelectOption('Owner','Owner'));  
        options.add(new SelectOption('CPA','CPA'));
        options.add(new SelectOption('Accounter','Accounter'));
        options.add(new SelectOption('Bookkeeper','Bookkeeper'));
        options.add(new SelectOption('Broker','Broker'));
        options.add(new SelectOption('Parent','Parent'));
        options.add(new SelectOption('Guardian','Guardian'));
        options.add(new SelectOption('Family Member','Family Member'));
        options.add(new SelectOption('Other','Other'));
        return options;
    }
    
    public List<SelectOption> getAffiliationVal() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getCountryVal() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = User.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
   /* 
    public List<SelectOption> getSecretQuestionVal() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = User.Secret_Question__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    */
    
    public void ShowAffiliated() {
        
    }
    
    public void SetState() {
        //if(country == 'US')
        state = '';
    }
    
    public PageReference registerUser() {
    
        errormessage = '';
        errortype = '';
        errorDisplay = 'none';
        
             
        
        
        String responseBody = makeRequest(baseUrl,
                'secret=' + privateKey +
                '&response='+ response
        );
        
        String success = getValueFromJson(responseBody, 'success');
        if(success.equalsIgnoreCase('true') || Test.isRunningTest()){

            if(String.isEmpty(firstName.trim())|| String.isEmpty(lastName.trim())) {
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'First Name, Last Name are required are must contain valid information.';
                return null;   
            }
    
            if((!String.isEmpty(firstName) && firstName.length() > 40) || (!String.isEmpty(lastName) && lastName.length() > 40)) {
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'First Name, Last Name should not have more that 40 characters.';
                return null;   
            }
            
            if(email != confirmemail) {
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'The email address does not match the confirmation. Please check the spelling and try again.';
                //errormessage = 'The email address provided already has an account. Please confirm the spelling of the email address entered. If you already have an account in the system, please use the forgot password option.';
                return null;  
            }
            
            if(!email.Contains('@')){
               errortype = 'alert alert-danger';
               errorDisplay = 'block'; 
               errormessage = 'The email address provided does not appear to be a valid email address. Please confirm the spelling of the email address entered.';
               return null;  
            }

            String profileID;
            
            // create user details
            //String profileId = '00er0000000DpBg'; // To be filled in by customer.
            if ( values.ContainsKey('Reg Community Profile')){
                profileID = values.get('Reg Community Profile');
            }
            else{
                    errortype = 'alert alert-danger';
                    errorDisplay = 'block'; 
                    errormessage = 'Profile not configured in custom setting. Please contact system administrator';
                    return null;
            }
        
            //get owner for account to be created
            if (values.containsKey('Integration User')){
                ownerID = values.get('Integration User');
            }
            else{
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'Owner ID not configured in custom setting. Please contact system administrator';
                return null;
            }
            
            String roleEnum = null; // To be filled in by customer.
            String accountId = null;// 001r0000007lzkY To be filled in by customer.
            
            //Organization myOrg = [SELECT ID, NamespacePrefix FROM Organization];
            if ( values.ContainsKey('Community UserID Suffix')){
                userName = email + values.get('Community UserID Suffix');
            }
            else{
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'Community UserID suffix not configured in custom setting. Please contact system administrator';
                return null;
            }
            System.debug('##### userName : ' + userName);
           if(!String.isEmpty(userName) && email.substringBefore('@').length() > 30) {
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'Your email address before the @sign cannot exceed 30 characters.';
                return null;   
            }
             else if( !String.isEmpty(userName) && email.length() > 70) {
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'Your email address cannot exceed 70 characters.';
                return null;   
            }
            
            List<User> existingUser = [SELECT Id FROM User WHERE username =: userName];
            if( existingUser.size() > 0 ) {
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'The email address provided already has an account. Please confirm the spelling of the email address entered. If you already have an account in the system, please use the forgot password option.';
                return null;  
            }
            
            
            if (!isValidPassword()) {
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = Label.site.passwords_dont_match;
                return null;   
            } 
            
            Pattern p = Pattern.compile('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[-!#$%=+_<>])[A-Za-z\\d-!#$%=+_<>]{8,}'); 
            if( !String.isEmpty(password) )
            {
                Matcher pm = p.matcher( password );  
                if( !pm.matches() )
                { 
                    errortype = 'alert alert-danger';
                    errorDisplay = 'block'; 
                    errormessage = 'Password must be 8 characters long and include at least one uppercase, one lowercase, one number and one character (- ! # $ % = + _ < >).';
                    return null;   
                }  
            }
            
            String userId;
            Savepoint sp = Database.setSavepoint();

            try {           
                
                //create account for user
                string rt = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeID();
                account a = new Account();
                a.RecordTypeId = rt;
                a.LastName = lastName;
                a.FirstName = firstName;
                a.MiddleName = MiddleName;
                a.PersonMailingStreet = address + '\n' + address2;
                a.PersonMailingCity = city;
                a.PersonMailingState = cUser.State__c;
                a.PersonMailingPostalCode = zip;
                a.PersonMailingCountry = cUser.Country__c;
                a.PersonEmail = email;
                a.Phone = Phone;
                a.OwnerId = ownerId;
                
                System.Debug('##### Creating account for user ' + a);
                insert a;
                
                accountID = a.Id;
                
                User u = new User();
                u.Username = userName;
                u.Email = email;
                u.Phone = phone;
                u.Title = title;
                u.FirstName = firstName;
                u.MiddleName = middleName;
                u.LastName = lastName;
                u.Street = address + '\n' + address2;
                u.City = city;
                u.State = cUser.State__c;
                u.PostalCode = zip;
                u.Country = cUser.Country__c;
                u.Country__c = cUser.Country__c;
                u.State__c = cUser.State__c;
                DateTime currentTime = System.now(); 
                Long timeInMili = currentTime.getTime()/1000; 
                String commNickname = email.substringBefore('@')+timeInMili;
                u.CommunityNickname = commNickname;
                System.debug('====>' + commNickname );
                u.ProfileId = profileId;

//            try {
                System.debug('##### Creating User: ' + u + ' -- AccountID: ' + accountID + ' -- Password: ' + password);
                
                userId = Site.createExternalUser(u, accountId, password);
                system.Debug('##### UserId: ' + userId);
 
            } catch(Site.ExternalUserCreateException ex) {
                List<String> errors = ex.getDisplayMessages();
                for (String error : errors)  {
                    errormessage += error + '\n';
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
                errortype = 'alert alert-danger';
                errorDisplay = 'block';
                
                // This message is used for debugging. Do not display this in the UI to the end user.
                // It has the information around why the user creation failed.
                System.debug(ex.getMessage());
                
                Database.rollback(sp);

            }
            catch(Exception ex) {
                errormessage = 'Unknown Exception trying to save your information to the system.  Please contact your System Administrator.' + ex.getLineNumber();
                errortype = 'alert alert-danger';
                errorDisplay = 'block';
                
                // This message is used for debugging. Do not display this in the UI to the end user.
                // It has the information around why the user creation failed.
                System.debug(ex.getMessage());
                
                Database.rollback(sp);

            }
        
            /* End replace - original code */
            
       
            
            if (userId != null) { 
    
                if (password != null && password.length() > 1) {
                    return Site.login(userName, password, '/CommunityRegistration');
                }
                else {
                    PageReference page = System.Page.CommunitySelfRegConfirm;
                    page.setRedirect(true);
                    return page;
                }
            }
        }
        else {
            // stay on page to re-try reCAPTCHA
            errormessage = 'Captcha verification expired. Please check the checkbox again before submitting.';
            errortype = 'alert alert-danger';
            errorDisplay = 'block';
            return null; 
        }

        
        return null;
    }
    
    public PageReference cancelBtn() {
        PageReference regPage = new PageReference('/CommunityLogin');
        regPage.setRedirect(true);
        return regPage;
    }
    
    /* Configuration */

    

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = '6LfD604UAAAAAAyj2VzMcyUP0bbYj20zZ_vSiPdg';
    public String publicKey { 
        get { 
            String pkey;
            if ( values.ContainsKey('Recaptcha public key')){
                pkey = values.get('Recaptcha public key');
            }
            return pkey; 
        }
    } 
    
     public String response  { 
        get { return ApexPages.currentPage().getParameters().get('g-recaptcha-response'); }
    }
    
    
    public string challenge {get; set;} { challenge = null; }
    public PageReference reset() {
        challenge = 'aaa';
        
        return null; 
    }   

    /**
     * Make request to verify captcha
     * @return      response message from google
     */
    private static String makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        
        try {
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return '{"success":false}';
    }   
    
    /**
     * to get value of the given json string
     * @params      
     *  - strJson       json string given
     *  - field         json key to get the value from
     * @return          string value
     */
    public static string getValueFromJson ( String strJson, String field ){
        JSONParser parser = JSON.createParser(strJson);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if(parser.getText() == field){
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }
        return null;
    }

}