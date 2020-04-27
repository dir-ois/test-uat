public with sharing class appointment_Methods {

public static void beforeInsert(List<Appointment__c> newList){
Map<Id, List<Appointment__c>> positionToAppointments = new Map<Id, List<Appointment__c>>();
Map<Id, List<Appointment__c>> form1ToAppointments = new Map<Id, List<Appointment__c>>();

Set<Id> positionIds = new Set<Id>();
Set<Id> form1Ids = new Set<Id>();
for(Appointment__c a : newList) {
if(a.Position__c != null) {
positionIds.add(a.Position__c);
}
if(a.Form_1__c != null) {
form1Ids.add(a.Form_1__c);
}
//BAO added five (5) lines below to prevent users from creating Appointment for CLOSED or ABOLISHED position 11/25/2014

for(Position__c p : [select Status__c from Position__c where Id in :positionIds]) {
if (p.Status__c == 'closed' || p.Status__c == 'abolished' ) {
a.addError('!!!You are creating new Appointment for a CLOSED/ABOLISHED position. This action is not allowed. Please click CANCEL to return to previous page!!!');
} 
} 

}

for(Position__c p : [select Id, Serial_Number__c, (select Temporarily_Vacant__c, Start_Date__c, End_Date__c from Appointments__r order by End_Date__c desc) from Position__c where Id in :positionIds]) {
if(p.Appointments__r.size() > 0 && Integer.valueOf(p.Serial_Number__c) < 900) {
positionToAppointments.put(p.Id, p.Appointments__r);
}
}

for(Form_1__c f1 : [select Id, (select Temporarily_Vacant__c, Start_Date__c, End_Date__c from Appointments__r) from Form_1__c where Id in :form1Ids]) {
if(f1.Appointments__r.size() > 0) {
form1ToAppointments.put(f1.Id, f1.Appointments__r);
}
}

System.debug(positionToAppointments);

Map<Id, Position__c> positionsToUpdate = new Map<Id, Position__c>();
for(Appointment__c a : newList) {
if(positionToAppointments.containsKey(a.Position__c)) {
if(checkAppointmentDates(positionToAppointments.get(a.Position__c), a.Start_Date__c, a.End_Date__c, null)) {
a.addError('There is already an appointment on this position for given date range.');
continue;
}
}
if(form1ToAppointments.containsKey(a.Form_1__c)) {
a.addError('There can be only one appointment on a Form 1');
continue;
}
if(a.Position__c != null) {
Position__c temp = new Position__c(Id = a.Position__c);
if(positionsToUpdate.containsKey(a.Position__c)) {
temp = positionsToUpdate.get(a.Position__c);
}
//if(a.End_Date__c == null || a.End_Date__c > system.today()) {
system.debug(positionToAppointments.get(a.Position__c));
if(positionToAppointments.get(a.Position__c) != null && positionToAppointments.get(a.Position__c).size() > 0) {
Date latestDate = positionToAppointments.get(a.Position__c).get(0).End_Date__c;
if(latestDate != null && a.End_Date__c != null && latestDate < a.End_Date__c) {
temp.Separation_Date__c = a.End_Date__c;
}
else {
temp.Separation_Date__c = null;
}
}
else {
temp.Separation_Date__c = a.End_Date__c;
}
temp.Status__c = 'Filled';
//}
positionsToUpdate.put(a.Position__c, temp);
}
} 
if(positionsToUpdate.values().size() > 0) {
update positionsToUpdate.values();
}
}

/*public static void afterInsert(List<Appointment__c> newList){
Set<Id> currentPositionSet = new Set<Id>();
List<Appointment__c> previousAppointmentUpdates = new List<Appointment__c>();
List<Position__c> positionUpdates = new List<Position__c>();
for ( Integer i=0;i<newList.size();i++ ){
if ( newList[i].Previous_Appointment__c != null && newList[i].Last_Day_Worked__c != null ){
previousAppointmentUpdates.add(new Appointment__c(Id=newList[i].Previous_Appointment__c,End_Date__c=newList[i].Last_Day_Worked__c));
}
if ( newList[i].Position__c != null ){
currentPositionSet.add(newList[i].Id);
}
}

//Update the Previous Appointment's End Date
//Workflow Rule to update Appointment Status when End Date is reached
//Roll-up Max Appointment End Dates to Position
//Workflow Rule on Position to update Status if currently Filled and max end date is met


}*/

public static Boolean checkAppointmentDates(List<Appointment__c> appts, Date startDate, Date endDate, Id origApptID) {
for(Appointment__c a : appts) {
System.debug('Appointments: ' + a);
system.debug(startDate);
system.debug(endDate);
system.debug(origApptID);
if(a.Id == origApptID) {
continue;
}
if(a.End_Date__c == null) {
if(startDate >= a.Start_Date__c || endDate > a.Start_Date__c || endDate == null) {
system.debug('Condition 1');
return true;
}
}
else {
if(endDate == null && (startDate >= a.Start_Date__c && startDate < a.End_Date__c)) {
system.debug('Condition 2');
return true;
}
if(endDate != null && ((startDate >= a.Start_Date__c && startDate < a.End_Date__c) || (endDate > a.Start_Date__c && endDate <= a.End_Date__c))) {
system.debug('Condition 3');
return true;
}
}
}

return false;
}

public static void beforeUpdate(List<Appointment__c> newList, List<Appointment__c> oldList) {
Map<Id, List<Appointment__c>> positionToAppointments = new Map<Id, List<Appointment__c>>();

Set<Id> positionIds = new Set<Id>();
for(Appointment__c a : newList) {
positionIds.add(a.Position__c);
}

for(Position__c p : [select Id, Serial_Number__c, (select Temporarily_Vacant__c, Start_Date__c, End_Date__c from Appointments__r) from Position__c where Id in :positionIds]) {
if(p.Appointments__r.size() > 0 && Integer.valueOf(p.Serial_Number__c) < 900) {
positionToAppointments.put(p.Id, p.Appointments__r);
}
}

for(Appointment__c a : newList) {
if(positionToAppointments.containsKey(a.Position__c)) {
if(checkAppointmentDates(positionToAppointments.get(a.Position__c), a.Start_Date__c, a.End_Date__c, a.Id)) {
a.addError('There is already an appointment on this position for given date range.');
}
}
}
}

public static void afterUpdate(List<Appointment__c> newList, List<Appointment__c> oldList){
Map<Id, List<Appointment__c>> positionToAppointments = new Map<Id, List<Appointment__c>>();
Set<Id> positionIds = new Set<Id>();
for(Appointment__c a : newList) {
positionIds.add(a.Position__c);
}

/*for(Position__c p : [select Id, (select Start_Date__c, End_Date__c from Appointments__r) from Position__c where Id in :positionIds]) {
if(p.Appointments__r.size() > 0) {
positionToAppointments.put(p.Id, p.Appointments__r);
}
}*/

List<Position__c> positionsToUpdate = new List<Position__c>();
for(Position__c p : [select Id, Status__c, Serial_Number__c, Separation_Date__c, (select Temporarily_Vacant__c, Start_Date__c, End_Date__c from Appointments__r order by End_Date__c asc) from Position__c where Id in :positionIds]) {
if(p.Appointments__r.size() > 0 && Integer.valueOf(p.Serial_Number__c) < 900) {
system.debug('Position: ' + p);
system.debug(p.Appointments__r);

// BAO commented out one (1) line below
//p.Status__c = 'Vacant';
p.Separation_Date__c = null;

// Getting the offset of the current appointment on this position
Integer i = 0;
for(; i < p.Appointments__r.size(); i++) {
Appointment__c a = p.Appointments__r.get(i);
if(a.End_Date__c == null) {// || a.End_Date__c > system.today()) {
break;
}
}
system.debug(i);
system.debug(p.Appointments__r.size());
/*if(i < p.Appointments__r.size()) {
Appointment__c a = p.Appointments__r.get(i);
//if(system.today() < a.End_Date__c || a.End_Date__c == null) {
if(a.Temporarily_Vacant__c == true) {
p.Status__c = 'Temporarily Vacant';
}
else {
p.Status__c = 'Filled';
}
p.Separation_Date__c = a.End_Date__c;
//}
}
else */ if(i > 0 && p.Appointments__r.size() > 0){
Appointment__c a = p.Appointments__r.get(i - 1);
//if(system.today() < a.End_Date__c || a.End_Date__c == null) {

//BAO added lines here to prevent status 'CLOSED' or 'ABOLISHEDD' from changing after editing appt.
if (p.Status__c == 'closed') {
p.Status__c = 'closed';
}
else if (p.Status__c == 'abolished') {
p.Status__c = 'abolished';

}

/*BAO ended codes here*/ else if(a.Temporarily_Vacant__c == true) {
p.Status__c = 'Temporarily Vacant';

}

else if(a.End_Date__c != null) {// && a.End_Date__c > system.today()){
p.Status__c = 'Vacant';
}
else {
p.Status__c = 'Filled';
}
p.Separation_Date__c = a.End_Date__c;
}
}
else if(p.Appointments__r.size() == 0 && p.Status__c == 'Filled') {
p.Status__c = 'Vacant';
}

positionsToUpdate.add(p);
}
update positionsToUpdate;
}

public static void afterDelete(List<Appointment__c> oldList){
Set<Id> positionIds = new Set<Id>();
for(Appointment__c a : oldList) {
positionIds.add(a.Position__c);
}

system.debug('OLDLIST: ' + oldList);

List<Position__c> positionsToUpdate = new List<Position__c>();
for(Position__c p : [select Id, Status__c, Serial_Number__c, Separation_Date__c, (select Temporarily_Vacant__c, Start_Date__c, End_Date__c from Appointments__r) from Position__c where Id in :positionIds]) {
if(p.Appointments__r.size() > 0 && Integer.valueOf(p.Serial_Number__c) < 900) {
system.debug('Position: ' + p);
system.debug(p.Appointments__r);
p.Status__c = 'Vacant';
p.Separation_Date__c = null;

// Getting the offset of the current appointment on this position
Integer i = 0;
for(i = 0; i < p.Appointments__r.size(); i++) {
Appointment__c a = p.Appointments__r.get(i);
if(a.End_Date__c == null ){//|| a.End_Date__c > system.today()) {
break;
}
}
/*if(i < p.Appointments__r.size()) {
Appointment__c a = p.Appointments__r.get(i);
//if(system.today() < a.End_Date__c || a.End_Date__c == null) {
if(a.Temporarily_Vacant__c == true) {
p.Status__c = 'Temporarily Vacant';
}
else {
p.Status__c = 'Filled';
}
p.Separation_Date__c = a.End_Date__c;
//}
}
else */
if(i > 0 && p.Appointments__r.size() > 0){
Appointment__c a = p.Appointments__r.get(i - 1);
//if(system.today() < a.End_Date__c || a.End_Date__c == null) {
if(a.Temporarily_Vacant__c == true) {
p.Status__c = 'Temporarily Vacant';
}
else if(a.End_Date__c != null) {// && a.End_Date__c > system.today()){
p.Status__c = 'Vacant';
}
else {
p.Status__c = 'Filled';
}
p.Separation_Date__c = a.End_Date__c;
//}
}
}
else if(p.Appointments__r.size() == 0 && p.Status__c == 'Filled') {
p.Status__c = 'Vacant';
p.Separation_Date__c = null;
}

positionsToUpdate.add(p);
}
update positionsToUpdate;
}
}