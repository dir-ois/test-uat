global class RegistrationEWPPDFController {
    
    private String registrationId { get; set; }
    public List<WrapRegistrationAccounts> permitInfo { get; set; }
    public Boolean checkBox { get; set; }
    
    public RegistrationEWPPDFController() {
        registrationId = ApexPages.CurrentPage().getParameters().get('Id');
        renderingService = ApexPages.CurrentPage().getParameters().get('renderingService');
        renderedFileName = ApexPages.CurrentPage().getParameters().get('renderedFileName');
        
        permitInfo = getPermitInfo(registrationId);
        
    }
    
    // public Registration_Account__c getLicense(Id regId) {
    //license = new Registration_Account__c();
    //license.Id = regId;
    //license.First_Name__c = 'Bao';
    
    //license = getPermitInfo(registrationId);
    //return license;
    // }
    
    public List<WrapRegistrationAccounts> getPermitInfo(Id pRegId){
        
        List<Registration_Account__c> regAccounts = new List<Registration_Account__c>();
        List<WrapRegistrationAccounts> wrapRALists = new List<WrapRegistrationAccounts>();
        
        String query = 'SELECT'
            + ' Id'
            + ' , First_Name__c'
            + ' , Middle_Name__c'
            + ' , Last_Name__c'
            + ' , Stage_Name__c'
            + ' , Residential_Street__c'
            + ' , Residential_Address_Line_2__c'
            + ' , Residential_City__c'
            + ' , Residential_State__c'
            + ' , Residential_Zip_Code__c'
            + ' , Residential_Phone__c'
            + ' , School_Name__c'
            + ' , Grade__c'
            + ' , Birth_Date__c'
            + ' , Height_ft__c'
            + ' , Height_in__c'
            + ' , Weight_In_Pounds__c'
            + ' , Natural_Hair_Color__c' 
            + ' , Natural_Eye_Color__c'
            + ' , Gender__c'
            + ' , RecordType.DeveloperName'
            + ' FROM Registration_Account__c'
            + ' WHERE Registration__c  = ' + '\'' + pRegId + '\'';
           // + ' AND RecordType.DeveloperName= \'Individual_Permit\'';
        
        
        query += ' ORDER BY Name DESC';
        System.debug('Query=======>'+query);
//        if(!Test.isRunningTest()){
            regAccounts = Database.query(query);
//        }
        
        String minors_First_Name;
        String minors_Middle_Name;
        String minors_Last_Name;
        String minors_Full_Name;
        String minors_Stage_Name;
        String minors_Street;
        String minors_Street2;
        String minors_Address;
        String minors_City;        
        String minors_State;
        String minors_Zip;
        String minors_Home_Phone;
        String minors_School;
        String minors_Grade;
        Date minors_Birth_Date;
        String minors_Height;
        String minors_Weight;
        String minors_Hair_Color;
        String minors_Eye_Color;
        String minors_Gender;
        String parents_Full_Name;
        String parents_Phone;
        
        for(Registration_Account__c eachRA : regAccounts){
            if(eachRA.RecordType.DeveloperName == 'Parent_Guardian'){
                parents_Full_Name = eachRA.First_Name__c == null ? '' : eachRA.First_Name__c + ' ';
                parents_Full_Name += eachRA.Middle_Name__c == null ? '' : eachRA.Middle_Name__c + ' ';
                parents_Full_Name += eachRA.Last_Name__c == null ? '' : eachRA.Last_Name__c;
                
                parents_Phone = eachRA.Residential_Phone__c;
            }
            if(eachRA.RecordType.DeveloperName == 'Individual_Permit'){
                minors_First_Name = eachRA.First_Name__c == null ? '' : eachRA.First_Name__c;
                minors_Middle_Name = eachRA.Middle_Name__c == null ? '' : eachRA.Middle_Name__c;
                minors_Last_Name = eachRA.Last_Name__c == null ? '' : eachRA.Last_Name__c;
                minors_Full_Name = minors_First_Name + ' ' + minors_Middle_Name + ' ' + minors_Last_Name;
                minors_Stage_Name = eachRA.Stage_Name__c == null ? '' : eachRA.Stage_Name__c ;
                minors_Street = eachRA.Residential_Street__c == null ? '' : eachRA.Residential_Street__c;
                minors_Street2 = eachRA.Residential_Address_Line_2__c == null ? '' : eachRA.Residential_Address_Line_2__c;
                minors_Address = minors_Street + ' ' + minors_Street2;
                minors_City = eachRA.Residential_City__c == null ? '' : eachRA.Residential_City__c;     
                minors_State = eachRA.Residential_State__c == null ? '' : eachRA.Residential_State__c;
                minors_Zip = eachRA.Residential_Zip_Code__c == null ? '' : eachRA.Residential_Zip_Code__c;
                minors_Home_Phone = eachRA.Residential_Phone__c == null ? '' : eachRA.Residential_Phone__c;
                minors_School = eachRA.School_Name__c == null ? '' : eachRA.School_Name__c;
                minors_Grade = eachRA.Grade__c == null ? '' : eachRA.Grade__c;
                minors_Birth_Date = eachRA.Birth_Date__c;
                minors_Height = eachRA.Height_ft__c + '\' ' +  eachRA.Height_in__c +  '\'\'';
                minors_Weight = eachRA.Weight_In_Pounds__c + ' lbs';
                minors_Hair_Color = eachRA.Natural_Hair_Color__c == null ? '' : eachRA.Natural_Hair_Color__c;
                minors_Eye_Color = eachRA.Natural_Eye_Color__c == null ? '' : eachRA.Natural_Eye_Color__c;
                minors_Gender = eachRA.Gender__c == null ? '' : eachRA.Gender__c;
            }
            }
            wrapRALists.add(new WrapRegistrationAccounts(minors_First_Name
                                                         , minors_Middle_Name
                                                         , minors_Last_Name
                                                         , minors_Stage_Name
                                                         , minors_Street
                                                         , minors_Street2 
                                                         , minors_Address
                                                         , minors_City
                                                         , minors_State
                                                         , minors_Zip
                                                         , minors_Home_Phone
                                                         , minors_School
                                                         , minors_Grade
                                                         , minors_Birth_Date
                                                         , minors_Height
                                                         , minors_Weight
                                                         , minors_Hair_Color
                                                         , minors_Eye_Color
                                                         , minors_Gender
                                                         , minors_Full_Name
                                                         , parents_Full_Name
                                                         , parents_Phone));
        
        return wrapRALists;
    }
    
    // Determines what kind of rendering to use for the page request
    public String renderingService { get; private set; }
    // Allow the page to set the PDF file name
    public String renderedFileName {
        get;
        set { renderedFileName = this.sanitizeFileName(value); }
    }
    
    // Rendered content MIME type, used to affect HTTP response
    public String renderedContentType {
        get {
            String renderedContentType = 'text/html'; // the default
            if( ! this.renderingAsHtml() ) {
                // Provides a MIME type for a PDF document
                renderedContentType = 'application/pdf';
                // Add a file name for the PDF file
                if( this.renderedFileName != null) {
                    // This is supposed to set the file name, but it doesn't work
                    renderedContentType += '#' + this.renderedFileName;
                    // This is a work-around to set the file name
                    ApexPages.currentPage().getHeaders().put(
                        'content-disposition', 'attachment; filename=' +
                        this.renderedFileName);
                }
            }
            return renderedContentType;
        }
    }
    
    // Are we rendering to HTML or PDF?
    public Boolean renderingAsHtml() {
        return ( (renderingService == null) ||
                ( ! renderingService.startsWith('PDF')) );
    }
    
    
    // Private helper -- basic, conservative santization
    private String sanitizeFileName(String unsafeName) {
        String allowedCharacters = '0-9a-zA-Z-_.';
        String sanitizedName =
            unsafeName.replaceAll('[^' + allowedCharacters + ']', '');
        // You might also want to check filename length,
        // that the filename ends in '.pdf', etc.
        return(sanitizedName);
    }
    
    global class WrapRegistrationAccounts{
        public String minorsFirstName {get;set;}
        public String minorsMiddleName {get;set;}
        public String minorsLastName {get;set;}
        public String minorsStageName {get;set;}
        public String minorsStreet {get;set;}
        public String minorsStreet2 {get;set;}
        public String minorsAddress {get;set;}
        public String minorsCity {get;set;}
        public String minorsState {get;set;}
        public String minorsZip {get;set;}
        public String minorsHomePhone {get;set;}
        public String minorsSchool {get;set;}
        public String minorsGrade {get;set;}
        public Date minorsBirthDate {get;set;}
        public String minorsHeight {get;set;}
        public String minorsWeight {get;set;}
        public String minorsHairColor {get;set;}
        public String minorsEyeColor {get;set;}
        public String minorsGender {get;set;}
        public String minorsFullName {get;set;}
        public String parentsFullName {get;set;}
        public String parents_Phone {get;set;}

        public WrapRegistrationAccounts(String sMinorsFirstName
                                        , String sMinorsMiddleName
                                        , String sMinorsLastName
                                        , String sMinorsStageName 
                                        , String sMinorsStreet
                                        , String sMinorsStreet2
                                        , String sMinorsAddress
                                        , String sMinorsCity 
                                        , String sMinorsState
                                        , String sMinorsZip 
                                        , String sMinorsHomePhone 
                                        , String sMinorsSchool 
                                        , String sMinorsGrade
                                        , Date sMinorsBirthDate 
                                        , String sMinorsHeight
                                        , String sMinorsWeight 
                                        , String sMinorsHairColor
                                        , String sMinorsEyeColor 
                                        , String sMinorsGender
                                        , String sMinorsFullName 
                                        , String sParentsFullName
                                        , String sParents_Phone)
        {
            minorsFirstName =  sMinorsFirstName == null ? '' : sMinorsFirstName;
            minorsMiddleName = sMinorsMiddleName == null ? '' : sMinorsMiddleName;    
            minorsLastName = sMinorsLastName == null ? '' : sMinorsLastName;    
            minorsStageName = sMinorsStageName == null ? '' : sMinorsStageName;     
            minorsStreet = sMinorsStreet == null ? '' : sMinorsStreet;
            minorsStreet2 = sMinorsStreet2 == null ? '' : sMinorsStreet2;
            minorsAddress = sMinorsAddress == null ? '' : sMinorsAddress;
            minorsCity = 	sMinorsCity == null ? '' : sMinorsCity;
            minorsState = 	sMinorsState == null ? '' : sMinorsState;
            minorsZip = 	sMinorsZip == null ? '' : sMinorsZip;
            minorsHomePhone = sMinorsHomePhone == null ? '' : sMinorsHomePhone;
            minorsSchool = 	sMinorsSchool == null ? '' : sMinorsSchool;
            minorsGrade = 	sMinorsGrade == null ? '' : sMinorsGrade;
            minorsBirthDate = sMinorsBirthDate;
            minorsHeight = 	sMinorsHeight == null ? '' : sMinorsHeight;
            minorsWeight = 	sMinorsWeight == null ? '' : sMinorsWeight;
            minorsHairColor = sMinorsHairColor == null ? '' : sMinorsHairColor;
            minorsEyeColor = sMinorsEyeColor == null ? '' : sMinorsEyeColor;
            minorsGender = 	sMinorsGender == null ? '' : sMinorsGender;
            minorsFullName = sMinorsFullName == null ? '' : sMinorsFullName;
            parentsFullName = sParentsFullName == null ? '' : sParentsFullName;
            parents_Phone = sParents_Phone == null ? '' : sParents_Phone;
        }
    }
}