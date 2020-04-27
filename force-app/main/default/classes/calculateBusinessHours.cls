/*********************************************************************

Author  : Robert Lucas
Date    : 6/17/2016

Usage   : This class is used to calculate a date based on number of days from a given start date and the BusinessHours object.

Dependencies : None

Modified Date : 
Comment : 

*********************************************************************/

public class calculateBusinessHours {
    
    BusinessHours bh;
    public calculatebusinessHours(){
        bh = [SELECT id, isActive, isDefault FROM BusinessHours WHERE isActive = true AND isDefault = true];
        
    }
    
    public Date addBusinessDays(Date startDate, Integer days){
        
        
        DateTime dt = datetime.newInstance(startDate.year(), startDate.month(),startDate.day());
        system.debug('datetime: ' + dt);
        system.debug('days: ' + days);

        Integer hours = 24;
        Integer minutes = 60;
        Integer seconds = 60;
        Integer milliseconds = 1000;
        Integer dayInMilliseconds = hours * minutes * seconds * milliseconds;
        

        dt = BusinessHours.add(bh.id, dt, days * dayInMilliseconds );
        while(!BusinessHours.isWithin(bh.id, dt)){
            
            dt = dt.addDays(1);
            system.debug(dt);
            
        }
        
        
        Date dtReturn = date.valueOf(dt);
        return dtReturn;
    }

}