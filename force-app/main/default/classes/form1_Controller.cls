public with sharing class form1_Controller {
    public String renderMode {get; set;}
    public String margins {get; set;}
    public Form1Wrapper fw1 {get; set;}
    
    public List<SelectOption> TypistOptions {get; set;}
    public List<SelectOption> TimeBaseOptions {get; set;}
    public List<SelectOption> TenureOptions {get; set;}
    public List<SelectOption> DutiesSameOptions {get; set;}
    public List<SelectOption> TransactionTypeOptions {get; set;}
    public List<SelectOption> RequestOptions {get; set;}
    public List<SelectOption> ApprovalOptions {get; set;}
    
    public Form_1__c form1 {get; set;}
    public Boolean WFD_Requested_Effective_Date {get; set;}
    public Boolean WFD_Special_Instructions_Date {get; set;}
    public Boolean WFD_Position_Open_Date {get; set;}
    public Boolean WFD_Certification_Date {get; set;}
    public Boolean WFD_Form_607_Date {get; set;}
    public Boolean WFD_Approval_Date {get; set;}
    
    public String dateFormatError {get; set;}
    public String positionDoesntExistError {get; set;}
    public String positionCannotBeEmptyError {get; set;}
    public String positionAlreadyExistsError {get; set;}
    
    public String pageTitle {get; set;}
    public String approvalStatus {get; set;}
    //Bao added 1 line 11/29/2016
    public String F1ApprovalStatus {get; set;}
    public String pdfURL {get; set;}
    
    public form1_Controller(ApexPages.StandardController con) {
        Form_1__c thisForm = (Form_1__c) con.getRecord();
        
        // Condition for a new Form 1
        if(ApexPages.currentPage().getParameters().get('id') == null) {
            fw1 = new Form1Wrapper();
            renderMode = '';
            pageTitle = 'New Form 1';
            dateFormatError = 'Date format \'MM-DD-YYYY\'';
            positionDoesntExistError = '';
            positionCannotBeEmptyError = '';
            positionAlreadyExistsError = '';
            //margins = '0.5in 1in 0.5in 1in';
            WFD_Requested_Effective_Date = true;
            WFD_Special_Instructions_Date = true;
            WFD_Position_Open_Date = true;
            WFD_Certification_Date = true;
            WFD_Form_607_Date = true;
            WFD_Approval_Date = true;
            
            TypistOptions = new List<SelectOption>();
            TypistOptions.add(new SelectOption('Range A', 'Range A'));
            TypistOptions.add(new SelectOption('Range B (over 50% dictaphone)', 'Range B (over 50% dictaphone)'));
            
            TimeBaseOptions = new List<SelectOption>();
            TimeBaseOptions.add(new SelectOption('Full Time', 'Full Time'));
            TimeBaseOptions.add(new SelectOption('Part Time', 'Part Time'));
            TimeBaseOptions.add(new SelectOption('', 'None'));
            
            TenureOptions = new List<SelectOption>();
            TenureOptions.add(new SelectOption('Permanent', 'Permanent'));
            TenureOptions.add(new SelectOption('Limited Term', 'Limited Term'));
            TenureOptions.add(new SelectOption('', 'None'));
            
            DutiesSameOptions = new List<SelectOption>();
            DutiesSameOptions.add(new SelectOption('Yes', 'Yes'));
            DutiesSameOptions.add(new SelectOption('No', 'No'));
            DutiesSameOptions.add(new SelectOption('', 'None'));
            
            TransactionTypeOptions = new List<SelectOption>();
            TransactionTypeOptions.add(new SelectOption('Establishment of New Position', 'Establishment of New Position'));
            TransactionTypeOptions.add(new SelectOption('Limited Term Appointment from Temporary Help Funds', 'Limited Term Appointment from Temporary Help Funds'));
            TransactionTypeOptions.add(new SelectOption('Change of Present Position', 'Change of Present Position'));
            TransactionTypeOptions.add(new SelectOption('', 'None'));
            
            RequestOptions = new List<SelectOption>();
            RequestOptions.add(new SelectOption('Yes', 'Yes'));
            RequestOptions.add(new SelectOption('No', 'No'));
            RequestOptions.add(new SelectOption('', 'None'));
            
            ApprovalOptions = new List<SelectOption>();
            ApprovalOptions.add(new SelectOption('Approved as Requested', 'Approved as Requested'));
            ApprovalOptions.add(new SelectOption('Approved as modified', 'Approved as modified'));
            ApprovalOptions.add(new SelectOption('Disapproved', 'Disapproved'));
            ApprovalOptions.add(new SelectOption('', 'None'));
            
            if(ApexPages.currentPage().getParameters().get('pid') != null) {
                List<Position__c> tempPosList = [select Id, Class_Title__c, Name from Position__c where Id = :ApexPages.currentPage().getParameters().get('pid')];
                if(tempPosList.size() == 1) {
                    Position__c temp = tempPosList.get(0);
                    fw1.SEC1_Class_Title = temp.Class_Title__c;
                    fw1.SEC1_Position_Number = temp.Name;
                    if(fw1.SEC1_Position_Number != null && fw1.SEC1_Position_Number != '') {
                        String[] parts = fw1.SEC1_Position_Number.split('-');
                        fw1.SEC1_Position_Number_Part1 = (parts.size() >= 1) ? parts[0] : '';
                        fw1.SEC1_Position_Number_Part2 = (parts.size() >= 2) ? parts[1] : '';
                        fw1.SEC1_Position_Number_Part3 = (parts.size() >= 3) ? parts[2] : '';
                        fw1.SEC1_Position_Number_Part4 = (parts.size() >= 4) ? parts[3] : '';
                    }
                }
            }
        }
        
        // Condition for viewing Form 1 as a PDF
        else if(ApexPages.currentPage().getParameters().get('pdf') != null){
            //Bao added "f.Form_1_Unique_Number__c" below, 2/13/2016)
            thisForm = [Select f.Form_1_Unique_Number__c, f.SEC5_Form_607_Number__c, f.SEC1_Part_Time_Fraction__c, f.SEC2_Part_Time_Fraction__c, f.Unit__c, f.SystemModstamp, f.Status__c, f.Serial__c, f.SEC5_Position_Open__c, f.SEC5_Position_Open_Date__c, f.SEC5_MGR_List__c, f.SEC5_Initials__c, f.SEC5_Form_607_Date__c, f.SEC5_Certification_Date__c, f.SEC5_Approval__c, f.SEC5_Approval_Date__c, f.SEC4_Title__c, f.SEC4_Special_Instructions_Date__c, f.SEC4_RoomNo2__c, f.SEC4_RoomNo1__c, f.SEC4_Request_Informal_List__c, f.SEC4_Request_Certification__c, f.SEC4_Phone2__c, f.SEC4_Phone1__c, f.SEC4_Name2__c, f.SEC4_Name1__c, f.SEC4_Explanation__c, f.SEC4_Division__c, f.SEC3_Remarks__c, f.SEC2_Working_Headquarters__c, f.SEC2_Typist__c, f.SEC2_Transaction_Type__c, f.SEC2_Top__c, f.SEC2_Time_Base__c, f.SEC2_Tenure__c, f.SEC2_Source_of_Funds__c, f.SEC2_Position_Number__c, f.SEC2_Limited_Term_Months__c, f.SEC2_Fill_Type__c, f.SEC2_Duties_Same__c, f.SEC2_Class_Title2__c, f.SEC2_Bottom__c, f.SEC1_Working_Headquarters__c, f.SEC1_Typist__c, f.SEC1_Time_Base__c, f.SEC1_Tenure__c, f.SEC1_Position_Number__c, f.SEC1_Name_of_Incumbent__c, f.SEC1_Limited_Term_Months__c, f.SEC1_Class_Title__c, f.Requested_Effective_Date__c, f.Part_Time_Fraction__c, f.Name, f.Location__c, f.Limited_Term_Months__c, f.LastModifiedDate, f.LastModifiedById, f.IsDeleted, f.Id, f.Fill_Type__c, f.Date_to_Certifications__c, f.Date_received_by_Personnel_Analyst__c, f.Date_Closed__c, f.CreatedDate, f.CreatedById, f.Classification__c, f.Classification_Title__c From Form_1__c f Where Id = :ApexPages.currentPage().getParameters().get('id')];
            fw1 = new Form1Wrapper(thisForm);
            renderMode = 'PDF';
            //margins = '0.2cm 1cm 0.2cm 1cm';
        }
        
        // Condition for editing an existing Form 1
        else {
            //Bao added "f.Form_1_Unique_Number__c" below, 12/27/2016)
            thisForm = [Select f.Form_1_Unique_Number__c, f.SEC5_Form_607_Number__c, f.SEC1_Part_Time_Fraction__c, f.SEC2_Part_Time_Fraction__c, f.Unit__c, f.SystemModstamp, f.Status__c, f.Serial__c, f.SEC5_Position_Open__c, f.SEC5_Position_Open_Date__c, f.SEC5_MGR_List__c, f.SEC5_Initials__c, f.SEC5_Form_607_Date__c, f.SEC5_Certification_Date__c, f.SEC5_Approval__c, f.SEC5_Approval_Date__c, f.SEC4_Title__c, f.SEC4_Special_Instructions_Date__c, f.SEC4_RoomNo2__c, f.SEC4_RoomNo1__c, f.SEC4_Request_Informal_List__c, f.SEC4_Request_Certification__c, f.SEC4_Phone2__c, f.SEC4_Phone1__c, f.SEC4_Name2__c, f.SEC4_Name1__c, f.SEC4_Explanation__c, f.SEC4_Division__c, f.SEC3_Remarks__c, f.SEC2_Working_Headquarters__c, f.SEC2_Typist__c, f.SEC2_Transaction_Type__c, f.SEC2_Top__c, f.SEC2_Time_Base__c, f.SEC2_Tenure__c, f.SEC2_Source_of_Funds__c, f.SEC2_Position_Number__c, f.SEC2_Limited_Term_Months__c, f.SEC2_Fill_Type__c, f.SEC2_Duties_Same__c, f.SEC2_Class_Title2__c, f.SEC2_Bottom__c, f.SEC1_Working_Headquarters__c, f.SEC1_Typist__c, f.SEC1_Time_Base__c, f.SEC1_Tenure__c, f.SEC1_Position_Number__c, f.SEC1_Name_of_Incumbent__c, f.SEC1_Limited_Term_Months__c, f.SEC1_Class_Title__c, f.Requested_Effective_Date__c, f.Part_Time_Fraction__c, f.Name, f.Location__c, f.Limited_Term_Months__c, f.LastModifiedDate, f.LastModifiedById, f.IsDeleted, f.Id, f.Fill_Type__c, f.Date_to_Certifications__c, f.Date_received_by_Personnel_Analyst__c, f.Date_Closed__c, f.CreatedDate, f.CreatedById, f.Classification__c, f.Classification_Title__c From Form_1__c f Where Id = :ApexPages.currentPage().getParameters().get('id')];
            fw1 = new Form1Wrapper(thisForm);
            renderMode = '';
            //Bao changed "thisForm.Name;" to "thisForm.Form_1_Unique_Number__c;" below, 12/27/2016)
            pageTitle = 'Edit Form 1: ' + thisForm.Form_1_Unique_Number__c;
            pdfURL = '/apex/form1?id=' + fw1.form1.Id + '&pdf=true';
            //Bao commented the block 11/29/2016
            /*
            // Check Approval Status 11/29/2016
            List<ProcessInstance> pi = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId = :fw1.form1.Id];
            if(pi.size() == 1) {
                approvalStatus = pi.get(0).Status;
            }
            else {
                approvalStatus = 'Not Submitted';
            }*/
            //Bao added one line below:11/29/2016
            F1ApprovalStatus = thisForm.Status__c;
            
            dateFormatError = 'Date format \'MM-DD-YYYY\'';
            positionDoesntExistError = '';
            positionCannotBeEmptyError = '';
            positionAlreadyExistsError = '';
            //margins = '0.5in 1in 0.5in 1in';
            WFD_Requested_Effective_Date = true;
            WFD_Special_Instructions_Date = true;
            WFD_Position_Open_Date = true;
            WFD_Certification_Date = true;
            WFD_Form_607_Date = true;
            WFD_Approval_Date = true;
            
            TypistOptions = new List<SelectOption>();
            TypistOptions.add(new SelectOption('Range A', 'Range A'));
            TypistOptions.add(new SelectOption('Range B (over 50% dictaphone)', 'Range B (over 50% dictaphone)'));
            TypistOptions.add(new SelectOption('', 'None'));
            
            TimeBaseOptions = new List<SelectOption>();
            TimeBaseOptions.add(new SelectOption('Full Time', 'Full Time'));
            TimeBaseOptions.add(new SelectOption('Part Time', 'Part Time'));
            TimeBaseOptions.add(new SelectOption('', 'None'));
            
            TenureOptions = new List<SelectOption>();
            TenureOptions.add(new SelectOption('Permanent', 'Permanent'));
            TenureOptions.add(new SelectOption('Limited Term', 'Limited Term'));
            TenureOptions.add(new SelectOption('', 'None'));
            
            DutiesSameOptions = new List<SelectOption>();
            DutiesSameOptions.add(new SelectOption('Yes', 'Yes'));
            DutiesSameOptions.add(new SelectOption('No', 'No'));
            DutiesSameOptions.add(new SelectOption('', 'None'));
            
            TransactionTypeOptions = new List<SelectOption>();
            TransactionTypeOptions.add(new SelectOption('Establishment of New Position', 'Establishment of New Position'));
            TransactionTypeOptions.add(new SelectOption('Limited Term Appointment from Temporary Help Funds', 'Limited Term Appointment from Temporary Help Funds'));
            TransactionTypeOptions.add(new SelectOption('Change of Present Position', 'Change of Present Position'));
            TransactionTypeOptions.add(new SelectOption('', 'None'));
            
            RequestOptions = new List<SelectOption>();
            RequestOptions.add(new SelectOption('Yes', 'Yes'));
            RequestOptions.add(new SelectOption('No', 'No'));
            RequestOptions.add(new SelectOption('', 'None'));
            
            ApprovalOptions = new List<SelectOption>();
            ApprovalOptions.add(new SelectOption('Approved as Requested', 'Approved as Requested'));
            ApprovalOptions.add(new SelectOption('Approved as modified', 'Approved as modified'));
            ApprovalOptions.add(new SelectOption('Disapproved', 'Disapproved'));
            ApprovalOptions.add(new SelectOption('', 'None'));
            
            fw1.processRemarksForEdit();
        }
    }
    
    public PageReference saveForm1() {
        positionDoesntExistError = '';
        positionCannotBeEmptyError = '';
        positionAlreadyExistsError = '';
        WFD_Requested_Effective_Date = dateWellFormatted(fw1.Requested_Effective_Date);
        WFD_Special_Instructions_Date = dateWellFormatted(fw1.SEC4_Special_Instructions_Date);
        WFD_Position_Open_Date = dateWellFormatted(fw1.SEC5_Position_Open_Date);
        WFD_Certification_Date = dateWellFormatted(fw1.SEC5_Certification_Date);
        WFD_Form_607_Date = dateWellFormatted(fw1.SEC5_Form_607_Date);
        WFD_Approval_Date = dateWellFormatted(fw1.SEC5_Approval_Date);
        System.debug(WFD_Requested_Effective_Date);
        System.debug(WFD_Special_Instructions_Date);
        System.debug(WFD_Position_Open_Date);
        System.debug(WFD_Form_607_Date);
        System.debug(WFD_Approval_Date);
        
            if(WFD_Requested_Effective_Date && WFD_Special_Instructions_Date && WFD_Position_Open_Date && WFD_Certification_Date && WFD_Form_607_Date && WFD_Approval_Date) {
            if(!fw1.checkIfPresentPositionExists()) {
                positionDoesntExistError = 'Position doesn\'t exist';
            }
            /*if(fw1.SEC2_Position_Number_Part1 == '' || fw1.SEC2_Position_Number_Part2 == '' || fw1.SEC2_Position_Number_Part3 == '' || fw1.SEC2_Position_Number_Part4 == '') {
                positionCannotBeEmptyError = 'Position number fields cannot be empty';
            }*/
            if(fw1.checkIfNewPositionExists()) {
                positionAlreadyExistsError = 'Position already exists';
            }
            if(positionDoesntExistError != '' || positionCannotBeEmptyError != '' || positionAlreadyExistsError != '') {
                system.debug('doesnt exist' + positionDoesntExistError);
                system.debug('already exists' + positionAlreadyExistsError);
                system.debug('empty' + positionCannotBeEmptyError);
                return null;
            }
            
            String[] dateParts = null;
            if(fw1.Requested_Effective_Date != '') {
                dateParts = fw1.Requested_Effective_Date.split('-');
                fw1.Requested_Effective_Date = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
            }
            if(fw1.SEC4_Special_Instructions_Date != '') {
                dateParts = fw1.SEC4_Special_Instructions_Date.split('-');
                fw1.SEC4_Special_Instructions_Date = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
            }
            if(fw1.SEC5_Position_Open_Date != '') {
                dateParts = fw1.SEC5_Position_Open_Date.split('-');
                fw1.SEC5_Position_Open_Date = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
            }
            if(fw1.SEC5_Certification_Date != '') {
                dateParts = fw1.SEC5_Certification_Date.split('-');
                fw1.SEC5_Certification_Date = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
            }
            if(fw1.SEC5_Form_607_Date != '') {
                dateParts = fw1.SEC5_Form_607_Date.split('-');
                fw1.SEC5_Form_607_Date = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
            }
            if(fw1.SEC5_Approval_Date != '') {
                dateParts = fw1.SEC5_Approval_Date.split('-');
                fw1.SEC5_Approval_Date = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
            }
            fw1.assignForm1Values();
            upsert fw1.form1;
            //PageReference p = new Pagereference('/' + fw1.form1.Id);
            PageReference p = Page.form1;
            p.getParameters().put('id',fw1.form1.Id);
            p.setRedirect(true);
            System.debug(p);
            return p;
        }
        else {
            return null;
        }
    }
    
    public Boolean dateWellFormatted(String d) {
        if(d != '') {
            if(d.length() != 10) {
                return false;
            }
            if(d.countMatches('-') != 2){
                return false;
            }
            if(d.indexOf('-') != 2) {
                return false;
            }
            if(d.substring(3).indexOf('-') != 2) {
                return false;
            }
        }
        return true;
    }
    
    public PageReference searchClassification() {
        if(fw1.SEC1_Position_Number_Part3.length() == 4) {
        //Bao added bu_ 1/12/2017
            List<Classification__c> tempList = [select Id, Bargaining_Unit__c, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :fw1.SEC1_Position_Number_Part3 order by Classification_Name__c limit 1];
            Classification__c temp = null;
            if(tempList.size() == 1) {
                temp = tempList.get(0);
            }
            
            if(temp != null && temp.Id != null) {
                fw1.SEC1_Class_Title = temp.Classification_Name__c;
            }
        }
        else {
            fw1.SEC1_Class_Title = '';
        }
        return null;
    }
    
    public PageReference searchClassification2() {
        if(fw1.SEC2_Position_Number_Part3.length() == 4) {
        //Bao added bu_ 1/12/2017
            List<Classification__c> tempList = [select Id, Bargaining_Unit__c, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :fw1.SEC2_Position_Number_Part3 order by Classification_Name__c limit 1];
            Classification__c temp = null;
            if(tempList.size() == 1) {
                temp = tempList.get(0);
            }
            
            if(temp != null && temp.Id != null) {
                fw1.SEC2_Class_Title2 = temp.Classification_Name__c;
            }
        }
        else {
            fw1.SEC2_Class_Title2 = '';
        }
        return null;
    }
    
    public class Form1Wrapper {
        public Form_1__c form1 {get; set;}
        public String Requested_Effective_Date {get; set;}
        public String SEC1_Position_Number {get; set;}
        public String SEC1_Position_Number_Part1 {get; set;}
        public String SEC1_Position_Number_Part2 {get; set;}
        public String SEC1_Position_Number_Part3 {get; set;}
        public String SEC1_Position_Number_Part4 {get; set;}
        public String SEC1_Class_Title {get; set;}
        public String SEC1_Name_of_Incumbent {get; set;}
        public String SEC1_Working_Headquarters {get; set;}
        public String SEC1_Typist {get; set;}
        public String SEC1_Time_Base {get; set;}
        public string SEC1_Part_Time_Fraction {get; set;}
        public String SEC1_Tenure {get; set;}
        public String SEC1_Limited_Term_Months {get; set;}
        
        public boolean SEC2_Top {get; set;}
        public boolean SEC2_Bottom {get; set;}
        public String SEC2_Fill_Type {get; set;}
        public String SEC2_Duties_Same {get; set;}
        public String SEC2_Transaction_Type {get; set;}
        public String SEC2_Position_Number {get; set;}
        public String SEC2_Position_Number_Part1 {get; set;}
        public String SEC2_Position_Number_Part2 {get; set;}
        public String SEC2_Position_Number_Part3 {get; set;}
        public String SEC2_Position_Number_Part4 {get; set;}
        public String SEC2_Class_Title2 {get; set;}
        public String SEC2_Source_of_Funds {get; set;}
        public String SEC2_Working_Headquarters {get; set;}
        public String SEC2_Typist {get; set;}
        public String SEC2_Time_Base {get; set;}
        public String SEC2_Part_Time_Fraction {get; set;}
        public String SEC2_Tenure {get; set;}
        public String SEC2_Limited_Term_Months {get; set;}
        
        public String SEC3_Remarks {get; set;}
        
        public String SEC4_Request_Certification {get; set;}
        public String SEC4_Explanation {get; set;}
        public String SEC4_Request_Informal_List {get; set;}
        public String SEC4_Name1 {get; set;}
        public String SEC4_Phone1 {get; set;}
        public String SEC4_RoomNo1 {get; set;}
        public String SEC4_Name2 {get; set;}
        public String SEC4_Phone2 {get; set;}
        public String SEC4_RoomNo2 {get; set;}
        public String SEC4_Title {get; set;}
        public String SEC4_Division {get; set;}
        public String SEC4_Special_Instructions_Date {get; set;}
        
        public String SEC5_MGR_List {get; set;}
        public String SEC5_Position_Open {get; set;}
        public String SEC5_Position_Open_Date {get; set;}
        public String SEC5_Certification_Date {get; set;}
        public String SEC5_Form_607_Number {get; set;}
        public String SEC5_Form_607_Date {get; set;}
        public String SEC5_Approval {get; set;}
        public String SEC5_Initials {get; set;}
        public String SEC5_Approval_Date {get; set;}
        
        public Form1Wrapper(Form_1__c f1) {
            form1 = f1;
            
            Requested_Effective_Date = (f1.Requested_Effective_Date__c != null) ? String.valueOf(f1.Requested_Effective_Date__c) : '';
            if(Requested_Effective_Date != '') {
                String[] dateParts = Requested_Effective_Date.split('-');
                Requested_Effective_Date = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            
            if(f1.SEC1_Position_Number__c != null && f1.SEC1_Position_Number__c != '') {
                String[] parts = f1.SEC1_Position_Number__c.split('-');
                SEC1_Position_Number_Part1 = (parts.size() >= 1) ? parts[0] : '';
                SEC1_Position_Number_Part2 = (parts.size() >= 2) ? parts[1] : '';
                SEC1_Position_Number_Part3 = (parts.size() >= 3) ? parts[2] : '';
                SEC1_Position_Number_Part4 = (parts.size() >= 4) ? parts[3] : '';
                SEC1_Position_Number = f1.SEC1_Position_Number__c;
            }
            else {
                SEC1_Position_Number_Part1 = '';
                SEC1_Position_Number_Part2 = '';
                SEC1_Position_Number_Part3 = '';
                SEC1_Position_Number_Part4 = '';
            }
            SEC1_Class_Title = f1.SEC1_Class_Title__c;
            SEC1_Name_of_Incumbent = f1.SEC1_Name_of_Incumbent__c;
            SEC1_Working_Headquarters = f1.SEC1_Working_Headquarters__c;
            SEC1_Typist = f1.SEC1_Typist__c;
            SEC1_Time_Base = f1.SEC1_Time_Base__c;
            SEC1_Part_Time_Fraction = (f1.SEC1_Part_Time_Fraction__c != null) ? String.valueOf(f1.SEC1_Part_Time_Fraction__c) : '';
            SEC1_Tenure = f1.SEC1_Tenure__c;
            SEC1_Limited_Term_Months = (f1.SEC1_Limited_Term_Months__c != null) ? String.valueOf(f1.SEC1_Limited_Term_Months__c) : '';
            
            SEC2_Top = f1.SEC2_Top__c;
            SEC2_Bottom = f1.SEC2_Bottom__c;
            SEC2_Fill_Type = f1.SEC2_Fill_Type__c;
            SEC2_Duties_Same = f1.SEC2_Duties_Same__c;
            SEC2_Transaction_Type = f1.SEC2_Transaction_Type__c;
            if(f1.SEC2_Position_Number__c != null && f1.SEC2_Position_Number__c != '') {
                String[] parts = f1.SEC2_Position_Number__c.split('-');
                SEC2_Position_Number_Part1 = (parts.size() >= 1) ? parts[0] : '';
                SEC2_Position_Number_Part2 = (parts.size() >= 2) ? parts[1] : '';
                SEC2_Position_Number_Part3 = (parts.size() >= 3) ? parts[2] : '';
                SEC2_Position_Number_Part4 = (parts.size() >= 4) ? parts[3] : '';
                SEC2_Position_Number = f1.SEC2_Position_Number__c;
            }
            else {
                SEC2_Position_Number_Part1 = '';
                SEC2_Position_Number_Part2 = '';
                SEC2_Position_Number_Part3 = '';
                SEC2_Position_Number_Part4 = '';
            }
            SEC2_Class_Title2 = f1.SEC2_Class_Title2__c;
            SEC2_Source_of_Funds = f1.SEC2_Source_of_Funds__c;
            SEC2_Working_Headquarters = f1.SEC2_Working_Headquarters__c;
            SEC2_Typist = f1.SEC2_Typist__c;
            SEC2_Time_Base = f1.SEC2_Time_Base__c;
            SEC2_Part_Time_Fraction = (f1.SEC2_Part_Time_Fraction__c != null) ? String.valueOf(f1.SEC2_Part_Time_Fraction__c) : '';
            SEC2_Tenure = f1.SEC2_Tenure__c;
            SEC2_Limited_Term_Months = (f1.SEC2_Limited_Term_Months__c != null) ? String.valueOf(f1.SEC2_Limited_Term_Months__c) : '';
            
            SEC3_Remarks = processDescription(f1.SEC3_Remarks__c);
            
            SEC4_Request_Certification = f1.SEC4_Request_Certification__c;
            SEC4_Explanation = f1.SEC4_Explanation__c;
            SEC4_Request_Informal_List = f1.SEC4_Request_Informal_List__c;
            SEC4_Name1 = f1.SEC4_Name1__c;
            SEC4_Phone1 = f1.SEC4_Phone1__c;
            SEC4_RoomNo1 = f1.SEC4_RoomNo1__c;
            SEC4_Name2 = f1.SEC4_Name2__c;
            SEC4_Phone2 = f1.SEC4_Phone2__c;
            SEC4_RoomNo2 = f1.SEC4_RoomNo2__c;
            SEC4_Title = f1.SEC4_Title__c;
            SEC4_Division = f1.SEC4_Division__c;
            SEC4_Special_Instructions_Date = (f1.SEC4_Special_Instructions_Date__c != null) ? String.valueOf(f1.SEC4_Special_Instructions_Date__c) : '';
            if(SEC4_Special_Instructions_Date != '') {
                String[] dateParts = SEC4_Special_Instructions_Date.split('-');
                SEC4_Special_Instructions_Date = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            
            SEC5_MGR_List = f1.SEC5_MGR_List__c;
            SEC5_Position_Open = f1.SEC5_Position_Open__c;
            SEC5_Position_Open_Date = (f1.SEC5_Position_Open_Date__c != null) ? String.valueOf(f1.SEC5_Position_Open_Date__c) : '';
            if(SEC5_Position_Open_Date != '') {
                String[] dateParts = SEC5_Position_Open_Date.split('-');
                SEC5_Position_Open_Date = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            SEC5_Certification_Date = (f1.SEC5_Certification_Date__c != null) ? String.valueOf(f1.SEC5_Certification_Date__c) : '';
            if(SEC5_Certification_Date != '') {
                String[] dateParts = SEC5_Certification_Date.split('-');
                SEC5_Certification_Date = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            SEC5_Form_607_Number = f1.SEC5_Form_607_Number__c;
            SEC5_Form_607_Date = (f1.SEC5_Form_607_Date__c != null) ? String.valueOf(f1.SEC5_Form_607_Date__c) : '';
            if(SEC5_Form_607_Date != '') {
                String[] dateParts = SEC5_Form_607_Date.split('-');
                SEC5_Form_607_Date = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            SEC5_Approval = f1.SEC5_Approval__c;
            SEC5_Initials = f1.SEC5_Initials__c;
            SEC5_Approval_Date = (f1.SEC5_Approval_Date__c != null) ? String.valueOf(f1.SEC5_Approval_Date__c) : '';
            if(SEC5_Approval_Date != '') {
                String[] dateParts = SEC5_Approval_Date.split('-');
                SEC5_Approval_Date = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
        }
        
        public Form1Wrapper() {
            form1 = new Form_1__c();
            Requested_Effective_Date = '';
            
            SEC1_Position_Number = '';
            SEC1_Position_Number_Part1 = '';
            SEC1_Position_Number_Part2 = '';
            SEC1_Position_Number_Part3 = '';
            SEC1_Position_Number_Part4 = '';
            SEC1_Class_Title = '';
            SEC1_Name_of_Incumbent = '';
            SEC1_Working_Headquarters = '';
            SEC1_Typist = '';
            SEC1_Time_Base = '';
            SEC1_Part_Time_Fraction = '';
            SEC1_Tenure = '';
            SEC1_Limited_Term_Months = '';
            
            SEC2_Top = false;
            SEC2_Bottom = false;
            SEC2_Fill_Type = '';
            SEC2_Duties_Same = '';
            SEC2_Transaction_Type = '';
            SEC2_Position_Number = '';
            SEC2_Position_Number_Part1 = '';
            SEC2_Position_Number_Part2 = '';
            SEC2_Position_Number_Part3 = '';
            SEC2_Position_Number_Part4 = '';
            SEC2_Class_Title2 = '';
            SEC2_Source_of_Funds = '';
            SEC2_Working_Headquarters = '';
            SEC2_Typist = '';
            SEC2_Time_Base = '';
            SEC2_Part_Time_Fraction = '';
            SEC2_Tenure = '';
            SEC2_Limited_Term_Months = '';
            
            SEC3_Remarks = '';
            
            SEC4_Request_Certification = '';
            SEC4_Explanation = '';
            SEC4_Request_Informal_List = '';
            SEC4_Name1 = '';
            SEC4_Phone1 = '';
            SEC4_RoomNo1 = '';
            SEC4_Name2 = '';
            SEC4_Phone2 = '';
            SEC4_RoomNo2 = '';
            SEC4_Title = '';
            SEC4_Division = '';
            SEC4_Special_Instructions_Date = '';
            
            SEC5_MGR_List = '';
            SEC5_Position_Open = '';
            SEC5_Position_Open_Date = '';
            SEC5_Certification_Date = '';
            SEC5_Form_607_Number = '';
            SEC5_Form_607_Date = '';
            SEC5_Approval = '';
            SEC5_Initials = '';
            SEC5_Approval_Date = '';
        }
        
        public void assignForm1Values() {
            form1.Requested_Effective_Date__c = (Requested_Effective_Date != '') ? Date.valueOf(Requested_Effective_Date) : null;
            
            form1.SEC1_Position_Number__c = SEC1_Position_Number_Part1 + '-' + SEC1_Position_Number_Part2 + '-' + SEC1_Position_Number_Part3 + '-' + SEC1_Position_Number_Part4;
            if(form1.SEC1_Position_Number__c == '---') {
                form1.SEC1_Position_Number__c = '';
            }
            form1.SEC1_Class_Title__c = SEC1_Class_Title;
            form1.SEC1_Name_of_Incumbent__c = SEC1_Name_of_Incumbent;
            form1.SEC1_Working_Headquarters__c = SEC1_Working_Headquarters;
            form1.SEC1_Typist__c = SEC1_Typist;
            form1.SEC1_Time_Base__c = SEC1_Time_Base;
            form1.SEC1_Part_Time_Fraction__c = (SEC1_Part_Time_Fraction != '') ? Double.valueOf(SEC1_Part_Time_Fraction) : null;
            form1.SEC1_Tenure__c = SEC1_Tenure;
            form1.SEC1_Limited_Term_Months__c = (SEC1_Limited_Term_Months != '') ? Double.valueOf(SEC1_Limited_Term_Months) : null;
            form1.SEC2_Top__c = SEC2_Top;
            form1.SEC2_Bottom__c = SEC2_Bottom;
            form1.SEC2_Fill_Type__c = (SEC2_Top) ? SEC2_Fill_Type : '';
            form1.SEC2_Duties_Same__c = SEC2_Duties_Same;
            form1.SEC2_Transaction_Type__c = (SEC2_Bottom) ? SEC2_Transaction_Type : '';
            form1.SEC2_Position_Number__c = SEC2_Position_Number_Part1 + '-' + SEC2_Position_Number_Part2 + '-' + SEC2_Position_Number_Part3 + '-' + SEC2_Position_Number_Part4;
            if(form1.SEC2_Position_Number__c == '---') {
                form1.SEC2_Position_Number__c = '';
            }
            form1.SEC2_Class_Title2__c = SEC2_Class_Title2;
            form1.SEC2_Source_of_Funds__c = SEC2_Source_of_Funds;
            form1.SEC2_Working_Headquarters__c = SEC2_Working_Headquarters;
            form1.SEC2_Typist__c = SEC2_Typist;
            form1.SEC2_Time_Base__c = SEC2_Time_Base;
            form1.SEC2_Part_Time_Fraction__c = (SEC2_Part_Time_Fraction != '') ? Double.valueOf(SEC2_Part_Time_Fraction) : null;
            form1.SEC2_Tenure__c = SEC2_Tenure;
            form1.SEC2_Limited_Term_Months__c = (SEC2_Limited_Term_Months != '') ? Double.valueOf(SEC2_Limited_Term_Months) : null;
            
            form1.SEC3_Remarks__c = SEC3_Remarks;
            
            form1.SEC4_Request_Certification__c = SEC4_Request_Certification;
            form1.SEC4_Explanation__c = SEC4_Explanation;
            form1.SEC4_Request_Informal_List__c = SEC4_Request_Informal_List;
            form1.SEC4_Name1__c = SEC4_Name1;
            form1.SEC4_Phone1__c = SEC4_Phone1;
            form1.SEC4_RoomNo1__c = SEC4_RoomNo1;
            form1.SEC4_Name2__c = SEC4_Name2;
            form1.SEC4_Phone2__c = SEC4_Phone2;
            form1.SEC4_RoomNo2__c = SEC4_RoomNo2;
            form1.SEC4_Title__c = SEC4_Title;
            form1.SEC4_Division__c = SEC4_Division;
            form1.SEC4_Special_Instructions_Date__c = (SEC4_Special_Instructions_Date != '') ? Date.valueOf(SEC4_Special_Instructions_Date) : null;
            
            form1.SEC5_MGR_List__c = SEC5_MGR_List;
            form1.SEC5_Position_Open__c = SEC5_Position_Open;
            form1.SEC5_Position_Open_Date__c = (SEC5_Position_Open_Date != '') ? Date.valueOf(SEC5_Position_Open_Date) : null;
            form1.SEC5_Certification_Date__c = (SEC5_Certification_Date != '') ? Date.valueOf(SEC5_Certification_Date) : null;
            form1.SEC5_Form_607_Number__c = SEC5_Form_607_Number;
            form1.SEC5_Form_607_Date__c = (SEC5_Form_607_Date != '') ? Date.valueOf(SEC5_Form_607_Date) : null;
            form1.SEC5_Approval__c = SEC5_Approval;
            form1.SEC5_Initials__c = SEC5_Initials;
            form1.SEC5_Approval_Date__c = (SEC5_Approval_Date != '') ? Date.valueOf(SEC5_Approval_Date) : null;
        }
        
        public Boolean checkIfPresentPositionExists() {
            form1.SEC1_Position_Number__c = SEC1_Position_Number_Part1 + '-' + SEC1_Position_Number_Part2 + '-' + SEC1_Position_Number_Part3 + '-' + SEC1_Position_Number_Part4;
            if(form1.SEC1_Position_Number__c == '---') {
                form1.SEC1_Position_Number__c = '';
            }
            if(form1.SEC1_Position_Number__c == '') {
                return true;
            }
            List<Position__c> tempList = [select Id from Position__c where Name = :form1.SEC1_Position_Number__c and isActive__c = true];
            if(tempList.size() == 1) {
                form1.SEC1_Position__c = tempList.get(0).Id;
                return true;
            }
            return false;
        }
        
        public Boolean checkIfNewPositionExists() {
            form1.SEC2_Position_Number__c = SEC2_Position_Number_Part1 + '-' + SEC2_Position_Number_Part2 + '-' + SEC2_Position_Number_Part3 + '-' + SEC2_Position_Number_Part4;
            if(form1.SEC2_Position_Number__c == '---') {
                form1.SEC2_Position_Number__c = '';
            }
            if(form1.SEC2_Position_Number__c == '') {
                return false;
            }
            
                       
          //Hirut added this if statement
            //if (Integer.valueOf(SEC2_Position_Number_Part4) >= 900) {
                //return false;
            //}
            
            List<Position__c> tempList = [select Id from Position__c where Name = :form1.SEC2_Position_Number__c and isActive__c = true];
            if(tempList.size() == 1) {
                //form1.SEC1_Position__c = tempList.get(0).Id;
                return true;
            }
            return false;
        }
        
        public String processDescription(String d) {
            if(d == null) {
                d = '';
            }
            Integer linecount = 1 + d.countMatches('\n');
            linecount += (Integer) d.length()/140;
            d = d.replace('\n', '<br/>');
            while(linecount < 6) {
                d += '<br />';
                linecount++;
            }
            return d;
        }
        
        public void processRemarksForEdit() {
            SEC3_Remarks = form1.SEC3_Remarks__c;
            if(SEC3_Remarks != null) {
                SEC3_Remarks = SEC3_Remarks.replace('<br/>','\n');
            }
        }
    }
    
////////////////////////////////////////////////////////////////
////            VIEW PAGE BUTTON FUNCTIONS                  ////
////////////////////////////////////////////////////////////////
    public PageReference deleteForm1() {
        PageReference p = null;
        if(fw1.form1.Id != null) {
            delete fw1.form1;
            p = new PageReference('/a0J/o');
        }
        return p;
    }
    
    
    
    
    
    
    public PageReference Cancel_Approved_Form1() {
    
        if(fw1.form1.Id != null) {
           fw1.form1.Status__c= 'Canceled';
        }
        return null;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    public PageReference submitForApproval() {
        if(fw1.form1.Id != null) {
            // Check if this form has already been submitted for approval
            List<ProcessInstance> pi = [SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectId = :fw1.form1.Id];
            if(pi.size() > 0) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This form has already been submitted for approval');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            PageReference p = new PageReference('/p/process/Submit?retURL=%2F' + fw1.form1.Id + '&id=' + fw1.form1.Id);
            return p;
            
            /*Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            System.debug('FORM1 ID: ' + fw1.form1.Id);
            req.setObjectId(fw1.form1.Id);
            req.
            Approval.ProcessResult result = Approval.process(req);
            
            if(result.isSuccess()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Form 1 successfully submitted for approval');
                ApexPages.addMessage(myMsg);
                
                pi = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId = :fw1.form1.Id];
                if(pi.size() == 1) {
                    approvalStatus = pi.get(0).Status;
                }
            }
            else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in submitting for approval: ' + result.getInstanceStatus());
                ApexPages.addMessage(myMsg);
            }*/
        }
        return null;
    }
    
    public PageReference create607() {
        PageReference p = null;
        if(fw1.form1.Id != null) {
            p = Page.form607;
            p.getParameters().put('fid',fw1.form1.Id);
            p.setRedirect(true);
        }
        return p;
    }
    
    /*public PageReference printPDF() {
        PageReference p = null;
        if(fw1.form1.Id != null) {
            p = Page.form1;
            p.getParameters().put('pdf','true');
            p.getParameters().put('id',fw1.form1.Id);
            p.setRedirect(true);
        }
        return p;
    }*/
    
    public PageReference detailPage() {
        PageReference p = null;
        if(fw1.form1.Id != null) {
            p = new PageReference('/' + fw1.form1.Id + '?nooverride=1');
            //p.getParameters().put('nooverride','0');
            p.setRedirect(true);
        }
        return p;
    }
}