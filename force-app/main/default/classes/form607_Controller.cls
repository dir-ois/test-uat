public with sharing class form607_Controller {
  ////////////////////////////////////////////////////////////////
  ////          FORM 607 ELEMENTS          ////
  ////////////////////////////////////////////////////////////////
  
  public X607__c form607 {get;set;}
  public X607_Position_Modification__c primaryAddition {get;set;}
  public X607_Position_Modification__c primaryDeletion {get;set;}
  public Position__c newAddPos {get; set;}
  public Position__c newDelPos {get; set;}
  public List<PosModWrapper> attachedAdditions {get;set;}
  public List<PosModWrapper> attachedDeletions {get;set;}
  public List<List<PosModWrapper>> outputAdditions {get;set;}
  public List<List<PosModWrapper>> outputDeletions {get;set;}
  public List<OutputWrapper> output {get; set;}
  public Integer deletedAdditionIndex {get; set;}
  public Integer deletedDeletionIndex {get; set;}
  public String renderMode {get; set;}
  public String newLine {get; set;}
  public Integer globalIndex {get; set;}
  public String pdfFontSize {get; set;}

  public String routing {get; set;}
  public String routeTo {get; set;}
  public List<SelectOption> routeToOptions {get; set;}
  
  public String transactionType {get; set;}
  public List<SelectOption> transactionOptions {get; set;}
  
  public String fiscalYear {get; set;}
  public String documentNo {get; set;}
  
  public String effectiveDate_4a {get; set;}
  public String expirationDate_4b {get; set;}
  
  public String departmentAndOrganizationalUnit_5a {get; set;}
  public String codeNo_5a {get; set;}
  public String reportingUnitOrFunction_5b {get; set;}
  public String codeNo_5b {get; set;}
  public String classTitle_5c {get; set;}
  public String BU {get; set;}
  public String codeNo_5c {get; set;}
  public String numberOfpositions_5d {get; set;}
  public String positionSerialNumbers_5e {get; set;}
  //public String codeNo_5d {get; set;}
  public String typeOfPosition_5f {get; set;}
  
  public String timeBasis_6a {get; set;}
  public String partTimeFraction_6a {get; set;}
  public List<SelectOption> timeBasisOptions_6a {get; set;}
  
  public String salary_6b {get; set;}
  public String rate_6b {get; set;}
  public List<SelectOption> rateOptions_6b {get; set;}
  
  public String effectiveDate_7a {get; set;}
  public String disencumberTo_7b {get; set;}
  
  public String departmentAndOrganizationalUnit_8a {get; set;}
  public String codeNo_8a {get; set;}
  public String reportingUnitOrFunction_8b {get; set;}
  public String codeNo_8b {get; set;}
  public String classTitle_8c {get; set;}
  public String codeNo_8c {get; set;}
  public String numberOfpositions_8d {get; set;}
  public String positionSerialNumbers_8e {get; set;}
  //public String codeNo_8d {get; set;}
  public String typeOfPosition_8f {get; set;}
  
  public String timeBasis_9a {get; set;}
  public String partTimeFraction_9a {get; set;}
  public List<SelectOption> timeBasisOptions_9a {get; set;}
  
  public String salary_9b {get; set;}
  public String rate_9b {get; set;}
  public List<SelectOption> rateOptions_9b {get; set;}
  
  public String presentStatus_9c {get; set;}
  public List<SelectOption> presentStatusOptions_9c {get; set;}
  public String docNo_9c {get; set;}
  
  public String descriptionOfDuties {get; set;}
  public String standardDescription {get; set;}
  public List<SelectOption> standardComments {get; set;}
  
  public String initials {get; set;}
  public String accountingOfficerDate {get; set;}
  
  public String contactPerson_12 {get; set;}
  public String phoneNumber_12 {get; set;}
  public String contactDate_12 {get; set;}
  public Boolean approvedCheck {get; set;}
  //TODO: public Contact contactNameHolder {get; set;}
  public Boolean WFD_effectiveDate_4a {get; set;}
  public Boolean WFD_expirationDate_4b {get; set;}
  public Boolean WFD_effectiveDate_7a {get; set;}
  public Boolean WFD_disencumberTo_7b {get; set;}
  public Boolean WFD_accountingOfficerDate {get; set;}
  public Boolean WFD_contactDate_12 {get; set;}
  public String dateFormatError {get; set;}
  public String numPos5dError {get; set;}
  public String numPos8dError {get; set;}
  public String salary6bError {get; set;}
  public String salary9bError {get; set;}
  
  public String pageTitle {get; set;}
  public String approvalStatus {get; set;}
  public String pdfURL {get; set;}
  public String attachmentURL {get; set;}
  
  public class PosModWrapper {
    public X607_Position_Modification__c posmod {get; set;}
    public Position__c pos {get; set;}
    public Integer index {get; set;}
    
    public PosModWrapper(X607_Position_Modification__c pm, Position__c p, Integer i) {
      posmod = pm;
      pos = p;
      index = i;
    }
  }
  public class OutputWrapper {
    public List<PosModWrapper> add {get; set;}
    public List<PosModWrapper> del {get; set;}
    
    public OutputWrapper(List<PosModWrapper> a, List<PosModWrapper> d) {
      add = a;
      del = d;
    }
  }
   
  ////////////////////////////////////////////////////////////////
  ////        End FORM 607 ELEMENTS          ////
  ////////////////////////////////////////////////////////////////
  
  public form607_Controller(ApexPages.StandardController con) {
    renderMode = '';
    newLine = '\n';
    globalIndex = 0;
    form607 = (X607__c) con.getRecord();
    numPos5dError = '';
    numPos8dError = ''; 
    salary6bError = '';
    salary9bError = '';
    
    // Condition for Print PDF
    if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('pdf') != null) {
      String formID = ApexPages.currentPage().getParameters().get('id');
      form607 = [Select x.Approved__c, x.X607_Position_Primary_Deletion__c, x.X607_Position_Primary_Deletion__r.Effective_Date__c, x.X607_Position_Primary_Deletion__r.Expiration_Date__c, x.X607_Position_Primary_Addition__r.Effective_Date__c, x.X607_Position_Primary_Addition__r.Expiration_Date__c, x.X607_Position_Primary_Deletion__r.Position__c, x.X607_Position_Primary_Addition__r.Position__c, x.X607_Position_Primary_Addition__c, x.Type__c, x.SystemModstamp, x.Status__c, x.Standard_Comment__c, x.Routing__c, x.Route_To__c, x.OwnerId, x.Name, x.LastModifiedDate, x.LastModifiedById, x.LastActivityDate, x.IsDeleted, x.Initials__c, x.Id, x.Form_1__c, x.Fiscal_Year__c, x.Expiration_Date__c, x.Effective_Date__c, x.Document_No__c, x.Date_Submitted_to_Budget__c, x.CreatedDate, x.CreatedById, x.Comments__c, x.Certification_Phone_Number__c, x.Certification_Date__c, x.Certification_Contact__c From X607__c x Where x.Id = :formID];
      system.debug(form607);
      renderMode = 'PDF';
      pdfFontSize = '';
      
      if(form607.Id != null) {
        routing = form607.Routing__c;
        //routeTo = form607.Route_To__c;
        routeTo = '';
        system.debug(routeTo);
        transactionType = form607.Type__c;
        
        fiscalYear = form607.Fiscal_Year__c;
        documentNo = form607.Document_No__c;
  
        if(form607.X607_Position_Primary_Addition__c != null) {
          // Case for when there is only one addition, the Position in the primary addition will be filled
          if(form607.X607_Position_Primary_Addition__r.Position__c != null) {
            Position__c posAdd = [Select p.BU__c, p.Serial_Number__c, p.Type__c, p.Time_Basis__c, p.Status__c, p.Status_DocNo__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Part_Time_Fraction__c, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Expiration_Date__c, p.Effective_Date__c, p.Department__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p Where Id = :form607.X607_Position_Primary_Addition__r.Position__c];
            effectiveDate_4a = (form607.X607_Position_Primary_Addition__r.Effective_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Addition__r.Effective_Date__c) : '';            
            //effectiveDate_4a = (posAdd.Effective_Date__c != null) ? String.valueOf(posAdd.Effective_Date__c) : '';
            if(effectiveDate_4a != '') {
              String[] dateParts = effectiveDate_4a.split('-');
              effectiveDate_4a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            expirationDate_4b = (form607.X607_Position_Primary_Addition__r.Expiration_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Addition__r.Expiration_Date__c) : '';
            //expirationDate_4b = (posAdd.Expiration_Date__c != null) ? posAdd.Expiration_Date__c : '';
            if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
              String[] dateParts = expirationDate_4b.split('/');
              dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
              dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
              expirationDate_4b = dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
            }
            /*if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
              String[] dateParts = expirationDate_4b.split('-');
              expirationDate_4b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }*/
            /*if(transactionType != 'Proposed New' && transactionType != 'Reclassification') {
              effectiveDate_4a = '';
              expirationDate_4b = '';
            }*/
            departmentAndOrganizationalUnit_5a = posAdd.Organizational_Unit__c;
            codeNo_5a = posAdd.Department__c;
            reportingUnitOrFunction_5b = posAdd.Reporting_Unit__c;
            codeNo_5b = posAdd.Reporting_Unit_CodeNo__c;
            classTitle_5c = posAdd.Class_Title__c;
            BU = posAdd.BU__c;
            codeNo_5c = posAdd.Class_Title_CodeNo__c;
            //5/13/2015 - Bao added (: '1';) - orginally (: '';) to the line below:
            numberOfpositions_5d = (posAdd.Number_of_Positions__c != null) ? String.valueOf(posAdd.Number_of_Positions__c) : '1';
            positionSerialNumbers_5e = posAdd.Serial_Number__c;
            system.debug(positionSerialNumbers_5e);
            //codeNo_5d = '';
            typeOfPosition_5f = posAdd.Type__c;
            if(typeOfPosition_5f != null && typeOfPosition_5f.length() > 1) {
              typeOfPosition_5f = typeOfPosition_5f.substring(0, 1);
            }
            
            timeBasis_6a = posAdd.Time_Basis__c;
            partTimeFraction_6a = (posAdd.Part_Time_Fraction__c != null) ? String.valueOf(posAdd.Part_Time_Fraction__c) : '';
            
            salary_6b = (posAdd.Salary_Rate__c != null) ? String.valueOf(posAdd.Salary_Rate__c) : '';
            if(codeNo_5c != null && codeNo_5c == 'various') {
              salary_6b = 'various';
            }
            rate_6b = posAdd.Salary_Per__c;
          }
          // Otherwise there are various positions and an attachment will be used
          else {
            X607_Position_Modification__c primeAddPosMod = [Select x.Salary__c, x.Salary_Rate__c, x.X607__c, x.Unit__c, x.Type__c, x.Time_Base__c, x.SystemModstamp, x.Serial__c, x.Reporting_Unit__c, x.Reporting_Unit_Code__c, x.Position__c, x.Number_of_Positions__c, x.Name, x.LastModifiedDate, x.LastModifiedById, x.LastActivityDate, x.IsDeleted, x.Id, x.Expiration_Date__c, x.Effective_Date__c, x.CreatedDate, x.CreatedById, x.Classification__c, x.Class_Title__c, x.Class_Title_Code__c, x.Approval_Status__c From X607_Position_Modification__c x where x.Id = :form607.X607_Position_Primary_Addition__c];
            effectiveDate_4a = (primeAddPosMod.Effective_Date__c != null) ? String.valueOf(primeAddPosMod.Effective_Date__c) : '';
            if(effectiveDate_4a != '') {
              String[] dateParts = effectiveDate_4a.split('-');
              effectiveDate_4a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            expirationDate_4b = (primeAddPosMod.Expiration_Date__c != null) ? String.valueOf(primeAddPosMod.Expiration_Date__c) : '';
            if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
              String[] dateParts = expirationDate_4b.split('/');
              dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
              dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
              expirationDate_4b = dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
            }
            /*if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
              String[] dateParts = expirationDate_4b.split('-');
              expirationDate_4b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }*/
            
            departmentAndOrganizationalUnit_5a = 'INDUSTRIAL RELATIONS';
            codeNo_5a = '400';
            reportingUnitOrFunction_5b = primeAddPosMod.Reporting_Unit__c;
            codeNo_5b = primeAddPosMod.Reporting_Unit_Code__c;
            classTitle_5c = primeAddPosMod.Class_Title__c;
            codeNo_5c = primeAddPosMod.Class_Title_Code__c;
            numberOfpositions_5d = (primeAddPosMod.Number_of_Positions__c != null) ? String.valueOf(primeAddPosMod.Number_of_Positions__c) : '';
            positionSerialNumbers_5e = primeAddPosMod.Serial__c;
            //codeNo_5d = '';
            typeOfPosition_5f = '1';
            
            timeBasis_6a = primeAddPosMod.Time_Base__c;
            partTimeFraction_6a = '';
            
            salary_6b = primeAddPosMod.Salary__c;
            rate_6b = primeAddPosMod.Salary_Rate__c;
          }
        }
        else {
          effectiveDate_4a = '';
          expirationDate_4b = '';
          departmentAndOrganizationalUnit_5a = '';
          codeNo_5a = '';
          reportingUnitOrFunction_5b = '';
          codeNo_5b = '';
          classTitle_5c = '';
          BU = '';
          codeNo_5c = '';
          numberOfpositions_5d = '';
          positionSerialNumbers_5e = '';
          //codeNo_5d = '';
          typeOfPosition_5f = '';
          
          timeBasis_6a = '';
          partTimeFraction_6a = '';
          
          salary_6b = '';
          rate_6b = '';
        }
        
        if(form607.X607_Position_Primary_Deletion__c != null) {
          if(form607.X607_Position_Primary_Deletion__r.Position__c != null) {
                      //5-15-2015 BAO added p.Present_Status to list below to reference this field in Position object          
            Position__c posDel = [Select p.Type__c, p.Time_Basis__c, p.Status__c, p.Present_Status_Filled__c, p.Status_DocNo__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Serial_Number__c, p.Part_Time_Fraction__c, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Expiration_Date__c, p.Effective_Date__c, p.Department__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p Where Id = :form607.X607_Position_Primary_Deletion__r.Position__c];
            effectiveDate_7a = (form607.X607_Position_Primary_Deletion__r.Effective_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Deletion__r.Effective_Date__c) : '';
            //effectiveDate_7a = (posDel.Effective_Date__c != null) ? String.valueOf(posDel.Effective_Date__c) : '';
            if(effectiveDate_7a != '') {
              String[] dateParts = effectiveDate_7a.split('-');
              effectiveDate_7a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            disencumberTo_7b = (form607.X607_Position_Primary_Deletion__r.Expiration_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Deletion__r.Expiration_Date__c) : '';
            //disencumberTo_7b = (posDel.Expiration_Date__c != null) ? String.valueOf(posDel.Expiration_Date__c) : '';
            /*if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM') {
              String[] dateParts = disencumberTo_7b.split('-');
              disencumberTo_7b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }*/
            if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM' && !dateWellFormatted(disencumberTo_7b)) {
              String[] dateParts = disencumberTo_7b.split('/');
              dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
              dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
              disencumberTo_7b =  dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
            }
            departmentAndOrganizationalUnit_8a = posDel.Organizational_Unit__c;
            codeNo_8a = posDel.Department__c;
            reportingUnitOrFunction_8b = posDel.Reporting_Unit__c;
            codeNo_8b = posDel.Reporting_Unit_CodeNo__c;
            classTitle_8c = posDel.Class_Title__c;
            codeNo_8c = posDel.Class_Title_CodeNo__c;
            numberOfpositions_8d = '1';
            positionSerialNumbers_8e = posDel.Serial_Number__c;
            //codeNo_5d = '';
            typeOfPosition_8f = posDel.Type__c;
            if(typeOfPosition_8f != null && typeOfPosition_8f.length() > 1) {
              typeOfPosition_8f = typeOfPosition_8f.substring(0, 1);
            }
            
            timeBasis_9a = posDel.Time_Basis__c;
            partTimeFraction_9a = (posDel.Part_Time_Fraction__c != null) ? String.valueOf(posDel.Part_Time_Fraction__c) : '';
            
            salary_9b = (posDel.Salary_Rate__c != null) ? String.valueOf(posDel.Salary_Rate__c) : '';
            rate_9b = posDel.Salary_Per__c;
            
              //5/17/2015 BAO added 1 line below:
                        presentStatus_9c = posDel.Present_Status_Filled__c;
                        
                        docNo_9c = posDel.Status_DocNo__c; 

          }
          else {
            X607_Position_Modification__c primeDelPosMod = [Select x.Salary__c, x.Salary_Rate__c, x.X607__c, x.Unit__c, x.Type__c, x.Time_Base__c, x.SystemModstamp, x.Serial__c, x.Reporting_Unit__c, x.Reporting_Unit_Code__c, x.Position__c, x.Number_of_Positions__c, x.Name, x.LastModifiedDate, x.LastModifiedById, x.LastActivityDate, x.IsDeleted, x.Id, x.Expiration_Date__c, x.Effective_Date__c, x.CreatedDate, x.CreatedById, x.Classification__c, x.Class_Title__c, x.Class_Title_Code__c, x.Approval_Status__c From X607_Position_Modification__c x where x.Id = :form607.X607_Position_Primary_Deletion__c];
            effectiveDate_7a = (primeDelPosMod.Effective_Date__c != null) ? String.valueOf(primeDelPosMod.Effective_Date__c) : '';
            if(effectiveDate_7a != '') {
              String[] dateParts = effectiveDate_7a.split('-');
              effectiveDate_7a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            disencumberTo_7b = (primeDelPosMod.Expiration_Date__c != null) ? String.valueOf(primeDelPosMod.Expiration_Date__c) : '';
            /*if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM') {
              String[] dateParts = disencumberTo_7b.split('-');
              disencumberTo_7b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }*/
            if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM' && !dateWellFormatted(disencumberTo_7b)) {
              String[] dateParts = disencumberTo_7b.split('/');
              dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
              dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
              disencumberTo_7b =  dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
            }
            departmentAndOrganizationalUnit_8a = 'INDUSTRIAL RELATIONS';
            codeNo_8a = '400';
            reportingUnitOrFunction_8b = primeDelPosMod.Reporting_Unit__c;
            codeNo_8b = primeDelPosMod.Reporting_Unit_Code__c;
            classTitle_8c = primeDelPosMod.Class_Title__c;
            codeNo_8c = primeDelPosMod.Class_Title_Code__c;
            numberOfpositions_8d = (primeDelPosMod.Number_of_Positions__c != null) ? String.valueOf(primeDelPosMod.Number_of_Positions__c) : '';
            positionSerialNumbers_8e = primeDelPosMod.Serial__c;
            //codeNo_5d = '';
            typeOfPosition_8f = '1';
            
            timeBasis_9a = primeDelPosMod.Time_Base__c;
            partTimeFraction_9a = '';
            
            salary_9b = primeDelPosMod.Salary__c;
            rate_9b = primeDelPosMod.Salary_Rate__c;
          
            //presentStatus_9c = posDel.Status__c;
            //docNo_9c = posDel.Status_DocNo__c;
          }
        }
        else {
          effectiveDate_7a = '';
          disencumberTo_7b = '';
          departmentAndOrganizationalUnit_8a = '';
          codeNo_8a = '';
          reportingUnitOrFunction_8b = '';
          codeNo_8b = '';
          classTitle_8c = '';
          codeNo_8c = '';
          numberOfpositions_8d = '';
          positionSerialNumbers_8e = '';
          //codeNo_8d = '';
          typeOfPosition_8f = '';
          
          timeBasis_9a = '';
          partTimeFraction_9a = '';
          
          salary_9b = '';
          if(codeNo_8c != null && codeNo_8c == 'various') {
            salary_9b = 'various';
          }
          rate_9b = '';
          
          docNo_9c = '';
          presentStatus_9c = '';
        }
        
        descriptionOfDuties = processDescription(form607.Comments__c);
        
        initials = form607.Initials__c;
        if(form607.Date_Submitted_to_Budget__c != null) {
          String[] dateParts = String.valueOf(form607.Date_Submitted_to_Budget__c).split('-');
          accountingOfficerDate = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
        }
        else {
          accountingOfficerDate = '';
        }
        
        contactPerson_12 = form607.Certification_Contact__c;
        phoneNumber_12 = form607.Certification_Phone_Number__c;
        if(form607.Certification_Date__c != null) {
          String[] dateParts = String.valueOf(form607.Certification_Date__c).split('-');
          contactDate_12 = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
        }
        else {
          contactDate_12 = '';
        }
        approvedCheck = form607.Approved__c;
        
        // Condition for View Position Modifications
        if(ApexPages.currentPage().getParameters().get('posmod') != null) {
          attachedAdditions = new List<PosModWrapper>();
          attachedDeletions = new List<PosModWrapper>();
          outputAdditions = new List<List<PosModWrapper>>();
          outputDeletions = new List<List<PosModWrapper>>();
          output = new List<OutputWrapper>();
          
          Integer rowCount = 0;
          for(X607_Position_Modification__c pm : [select Position__c, Position__r.Serial_Number__c, Position__r.Department__c, Position__r.Reporting_Unit_CodeNo__c, Position__r.Class_Title_CodeNo__c, Position__r.Type__c, Position__r.Time_Basis__c, Position__r.Class_Title__c, Position__r.Salary_Rate__c from X607_Position_Modification__c where Type__c = 'Addition' and X607__c = :form607.Id and Id != :form607.X607_Position_Primary_Addition__c]) {
            Position__c temp = new Position__c();
            temp.Department__c = pm.Position__r.Department__c;
            temp.Reporting_Unit_CodeNo__c = pm.Position__r.Reporting_Unit_CodeNo__c;
            temp.Class_Title_CodeNo__c = pm.Position__r.Class_Title_CodeNo__c;
            temp.Serial_Number__c = pm.Position__r.Serial_Number__c;
            temp.Type__c = pm.Position__r.Type__c;
            temp.Time_Basis__c = pm.Position__r.Time_Basis__c;
            temp.Class_Title__c = pm.Position__r.Class_Title__c;
            temp.Salary_Rate__c = pm.Position__r.Salary_Rate__c;
            
            PosModWrapper pmw = new PosModWrapper(new X607_Position_Modification__c(), temp, 0);
            if(Math.mod(rowCount, 28) == 27) {
              attachedAdditions.add(pmw);
              outputAdditions.add(attachedAdditions);
              attachedAdditions = new List<PosModWrapper>();
            }
            else {
              attachedAdditions.add(pmw);
            }
            rowCount++;
          }
          if(attachedAdditions.size() > 0) {
            outputAdditions.add(attachedAdditions);
          }
          
          rowCount = 0;
          for(X607_Position_Modification__c pm : [select Position__c, Position__r.Serial_Number__c, Position__r.Department__c, Position__r.Reporting_Unit_CodeNo__c, Position__r.Class_Title_CodeNo__c, Position__r.Type__c, Position__r.Time_Basis__c, Position__r.Class_Title__c, Position__r.Salary_Rate__c from X607_Position_Modification__c where Type__c = 'Deletion' and X607__c = :form607.Id and Id != :form607.X607_Position_Primary_Deletion__c]) {
            Position__c temp = new Position__c();
            temp.Department__c = pm.Position__r.Department__c;
            temp.Reporting_Unit_CodeNo__c = pm.Position__r.Reporting_Unit_CodeNo__c;
            temp.Class_Title_CodeNo__c = pm.Position__r.Class_Title_CodeNo__c;
            temp.Serial_Number__c = pm.Position__r.Serial_Number__c;
            temp.Type__c = pm.Position__r.Type__c;
            temp.Time_Basis__c = pm.Position__r.Time_Basis__c;
            temp.Class_Title__c = pm.Position__r.Class_Title__c;
            temp.Salary_Rate__c = pm.Position__r.Salary_Rate__c;
            
            PosModWrapper pmw = new PosModWrapper(new X607_Position_Modification__c(), temp, 0);
            if(Math.mod(rowCount, 28) == 27) {
              attachedDeletions.add(pmw);
              outputDeletions.add(attachedDeletions);
              attachedDeletions = new List<PosModWrapper>();
            }
            else {
              attachedDeletions.add(pmw);
            }
            rowCount++;
          }
          if(attachedDeletions.size() > 0) {
            outputDeletions.add(attachedDeletions);
          }
          
          if(outputAdditions.size() > outputDeletions.size()) {
            for(Integer i = 0; i < outputDeletions.size(); i++) {
              OutputWrapper ow = new OutputWrapper(outputAdditions[i], outputDeletions[i]);
              output.add(ow);
            }
            for(Integer i = outputDeletions.size(); i < outputAdditions.size(); i++) {
              OutputWrapper ow = new OutputWrapper(outputAdditions[i], new List<PosModWrapper>());
              output.add(ow);
            }
          }
          else {
            for(Integer i = 0; i < outputAdditions.size(); i++) {
              OutputWrapper ow = new OutputWrapper(outputAdditions[i], outputDeletions[i]);
              output.add(ow);
            }
            for(Integer i = outputAdditions.size(); i < outputDeletions.size(); i++) {
              OutputWrapper ow = new OutputWrapper(new List<PosModWrapper>(), outputDeletions[i]);
              output.add(ow);
            }
          }
          
          if(outputAdditions.size() == 0) {
            outputAdditions = null;
          }
          if(outputDeletions.size() == 0) {
            outputDeletions = null;
          }
        }
      }
    }
    // Condition for Add Position Modification
    else if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('posmod') != null){
      pdfFontSize = '';
      form607 = [Select x.X607_Position_Primary_Addition__r.Position__r.Name, x.X607_Position_Primary_Addition__r.Salary_Rate__c, x.X607_Position_Primary_Addition__r.Time_Base__c, x.X607_Position_Primary_Addition__r.Reporting_Unit__c, x.X607_Position_Primary_Addition__r.Reporting_Unit_Code__c, x.X607_Position_Primary_Addition__r.Number_of_Positions__c, x.X607_Position_Primary_Addition__r.Expiration_Date__c, x.X607_Position_Primary_Addition__r.Effective_Date__c, x.X607_Position_Primary_Addition__r.Class_Title__c, x.X607_Position_Primary_Addition__r.Class_Title_Code__c, x.X607_Position_Primary_Addition__r.Serial__c, x.X607_Position_Primary_Addition__r.Salary__c,
                x.X607_Position_Primary_Deletion__r.Position__r.Name, x.X607_Position_Primary_Deletion__r.Salary_Rate__c, x.X607_Position_Primary_Deletion__r.Time_Base__c, x.X607_Position_Primary_Deletion__r.Reporting_Unit__c, x.X607_Position_Primary_Deletion__r.Reporting_Unit_Code__c, x.X607_Position_Primary_Deletion__r.Number_of_Positions__c, x.X607_Position_Primary_Deletion__r.Expiration_Date__c, x.X607_Position_Primary_Deletion__r.Effective_Date__c, x.X607_Position_Primary_Deletion__r.Class_Title__c, x.X607_Position_Primary_Deletion__r.Class_Title_Code__c, x.X607_Position_Primary_Deletion__r.Serial__c, x.X607_Position_Primary_Deletion__r.Salary__c, x.X607_Position_Primary_Addition__c, x.X607_Position_Primary_Deletion__c, x.Document_No__c, x.Id, x.Type__c From X607__c x Where x.Id = :ApexPages.currentPage().getParameters().get('id')];
      attachedAdditions = new List<PosModWrapper>();
      attachedDeletions = new List<PosModWrapper>();
      primaryAddition = new X607_Position_Modification__c();
      primaryDeletion = new X607_Position_Modification__c();
      newAddPos = new Position__c();
      newDelPos = new Position__c();
      
      if(form607.X607_Position_Primary_Addition__c != null && form607.X607_Position_Primary_Addition__r.Number_of_Positions__c > 1) {
        // Visible addition fields
        newAddPos.Department__c = '400';
        newAddPos.Reporting_Unit_CodeNo__c = (form607.X607_Position_Primary_Addition__r.Reporting_Unit_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Reporting_Unit_Code__c : '';
        newAddPos.Class_Title_CodeNo__c = (form607.X607_Position_Primary_Addition__r.Class_Title_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Class_Title_Code__c : '';
        newAddPos.Type__c = '1';
        newAddPos.Time_Basis__c = form607.X607_Position_Primary_Addition__r.Time_Base__c;
        newAddPos.Salary_Per__c = form607.X607_Position_Primary_Addition__r.Salary_Rate__c;
        newAddPos.Serial_Number__c = (form607.X607_Position_Primary_Addition__r.Serial__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Serial__c : '';
        newAddPos.Salary_Rate__c = (form607.X607_Position_Primary_Addition__r.Salary__c.toLowerCase() != 'various') ? Double.valueOf(form607.X607_Position_Primary_Addition__r.Salary__c) : null;
        
        // Other addition fields
        if(form607.Type__c == 'Proposed New' || form607.Type__c == 'Extension of Present' || form607.Type__c == 'Reclassification') {
          newAddPos.Effective_Date__c = form607.X607_Position_Primary_Addition__r.Effective_Date__c;
          newAddPos.Expiration_Date__c = form607.X607_Position_Primary_Addition__r.Expiration_Date__c;
          if(newAddPos.Expiration_Date__c.toUpperCase() == 'PERM') {
            newAddPos.Term_Type__c = 'Permanent';
          }
          else {
            newAddPos.Term_Type__c = 'Limited';
          }
        }
        newAddPos.Organizational_Unit__c = 'INDUSTRIAL RELATIONS';
        newAddPos.Reporting_Unit__c = (form607.X607_Position_Primary_Addition__r.Reporting_Unit_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Reporting_Unit__c : '';
        newAddPos.Class_Title__c = (form607.X607_Position_Primary_Addition__r.Class_Title_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Class_Title__c : '';
      }
      if(form607.X607_Position_Primary_Deletion__c != null && form607.X607_Position_Primary_Deletion__r.Number_of_Positions__c > 1) {
        // Visible deletion fields
        newDelPos.Department__c = '400';
        newDelPos.Reporting_Unit_CodeNo__c = (form607.X607_Position_Primary_Deletion__r.Reporting_Unit_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Deletion__r.Reporting_Unit_Code__c : '';
        newDelPos.Class_Title_CodeNo__c = (form607.X607_Position_Primary_Deletion__r.Class_Title_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Deletion__r.Class_Title_Code__c : '';
        //newDelPos.Type__c = '1';
        //newDelPos.Time_Basis__c = form607.X607_Position_Primary_Deletion__r.Time_Base__c;
        
        //newDelPos.Effective_Date__c = form607.X607_Position_Primary_Deletion__r.Effective_Date__c;
        //newDelPos.Expiration_Date__c = form607.X607_Position_Primary_Deletion__r.Expiration_Date__c;
      }
      
      system.debug('REACHED after initialization');
      Map<Id, PosModWrapper> ModificationToPositionMap = new Map<Id, PosModWrapper>();
      for(X607_Position_Modification__c pm : [select Id, Position__c from X607_Position_Modification__c where Type__c = 'Addition' and X607__c = :form607.Id and Id != :form607.X607_Position_Primary_Addition__c]) {
        PosModWrapper temp = new PosModWrapper(pm, new Position__c(), globalIndex);
        ModificationToPositionMap.put(pm.Position__c, temp);
        globalIndex++;
      }
      for(Position__c pos : [select Id, Department__c, Reporting_Unit_CodeNo__c, Class_Title_CodeNo__c, Serial_Number__c, Type__c, Time_Basis__c, Class_Title__c, Salary_Rate__c from Position__c where Id in :ModificationToPositionMap.keySet()]) {
        if(ModificationToPositionMap.containsKey(pos.Id)) {
          PosModWrapper temp = ModificationToPositionMap.get(pos.Id);
          temp.pos = pos;
          attachedAdditions.add(temp);
        }
      }
      
      ModificationToPositionMap = new Map<Id, PosModWrapper>();
      for(X607_Position_Modification__c pm : [select Id, Position__c from X607_Position_Modification__c where Type__c = 'Deletion' and X607__c = :form607.Id and Id != :form607.X607_Position_Primary_Deletion__c]) {
        PosModWrapper temp = new PosModWrapper(pm, new Position__c(), globalIndex);
        ModificationToPositionMap.put(pm.Position__c, temp);
        globalIndex++;
      }
      for(Position__c pos : [select Id, Department__c, Reporting_Unit_CodeNo__c, Class_Title_CodeNo__c, Serial_Number__c, Type__c, Time_Basis__c, Class_Title__c, Salary_Rate__c from Position__c where Id in :ModificationToPositionMap.keySet()]) {
        if(ModificationToPositionMap.containsKey(pos.Id)) {
          PosModWrapper temp = ModificationToPositionMap.get(pos.Id);
          temp.pos = pos;
          attachedDeletions.add(temp);
        }
      }
      
      system.debug('REACHED esarching for existing modifications');
    }
    // Condition for new Form 607
    else if(ApexPages.currentPage().getParameters().get('id') == null){
      pdfFontSize = 'font-size:12pt;padding-top:10px;padding-bottom:10px';
      form607 = new X607__c();
      renderMode = '';
      pageTitle = 'New Form 607';
      
      dateFormatError = 'Date format \'MM-DD-YYYY\'';
      WFD_effectiveDate_4a = true;
      WFD_expirationDate_4b = true;
      WFD_effectiveDate_7a = true;
      WFD_disencumberTo_7b = true;
      WFD_accountingOfficerDate = true;
      WFD_contactDate_12 = true;
      
      routing = '';
      routeTo = '';
      routeToOptions = new List<SelectOption>();
      routeToOptions.add(new SelectOption('true', 'Controller\'s Division of Disbursements'));
      routeToOptions.add(new SelectOption('false', 'Other (specify)'));
      
      transactionType = '';
      transactionOptions = new List<SelectOption>();
      transactionOptions.add(new SelectOption('Proposed New', 'Proposed New Position'));
      transactionOptions.add(new SelectOption('Extension of Present', 'Extension of Present Position'));
      transactionOptions.add(new SelectOption('Reclassification', 'Reclassification of Position'));
      transactionOptions.add(new SelectOption('Encumbrance', 'Encumbrance Increase'));
      transactionOptions.add(new SelectOption('Abolishment', 'Abolishment of Position'));
      transactionOptions.add(new SelectOption('Disencumbrance', 'Disencumbrance'));
      transactionOptions.add(new SelectOption('Other', 'Other (Describe in item 10)'));
      transactionOptions.add(new SelectOption('', 'None'));
      
      fiscalYear = '';
      documentNo = '';
      
      effectiveDate_4a = '';
      expirationDate_4b = '';
      departmentAndOrganizationalUnit_5a = '';
      codeNo_5a = '';
      reportingUnitOrFunction_5b = '';
      codeNo_5b = '';
      classTitle_5c = '';
      BU = '';
      codeNo_5c = '';
      numberOfpositions_5d = '';
      positionSerialNumbers_5e = '';
      //codeNo_5d = '';
      typeOfPosition_5f = '';
      
      timeBasis_6a = '';
      partTimeFraction_6a = '';
      timeBasisOptions_6a = new List<SelectOption>();
      timeBasisOptions_6a.add(new SelectOption('Full-Time', 'FULL-TIME'));
      timeBasisOptions_6a.add(new SelectOption('Part-Time', 'PART-TIME'));
      timeBasisOptions_6a.add(new SelectOption('Intermittent', 'INTERMITTENT'));
      timeBasisOptions_6a.add(new SelectOption('Indeterminate', 'INDETERMINATE'));
      timeBasisOptions_6a.add(new SelectOption('', 'None'));
      
      salary_6b = '';
      rate_6b = '';
      rateOptions_6b = new List<SelectOption>();
      rateOptions_6b.add(new SelectOption('Month', 'MONTH'));
      rateOptions_6b.add(new SelectOption('Day', 'DAY'));
      rateOptions_6b.add(new SelectOption('Hour', 'HOUR'));
      rateOptions_6b.add(new SelectOption('', 'None'));
      
      effectiveDate_7a = '';
      disencumberTo_7b = '';
      departmentAndOrganizationalUnit_8a = '';
      codeNo_8a = '';
      reportingUnitOrFunction_8b = '';
      codeNo_8b = '';
      classTitle_8c = '';
      codeNo_8c = '';
      numberOfpositions_8d = '';
      positionSerialNumbers_8e = '';
      //codeNo_8d = '';
      typeOfPosition_8f = '';
      
      timeBasis_9a = '';
      partTimeFraction_9a = '';
      timeBasisOptions_9a = new List<SelectOption>();
      timeBasisOptions_9a.add(new SelectOption('Full-Time', 'FULL-TIME'));
      timeBasisOptions_9a.add(new SelectOption('Part-Time', 'PART-TIME'));
      timeBasisOptions_9a.add(new SelectOption('Intermittent', 'INTERMITTENT'));
      timeBasisOptions_9a.add(new SelectOption('Indeterminate', 'INDETERMINATE'));
      timeBasisOptions_9a.add(new SelectOption('', 'None'));
      
      salary_9b = '';
      rate_9b = '';
      rateOptions_9b = new List<SelectOption>();
      rateOptions_9b.add(new SelectOption('Month', 'MONTH'));
      rateOptions_9b.add(new SelectOption('Day', 'DAY'));
      rateOptions_9b.add(new SelectOption('Hour', 'HOUR'));
      rateOptions_9b.add(new SelectOption('', 'None'));
      
      docNo_9c = '';
      presentStatus_9c = '';
      presentStatusOptions_9c = new List<SelectOption>();
      presentStatusOptions_9c.add(new SelectOption('Vacant', 'VACANT'));
      presentStatusOptions_9c.add(new SelectOption('Filled', 'FILLED'));
      presentStatusOptions_9c.add(new SelectOption('Employees Status Changed By Form', 'EMPLOYEE\'S STATUS CHANGED BY FORM'));
      presentStatusOptions_9c.add(new SelectOption('', 'None'));
      
      descriptionOfDuties = '';
      standardDescription = '';
      standardComments = new List<SelectOption>();
      standardComments.add(new SelectOption('', '-- None --'));
      standardComments.add(new SelectOption('Reclassed to meet the needs of the division', 'Reclassed to meet the needs of the division'));
      standardComments.add(new SelectOption('Reporting Unit change to meet the needs of the division', 'Reporting Unit change to meet the needs of the division'));
      
      initials = '';
      accountingOfficerDate = '';
      
      contactPerson_12 = '';
      phoneNumber_12 = '';
      contactDate_12 = '';
      
      approvedCheck = true;
      
      // Checks if this page was navigated from a Form 1 record
      if(ApexPages.currentPage().getParameters().get('fid') != null){
        form607.Form_1__c = ApexPages.currentPage().getParameters().get('fid');
        Form_1__c f1 = [select Id, SEC1_Position_Number__c, SEC2_Position_Number__c, SEC5_Form_607_Number__c, SEC1_Position__c from Form_1__c where Id = :ApexPages.currentPage().getParameters().get('fid')];
        if(f1 != null) {
          System.debug('DELETION POSITION: ' + f1.SEC1_Position__c);
          if(f1.SEC1_Position__c != null) {
            Position__c posDel = [Select p.Type__c, p.Time_Basis__c, p.Status__c, p.Status_DocNo__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Serial_Number__c, p.Part_Time_Fraction__c, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Expiration_Date__c, p.Effective_Date__c, p.Department__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p Where Id = :f1.SEC1_Position__c];
            //effectiveDate_7a = (posDel.Effective_Date__c != null) ? String.valueOf(posDel.Effective_Date__c) : '';
            if(effectiveDate_7a != '') {
              String[] dateParts = effectiveDate_7a.split('-');
              effectiveDate_7a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            //disencumberTo_7b = (posDel.Expiration_Date__c != null) ? String.valueOf(posDel.Expiration_Date__c) : '';
            if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM') {
              String[] dateParts = disencumberTo_7b.split('-');
              disencumberTo_7b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
            }
            departmentAndOrganizationalUnit_8a = posDel.Organizational_Unit__c;
            codeNo_8a = posDel.Department__c;
            reportingUnitOrFunction_8b = posDel.Reporting_Unit__c;
            codeNo_8b = posDel.Reporting_Unit_CodeNo__c;
            classTitle_8c = posDel.Class_Title__c;
            codeNo_8c = posDel.Class_Title_CodeNo__c;
            numberOfpositions_8d = '1';
            positionSerialNumbers_8e = posDel.Serial_Number__c;
            //codeNo_5d = '';
            typeOfPosition_8f = posDel.Type__c;
            if(typeOfPosition_8f != null && typeOfPosition_8f.length() > 1) {
              typeOfPosition_8f = typeOfPosition_8f.substring(0, 1);
            }
            
            timeBasis_9a = posDel.Time_Basis__c;
            partTimeFraction_9a = (posDel.Part_Time_Fraction__c != null) ? String.valueOf(posDel.Part_Time_Fraction__c) : '';
            
            salary_9b = (posDel.Salary_Rate__c != null) ? String.valueOf(posDel.Salary_Rate__c) : '';
            rate_9b = posDel.Salary_Per__c;
            /*String[] parts = f1.SEC1_Position_Number__c.split('-');
            system.debug(parts.size());
            system.debug(parts);
            
            if(parts.size() == 4) {
              codeNo_8a = parts[0];
              codeNo_8b = parts[1];
              codeNo_8c = parts[2];
              positionSerialNumbers_8e = parts[3];
              
              departmentAndOrganizationalUnit_8a = 'INDUSTRIAL RELATIONS';
              
              List<Unit__c> tempUnitList = [select Id, Unit_Name__c from Unit__c where Name = :codeNo_8b];
              Unit__c tempUnit = null;
              if(tempUnitList.size() == 1) {
                tempUnit = tempUnitList.get(0);
              }
              if(tempUnit != null) {
                reportingUnitOrFunction_8b = tempUnit.Unit_Name__c;
              }
              
              List<Classification__c> tempClassList = [select Id, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :codeNo_8c];
              Classification__c tempClass = null;
              if(tempClassList.size() == 1) {
                tempClass = tempClassList.get(0);
              }
              
              if(tempClass != null && tempClass.Id != null) {
                classTitle_8c = tempClass.Classification_Name__c;
                salary_9b = String.valueOf(tempClass.Minimum_Salary_Rate__c);
                rate_9b = tempClass.Salary_Per__c;
                typeOfPosition_8f = tempClass.Type_of_Position__c.substring(0,1);
              }
              
              numberOfpositions_8d = '1';
            }*/
          }
          if(f1.SEC2_Position_Number__c != null && f1.SEC2_Position_Number__c != '') {
            String[] parts = f1.SEC2_Position_Number__c.split('-');
            
            if(parts.size() == 4) {
              codeNo_5a = parts[0];
              codeNo_5b = parts[1];
              codeNo_5c = parts[2];
              positionSerialNumbers_5e = parts[3];
              
              departmentAndOrganizationalUnit_5a = 'INDUSTRIAL RELATIONS';
              
              List<Unit__c> tempUnitList = [select Id, Unit_Name__c from Unit__c where Name = :codeNo_5b];
              Unit__c tempUnit = null;
              if(tempUnitList.size() == 1) {
                tempUnit = tempUnitList.get(0);
              }
              if(tempUnit != null) {
                reportingUnitOrFunction_5b = tempUnit.Unit_Name__c;
              }
              
              List<Classification__c> tempClassList = [select Bargaining_Unit__c, Id, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :codeNo_5c order by Classification_Name__c limit 1];
              Classification__c tempClass = null;
              if(tempClassList.size() == 1) {
                tempClass = tempClassList.get(0);
              }
              
              if(tempClass != null && tempClass.Id != null) {
                classTitle_5c = tempClass.Classification_Name__c;
                BU = tempClass.Bargaining_Unit__c;
                salary_6b = String.valueOf(tempClass.Minimum_Salary_Rate__c);
                rate_6b = tempClass.Salary_Per__c;
                typeOfPosition_5f = tempClass.Type_of_Position__c.substring(0,1);
              }
              
              numberOfpositions_5d = '1';
            }
          }
        }
      }
    }
    // Condition for Edit Form 607
    else {
      pdfFontSize = 'font-size:12pt;padding-top:10px;padding-bottom:10px';
      system.debug(ApexPages.currentPage().getParameters().get('id'));
      form607 = [Select x.Approved__c, x.X607_Position_Primary_Deletion__c, x.X607_Position_Primary_Addition__r.Effective_Date__c, x.X607_Position_Primary_Addition__r.Expiration_Date__c, x.X607_Position_Primary_Deletion__r.Effective_Date__c, x.X607_Position_Primary_Deletion__r.Expiration_Date__c, x.X607_Position_Primary_Deletion__r.Position__c, x.X607_Position_Primary_Addition__r.Position__c, x.X607_Position_Primary_Addition__c, x.Type__c, x.SystemModstamp, x.Status__c, x.Standard_Comment__c, x.Routing__c, x.Route_To__c, x.OwnerId, x.Name, x.LastModifiedDate, x.LastModifiedById, x.LastActivityDate, x.IsDeleted, x.Initials__c, x.Id, x.Form_1__c, x.Fiscal_Year__c, x.Expiration_Date__c, x.Effective_Date__c, x.Document_No__c, x.Date_Submitted_to_Budget__c, x.CreatedDate, x.CreatedById, x.Comments__c, x.Certification_Phone_Number__c, x.Certification_Date__c, x.Certification_Contact__c From X607__c x Where x.Id = :ApexPages.currentPage().getParameters().get('id')];
      system.debug(form607);
      renderMode = '';
      pageTitle = 'Edit Form 607: ' + form607.Name;
      pdfURL = '/apex/form607?id=' + form607.Id + '&pdf=true';
      attachmentURL = '/apex/positionModificationAttachment?id=' + form607.Id + '&pdf=true&posmod=true';
      
      // Check Approval Status
      List<ProcessInstance> pi = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId = :form607.Id];
      if(pi.size() == 1) {
        approvalStatus = pi.get(0).Status;
      }
      else {
        approvalStatus = 'Not Submitted';
      }
      
      dateFormatError = 'Date format \'MM-DD-YYYY\'';
      WFD_effectiveDate_4a = true;
      WFD_expirationDate_4b = true;
      WFD_effectiveDate_7a = true;
      WFD_disencumberTo_7b = true;
      WFD_accountingOfficerDate = true;
      WFD_contactDate_12 = true;
      
      routeToOptions = new List<SelectOption>();
      routeToOptions.add(new SelectOption('true', 'Controller\'s Division of Disbursements'));
      routeToOptions.add(new SelectOption('false', 'Other (specify)'));
      
      transactionOptions = new List<SelectOption>();
      transactionOptions.add(new SelectOption('Proposed New', 'Proposed New Position'));
      transactionOptions.add(new SelectOption('Extension of Present', 'Extension of Present Position'));
      transactionOptions.add(new SelectOption('Reclassification', 'Reclassification of Position'));
      transactionOptions.add(new SelectOption('Encumbrance', 'Encumbrance Increase'));
      transactionOptions.add(new SelectOption('Abolishment', 'Abolishment of Position'));
      transactionOptions.add(new SelectOption('Disencumbrance', 'Disencumbrance'));
      transactionOptions.add(new SelectOption('Other', 'Other (Describe in item 10)'));
      transactionOptions.add(new SelectOption('', 'None'));

      timeBasisOptions_6a = new List<SelectOption>();
      timeBasisOptions_6a.add(new SelectOption('Full-Time', 'FULL-TIME'));
      timeBasisOptions_6a.add(new SelectOption('Part-Time', 'PART-TIME'));
      timeBasisOptions_6a.add(new SelectOption('Intermittent', 'INTERMITTENT'));
      timeBasisOptions_6a.add(new SelectOption('Indeterminate', 'INDETERMINATE'));
      timeBasisOptions_6a.add(new SelectOption('', 'None'));
      
      rateOptions_6b = new List<SelectOption>();
      rateOptions_6b.add(new SelectOption('Month', 'MONTH'));
      rateOptions_6b.add(new SelectOption('Day', 'DAY'));
      rateOptions_6b.add(new SelectOption('Hour', 'HOUR'));
      rateOptions_6b.add(new SelectOption('', 'None'));
      
      timeBasisOptions_9a = new List<SelectOption>();
      timeBasisOptions_9a.add(new SelectOption('Full-Time', 'FULL-TIME'));
      timeBasisOptions_9a.add(new SelectOption('Part-Time', 'PART-TIME'));
      timeBasisOptions_9a.add(new SelectOption('Intermittent', 'INTERMITTENT'));
      timeBasisOptions_9a.add(new SelectOption('Indeterminate', 'INDETERMINATE'));
      timeBasisOptions_9a.add(new SelectOption('', 'None'));
      
      rateOptions_9b = new List<SelectOption>();
      rateOptions_9b.add(new SelectOption('Month', 'MONTH'));
      rateOptions_9b.add(new SelectOption('Day', 'DAY'));
      rateOptions_9b.add(new SelectOption('Hour', 'HOUR'));
      rateOptions_9b.add(new SelectOption('', 'None'));
      
      presentStatusOptions_9c = new List<SelectOption>();
      presentStatusOptions_9c.add(new SelectOption('Vacant', 'VACANT'));
      presentStatusOptions_9c.add(new SelectOption('Filled', 'FILLED'));
      presentStatusOptions_9c.add(new SelectOption('Employees Status Changed By Form', 'EMPLOYEE\'S STATUS CHANGED BY FORM'));
      presentStatusOptions_9c.add(new SelectOption('', 'None'));
      
      routing = form607.Routing__c;
      //routeTo = (form607.Route_To__c == 'Other (specify)') ? 'false' : 'true';
      routeTo = '';
      
      transactionType = form607.Type__c;
      
      fiscalYear = form607.Fiscal_Year__c;
      documentNo = form607.Document_No__c;

      if(form607.X607_Position_Primary_Addition__c != null) {
        // Case for when there is only one addition, the Position in the primary addition will be filled
        if(form607.X607_Position_Primary_Addition__r.Position__c != null) {
          Position__c posAdd = [Select p.BU__c, p.Type__c, p.Time_Basis__c, p.Status__c, p.Status_DocNo__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Serial_Number__c, p.Part_Time_Fraction__c, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Expiration_Date__c, p.Effective_Date__c, p.Department__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p Where Id = :form607.X607_Position_Primary_Addition__r.Position__c];
          effectiveDate_4a = (form607.X607_Position_Primary_Addition__r.Effective_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Addition__r.Effective_Date__c) : '';
          //effectiveDate_4a = (posAdd.Effective_Date__c != null) ? String.valueOf(posAdd.Effective_Date__c) : '';
          if(effectiveDate_4a != '') {
            String[] dateParts = effectiveDate_4a.split('-');
            effectiveDate_4a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }
          expirationDate_4b = (form607.X607_Position_Primary_Addition__r.Expiration_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Addition__r.Expiration_Date__c) : '';
          //expirationDate_4b = (posAdd.Expiration_Date__c != null) ? String.valueOf(posAdd.Expiration_Date__c) : '';
          /*if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
            String[] dateParts = expirationDate_4b.split('-');
            expirationDate_4b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }*/
          if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
            String[] dateParts = expirationDate_4b.split('/');
            dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
            dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
            expirationDate_4b = dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
          }
          
          departmentAndOrganizationalUnit_5a = posAdd.Organizational_Unit__c;
          codeNo_5a = posAdd.Department__c;
          reportingUnitOrFunction_5b = posAdd.Reporting_Unit__c;
          codeNo_5b = posAdd.Reporting_Unit_CodeNo__c;
          classTitle_5c = posAdd.Class_Title__c;
          BU = posAdd.BU__c;
          codeNo_5c = posAdd.Class_Title_CodeNo__c;
          numberOfpositions_5d = '1';
          positionSerialNumbers_5e = posAdd.Serial_Number__c;
          typeOfPosition_5f = posAdd.Type__c;
          if(typeOfPosition_5f != null && typeOfPosition_5f.length() > 1) {
            typeOfPosition_5f = typeOfPosition_5f.substring(0, 1);
          }
          
          timeBasis_6a = posAdd.Time_Basis__c;
          partTimeFraction_6a = (posAdd.Part_Time_Fraction__c != null) ? String.valueOf(posAdd.Part_Time_Fraction__c) : '';
          
          salary_6b = (posAdd.Salary_Rate__c != null) ? String.valueOf(posAdd.Salary_Rate__c) : '';
          rate_6b = posAdd.Salary_Per__c;
        }
        // Otherwise there are various positions and an attachment will be used
        else {
          X607_Position_Modification__c primeAddPosMod = [Select x.Salary__c, x.Salary_Rate__c, x.X607__c, x.Unit__c, x.Type__c, x.Time_Base__c, x.SystemModstamp, x.Serial__c, x.Reporting_Unit__c, x.Reporting_Unit_Code__c, x.Position__c, x.Number_of_Positions__c, x.Name, x.LastModifiedDate, x.LastModifiedById, x.LastActivityDate, x.IsDeleted, x.Id, x.Expiration_Date__c, x.Effective_Date__c, x.CreatedDate, x.CreatedById, x.Classification__c, x.Class_Title__c, x.Class_Title_Code__c, x.Approval_Status__c From X607_Position_Modification__c x where x.Id = :form607.X607_Position_Primary_Addition__c];
          effectiveDate_4a = (primeAddPosMod.Effective_Date__c != null) ? String.valueOf(primeAddPosMod.Effective_Date__c) : '';
          if(effectiveDate_4a != '') {
            String[] dateParts = effectiveDate_4a.split('-');
            effectiveDate_4a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }
          expirationDate_4b = (primeAddPosMod.Expiration_Date__c != null) ? String.valueOf(primeAddPosMod.Expiration_Date__c) : '';
          /*if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
            String[] dateParts = expirationDate_4b.split('-');
            expirationDate_4b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }*/
          if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
            String[] dateParts = expirationDate_4b.split('/');
            dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
            dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
            expirationDate_4b = dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
          }
          
          departmentAndOrganizationalUnit_5a = 'INDUSTRIAL RELATIONS';
          codeNo_5a = '400';
          reportingUnitOrFunction_5b = primeAddPosMod.Reporting_Unit__c;
          codeNo_5b = primeAddPosMod.Reporting_Unit_Code__c;
          classTitle_5c = primeAddPosMod.Class_Title__c;
          codeNo_5c = primeAddPosMod.Class_Title_Code__c;
          numberOfpositions_5d = (primeAddPosMod.Number_of_Positions__c != null) ? String.valueOf(primeAddPosMod.Number_of_Positions__c) : '';
          positionSerialNumbers_5e = primeAddPosMod.Serial__c;
          //codeNo_5d = '';
          typeOfPosition_5f = '1';
          
          timeBasis_6a = primeAddPosMod.Time_Base__c;
          partTimeFraction_6a = '';
          
          salary_6b = primeAddPosMod.Salary__c;
          rate_6b = primeAddPosMod.Salary_Rate__c;
        }
      }
      else {
        effectiveDate_4a = '';
        expirationDate_4b = '';
        departmentAndOrganizationalUnit_5a = '';
        codeNo_5a = '';
        reportingUnitOrFunction_5b = '';
        codeNo_5b = '';
        classTitle_5c = '';
        codeNo_5c = '';
        numberOfpositions_5d = '';
        positionSerialNumbers_5e = '';
        //codeNo_5d = '';
        typeOfPosition_5f = '';
        
        timeBasis_6a = '';
        partTimeFraction_6a = '';
        
        salary_6b = '';
        rate_6b = '';
      }
      
      if(form607.X607_Position_Primary_Deletion__c != null) {
        if(form607.X607_Position_Primary_Deletion__r.Position__c != null) {
          //5-15-2015 BAO added p.Present_Status to list below to reference this field in Position object 
          Position__c posDel = [Select p.Type__c, p.Time_Basis__c, p.Status__c, p.Present_Status_Filled__c, p.Status_DocNo__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Serial_Number__c, p.Part_Time_Fraction__c, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Expiration_Date__c, p.Effective_Date__c, p.Department__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p Where Id = :form607.X607_Position_Primary_Deletion__r.Position__c];
          
          system.debug('PRIMARY DELETION: ' + posdel);
          effectiveDate_7a = (form607.X607_Position_Primary_Deletion__r.Effective_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Deletion__r.Effective_Date__c) : '';
          //effectiveDate_7a = (posDel.Effective_Date__c != null) ? String.valueOf(posDel.Effective_Date__c) : '';
          if(effectiveDate_7a != '') {
            String[] dateParts = effectiveDate_7a.split('-');
            effectiveDate_7a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }
          disencumberTo_7b = (form607.X607_Position_Primary_Deletion__r.Expiration_Date__c != null) ? String.valueOf(form607.X607_Position_Primary_Deletion__r.Expiration_Date__c) : '';
          //disencumberTo_7b = (posDel.Expiration_Date__c != null) ? String.valueOf(posDel.Expiration_Date__c) : '';
          /*if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM') {
            String[] dateParts = disencumberTo_7b.split('-');
            disencumberTo_7b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }*/
          if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM' && !dateWellFormatted(disencumberTo_7b)) {
            String[] dateParts = disencumberTo_7b.split('/');
            dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
            dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
            disencumberTo_7b =  dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
          }
          departmentAndOrganizationalUnit_8a = posDel.Organizational_Unit__c;
          codeNo_8a = posDel.Department__c;
          reportingUnitOrFunction_8b = posDel.Reporting_Unit__c;
          codeNo_8b = posDel.Reporting_Unit_CodeNo__c;
          classTitle_8c = posDel.Class_Title__c;
          codeNo_8c = posDel.Class_Title_CodeNo__c;
          numberOfpositions_8d = '1';
          positionSerialNumbers_8e = posDel.Serial_Number__c;
          typeOfPosition_8f = posDel.Type__c;
          if(typeOfPosition_8f != null && typeOfPosition_8f.length() > 1) {
            typeOfPosition_8f = typeOfPosition_8f.substring(0, 1);
          }
          
          timeBasis_9a = posDel.Time_Basis__c;
          partTimeFraction_9a = (posDel.Part_Time_Fraction__c != null) ? String.valueOf(posDel.Part_Time_Fraction__c) : '';
          
          salary_9b = (posDel.Salary_Rate__c != null) ? String.valueOf(posDel.Salary_Rate__c) : '';
          rate_9b = posDel.Salary_Per__c;
        
          //5-15-2015 BAO added p.Present_Status to list below to have 9c to show Present Status instead of Status
          if (approvalStatus == 'Approved')
            presentStatus_9c = posDel.Present_Status_Filled__c;
          else
          presentStatus_9c = posDel.Status__c;
          posDel.Status_DocNo__c = docNo_9c;

        }
        else {
          X607_Position_Modification__c primeDelPosMod = [Select x.Salary__c, x.Salary_Rate__c, x.X607__c, x.Unit__c, x.Type__c, x.Time_Base__c, x.SystemModstamp, x.Serial__c, x.Reporting_Unit__c, x.Reporting_Unit_Code__c, x.Position__c, x.Number_of_Positions__c, x.Name, x.LastModifiedDate, x.LastModifiedById, x.LastActivityDate, x.IsDeleted, x.Id, x.Expiration_Date__c, x.Effective_Date__c, x.CreatedDate, x.CreatedById, x.Classification__c, x.Class_Title__c, x.Class_Title_Code__c, x.Approval_Status__c From X607_Position_Modification__c x where x.Id = :form607.X607_Position_Primary_Deletion__c];
          effectiveDate_7a = (primeDelPosMod.Effective_Date__c != null) ? String.valueOf(primeDelPosMod.Effective_Date__c) : '';
          if(effectiveDate_7a != '') {
            String[] dateParts = effectiveDate_7a.split('-');
            effectiveDate_7a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }
          disencumberTo_7b = (primeDelPosMod.Expiration_Date__c != null) ? String.valueOf(primeDelPosMod.Expiration_Date__c) : '';
          /*if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM') {
            String[] dateParts = disencumberTo_7b.split('-');
            disencumberTo_7b = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
          }*/
          if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM' && !dateWellFormatted(disencumberTo_7b)) {
            String[] dateParts = disencumberTo_7b.split('/');
            dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
            dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
            disencumberTo_7b =  dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
          }
          departmentAndOrganizationalUnit_8a = 'INDUSTRIAL RELATIONS';
          codeNo_8a = '400';
          reportingUnitOrFunction_8b = primeDelPosMod.Reporting_Unit__c;
          codeNo_8b = primeDelPosMod.Reporting_Unit_Code__c;
          classTitle_8c = primeDelPosMod.Class_Title__c;
          codeNo_8c = primeDelPosMod.Class_Title_Code__c;
          numberOfpositions_8d = (primeDelPosMod.Number_of_Positions__c != null) ? String.valueOf(primeDelPosMod.Number_of_Positions__c) : '';
          positionSerialNumbers_8e = primeDelPosMod.Serial__c;
          //codeNo_5d = '';
          typeOfPosition_8f = '1';
          
          timeBasis_9a = primeDelPosMod.Time_Base__c;
          partTimeFraction_9a = '';
          
          salary_9b = primeDelPosMod.Salary__c;
          rate_9b = primeDelPosMod.Salary_Rate__c;
        
          //presentStatus_9c = posDel.Status__c;
          //docNo_9c = posDel.Status_DocNo__c;
        }
      }
      else {
        effectiveDate_7a = '';
        disencumberTo_7b = '';
        departmentAndOrganizationalUnit_8a = '';
        codeNo_8a = '';
        reportingUnitOrFunction_8b = '';
        codeNo_8b = '';
        classTitle_8c = '';
        codeNo_8c = '';
        numberOfpositions_8d = '';
        positionSerialNumbers_8e = '';
        //codeNo_8d = '';
        typeOfPosition_8f = '';
        
        timeBasis_9a = '';
        partTimeFraction_9a = '';
        
        salary_9b = '';
        rate_9b = '';
        
        docNo_9c = '';
        presentStatus_9c = '';
      }
      
      descriptionOfDuties = processDescriptionForEdit(form607.Comments__c);
      standardDescription = '';
      standardComments = new List<SelectOption>();
      standardComments.add(new SelectOption('', '-- None --'));
      standardComments.add(new SelectOption('Reclassed to meet the needs of the division', 'Reclassed to meet the needs of the division'));
      standardComments.add(new SelectOption('Reporting Unit change to meet the needs of the division', 'Reporting Unit change to meet the needs of the division'));
      
      initials = form607.Initials__c;
      if(form607.Date_Submitted_to_Budget__c != null) {
        String[] dateParts = String.valueOf(form607.Date_Submitted_to_Budget__c).split('-');
        accountingOfficerDate = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
      }
      else {
        accountingOfficerDate = '';
      }
      
      contactPerson_12 = form607.Certification_Contact__c;
      phoneNumber_12 = form607.Certification_Phone_Number__c;
      if(form607.Certification_Date__c != null) {
        String[] dateParts = String.valueOf(form607.Certification_Date__c).split('-');
        contactDate_12 = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
      }
      else {
        contactDate_12 = '';
      }
      approvedCheck = form607.Approved__c;
    }
  }
  
  public PageReference resetDates() {
    String[] dateParts = null;
    if(effectiveDate_4a != '' && !dateWellFormatted(effectiveDate_4a)) {
      dateParts = effectiveDate_4a.split('-');
      effectiveDate_4a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
    }
    if(expirationDate_4b != '' && expirationDate_4b != 'PERM' && !dateWellFormatted(expirationDate_4b)) {
      dateParts = expirationDate_4b.split('/');
      dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
      dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
      expirationDate_4b =  dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
    }
    if(effectiveDate_7a != '' && !dateWellFormatted(effectiveDate_7a)) {
      dateParts = effectiveDate_7a.split('-');
      effectiveDate_7a = dateParts[1] + '-' + dateParts[2] + '-' + dateParts[0];
    }
    if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM' && !dateWellFormatted(disencumberTo_7b)) {
      dateParts = disencumberTo_7b.split('/');
      dateParts[0] = (dateParts[0].length()==1) ? '0' + dateParts[0] : dateParts[0];
      dateParts[1] = (dateParts[1].length()==1) ? '0' + dateParts[1] : dateParts[1];
      disencumberTo_7b =  dateParts[0] + '-' + dateParts[1] + '-' + dateParts[2];
    }
    return null;
  }
  
  public PageReference saveForm() {
    numPos5dError = '';
    numPos8dError = ''; 
    salary6bError = '';
    salary9bError = '';
    primaryAddition = new X607_Position_Modification__c();
    primaryDeletion = new X607_Position_Modification__c();
    Position__c posAdd = new Position__c();
    Position__c posDel = new Position__c();
    
    Boolean errorMessage = false;
    Integer numAdditions = (numberOfpositions_5d == '') ? 0 : Integer.valueOf(numberOfpositions_5d);
    Integer numDeletions = (numberOfpositions_8d == '') ? 0 : Integer.valueOf(numberOfpositions_8d);
    
    // Make sure that if a date is inserted the remaining fields are filled
    if((effectiveDate_4a != '' || expirationDate_4b != '') && (departmentAndOrganizationalUnit_5a == '' || codeNo_5a == '' ||
                                   reportingUnitOrFunction_5b == '' || codeNo_5b == '' ||
                                   classTitle_5c == '' || codeNo_5c == '' ||
                                   numberOfpositions_5d == '' || positionSerialNumbers_5e == '')) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Finish filling out the fields for the addition roster');
      ApexPages.addMessage(myMsg);
      errorMessage = true;
    }
    if((effectiveDate_7a != '' || disencumberTo_7b != '') && (departmentAndOrganizationalUnit_8a == '' || codeNo_8a == '' ||
                                   reportingUnitOrFunction_8b == '' || codeNo_8b == '' ||
                                   classTitle_8c == '' || codeNo_8c == '' ||
                                   numberOfpositions_8d == '' || positionSerialNumbers_8e == '')) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Finish filling out the fields for the deletion roster');
      ApexPages.addMessage(myMsg);
      errorMessage = true;
    }
    if(errorMessage) {
      return null;
    }
    
    // If all the dates are will formatted
    if(departmentAndOrganizationalUnit_5a != '') {
      WFD_effectiveDate_4a = dateWellFormatted(effectiveDate_4a);
      WFD_expirationDate_4b = dateWellFormatted(expirationDate_4b);
    }
    if(departmentAndOrganizationalUnit_8a != '') {
      WFD_effectiveDate_7a = dateWellFormatted(effectiveDate_7a);
      WFD_disencumberTo_7b = dateWellFormatted(disencumberTo_7b);
    }
    
    if(accountingOfficerDate != '') {
      WFD_accountingOfficerDate = dateWellFormatted(accountingOfficerDate);
    }
    if(contactDate_12 != '') {
      WFD_contactDate_12 = dateWellFormatted(contactDate_12);
    }
    
    if(!WFD_effectiveDate_4a || !WFD_expirationDate_4b || !WFD_effectiveDate_7a || !WFD_disencumberTo_7b || !WFD_accountingOfficerDate || !WFD_contactDate_12) {
      return null;
    }
    
    // If this is the edit page, get the existing Primary Addition and Deletion
    if(form607.X607_Position_Primary_Addition__c != null) {
      primaryAddition = [select Id, Position__c, X607__c from X607_Position_Modification__c where Id = :form607.X607_Position_Primary_Addition__c];
      // If the Position in the primary addition is not null, then only one position is being added
      if(primaryAddition.Position__c != null) {
        posAdd = [select BU__c, Id, Effective_Date__c, Department__c, Reporting_Unit__c, Class_Title_CodeNo__c, Serial_Number__c, PY__c, Time_Basis__c, Class_Title__c, Salary_Rate__c from Position__c where Id = :primaryAddition.Position__c];
      }
    }
    if(form607.X607_Position_Primary_Deletion__c != null) {
      primaryDeletion = [select Id, Position__c, X607__c from X607_Position_Modification__c where Id = :form607.X607_Position_Primary_Deletion__c];
      // If the Position in the primary deletion is not null, then only one position is being deleted
      if(primaryDeletion.Position__c != null) {
        posDel = [select Id, Effective_Date__c, Department__c, Reporting_Unit__c, Class_Title_CodeNo__c, Serial_Number__c, PY__c, Time_Basis__c, Class_Title__c, Salary_Rate__c from Position__c where Id = :primaryDeletion.Position__c];
      }
    }
    
    // Form 607 fields
    form607.Routing__c = routing;
    /*if(routeTo == 'true') {
      form607.Route_To__c = 'Controller\'s Division of Disbursements';
    }
    else {
      form607.Route_To__c = 'Other (specify)';
    }*/
    
    form607.Type__c = transactionType;
    form607.Fiscal_Year__c = fiscalYear;
    form607.Document_No__c = documentNo;
    form607.Comments__c = (standardDescription == '' || standardDescription == null) ? descriptionOfDuties : standardDescription;
    
    form607.Initials__c = initials;
    
    form607.Certification_Contact__c = contactPerson_12;
    form607.Certification_Phone_Number__c = phoneNumber_12;
    form607.Approved__C = approvedCheck;
    
    // Check to make sure the number of position fields have number values 
    // and if salary is various, the number of positions needs to be greater than 1
    if(departmentAndOrganizationalUnit_5a != '') {
      if(numberOfPositions_5d == '') {
        numPos5dError = 'Number of positions cannot be empty';
      }
      if(!numberOfPositions_5d.isNumeric()) {
        numPos5dError = 'Must be a number';
      }
      if(salary_6b == '') {
        salary6bError = 'Salary cannot be empty';
      }
      if(salary_6b.toLowerCase() == 'various' && Integer.valueOf(numberOfPositions_5d) <= 1) {
        numPos5dError = 'Number of positions must be greater than 1 for various salaries';
      }
    }
    if(departmentAndOrganizationalUnit_8a != '') {
      if(numberOfPositions_8d == '') {
        numPos8dError = 'Number of positions cannot be empty';
      }
      if(!numberOfPositions_8d.isNumeric()) {
        numPos8dError = 'Must be a number';
      }
      if(salary_9b == '') {
        salary9bError = 'Salary cannot be empty';
      }
      if(salary_9b.toLowerCase() == 'various' && Integer.valueOf(numberOfPositions_8d) <= 1) {
        numPos8dError = 'Number of positions must be greater than 1 for various salaries';
      }
    }
    
    if(numPos5dError != '' || numPos8dError != '' || salary6bError != '' || salary9bError != '') {
      return null;
    }
    
    upsert form607;
    
    primaryAddition.Type__c = 'Addition';
    // If more than one position is being added, store the roster information in the primary addition
    if(numAdditions > 1) {
      String[] dateParts = null;
      if(effectiveDate_4a != '') {
        dateParts = effectiveDate_4a.split('-');
        effectiveDate_4a = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
      }
      if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
        dateParts = expirationDate_4b.split('-');
        dateParts[0] = (dateParts[0].startsWith('0')) ? dateParts[0].substring(1) : dateParts[0];
        dateParts[1] = (dateParts[1].startsWith('0')) ? dateParts[1].substring(1) : dateParts[1];
        expirationDate_4b =  dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];
      }
      
      if(transactionType == 'Extension of Present') {// || transactionType == 'Reclassification') {
        system.debug('Reached Extension condition');
        String delPosName = codeNo_8a + '-' + codeNo_8b + '-' + codeNo_8c + '-' + positionSerialNumbers_8e;
        List<Position__c> findPosList = [Select p.X6_Month_Lapsed_Date__c, p.X607__c, p.Unit__c, p.Type__c, p.Time_Basis__c, p.Term_Type__c, p.SystemModstamp, p.Status__c, p.Status_DocNo__c, p.Serial_Number__c, p.Separation_Date__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Position_Number2__c, p.Part_Time_Fraction__c, p.PY__c, p.OwnerId, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.LastActivityDate, p.IsDeleted, p.IsActive__c, p.Id, p.Expiration_Date__c, p.Effective_Date__c, p.Division__c, p.Department__c, p.CreatedDate, p.CreatedById, p.Comments__c, p.Classification__c, p.ClassificationId__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p where IsActive__c = true and Name = :delPosName];
        if(findPosList.size() != 1) {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number(' + delPosName + ') does not exist');
          ApexPages.addMessage(myMsg);
          return resetDates();
        }
      }
      /*  primaryAddition.Effective_Date__c = findPosList.get(0).Effective_Date__c;
        primaryAddition.Expiration_Date__c = findPosList.get(0).Expiration_Date__c;
        system.debug(primaryAddition.Effective_Date__c);
        system.debug(primaryAddition.Expiration_Date__c);
      }
      else {
        primaryAddition.Effective_Date__c = (effectiveDate_4a != '') ? Date.valueOf(effectiveDate_4a) : null;
        primaryAddition.Expiration_Date__c = expirationDate_4b;
      }*/
      primaryAddition.Effective_Date__c = (effectiveDate_4a != '') ? Date.valueOf(effectiveDate_4a) : null;
      primaryAddition.Expiration_Date__c = expirationDate_4b;
      primaryAddition.Reporting_Unit__c = reportingUnitOrFunction_5b;
      primaryAddition.Reporting_Unit_Code__c = codeNo_5b;
      primaryAddition.Class_Title__c = classTitle_5c;
      primaryAddition.Class_Title_Code__c = codeNo_5c;
      primaryAddition.Number_of_Positions__c = Integer.valueOf(numberOfpositions_5d);
      primaryAddition.Time_Base__c = timeBasis_6a;
      primaryAddition.Salary_Rate__c = rate_6b;
      primaryAddition.Serial__c = positionSerialNumbers_5e;
      primaryAddition.Salary__c = salary_6b;
    }
    // Otherwise, if only one position is being added, fill out the temporary position with the information in the roster
    else {
      if(departmentAndOrganizationalUnit_5a != '') {
        String addPosName = codeNo_5a + '-' + codeNo_5b + '-' + codeNo_5c + '-' + positionSerialNumbers_5e;
        List<Position__c> findPosList = [Select p.X6_Month_Lapsed_Date__c, p.X607__c, p.Unit__c, p.Type__c, p.Time_Basis__c, p.Term_Type__c, p.SystemModstamp, p.Status__c, p.Status_DocNo__c, p.Serial_Number__c, p.Separation_Date__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Position_Number2__c, p.Part_Time_Fraction__c, p.PY__c, p.OwnerId, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.LastActivityDate, p.IsDeleted, p.IsActive__c, p.Id, p.Expiration_Date__c, p.Effective_Date__c, p.Division__c, p.Department__c, p.CreatedDate, p.CreatedById, p.Comments__c, p.Classification__c, p.ClassificationId__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p where IsActive__c = true and Name = :addPosName];
        if(findPosList.size() != 0 && posAdd.Id == null) {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number(' + addPosName + ') already exists');
          ApexPages.addMessage(myMsg);
          return resetDates();
        }
        
        if(transactionType == 'Extension of Present') {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Need more than one new position for extension');
          ApexPages.addMessage(myMsg);
          return resetDates();
        }
        
        /*if(transactionType == 'Reclassification') {
          String delPosName = codeNo_8a + '-' + codeNo_8b + '-' + codeNo_8c + '-' + positionSerialNumbers_8e;
          List<Position__c> tempPosList = [Select p.X6_Month_Lapsed_Date__c, p.X607__c, p.Unit__c, p.Type__c, p.Time_Basis__c, p.Term_Type__c, p.SystemModstamp, p.Status__c, p.Status_DocNo__c, p.Serial_Number__c, p.Separation_Date__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Position_Number2__c, p.Part_Time_Fraction__c, p.PY__c, p.OwnerId, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.LastActivityDate, p.IsDeleted, p.IsActive__c, p.Id, p.Expiration_Date__c, p.Effective_Date__c, p.Division__c, p.Department__c, p.CreatedDate, p.CreatedById, p.Comments__c, p.Classification__c, p.ClassificationId__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p where IsActive__c = true and Name = :delPosName];
          if(tempPosList.size() != 1) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number(' + delPosName + ') does not exist');
            ApexPages.addMessage(myMsg);
            return null;
          }
          posAdd.Effective_Date__c = tempPosList.get(0).Effective_Date__c;
          posAdd.Expiration_Date__c = tempPosList.get(0).Expiration_Date__c;
        }*/
        
        String[] dateParts = null;
        if(effectiveDate_4a != '') {
          dateParts = effectiveDate_4a.split('-');
          effectiveDate_4a = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
        }
        if(expirationDate_4b != '' && expirationDate_4b != 'PERM') {
          dateParts = expirationDate_4b.split('-');
          dateParts[0] = (dateParts[0].startsWith('0')) ? dateParts[0].substring(1) : dateParts[0];
          dateParts[1] = (dateParts[1].startsWith('0')) ? dateParts[1].substring(1) : dateParts[1];
          expirationDate_4b =  dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];
        }
        
        if(transactionType == 'Proposed New' || transactionType == 'Reclassification') {
          posAdd.Effective_Date__c = (effectiveDate_4a != '') ? Date.valueOf(effectiveDate_4a) : null;
          posAdd.Expiration_Date__c = expirationDate_4b;
          if(expirationDate_4b.toUpperCase() == 'PERM') {
            posAdd.Term_Type__c = 'Permanent';
          }
          else {
            posAdd.Term_Type__c = 'Limited';
          }
        }
        
        //5/13/2015 - Bao added IF block for 'Other' (13 lines)below:
                    if(transactionType == 'Other'){
                      posAdd.Effective_Date__c = (effectiveDate_4a != '') ? Date.valueOf(effectiveDate_4a) : null;
                      posAdd.Expiration_Date__c = expirationDate_4b;
                      if(expirationDate_4b.toUpperCase() == 'PERM') {
                          posAdd.Term_Type__c = 'Permanent';
                      }
                      else {
                          posAdd.Term_Type__c = 'Limited';
                          }
                        }
                //Bao Modification Ends
        
        primaryAddition.Effective_Date__c = (effectiveDate_4a != '') ? Date.valueOf(effectiveDate_4a) : null;
        primaryAddition.Expiration_Date__c = expirationDate_4b;
        
        posAdd.Organizational_Unit__c = departmentAndOrganizationalUnit_5a;
        
        posAdd.Department__c = '400';
        
        
        posAdd.Reporting_Unit__c = reportingUnitOrFunction_5b;
        posAdd.Reporting_Unit_CodeNo__c = codeNo_5b;
        
        posAdd.Class_Title__c = classTitle_5c;
        posAdd.BU__c = BU;
        posAdd.Class_Title_CodeNo__c = codeNo_5c;
        
        primaryAddition.Number_of_Positions__c = 1;
        posAdd.Serial_Number__c = positionSerialNumbers_5e;
        posAdd.Type__c = typeOfPosition_5f;
        
        posAdd.Time_Basis__c = timeBasis_6a;
        if(timeBasis_6a == 'Part-Time') {
          posAdd.Part_Time_Fraction__c = (partTimeFraction_6a != '') ? Double.valueOf(partTimeFraction_6a) : null;
        }
        posAdd.Salary_Rate__c = (salary_6b != '' && (salary_6b.ToLowerCase() != 'various')) ? Double.valueOf(salary_6b) : null;
        posAdd.Salary_Per__c = rate_6b;
      
        posAdd.X607__c = documentNo;
        posAdd.Name = posAdd.Department__c + '-' + posAdd.Reporting_Unit_CodeNo__c + '-' + posAdd.Class_Title_CodeNo__c + '-' + posAdd.Serial_Number__c;
        
        posAdd.IsActive__c = false;
        posAdd.Manual_Entry__c = false;
        posAdd.Status__c = 'Vacant';
        upsert posAdd;
      }
    }
    
    primaryDeletion.Type__c = 'Deletion';
    // If more than one position is being deleted, store the roster information in the primary deletion
    if(numDeletions > 1) {
      String[] dateParts = null;
      if(effectiveDate_7a != '') {
        dateParts = effectiveDate_7a.split('-');
        effectiveDate_7a = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
      }
      if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM') {
        dateParts = disencumberTo_7b.split('-');
        dateParts[0] = (dateParts[0].startsWith('0')) ? dateParts[0].substring(1) : dateParts[0];
        dateParts[1] = (dateParts[1].startsWith('0')) ? dateParts[1].substring(1) : dateParts[1];
        disencumberTo_7b =  dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];
      }
      primaryDeletion.Effective_Date__c = (effectiveDate_7a != '') ? Date.valueOf(effectiveDate_7a) : null;
      primaryDeletion.Expiration_Date__c = disencumberTo_7b;
      primaryDeletion.Reporting_Unit__c = reportingUnitOrFunction_8b;
      primaryDeletion.Reporting_Unit_Code__c = codeNo_8b;
      primarydeletion.Class_Title__c = classTitle_8c;
      primaryDeletion.Class_Title_Code__c = codeNo_8c;
      primaryDeletion.Number_of_Positions__c = Integer.valueOf(numberOfpositions_8d);
      primaryDeletion.Time_Base__c = timeBasis_9a;
      primaryDeletion.Salary_Rate__c = rate_9b;
      primaryDeletion.Serial__c = positionSerialNumbers_8e;
      primaryDeletion.Salary__c = salary_9b;
    }
    // Otherwise, if only one position is being deleted, search for the position desired
    else {
      //posDel.Organizational_Unit__c = departmentAndOrganizationalUnit_8a;
      if(departmentAndOrganizationalUnit_8a != '') {
        String delPosName = codeNo_8a + '-' + codeNo_8b + '-' + codeNo_8c + '-' + positionSerialNumbers_8e;
        List<Position__c> findPosList = [Select p.X6_Month_Lapsed_Date__c, p.X607__c, p.Unit__c, p.Type__c, p.Time_Basis__c, p.Term_Type__c, p.SystemModstamp, p.Status__c, p.Status_DocNo__c, p.Serial_Number__c, p.Separation_Date__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Position_Number2__c, p.Part_Time_Fraction__c, p.PY__c, p.OwnerId, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.LastActivityDate, p.IsDeleted, p.IsActive__c, p.Id, p.Expiration_Date__c, p.Effective_Date__c, p.Division__c, p.Department__c, p.CreatedDate, p.CreatedById, p.Comments__c, p.Classification__c, p.ClassificationId__c, p.Class_Title__c, p.Class_Title_CodeNo__c From Position__c p where IsActive__c = true and Name = :delPosName];
        if(findPosList.size() != 1) {
          system.debug('Reached condition');
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number(' + delPosName + ') does not exist');
          ApexPages.addMessage(myMsg);
          return resetDates();
        }
        
        posDel = findPosList.get(0);
        
        String[] dateParts = null;
        if(effectiveDate_7a != '') {
          dateParts = effectiveDate_7a.split('-');
          effectiveDate_7a = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
        }
        if(disencumberTo_7b != '' && disencumberTo_7b != 'PERM') {
          dateParts = disencumberTo_7b.split('-');
          dateParts[0] = (dateParts[0].startsWith('0')) ? dateParts[0].substring(1) : dateParts[0];
          dateParts[1] = (dateParts[1].startsWith('0')) ? dateParts[1].substring(1) : dateParts[1];
          disencumberTo_7b =  dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];
        }
        
        primaryDeletion.Effective_Date__c = (effectiveDate_7a != '') ? Date.valueOf(effectiveDate_7a) : null;
        primaryDeletion.Expiration_Date__c = disencumberTo_7b;
        primaryDeletion.Number_of_Positions__c = 1;
        //upsert posDel;
      }
    }
    
    //List<Position__c> newPosList = new List<Position__c>();
    List<X607_Position_Modification__c> newPosModList = new List<X607_Position_Modification__c>();
    
    /*if(departmentAndOrganizationalUnit_5a != '' && codeNo_5c.ToUppercase() != 'VARIOUS') {
      posAdd.Name = posAdd.Department__c + '-' + posAdd.Reporting_Unit_CodeNo__c + '-' + posAdd.Class_Title_CodeNo__c + '-' + posAdd.Position_Serial_Numbers__c;
      newPosList.add(posAdd);
    }
    if(departmentAndOrganizationalUnit_8a != '' && codeNo_8c.ToUppercase() == 'VARIOUS') {
      posDel.Name = posDel.Department__c + '-' + posDel.Reporting_Unit_CodeNo__c + '-' + posDel.Class_Title_CodeNo__c + '-' + posDel.Position_Serial_Numbers__c;
      newPosList.add(posDel);
    }
    upsert newPosList;*/
    
    String[] dateParts = null;
    if(contactDate_12 != '') {
      dateParts = contactDate_12.split('-');
      contactDate_12 = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
      form607.Certification_Date__c = Date.valueOf(contactDate_12);
    }
    if(accountingOfficerDate != '') {
      dateParts = accountingOfficerDate.split('-');
      accountingOfficerDate = dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
      form607.Date_Submitted_to_Budget__c = Date.valueOf(accountingOfficerDate);
    }
    
    if(departmentAndOrganizationalUnit_5a != '') {
      primaryAddition.Position__c = (numAdditions == 1) ? posAdd.Id : null;
      /*if(codeNo_5c.ToUppercase() != 'VARIOUS' && form607.Form_1__c != null) {
        Form_1__c originatingForm1 = [select Id, SEC2_Position__c from Form_1__c where Id = :form607.Form_1__c];
        originatingForm1.SEC2_Position__c = posAdd.Id;
        update originatingForm1;
      }*/
      primaryAddition.Approval_Status__c = 'Pending';
      if(primaryAddition.X607__c == null) {
        primaryAddition.X607__c = form607.Id;
      }
      newPosModList.add(primaryAddition);
    }
    if(departmentAndOrganizationalUnit_8a != '') {
      primaryDeletion.Position__c = (numDeletions == 1) ? posDel.Id : null;
      primaryDeletion.Approval_Status__c = 'Pending';
      if(primaryDeletion.X607__c == null) {
        primaryDeletion.X607__c = form607.Id;
      }
      newPosModList.add(primaryDeletion);
    }
    upsert newPosModList;
    
    if(departmentAndOrganizationalUnit_5a != '') {
      form607.X607_Position_Primary_Addition__c = primaryAddition.Id;
    }
    if(departmentAndOrganizationalUnit_8a != '') {
      form607.X607_Position_Primary_Deletion__c = primaryDeletion.Id;
    }

    update form607;
    
    // If more than one position is being added and or deleted, navigate the user to the add position modifications page
    if( numAdditions > 1 || numDeletions > 1) {
      PageReference p = page.addPositionModifications;
      p.getParameters().put('id', form607.Id);
      p.getParameters().put('posmod', 'true');
      p.setRedirect(true);
      return p;
    }
    else {
      return new PageReference('/' + form607.Id);
    }
  }
  
  /*public PageReference saveFormAndAddModifications() {
    saveForm();
    PageReference p = page.addPositionModifications;
    p.getParameters().put('id', form607.Id);
    p.getParameters().put('posmod', 'true');
    p.setRedirect(true);
    return p;
  }*/
  
  public PageReference viewAsPDF() {
    renderMode = 'PDF';
    return null;
  }
  
  private String processDescription(String d) {
    if(d != null) {
      Integer linecount = 1 + d.countMatches('\n');
      linecount += (Integer) d.length()/140;
      d = d.replace('\n', '<br/>');
      while(linecount < 9) {
        d += '<br/>';
        linecount++;
      }
      return d;
    }
    else {
      return '<br/><br/><br/><br/><br/><br/><br/><br/>';
    }
  }
  
  private String processDescriptionForEdit(String d) {
    return (d != null) ? d.replace('<br/>','\n') : '';
  }
  
  public PageReference fillDepartment5() {
    if(codeNo_5a == '400') {
      departmentAndOrganizationalUnit_5a = 'INDUSTRIAL RELATIONS';
    }
    else {
      departmentAndOrganizationalUnit_5a = '';
    }
    return null;
  }
  
  public PageReference fillDepartment8() {
    if(codeNo_8a == '400') {
      departmentAndOrganizationalUnit_8a = 'INDUSTRIAL RELATIONS';
    }
    else {
      departmentAndOrganizationalUnit_8a = '';
    }
    return null;
  }
  
  public PageReference searchUnit5() {
    if(codeNo_5b.length() >= 3) {
      if(codeNo_5b.length() == 3 && codeNo_5b.isNumeric()) {
        List<Unit__c> tempList = [select Id, Unit_Name__c from Unit__c where Name = :codeNo_5b];
        Unit__c temp = null;
        if(tempList.size() == 1) {
          temp = tempList.get(0);
        }
        if(temp != null){// && temp.Id != null) {
          reportingUnitOrFunction_5b = temp.Unit_Name__c;
        }
      } else if(codeNo_5b.length() == 7 && (codeNo_5b.toUpperCase() == 'VARIOUS')) {
        codeNo_5b = codeNo_5b.toLowerCase();
        reportingUnitOrFunction_5b = 'VARIOUS';
      } else {
        reportingUnitOrFunction_5b = '';
      }
    }
    else {
      reportingUnitOrFunction_5b = '';
    }
    return null;
  }
  
  public PageReference searchUnit8() {
    if(codeNo_8b.length() >= 3) {
      if(codeNo_8b.length() == 3 && codeNo_8b.isNumeric()) {
        List<Unit__c> tempList = [select Id, Unit_Name__c from Unit__c where Name = :codeNo_8b];
        Unit__c temp = null;
        if(tempList.size() == 1) {
          temp = tempList.get(0);
        }
        if(temp != null){// && temp.Id != null) {
          reportingUnitOrFunction_8b = temp.Unit_Name__c;
        }
      } else if(codeNo_8b.length() == 7 && (codeNo_8b.toUpperCase() == 'VARIOUS')) {
        codeNo_8b = codeNo_8b.toLowerCase();
        reportingUnitOrFunction_8b = 'VARIOUS';
      } else {
        reportingUnitOrFunction_8b = '';
      }
    }
    else {
      reportingUnitOrFunction_8b = '';
    }
    return null;
  }
  
  public PageReference searchClassification5() {
    if(codeNo_5c.length() >= 4) {
      if(codeNo_5c.length() == 4 && codeNo_5c.isNumeric()) {
        List<Classification__c> tempList = [select Bargaining_Unit__c, Id, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :codeNo_5c order by Classification_Name__c limit 1];
        Classification__c temp = null;
        if(tempList.size() == 1) {
          temp = tempList.get(0);
        }
        if(temp != null){// && temp.Id != null) {
          classTitle_5c = temp.Classification_Name__c;
          BU = temp.Bargaining_Unit__c;
          salary_6b = String.valueOf(temp.Minimum_Salary_Rate__c);
          rate_6b = temp.Salary_Per__c;
          typeOfPosition_5f = temp.Type_of_Position__c.substring(0,1);
        }
      } else if(codeNo_5c.length() == 7 && (codeNo_5c.toUpperCase() == 'VARIOUS')) {
        codeNo_5c = codeNo_5c.toLowerCase();
        classTitle_5c = 'VARIOUS';
        salary_6b = 'various';
        rate_6b = 'Month';
        typeOfPosition_5f = '1';
        positionSerialNumbers_5e = 'various';
      } else {
        classTitle_5c = '';
        salary_6b = '';
        rate_6b = '';
        typeOfPosition_5f = '';
        positionSerialNumbers_5e = '';
      }
    }
    else {
      classTitle_5c = '';
      salary_6b = '';
      rate_6b = '';
      typeOfPosition_5f = '';
      positionSerialNumbers_5e = '';
    }
    return null;
  }
  
  public PageReference searchClassification8() {
    if(codeNo_8c.length() >= 4) {
      if(codeNo_8c.length() == 4 && codeNo_8c.isNumeric()) {
        List<Classification__c> tempList = [select Id, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :codeNo_8c order by Classification_Name__c limit 1];
        Classification__c temp = null;
        if(tempList.size() == 1) {
          temp = tempList.get(0);
        }
        
        if(temp != null && temp.Id != null) {
          classTitle_8c = temp.Classification_Name__c;
          salary_9b = String.valueOf(temp.Minimum_Salary_Rate__c);
          rate_9b = temp.Salary_Per__c;
          typeOfPosition_8f = temp.Type_of_Position__c.substring(0,1);
        }
      } else if(codeNo_8c.length() == 7 && (codeNo_8c.toUpperCase() == 'VARIOUS')) {
        codeNo_8c = codeNo_8c.toLowerCase();
        classTitle_8c = 'VARIOUS';
        salary_9b = 'various';
        rate_9b = 'Month';
        typeOfPosition_8f = '1';
        positionSerialNumbers_8e = 'various';
      } else {
        classTitle_8c = '';
        salary_9b = '';
        rate_9b = '';
        typeOfPosition_8f = '';
        positionSerialNumbers_8e = '';
      }
    }
    else {
      classTitle_8c = '';
      salary_9b = '';
      rate_9b = '';
      typeOfPosition_8f = '';
      positionSerialNumbers_8e = '';
    }
    return null;
  }
  
  public PageReference searchClassificationAddPosMod() {
    if(newAddPos.Class_Title_CodeNo__c != null && newAddPos.Class_Title_CodeNo__c.length() == 4) {
      List<Classification__c> tempList = [select Id, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :newAddPos.Class_Title_CodeNo__c order by Classification_Name__c limit 1];
      Classification__c temp = null;
      if(tempList.size() == 1) {
        temp = tempList.get(0);
      }
      
      if(temp != null && temp.Id != null) {
        newAddPos.Class_Title__c = temp.Classification_Name__c;
        newAddPos.Salary_Rate__c = temp.Minimum_Salary_Rate__c;
        newAddPos.Type__c = temp.Type_of_Position__c.substring(0,1);
      }
    }
    else {
      newAddPos.Class_Title__c = '';
      newAddPos.Salary_Rate__c = null;
      newAddPos.Type__c = '';
    }
    return null;
  }
  
  public PageReference searchClassificationDelPosMod() {
    if(newDelPos.Class_Title_CodeNo__c != null && newDelPos.Class_Title_CodeNo__c.length() == 4) {
      List<Classification__c> tempList = [select Id, Classification_Name__c, Minimum_Salary_Rate__c, Salary_Per__c, Type_of_Position__c from Classification__c where Name = :newDelPos.Class_Title_CodeNo__c order by Classification_Name__c limit 1];
      Classification__c temp = null;
      if(tempList.size() == 1) {
        temp = tempList.get(0);
      }      
      if(temp != null && temp.Id != null) {
        newDelPos.Class_Title__c = temp.Classification_Name__c;
        newDelPos.Salary_Rate__c = temp.Minimum_Salary_Rate__c;
        newDelPos.Type__c = temp.Type_of_Position__c.substring(0,1);
      }
    }
    else {
      newDelPos.Class_Title__c = '';
      newDelPos.Salary_Rate__c = null;
      newDelPos.Type__c = '';
    }
    return null;
  }
  
  public Boolean dateWellFormatted(String d) {
    if(d.ToUppercase() == 'PERM') {
      return true;
    }
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
      return true;
    }
    return false;
  }

////////////////////////////////////////////////////////////////////////////
////      ADD POSITION MODIFICATION FUNCTIONS            ////
////////////////////////////////////////////////////////////////////////////
  public PageReference cancel() {
    return new PageReference('/' + form607.Id);
  }
  
  private Boolean alreadyInAdditionList(String dept, String unit, String cls, String ser) {
    for(PosModWrapper pmw : attachedAdditions) {
      if(pmw.pos.Department__c == dept && 
         pmw.pos.Reporting_Unit_CodeNo__c == unit && 
         pmw.pos.Class_Title_CodeNo__c == cls && 
         pmw.pos.Serial_Number__c == ser) {
        return true;
      }
    }
    return false;
  }
  
  private Boolean alreadyInDeletionList(String dept, String unit, String cls, String ser) {
    for(PosModWrapper pmw : attachedDeletions) {
      if(pmw.pos.Department__c == dept && 
         pmw.pos.Reporting_Unit_CodeNo__c == unit && 
         pmw.pos.Class_Title_CodeNo__c == cls && 
         pmw.pos.Serial_Number__c == ser) {
        return true;
      }
    }
    return false;
  }
  
  public PageReference savePositionModifications() {
    List<Position__c> newPosList = new List<Position__c>();
    List<X607_Position_Modification__c> newPosModList = new List<X607_Position_Modification__c>();
    if(form607.X607_Position_Primary_Addition__c != null) {
      if(form607.X607_Position_Primary_Addition__r.Number_of_Positions__c > 1 && form607.X607_Position_Primary_Addition__r.Number_of_Positions__c != attachedAdditions.size()) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected ' + String.valueOf(form607.X607_Position_Primary_Addition__r.Number_of_Positions__c) + ' additions. Current number of additions: ' + attachedAdditions.size());
        ApexPages.addMessage(myMsg);
        return null;
      }
      for(PosModWrapper pmw : attachedAdditions) {
        newPosList.add(pmw.pos);
      }
    }
    if(form607.X607_Position_Primary_Deletion__c != null) {
      if(form607.X607_Position_Primary_Deletion__r.Number_of_Positions__c > 1 && form607.X607_Position_Primary_Deletion__r.Number_of_Positions__c != attachedDeletions.size()) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected ' + String.valueOf(form607.X607_Position_Primary_Deletion__r.Number_of_Positions__c) + ' deletions. Current number of deletions: ' + attachedDeletions.size());
        ApexPages.addMessage(myMsg);
        return null;
      }
      for(PosModWrapper pmw : attachedDeletions) {
        newPosList.add(pmw.pos);
      }
    }
    upsert newPosList;
    
    if(form607.X607_Position_Primary_Addition__c != null) {
      for(PosModWrapper pmw : attachedAdditions) {
        pmw.posmod.Position__c = pmw.pos.Id;
        newPosModList.add(pmw.posmod);
      }
    }
    if(form607.X607_Position_Primary_Deletion__c != null) {
      for(PosModWrapper pmw : attachedDeletions) {
        pmw.posmod.Position__c = pmw.pos.Id;
        newPosModList.add(pmw.posmod);
      }
    }
    upsert newPosModList;
    return new PageReference('/' + form607.Id);
  }
  
  public PageReference addAddition() {
    newAddPos.X607__c = form607.Document_No__c;
    List<Position__c> tempPosList = [select p.Id
                     from Position__c p where p.IsActive__c = true and p.Department__c = :newAddPos.Department__c and p.Reporting_Unit_CodeNo__c = :newAddPos.Reporting_Unit_CodeNo__c and p.Class_Title_CodeNo__c = :newAddPos.Class_Title_CodeNo__c and p.Serial_Number__c = :newAddPos.Serial_Number__c];
    
    if(newAddPos.Class_Title_CodeNo__c == null || newAddPos.Class_Title_CodeNo__c == '' || newAddPos.Reporting_Unit_CodeNo__c == null || newAddPos.Reporting_Unit_CodeNo__c == '' || newAddPos.Serial_Number__c == null || newAddPos.Serial_Number__c == '') {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'All code number fields must be filled: RU, CC and SER');
      ApexPages.addMessage(myMsg);
      return null;
    }
    if(form607.X607_Position_Primary_Addition__r.Number_of_Positions__c > 1 && form607.X607_Position_Primary_Addition__r.Number_of_Positions__c == attachedAdditions.size()) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Expecting ' + String.valueOf(form607.X607_Position_Primary_Addition__r.Number_of_Positions__c) + ' additions. Cannot add anymore positions');
      ApexPages.addMessage(myMsg);
      return null;
    }
    if(tempPosList.size() != 0) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number (' + newAddPos.Department__c + '-' + newAddPos.Reporting_Unit_CodeNo__c + '-' + newAddPos.Class_Title_CodeNo__c + '-' + newAddPos.Serial_Number__c + ') already exists and is active');
      ApexPages.addMessage(myMsg);
      return null;
    }
    if(alreadyInAdditionList(newAddPos.Department__c, newAddPos.Reporting_Unit_CodeNo__c, newAddPos.Class_Title_CodeNo__c, newAddPos.Serial_Number__c)) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number (' + newAddPos.Department__c + '-' + newAddPos.Reporting_Unit_CodeNo__c + '-' + newAddPos.Class_Title_CodeNo__c + '-' + newAddPos.Serial_Number__c + ') is already in the additions list');
      ApexPages.addMessage(myMsg);
      return null;
    }
    
    // Getting the Reporting Unit in case it was various in the 607 form
    if(newAddPos.Reporting_Unit__c == '') {
      Unit__c tempUnit = [select Id, Unit_Name__c from Unit__c where Name = :newAddPos.Reporting_Unit_CodeNo__c];
      newAddPos.Reporting_Unit__c = tempUnit.Unit_Name__c;
    }
    
    X607_Position_Modification__c tempPosMod = new X607_Position_Modification__c();
    tempPosMod.X607__c = form607.Id;
    tempPosMod.Approval_Status__c = 'Pending';
    tempPosMod.Type__c = 'Addition';
    newAddPos.Name = newAddPos.Department__c + '-' + newAddPos.Reporting_Unit_CodeNo__c + '-' + newAddPos.Class_Title_CodeNo__c + '-' + newAddPos.Serial_Number__c;
    newAddPos.IsActive__c = false;
    newAddPos.Manual_Entry__c = false;
    newAddPos.Status__c = 'Vacant';
    PosModWrapper tempPMW = new PosModWrapper(tempPosMod, newAddPos, globalIndex);
    attachedAdditions.add(tempPMW);
    globalIndex++;
    newAddPos = new Position__c();
    
    if(form607.X607_Position_Primary_Addition__c != null) {
      // Visible addition fields
      newAddPos.Department__c = '400';
      newAddPos.Reporting_Unit_CodeNo__c = (form607.X607_Position_Primary_Addition__r.Reporting_Unit_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Reporting_Unit_Code__c : '';
      newAddPos.Class_Title_CodeNo__c = (form607.X607_Position_Primary_Addition__r.Class_Title_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Class_Title_Code__c : '';
      newAddPos.Type__c = '1';
      newAddPos.Time_Basis__c = form607.X607_Position_Primary_Addition__r.Time_Base__c;
      newAddPos.Salary_Per__c = form607.X607_Position_Primary_Addition__r.Salary_Rate__c;
      newAddPos.Serial_Number__c = (form607.X607_Position_Primary_Addition__r.Serial__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Serial__c : '';
      newAddPos.Salary_Rate__c = (form607.X607_Position_Primary_Addition__r.Salary__c.toLowerCase() != 'various') ? Double.valueOf(form607.X607_Position_Primary_Addition__r.Salary__c) : null;
      
      // Other addition fields
      if(form607.Type__c == 'Proposed New' || form607.Type__c == 'Extension of Present' || form607.Type__c == 'Reclassification') {
        newAddPos.Effective_Date__c = form607.X607_Position_Primary_Addition__r.Effective_Date__c;
        newAddPos.Expiration_Date__c = form607.X607_Position_Primary_Addition__r.Expiration_Date__c;
        if(newAddPos.Expiration_Date__c.toUpperCase() == 'PERM') {
          newAddPos.Term_Type__c = 'Permanent';
        }
        else {
          newAddPos.Term_Type__c = 'Limited';
        }
      }
      newAddPos.Organizational_Unit__c = 'INDUSTRIAL RELATIONS';
      newAddPos.Reporting_Unit__c = (form607.X607_Position_Primary_Addition__r.Reporting_Unit_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Reporting_Unit__c : '';
      newAddPos.Class_Title__c = (form607.X607_Position_Primary_Addition__r.Class_Title_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Addition__r.Class_Title__c : '';
    }
    return null;
  }
  
  public PageReference addDeletion() {
    // Search for the position with the given code numbers
    List<Position__c> tempPosList = [select p.X6_Month_Lapsed_Date__c, p.X607__c, p.Unit__c, p.Type__c, p.Time_Basis__c, p.Term_Type__c, p.SystemModstamp, p.Status__c, p.Status_DocNo__c, p.Serial_Number__c, p.Separation_Date__c, p.Salary_Rate__c, p.Salary_Per__c, p.Reporting_Unit__c, p.Reporting_Unit_CodeNo__c, p.Position_Number2__c, p.Part_Time_Fraction__c, p.PY__c, p.OwnerId, p.Organizational_Unit__c, p.Number_of_Positions__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.LastActivityDate, p.IsDeleted, p.Id, p.Expiration_Date__c, p.Effective_Date__c, p.Division__c, p.Department__c, p.CreatedDate, p.CreatedById, p.Comments__c, p.Classification__c, p.ClassificationId__c, p.Class_Title__c, p.Class_Title_CodeNo__c
                     From Position__c p where p.IsActive__c = true and p.Department__c = :newDelPos.Department__c and p.Reporting_Unit_CodeNo__c = :newDelPos.Reporting_Unit_CodeNo__c and p.Class_Title_CodeNo__c = :newDelPos.Class_Title_CodeNo__c and p.Serial_Number__c = :newDelPos.Serial_Number__c];
    
    if(form607.X607_Position_Primary_Deletion__r.Number_of_Positions__c > 1 && form607.X607_Position_Primary_Deletion__r.Number_of_Positions__c <= attachedDeletions.size()) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Expecting ' + String.valueOf(form607.X607_Position_Primary_Deletion__r.Number_of_Positions__c) + ' deletions. Cannot add anymore positions');
      ApexPages.addMessage(myMsg);
      return null;
    }
    if(alreadyInDeletionList(newDelPos.Department__c, newDelPos.Reporting_Unit_CodeNo__c, newDelPos.Class_Title_CodeNo__c, newDelPos.Serial_Number__c)) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number (' + newDelPos.Department__c + '-' + newDelPos.Reporting_Unit_CodeNo__c + '-' + newDelPos.Class_Title_CodeNo__c + '-' + newDelPos.Serial_Number__c + ') is already in the deletions list');
      ApexPages.addMessage(myMsg);
      return null;
    }
    if(newDelPos.Class_Title_CodeNo__c == null || newDelPos.Class_Title_CodeNo__c == '' || newDelPos.Reporting_Unit_CodeNo__c == null || newDelPos.Reporting_Unit_CodeNo__c == '' || newDelPos.Serial_Number__c == null || newDelPos.Serial_Number__c == '') {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'All code number fields must be filled: RU, CC and SER');
      ApexPages.addMessage(myMsg);
      return null;
    }
    if(tempPosList.size() == 0) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Position with number (' + newDelPos.Department__c + '-' + newDelPos.Reporting_Unit_CodeNo__c + '-' + newDelPos.Class_Title_CodeNo__c + '-' + newDelPos.Serial_Number__c + ') not found or is no longer active');
      ApexPages.addMessage(myMsg);
      return null;
    }
    
    newDelPos = tempPosList.get(0);
    //newDelPos.Status__c = form607.X607_Position_Primary_Deletion__r.Position__r.Status__c;
    
    //newDelPos.X607__c = form607.Document_No__c;
    X607_Position_Modification__c tempPosMod = new X607_Position_Modification__c();
    tempPosMod.X607__c = form607.Id;
    tempPosMod.Approval_Status__c = 'Pending';
    tempPosMod.Type__c = 'Deletion';
    
    PosModWrapper tempPMW = new PosModWrapper(tempPosMod, newDelPos, globalIndex);
    attachedDeletions.add(tempPMW);
    globalIndex++;
    newDelPos = new Position__c();
    
    if(form607.X607_Position_Primary_Deletion__c != null) {
      // Visible deletion fields
      newDelPos.Department__c = '400';
      newDelPos.Reporting_Unit_CodeNo__c = (form607.X607_Position_Primary_Deletion__r.Reporting_Unit_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Deletion__r.Reporting_Unit_Code__c : '';
      newDelPos.Class_Title_CodeNo__c = (form607.X607_Position_Primary_Deletion__r.Class_Title_Code__c.toLowerCase() != 'various') ? form607.X607_Position_Primary_Deletion__r.Class_Title_Code__c : '';
      //newDelPos.Type__c = '1';
      //newDelPos.Time_Basis__c = form607.X607_Position_Primary_Deletion__r.Time_Base__c;
      //newDelPos.Effective_Date__c = form607.X607_Position_Primary_Deletion__r.Effective_Date__c;
      //newDelPos.Expiration_Date__c = form607.X607_Position_Primary_Deletion__r.Expiration_Date__c;
    }
    return null;
  }
  
  public PageReference deleteAddition() {
    for(Integer i = 0; i < attachedAdditions.size(); i++) {
      if(attachedAdditions[i].index == deletedAdditionIndex) {
        if(attachedAdditions[i].pos.Id != null) {
          delete attachedAdditions[i].pos;
        }
        if(attachedAdditions[i].posmod.Id != null) {
          delete attachedAdditions[i].posmod;
        }
        attachedAdditions.remove(i);
        break;
      }
    }
    return null;
  }
  
  public PageReference deleteDeletion() {
    for(Integer i = 0; i < attachedDeletions.size(); i++) {
      if(attachedDeletions[i].index == deletedDeletionIndex) {
        /*if(attachedDeletions[i].pos.Id != null) {
          delete attachedDeletions[i].pos;
        }
        if(attachedDeletions[i].posmod.Id != null) {
          delete attachedDeletions[i].posmod;
        }*/
        attachedDeletions.remove(i);
        break;
      }
    }
    return null;
  }
  
////////////////////////////////////////////////////////////////
////      VIEW PAGE BUTTON FUNCTIONS          ////
////////////////////////////////////////////////////////////////
  public PageReference deleteForm607() {
    PageReference p = null;
    if(form607.Id != null) {
      delete form607;
      p = new PageReference('/a04/o');
    }
    return p;
  }
  
  public PageReference submitForApproval() {
    if(form607.Id != null) {
      // Check if this form has already been submitted for approval
      List<ProcessInstance> pi = [SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectId = :form607.Id];
      if(pi.size() > 0) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This form has already been submitted for approval');
        ApexPages.addMessage(myMsg);
        return null;
      }
      
      Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
      req.setObjectId(form607.Id);
      Approval.ProcessResult result = Approval.process(req);
      
      if(result.isSuccess()) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Form 607 successfully submitted for approval');
        ApexPages.addMessage(myMsg);
        
        pi = [SELECT TargetObjectId, Status FROM ProcessInstance WHERE TargetObjectId = :form607.Id];
        if(pi.size() == 1) {
          approvalStatus = pi.get(0).Status;
        }
      }
      else {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in submitting for approval: ' + result.getInstanceStatus());
        ApexPages.addMessage(myMsg);
      }
    }
    return null;
  }
  
  public PageReference addPositionModifications() {
    PageReference p = null;
    if(form607.Id != null) {
      p = Page.addPositionModifications;
      p.getParameters().put('id',form607.Id);
      p.getParameters().put('posmod','true');
      p.setRedirect(true);
    }
    return p;
  }
  
  /*public PageReference printPDF() {
    PageReference p = null;
    pdfURL = '';
    if(form607.Id != null) {
      p = Page.form607;
      p.getParameters().put('pdf','true');
      p.getParameters().put('id',form607.Id);
      p.setRedirect(true);
      
      //pdfURL = '/form607?id=' + form607.Id + '&pdf=true';
      pdfURL = p.getURL();
    }
    system.debug(pdfURL);
    return null;
  }*/
  
  public PageReference viewAttachment() {
    PageReference p = null;
    if(form607.Id != null) {
      p = Page.positionModificationAttachment;
      p.getParameters().put('id',form607.Id);
      p.getParameters().put('posmod','true');
      p.getParameters().put('pdf','true');
      p.setRedirect(true);
    }
    return p;
  }
  
  public PageReference detailPage() {
    PageReference p = null;
    if(form607.Id != null) {
      p = new PageReference('/' + form607.Id + '?nooverride=1');
    }
    return p;
  }
}