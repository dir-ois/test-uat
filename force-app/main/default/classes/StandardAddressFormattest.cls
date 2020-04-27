@istest
public class StandardAddressFormattest {

    public static testMethod void StandardAddressFormattest(){
        PageReference pageRef = Page.StandardAddressFormat;
        Test.setCurrentPage(pageRef);
        
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingStreet = '123 main st';
        acc.ShippingCity = 'San Francisco';
        acc.ShippingState = 'ca';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        
        
        account a = [select id, name, shippingstreet, shippingcity, shippingstate, shippingpostalcode from Account Where ID =: acc.id limit 1];
        
        ApexPages.currentPage().getParameters().put('objectType','Account');
        ApexPages.currentPage().getParameters().put('recordId', acc.Id);
        ApexPages.currentPage().getParameters().put('cityfiled', 'ShippingCity');
        ApexPages.currentPage().getParameters().put('streetfield','ShippingStreet');
        ApexPages.currentPage().getParameters().put('stateField', 'ShippingState');
        ApexPages.currentPage().getParameters().put('postalCodeField', 'ShippingPostalCode');
        
        StandardAddressFormat controller = new StandardAddressFormat();
        
        Standard_Address_Format__c saf = new Standard_Address_Format__c();
        saf.Name = 'Validate Address';
        saf.UserID__c = UserInfo.getUserId().substring(15);
        saf.Verify_Address_URL__c = 'test';
        insert saf; 
        
        controller.CheckAddressFormat();
        controller.oneAddressReturned = true;
        controller.SelectAddressFormat();
        controller.ReturnToTheRecord();
        controller.CancAndReturn();
       
    }
    
    public static testMethod void StandardAddressFormattest2(){
        PageReference pageRef = Page.StandardAddressFormat;
        Test.setCurrentPage(pageRef);
        
        
        Account acc = new Account();
        acc.Name = 'name';
        acc.ShippingStreet = '123 main st';
        acc.ShippingCity = 'San Francisco';
        acc.ShippingState = 'ca';
        acc.ShippingPostalCode = '234889';
        insert acc;
        
        
        
        account a = [select id, name, shippingstreet, shippingcity, shippingstate, shippingpostalcode from Account Where ID =: acc.id limit 1];
        
        ApexPages.currentPage().getParameters().put('objectType','Account');
        ApexPages.currentPage().getParameters().put('recordId', acc.Id);
        ApexPages.currentPage().getParameters().put('cityfiled', 'ShippingCity');
        ApexPages.currentPage().getParameters().put('streetfield','ShippingStreet');
        ApexPages.currentPage().getParameters().put('stateField', 'ShippingState');
        ApexPages.currentPage().getParameters().put('postalCodeField', 'ShippingPostalCode');
        
        StandardAddressFormat controller = new StandardAddressFormat();
        
        Standard_Address_Format__c saf = new Standard_Address_Format__c();
        saf.Name = 'Validate Address';
        saf.UserID__c = UserInfo.getUserId().substring(15);
        saf.Verify_Address_URL__c = 'test';
        insert saf; 
        
        controller.CheckAddressFormat();
        controller.SelectAddressFormat();
        controller.ReturnToTheRecord();
        controller.CancAndReturn();
       
    }
    
}