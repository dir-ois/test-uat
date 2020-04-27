public class RegistrationDocDownloadController {
    public String registrationId { get; set; }
    public License_Registration__c license { get; set; }
    
    public RegistrationDocDownloadController() {
        registrationId = ApexPages.CurrentPage().getParameters().get('Id');
        
        
        getLicense(registrationId);
    }
    
    public License_Registration__c getLicense(Id regId) {
        license = new License_Registration__c();
        license.Id = regId;

        return license;
    }
    
    public PageReference openSchoolInfoToPdf() {
        PageReference schoolPage = new PageReference('/apex/RegistrationEWPSchoolPDF');
        schoolPage.setRedirect(true);
        schoolPage.getParameters().put('Id', registrationId);
        schoolPage.getParameters().put('renderingService', 'PDF'); // renderingService, html = '' (empty string), pdf = 'PDF'
        schoolPage.getParameters().put('renderedFileName', 'SchoolInformation.pdf');
        return schoolPage;
    }
    
        public PageReference openMedicalInfoToPdf() {
        PageReference schoolPage = new PageReference('/apex/RegistrationEWPMedicalPDF');
        schoolPage.setRedirect(true);
        schoolPage.getParameters().put('Id', registrationId);
        schoolPage.getParameters().put('renderingService', 'PDF');
        schoolPage.getParameters().put('saveToPdf', 'saveToPdf');
        schoolPage.getParameters().put('renderedFileName', 'MedicalInformation.pdf');
        return schoolPage;
    }

    
}