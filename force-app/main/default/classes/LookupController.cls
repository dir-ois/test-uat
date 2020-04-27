public with sharing class LookupController {
    
    public String api_name {get;set;} 
    public boolean ShowDialog { get; set; }
    public String sobjId {get;set;}
    public String fieldOfMO {get;set;} 
    public String sobjName { get; set; }
    public String SearchKeysobj { get; set; } 
    public String typeOfMO {get;set;} 
    public SObject sobj {get;set {
        sobj = value;
        Id lookupid = (Id)sobj.get(fieldOfMO);
        List<SObject> lookupObjects = Database.query('SELECT  Name FROM '+api_name+' WHERE Id=:lookupid limit 1');
        SObject lookupObject;
        if (lookupObjects.size()>0){
            lookupObject = lookupObjects[0];
        }
        if (lookupObject!=null)
        if (lookupObject.get('Name')!=null ){
            sobjName=(String)lookupObject.get('Name');
        }
        else {
            sobjName='';
        }
    }}
    
    public List<SObjectWrapper> SearchResults {get;set;}
    public LookupController(){
        
    }
    public void SearchSObject() {
        
        string searchKey1 = '%' + SearchKeysobj + '%';
        System.debug('Search key --> '+searchKey1);
        List<SObject> sr = Database.query('SELECT Id, Name FROM '+api_name+' WHERE Name LIKE :searchKey1 ORDER BY Name LIMIT 10');
        System.debug('sobjects found -->' + sr.size());
        SearchResults = new List<SobjectWrapper>();
        for (SObject so : sr){
            SObjectWrapper sow = new SObjectWrapper();
            sow.sobj = so;
            
            sow.name = (string)so.get('Name');
            SearchResults.add(sow);
        }
        ShowDialog = true;
    }
    
    public void SelectSObject() {
        
        System.debug('Sobj id ---->'+sobjId);
        System.debug('Sobj Name ---->'+sobjName);
        sobj.put(fieldOfMO , sobjId);
        ShowDialog = false;
        
    }
    
    public class SObjectWrapper {
        public SObject sobj {get;set;}
        public String name {get;set;}
        
    }
}