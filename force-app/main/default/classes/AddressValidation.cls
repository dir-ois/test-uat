public with sharing class AddressValidation {

	private string recordId;
	private string objectName;
	private string streetField;
	private string cityField;
	private string countyField;
	private string stateField;
	private string zipField;
	
	public string result { get; set; }

	public AddressValidation() {
		
		recordId = ApexPages.currentPage().getParameters().get('id');
		objectName = ApexPages.currentPage().getParameters().get('object');
		streetField = ApexPages.currentPage().getParameters().get('streetField');
		cityField = ApexPages.currentPage().getParameters().get('cityField');
		countyField = ApexPages.currentPage().getParameters().get('countyField');
		stateField = ApexPages.currentPage().getParameters().get('stateField');
		zipField = ApexPages.currentPage().getParameters().get('zipField');
		
	}
	
	public void ValidateAddress() {
		
		//sObject obj = database.query('SELECT Id, ' + streetField + ', ' + cityField + ', ' + countyField + ', ' + stateField + ', ' + zipField + ' FROM ' + objectName + ' WHERE Id = :recordId');
		
		string URL = 'http://production.shippingapis.com/ShippingAPITest.dll?API=Verify&XML=<AddressValidateRequest USERID="428DEPAR4330"><Address ID="0"><Address1></Address1><Address2>6406 Ivy Lane</Address2><City>Greenbelt</City><State>MD</State><Zip5></Zip5><Zip4></Zip4></Address></AddressValidateRequest>';
		
		HttpRequest req = new HttpRequest();
     	req.setEndpoint(URL);
     	req.setMethod('GET');
        Http http = new Http();
     	HTTPResponse res = http.send(req);
     	result = res.getBody();
		
	}

}