/********************************************************************************************************
Name:  CommunityRenewals.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  1/15/2018
Modified by: 
Date:
Test class: CommunityPayCheck.cls

Behavior:
    
       
********************************************************************************************************/

public class CommunityRenewals {
    
    
    private Id lRegId;
    public String errormessage {get; set;}
    public String errortype {get; set;}
    public String errorDisplay {get; set;}
    
    public CommunityRenewals(){
        lRegId = apexpages.currentpage().getparameters().get('id'); 
    }
    
    public PageReference cloneWithItems() {

         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();

         try {
             
             License_Registration__c originalLR = [SELECT Id, Status__c FROM License_Registration__c WHERE Id = :lRegId];
             
              //copy the purchase order - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
             License_Registration__c  lr = [select Id, Account__c, Account_Email__c, Applicant__c/*, Application_Type__c*/, Assigned_Deputy__c, 
             Audit_Number__c, Company_Ownership_Section_Complete__c, Company_Type__c, Employee_Leasing__c, Corp_or_LLC_ID__c,
             Date_Formed__c, Date_Paid__c, Daytime_Phone__c, Daytime_Phone_Ext__c, Effective_Date__c, Expiration_Date__c,
             Federal_Employer_Identification_Number__c, Fee_Summary_ID__c, First_Name__c, Good_standing_with_CA_Secretary_of_State__c,
             Imported_From__c, Insurance_Carrier__c, Last_Name__c, Legacy_ID__c, Legal_Entity_Name__c, License_Registration_Number__c,
             License_Registration_Type__c, License_Revocation_Hearing_Date__c, License_Revocation_Results__c, Mailing_Address_Line_1__c,
             Mailing_Address_Line_2__c, Mailing_Address_Same_as_Physical__c, Mailing_Address_Same_as_Residential__c, Mailing_City__c,
             Mailing_Country__c, Mailing_Postal_Code__c, Mailing_State__c, Middle_Name__c, Mobile_Phone__c, Name_of_License_Registration__c,
             Need_to_assign_agent_s__c, Not_in_good_standing_explanation__c, Original_Registration__c, Payment_Status__c,
             Physical_Business_Address_Line_1__c, Physical_Business_Address_Line_2__c, Physical_Business_City__c, Physical_Business_Country__c,
             Physical_Business_Postal_Code__c,Physical_Business_State__c, Ready_to_Submit__c, Received_Date__c, Registration_Renewal_Rollup__c,
             Renewal__c, Residential_Address_Line_1__c, Residential_Address_Line_2__c, Residential_City__c, Residential_Country__c, Residential_Postal_Code__c,
             Residential_State__c, Secured_License_Registration_Type__c, Service_Type__c, State_Employer_Identification_Number__c, State_of_Incorporation__c,
             Status__c, Submission_Type__c, Submit_Payment__c, Surety_Type__c, Title__c
             FROM License_Registration__c where id = :lRegId];
             License_Registration__c newlr = lr.clone(false);
             newlr.Original_Registration__c = lRegId;
             newlr.Status__c = 'Submitted';
             newlr.Renewal__c = true;
             newlr.Effective_Date__c = lr.Expiration_Date__c;
             newlr.Expiration_Date__c = (lr.Effective_Date__c).addYears(1);
             
             if(!Test.isRunningTest()){
                 insert newlr;
             }
             else{
                 newlr.id = lRegId;
             }

             // set the id of the new lr created for testing
             Id newRecordId = newlr.id;
             
            // ==================================================             
            // copy over Registration Account records
            // ==================================================
            List<Registration_Account__c> RegistrationAccounts = new List<Registration_Account__c>();
            List<Registration_Account__c> xRegistrationAccounts =  [SELECT Id, Name, RecordTypeId, Account__c, Corp_or_LLC_ID__c, Corp_or_LLC_Name__c, Date_Formed__c, Business_Phone__c, 
            Daytime_Phone_Ext__c, Driver_s_License__c, Driver_s_License_State__c, Email_Address__c, Federal_Employer_Identification_Number__c,
            First_Name__c, Foreign_Address__c, Good_standing_with_CA_Secretary_of_State__c, Imported_From__c, Joint_Venture_Company_Type__c,
            Last_Name__c, Legacy_ID__c, Legal_Entity_Name__c, Mailing_Street__c, Mailing_Address_Line_2__c, Mailing_Address_Line_3__c,
            Mailing_Address_Same_as_Physical__c, Mailing_Address_Same_as_Residential__c, Mailing_City__c, Mailing_Country__c, Mailing_Zip_Code__c,
            Mailing_State__c, Middle_Name__c, Mobile_Phone__c, Not_in_good_standing_explanation__c, Number_of_Registration_Accounts__c,
            Physical_Business_Street__c, Physical_Business_Line_2__c, Physical_Business_Line_3__c, Physical_Business_City__c, Physical_Business_Country__c,
            Physical_Business_Zip_Code__c, Physical_Business_State__c, Residential_Street__c, Residential_Address_Line_2__c, Residential_Address_Line_3__c,
            Residential_City__c, Residential_Country__c, Residential_Zip_Code__c, Residential_State__c, Re_type_SSN__c, SSN__c, State_Employer_Identification_Number_c__c,
            State_of_Incorporation__c, Title__c, Registration__c FROM Registration_Account__c WHERE Registration__c = :lRegId];
            for (Registration_Account__c ra : xRegistrationAccounts) {
                Registration_Account__c newRA = ra.clone(false);
                newRA.Registration__c = newlr.id;
                RegistrationAccounts.add(newRA);
            }
            if(RegistrationAccounts.size() > 0)
                insert RegistrationAccounts;
            
            // ================================================== 
            // copy over Registration Location records
            // ==================================================
            List<Registration_Location__c> RegistrationLocations = new List<Registration_Location__c>();
            List<Registration_Location__c> xRegistrationLocations = [SELECT Id, RecordTypeId, Account__c, Address__c, Address_Line_2__c, Address_Line_3__c,
            City__c, Country__c, DBA_Name__c, FBNS__c, Foreign_Address__c, Imported_From__c, Latitude__c, Legacy_ID__c, Location__c,
            Longitude__c, Mobile_Business__c, Phone__c, Phone_Extension__c, Zip_Code__c, Registration__c, State__c
            FROM Registration_Location__c WHERE Registration__c = :lRegId AND Date_Deactivated__c = NULL];
            for (Registration_Location__c rl : xRegistrationLocations) {
                Registration_Location__c  newRL = rl.clone(false);
                newRL.Registration__c = newlr.id;
                RegistrationLocations.add(newRL);
            }
            if(RegistrationLocations.size() > 0)
                insert RegistrationLocations;
            
            // ==================================================     
            // copy over Bonds records
            // ==================================================
            List<Bond__c> Bonds = new List<Bond__c>();
            List<Bond__c> xBonds = [SELECT Id, Amount_Returned__c, Appeal__c, Bond_Amount__c, Bond_Balance__c, Bond_Type__c, Writ__c,
            Date_Due_for_Return_to_Defendant__c, Date_Posted__c, Date_Request_Made_to_Hold_Bond__c, Date_Returned_to_Defendant__c,
            Effective_Date__c, Name_of_Surety_Company__c, Posted_By__c, Posted_By_Name__c,Referral__c, Registration__c, Total_Deductions__c    
            FROM Bond__c WHERE Registration__c = :lRegId];
            for (Bond__c b : xBonds) {
                Bond__c newB = b.clone(false);
                newB.Registration__c = newlr.id;
                Bonds.add(newB);
            }
            if(Bonds.size() > 0)
                insert Bonds;    
                 
            // ==================================================
            // copy over Ownership records
            // ==================================================
            List<Ownership__c> Ownership = new List<Ownership__c>();
            List<Ownership__c> xOwnership = [SELECT Id, RecordTypeId, Company__c, Daytime_Phone__c, Daytime_Phone_Ext__c, Driver_s_License__c,
            Driver_s_License_State__c, Email__c, First_Name__c, Imported_From__c, Last_Name__c, Legacy_ID__c, Joint_Venture_Company__c,
            Mailing_Street__c, Mailing_Address_Line_2__c, Mailing_Address_Line_3__c, Mailing_Address_Same_as_Residential__c, Mailing_City__c,
            Mailing_Country__c, Mailing_Zip_Code__c, Mailing_State__c, Middle_Name__c, Owner__c, Ownership_Percentage__c, Registration__c,
            Street__c, Residential_Address_Line_2__c, Residential_Address_Line_3__c, City__c, Residential_Country__c, Residential_Zip_Code__c,
            State__c, Re_type_SSN__c, SSN__c, Title__c    
            FROM Ownership__c WHERE Registration__c = :lRegId];
            for (Ownership__c o : xOwnership) {
                Ownership__c newO = o.clone(false);
                newO.Registration__c = newlr.id;
                Ownership.add(newO);
            }
            if(Ownership.size() > 0)
                insert Ownership;   
             
            // ==================================================
            // copy over Registration Questions records
            // ==================================================
            List<Registration_Question__c> RegistrationQuestion = new List<Registration_Question__c>();
            List<Registration_Question__c> xRegistrationQuestion = [SELECT Id, RecordTypeId, Reg_Answer__c, Answered__c, Checkbox__c, 
            Disqualified__c, Correction_Instructions__c, Disqualified_Answer__c, Eligibility_Notification__c, 
            Long_Text__c, Question_ID__c,  Registration_ID__c, Text__c, YesNo__c  
            FROM Registration_Question__c WHERE Registration_ID__c = :lRegId];
            for (Registration_Question__c rq : xRegistrationQuestion) {
                 Registration_Question__c newRQ = rq.clone(false);
                 newRQ.Registration_ID__c = newlr.id;
                 RegistrationQuestion.add(newRQ);
            }
            if(RegistrationQuestion.size() > 0)
                insert RegistrationQuestion; 
             
            Map<Id, Id> NewRegistrationQuestionMap = new Map<Id, Id>();  
            for (Registration_Question__c rq : [SELECT Id, Question_ID__c,  Registration_ID__c  
            FROM Registration_Question__c WHERE Registration_ID__c = :newlr.id]) {
                NewRegistrationQuestionMap.put(rq.Question_ID__c, rq.Id);
                 
            }
            
            // ================================================== 
            // copy over Follow-Up Questions records
            // ==================================================
            List<Follow_Up_Question__c> FollowUpQuestions = new List<Follow_Up_Question__c>();
            List<Follow_Up_Question__c> xFollowUpQuestions = [SELECT Id, RecordTypeId, Answer__c, Answered__c, Follow_Up_Checkbox__c, Follow_Up_Long_Text__c,
            Follow_Up_Text__c, Follow_Up_YesNo__c, Question_ID__c, Registration__c, Registration_Question_ID__c, Registration_Questions__c
            FROM Follow_Up_Question__c WHERE Registration__c = :lRegId];
            for (Follow_Up_Question__c fq : xFollowUpQuestions) {
                Follow_Up_Question__c newFUQ = fq.clone(false);
                newFUQ.Registration__c = newlr.id;
                newFUQ.Registration_Question_ID__c = newlr.id;
                newFUQ.Registration_Question_ID__c = NewRegistrationQuestionMap.get(fq.Question_ID__c);
                FollowUpQuestions.add(newFUQ);
            }
            if(RegistrationQuestion.size() > 0)
                insert RegistrationQuestion;
             
            // copy over Registration Education records
            List<Registration_Education__c> RegistrationEducation = new List<Registration_Education__c>();
            List<Registration_Education__c> xRegistrationEducation = [SELECT Id, Name, Applicant__c, Applicant_Email__c, Applicant_Populated__c, Attendee__c,
            Exam_Date__c, Exam_Notification_Sent__c, Expiration_Date__c, Instructions__c, Language__c, Pass_Fail__c, Registration__c, Version__c
            FROM Registration_Education__c WHERE Registration__c = :lRegId];
            for (Registration_Education__c re : xRegistrationEducation) {
                Registration_Education__c newRE = re.clone(false);
                newRE.Registration__c = newlr.id;
                RegistrationEducation.add(newRE);
            }
            if(RegistrationQuestion.size() > 0)
                insert RegistrationQuestion;     
             
            // ==================================================
            // copy over Fee Summaries records
            // ==================================================
            List<Fee_Summary__c> FeeSummary = new List<Fee_Summary__c>();
            List<Fee_Summary__c> xFeeSummary = [SELECT Id, Fees_Paid_Manual__c, Fees_Due__c, Original_Fee_Summary__c, Fees_Paid_Online__c, Type__c, Registration__c, Status__c
            FROM Fee_Summary__c WHERE Registration__c = :lRegId];
            for (Fee_Summary__c fs : xFeeSummary) {
                Fee_Summary__c newFS = fs.clone(false);
                newFS.Registration__c = newlr.id;
                newFS.Original_Fee_Summary__c = fs.Id;
                FeeSummary.add(newFS);
            }
            if(FeeSummary.size() > 0)
                insert FeeSummary; 
            
            Map<Id, Id> FeeSummaryMap = new Map<Id, Id>();
            for (Fee_Summary__c fs : [SELECT Id, Original_Fee_Summary__c
            FROM Fee_Summary__c WHERE Registration__c = :newlr.id]) {
                FeeSummaryMap.put(fs.Original_Fee_Summary__c, fs.Id);
            }
                 
            // ==================================================               
            // copy over Fees records
            // ==================================================
            List<Fee__c> xFees = new List<Fee__c>();
            List<Fee__c> Fees = [SELECT Id, Description__c, Fee__c, Fee_Schedule__c, Fee_Summary__c, Registration__c
            FROM Fee__c WHERE Registration__c = :lRegId];
            for (Fee__c f : Fees) {
                Fee__c newF = f.clone(false);
                newF.Registration__c = newlr.id;
                if(FeeSummaryMap.containsKey(f.Fee_Summary__c))
                    newF.Fee_Summary__c = FeeSummaryMap.get(f.Fee_Summary__c);
                    
                newF.Id = null;
                xFees.add(newF);
            }
            if(xFees.size() > 0)
                insert xFees; 
                     
            // ==================================================
            // copy over Manual_Fee_Payment records
            // ==================================================
            List<Manual_Fee_Payment__c> Manual_Fee_Payment = new List<Manual_Fee_Payment__c>();
            List<Manual_Fee_Payment__c> xManual_Fee_Payment = [SELECT Id, Amount__c, Check_Number__c, Check_Type__c, Fee_Summary__c, Registration__c, Status__c
            FROM Manual_Fee_Payment__c WHERE Registration__c = :lRegId];
            for (Manual_Fee_Payment__c mfp : xManual_Fee_Payment) {
                Manual_Fee_Payment__c newMFP = mfp.clone(false);
                newMFP.Registration__c = newlr.id;
                Manual_Fee_Payment.add(newMFP);
            }
            if(Manual_Fee_Payment.size() > 0)
                insert Manual_Fee_Payment;

            // ================================================== 
            // copy over Rejection records
            // ==================================================
            List<Rejection__c> Rejection = new List<Rejection__c>();
            List<Rejection__c> xRejection = [SELECT Id, X1st_Defect_Letter_Sent__c, X2nd_Defect_Letter_Sent__c, X3rd_Defect_Letter_Sent__c,
            Applicant__c, General_Notes_Instructions__c, Registration__c, Times_Rejected__c, Original_Rejection__c
            FROM Rejection__c WHERE Registration__c = :lRegId];
            for (Rejection__c r : xRejection) {
                Rejection__c newR = r.clone(false);
                newR.Registration__c = newlr.id;
                newR.Original_Rejection__c = r.Id;
                Rejection.add(newR);
            }
            if(Rejection.size() > 0)
                insert Rejection;
             
            Map<Id, Id> RejectionMap = new Map<Id, Id>();
            List<Rejection__c> xrej = [SELECT Id, X1st_Defect_Letter_Sent__c, X2nd_Defect_Letter_Sent__c, X3rd_Defect_Letter_Sent__c,
            Applicant__c, General_Notes_Instructions__c, Registration__c, Times_Rejected__c, Original_Rejection__c
            FROM Rejection__c WHERE Registration__c = :lRegId];
            for (Rejection__c r : xrej) {
                RejectionMap.put(r.Original_Rejection__c, r.Id);
            }
             
            // ================================================== 
            // copy over Rejection Defect records
            // ==================================================
             List<Rejection_Defect__c> RejectionDefect = new List<Rejection_Defect__c>();
             List<Rejection_Defect__c> xRejectionDefect = [SELECT Id, RecordTypeId, Applies__c, Defect__c, Description_of_Defect__c, Item_Name__c,
             Registration__c, Rejection__c, Resolved__c, Section__c, Sub_Section__c
             FROM Rejection_Defect__c  WHERE Registration__c = :lRegId];
             for (Rejection_Defect__c rd : xRejectionDefect) {
                  Rejection_Defect__c newRD = rd.clone(false);
                  newRD.Registration__c = newlr.id;
                  if(RejectionMap.containsKey(rd.Registration__c))
                      newRD.Rejection__c = RejectionMap.get(rd.Registration__c);
                  RejectionDefect.add(newRD);
             }
             if(RejectionDefect.size() > 0)
                 insert RejectionDefect;
             
             
             originalLR.Status__c = 'Closed';
             update originalLR;
             
         } catch (Exception e){
             // roll everything back in case of error
             system.debug(e.getStackTraceString()+'--------'+e.getMessage());
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }

        return new PageReference('/CommunityRegistration');
    }
    
}