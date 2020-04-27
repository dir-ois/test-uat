/*************************************************************************************

Class     :  purgeChargentOrderScheduler .cls

Developer :  Kavya Somashekar

Created   :  20 11, 2018

Objective :  scheduler class for the batch apex purgeChargentOrderBatch .cls

Requirement : 

*************************************************************************************/
global class purgeChargentOrderScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      purgeChargentOrderBatch b = new purgeChargentOrderBatch(); 
      database.executebatch(b);
   }
}