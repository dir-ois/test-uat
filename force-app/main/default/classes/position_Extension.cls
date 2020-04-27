public with sharing class position_Extension {
    public Position__c position {get;set;}
    public String departmentCode {get; set;}
    
    public String departmentCodeError {get; set;}
    public String unitCodeError {get; set;}
    public String classCodeError {get; set;}
    public String serialCodeError {get; set;}
    
    public position_Extension(apexPages.standardController controller){
        position = (Position__c)controller.getRecord();
        if ( position.Id != null ){
            position = [select BU__C, Last_Pay_period__c, Location__c, X6_Month_Lapsed_Date__c, X607__c, Unit__c, Type__c, Time_Basis__c, Term_Type__c, SystemModstamp, Status__c, Status_DocNo__c, Serial_Number__c, Separation_Date__c, Salary_Rate__c, Maximum_Salary__c, Salary_Per__c, Reporting_Unit__c, Reporting_Unit_CodeNo__c, Position_Serial_Numbers__c, Position_Number2__c, Part_Time_Fraction__c, PY__c, OwnerId, Organizational_Unit__c, Number_of_Positions__c, Name, Max_End_Date__c, Manual_Entry__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, IsActive__c, Id, Expiration_Date__c, Effective_Date__c, Division__c, Department__c, CreatedDate, CreatedById, Comments__c, Classification__c, ClassificationId__c, Class_Title__c, Class_Title_CodeNo__c From Position__c where Id = :position.Id];
            departmentCode = position.Department__c;
        }
        else {
            position = new Position__c();
            departmentCode = '400';
            position.Organizational_Unit__c = 'INDUSTRIAL RELATIONS';
        }
        departmentCodeError = '';
        unitCodeError = '';
        classCodeError = '';
        serialCodeError = '';
    }
    
    public PageReference createForm1OnLoad(){
        if(Apexpages.currentPage().getParameters().get('id') != null && Apexpages.currentPage().getParameters().get('form') != null) {
            PageReference p = page.form1;
            p.getParameters().put('pid',Apexpages.currentPage().getParameters().get('id'));
            p.setRedirect(true);
            return p;
        }
        else {
            return null;
        }
    }
    
    public PageReference save(){
        departmentCodeError = '';
        unitCodeError = '';
        classCodeError = '';
        serialCodeError = '';
        if(departmentCode != '400') {
            departmentCodeError = 'Deparment Code must be 400';
        }
        if(departmentCode == '') {
            departmentCodeError = 'Deparment Code must be filled';
        }
        if(position.Reporting_Unit_CodeNo__c == '' || position.Reporting_Unit_CodeNo__c == null) {
            unitCodeError = 'Unit Code must be filled';
        }
        if(position.Class_Title_CodeNo__c == '' || position.Class_Title_CodeNo__c == null) {
            classCodeError = 'Class Code must be filled';
        }
        if(position.Serial_Number__c == '' || position.Serial_Number__c == null) {
            serialCodeError = 'Serial Number must be filled';
        }
        if(departmentCodeError != '' || unitCodeError != '' || classCodeError != '' || serialCodeError != '') {
            return null;
        }
        
        position.Department__c = '400';
        position.Name = position.Department__c + '-' + position.Reporting_Unit_CodeNo__c + '-' + position.Class_Title_CodeNo__c + '-' + position.Serial_Number__c;
        upsert position;
        return new PageReference('/' + position.Id);
    }

    public static String formatString(String s,Integer digits){
        String x = '';
        for ( Integer i=0;i<digits;i++ ){
            x += '0';
        }
        x += s;
        x = x.subString(x.length()-digits,x.length());
        return x;
    }
    
    public PageReference searchUnit() {
        system.debug(position.Reporting_Unit_CodeNo__c);
        if(position.Reporting_Unit_CodeNo__c != null && position.Reporting_Unit_CodeNo__c.length() == 3) {
            if(position.Reporting_Unit_CodeNo__c.isNumeric()) {
                List<Unit__c> tempList = [select Id, Unit_Name__c from Unit__c where Name = :position.Reporting_Unit_CodeNo__c];
                Unit__c temp = null;
                if(tempList.size() == 1) {
                    temp = tempList.get(0);
                }
                if(temp != null){// && temp.Id != null) {
                    position.Reporting_Unit__c = temp.Unit_Name__c;
                }
            } else {
                position.Reporting_Unit__c = '';
            }
        }
        else {
            position.Reporting_Unit__c = '';
        }
        return null;
    }
    
    public PageReference searchClassification() {
        if(position.Class_Title_CodeNo__c != null && position.Class_Title_CodeNo__c.length() == 4) {
            if(position.Class_Title_CodeNo__c.isNumeric()) {
                List<Classification__c> tempList = [select Id, Classification_Name__c, Minimum_Salary_Rate__c, Maximum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :position.Class_Title_CodeNo__c order by Classification_Name__c limit 1];
                Classification__c temp = null;
                if(tempList.size() == 1) {
                    temp = tempList.get(0);
                }
                if(temp != null){// && temp.Id != null) {
                    position.Class_Title__c = temp.Classification_Name__c;
                    position.Salary_Rate__c = temp.Minimum_Salary_Rate__c;
                    position.Maximum_Salary__c = temp.Maximum_Salary_Rate__c;
                    position.Salary_Per__c = temp.Salary_Per__c;
                    position.Type__c = temp.Type_of_Position__c;
                }
            } else {
                position.Class_Title__c = '';
                position.Salary_Rate__c = null;
                position.Maximum_Salary__c = null;
                position.Salary_Per__c = '';
                position.Type__c = '';
            }
        }
        else {
            position.Class_Title__c = '';
            position.Salary_Rate__c = null;
            position.Maximum_Salary__c = null;
            position.Salary_Per__c = '';
            position.Type__c = '';
        }
        return null;
    }
}