public with sharing class ABTActViewExtension {
    /*
    public ABTActViewExtension(ApexPages.StandardController stdController){
        
    }
    */
    
  //  public string teamSearchName{get;set;}
  //  public string teamSearchRole{get;set;}
    public string firstNameInd{get;set;}
    public string lastNameInd{get;set;}
    public string emailInd{get;set;}
    public string titleInd{get;set;}
    public string phoneInd{get;set;}
 //   public string nameBus{get;set;}
 //   public string acctSearch{get;set;}
 //   public date callDate{get;set;}
 //   public string callDesc{get;set;}
    public string affPair{get;set;}
    public Affiliation__c aff1{get;set;}
    public Affiliation__c aff2{get;set;}
    public Contact newContact {get;set;}
    public Account newAccount {get;set;}
    public String accOrCont {get;set;}
    public String type;
    public Boolean isPersonAccount {get;set;}
    public String rtype {get;set;}
    public string accountName {get;set;}
    public String firstName {get;set;}
    public String lastName {get;set;}
    
    private final Account a;
    private final Contact c;
    public Account acct;
    public Contact cont;
    public ABTActViewExtension(ApexPages.StandardController stdController){
        type = stdController.getRecord().getSObjectType().getDescribe().getName();
        if (type == 'Account'){
            this.a = (Account)stdController.getRecord();
            acct = [SELECT Id, Name FROM Account WHERE Id =: a.Id];
        }
        else{
            this.c = (Contact)stdController.getRecord();
            cont = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE Id =: c.Id];
        }
        aff1 = new Affiliation__c();
        aff2 = new Affiliation__c();
        newContact = new Contact();
        newAccount = new Account();
        accOrCont = 'Account';
        isPersonAccount = false;
        //acct = new Account();
        //cont = new Contact();
        
        
    }
    
    public List<SelectOption> getAccOrContItems() {
        List<SelectOption> options = new List<SelectOption>();  
        options.add(new SelectOption('Account','Account'));
        options.add(new SelectOption('Contact','Contact'));
         return options; 
    }
    
    public pageReference doNothing(){
        return null;
    }

//used for Affiliation inline edit page on the ABT Account page layouts.    
    List<Affiliation__c> affs;
    Public List<Affiliation__c> getAffs(){
        if(affs == null){
            if (type == 'Account')
                affs = [Select Id, Affiliation_Type__c, Affiliated_Account__c, Affiliated_Account__r.Name, Affiliated_Contact__c, Affiliated_Contact__r.Name from Affiliation__c where Main_Account__c=:acct.id 
                        order by CreatedDate];
            else
                affs = [Select Id, Affiliation_Type__c, Affiliated_Account__c, Affiliated_Account__r.Name, Affiliated_Contact__c, Affiliated_Contact__r.Name from Affiliation__c where Main_Contact__c=:cont.id 
                        order by CreatedDate];
        }
        return affs;
    }
    
    public List<SelectOption> getPairs(){
        List<SelectOption> options = new List<SelectOption>();
        for (Affiliation_Pair__c ap:[Select Id, Name, Relationship__c FROM Affiliation_Pair__c WHERE Relationship__c!=null order by Name]){
            options.add(new SelectOption(ap.Id, ap.Name));
        }
        return options;
    }
    
    public List<SelectOption> getTypes(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        for( Schema.RecordTypeInfo recordType : RT ){
            if ((recordType.isAvailable()) && (recordType.Name!='Master'))
                options.add(new SelectOption(recordType.Name, recordType.Name));
        }
        
        return options;
        
    }
    
    public pageReference createIndNew(){
        try{
        //insert new Contact
        insert newContact;
        //insert primary affiliation
            if (type == 'Account'){
                aff1.Main_Account__c=acct.id;
                aff1.Name = acct.Name + '>>';
            }
            else{
                aff1.Main_Contact__c=cont.id;
                aff1.Name = cont.LastName + '>>';
            }
            aff1.Affiliated_Contact__c = newContact.id;
            aff1.Name += newContact.LastName;
            aff1.Affiliation_Type__c=[Select id, Name FROM Affiliation_Pair__c where id=:affPair limit 1].Name;
        insert aff1;
        //insert secondary affiliation
            aff2.Main_Contact__c = newContact.id;
            aff2.Name = newContact.LastName + '>>';
            if (type == 'Account'){
                aff2.Affiliated_Account__c = acct.id;
                aff2.Name += acct.Name;
            }
            else{
                aff2.Affiliated_Contact__c = cont.Id;
                aff2.Name += cont.LastName;
            }
            aff2.Affiliation_Type__c=[Select id, Relationship__c FROM Affiliation_Pair__c where id=:affPair limit 1].Relationship__c;
        insert aff2;
        
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;     
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
        
        return null;
    }

    public pageReference createBusNew(){
        try{
        //insert new account
        String rtid = [Select Id From RecordType  Where SobjectType = 'Account' and Name =: rtype].id;
        newAccount.RecordTypeId = rtid;
        if (rtype == 'Person Account'){
            if (firstName != null)
                newAccount.FirstName = firstName; 
            newAccount.lastName = lastName;
        } else {
            newAccount.Name = accountName;
        }
        insert newAccount;
        //insert primary affiliation
            if (type == 'Account'){
                aff1.Main_Account__c = acct.id;
                aff1.Name = acct.Name + '>>';
            }
            else{
                aff1.Main_Contact__c = cont.id;
                aff1.Name = cont.LastName + '>>';
            }
            aff1.Affiliated_Account__c = newAccount.id;
            aff1.Name += newAccount.LastName;
            aff1.Affiliation_Type__c=[Select id, Name FROM Affiliation_Pair__c where id=:affPair limit 1].Name;
        insert aff1;
        //insert secondary affiliation
            aff2.Main_Account__c = newAccount.id;
            aff2.Name = newAccount.LastName + '>>';
            if (type == 'Account'){
                aff2.Affiliated_Account__c = acct.id;
                aff2.Name += acct.Name;
            }
            else{
                aff2.Affiliated_Contact__c = cont.id;
                aff2.Name += cont.LastName;
            }
            aff2.Affiliation_Type__c=[Select id, Relationship__c FROM Affiliation_Pair__c where id=:affPair limit 1].Relationship__c;
        insert aff2;
        
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;     
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
        
        return null;
    }
    
    public pageReference createSearchAffNew(){
        String name;
        if (accOrCont == 'Account') 
            name = [SELECT Id, Name FROM Account WHERE Id =: aff1.Affiliated_Account__c].Name;
        else{
            List<Account> personAccount = [SELECT Id FROM Account WHERE Id =: aff1.Affiliated_Contact__c AND IsPersonAccount = true];
            if (personAccount.size() == 0)
                name = [SELECT Id, Name, LastName FROM Contact WHERE Id =: aff1.Affiliated_Contact__c].LastName;
            else{
                name = [SELECT Id, Name FROM Account WHERE Id =: aff1.Affiliated_Account__c].Name;
                isPersonAccount = true;
            }
        }
        
        try{
            if (type == 'Account'){
                aff1.Main_Account__c = acct.id;
                aff1.Name = acct.Name + '>>' + name;
            }
            else{
                aff1.Main_Contact__c = cont.id;
                aff1.Name = cont.LastName + '>>' + name;
            }
            aff1.Affiliation_Type__c=[Select id, Name FROM Affiliation_Pair__c where id=:affPair limit 1].Name;
            insert aff1;
            
            if (accOrCont == 'Account'){
                aff2.Main_Account__c = aff1.Affiliated_Account__c;
                aff2.Name = name + '>>';
            }
            else{
                if (isPersonAccount == false)
                    aff2.Main_Contact__c = aff1.Affiliated_Contact__c;
                else
                    aff2.Main_Account__c = aff1.Affiliated_Account__c;
                aff2.Name = name + '>>';
            }
            if (type == 'Account'){
                aff2.Affiliated_Account__c = acct.id;
                aff2.Name += acct.Name;
            }
            else{
                aff2.Affiliated_Contact__c = cont.id;
                aff2.Name += cont.LastName;
            }
            aff2.Affiliation_Type__c=[Select id, Relationship__c FROM Affiliation_Pair__c where id=:affPair limit 1].Relationship__c;
            insert aff2;
            
            PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
            pageRef.setRedirect(true);
            return pageRef;
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
        return null;
    }
          
    @TestVisible String affType = null;
         
    public PageReference typeSelect() {
        return null;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Lookup Existing C/P','Lookup Existing C/P')); 
        options.add(new SelectOption('Create New Individual','Create New Individual'));
        options.add(new SelectOption('Create New Business','Create New Business'));
         return options; 
    }
                   
    public String getaffType() {
        return affType;
    }
                    
    public void setaffType(String affType) { this.affType = affType; }
    
    public void deleteAff(){
        
        String affId = ApexPages.currentPage().getParameters().get('affid');
        
        Affiliation__c aff = [SELECT Id FROM Affiliation__c WHERE Id =: affId];
        
        delete aff;
        
        if (type == 'Account')
            affs = [Select Id, Affiliation_Type__c, Affiliated_Account__c, Affiliated_Account__r.Name, Affiliated_Contact__c, Affiliated_Contact__r.Name from Affiliation__c where Main_Account__c=:acct.id 
                    order by CreatedDate];
        else
            affs = [Select Id, Affiliation_Type__c, Affiliated_Account__c, Affiliated_Account__r.Name, Affiliated_Contact__c, Affiliated_Contact__r.Name from Affiliation__c where Main_Contact__c=:cont.id 
                    order by CreatedDate];
        
    }
    
}