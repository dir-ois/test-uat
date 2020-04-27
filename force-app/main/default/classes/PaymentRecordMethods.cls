/*********************************************************************

Author  :   DIR Salesforce Support Team 
Date    :   May 2018

Usage   :   This class is used to provide various methods on the Payment Record object.
                Triggered by PaymentRecordTrigger.cls

Comment :   As of this date, for other Apex code that messes with the Payment Records,
                see "requestChecks_Controller" and "CreateUWFCheckController" classes

*********************************************************************/
//TODO: Cashiering Rearchitecting Tier 2: Consider rolling up to CM.Funds_Drawn_on_Deposits__c through combined LP/JP object. Or not.
public class PaymentRecordMethods {
    
    public static void afterUpdateOrInsert(List<Payment_Record__c> triggerNew){
        /***********
        Sums up the Payment Amounts on the PRs on a Case where the PRs have had a check issued from them.
        Updates the DIR_Case__c.Funds_Drawn_on_Deposits__c field with this amount.
        ***********/
        
        //Set<Id> LPidSet = new Set<Id>();
        //Set<Id> JPidSet = new Set<Id>();
        Set<Id> payeeIdSet = new Set<Id>();
        //List<Liability_Payment__c> LPlist = new List<Liability_Payment__c>();
        //List<Judgment_Payment__c> JPlist = new List<Judgment_Payment__c>();
        List<Payee__c> payeeList = new List<Payee__c>();
        Set<Id> CMidSet = new Set<Id>();
        List<DIR_Case__c> CMlist = new List<DIR_Case__c>();
        List<Payment_Record__c> PRlist = new List<Payment_Record__c>();
        
        //System.debug('PRM.triggerNew: '+triggerNew);
        //query the greatgrandparent CMs for each PR in triggerNew
        for(Payment_Record__c PR : triggerNew) {
            System.debug('PRM.PR: '+PR);
            /*Rolling up funds from PRs through Payee records to CM.Funds_Drawn_on_Deposits__c, instead of through LPs/JPs, then CPs, to CM.Funds_Drawn_on_Deposits__c. Temporary fix for "parentless" PRs created for buybacks, until Cashiering Rearchitecting Tier 2*/
            if(PR.Payee__c != NULL){
                //System.debug('PRM.PR.Payee__r.Id: '+PR.Payee__r.Id);
                //System.debug('PRM.PR.Payee__c: '+PR.Payee__c);
                payeeIdSet.add(PR.Payee__c);
            }
            /* 
            if(PR.Liability_Payment__c != NULL){
                LPidSet.add(PR.Liability_Payment__c);
            }else if(PR.Judgment_Payment__c != NULL){
                JPidSet.add(PR.Judgment_Payment__c);
            }else{
                System.debug(System.LoggingLevel.ERROR, 'PaymentRecordMethods class: PR has no parent LP nor JP');
            }*/
        }
        //System.debug('PRM.payeeIdSet: '+payeeIdSet);
        
        /*LPlist = [SELECT Id, Case_Payment__c, Case_Payment__r.Case__c FROM Liability_Payment__c WHERE Id IN :LPidSet];
        JPlist = [SELECT Id, Case_Payment__c, Case_Payment__r.Case__c FROM Judgment_Payment__c WHERE Id IN :JPidSet];*/
        
        payeeList = [SELECT Id, Case_Management__c FROM Payee__c WHERE Id IN :payeeIdSet];
        //System.debug('PRM.payeeList: '+payeeList);
        /*
        for(Liability_Payment__c LP : LPlist){
            CMidSet.add(LP.Case_Payment__r.Case__c);
        }
        
        for(Judgment_Payment__c JP : JPlist){
            CMidSet.add(JP.Case_Payment__r.Case__c);
        }*/
        
        for(Payee__c payee : payeeList){
            CMidSet.add(payee.Case_Management__c);
        }
        
        CMlist = [SELECT Id, Funds_Drawn_on_Deposits__c FROM DIR_Case__c WHERE Id IN :CMidSet];
        
        //query ALL PRs under these CMs (triggerNew will not have all eligible PRs)
        PRlist = [SELECT Id, Check_Issued__c, Payment_Amount__c, Check__c, Check__r.Status__c,
                        Payee__c, Payee__r.Case_Management__c,
                        Liability_Payment__c, Liability_Payment__r.Case_Payment__r.Case__c,
                        Judgment_Payment__c, Judgment_Payment__r.Case_Payment__r.Case__c
                            FROM Payment_Record__c
                            WHERE Check__c != NULL
                                AND Payment_Amount__c != NULL
                                AND (
                                    Check__r.Status__c = 'Approved'
                                    OR Check__r.Status__c = 'Printed'
                                    OR Check__r.Status__c = 'UWF Allocation'
                                    //OR Check__r.Status__c = 'Uncleared' //'Cleared' and 'Uncleared' statuses never used per cashiering SMEs
                                    //OR Check__r.Status__c = 'Cleared'
                                    )
                                //AND ((Liability_Payment__c != NULL
                                //        AND Liability_Payment__r.Case_Payment__r.Case__c IN :CMidSet)
                                //    OR (Judgment_Payment__c != NULL
                                //        AND Judgment_Payment__r.Case_Payment__r.Case__c IN :CMidSet))
                                AND (Payee__c != NULL
                                    AND Payee__r.Case_Management__c IN :CMidSet)
                    ];
        
        //for each CM, sum it's PRs
        for(DIR_Case__c CM : CMlist){
            Decimal sumOfPRamounts = 0;
            
            for(Payment_Record__c PR : PRlist){
                if(PR.Payee__r.Case_Management__c == CM.Id){
                    sumOfPRamounts += PR.Payment_Amount__c;
                }
                /*
                if((PR.Liability_Payment__c != NULL && PR.Liability_Payment__r.Case_Payment__r.Case__c == CM.Id) ||
                    (PR.Judgment_Payment__c != NULL && PR.Judgment_Payment__r.Case_Payment__r.Case__c == CM.Id)){
                        sumOfPRamounts += PR.Payment_Amount__c;
                }*/
            }
            CM.Funds_Drawn_on_Deposits__c = sumOfPRamounts;
        }
        update CMlist;
    }
    
    public static void afterDelete(List<Payment_Record__c> triggerOld){
        /***********
        Sums up the Payment Amounts on the remaining PRs on a Case where the PRs have had a check issued from them.
        Updates the DIR_Case__c.Funds_Drawn_on_Deposits__c field with this amount.
        ***********/
        
        Set<Id> payeeIdSet = new Set<Id>();
        List<Payee__c> payeeList = new List<Payee__c>();
        Set<Id> CMidSet = new Set<Id>();
        List<DIR_Case__c> CMlist = new List<DIR_Case__c>();
        List<Payment_Record__c> PRlist = new List<Payment_Record__c>();
        
        //System.debug('PRM.triggerNew: '+triggerNew);
        //query the greatgrandparent CMs for each PR in triggerOld
        for(Payment_Record__c PR : triggerOld) {
            System.debug('PRM.PR: '+PR);
            /*Rolling up funds from PRs through Payee records to CM.Funds_Drawn_on_Deposits__c, instead of through LPs/JPs, then CPs, to CM.Funds_Drawn_on_Deposits__c. Temporary fix for "parentless" PRs created for buybacks, until Cashiering Rearchitecting Tier 2*/
            if(PR.Payee__c != NULL){
                //System.debug('PRM.PR.Payee__r.Id: '+PR.Payee__r.Id);
                //System.debug('PRM.PR.Payee__c: '+PR.Payee__c);
                payeeIdSet.add(PR.Payee__c);
            }
        }
        //System.debug('PRM.payeeIdSet: '+payeeIdSet);
        
        payeeList = [SELECT Id, Case_Management__c FROM Payee__c WHERE Id IN :payeeIdSet];
        //System.debug('PRM.payeeList: '+payeeList);
        
        for(Payee__c payee : payeeList){
            CMidSet.add(payee.Case_Management__c);
        }
        
        CMlist = [SELECT Id, Funds_Drawn_on_Deposits__c FROM DIR_Case__c WHERE Id IN :CMidSet];
        
        //query ALL PRs under these CMs (triggerOld will only have the PRs that have been deleted, not all the other remaining PRs on each case)
        PRlist = [SELECT Id, Check_Issued__c, Payment_Amount__c, Check__c, Check__r.Status__c,
                        Payee__c, Payee__r.Case_Management__c,
                        Liability_Payment__c, Liability_Payment__r.Case_Payment__r.Case__c,
                        Judgment_Payment__c, Judgment_Payment__r.Case_Payment__r.Case__c
                            FROM Payment_Record__c
                            WHERE Check__c != NULL
                                AND Payment_Amount__c != NULL
                                AND (
                                    Check__r.Status__c = 'Approved'
                                    OR Check__r.Status__c = 'Printed'
                                    OR Check__r.Status__c = 'UWF Allocation'
                                    //OR Check__r.Status__c = 'Uncleared' //'Cleared' and 'Uncleared' statuses never used per cashiering SMEs
                                    //OR Check__r.Status__c = 'Cleared'
                                )
                                AND (Payee__c != NULL
                                    AND Payee__r.Case_Management__c IN :CMidSet)
                    ];
        
        //for each CM, sum it's PRs
        for(DIR_Case__c CM : CMlist){
            Decimal sumOfPRamounts = 0;
            
            for(Payment_Record__c PR : PRlist){
                if(PR.Payee__r.Case_Management__c == CM.Id){
                    sumOfPRamounts += PR.Payment_Amount__c;
                }
            }
            CM.Funds_Drawn_on_Deposits__c = sumOfPRamounts;
        }
        update CMlist;
    }
}