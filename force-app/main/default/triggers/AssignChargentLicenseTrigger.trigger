/* Takes the user as input and creates a chargent license for the community user
 * 
 * Fired from LicenseRegistrationAllHandler when the uer needs a license
 * Created by Jeremy Case 20180330
 */

trigger AssignChargentLicenseTrigger on AssignChargentLicense__e (after insert) {
	
    
    PackageLicense pl = [SELECT Id, AllowedLicenses, UsedLicenses FROM PackageLicense Where NamespacePrefix = 'ChargentOrders'];
    
    if(pl == null){
        System.debug('##### Unable to locate chargent package');
    } // end if
    else{
        set <id> userIds = new set<id>();
        
        
        for(AssignChargentLicense__e acl : trigger.new){
        	userIds.add(acl.UserId__c);
            
    	} //end for
        
        if(userIds.size() > 0){
            //get all user package licenses for the users in the trigger
            List<UserPackageLicense> uplList = new list<UserPackageLicense>([SELECT Id, PackageLicenseID, UserId FROM UserPackageLicense WHERE PackageLicenseID =: pl.Id AND UserId IN :UserIds]);
            
            for(UserPackageLicense upl : uplList){
                //remove users from set so as to not attempt to create a license for users who already have them
                System.Debug('##### the user: ' + upl.UserId + ' does not need a license. Skipping');
            	userIds.remove(upl.UserId);    
            } 
            
            if(userIds.size() > 0){
            	List<UserPackageLicense> uplsToAdd = new List<UserPackageLicense>();
                for(Id i : userIds){
                	System.debug('##### Need to create user license');
                    UserPackageLicense license = new UserPackageLicense();
                    license.PackageLicenseId = pl.Id;
                    license.UserId = i;
                    uplsToAdd.add(license);
                    System.debug('##### UPL added to list: ' + license); 
                }
                
                if(uplsToAdd.size() > 0){
                    try{
                        	System.debug('##### Inserting uplsToAdd');
                            insert uplsToAdd;
   
                    }
                    catch(DmlException e){
                        for(Integer i = 0; i > e.getNumDml(); i++){
                            System.debug(e.getDmlMessage(i));
                            String status = e.getDmlStatusCode(i);
                            System.debug(status + ' ' + e.getDmlMessage(i));
                            if(status.equals('LICENSE_LIMIT_EXCEEDED')){
                                System.debug('You tried to assign more licenses than available. ');
                            }
                            
                        }
                    }
                }
                    
            }
                            
        } // end if
           
    } // end else
   
    
} // end trigger