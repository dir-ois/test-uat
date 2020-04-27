//Scheduled by the ScheduleCreateOAMTRecords class, q.v. Should be run on the 1st of each month for the month previous.
public class CreateOAMTRecords{
    // TODO: change this to a batch class if RCT and Check record amounts get too large
    public List<Office_Account_Monthly_Totals__c> OAMTsToInsert = new List<Office_Account_Monthly_Totals__c>();
    
    public void CreateOAMTRecords(){
        Date today = Date.today(); //Date this class is scheduled to run, which should be the 1st of each month for the month just previous
        if(Test.isRunningTest()){
            today = Date.parse('08/01/2019'); //test class has hard-coded dates
        }
        Date firstOfPreviousMonth = today.addMonths(-1).toStartOfMonth(); //first day of the month that the OAMT records are created FOR
        Date lastOfPreviousMonth = Date.newInstance(firstOfPreviousMonth.year(), firstOfPreviousMonth.month(), Date.daysInMonth(firstOfPreviousMonth.year(), firstOfPreviousMonth.month()));
        Date firstOf2MonthsPrevious = firstOfPreviousMonth.addMonths(-1).toStartOfMonth();
        Date lastOf2MonthsPrevious = Date.newInstance(firstOf2MonthsPrevious.year(), firstOf2MonthsPrevious.month(), Date.daysInMonth(firstOf2MonthsPrevious.year(), firstOf2MonthsPrevious.month()));
        
        List<Office_Account__c> OAs = [SELECT Id, Name FROM Office_Account__c];
        
        /*OAMT.Adjustments__c : Adjustment type TRNs deposited in the previous month. */
        List<Transaction__c> adjustmentTRNs = [SELECT Id, Name, Deposit_Date__c, Transaction_Type__c, Transaction_Sum__c, Office_Account__c
                                                FROM Transaction__c
                                                WHERE ((Deposit_Date__c >= :firstOfPreviousMonth AND Deposit_Date__c <= :lastOfPreviousMonth)
                                                        AND Transaction_Type__c = 'Adjustment')];
        
        /*OAMT.Deposited_Receipts__c : RCTs deposited in the previous month (including RCTs deposited AND returned in the previous month) */
        /*OAMT.Prior_Month_Returned_Receipts__c : RCTs returned in the previous month that were deposited prior to the previous month */
        List<Receipt__c> depositedOrReturnedRCTs = [SELECT Id, Name, Deposit_Date__c, Deposit_Account__c, Returned_Item__c, Returned_Date__c, Voided_Item__c, Status__c, Payment_Amount__c,
                                                        Transaction__c, Transaction__r.Id, Transaction__r.Deposit_Date__c, Transaction__r.Transaction_Type__c,
                                                        Transaction__r.Office_Account__c, Transaction__r.Office_Account__r.Id, Transaction__r.Office_Account__r.Name
                                                    FROM Receipt__c
                                                    WHERE (((Deposit_Date__c >= :firstOfPreviousMonth AND Deposit_Date__c <= :lastOfPreviousMonth)
                                                                AND (Status__c = 'Deposited'
                                                                    OR Status__c = 'Returned'))
                                                            OR((Deposit_Date__c <= :lastOf2MonthsPrevious)
                                                                AND(Returned_Date__c >= :firstOfPreviousMonth AND Returned_Date__c <= :lastOfPreviousMonth)
                                                                AND Returned_Item__c = TRUE))];
        
        /*OAMT.Disbursements__c : Printed or cleared status Checks issued in the previous month
        /*OAMT.Prior_Month_Voided_and_Canceled_Checks__c : Voided or canceled status Checks voided or canceled in the previous month, issued prior to the previous month */
        List<Check__c> printedOrVoidedChecks = [SELECT Id, Name, Status__c, Status_Date__c, Issue_Date__c, Amount__c, Office_Account__c, Office_Account__r.Id, Office_Account__r.Name
                                                FROM Check__c
                                                WHERE (((Issue_Date__c >= :firstOfPreviousMonth AND Issue_Date__c <= :lastOfPreviousMonth)
                                                        AND(Status__c = 'Printed' OR Status__c = 'Cleared'))
                                                    OR((Issue_Date__c <= :lastOf2MonthsPrevious)
                                                        AND(Status_Date__c >= :firstOfPreviousMonth AND Status_Date__c <= :lastOfPreviousMonth)
                                                        AND(Status__c = 'Voided' OR Status__c = 'Canceled')))];
        
        //Assumes previous OAMT records were created by this code on the 1st of the previous month
        List<Office_Account_Monthly_Totals__c> OAMTs = [SELECT Id, Name, CreatedDate, Office_Account__c, Date__c, Ending_Balance__c, Adjustments__c, Prior_Month_Returned_Receipts__c,
                                                            Prior_Month_Voided_and_Canceled_Checks__c, Deposited_Receipts__c, Disbursements__c, Month_Year__c
                                                        FROM Office_Account_Monthly_Totals__c
                                                        WHERE (Date__c = :lastOf2MonthsPrevious)];
        
        for(Office_Account__c OA : OAs){
            for(Office_Account_Monthly_Totals__c OAMT : OAMTs){
                
                if(OA.Id == OAMT.Office_Account__c){
                    Decimal sumOfDepositedRCTs = 0.00;
                    Decimal sumOfReturnedRCTs = 0.00;
                    Decimal sumOfPrintedChecks = 0.00;
                    Decimal sumOfVoidedChecks = 0.00;
                    Decimal sumOfAdjustmentTRNs = 0.00;

                    for(Receipt__c RCT : depositedOrReturnedRCTs){
                        if(RCT.Transaction__r.Office_Account__c == OAMT.Office_Account__c){
                            if(RCT.Deposit_Date__c >= firstOfPreviousMonth && RCT.Deposit_Date__c <= lastOfPreviousMonth){
                                sumOfDepositedRCTs += RCT.Payment_Amount__c;
                            }else{
                                sumOfReturnedRCTs += RCT.Payment_Amount__c;
                            }
                        }
                    }
                    for(Check__c check : printedOrVoidedChecks){
                        if(check.Office_Account__c == OAMT.Office_Account__c){
                            if(check.Status__c == 'Printed' || check.Status__c == 'Cleared'){
                                sumOfPrintedChecks += check.Amount__c;
                            }else{
                                sumOfVoidedChecks += check.Amount__c;
                            }
                        }
                    }
                    for(Transaction__c trn : adjustmentTRNs){
                        if(trn.Office_Account__c == OAMT.Office_Account__c){
                            sumOfAdjustmentTRNs += trn.Transaction_Sum__c;
                        }
                    }

                    Office_Account_Monthly_Totals__c newOAMT = new Office_Account_Monthly_Totals__c(
                        Office_Account__c = OA.Id,
                        Date__c = lastOfPreviousMonth,
                        Prior_Month_Starting_Balance__c = OAMT.Ending_Balance__c,
                        Adjustments__c = sumOfAdjustmentTRNs,
                        Prior_Month_Returned_Receipts__c = sumOfReturnedRCTs,
                        Prior_Month_Voided_and_Canceled_Checks__c = sumOfVoidedChecks,
                        Deposited_Receipts__c = sumOfDepositedRCTs,
                        Disbursements__c = sumOfPrintedChecks
                    );
                    OAMTsToInsert.add(newOAMT);
                }
            }
        }
        insert OAMTsToInsert;
    }
}