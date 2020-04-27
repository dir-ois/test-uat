/*******************************************************************************
* @author       Cloud Sherpas
* @date         5.19.2014
* @description  Class that is used to retrieve the LogConfig custom settings of 
*               the current user profile. 
*******************************************************************************/
public class LogConfigSettings{
    
    private static ApexLogSetting__c theSetting = ApexLogSetting__c.getInstance().Id != null ? 
    ApexLogSetting__c.getInstance() : apexLogSetting__c.getInstance(userinfo.getprofileid());
    private static List<RecordType> recordTypes = [SELECT Id, DeveloperName from RecordType WHERE SobjectType =: 'apexLog__c'];
    
    public static Id getDebugRecordType(){
        for(RecordType rt : recordTypes){
            if(rt.DeveloperName.tolowercase()  == 'debug'){
                return rt.Id;
            }
        }
        return null;       
    }
    
    
    public static Id getExceptionRecordType(){
        for(RecordType rt : recordTypes){
            if(rt.DeveloperName.tolowercase()  == 'exception'){
                return rt.Id;
            }
        }
        return null;       
    }
    
    public static  Boolean loggingEnabled(){

        return theSetting.DebugsEnabled__c;
    }
    public static  Boolean exceptionEnabled(){

        return theSetting.ExceptionsEnabled__c;
    }
}