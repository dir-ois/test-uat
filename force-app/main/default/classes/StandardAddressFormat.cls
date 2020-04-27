public with sharing class StandardAddressFormat {
    
    public string ObjectType { get;set; }
    public string RecordId { get;set; }
    public string CityField { get;set; }
    public string StateField { get;set; }
    public string StreetField { get;set; }
    public string PostalCodeField { get;set; }
    
    public string CityValue { get;set; }
    public string StateValue { get;set; }
    public string StreetValue { get;set; }
    public string PostalCodeValue { get;set; }

    public List<sObjectWrapper> objectsList {get; set;}

    public Boolean displayResults {get;set;}
    public Boolean noResults {get;set;}
    public Boolean oneAddressReturned {get;set;}
    public List<String> XMLData{get;set;}
    public string outAddress { get;set; }
    public string sendAddress { get;set; }
    public string messageError {get;set;}

    public string msgNotChanged {get;set;}
    public string msgChanged {get;set;}
    public Boolean addressChanged {get;set;}
    private Boolean BAAAAdress {get;set;}
    public string changedStr {get;set;}
    public string changedCit {get;set;}
    public string changedSta {get;set;}
    public string changedZip {get;set;}
    private SObject sToUpdate;

    public StandardAddressFormat(){
        ObjectType = ApexPages.currentPage().getParameters().get('objecttype');
        RecordId = ApexPages.currentPage().getParameters().get('recordId');
        CityField = ApexPages.currentPage().getParameters().get('cityfiled');
        StateField = ApexPages.currentPage().getParameters().get('statefield');
        StreetField = ApexPages.currentPage().getParameters().get('streetfield');
        PostalCodeField = ApexPages.currentPage().getParameters().get('postalcodefield');
        if(RecordId != null) {
            sToUpdate = Database.query('SELECT Id, ' + CityField + ', ' + StateField + ', ' + StreetField + ', ' + PostalCodeField + ' FROM ' + ObjectType + ' WHERE Id = \'' + recordId + '\' LIMIT 1');
            CityValue = (String)sToUpdate.get(CityField);
            StateValue = (String)sToUpdate.get(StateField);
            StreetValue = (String)sToUpdate.get(StreetField);
            PostalCodeValue = (String)sToUpdate.get(PostalCodeField);
        }
        
        displayResults = false;
        noResults = false;
         
    }
    
    public PageReference CheckAddressFormat() {
    
        HttpRequest req = new HttpRequest(); 
        List<Standard_Address_Format__c> SAF = [SELECT Name, UserID__c, Verify_Address_URL__c FROM Standard_Address_Format__c WHERE Name = 'Validate Address' LIMIT 1];
        system.debug('SAF List:::: ' + SAF);
        
        string XMLString = '<AddressValidateRequest USERID="' + SAF[0].UserID__c + '"><Address ID="0"> <Address1></Address1><Address2>' + StreetValue  + '</Address2><City>' + CityValue  + '</City><State>' + StateValue + '</State><Zip5></Zip5><Zip4></Zip4></Address><Address ID="1"> <Address1></Address1><Address2>' + StreetValue  + 'aaaa</Address2><City>' + CityValue  + '</City><State>' + StateValue + '</State><Zip5></Zip5><Zip4></Zip4></Address></AddressValidateRequest>';
        string endpoint = SAF[0].Verify_Address_URL__c+ '?API=Verify&XML=' + EncodingUtil.urlEncode(XMLString, 'UTF-8');
        system.debug('XMLString:::: ' + XMLString);
        
        sendAddress = endpoint;
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        messageError = '';
        msgNotChanged = '';
        msgChanged = '';
        changedStr = 'valid';
        changedCit = 'valid';
        changedSta = 'valid';
        changedZip = 'valid';
        addressChanged = false;
        BAAAAdress = false;
        displayResults = false;
        noResults = false;
        oneAddressReturned  = false;
        Http http = new Http();

        try {
            if (Test.isRunningTest()) {
                outAddress = '<AddressValidateResponse><Address ID="0"><Address1></Address1><Address2>6406 I Lanes</Address2><City>Greenbelt</City><State>MD</State><Zip5></Zip5><Zip4></Zip4></Address><Address ID="1"><Address1></Address1><Address2>6406 I Lane</Address2><City>Greenbelt</City><State>MD</State><Zip5></Zip5><Zip4></Zip4></Address></AddressValidateResponse>';
            } else {
                HTTPResponse res = http.send(req);
                System.debug(res.toString());
                outAddress = res.getBody();
            }  
            System.debug('****  response body: ' + outAddress);

            DOM.Document xmlDOC = new DOM.Document();
            xmlDOC.load(outAddress);
            DOM.XMLNode rootElement = xmlDOC.getRootElement();
            
            allsObjects = new List<sObject>();

            for(DOM.XMLNode xmlnodeobj:xmlDOC.getRootElement().getChildElements())
            {        
               loadChilds(xmlnodeobj);         
            }
            
            if(allsObjects.size() > 1) {

                    objectsList = new List<sObjectWrapper>();
                    integer i = 0;
                    for(sObject so: allsObjects) {
                        if(i == 0 )
                            objectsList.add(new sObjectWrapper(so, true));
                        else
                            objectsList.add(new sObjectWrapper(so, false));
                        i++;
                    }

                displayResults = true;
                noResults = false;
            } else {
                if(allsObjects.size() == 0) {
                    messageError = 'Unable to locate address. You may attempt to modify and retry with a corrected address.';
                    displayResults = false;
                }
                if(allsObjects.size() == 1) {
                    oneAddressReturned = true;
                    displayResults = true;

                    objectsList = new List<sObjectWrapper>();
                    integer i = 0;
                    for(sObject so: allsObjects) {
                        if(i == 0 )
                            objectsList.add(new sObjectWrapper(so, true));
                        else
                            objectsList.add(new sObjectWrapper(so, false));
                        i++;
                    }

                    SelectAddressFormat();
                }
            }
        } catch(System.CalloutException e) {
        
        }
        return null;
    }

    public List<sObject> allsObjects {get; set;}
    
    public void loadChilds(DOM.XMLNode xmlnode){
        sObject sObj = Schema.getGlobalDescribe().get(ObjectType).newSObject();

        for(Dom.XMLNode child : xmlnode.getChildElements()){    
              if(child.getName() == 'Address2' && child.getText().contains('AAAA'))
                BAAAAdress = true;  
        }

        If (!BAAAAdress) {
        for(Dom.XMLNode child : xmlnode.getChildElements()){    
              
              if(sObj == null)
                  sObj = Schema.getGlobalDescribe().get(ObjectType).newSObject() ;
              String s = '';
              //if(child.getName() == 'Address1')
              //    s = child.getText();
              if(child.getName() == 'Address2')
                  s = child.getText();
              if(!String.isEmpty(s))
                  sObj.put(StreetField, s);
              if(child.getName() == 'State')
                  sObj.put(StateField, child.getText());
              if(child.getName() == 'City')
                  sObj.put(CityField, child.getText());
              if(child.getName() == 'Zip5')
                  sObj.put(PostalCodeField, child.getText());
              if(sObj != null && child.getName() == 'Zip5')
                  allsObjects.add(sObj);     
        }
        }
    }
    
    public class sObjectWrapper {
        public sObject sObj {get; set;}
        public Boolean selected {get; set;}

        public sObjectWrapper(sObject s, Boolean f) {
            sObj = s;
            selected = f;
        }
    }
    
    public PageReference SelectAddressFormat(){
        
        if(oneAddressReturned == true){

            if(StreetValue <> allsObjects[0].get(StreetField)) {
                addressChanged = true;
                changedStr = 'changed';
            }
            if(CityValue <> allsObjects[0].get(CityField)) {
                addressChanged = true;
                changedCit = 'changed';
            }
            if(StateValue <> allsObjects[0].get(StateField)) {
                addressChanged = true;
                changedSta = 'changed';
            }
            if(PostalCodeValue <> allsObjects[0].get(PostalCodeField)) {
                addressChanged = true;
                changedZip = 'changed';
            }
            if(!addressChanged) msgNotChanged = 'Your address is valid!';
            if(addressChanged) msgChanged = 'Your address is not valid. The change needed to make it valid is highlighted below in yellow.';

            noResults = true;
            
        } else {
            for(sObjectWrapper sWrap: objectsList) {
                if(sWrap.selected == true){
                    sToUpdate.put(StateField, sWrap.sObj.get(StateField));
                    sToUpdate.put(StreetField, sWrap.sObj.get(StreetField));
                    sToUpdate.put(CityField, sWrap.sObj.get(CityField));
                    sToUpdate.put(PostalCodeField, sWrap.sObj.get(PostalCodeField));
                    update sToUpdate;
                  }
            }
            PageReference pageRef = new PageReference('/' + RecordId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
        
    }
    
    public PageReference ReturnToTheRecord(){
 
        if(oneAddressReturned == true){
            sToUpdate.put(StateField, allsObjects[0].get(StateField));
            sToUpdate.put(StreetField, allsObjects[0].get(StreetField));
            sToUpdate.put(CityField, allsObjects[0].get(CityField));
            sToUpdate.put(PostalCodeField, allsObjects[0].get(PostalCodeField));
            update sToUpdate;

        PageReference pageRef = new PageReference('/' + RecordId);
        pageRef.setRedirect(true);
        return pageRef;

        } else {
            for(sObjectWrapper sWrap: objectsList) {
                if(sWrap.selected == true){
                    sToUpdate.put(StateField, sWrap.sObj.get(StateField));
                    sToUpdate.put(StreetField, sWrap.sObj.get(StreetField));
                    sToUpdate.put(CityField, sWrap.sObj.get(CityField));
                    sToUpdate.put(PostalCodeField, sWrap.sObj.get(PostalCodeField));
                    update sToUpdate;
                  }
            }
         
            PageReference pageRef = new PageReference('/' + RecordId);
            pageRef.setRedirect(true);
            return pageRef;
        }
    }

    public PageReference CancAndReturn(){

        PageReference pageRef = new PageReference('/' + RecordId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}