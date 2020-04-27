/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        // Below code added by Kavya Somashekar for req 170024
        
        list<AssignChargentLicense__e> assignLicense = new list<AssignChargentLicense__e>();  
        //user details
        List<User> userList = [select Id,contactid from user where id =:UserInfo.getUserId()];
        //Check if the Community user has 1 or more registrations in Pending Payment status
        system.debug('userList[0].contactid*****'+userList[0].contactid);
        List<License_Registration__c> lastLR = [SELECT Id, Ready_to_Submit__c,Balance__c FROM License_Registration__c 
                                                    WHERE Ready_to_Submit__c = 'Yes' 
                                                    AND Balance__c >0 
                                                    AND Applicant__c =: userList[0].contactid];
        if(!lastLR.isEmpty()){
              System.debug('##### Registration record meets criteria for license to be assigned to the logged in user');
                AssignChargentLicense__e a = new AssignChargentLicense__e();
                a.UserId__c = userList[0].Id;
                assignLicense.add(a);
                list<Database.SaveResult> results = EventBus.publish(assignLicense);
            
                for(Database.SaveResult sr : results){
                    if(sr.isSuccess()){
                        system.debug('##### Successfully published assign license event');
                    }
                    else{
                        for(Database.Error err : sr.getErrors()){
                            System.debug('##### Error returned from publishing assign license event: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
                        }
                    }
                }
        }
         
        return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
}