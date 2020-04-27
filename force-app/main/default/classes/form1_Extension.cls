public with sharing class form1_Extension {
    
    public Form_1__c form1 {get;set;}

    public form1_Extension(apexPages.standardController controller){
        form1 = (Form_1__c)controller.getRecord();
    }
    
    public PageReference create607OnLoad(){
        /*if ( form1 == null || form1.Id == null ){
            Id i = apexPages.currentPage().getParameters().get('id');
            form1 = [Select Id, Classification__c, /*Position__c, Unit__c, Serial__c from Form_1__c where Id = :i limit 1];
        }
        x607__c x607 = new x607__c();
        x607.Form_1__c = form1.Id;
        insert x607;
        
        x607_Position_Modification__c pm = new x607_Position_Modification__c();
        pm.X607__c = x607.Id;
        //pm.Position__c = form1.Position__c;
        pm.Type__c = 'Modification';
        pm.Classification__c = form1.Classification__c;
        pm.Unit__c = form1.Unit__c;
        pm.Serial__c = form1.Serial__c;
        insert pm;
        
        PageReference p = new PageReference('/'+x607.Id);
        p.setRedirect(true);
        return p;*/
        
        if(form1.Id != null) {
            PageReference p = page.form607;
            p.getParameters().put('fid',form1.Id);
            p.setRedirect(true);
            return p;
        }
        else {
            return null;
        }
    }

}