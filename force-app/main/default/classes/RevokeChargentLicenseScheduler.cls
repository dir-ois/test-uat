/*****************************************************************************************

Class     :  RevokeChargentLicenseScheduler .cls

Developer :  Kavya Somashekar

Created   :  20 11, 2018

Objective :  scheduler class for the batch apex RevokeChargentLicenseBatch.cls

Requirement : 

****************************************************************************************/
global class RevokeChargentLicenseScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      RevokeChargentLicenseBatch b = new RevokeChargentLicenseBatch(); 
      database.executebatch(b,2000);
   }
}