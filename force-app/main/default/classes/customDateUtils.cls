public with sharing class customDateUtils {

    //private SObject sToUpdate {get;set;}
    //public String resultFieldValue {get; set;}
	
    // gets the date a specified number of days from the start date in either calendar days or weekdays
	// as defined by the "Selector" argument.
    public static void daysFrom(String objectType, ID recordID, Date startDate, String resultDateField, Integer dayCount, String countSelector){
        System.debug('****  Running daysFrom in the customDateUtils class');
        System.debug('****  Input variables: ObjecType:' + objectType +' recordID: ' + recordID + ' startDate: ' + startDate + 'resultDateField: ' + resultDateField + ' dayCount: ' + dayCount + 'countSelector: '+ countSelector);

        SObject sToUpdate;
        date knownDate = date.newInstance(1900, 1, 7);
        string soql = 'Select ID, ' + resultDateField + ' FROM ' + objectType + ' Where ID = \'' + recordID + '\' LIMIT 1';
        system.debug('SOQL::: ' + soql);
        sToUpdate = Database.query(soql);
        system.debug('resultDateField::: ' + resultDateField);
        String resultFieldValue = (string)sToUpdate.get(resultDateField);
        system.debug('sToUpdate::::' + sToUpdate);

        if(countSelector == 'Calendar'){
            System.debug('****  Running calendar day count');
            // add calendar days 
            Date finalDate = startDate.addDays(dayCount);
            System.debug('**** finalDate set to: ' + finalDate);
            // if final day is a weekend, go to next weekday
            while(math.mod(knownDate.daysBetween(finalDate), 7) == 0 || math.mod(knownDate.daysBetween(finalDate), 7) == 6){
                System.debug('****  finalDate is a weekend date. Incrementing');
                finalDate = finalDate.addDays(1);
            }
            
            //Update resultDate field with the calculated finalDate
            // ******************** Update Here ************************
            system.debug('Updating the ' + resultDateField + ' to the value ' + finalDate);
            Date newDate = (Date)sToUpdate.put(resultDateField, finalDate);
            update sToUpdate;
            system.debug('Set resultDate field value to be the date calculated using calendar days' + newDate);
        }
        else if (countSelector == 'weekdays'){
            System.debug('****  Running Weekdays count');
            // add weekedays
            Integer i = dayCount;
            system.debug('i = ' + i);
            Date finalDate = startDate;

            while(i > 0){          
                //iterate through the value of the dayCount adding the days until counted down to zero
                //Start with the next day
                system.debug('next day');
                finalDate = finalDate.addDays(1);
                system.debug('finalDate = ' + finalDate);
                system.debug('days mod: ' + math.mod(startDate.daysBetween(finalDate), 7));
                
                if((math.mod(knownDate.daysBetween(finalDate), 7) != 0 ) && (math.mod(knownDate.daysBetween(finalDate), 7) != 6 )){
                    i--;
                    system.debug('weekday day, decrement i. i= ' + i);
                }
                else
                    system.debug('WEEKEND DAY - Not Decrementing');

            }
            //Update resultDate field with the calculated finalDate
            // ********************* update here ************************
            system.debug('Updating the ' + resultDateField + ' to the value ' + finalDate);
            system.debug('sobjecttoupdate:: ' + sToUpdate);
            Date newDate = (Date)sToUpdate.put(resultDateField, finalDate);
            update sToUpdate;
            system.debug('sobjecttoupdate:: ' + sToUpdate + 'Update complete');
            system.debug('Set resultDate field value to be the date calculated using Weekdays::: ' + newDate);

        }
        else{
            //throw error
            // **************** Add Error message here *********************
            //.addError('No selection for how the days should be counted has been selected. Check with your system administrator to be sure all parameters are set correctly');
        }

	}

}