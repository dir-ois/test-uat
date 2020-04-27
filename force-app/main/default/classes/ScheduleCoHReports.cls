/*Schedules the RunCoHReports class to run on the 1st of every month
To set the schedule, assuming there isn't one already, paste the following lines in the execute anonymous window (CTRL+e) in the developer console:

ScheduleCoHReports monthlyCoHReports = new ScheduleCoHReports();
// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
String runTime = '30 15 1 1 * ?'; //runs the 1st of the month at 1:15:30 am
String jobID = System.schedule('Run Cash on Hand Reports Monthly', runTime, monthlyCoHReports);

*/

global class ScheduleCoHReports implements Schedulable{
    global void execute(SchedulableContext sc) {
        RunCoHReports runCoHReports = new RunCoHReports();
        runCoHReports.RunCoHReports();
    }
}