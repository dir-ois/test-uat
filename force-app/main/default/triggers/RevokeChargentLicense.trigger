/* Takes the user as input and revokes a chargent license from the community user
 * 
 * Fired from RevokeChargentLicenseBatch when the userLicense needs to be recoked
 * 
 */

trigger RevokeChargentLicense on Revoke_Chargent_License__e (after insert) {
     set <id> uplIds = new set<id>();
       
     for(Revoke_Chargent_License__e rcl : trigger.new){
         uplIds.add(rcl.UserPackageLicenseId__c);            
     } 
     
    List<UserPackageLicense> uplList = new list<UserPackageLicense>([SELECT Id, PackageLicenseID, UserId FROM UserPackageLicense 
                                                                        WHERE Id IN: uplIds]);
    if(!uplList.isEmpty()){
        try{
            delete uplList; //DML operation
        }catch(Exception e){
            system.debug('exception message :'+e.getMessage());
        }
    }
                                                                         
}