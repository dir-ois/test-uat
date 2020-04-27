global without sharing class TransmittalSchedule {

	global void execute(SchedulableContext SC) {
    	
    	Database.executeBatch(new TransmittalBatch(), 200);
    	
    }

}