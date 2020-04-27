//-----------------------------
// @author: Oswin Correa 
// @date: 4/4/2018
// @description: Test Class of A_Plus_Controller (Controller of the Attachments + Lightning component)
//-----------------------------
@isTest
private class A_Plus_Controller_Test {

    private static testMethod void testController() {
        
        
        Account objAccount = new Account(Name = 'Test');
        insert objAccount;
        
        Contact objContact =  new Contact(LastName = 'Test', AccountId = objAccount.Id);
        insert objContact;
        
        Attachments_New__c objAttachment1 = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = objAccount.Id);
                                                                  
        Attachments_New__c objAttachment2 = new Attachments_New__c(File_Name__c = 'Test',
                                                                  File_Type__c = 'Test',
                                                                  Related_Id__c = objContact.Id);
                                                                  
        insert new List<Attachments_New__c> {objAttachment1,objAttachment2};
        
        insert new List<Attachments_Data__c> {new Attachments_Data__c(Field_Name__c = 'Test',
                                                                    Value__c = 'Test',
                                                                    Field_API_Name__c = 'Test',
                                                                    Attachments__c = objAttachment1.id),
                                                                    
                                            new Attachments_Data__c(Field_Name__c = 'Test',
                                                                    Value__c = 'Test',
                                                                    Field_API_Name__c = 'Test',
                                                                    Attachments__c = objAttachment2.id)};

        
        A_Plus_Controller.fetchHeadersAndData(objAccount.id,'','');
        
        
        //Public Sharing
        A_Plus_Controller.uploadFile('{"Test" : "Test"}','Unit Test Content Body','Test',objAccount.id,'Test', '{"Id":"m06350000004Dl8AAE","Community_ID__c":"","File_Type__c":"Legal","Object_API_Name__c":"Account","Child_Relationship_Names_Standard__c": "Contacts","Child_Relationship_Names_Custom__c": "",'+
                                                                                                                                      '"Collaboration_Group_Names__c":"","Sharing_Permissions__c":"Public","Sort_Order__c":"5"}');
        
        //Private Sharing
        A_Plus_Controller.uploadFile('{"Test" : "Test"}','Unit Test Content Body','Test',objAccount.id,'Test', '{"Id":"m06350000004Dl8AAE","Community_ID__c":"","File_Type__c":"Legal","Object_API_Name__c":"Account","Child_Relationship_Names_Standard__c": "Contacts","Child_Relationship_Names_Custom__c": "",'+
                                                                                                                    '"Collaboration_Group_Names__c":"Test,Test1","Sharing_Permissions__c":"Private","Sort_Order__c":"5"}');
        
        //Move/Edit Sharing
        A_Plus_Controller.updateAttachment('{"Test" : "Test2","Test1" : "Test2"}',objAttachment1.id,objAccount.Id,'Test', '{"Id":"m06350000004Dl8AAE","Community_ID__c":"","File_Type__c":"Legal","Object_API_Name__c":"Account","Child_Relationship_Names_Standard__c": "Contacts","Child_Relationship_Names_Custom__c": "",'+
                                                                                                                                      '"Collaboration_Group_Names__c":"","Sharing_Permissions__c":"Private","Sort_Order__c":"5"}', true);
                                                                                                                                      
        
        String attchId = objAttachment1.id;
        A_Plus_Controller.deleteAttachment(attchId);
        
        system.assertEquals(false, [SELECT Id 
                                    FROM Attachments_Data__c
                                    WHERE Id =: attchId ].size() ==  1);

        
    }

}