public class LRHandlerRegistrations {
    public static LRHandlerRegistrations classInstance = null;
    private static Boolean stopEWPRecursion {get; set;}
    
    public LRHandlerRegistrations () {
        stopEWPRecursion = false;
    }
    
    
    public static LRHandlerRegistrations getInstance(){
        if (null == classInstance) {
            classInstance = new LRHandlerRegistrations ();
        }
        return classInstance;
    }
    
    public void CreateRegistrations(list<License_Registration__c> newList)
    {
        if(stopEWPRecursion == null || !stopEWPRecursion){

            stopEWPRecursion = true;
            
            DescribeSObjectResult describeResult = License_Registration__c.sObjectType.getDescribe();
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            sObject newLicenseRegObj = NULL;
            
            String recordId = newList[0].Id; 
            String query = '';
            
            describeResult = License_Registration__c.sObjectType.getDescribe();
            fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            
            query =
                ' SELECT ' +
                String.join( fieldNames, ',' ) +
                ' FROM ' +
                describeResult.getName() +
                ' WHERE ' +
                ' Id = :recordId ' +
                ' '
                ;               
            List<License_Registration__c> toCloneLicRegObj = Database.query( query );
            
            License_Registration__c  lr = toCloneLicRegObj[0];
            
            if(isDuplicateRegistration(lr)){
                //System.debug('************* Duplicates found: ' +  lr.id);
                stopEWPRecursion = false;
                return;
            }

            //for(License_Registration__c  lr: toCloneLicRegObj){
            //System.debug('*************lr.Record_Type_Name__c: ' +  lr.Record_Type_Name__c);
            //System.debug('*************lr.Status_of_Payment__c: ' + lr.Status_of_Payment__c);
            //System.debug('*************lr.Status__c: ' + lr.Status__c);
            //System.debug('*************lr.Registration_Duration__c: ' + lr.Registration_Duration__c);
            //System.debug('*************lr.Submission_Type__c: ' + lr.Submission_Type__c);
            
            if( lr.Record_Type_Name__c == 'Entertainment_Work'
               && lr.Registration_Duration__c  == '10 Days - Temporary Permit'
               && lr.Submission_Type__c == 'Online')
            {
                newLicenseRegObj = lr.clone(false, false, false, false);
                //sObject newLicenseRegObj = new License_Registration__c();
                
                newLicenseRegObj.put('OwnerId', lr.OwnerId);
                //newLicenseRegObj.put('License_Registration_Number__c', oldMap.get(lr.Id).License_Registration_Number__c);
                //newLicenseRegObj.put('Applicant__c', lr.Applicant__c);
                //newLicenseRegObj.put('OwnerId', lr.OwnerId);
                //	I_Agree__c
                //newLicenseRegObj.put('License_Registration_Number__c', lr.License_Registration_Number__c);
                newLicenseRegObj.put('Enter_Your_Name__c', NULL);
                newLicenseRegObj.put('I_Agree_YesNo__c', NULL);
                newLicenseRegObj.put('Effective_Date__c', Date.today().addDays(11));
                newLicenseRegObj.put('Expiration_Date__c', Date.today().addMonths(6));
                newLicenseRegObj.put('Renewal__c', False);
                newLicenseRegObj.put('Internal_Notes__c', NULL);
                newLicenseRegObj.put('Ready_To_Submit__c', NULL);
                newLicenseRegObj.put('Ready_to_resubmit__c', NULL);
                newLicenseRegObj.put('Assigned_Deputy__c', NULL);
                newLicenseRegObj.Put('Imported_From__c', NULL);
                newLicenseRegObj.put('Submission_Type__c', 'Online');
                
                newLicenseRegObj.Put('Approval_Date_Time__c', NULL);
                newLicenseRegObj.Put('Approved__c', false);
                //newLicenseRegObj.put('Status_of_Payment__c', NULL );
                newLicenseRegObj.put('Status__c', 'Incomplete');
                newLicenseRegObj.put('Service_Type__c', 'New');
                newLicenseRegObj.put('Registration_Duration__c', '6 Months - Permit');
                newLicenseRegObj.Put('I_Acknowledge_Labor_Code_Compliance__c', NULL);
                newLicenseRegObj.Put('Enter_Your_Name_Labor_Code__c', NULL);
                newLicenseRegObj.Put('VIP_Date_Time_Submitted__c', NULL);
                
                newLicenseRegObj.Put('Payment_Date_Time__c', NULL);
                newLicenseRegObj.Put('Payment_Method__c', NULL);
                newLicenseRegObj.Put('Payment_Status__c', NULL);
                newLicenseRegObj.Put('Ready_For_Payment_Email_Sent__c', FALSE);
                newLicenseRegObj.Put('Amount_Paid_Online__c', NULL);
                newLicenseRegObj.Put('Amount_Paid_Manually__c', NULL);
                newLicenseRegObj.Put('Amount_Due__c', NULL);
                
                newLicenseRegObj.Put('Ready_to_Submit__c', NULL);
                //newLicenseRegObj.Put('Status_of_Payment__c', NULL);
                newLicenseRegObj.Put('Submit_Payment__c', NULL);
                
                If (lr.VIP_Template_Status__c != null)
                    newLicenseRegObj.put('VIP_Template_Status__c', lr.VIP_Template_Status__c.Replace('Completed', 'Incomplete'));
                
                System.debug('##### Ready to insert NewLicenseRegObj: ' + newLicenseRegObj);
                insert newLicenseRegObj;
                
                newLicenseRegObj.put('License_Registration_Number__c', lr.License_Registration_Number__c);
                
                update newLicenseRegObj;
                
                describeResult = Registration_Account__c.sObjectType.getDescribe();
                
                fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                
                query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' Registration__c = :recordId ' +
                    ' '
                    ;               
                List<Registration_Account__c> toRegistrationAccountsList = Database.query( query ); 
                
                List<Registration_Account__c> newRegistrationAccountsList = new List<Registration_Account__c>(); 
                for(Registration_Account__c toRegistrationAccountsObj: toRegistrationAccountsList){
                    Registration_Account__c newRegistrationAccountsObj = toRegistrationAccountsObj.clone(false, false, false, false);
                    newRegistrationAccountsObj.put('Registration__c', newLicenseRegObj.Id);
                    //                        System.debug('****************newRegistrationAccountsObj.Registration__c: ' + newRegistrationAccountsObj.Registration__c);
                    //                        System.debug('****************newRegistrationAccountsObj.Registration__r.Registration_Duration__c: ' + newRegistrationAccountsObj.Registration__r.Registration_Duration__c);
                    
                    newRegistrationAccountsList.add(newRegistrationAccountsObj);
                }
                insert newRegistrationAccountsList;
            }
            //}
            
            //           Map<Id, License_Registration__c> lrMap = new Map<Id, License_Registration__c>([SELECT Id, Account__c, Applicant__r.AccountId, Company_Type__c FROM License_Registration__c WHERE ID IN: newList]);
            stopEWPRecursion = false;
        }
    }
    
    private Boolean isDuplicateRegistration(License_Registration__c lreg){
        List<License_Registration__c> existingLreg = [SELECT id
                                                      , License_Registration_Type__c
                                                      , License_Registration_Number__c
                                                      , Record_Type_Name__c
                                                      , Submission_Type__c
                                                      , Registration_Duration__c
                                                      , Effective_Date__c
                                                      , Expiration_Date__c 
                                                      FROM License_Registration__c 
                                                      WHERE License_Registration_Number__c =: lreg.License_Registration_Number__c
                                                      AND Record_Type_Name__c = 'Entertainment_Work'
                                                      AND Registration_Duration__c = '6 Months - Permit'
                                                      AND Service_Type__c = 'New'
                                                      AND Status__c = 'Incomplete'];
        
        if(!existingLreg.isEmpty()){
            //System.debug('****************duplicate found: ');
            return true;
        }
        //System.debug('****************duplicate not found: ');
        return false;
    }
}