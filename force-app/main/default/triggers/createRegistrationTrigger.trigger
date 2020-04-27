trigger createRegistrationTrigger on Create_Registrations__e (after insert) {
    system.debug('##### Entering createRegistrationTrigger');
    
    LRHandlerRegistrations handler = LRHandlerRegistrations.getInstance();
    
    list<License_Registration__c> regList = new list<License_Registration__c>();
    
    for(Create_Registrations__e event : trigger.new){
        System.debug('##### Adding ' + event.RegistrationID__c + ' to reglist');
        regList.add(new License_Registration__c(Id = event.RegistrationID__c));
    }   
    
    if(regList.size() > 0){
        system.debug('##### Calling Create_Registrations__e with list: ' + regList);
        handler.CreateRegistrations(regList);
    }
}