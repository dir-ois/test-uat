/********************************************************************************************************
Name:    emailForExpiringRegistrations.cls
Author:  Shivam Goyal (shivam.goyal@sapient.com)
Date:    11/12/2018
Modified by: 
Date:
Test class: 

Behavior:
    As a submitter, I need renewal email alerts to be sent on June 15 for all active expiring registrations. @mention the person Account that is
    in the Applicant Field (Applicant__c) on the Registration object.
       
********************************************************************************************************/

global class emailForExpiringRegistrations implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID,Applicant__c FROM License_Registration__c ' +
            'where Status__c=\'Active\' and Record_Type_Name__c=\'Public_Works\' and Expiration_Date__c <= THIS_YEAR LIMIT 200' 
        );
    }
    
    global void execute(Database.BatchableContext bc, List<License_Registration__c> scope){
        
        List<FeedItem> posts = new List<FeedItem>();
        for(License_Registration__c registeration:scope){
            FeedItem post = new FeedItem();
                try{
                    if(registeration.Applicant__c!=null){
                        User user=[select id from User where contactid= :registeration.Applicant__c];
                        post.ParentId = user.id;     
                        post.type = 'ContentPost';
                        post.Body = label.Expiring_Registration_Notification;
                        posts.add(post);                            
                    }
                }catch(Exception e){
                    Continue;
                }
        }
     
     if(posts.size()>0){
         System.debug('posts----'+posts);
         Database.insert(posts,false);
     }    
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}