public class ReceiptLogFormController {
	//TODO: create a single get function for init pickList.

	@AuraEnabled
	public static List<String> getPaymentTypes()
	{
	   List<String> options = new List<String>();
        
	   Schema.DescribeFieldResult fieldResult = Receipt__c.Payment_Type__c.getDescribe();
	   List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        
	   for( Schema.PicklistEntry f : pickList)
	   {
           if(f.getLabel()!='Deduction'){
               options.add(f.getLabel());
           }
	   }
	   return options;
	}

	@AuraEnabled
	public static List<String> getDepositAccount()
	{
	   List<String> options = new List<String>();
        
	   Schema.DescribeFieldResult fieldResult = Receipt__c.Deposit_Account__c.getDescribe();
	   List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
		options.add('None');
	   for( Schema.PicklistEntry f : pickList)
	   {
		  options.add(f.getLabel());
	   }
	   return options;
	}

	@AuraEnabled
	public static List<String> getBankLocation()
	{
	   List<String> options = new List<String>();
        
	   Schema.DescribeFieldResult fieldResult = Receipt__c.Bank_Location__c.getDescribe();
	   List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        
	   for( Schema.PicklistEntry f : pickList)
	   {
		  options.add(f.getLabel());
	   }       
	   return options;
	}

	@AuraEnabled
	public static List<String> getPaymentExchange()
	{
	   List<String> options = new List<String>();
        
	   Schema.DescribeFieldResult fieldResult = Receipt__c.Payment_Exchange__c.getDescribe();
	   List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        
	   for( Schema.PicklistEntry f : pickList)
	   {
		  options.add(f.getLabel());
	   }       
	   return options;
	}

	@AuraEnabled
	public static List<String> getOfficeUnit()
	{
	   List<String> options = new List<String>();
        
	   Schema.DescribeFieldResult fieldResult = Receipt__c.Office_Unit__c.getDescribe();
	   List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        
	   for( Schema.PicklistEntry f : pickList)
	   {
		  options.add(f.getLabel());
	   }       
	   return options;
	}

	@AuraEnabled
	public static String getPayorName(String payorId){ 
		Account payor = [Select Id, Name from Account where id =: payorId Limit 1];
		return payor.Name;
	}

	/*
    @AuraEnabled
	public static String getDeputyName(String deputyId){ 
		DIR_Employee__c deputy = [Select Id, Name from DIR_Employee__c where id =: deputyId Limit 1];
		return deputy.Name;
	}
    

	//add field set in receiptLogForm
	@AuraEnabled
    public static List<FieldSetMember> getFields(String typeName, String fsName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        
		Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
		System.debug('fs: ' + fsMap);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        
		for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f));
        }
		return fset;
    }

	public class FieldSetMember {

		public FieldSetMember(Schema.FieldSetMember f) {
			this.DBRequired = f.DBRequired;
			this.fieldPath = f.fieldPath;
			this.label = f.label;
			this.required = f.required;
			this.type = '' + f.getType();
		}

		public FieldSetMember(Boolean DBRequired) {
			this.DBRequired = DBRequired;
		}

		@AuraEnabled
		public Boolean DBRequired { get;set; }

		@AuraEnabled
		public String fieldPath { get;set; }

		@AuraEnabled
		public String label { get;set; }

		@AuraEnabled
		public Boolean required { get;set; }

		@AuraEnabled
		public String type { get; set; }
	}
 	*/

}