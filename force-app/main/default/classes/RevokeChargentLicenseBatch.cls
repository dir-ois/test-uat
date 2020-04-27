/*************************************************************************************************************
Name:  RevokeChargentLicenseBatch.cls
Author:  vertiba
Date:  11/14/2018
Modified by: 
Date:
Test class: 

Behavior: Fetch All the usres with chargent licenses whose last login is greater than 2 hours
           Reallocate nightly at 3AM 
***********************************************************************************************************/
global without sharing class RevokeChargentLicenseBatch implements Database.Batchable<sObject>, Database.Stateful { 
    @TestVisible
    private DateTime selectedTime = System.Now().addHours(-2);
    
    public RevokeChargentLicenseBatch() {
        
    }
   
    global Database.QueryLocator start(Database.BatchableContext info){
    //should the license Id and profile Id be updated in custom labels?
        PackageLicense pl = [SELECT Id, AllowedLicenses, UsedLicenses FROM PackageLicense Where NamespacePrefix = 'ChargentOrders'];
        Id p = [SELECT id FROM profile WHERE Name='Community Registrations User'].id;
        string q;

        if(pl == null){
            System.debug('##### Unable to locate chargent package');
        } 
        else{
            //get all user package licenses 
            q = 'SELECT Id, PackageLicenseID, UserId FROM UserPackageLicense WHERE PackageLicenseID =\''+pl.Id+'\' AND UserId IN (SELECT Id FROM User WHERE ProfileId =:p  AND LastLoginDate <=: selectedTime) LIMIT 2000';
        }   
        
        return Database.getQueryLocator(q);
    }

    global void execute(Database.BatchableContext info, List<sObject> scopeX){
        List<UserPackageLicense > scope = (List<UserPackageLicense >)scopeX;
        List<Revoke_Chargent_License__e> revokeLicense = New List<Revoke_Chargent_License__e>();
                
        for(UserPackageLicense upl: scope){
            Revoke_Chargent_License__e a = new Revoke_Chargent_License__e();
            a.UserPackageLicenseId__c = upl.Id;
            revokeLicense.add(a);
        }
         if(revokeLicense.size() > 0){
            System.debug('##### Attempting to publish revoke license event');
            list<Database.SaveResult> results = EventBus.publish(revokeLicense);
            
            for(Database.SaveResult sr : results){
                if(sr.isSuccess()){
                    system.debug('##### Successfully published revoke license event');
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug('##### Error returned from publishing revoke license event: ' +
                         err.getStatusCode() +
                         ' - ' +
                         err.getMessage());
                    }
                }
            }
            
        }
        
    }
    
    global void finish(Database.BatchableContext info) {
        
    }
    
   
}