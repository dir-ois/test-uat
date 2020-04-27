/*********************************************************************

Author  : Robert Lucas
Date    : 8/15/2016

Usage   : This class handles the importing of Person Accounts and facilitates the creation and relation of
            Case Roles and Payees.

Dependencies : 

Modified Date : 
Comment : 

*********************************************************************/



public without sharing class form40ImportController 
{
    public transient string nameFile{get;set;}
    public transient string name {get;set;}
    public transient Blob contentFile{get;set;}
    public Boolean showProcessButton {get; set;}
    public Boolean showImportButton {get; set;}
    private String[] fileLines = new String[]{};
    private List<Account> accsToUpload;
    private List<Payee__c> payeesToUpload;
    public String CaseId;
    public DIR_Case__c dirCase;
    public List<recordWrapper> accPayeeList;
    public Map<String,recordWrapper> accPayeeMap;
    public static Decimal lineNumber {get; set;}
    public static Boolean invalidFileFormat {get; set;}
    
    public form40ImportController()
    {
        showProcessButton = true;
        showImportButton = true;

        if(ApexPages.currentPage().getParameters().containsKey('msg'))
        {
            if('success'.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('status')))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ApexPages.currentPage().getParameters().get('msg')));
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ApexPages.currentPage().getParameters().get('msg')));
            }
            
        }
        caseId = ApexPages.currentPage().getParameters().get('id');
        
        dirCase = [SELECT id, name, Total_Wages_Balance_Due__c FROM DIR_Case__c WHERE id = :caseId];
        
        accPayeeList = new List<recordWrapper>();
        accPayeeMap = new Map<String, recordWrapper>();
        
    }
    
    /***This function reads the CSV file and inserts records into the Account object. ***/
    public Pagereference ImportFile()
    {
        String pageMsg = '';        
        invalidFileFormat = false;
        List<Import__c> allCSVRecords = new List<Import__c>();
        pageReference pr = Page.form40Import;
        pr.getParameters().put('id', CaseId);
        pr.setRedirect(false);
        try
        {
            //Validate file is csv
            if(!nameFile.endsWith('.csv')){
                /*pr.getParameters().put('status', 'error');
                pr.getParameters().put('msg', 'The file uploaded is not a CSV file type.');*/
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The file uploaded is not a CSV file type.');
                ApexPages.addMessage(errormsg);
                return pr;
            }
            //Convert the uploaded file which is in BLOB format into a string
            nameFile =blobToString( contentFile,'ISO-8859-1');
            
            //Now sepatate every row of the excel file
            filelines = nameFile.split('\r');
            
            //Iterate through every line and create an Account and Payee record for each row
            accsToUpload = new List<Account>();
            payeesToUpload = new List<Payee__c>();                
            
            allCSVRecords = parseCSV(contentFile.toString(),true, caseId);

            if(invalidFileFormat == false)
            {
                //Sum Factors and wages
                Decimal sumFactors = 0;
                Decimal sumWages = 0;
                
                for(Import__c record : allCSVRecords){
                    sumFactors += record.Factor__c;
                    sumWages += record.Gross_Wages_Paid__c;
                }
                
                if(sumFactors != 100){
                    pageMsg = 'Error: The Factors must add up to 100';
                    //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error: The Factors must add up to 100');
                    //ApexPages.addMessage(errormsg);
                }
                
                if(sumWages != dirCase.Total_Wages_Balance_Due__c){
                    pageMsg = 'Error: The total Gross Wages Paid must equal the Total Wages Due on the case';
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error: The total Gross Wages Paid must equal the Total Wages Due on the case');
                    ApexPages.addMessage(errormsg);
                }
                
                sumFactors = 0;
                sumWages = 0;

                if(String.isNotBlank(pageMsg)){
                    /*pr.getParameters().put('status', 'error');
                    pr.getParameters().put('msg', pageMsg);*/
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR, pageMsg);
                    ApexPages.addMessage(errormsg);
                    return pr;
                }

                insert allCSVRecords;
            }
            else
            {
                allCSVRecords = new List<Import__c>();
            }

            if(allCSVRecords.size() <= 0)
            {
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file: Invalid File Format at line: \n' + (lineNumber + 1));
                ApexPages.addMessage(errormsg);
                 
                return pr;
            }
                
         }
         catch(Exception e)
         {
             /*pr.getParameters().put('status', 'error');
             pr.getParameters().put('msg', 'An error has occured reading the CSV file'+e.getMessage());*/
             
             ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file: '+e.getMessage());
             ApexPages.addMessage(errormsg);
             
             return pr;
         }
         finally
         {
            fileLines = null;
            nameFile = null;
            name = null;
            contentFile = null;
         }     

        if(String.isBlank(pageMsg) && String.isBlank(pr.getParameters().get('msg'))){
            showImportButton = false;
            /*pr.getParameters().put('status', 'success');
            pr.getParameters().put('msg', 'The file has been successfully imported, click the \'Process File\' button to start processing the import.!');*/
            ApexPages.Message successMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'The file has been successfully imported, click the \'Process File\' button to start processing the import.');
            ApexPages.addMessage(successMsg);
        }
        
        return pr;
    }

    public Pagereference ProcessFile()
    {
        String pageMsg = '';
        List<Import__c> allCSVRecords = new List<Import__c>();
        pageReference pr = Page.form40ProcessFile;
        pr.getParameters().put('id', CaseId);
        pr.setRedirect(false);

        ProcessImportRecords myBatchObject = new ProcessImportRecords();
        myBatchObject.caseId = caseId;

        Database.executeBatch(myBatchObject);

        ApexPages.Message successMsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'The records are now being processed. You will received an email when the processing will be complete!');
        ApexPages.addMessage(successMsg);

        showProcessButton = false;

        return pr;
    } 
     
        /**
         This function convers the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
     */
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }  
    
    
   public static List<Import__c> parseCSV(String contents,Boolean skipHeaders, String caseId) 
   {        
        List<Import__c> allCSVRecords = new List<Import__c>();
    
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }

        Integer num = 0;
        //remove the firt line containing the csv column headers
        lines.remove(0);         
        lineNumber = 0;

        for(String line : lines) 
        {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');             
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            Import__c csvRecord = new Import__c();

            for(String field : fields) 
            {
                if (field.startsWith('"') && field.endsWith('"')) 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } 
                else if (field.startsWith('"')) 
                {
                    makeCompositeField = true;
                    compositeField = field;
                } 
                else if (field.endsWith('"')) 
                {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } 
                else if (makeCompositeField) 
                {
                    compositeField +=  ',' + field;
                } 
                else 
                {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            

            if(cleanFields.size() != 18)
            {
                system.debug(cleanFields.size());
                system.debug(cleanFields);
                invalidFileFormat = true;
                break;
            }

            csvRecord.Case_Management__c = caseId;

            if(cleanFields[0].contains(','))
            {
                csvRecord.Employee_First_Name__c = cleanFields[0].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Employee_First_Name__c = cleanFields[0].trim();
            }

            if(cleanFields[1].contains(','))
            {
                csvRecord.Employee_Last_Name__c = cleanFields[1].trim().removeStart('"').removeEnd('"');
            }
            else
            {
                csvRecord.Employee_Last_Name__c = cleanFields[1].trim();
            }

            if(!String.isEmpty(cleanFields[14]))
            {
                csvRecord.Deductions_Federal_Withholding__c = Decimal.valueof(cleanFields[14]);
            }
            if(!String.isEmpty(cleanFields[12]))
                csvRecord.Deductions_Medicare__c = Decimal.valueof(cleanFields[12]);
            if(!String.isEmpty(cleanFields[11]))
                csvRecord.Deductions_Social_Security__c = Decimal.valueof(cleanFields[11]);
            if(!String.isEmpty(cleanFields[10]))
                csvRecord.Deductions_State_Disability_Insurance__c = Decimal.valueof(cleanFields[10]);
            if(!String.isEmpty(cleanFields[13]))
                csvRecord.Deductions_State_Withholding__c = Decimal.valueof(cleanFields[13]);
            if(!String.isEmpty(cleanFields[15]))
            {
                csvRecord.Deductions_Total__c = Decimal.valueof(cleanFields[15]);
            }
            csvRecord.Employee_City__c = cleanFields[3];  
            csvRecord.Employee_State__c = cleanFields[4];
            csvRecord.Employee_Street__c = cleanFields[2];
            csvRecord.Employee_Zip__c = cleanFields[5];
            if(!String.isEmpty(cleanFields[17]))
            {
                csvRecord.Factor__c = Decimal.valueOf(cleanFields[17].trim());
            }
            if(!String.isEmpty(cleanFields[9]))
                csvRecord.Gross_Wages_Paid__c = Decimal.valueof(cleanFields[9]);
            if(!String.isEmpty(cleanFields[16]))
                csvRecord.Net_Wages_Paid__c = Decimal.valueof(cleanFields[16]);
            csvRecord.Period_Covered_by_Adjustment__c = cleanFields[7];
            csvRecord.SSN__c = cleanFields[6];
            if(!String.isEmpty(cleanFields[8]))
                csvRecord.Total_Wage_Assessment__c = Decimal.valueof(cleanFields[8]);

            allCSVRecords.add(csvRecord);
            lineNumber++;
        }       

        return allCSVRecords;       
    }



    public class recordWrapper{

        public String key;

        public String firstname;
        public String lastName;
        public String shippingStreet;
        public String shippingCity;
        public String shippingState;
        public String shippingPostalCode;
        public String SSN;

        public String periodCovered;
        public String wageAsssesment;
        public String grossWages;
        public String disabilityInsurance;
        public String socialSecurity;
        public String medicare;
        public String stateWitholding;
        public String federalWitholding;
        public String totalDeductions;
        public String netWages;
        public String factor;
        public String caseManagment;
    }       
}