global class printRegDetailsController {
    
    private static List<License_Registration__c> regListTemp;
    private static String listNameBase;
    private static String listName;
    private static Integer alpha;
    private static List<LicenseRegistration> registrationList;
    private static Integer listCount;
    private static List<String> listRegistrations  = new List<String>();    
    private static Map<String,List<License_Registration__c>> mapIdList;
    
    public printRegDetailsController(){
        listCount = Integer.valueOf(apexpages.currentpage().getparameters().get('listCount'));
        listRegistrations = apexpages.currentpage().getparameters().get('myListString').split(',');                              
    }
    
    @RemoteAction
    public static List<LicenseRegistration> getnewRegList(Integer listCount, String myList){
        
        
                
        listNameBase = 'myList';
        listName = '';
        List<String> listRegistrations  = new List<String>();            
        List<LicenseRegistration> registrationList  = new List<LicenseRegistration>();
        
        for (alpha = 0; alpha < listCount; alpha++){
            if (alpha == 0){
                listName = listNameBase;
                listRegistrations.add(myList);
            }else{
                listName = listNameBase+alpha;
                listRegistrations.add(myList);
            }
        }             
        
        List<String> listString;
        List<String> listRegNum;
        List<License_Registration__c> regHistory;
        
        
        System.debug('***regIdList-'+listRegistrations.size());
        System.debug('Starting heap size: ' +  Limits.getHeapSize());
        alpha = 0;
        List<License_Registration__c> regListTemp=new List<License_Registration__c>();
        for(String listRegistration :listRegistrations) {
            System.debug('***regIdList-'+alpha);
            alpha++;
            listString = null;
            listString = listRegistration.split(',');
            for(License_Registration__c lrRec:[SELECT id,Legal_Entity_Name__c,status__c,Company_Type__c,License_Registration_Number__c,Effective_Date__c,Expiration_Date__c,
                           Mailing_Address_Line_1__c,Mailing_Address_Line_2__c,Mailing_City__c,Mailing_Postal_Code__c,Mailing_State__c,Mailing_Country__c,County__c,
                           Physical_Business_Address_Line_1__c,Physical_Business_Address_Line_2__c,Physical_Business_City__c,Physical_Business_Postal_Code__c,Physical_Business_State__c,
                           Physical_Business_Country__c,Account_Email__c,PEO_Name__c,PEO_Phone__c,PEO_Email__c,Lease_Through_PEO__c,Workers_Comp_Selection__c,
                           Workers_Compensation_Carrier__c,Insurance_Carrier__c,WCI_Cert_Number__c,WCI_Initial_Certification_Date__c,WCI_Expiration_Date__c,
                           Exempt_Reason__c,
                           (select id,Name from DBAS__r),
                           (select id,License_Number__c,License_Type__c, Effective_Date__c,Expiration_Date__c,License_Registration_Number__c  from Registrations__r),
                           (select id,Corp_or_LLC_ID__c,Federal_Employer_Identification_Number__c,PresidentsName__c,VicePresidentName__c,TreasurerName__c,SecretaryName__c,
                            CEOName__c,AgentofServiceName__c,AgentofServiceFirstName__c,AgentofServiceLastName__c,Mailing_Street__c,Mailing_Address_Line_2__c,Mailing_City__c,Mailing_Zip_Code__c,Mailing_State__c,
                            Mailing_Country__c,First_Name__c,Last_Name__c,recordtype.developername,toLabel(Joint_Venture_Company_Type__c),Legal_Entity_Name__c,Corp_or_LLC_Name__c
                            from Registration_Accounts__r)
                            FROM License_Registration__c where id IN:listString LIMIT 300]){
                                regListTemp.add(lrRec);
                                
            }
            listRegNum = new List<String>();
            system.debug('heap before reg list temp loop - '+Limits.getHeapSize());
            for(License_Registration__c lObj:regListTemp){
                if(lObj.License_Registration_Number__c!=null){
                    listRegNum.add(lObj.License_Registration_Number__c);
                }
            }
            System.debug('heap regListTemp: ' +  Limits.getHeapSize());
            regHistory = [Select id,Effective_Date__c,Expiration_Date__c,License_Registration_Number__c 
                          FROM License_Registration__c 
                          WHERE License_Registration_Number__c IN:listRegNum
                          AND (status__c='Active' OR status__c='Expired' OR status__c='Disqualified') LIMIT 50000 ];
            //build list keyed by license registration number  
            listRegNum = new List<String>();
            mapIdList = new Map<String,List<License_Registration__c>>() ;
            for(License_Registration__c lObj:regHistory){
                List<License_Registration__c> lstNew =new List<License_Registration__c>();
                if(mapIdList.containsKey(lObj.License_Registration_Number__c)) {
                    
                    lstNew = mapIdList.get(lObj.License_Registration_Number__c);                
                }
                lstNew.add(lObj);
                mapIdList.put(lObj.License_Registration_Number__c,lstNew);
            } 
            //clear space
            regHistory =new List<License_Registration__c>(); 
            System.debug('Heap reg history: ' +  Limits.getHeapSize());
            // wrap license registration data with registration history
            Integer alpha = 1;
            for(License_Registration__c regObj:regListTemp){
                System.debug('Heap during wrap: ' +  Limits.getHeapSize());
                List<License_Registration__c> regHistNew =new List<License_Registration__c>(); 
                if (mapIdList.containsKey(regObj.License_Registration_Number__c)){
                    regHistNew = mapIdList.get(regObj.License_Registration_Number__c);
                    registrationList.add(new LicenseRegistration(regObj,regHistNew));
                } 
                alpha++;
            }
            System.debug('Heap after wrap: ' +  Limits.getHeapSize());
            System.debug('reglist--'+registrationList);
            System.debug('reg list temp--'+regListTemp);
            System.debug('end of merge');
            
            
        }
                            
        return registrationList;
        
        
    }
    
    // CSK - Use LicenseRegistration to populate data for an individual card adding parent License Registrations and child license history for a given License Registrations 
    public class LicenseRegistration{
        public List<ChildLicenseRegistrations> RegistrationHistory {get;set;}   //this will be child list of License Registrations based on License Registraion Number
        public License_Registration__c License_RegistrationRoot {get;set;}  //this will be parent of a given License Registrations
        public String FormattedExpirationDate{get;set;}
        public String FormattedEffectiveDate{get;set;}
        public LicenseRegistration(License_Registration__c root, List<License_Registration__c> hist){
            License_RegistrationRoot = new License_Registration__c();
            RegistrationHistory = new List<ChildLicenseRegistrations>();
            License_Registration__c histRegObj = new License_Registration__c();
            for (License_Registration__c histObj:hist){
                RegistrationHistory.add(new ChildLicenseRegistrations(histObj));
            }
            License_RegistrationRoot = root;
            FormattedExpirationDate='';
            FormattedEffectiveDate='';
            if(root.Expiration_Date__c!=null)
                FormattedExpirationDate = root.Expiration_Date__c.format();
            if(root.Effective_Date__c!=null)
                FormattedEffectiveDate = root.Effective_Date__c.format();
        }
    }
    
    // CSK - These are the desired child registration history record elements
    public class ChildLicenseRegistrations {
        public Date Effective_Date {get; set;}
        public Date Expiration_Date {get; set;}
        public String FormattedExpirationDate{
            get;set;
        }
        public String FormattedEffectiveDate{get;set;}
        public String License_Registration_Number {get; set;}
        public ChildLicenseRegistrations(License_Registration__c regObj){
            License_Registration_Number = regObj.License_Registration_Number__c;
            Effective_Date = regObj.Effective_Date__c;
            Expiration_Date = regObj.Expiration_Date__c;
            FormattedExpirationDate='';
            FormattedEffectiveDate='';
            if(regObj.Expiration_Date__c!=null)
                FormattedExpirationDate = regObj.Expiration_Date__c.format();
            if(regObj.Effective_Date__c!=null)
                FormattedEffectiveDate = regObj.Effective_Date__c.format();
        }
    }
}