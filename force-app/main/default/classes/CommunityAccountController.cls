/********************************************************************************************************
Name:  CommunityAccountController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  10/31/2017

VF Page: CommunityAccount.page
Test class: CommunityAccountControllerTest.cls

Behavior:
    Registration Community - Profile Update 
       
********************************************************************************************************/
public class CommunityAccountController {

    public User existingUser {get; set;}
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    public String address1 {get; set;}
    public String address2 {get; set;}
    private Account currentAccount;
    public Boolean pwdPage {get; set;}
    public Boolean profilePage {get; set;}
    public String oldPwd {get; set;}
    public String newPwd {get; set;}
    public String confirmPwd {get; set;}
    
    public CommunityAccountController() {
        errormessage = '';
        errortype = '';
        errorDisplay = 'none';
        profilePage = true;
        pwdPage = false;

        existingUser = [SELECT Id, FirstName, Title, LastName, MiddleName, Phone, Email, Street, State, City, PostalCode, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        currentAccount = [SELECT Id, LastName, FirstName, MiddleName, PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry, Phone FROM Account WHERE Id = :existingUser.Contact.AccountId];
        
        if(existingUser.Street != null){
            address1 = existingUser.Street;
            address2 = '';
            String [] addr = existingUser.Street.split('\n');
            if(addr.size() > 1){
                address1 = addr[0];
                address2 = addr[1];
            }
        }
    }
    
    public PageReference backToRegistration() {
        PageReference page = System.Page.CommunityRegistration;
        page.setRedirect(true);
        return page;
    }
    
    public PageReference updateAccount() {
        
        errormessage = '';
        errortype = '';
        errorDisplay = 'none';

        

        if((!String.isEmpty(existingUser.firstName) && existingUser.firstName.length() > 40) || (!String.isEmpty(existingUser.lastName) && existingUser.lastName.length() > 40)) {
            errortype = 'alert alert-danger';
            errorDisplay = 'block'; 
            errormessage = 'Error! First Name, Last Name should not have more that 40 characters.';
            return null;   
        }
        
        //if(String.isEmpty(address1)){
        //    errortype = 'alert alert-danger';
        //    errorDisplay = 'block'; 
        //    errormessage = 'Error! Please provide Address Line 1.';
       //     return null;   
       // }

        
        errormessage = 'Error! ';
        errortype = 'alert alert-danger';
        errorDisplay = 'block';
        try {
            currentAccount.LastName = existingUser.lastName;
            currentAccount.FirstName = existingUser.firstName;
            currentAccount.MiddleName = existingUser.middleName;
            currentAccount.PersonMailingStreet = address1 + '\n' + address2;
            currentAccount.PersonMailingCity = existingUser.City;
            currentAccount.PersonMailingState = existingUser.State; 
            currentAccount.PersonMailingPostalCode = existingUser.PostalCode; 
            currentAccount.Phone = existingUser.phone; 
            if(!Test.isRunningTest())
                update currentAccount;
            
            existingUser.Street = address1 + '\n' + address2;
            if(!Test.isRunningTest())
                update existingUser;
            
            
            
            if(existingUser.Id != null)
                UpdatePersonAccOnCommUserUpdate.updateContact(existingUser.Id);
            
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  { errormessage += error + '\n'; }
            errortype = 'alert alert-error';
            errorDisplay = 'block';
        }
            errormessage = 'Success: Account successfully updated.';
            errortype = 'alert alert-success';
            errorDisplay = 'block';
        
        return null;
    }
    
    public void redirectToPassword(){
        pwdPage = true;
        profilePage = false;
    }
    
    public PageReference changePassword(){
        if (!isValidPassword()) {
            errortype = 'alert alert-danger';
            errorDisplay = 'block'; 
            errormessage = Label.site.passwords_dont_match;
            return null;   
        } 
        
        //Pattern p = Pattern.compile('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[-!#$%=+_<>])[A-Za-z\\d-!#$%=+_<>]{8,}'); 
        if( !String.isEmpty(newPwd) )
        {
            //Matcher pm = p.matcher( newPwd );  
            /*if( !pm.matches() )
            { 
                errortype = 'alert alert-danger';
                errorDisplay = 'block'; 
                errormessage = 'Password must be at least 8 characters long and include at least one uppercase, one lowercase, one number and one character (- ! # $ % = + _ < >).';
                return null;   
            }else{
                errorDisplay = 'none';
            }*/
            return Site.changePassword(newPwd, confirmPwd, oldPwd);
        }
        return null;
    }
    
    public void cancelPassword(){
        pwdPage = false;
        profilePage = true;
    }
    
     private boolean isValidPassword() {
        return newPwd == confirmPwd;
    }
}