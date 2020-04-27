/********************************************************************************************************
Name: UpdatePersonAccOnCommUserUpdate.cls
Called from:  CommunityAccountController.cls
Author:  Mirela Chituc (mirela.chituc@vertiba.com)
Date:  10/31/2017

Behavior:
    Registration Community - Profile Update - future method to update contact related to community user when the user is updated
       
********************************************************************************************************/

global class UpdatePersonAccOnCommUserUpdate {
    
    @future
    public static void updateContact(String userId) {
        User u = [SELECT City, ContactId, Contact.AccountId, Country, Email, FirstName, MiddleName, LastName, Phone, PostalCode, State, Street, Title FROM User WHERE Id = :userId]; //query for the User details
        if (u != null) { //if there is a query result
            if (u.ContactId != null) { //if there is an associated Contact
                Account a = new Account(Id = u.Contact.AccountId);
                a.PersonEmail = u.Email;
                a.FirstName = u.FirstName;
                a.LastName = u.LastName;
                a.Middle_Name__pc = u.MiddleName;
                a.Primary_City_Placeholder__c  = u.City;
                a.Primary_Zip_Placeholder__c = u.PostalCode;
                a.Primary_State_Placeholder__c = u.State ;
                a.Primary_Street_Placeholder__c = u.Street;
                a.Phone = u.Phone;
                a.PersonTitle = u.Title;
                
                update a; //update the contact record
            }
        }
    }

}