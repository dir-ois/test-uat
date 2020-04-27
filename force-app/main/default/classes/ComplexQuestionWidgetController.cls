public class ComplexQuestionWidgetController{
    private String registrationId;
    public License_Registration__c registration {get; set;}
    public List<PrimaryQuestionsWrapper> primaryQuesWrapper {get; set;}
    public List<FollowUpQuestionsWrapper> followQuesWrapper {get; set;}
    public List<FollowUpComplexQuestionsWrapper> followComplexWrapper {get; set;}
    public List<FollowUpQuestionsDetailWrapper> followDetailsWrapper {get; set;}
    public Boolean showPrimaryQuestions {get; set;}
    public Boolean showFollowUpQuestions {get; set;}
    public Boolean showComplexQuestions {get; set;}
    private Id complexQuestionTypeID;
    List<Follow_Up_Question__c> followUpQuestions = new List<Follow_Up_Question__c>();
    Map<ID,List<Follow_Up_Question_Detail__c>> qDetailsMap = new Map<ID,List<Follow_Up_Question_Detail__c>>();
    public List<FollowUpComplexQuestionsWrapper> newDetails {get; set;}
    public List<FinalQuestionTable> finalList {get; set;}
    
    public ComplexQuestionWidgetController(){
        registrationId = ApexPages.CurrentPage().getParameters().get('id');
        showFollowUpQuestions = false;
        showComplexQuestions = false;
        followDetailsWrapper = new List<FollowUpQuestionsDetailWrapper>();
        finalList = new List<FinalQuestionTable>();
        complexQuestionTypeID = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByName().get('Complex').getRecordTypeId();
        
        checkPrimaryQuestions();
        checkFollowUpQuestions();
        checkComplexQuestions();
    }
    
    public class PrimaryQuestionsWrapper{
        public Registration_Question__c regQuestion {get; set;}
        public List<SelectOption> options {get; set;}
        public PrimaryQuestionsWrapper(Registration_Question__c rq, List<String> optList){
            this.regQuestion = rq;
            if(optList.size() > 0){
                this.options = new List<SelectOption>();
                for(String opt : optList){
                    this.options.add(new SelectOption(opt,opt));
                }
            }
        }
    }
    
    public class FollowUpQuestionsWrapper{
        public Follow_Up_Question__c followQuestion {get; set;}
        public List<SelectOption> options {get; set;}
        public FollowUpQuestionsWrapper(Follow_Up_Question__c fq, List<String> optList){
            this.followQuestion = fq;
            if(optList.size() > 0){
                this.options = new List<SelectOption>();
                for(String opt : optList){
                    this.options.add(new SelectOption(opt,opt));
                }
            }
        }
    }
    
    public class FollowUpComplexQuestionsWrapper{
        public Follow_Up_Question__c followQuestion;
        public Follow_Up_Detail_Config__c followConfig {get; set;}
        public Follow_Up_Question_Data__c followAnswer {get; set;}
        public List<SelectOption> options {get; set;}
        
        public FollowUpComplexQuestionsWrapper(Follow_Up_Question__c fQues, Follow_Up_Detail_Config__c fConfig, Follow_Up_Question_Data__c fData){
            this.followQuestion = fQues;
            this.followConfig = fConfig;
            this.followAnswer = fData;
        }
        
        public FollowUpComplexQuestionsWrapper(Follow_Up_Question__c fQues, Follow_Up_Detail_Config__c fConfig, Follow_Up_Question_Data__c fData, List<string> optList){
            this.followQuestion = fQues;
            this.followConfig = fConfig;
            this.followAnswer = fData;
            if(optList.size() > 0){
                this.options = new List<SelectOption>();
                for(String opt : optList){
                    this.options.add(new SelectOption(opt,opt));
                }
            }
        }
    }
    
    public class FollowUpQuestionsDetailWrapper{
        public Follow_Up_Question__c followQuestion {get; set;}
        public Follow_Up_Question_Detail__c followDetail {get; set;}
        public List<FollowUpComplexQuestionsWrapper> wrap {get; set;}
        public Boolean hasDetails {get; set;}
        
        public FollowUpQuestionsDetailWrapper(Follow_Up_Question__c fQuestion, Follow_Up_Question_Detail__c fDetail,List<FollowUpComplexQuestionsWrapper> fWrap){
            this.followQuestion = fQuestion;
            this.followDetail = fDetail;
            this.wrap = fWrap;
            if(fDetail.id != null){
                this.hasDetails = true;
            }else{
                this.hasDetails = false;
            }
            
            if(fWrap.size() > 0){
                Map<Decimal,FollowUpComplexQuestionsWrapper> orderMap = new Map<Decimal,FollowUpComplexQuestionsWrapper>();
                List<Decimal> orderList = new List<Decimal>();
                this.wrap = new List<FollowUpComplexQuestionsWrapper>();
                for(FollowUpComplexQuestionsWrapper w : fWrap){
                    orderMap.put(w.followConfig.Sort_Order__c, w);
                    orderList.add(w.followConfig.Sort_Order__c);
                }
                orderList.sort();
                for(Decimal i : orderList){
                    this.wrap.add(orderMap.get(i));
                }
            }
        }
        
        public FollowUpQuestionsDetailWrapper(Follow_Up_Question__c fQuestion){
            this.followQuestion = fQuestion;
            this.hasDetails = false;
        }
    }
    
    public class FinalQuestionTable{
        public Follow_Up_Question__c followQuestion {get; set;}
        public List<FollowUpQuestionsDetailWrapper> qTable {get; set;}
        public Boolean hasButtonText {get; set;}
        public String buttonText {get; set;}
        public Boolean hasDetails {get; set;}
        public Boolean showQuestionForm {get; set;}
        
        public FinalQuestionTable(Follow_Up_Question__c fQues, List<FollowUpQuestionsDetailWrapper> dWrap){
            this.followQuestion = fQues;
            this.qTable = dWrap;
            this.showQuestionForm = false;
            
            if(dWrap.size() > 0){
                this.hasDetails = true;
            }else{
                this.hasDetails = false;
            }
            if(this.followQuestion.Question_ID__r.Button_Text__c != null){
                this.hasButtonText = true;
                this.buttonText = followQuestion.Question_ID__r.Button_Text__c;
            }
        }
        
        public FinalQuestionTable(Follow_Up_Question__c fQuestion){
            this.followQuestion = fQuestion;
            this.hasDetails = false;
            this.qTable = new List<FollowUpQuestionsDetailWrapper>();
            if(this.followQuestion.Question_ID__r.Button_Text__c != null){
                this.hasButtonText = true;
                this.buttonText = followQuestion.Question_ID__r.Button_Text__c;
            }
        }
    }
    
    
    public void checkPrimaryQuestions(){
        registration = [select id,
                        (select id,Reg_Answer__c,Answered__c,Checkbox__c,Correction_Instructions__c,Disqualified__c,Disqualified_Answer__c,
                         Eligibility_Notification__c,Long_Text__c,Question_ID__c,Question_Text__c,Registration_ID__c,Text__c,YesNo__c,
                         Question_ID__r.Answer_Type__c,Question_ID__r.Button_Text__c,Question_ID__r.Controlling_Question__c,
                         Question_ID__r.Correction_Instructions__c,Question_ID__r.Disqualified_Answer__c,Question_ID__r.Follow_up_Criteria__c,
                         Question_ID__r.Picklist_Values__c,Question_ID__r.Question_Text__c,Question_ID__r.Registration_Type__c,
                         Question_ID__r.Short_Text__c from Registration_Questions__r ORDER BY Sort_Order__c ASC)
                        from License_Registration__c WHERE id = :registrationId];
        if(registration.Registration_Questions__r != null && registration.Registration_Questions__r.size() > 0){
            showPrimaryQuestions = true;
            primaryQuesWrapper = new List<PrimaryQuestionsWrapper>();
            for(Registration_Question__c rq : registration.Registration_Questions__r){
                if(rq.Question_ID__r.Answer_Type__c == 'Picklist' && !String.isBlank(rq.Question_ID__r.Picklist_Values__c)){
                    primaryQuesWrapper.add(new PrimaryQuestionsWrapper(rq, rq.Question_ID__r.Picklist_Values__c.split(',')));
                }else{
                    primaryQuesWrapper.add(new PrimaryQuestionsWrapper(rq, new List<String>()));
                }
            }
        }
    }
    
    public void checkFollowUpQuestions(){
        followUpQuestions = [select id,Answer__c,Answered__c,Follow_Up_Checkbox__c,Follow_Up_Long_Text__c,Follow_Up_Question_Text__c,
                         Follow_Up_Text__c,Follow_Up_YesNo__c,Question_ID__c,Registration__c,Question_ID__r.Answer_Type__c,
                         Question_ID__r.Button_Text__c,Question_ID__r.Controlling_Question__c,Question_ID__r.Correction_Instructions__c,
                         Question_ID__r.Disqualified_Answer__c,Question_ID__r.Follow_up_Criteria__c,Question_ID__r.Picklist_Values__c,
                         Question_ID__r.Question_Text__c,Question_ID__r.Registration_Type__c,Question_ID__r.Short_Text__c,
                         Question_ID__r.RecordTypeId,
                         (select id,Follow_Up_Question__c from Follow_Up_Question_Details__r)
                         from Follow_Up_Question__c WHERE Registration_Question_ID__c = :registrationId ORDER BY LastModifiedDate DESC];
        
        if(followUpQuestions.size() > 0){
            followQuesWrapper = new List<FollowUpQuestionsWrapper>();
            List<Question_Bank__c> complexQuestions = new List<Question_Bank__c>();
            List<Follow_Up_Question_Detail__c> qDetails = new List<Follow_Up_Question_Detail__c>();
            Map<ID,Follow_Up_Question__c> fMap = new Map<ID,Follow_Up_Question__c>();
            for(Follow_Up_Question__c fq : followUpQuestions){
                if(fq.Question_ID__r.RecordTypeId != complexQuestionTypeID){
                    if(fq.Question_ID__r.Answer_Type__c == 'Picklist' && !String.isBlank(fq.Question_ID__r.Picklist_Values__c)){
                        followQuesWrapper.add(new FollowUpQuestionsWrapper(fq, fq.Question_ID__r.Picklist_Values__c.split(',')));
                    }else{
                        followQuesWrapper.add(new FollowUpQuestionsWrapper(fq, new List<String>()));
                    }
                }else{
                    complexQuestions.add(fq.Question_ID__r);
                    fMap.put(fq.id,fq);
                    if(fq.Follow_Up_Question_Details__r != null && fq.Follow_Up_Question_Details__r.size() > 0){
                        qDetails.addAll(fq.Follow_Up_Question_Details__r);
                    }else{
                        finalList.add(new FinalQuestionTable(fq));
                    }
                }
            }
            if(followQuesWrapper.size() > 0){
                showFollowUpQuestions = true;
            }
            if(qDetails.size() > 0){
                for(Follow_Up_Question_Detail__c fDetail : [select id,Follow_Up_Question__c,Follow_Up_Question__r.id,Follow_Up_Question__r.Question_Id__c,
                                                            Follow_Up_Question__r.Answer__c,Follow_Up_Question__r.Answered__c,Follow_Up_Question__r.Follow_Up_Checkbox__c,
                                                            Follow_Up_Question__r.Follow_Up_Long_Text__c,Follow_Up_Question__r.Follow_Up_Question_Text__c,
                                                            Follow_Up_Question__r.Question_ID__r.Button_Text__c,
                                                            (select id,Field_Name__c,Follow_Up_Detail_Config__c,Follow_Up_Question_Detail__c,Value__c,
                                                             Follow_Up_Detail_Config__r.Active__c,Follow_Up_Detail_Config__r.Answer_Type__c,
                                                             Follow_Up_Detail_Config__r.Field_Name__c,Follow_Up_Detail_Config__r.Question_Bank__c,
                                                             Follow_Up_Detail_Config__r.Required__c,Follow_Up_Detail_Config__r.Picklist_Values__c,
                                                             Follow_Up_Detail_Config__r.Show_on_summary_table__c,Show_on_summary_table__c,
                                                             Follow_Up_Detail_Config__r.Sort_Order__c,Follow_Up_Detail_Config__r.Currency_Placeholder__c,
                                                             Follow_Up_Detail_Config__r.Date_Placeholder__c,Follow_Up_Detail_Config__r.Number_Placeholder__c
                                                             from Follow_Up_Question_Data__r WHERE Follow_Up_Detail_Config__r.Active__c = true)
                                                            from Follow_Up_Question_Detail__c WHERE Id IN : qDetails]){
                    if(fDetail.Follow_Up_Question_Data__r != null && fDetail.Follow_Up_Question_Data__r.size() > 0){
                        if(qDetailsMap.containsKey(fDetail.Follow_Up_Question__c)){
                            List<Follow_Up_Question_Detail__c> details = qDetailsMap.get(fDetail.Follow_Up_Question__c);
                            details.add(fDetail);
                            qDetailsMap.put(fDetail.Follow_Up_Question__c,details);
                        }else{
                            qDetailsMap.put(fDetail.Follow_Up_Question__c,new Follow_Up_Question_Detail__c[]{fDetail});
                        }
                    }
                }
                
                for(ID fID : qDetailsMap.keySet()){
                    followDetailsWrapper = new List<FollowUpQuestionsDetailWrapper>();
                    for(Follow_Up_Question_Detail__c fDetail : qDetailsMap.get(fID)){
                        followComplexWrapper = new List<FollowUpComplexQuestionsWrapper>();
                        for(Follow_Up_Question_Data__c fData : fDetail.Follow_Up_Question_Data__r){
                            followComplexWrapper.add(new FollowUpComplexQuestionsWrapper(fDetail.Follow_Up_Question__r, fData.Follow_Up_Detail_Config__r, fData));
                        }
                        followDetailsWrapper.add(new FollowUpQuestionsDetailWrapper(fDetail.Follow_Up_Question__r, fDetail, followComplexWrapper));
                    }
                    finalList.add(new FinalQuestionTable(fMap.get(fId), followDetailsWrapper));
                }
            }
        }
    }
    
    
    public void checkComplexQuestions(){
        if(finalList != null && finalList.size() > 0){
            showComplexQuestions = true;
        }
    }
    
    
    public PageReference checkFollowUpQuestionsAndRefresh(){
        checkFollowUpQuestions();
        PageReference pageRef = Page.ComplexQuestionWidget;
        pageRef.getParameters().put('id',registrationId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    public void savePrimaryQuestions(){
        List<Registration_Question__c> regQuestions = new List<Registration_Question__c>();
        for(PrimaryQuestionsWrapper pqw : primaryQuesWrapper){
            regQuestions.add(pqw.regQuestion);
        }
        update regQuestions;
    }
    
    
    public void saveFollowUpQuestions(){
        List<Follow_Up_Question__c> followQuestions = new List<Follow_Up_Question__c>();
        for(FollowUpQuestionsWrapper fqw : followQuesWrapper){
            followQuestions.add(fqw.followQuestion);
        }
        update followQuestions;
    }
    
    
    public void addComplexQuestionData(){
        string QuesBankID = ApexPages.currentPage().getParameters().get('QuesBankID');
        string FollowQuesID = ApexPages.currentPage().getParameters().get('FollowQuesID');
        
        newDetails = new List<FollowUpComplexQuestionsWrapper>();
        for(Question_Bank__c qb : [select id,Answer_Type__c,Button_Text__c,Controlling_Question__c,
                                    Correction_Instructions__c,Disqualified_Answer__c,Follow_up_Criteria__c,
                                    Picklist_Values__c,Question_Text__c,Registration_Type__c,
                                    Short_Text__c,RecordTypeId,
                                    (select id,Active__c,Answer_Type__c,Field_Name__c,Question_Bank__c,Required__c,Picklist_Values__c,
                                     Show_on_summary_table__c,Sort_Order__c,Currency_Placeholder__c,Date_Placeholder__c,Number_Placeholder__c
                                     from Follow_Up_Detail_Configs__r WHERE Active__c = true ORDER BY Sort_Order__c ASC),
                                    (select id,Answer__c,Answered__c,Follow_Up_Checkbox__c,Follow_Up_Long_Text__c,Follow_Up_Question_Text__c,
                                     Follow_Up_Text__c,Follow_Up_YesNo__c,Question_ID__c,Registration__c,Question_ID__r.Button_Text__c
                                     from Follow_Up_Questions__r WHERE Registration_Question_ID__c = :registrationId)
                                    from Question_Bank__c WHERE Id = :QuesBankID]){
            
            newDetails = new List<FollowUpComplexQuestionsWrapper>();
            for(Follow_Up_Detail_Config__c fConfig : qb.Follow_Up_Detail_Configs__r){
                if(fConfig.Answer_Type__c == 'Picklist' && !String.isBlank(fConfig.Picklist_Values__c)){
                    newDetails.add(new FollowUpComplexQuestionsWrapper(qb.Follow_Up_Questions__r[0],fConfig,new Follow_Up_Question_Data__c(),fConfig.Picklist_Values__c.split(',')));
                }else{
                    newDetails.add(new FollowUpComplexQuestionsWrapper(qb.Follow_Up_Questions__r[0],fConfig,new Follow_Up_Question_Data__c(), new List<string>()));
                }
            }
            
            for(FinalQuestionTable fTable : finalList){
                if(fTable.followQuestion.id == qb.Follow_Up_Questions__r[0].id){
                    fTable.qTable.add(new FollowUpQuestionsDetailWrapper(qb.Follow_Up_Questions__r[0], new Follow_Up_Question_Detail__c(), newDetails));
                    fTable.showQuestionForm = true;
                }else{
                    fTable.showQuestionForm = false;
                }
                if(fTable.qTable.size() > 0){
                    Integer i = fTable.qTable.size() - 1;
                    if(String.isBlank(fTable.qTable[i].followDetail.id)){
                        fTable.qTable.remove(i);
                    }
                }
            }
        }
    }
    
    public PageReference saveComplexQuestions(){
        List<Follow_Up_Question_Data__c> quesData = new List<Follow_Up_Question_Data__c>();
        Follow_Up_Question_Detail__c fDetail = new Follow_Up_Question_Detail__c(Follow_Up_Question__c = newDetails[0].followQuestion.id);
        insert fDetail;
        for(FollowUpComplexQuestionsWrapper cxWrap : newDetails){
            cxWrap.followAnswer.Follow_Up_Question_Detail__c = fDetail.id;
            cxWrap.followAnswer.Follow_Up_Detail_Config__c = cxWrap.followConfig.id;
            if(cxWrap.followConfig.Currency_Placeholder__c != null){
                cxWrap.followAnswer.value__c = String.valueOf(cxWrap.followConfig.Currency_Placeholder__c);
            }
            if(cxWrap.followConfig.Date_Placeholder__c != null){
                cxWrap.followAnswer.value__c = String.valueOf(cxWrap.followConfig.Date_Placeholder__c);
            }
            if(cxWrap.followConfig.Number_Placeholder__c != null){
                cxWrap.followAnswer.value__c = String.valueOf(cxWrap.followConfig.Number_Placeholder__c);
            }
            quesData.add(cxWrap.followAnswer);
        }
        if(quesData.size() > 0){
            insert quesData;
            PageReference pageRef = Page.ComplexQuestionWidget;
            pageRef.getParameters().put('id',registrationId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    public PageReference deleteQuestionData(){
        string fDetailID = ApexPages.CurrentPage().getParameters().get('fDetailID');
        if(fDetailID != null){
            delete new Follow_Up_Question_Detail__c(id = fDetailID);
            PageReference pageRef = Page.ComplexQuestionWidget;
            pageRef.getParameters().put('id',registrationId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
}