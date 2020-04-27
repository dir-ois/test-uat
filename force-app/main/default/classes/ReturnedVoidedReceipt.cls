/*************************************************************************************************
Class     :  ReturnedVoidedReceipt.cls
Created   :  
Modified  :
Objective :  This class creates negative amount cashiering object records (Receipt__c,
                Case_Payment__c, Liability_Payment__c, Judgment_Payment__c, Payment_Record__c)
                to negate Receipt__c records marked returned or voided.
                
TODO        TRN stuff commented out. May be needed for voids, ask business.
            Chatter stuff commented out. Ask business if needed.

*************************************************************************************************/

public class ReturnedVoidedReceipt{
    
    /* This validation was moved to ReceiptTrigger class
    
    public static void runForrestRun(List<Receipt__c> rctList, Map<ID, Receipt__c> oldRctMap){
        //Boolean runAutomation = false;
        //Boolean returnedItem = false;
        //Booleas voidedItem = false;

        for(Receipt__c rct : rctList){
            if(rct.Returned_Item__c == true && oldRctMap.get(rct.Id).Returned_Item__c == false){
                System.debug('returned');
                returnReceipts(rctList);
            }
            if(rct.Voided_Item__c == true && oldRctMap.get(rct.Id).Voided_Item__c == false){
                System.debug('voided');
                voidReceipts(rctList);
            }
        }
    } */


    @future
    @TestVisible
    /*Voiding very similar to Returning. Negative records created and linked. Differences:
    1 - Void: original RCT removed from TRN. Return: original RCT not removed from TRN. TODO: make return RCT removal dependant on TRN "Pending" or "Deposited".
    2 - Void: negative CP rolls up to CM.Deposited_Funds__c. Return: negative CP does not roll up to CM.Deposited_Funds__c.
    3 - Void: negative CP.Status__c same as original CP.Status__c. Return: negative CP.Status__c = "New". TODO: Verify "New", or maybe a new status value? */
    public static void voidReceipts(List<Id> rctIdList){
        List<Receipt__c> rctList = new List<Receipt__c>();
        List<Case_Payment__c> cpList = new List<Case_Payment__c>();
        List<Id> cpIdList = new List<Id>();
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        List<Id> lpIdList = new List<Id>();
        List<Applied_Accounting_Code__c> AeACList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        //List<Payment_Record__c> prList = new List<Payment_Record__c>(); //PR processing reserved for Tier 2
        
        rctList = [SELECT Id, Payor__c, Payment_Amount__c, Deposit_Account__c, Date_Received__c, Instrument_Number__c, Payment_Type__c, Bank_Location__c, Payment_Exchange__c,
                        Senior_Deputy__c, Status__c, Office_Unit__c, Returned_Voided_Receipt__c, Adjustment__c,
                        
                        (SELECT Id, Name, Receipt__c, RecordTypeId, Case__c, Payment_Amount__c, Payment_Plan__c, Transmittal__c, Status__c, Restitution_Fund__c,
                                Amount_Payable_to_Employees__c, Deduction_Payment__c, Public_Works_Penalties__c, Apprenticeship_Penalties__c,
                                California_Apprenticeship_Council__c, CA_Apprenticeship_Council_Craft__c, CA_Apprenticeship_County__c,
                                CPR_Only__c, CPR_Refund__c, CMU_Reimbursement__c, DIR_Attorney_Fees__c, DIR_Attorney_Fees_Explanation__c,
                                Hold_Amount__c, CPR_Only_Pay_Business__c, CPR_Refund_Pay_Business__c, Other_Refund__c
                            FROM Case_Payments__r)
                    
                    FROM Receipt__c
                    WHERE Id IN :rctIdList];
        
        for(Receipt__c rct : rctList){
            cpList.addAll(rct.Case_Payments__r);
        }
        
        for(Case_Payment__c cp : cpList){
            cpIdList.add(cp.Id);
        }
        
        lpList = [SELECT Id, Name, Case_Payment__c, Liability__c, Assessment__c, Case_Violation__c, Payment_Amount__c, Payment_Applied_To__c,
                        Payment_on_Behalf_of__c, Payment_Type__c, Recommended_Allocation__c,
                        
                        (SELECT Id, Name, Added_Manually__c, Check_Count__c, Liability_Payment__c, Receipt__c, Accounting_Code__c,
                                Violation_Accounting_Code__c, Payment_Type__c, Amount__c, Penalty_Amt__c, Interest_Amt__c
                            FROM Applied_Accounting_Codes__r)
                        
                        //(SELECT Id, Name //Payment Record processing reserved for Tier 2
                        //  FROM Payment_Records__r)
                    
                    FROM Liability_Payment__c
                    WHERE Case_Payment__c IN :cpIdList];
        
        for(Liability_Payment__c lp : lpList){
            AeACList.addAll(lp.Applied_Accounting_Codes__r);
            //prList.addAll(lp.Payment_Records__r);
        }
        
        jpList = [SELECT Id, Name, Case_Payment__c, Judgment__c, Allocated_Amount__c, Apply_Payment_To__c, Payment_On_Behalf_Of__c, Recommended_Amount__c, Status__c
                        
                        //(SELECT Id, Name //Payment Record processing reserved for Tier 2
                        //  FROM Payment_Records__r)
                    
                    FROM Judgment_Payment__c
                    WHERE Case_Payment__c IN :cpIdList];
        
        //for(Judgment_Payment__c jp : jpList){
        //  prList.addAll(jp.Payment_Records__r);
        //}
        
        
        //make cashiering object records in negative amounts
        List<Receipt__c> rctsToUpsertList = new List<Receipt__c>();
        List<Case_Payment__c> cpsToUpsertList = new List<Case_Payment__c>();
        List<Liability_Payment__c> lpsToInsertList = new List<Liability_Payment__c>();
        List<Applied_Accounting_Code__c> AeACsToInsertList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpsToInsertList = new List<Judgment_Payment__c>();
        //List<Payment_Record__c> prsToInsertList = new List<Payment_Record__c>();
        
        for(Receipt__c rct : rctList){
            Receipt__c newNegativeRct = new Receipt__c(
                Payor__c = rct.Payor__c,
                Payment_Amount__c = -rct.Payment_Amount__c,
                Deposit_Account__c = rct.Deposit_Account__c,
                Date_Received__c = Date.today(), //the negated record's Date Received is the original record's Date Returned
                Instrument_Number__c = rct.Instrument_Number__c,
                Payment_Type__c = rct.Payment_Type__c,
                Bank_Location__c = rct.Bank_Location__c,
                Payment_Exchange__c = rct.Payment_Exchange__c,
                Senior_Deputy__c = rct.Senior_Deputy__c,
                Status__c = 'New', //TODO: or maybe a new status?
                Office_Unit__c = rct.Office_Unit__c,
                Returned_Voided_Receipt__c = rct.Id,
                Adjustment__c = true
            );
            rctsToUpsertList.add(newNegativeRct);
            rct.Transaction__c = null;
            rct.Status__c = 'Voided';
            rct.Status_Date__c = Date.today();
            rctsToUpsertList.add(rct);
        }
        upsert rctsToUpsertList;
        
        for(Case_Payment__c cp : cpList){
            for(Receipt__c newNegativeRct : rctsToUpsertList){
                if(newNegativeRct.Status__c != 'Voided'){ //original RCT was added to rctsToUpsertList for DML convenience, so we're filtering it out here
                    if(cp.Receipt__c == newNegativeRct.Returned_Voided_Receipt__c && cp.Status__c == 'Posted'){ //only create a negative CP record (and thus negatives for it's children) if the original CP was Posted.
                        Case_Payment__c newNegativeCp = new Case_Payment__c(
                            Receipt__c = newNegativeRct.Id,
                            RecordTypeId = cp.RecordTypeId,
                            Case__c = cp.Case__c,
                            Payment_Amount__c = cp.Payment_Amount__c == null ? null : -cp.Payment_Amount__c,
                            Payment_Plan__c = cp.Payment_Plan__c,
                            //Transmittal__c = cp.Transmittal__c, //or allow newNegativeCp to be added to a new Transmittal? or no Transmittal
                            Returned_Voided_Case_Payment__c = cp.Id,
                            Status__c = cp.Status__c, //TODO: this ends up with the newNegativeCp.Status being Void, as is what the original CP status gets changed to below. the intent is for this to be the original CPs original status.
                            Restitution_Fund__c = cp.Restitution_Fund__c,
                            Amount_Payable_to_Employees__c = cp.Amount_Payable_to_Employees__c == null ? null : -cp.Amount_Payable_to_Employees__c,
                            Deduction_Payment__c = cp.Deduction_Payment__c,
                            Public_Works_Penalties__c = cp.Public_Works_Penalties__c == null ? null : -cp.Public_Works_Penalties__c,
                            Apprenticeship_Penalties__c = cp.Apprenticeship_Penalties__c == null ? null : -cp.Apprenticeship_Penalties__c,
                            California_Apprenticeship_Council__c = cp.California_Apprenticeship_Council__c == null ? null : -cp.California_Apprenticeship_Council__c,
                            CA_Apprenticeship_Council_Craft__c = cp.CA_Apprenticeship_Council_Craft__c == null ? null : -cp.CA_Apprenticeship_Council_Craft__c,
                            CA_Apprenticeship_County__c = cp.CA_Apprenticeship_County__c == null ? null : -cp.CA_Apprenticeship_County__c,
                            CPR_Only__c = cp.CPR_Only__c == null ? null : -cp.CPR_Only__c,
                            CPR_Refund__c = cp.CPR_Refund__c == null ? null : -cp.CPR_Refund__c,
                            CMU_Reimbursement__c = cp.CMU_Reimbursement__c == null ? null : -cp.CMU_Reimbursement__c,
                            DIR_Attorney_Fees__c = cp.DIR_Attorney_Fees__c == null ? null : -cp.DIR_Attorney_Fees__c,
                            DIR_Attorney_Fees_Explanation__c = cp.DIR_Attorney_Fees_Explanation__c,
                            Hold_Amount__c = cp.Hold_Amount__c == null ? null : -cp.Hold_Amount__c,
                            CPR_Only_Pay_Business__c = cp.CPR_Only_Pay_Business__c,
                            CPR_Refund_Pay_Business__c = cp.CPR_Refund_Pay_Business__c,
                            Other_Refund__c = cp.Other_Refund__c == null ? null : -cp.Other_Refund__c
                        );
                        cpsToUpsertList.add(newNegativeCp);
                    }
                }
            }
            cp.Status__c = 'Voided';
            cpsToUpsertList.add(cp);
        }
        upsert cpsToUpsertList;
        
        
        for(Liability_Payment__c lp : lpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Voided'){
                    if(lp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Liability_Payment__c newNegativeLp = new Liability_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Liability__c = lp.Liability__c,
                            Assessment__c = lp.Assessment__c,
                            Case_Violation__c = lp.Case_Violation__c,
                            Payment_Amount__c = lp.Payment_Amount__c == null ? null : -lp.Payment_Amount__c,
                            Payment_Applied_To__c = lp.Payment_Applied_To__c,
                            Payment_on_Behalf_of__c = lp.Payment_on_Behalf_of__c,
                            Payment_Type__c = lp.Payment_Type__c,
                            Recommended_Allocation__c = lp.Recommended_Allocation__c == null ? null : -lp.Recommended_Allocation__c,
                            Returned_Voided_Liability_Payment__c = lp.Id
                        );
                        lpsToInsertList.add(newNegativeLp);
                    }
                }
            }
        }
        insert lpsToInsertList;
        
        
        for(Applied_Accounting_Code__c AeAC : AeACList){
            for(Liability_Payment__c newNegativeLp : lpsToInsertList){
                if(AeAC.Liability_Payment__c == newNegativeLp.Returned_Voided_Liability_Payment__c){
                    Applied_Accounting_Code__c newNegativeAeAC = new Applied_Accounting_Code__c(
                        Accounting_Code__c = AeAC.Accounting_Code__c,
                        Added_Manually__c = AeAC.Added_Manually__c,
                        Amount__c = AeAC.Amount__c == null ? null : -AeAC.Amount__c,
                        Check_Count__c = AeAC.Check_Count__c == null ? null : AeAC.Check_Count__c, //verify this with business
                        Liability_Payment__c = newNegativeLp.Id,
                        Payment_Type__c = AeAC.Payment_Type__c,
                        Returned_Voided_Applied_Accounting_Code__c = AeAC.Id,
                        Violation_Accounting_Code__c = AeAC.Violation_Accounting_Code__c
                    );
                    AeACsToInsertList.add(newNegativeAeAC);
                }
            }
        }
        insert AeACsToInsertList;
        
        
        for(Judgment_Payment__c jp : jpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Voided'){
                    if(jp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Judgment_Payment__c newNegativeJp = new Judgment_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Judgment__c = jp.Judgment__c,
                            Allocated_Amount__c = jp.Allocated_Amount__c == null ? null : -jp.Allocated_Amount__c,
                            Apply_Payment_To__c = jp.Apply_Payment_To__c,
                            Payment_On_Behalf_Of__c = jp.Payment_On_Behalf_Of__c,
                            Recommended_Amount__c = jp.Recommended_Amount__c == null ? null : -jp.Recommended_Amount__c,
                            Status__c = 'New', //TODO: or other status to be defined
                            Returned_Voided_Judgment_Payment__c = jp.Id
                        );
                        jpsToInsertList.add(newNegativeJp);
                    }
                }
            }
        }
        insert jpsToInsertList;
        
        
        /* PRs processing reserved for Tier 2
        for(Payment_Record__c pr: prList){
            for(Liability_Payment__c newNegativeLp : lpsToInsertList){
                if(pr.Liability_Payment__c == newNegativeLp.Returned_Voided_Liability_Payment__c){
                    Payment_Record__c newNegativePr = new Payment_Record__c(
                        Liability_Payment__c = newNegativeLp.Id,
                        Payee__c = pr.Payee__c,
                        Payment_Amount__c = -pr.Payment_Amount__c,
                        Check_Issued__c = pr.Check_Issued__c,
                        Returned_Voided_Payment_Record__c = pr.Id
                    );
                    prsToInsertList.add(newNegativePr);
                }
            }
        }
        
        for(Payment_Record__c pr: prList){
            for(Judgment_Payment__c newNegativeJp : jpsToInsertList){
                if(pr.Judgment_Payment__c == newNegativeJp.Returned_Voided_Judgment_Payment__c){
                    Payment_Record__c newNegativePr = new Payment_Record__c(
                        Judgment_Payment__c = newNegativeJp.Id,
                        Payee__c = pr.Payee__c,
                        Payment_Amount__c = -pr.Payment_Amount__c,
                        Check_Issued__c = pr.Check_Issued__c,
                        Returned_Voided_Payment_Record__c = pr.Id
                    );
                    prsToInsertList.add(newNegativePr);
                }
            }
        }
        insert prsToInsertList; */
    }


    @future
    @TestVisible
    /*Voiding very similar to Returning. Negative records created and linked. Differences:
    1 - Void: original RCT removed from TRN. Return: original RCT not removed from TRN. TODO: make return RCT removal dependent on TRN "Pending" or "Deposited".
    2 - Void: negative CP rolls up to CM.Deposited_Funds__c. Return: negative CP does not roll up to CM.Deposited_Funds__c.
    3 - Void: negative CP.Status__c same as original CP.Status__c. Return: negative CP.Status__c = "New". TODO: Verify "New", or maybe a new status value? */
    public static void returnReceipts(List<Id> rctIdList){
        Map<Id, Transaction__c> trnMap;
        Set<Id> trnIdSet = new Set<Id>();
        List<Receipt__c> rctList = new List<Receipt__c>();
        List<Case_Payment__c> cpList = new List<Case_Payment__c>();
        List<Id> cpIdList = new List<Id>();
        List<Liability_Payment__c> lpList = new List<Liability_Payment__c>();
        List<Applied_Accounting_Code__c> AeACList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpList = new List<Judgment_Payment__c>();
        //List<Payment_Record__c> prList = new List<Payment_Record__c>(); //PR processing reserved for Tier 2
        
        rctList = [SELECT Id, Payor__c, Payment_Amount__c, Deposit_Account__c, Date_Received__c, Instrument_Number__c, Payment_Type__c, Bank_Location__c, Payment_Exchange__c,
                        Senior_Deputy__c, Status__c, Office_Unit__c, Returned_Voided_Receipt__c, Adjustment__c, Transaction__c, Returned_Date__c,
                        
                        (SELECT Id, Name, Receipt__c, RecordTypeId, Case__c, Payment_Amount__c, Payment_Plan__c, Transmittal__c, Status__c, Restitution_Fund__c,
                                Amount_Payable_to_Employees__c, Deduction_Payment__c, Public_Works_Penalties__c, Apprenticeship_Penalties__c,
                                California_Apprenticeship_Council__c, CA_Apprenticeship_Council_Craft__c, CA_Apprenticeship_County__c,
                                CPR_Only__c, CPR_Refund__c, CMU_Reimbursement__c, DIR_Attorney_Fees__c, DIR_Attorney_Fees_Explanation__c,
                                Hold_Amount__c, CPR_Only_Pay_Business__c, CPR_Refund_Pay_Business__c, Other_Refund__c
                            FROM Case_Payments__r)
                    
                    FROM Receipt__c
                    WHERE Id IN :rctIdList];
        
        
        for(Receipt__c rct : rctList){
            trnIdSet.add(rct.Transaction__c);
            cpList.addAll(rct.Case_Payments__r);
        }
        
        trnMap = new Map<Id, Transaction__c>([SELECT Id, Name, Office_Account__c, Business_Unit__c, Transaction_Status__c
                                                FROM Transaction__c
                                                WHERE Id IN :trnIdSet]);
        
        for(Case_Payment__c cp : cpList){
            cpIdList.add(cp.Id);
        }
        
        lpList = [SELECT Id, Name, Case_Payment__c, Liability__c, Assessment__c, Case_Violation__c, Payment_Amount__c, Payment_Applied_To__c,
                        Payment_on_Behalf_of__c, Payment_Type__c, Recommended_Allocation__c,
                        
                        (SELECT Id, Name, Added_Manually__c, Check_Count__c, Liability_Payment__c, Receipt__c, Accounting_Code__c,
                                Violation_Accounting_Code__c, Payment_Type__c, Amount__c, Penalty_Amt__c, Interest_Amt__c
                            FROM Applied_Accounting_Codes__r)
                        
                        //(SELECT Id, Name //Payment Record processing reserved for Tier 2
                        //  FROM Payment_Records__r)
                    
                    FROM Liability_Payment__c
                    WHERE Case_Payment__c IN :cpIdList];
        
        for(Liability_Payment__c lp : lpList){
            AeACList.addAll(lp.Applied_Accounting_Codes__r);
        }
        
        jpList = [SELECT Id, Name, Case_Payment__c, Judgment__c, Allocated_Amount__c, Apply_Payment_To__c, Payment_On_Behalf_Of__c, Recommended_Amount__c, Status__c
                
                //(SELECT Id, Name //Payment Record processing reserved for Tier 2
                //  FROM Payment_Records__r)
            
            FROM Judgment_Payment__c
            WHERE Case_Payment__c IN :cpIdList];
        
        //for(Judgment_Payment__c jp : jpList){
        //  prList.addAll(jp.Payment_Records__r);
        //}
        
        
        
        //make cashiering object records in negative amounts
        //List<Transaction__c> trnsToInsertList = new List<Transaction__c>();
        List<Receipt__c> rctsToUpsertList = new List<Receipt__c>();
        List<Case_Payment__c> cpsToUpsertList = new List<Case_Payment__c>();
        List<Liability_Payment__c> lpsToInsertList = new List<Liability_Payment__c>();
        List<Applied_Accounting_Code__c> AeACsToInsertList = new List<Applied_Accounting_Code__c>();
        List<Judgment_Payment__c> jpsToInsertList = new List<Judgment_Payment__c>();
        //List<Payment_Record__c> prsToInsertList = new List<Payment_Record__c>();
        
        for(Receipt__c rct : rctList){
            /*if(rct.Transaction__c != null){ //TODO: check with business: don't create create a negative TRN for Returns, but for Voids?
                System.debug('### rct.Transaction__c = '+rct.Transaction__c);
                System.debug('### trnMap.get(rct.Transaction__c).Office_Account__c = '+trnMap.get(rct.Transaction__c).Office_Account__c);
                System.debug('### rct.Transaction__r.Office_Account__c = '+rct.Transaction__r.Office_Account__c);
                
                Transaction__c newNegativeTrn = new Transaction__c(
                    Office_Account__c = trnMap.get(rct.Transaction__c).Office_Account__c,
                    Transaction_Type__c = 'Adjustment',
                    Transaction_Status__c = 'Adjusted',
                    Other_Amount__c = -rct.Payment_Amount__c,
                    Other_Amount_Description__c = 'Returned//Voided Receipt: ' + rct.Name,
                    Adjustment_Reason__c = 'Returned//Voided Receipt: ' + rct.Name,
                    Business_Unit__c = trnMap.get(rct.Transaction__c).Business_Unit__c,
                    Original_Transaction__c = rct.Transaction__c
                );
                
                System.debug('newNegativeTrn.Original_Transaction__c = '+newNegativeTrn.Original_Transaction__c);
                trnsToInsertList.add(newNegativeTrn);
            }*/
            
            Receipt__c newNegativeRct = new Receipt__c(
                Payor__c = rct.Payor__c,
                Payment_Amount__c = -rct.Payment_Amount__c,
                Deposit_Account__c = rct.Deposit_Account__c,
                Date_Received__c = Date.today(), //the negated record's Date Received is the original record's Date Returned
                Instrument_Number__c = rct.Instrument_Number__c,
                Payment_Type__c = rct.Payment_Type__c,
                Bank_Location__c = rct.Bank_Location__c,
                Payment_Exchange__c = rct.Payment_Exchange__c,
                Senior_Deputy__c = rct.Senior_Deputy__c,
                Status__c = 'New', //TODO: or maybe a new status?
                Office_Unit__c = rct.Office_Unit__c,
                Returned_Voided_Receipt__c = rct.Id,
                Adjustment__c = true
            );
            rctsToUpsertList.add(newNegativeRct);
            
            rct.Status__c = 'Returned'; //this status not changed here because it interferes with a validation rule on the RCT. Updated below in separate DML
            rct.Status_Date__c = Date.today();
            rct.Returned_Date__c = Date.today();
            
            if(!trnMap.isEmpty() && trnMap.get(rct.Transaction__c).Transaction_Status__c == 'Pending'){ //if TRN is deposited, don't remove the RCT
                rct.Transaction__c = null;
            }
            rctsToUpsertList.add(rct);
            
            
        }
        /*insert trnsToInsertList; */
        
        
        //If an original returned/voided RCT and a newNegativeTrn point to the same original TRN, AND the newNegativeRct and newNegativeTrn have the same amounts,
        // they can be linked, then the newNegativeTrn is removed from the list so another newNegativeRct can't be linked to it.
        //Using integer iterator because List.remove() only works with indices.
        /*for(Receipt__c newNegativeRct : rctsToInsertList){
            for(Integer i = trnsToInsertList.size() - 1; i >= 0; i--){
                if(newNegativeRct.Returned_Voided_Receipt__r.Transaction__c == trnsToInsertList[i].Original_Transaction__c &&
                    newNegativeRct.Payment_Amount__c == trnsToInsertList[i].Other_Amount__c){
                    newNegativeRct.Transaction__c = trnsToInsertList[i].Id;
                    trnsToInsertList.remove(i); //If a TRN has a child RCT attached to it, we don't want it available to have another child RCT attached to it.
                }
            }
        }*/
        upsert rctsToUpsertList;
        //upsert rctList; //no DML needed-Trigger.new gets updated automatically
        
        
        for(Case_Payment__c cp : cpList){
            for(Receipt__c newNegativeRct : rctsToUpsertList){
                if(newNegativeRct.Status__c != 'Returned'){ //original RCT was added to rctsToUpsertList for DML convenience, so we're filtering it out here
                    if(cp.Receipt__c == newNegativeRct.Returned_Voided_Receipt__c){
                        Case_Payment__c newNegativeCp = new Case_Payment__c(
                            Receipt__c = newNegativeRct.Id,
                            RecordTypeId = cp.RecordTypeId,
                            Case__c = cp.Case__c,
                            Payment_Amount__c = cp.Payment_Amount__c == null ? null : -cp.Payment_Amount__c,
                            Payment_Plan__c = cp.Payment_Plan__c,
                            Transmittal__c = cp.Transmittal__c, //or allow newNegativeCp to be added to a new Transmittal? or no Tr
                            Returned_Voided_Case_Payment__c = cp.Id,
                            Status__c = 'New', //TODO: or another status?
                            Restitution_Fund__c = cp.Restitution_Fund__c,
                            Amount_Payable_to_Employees__c = cp.Amount_Payable_to_Employees__c == null ? null : -cp.Amount_Payable_to_Employees__c,
                            Deduction_Payment__c = cp.Deduction_Payment__c,
                            Public_Works_Penalties__c = cp.Public_Works_Penalties__c == null ? null : -cp.Public_Works_Penalties__c,
                            Apprenticeship_Penalties__c = cp.Apprenticeship_Penalties__c == null ? null : -cp.Apprenticeship_Penalties__c,
                            California_Apprenticeship_Council__c = cp.California_Apprenticeship_Council__c == null ? null : -cp.California_Apprenticeship_Council__c,
                            CA_Apprenticeship_Council_Craft__c = cp.CA_Apprenticeship_Council_Craft__c == null ? null : -cp.CA_Apprenticeship_Council_Craft__c,
                            CA_Apprenticeship_County__c = cp.CA_Apprenticeship_County__c == null ? null : -cp.CA_Apprenticeship_County__c,
                            CPR_Only__c = cp.CPR_Only__c == null ? null : -cp.CPR_Only__c,
                            CPR_Refund__c = cp.CPR_Refund__c == null ? null : -cp.CPR_Refund__c,
                            CMU_Reimbursement__c = cp.CMU_Reimbursement__c == null ? null : -cp.CMU_Reimbursement__c,
                            DIR_Attorney_Fees__c = cp.DIR_Attorney_Fees__c == null ? null : -cp.DIR_Attorney_Fees__c,
                            DIR_Attorney_Fees_Explanation__c = cp.DIR_Attorney_Fees_Explanation__c,
                            Hold_Amount__c = cp.Hold_Amount__c == null ? null : -cp.Hold_Amount__c,
                            CPR_Only_Pay_Business__c = cp.CPR_Only_Pay_Business__c,
                            CPR_Refund_Pay_Business__c = cp.CPR_Refund_Pay_Business__c,
                            Other_Refund__c = cp.Other_Refund__c == null ? null : -cp.Other_Refund__c
                        );
                        cpsToUpsertList.add(newNegativeCp);
                    }
                }
            }
            cp.Status__c = 'Returned';
            cpsToUpsertList.add(cp);
        }
        upsert cpsToUpsertList;
        
        
        for(Liability_Payment__c lp : lpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Returned'){
                    if(lp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Liability_Payment__c newNegativeLp = new Liability_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Liability__c = lp.Liability__c,
                            Assessment__c = lp.Assessment__c,
                            Case_Violation__c = lp.Case_Violation__c,
                            Payment_Amount__c = lp.Payment_Amount__c == null ? null : -lp.Payment_Amount__c,
                            Payment_Applied_To__c = lp.Payment_Applied_To__c,
                            Payment_on_Behalf_of__c = lp.Payment_on_Behalf_of__c,
                            Payment_Type__c = lp.Payment_Type__c,
                            Recommended_Allocation__c = lp.Recommended_Allocation__c == null ? null : -lp.Recommended_Allocation__c,
                            Returned_Voided_Liability_Payment__c = lp.Id
                        );
                        lpsToInsertList.add(newNegativeLp);
                    }
                }
            }
        }
        insert lpsToInsertList;
        
        
        for(Applied_Accounting_Code__c AeAC : AeACList){
            for(Liability_Payment__c newNegativeLp : lpsToInsertList){
                if(AeAC.Liability_Payment__c == newNegativeLp.Returned_Voided_Liability_Payment__c){
                    Applied_Accounting_Code__c newNegativeAeAC = new Applied_Accounting_Code__c(
                        Accounting_Code__c = AeAC.Accounting_Code__c,
                        Added_Manually__c = AeAC.Added_Manually__c,
                        Amount__c = AeAC.Amount__c == null ? null : -AeAC.Amount__c,
                        Check_Count__c = AeAC.Check_Count__c == null ? null : AeAC.Check_Count__c, //verify this with business
                        Liability_Payment__c = newNegativeLp.Id,
                        Payment_Type__c = AeAC.Payment_Type__c,
                        Returned_Voided_Applied_Accounting_Code__c = AeAC.Id,
                        Violation_Accounting_Code__c = AeAC.Violation_Accounting_Code__c
                    );
                    AeACsToInsertList.add(newNegativeAeAC);
                }
            }
        }
        insert AeACsToInsertList;
        
        
        for(Judgment_Payment__c jp : jpList){
            for(Case_Payment__c newNegativeCp : cpsToUpsertList){
                if(newNegativeCp.Status__c != 'Returned'){
                    if(jp.Case_Payment__c == newNegativeCp.Returned_Voided_Case_Payment__c){
                        Judgment_Payment__c newNegativeJp = new Judgment_Payment__c(
                            Case_Payment__c = newNegativeCp.Id,
                            Judgment__c = jp.Judgment__c,
                            Allocated_Amount__c = jp.Allocated_Amount__c == null ? null : -jp.Allocated_Amount__c,
                            Apply_Payment_To__c = jp.Apply_Payment_To__c,
                            Payment_On_Behalf_Of__c = jp.Payment_On_Behalf_Of__c,
                            Recommended_Amount__c = jp.Recommended_Amount__c == null ? null : -jp.Recommended_Amount__c,
                            Status__c = 'New', //TODO: or other status to be defined
                            Returned_Voided_Judgment_Payment__c = jp.Id
                        );
                        jpsToInsertList.add(newNegativeJp);
                    }
                }
            }
        }
        insert jpsToInsertList;
        
        
        
        /* PRs processing reserved for Tier 2
        for(Payment_Record__c pr: prList){
            for(Liability_Payment__c newNegativeLp : lpsToInsertList){
                if(pr.Liability_Payment__c == newNegativeLp.Returned_Voided_Liability_Payment__c){
                    Payment_Record__c newNegativePr = new Payment_Record__c(
                        Liability_Payment__c = newNegativeLp.Id,
                        Payee__c = pr.Payee__c,
                        Payment_Amount__c = -pr.Payment_Amount__c,
                        Check_Issued__c = pr.Check_Issued__c,
                        Returned_Voided_Payment_Record__c = pr.Id
                    );
                    prsToInsertList.add(newNegativePr);
                }
            }
        }
        
        for(Payment_Record__c pr: prList){
            for(Judgment_Payment__c newNegativeJp : jpsToInsertList){
                if(pr.Judgment_Payment__c == newNegativeJp.Returned_Voided_Judgment_Payment__c){
                    Payment_Record__c newNegativePr = new Payment_Record__c(
                        Judgment_Payment__c = newNegativeJp.Id,
                        Payee__c = pr.Payee__c,
                        Payment_Amount__c = -pr.Payment_Amount__c,
                        Check_Issued__c = pr.Check_Issued__c,
                        Returned_Voided_Payment_Record__c = pr.Id
                    );
                    prsToInsertList.add(newNegativePr);
                }
            }
        }
        insert prsToInsertList; */
        
        
        /*
        //Hack to get around validation rule RCT.Cant_Be_Returned_If_Not_Deposited. Tried performing returning in AfterUpdate, still didn't work. TODO.
        for(Receipt__c rct : rctList){
            rct.Status__c = 'Deposited';
        }
        update rctList;
        
        for(Receipt__c rct : rctList){
            rct.Status__c = 'Returned';
            rct.Status_Date__c = Date.today();
            rct.Returned_Date__c = Date.today();
            
            if(!trnMap.isEmpty() && trnMap.get(rct.Transaction__c).Transaction_Status__c == 'Pending'){ //if TRN is deposited, don't remove the RCT
                rct.Transaction__c = null;
            }
        }
        update rctList;*/
    }
    
    
    
    
//Chatter methods, if needed. See original ReturnedItemAutomation.cls for use
/*      

    private static void postChatterReturnToChatter(List<ConnectApi.BatchInput> posts){
        system.debug('@@@Chatter Posts: '+posts);
        if( test.isRunningTest() ) return;
        ConnectApi.ChatterFeeds.postFeedElementBatch(null, posts);
    }

    private static ConnectApi.BatchInput generateReturnToChatter(Id userToMentionId, String postText, Id objId){ 

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        if(!String.isBlank(userToMentionId)){
            mentionSegmentInput.id = userToMentionId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        }
        
        textSegmentInput.text = ' - '+postText;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = objId;
        
        return new ConnectApi.BatchInput(feedItemInput);
    } */
}