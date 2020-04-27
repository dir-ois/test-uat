public with sharing class AddAppeal {

    Id appealRecTypeId_RCI = Schema.SObjectType.Appeal__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
    Id appealRecTypeId_BOFE = Schema.SObjectType.Appeal__c.getRecordTypeInfosByName().get('BOFE').getRecordTypeId(); 
    Id appealRecTypeId_DeNovo = Schema.SObjectType.Appeal__c.getRecordTypeInfosByName().get('De Novo').getRecordTypeId(); 
        
    Id caseRecTypeId_RCI = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('RCI').getRecordTypeId();
    Id caseRecTypeId_BOFEIntake = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Intake').getRecordTypeId();
    Id caseRecTypeId_BOFEInvesg = Schema.SObjectType.DIR_Case__c.getRecordTypeInfosByName().get('BOFE Investigation').getRecordTypeId();

    public DIR_Case__c cs { get; set; } 
    public Appeal__c appeal { get; set; }
    
    
    public AddAppeal(ApexPages.StandardController sc) {
        cs = [SELECT Id, Employer__c, Employer__r.Name, Employer__r.Phone, RecordTypeId FROM DIR_Case__c WHERE Id = :sc.getId()];
        
        LoadAccounts();
        LoadCitations();
        InitAppeal();
    }
    
    public void InitAppeal() {  

        appeal = new Appeal__c();
        appeal.Case__c = cs.Id;
    }
        
   
    public List<AccountWrapper> Accounts { get; set; }
    public void LoadAccounts() {
        List<Affiliation__c> affs = [SELECT Id, Affiliated_Account__c, Affiliated_Account__r.Name, Affiliation_Type__c, Affiliated_Account__r.Phone FROM Affiliation__c WHERE Main_Account__c = :cs.Employer__c];
        Accounts = new List<AccountWrapper>();
        Accounts.add(new AccountWrapper(new Affiliation__c(Affiliated_Account__c = cs.Employer__c,Affiliated_Account__r = cs.Employer__r, Affiliation_Type__c = 'Employer')));
        for (Affiliation__c aff : affs) {
            Accounts.add(new AccountWrapper(aff));
        }
        if (Accounts.size() > 0) {
            Accounts[0].selected = true;
        }
    }
 
    public List<CitationWrapper> Citations { get; set; }
    public void LoadCitations() {
        Id selAccId = null;
        for (AccountWrapper aw : Accounts)
            if (aw.selected)
                selAccId = aw.acc.Affiliated_Account__c;
        List<Liability__c> liabs = [SELECT Id, Citation_Number__c, CreatedDate, Appeal_Deadline__c, Assessment__c, (SELECT Id FROM Liable_Parties__r WHERE Entity__c = :selAccId) FROM Liability__c WHERE (Status__c = 'new' OR Status__c = 'Appeal Withdrawn') AND Case_Management__c = :cs.Id];
        Citations = new List<CitationWrapper>();
        Map<Id, String> assIds = new Map<Id, String>();
        for (Liability__c liab : liabs) {
            Citations.add(new CitationWrapper(liab, liab.Liable_Parties__r.size() > 0));
            assIds.put(liab.Assessment__c, '');
        }
        List<DIR_Violation__c> viols = [SELECT Assessment__c, Violation_Type__r.Name FROM DIR_Violation__c WHERE Assessment__c IN :assIds.keyset()];
        for (DIR_Violation__c viol : viols) {
            assIds.put(viol.Assessment__c, assIds.get(viol.Assessment__c) + viol.Violation_Type__r.Name + '\n');
        }
        for (CitationWrapper cw : Citations) {
            if (assIds.containsKey(cw.liab.Assessment__c)) {
                cw.violations = assIds.get(cw.liab.Assessment__c);
            }
         }
    }  
    
    public PageReference SaveAppeal() {
        
        
        Savepoint sp = Database.setSavepoint();
        try {
            for (AccountWrapper aw : Accounts) {
                if (aw.selected)
                    appeal.Appeal_Request_Entity__c = aw.acc.Affiliated_Account__c; 
            }
            for (CitationWrapper cw : Citations) {
                if (cw.selected)
                    appeal.Citation_Selected__c=true;  
            }
            
            if (cs.RecordTypeId == caseRecTypeId_RCI){
                appeal.RecordTypeId = appealRecTypeId_RCI;
            }
            else if (cs.RecordTypeId == caseRecTypeId_BOFEIntake){
                appeal.RecordTypeId = appealRecTypeId_BOFE;
            }
            else if (cs.RecordTypeId == caseRecTypeId_BOFEInvesg){
                appeal.RecordTypeId = appealRecTypeId_BOFE;
            }
           
            insert appeal;
            
 
            List<Liability_Appeal__c> las = new List<Liability_Appeal__c>();
            for (CitationWrapper cw : Citations) {
                if (cw.selected) {
                    Liability_Appeal__c la = new Liability_Appeal__c();
                    la.Appeal__c = appeal.Id;
                    la.Liability__c = cw.liab.Id;
                    las.add(la);
                }
            }
            insert las;
            
            List<DIR_Appeal_Party__c> aps = new List<DIR_Appeal_Party__c>();
            for (AccountWrapper aw : Accounts) {
                if (aw.selected2) {
                    DIR_Appeal_Party__c ap = aw.party;
                    ap.Appeal__c = appeal.Id;
                    aps.add(ap);
                }
            }
            insert aps;
            update appeal;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference('/' + appeal.Id);
    }
    
    public class AccountWrapper { 
        public Affiliation__c acc { get; set; }
        public boolean selected { get; set; }
        public DIR_Appeal_Party__c party { get; set; }
        public boolean selected2 { get; set; }
        public AccountWrapper(Affiliation__c a) {
            acc = a;
            if (Test.isRunningTest())
                selected = true;
            else
                selected = false;
            
            party = new DIR_Appeal_Party__c();
            party.Entity__c = acc.Affiliated_Account__c;
            
            if (Test.isRunningTest())
                selected2 = true;
            else
                selected2 = false;
        }
    }
    
    public class CitationWrapper { 
        public Liability__c liab { get; set; }
        public boolean selected { get; set; }
        public boolean highlight { get; set; }
        public string lastDay {
            get {
                return Date.today() > liab.Appeal_Deadline__c ? 'No' : 'Yes';
            }
        }
        public string violations { get; set; }
        public CitationWrapper(Liability__c l, boolean h) {
            liab = l;
            if (Test.isRunningTest())
                selected = true;
            else
                selected = false;
            highlight = h;
            violations = '';
        }
    }
    
}