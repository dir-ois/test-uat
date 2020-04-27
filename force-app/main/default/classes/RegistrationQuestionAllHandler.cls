/********************************************************************************************************
Name:  RegistrationQuestionAllHandler.trigger
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  10/03/2017
Modified by: 
Date:
Trigger: RegistrationQuestionAll.trigger
Test class: RegistrationQuestionAllTest.cls

Behavior: When a user answers a question, the answer field ( reg_answer__c ) on the registration question 
record is populated. This should trigger looking up to see if there are any follow-up questions necessary 
for the question that was answered. 
 


********************************************************************************************************/

public without sharing class RegistrationQuestionAllHandler {
    
     //Handler for before insert methods
    public void onBeforeInsert(list<Registration_Question__c> newList , map<id, Registration_Question__c> newMap) {

    }
    //Handler for after insert methods
    public void onAfterInsert(list<Registration_Question__c> newList , map<id, Registration_Question__c> newMap) {
        
    }
    //Handler for before Update methods
    public void onBeforeUpdate(list<Registration_Question__c> newList, map<id, Registration_Question__c> newMap , map<id, Registration_Question__c> oldMap) {

    }
    //Handler for after Update methods
    public void onAfterUpdate(list<Registration_Question__c> newList, map<id, Registration_Question__c> newMap,  map<id, Registration_Question__c> oldMap) {
        CreateFollowUpQuestions(newList, oldMap);
    }

    //Handler for before Deletes methods
    public void onBeforeDelete(list<Registration_Question__c> oldList , map<id, Registration_Question__c> oldMap) {

    }
    //Handler for after Deletes methods
    public void onAfterDelete(list<Registration_Question__c> oldList , map<id, Registration_Question__c> oldMap) {

    }

    private void CreateFollowUpQuestions(list<Registration_Question__c> newList, map<id, Registration_Question__c> oldMap ) {

        Set<Id> regquestionsId = new Set<Id>();
        Set<Id> delreqquestionsId = new Set<Id>();
        
        Set<String> allQRIds = new Set<String>();
        Set<Id> allRIds = new Set<Id>();
        for( Registration_Question__c rq: newList ) {
        
            Registration_Question__c oldRegistrationQuestion = oldMap.get(rq.ID);
            if( (oldRegistrationQuestion.Reg_Answer__c == null || oldRegistrationQuestion.Reg_Answer__c == '') && rq.Reg_Answer__c != null ) {
                regquestionsId.add(rq.Id);
            }
            
            if( oldRegistrationQuestion.Reg_Answer__c != null && oldRegistrationQuestion.Reg_Answer__c != rq.Reg_Answer__c) {
                 regquestionsId.add(rq.Id);
            }
            
            if( oldRegistrationQuestion.Reg_Answer__c != null && (rq.Reg_Answer__c == null || rq.Reg_Answer__c == '') ) {
                allQRIds.add(rq.Registration_ID__c + '/' + rq.Question_ID__c);
                allRIds.add(rq.Registration_ID__c);
            }  
        }

        // Create Follow_Up_Question__c
        if( regquestionsId.size() > 0 ) {
            
            List<Registration_Question__c> regQuestionsAll = [SELECT Id, Reg_Answer__c, Question_ID__c, Registration_ID__c FROM Registration_Question__c WHERE Id IN: regquestionsId];
            
            Map<Id, List<Registration_Question__c>> RegistrationQuestionsMap = new Map<Id, List<Registration_Question__c>>();
            for( Registration_Question__c rq: regQuestionsAll ) {
                if(!RegistrationQuestionsMap.containsKey(rq.Question_ID__c)) {
                    List<Registration_Question__c> newRQList = new List<Registration_Question__c>();
                    newRQList.add(rq);
                    RegistrationQuestionsMap .put(rq.Question_ID__c, newRQList);
                } else {
                    List<Registration_Question__c> existingRQList = RegistrationQuestionsMap.get(rq.Question_ID__c);
                    existingRQList.add(rq);
                    RegistrationQuestionsMap.put(rq.Question_ID__c, existingRQList);  
                }
            }

            Map<Id, Question_Bank__c> allQuestions = new Map<Id, Question_Bank__c>([SELECT Id, Controlling_Question__c, Follow_up_Criteria__c FROM Question_Bank__c WHERE Controlling_Question__c IN: RegistrationQuestionsMap.keySet()]);
            List<Follow_Up_Question__c> followUpToInsert = new List<Follow_Up_Question__c>();
            for( String s: allQuestions.KeySet() ) {
                Question_Bank__c currentQuestionBank = allQuestions.get(s);
                List<Registration_Question__c> currentRegQuestions = RegistrationQuestionsMap.get(currentQuestionBank.Controlling_Question__c);
                for( Registration_Question__c rq: currentRegQuestions ) {
                    if( (currentQuestionBank.Follow_up_Criteria__c != 'not null' && currentQuestionBank.Follow_up_Criteria__c  == rq.Reg_Answer__c) || 
                        (currentQuestionBank.Follow_up_Criteria__c == 'not null' && !String.isEmpty(rq.Reg_Answer__c))) {
                        
                        Follow_Up_Question__c newFollowUp = new Follow_Up_Question__c();
                        newFollowUp.Question_ID__c = s;
                        newFollowUp.Registration_Question_ID__c = rq.Registration_ID__c;
                        
                        followUpToInsert.add(newFollowUp);
                       
                    } else {
                        allQRIds.add(rq.Registration_ID__c + '/' + currentQuestionBank.Controlling_Question__c);
                        allRIds.add(rq.Registration_ID__c);
                    }
                }
            }
            
            if( followUpToInsert.size() > 0 )
                insert followUpToInsert;
        }
        
        
        // Delete Follow_Up_Question__c if the answer is deleted
        if( allRIds.size() > 0 ) { 
            List<Follow_Up_Question__c> followUpToDelete = new List<Follow_Up_Question__c>();
            List<Follow_Up_Question__c> allFollowUpQuestions = [SELECT Id, Question_ID__c, Question_ID__r.Controlling_Question__c, Registration_Question_ID__c FROM Follow_Up_Question__c WHERE Registration_Question_ID__c IN: allRIds];
            for( Follow_Up_Question__c f: allFollowUpQuestions ) {
                if( allQRIds.contains(f.Registration_Question_ID__c + '/' + f.Question_ID__r.Controlling_Question__c) )
                    followUpToDelete.add(f);  
            }
            
            if( followUpToDelete.size() > 0 )
                delete followUpToDelete;
        }
    }
}