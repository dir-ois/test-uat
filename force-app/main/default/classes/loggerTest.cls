/*******************************************************************************
* @author         Sapient
* @date           December 2018
* @return         
* @description    Test class for testing the class named 
*                 logger
*******************************************************************************/
@isTest
public class loggerTest {

/*******************************************************************************
* @author         Sapient
* @date           December 2018
* @return         
* @description    This test methods creates log exceptions intentionally to check
                  the logger methods of logger class
* @Revision(s) 
*******************************************************************************/

    static testMethod void testlogger() {
        
        list<RecordType> apexLogrts = [SELECT Id, Name from RecordType WHERE SobjectType =: 'apexLog__c'];
             ApexLogSetting__c logconfig = new ApexLogSetting__c ();
             logconfig.ExceptionsEnabled__c=true;
             logconfig.debugsEnabled__c=true;
             insert logconfig;
            Test.startTest(); 
            
            //test push method
            logger.push('createAccount','AccountDML');     
            logger.debug('Test debug message');
            //generate exception
            try 
            {
              insert new Account();
            
            }   
            catch (System.DmlException ex) {
                
              logger.debugException(ex); 
              logger.debugException(ex.getmessage());   
          
            }
            
            //test pop method
            logger.pop();
            logger.setInConstuctor();
            List<apexlog__c> testLog = [Select ExceptionType__c, Message__c from apexlog__c];
            System.assertEquals('Test debug message', testLog[0].Message__c);
            System.assert(testLog[1].Message__c.indexOf('fail') > -1);
            Test.stopTest();
            
        
     
   }
   
}