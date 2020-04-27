/*To set the schedule, assuming there isn't one already, paste the following lines in the execute anonymous window (CTRL+e) in the developer console:
ScheduleCreateOAMTRecords createOAMT = new ScheduleCreateOAMTRecords();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String runTime = '30 15 1 1 * ?'; //runs the 1st of the month at 1:15:30 am, because really, who'd be awake then?
String jobID = System.schedule('Create OAMT Records Monthly', runTime, createOAMT);
*/

global class ScheduleCreateOAMTRecords implements Schedulable{
    global void execute(SchedulableContext sc) {
        CreateOAMTRecords createOAMTRecords = new CreateOAMTRecords();
        createOAMTRecords.CreateOAMTRecords();
    }
}