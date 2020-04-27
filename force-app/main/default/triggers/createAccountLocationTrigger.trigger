trigger createAccountLocationTrigger on Create_Accounts_Locations__e (after insert) {
    system.debug('##### Entering createAcountLocationTrigger');
    list<License_Registration__c> regList = new list<License_Registration__c>();
 
     for(Create_Accounts_Locations__e event : trigger.new){
         system.debug('##### Adding ' + event.RegistrationID__c + ' to reglist');
         regList.add(new License_Registration__c(Id = event.RegistrationID__c));
     }   
    
    //LicenseRegistrationAllHandler handler = new LicenseRegistrationAllHandler();
    if(regList.size() > 0){
        system.debug('##### Calling CreateAccountsAndLocations with list: ' + regList);
        //handler.CreateAccountsAndLocations(regList);
        LRHandlerAccountLocations.CreateAccountsAndLocations(regList);
    }
}