({
    doInit : function(component, event, helper) {
        helper.initPicklists(component);
    },
    
    addBankFields: function(component, event, helper){
        var inputBankDate = component.find("bankDate");
        var selected = component.find("depositAccountId").get("v.value"); 
        if(selected === "108"){
            $("#BankDepositDateIdField").css("display","inline");
        }else{
            component.find("bankDate").set("v.value", null);
            $("#BankDepositDateIdField").css("display","none");
        }
    },
    
    changePaymentType: function(component, event, helper){
        var inputChk = component.find("checkInstrumentNoId");
        var selected = component.find("paymentTypesId").get("v.value");
        if(selected === "Cash"){
            $A.util.removeClass(inputChk, 'changeRequired');
        }else{
            if(inputChk.get("v.class").indexOf('changeRequired') === -1){
                $A.util.addClass(inputChk, 'changeRequired');
            }
        }
    },
    
    showHideChqOpts: function(component, event, helper){
        var selected = component.find("canBeProcId").get("v.value");
        if(selected === true){
            $("#chqNotProcessed").css("display","none");           
        }
        else{
            $("#chqNotProcessed").css("display","inline");
        }
        
    },
    
    addPaidDate: function(component, event, helper){
        var checkPaidFull = component.find("paidInFullId").get("v.value");        
        if(checkPaidFull){
            $("#PaidFullDateId").css("display","inline");
        }else{
            $("#PaidFullDateId").css("display","none");
        }
    },
    
    showHideOtherReason: function(component, event, helper){
        var selected = component.find("othersId").get("v.value");
        if(selected === true){
            $("#OtherReason").css("display","inline");
        }
        else{
            $("#OtherReason").css("display","none");
        }
    },
    
    getModifPayment: function(component, event, helper){
        console.log("C-----------getModifPayment-----------C")
        var ShowResultValue = event.getParam("Pass_Modif_Payment");
        if(ShowResultValue != null){
            component.set("v.receiptLog", ShowResultValue);
        }
        console.log(ShowResultValue);
        
        var getEditRct = component.get("v.receiptLog");
        var EditReceipt = JSON.parse(JSON.stringify(getEditRct));
        console.log("Receipts to be populated in the Receipt Log");
        console.log(EditReceipt);
        
        console.log("Check for the Add Deduction");
        var addDeduc = component.find("addDeducId").get("v.value")
        console.log(addDeduc);
        if(component.find("addDeducId").get("v.value") === true){
            console.log("Add Deduction is True");
            $("#grossAmt").css("display","inline"); 
            $("#deducAmt").css("display","inline");
        }
        else{
            console.log("Add Deduction is False");
            $("#grossAmt").css("display","none"); 
            $("#deducAmt").css("display","none");
        }
        
        if(component.find("canBeProcId").get("v.value") === true){
            $("#chqNotProcessed").css("display","none");           
        }
        else{
            $("#chqNotProcessed").css("display","inline");
        } 
        
        if(component.find("paidInFullId").get("v.value")){
            $("#PaidFullDateId").css("display","inline");
        }else{
            $("#PaidFullDateId").css("display","none");
        }
        
        if(component.find("othersId").get("v.value") === true){
            $("#OtherReason").css("display","inline");
        }
        else{
            $("#OtherReason").css("display","none");
        }
        if(ShowResultValue != null){
            helper.getEditFieldsSet(component, event, ShowResultValue);
        }
        var payorId = component.get("v.receiptLog.Payor__c");
        if(ShowResultValue != null && payorId != null && payorId.length > 0){
            var action = component.get("c.getPayorName");
            action.setParams({
                "payorId" : payorId,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    $("#payee01_typeahead").val(response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }

        //var action1 = component.get("c.calculateNetAmt");
        //$A.enqueueAction(action1);
        
    },
    
    getLookUpId: function(component, event, helper){
        var showLookupId = event.getParam("Pass_Lookup_Id");
        var showDeputyId = event.getParam("Pass_Lookup_Id_Deputy");
        if(showLookupId != null && showLookupId.length > 0){ 
            component.set("v.receiptLog.Payor__c",showLookupId);
        }
        console.log(component.get("v.receiptLog.Payor__r.Name"));
    },
    
    showHideAmtOpts: function(component, event, helper){
        var selected = component.find("addDeducId").get("v.value");
        if(selected === false){
            $A.util.removeClass(component.find("deductionAmtID"), 'addERR');
            $A.util.removeClass(component.find("grossAmtID"), 'addERR');
            document.getElementById('grossAmtErrId').innerHTML  = '';
            document.getElementById('deducAmtErrId').innerHTML  = '';
            $("#grossAmt").css("display","none"); 
            $("#deducAmt").css("display","none");
        }
        else{
            $("#grossAmt").css("display","inline");
            $("#deducAmt").css("display","inline");
        }    
    },
    
    calculateDeducAmt: function(component, event, helper){
        var selected = component.find("addDeducId").get("v.value");
        if(selected === true){
            var grossAmt = component.find("grossAmtID").get("v.value");
            var netAmt = component.find("paymentAmountID").get("v.value");
            var deductionAmt = (grossAmt*1000 - netAmt*1000)/1000;
            component.set("v.receiptLog.Deduction_Amount__c",deductionAmt);
            //var deducAmt = Number(component.find("deductionAmtID").get("v.value"));
            console.log("Dedcution Amt - "+deductionAmt);
        }
    },
    
    addPayment: function(component, event, helper){
        //component.set("v.AddPmtDisable",true);
        //console.log(JSON.parse(JSON.stringify(receiptList)));
        component.set("v.receiptLog.Case_Assigned__c", false);
        
        var paymTypeIP = component.find("paymentTypesId");
        var inputChkIP = component.find("checkInstrumentNoId");		
        var dateReceivedIP = component.find("receivedDate");
        var depositAccIP = component.find("depositAccountId");
        var bankDepDateIP = component.find("bankDate");
        var bankLocIP = component.find("bankLocationId");
        var pmtExchgIP = component.find("paymentExchangeId");
        var addDeductionIP = component.find("addDeducId");
        var grossAmtIP = component.find("grossAmtID");
        var paymentAmtIP = component.find("paymentAmountID");
        var deductionAmtIP = component.find("deductionAmtID");
        var officeUnitIP = component.find("officeUnitId");
        var canBeProcIP = component.find("canBeProcId");
        var staleDateIP = component.find("staleDateId");
        var insuffSignIP = component.find("insuffSignId");
        var amtDoNotMatchIP = component.find("amountsNotMachId");
        var noAmtIP = component.find("noAmountOnChkId");
        var limitExceededIP = component.find("limitExceedId");
        var postDatedIP = component.find("postDatedId");
        var paidFullIP = component.find("paidInFullId");
        var datePaidIP = component.find("paidDateId");
        var otherIP = component.find("othersId");
        var otherReasonIP = component.find("otherReasonTxtId");
        
        var today = new Date();
        var dateReceivedVal = dateReceivedIP.get("v.value");
        var dateDepositVal = bankDepDateIP.get("v.value");
        var datePaidValue = datePaidIP.get("v.value");
        var actualRecvVal = new Date(dateReceivedVal);
        var actualDepVal = new Date(dateDepositVal);
        var actualPaidVal = new Date(datePaidVal);
        
        var chkNoVal=1, dateRecVal=1, bankDepVal=1, bankLoc=1, paymAmtVal=1, grossAmtVal=1, deducVal=1, chkPayProcVal=1, othReasonVal=1, datePaidVal=1, isDeduc=1;
        
        if(inputChkIP.get("v.value").length === 0 && paymTypeIP.get("v.value") != "Cash"){
            document.getElementById('checkErrId').innerHTML = 'Enter check details.';
            $A.util.addClass(inputChkIP, 'addERR');
            chkNoVal = 0;
        }
        else{
            document.getElementById('checkErrId').innerHTML = '';
            $A.util.removeClass(inputChkIP, 'addERR');
            chkNoVal = 1;
        }
        
        if(dateReceivedVal == undefined || dateReceivedVal == null){
            document.getElementById('recvDateErrId').innerHTML  = 'Enter date received.';
            $A.util.addClass(dateReceivedIP, 'addERR');
            dateRecVal = 0;
        }
        else if(actualRecvVal > today){
            document.getElementById('recvDateErrId').innerHTML  = 'Date received cannot be in future.';
            $A.util.addClass(dateReceivedIP, 'addERR');
            dateRecVal = 0;
        }
            else{
                document.getElementById('recvDateErrId').innerHTML  = '';
                $A.util.removeClass(dateReceivedIP, 'addERR');
                dateRecVal = 1;
            }
        
        if (depositAccIP.get("v.value") === "108" && dateDepositVal === null){
            document.getElementById('depDateErrId').innerHTML  = 'Enter date deposited';
            $A.util.addClass(bankDepDateIP, 'addERR');
            bankDepVal = 0;
        }
        /*
        else if(depositAccIP.get("v.value") === "108" && actualDepVal > today){
            document.getElementById('depDateErrId').innerHTML  = 'Date deposited cannot be in future.';
            $A.util.addClass(bankDepDateIP, 'addERR');
            var bankDepVal = 0;
        }
        */
        else{
            document.getElementById('depDateErrId').innerHTML  = '';
            $A.util.removeClass(bankDepDateIP, 'addERR');
            bankDepVal = 1;
        }
        
        if(bankLocIP.get("v.value") == "None"){
            document.getElementById('bankLocErrId').innerHTML = 'Select the bank location.';
            $A.util.addClass(bankLocIP, 'addERR');
            bankLoc = 0;
        }
        else{
            document.getElementById('bankLocErrId').innerHTML = '';
            $A.util.removeClass(bankLocIP, 'addERR');
            bankLoc = 1;
        }
        
        //console.log($("#payee01_typeahead"));
        //var payorName = $(".payor")[0].value;
        //var payorName = $("#payee01_typeahead").val();
        //console.log(payorName);
        //component.set("v.receiptLog.Payor__r.Name", payorName)  
        //console.log(component.get("v.receiptLog.Payor__r.Name")); 
        
        //////////Check Gross & Net & Deduc Validation//////////////
        
        if(isNaN(paymentAmtIP.get("v.value")) || paymentAmtIP.get("v.value") == ''){
            document.getElementById('payAmtErrId').innerHTML  = 'Enter net amount.';
            $A.util.addClass(paymentAmtIP, 'addERR');
            paymAmtVal = 0;
        }
        else{
            document.getElementById('payAmtErrId').innerHTML  = '';
            $A.util.removeClass(paymentAmtIP, 'addERR');
            paymAmtVal = 1;
        }
        
        if(isNaN(grossAmtIP.get("v.value")) || grossAmtIP.get("v.value") == ''){
            document.getElementById('grossAmtErrId').innerHTML  = 'Enter gross amount.';
            $A.util.addClass(grossAmtIP, 'addERR');
            grossAmtVal = 0;
        }
        else{
            document.getElementById('grossAmtErrId').innerHTML  = '';
            $A.util.removeClass(grossAmtIP, 'addERR');
            grossAmtVal = 1;
        }
        
        if(addDeductionIP.get("v.value") === true){
            isDeduc = 1;
            if ((grossAmtIP.get("v.value") == paymentAmtIP.get("v.value")) || (grossAmtIP.get("v.value") <= paymentAmtIP.get("v.value"))){
                document.getElementById('deducAmtErrId').innerHTML  = 'Enter valid gross & net amount';
                $A.util.addClass(deductionAmtIP, 'addERR');
                deducVal = 0;
            }
            else if(deductionAmtIP.get("v.value") > 0){
                $A.util.removeClass(deductionAmtIP, 'addERR');
                document.getElementById('deducAmtErrId').innerHTML  = '';
                deducVal = 1;
            }
        }
        else{
            isDeduc = 0;
            document.getElementById('grossAmtErrId').innerHTML  = '';
            $A.util.removeClass(grossAmtIP, 'addERR');
            grossAmtVal = 1;
        }
        
        if(canBeProcIP.get("v.value") == false){
            if(staleDateIP.get("v.value") == true){
                document.getElementById('canProcErrId').innerHTML = '';
                $A.util.removeClass(canBeProcIP, 'addChBxErr');
                chkPayProcVal = 1;
            }
            else if(insuffSignIP.get("v.value") == true){
                document.getElementById('canProcErrId').innerHTML = '';
                $A.util.removeClass(canBeProcIP, 'addChBxErr');
                chkPayProcVal = 1;
            }
                else if(amtDoNotMatchIP.get("v.value") == true){
                    document.getElementById('canProcErrId').innerHTML = '';
                    $A.util.removeClass(canBeProcIP, 'addChBxErr');
                    chkPayProcVal = 1;
                }
                    else if(noAmtIP.get("v.value") == true){
                        document.getElementById('canProcErrId').innerHTML = '';
                        $A.util.removeClass(canBeProcIP, 'addChBxErr');
                        chkPayProcVal = 1;
                    }
                        else if(limitExceededIP.get("v.value") == true){
                            document.getElementById('canProcErrId').innerHTML = '';
                            $A.util.removeClass(canBeProcIP, 'addChBxErr');
                            chkPayProcVal = 1;
                        }
                            else if(postDatedIP.get("v.value") == true){
                                document.getElementById('canProcErrId').innerHTML = '';
                                $A.util.removeClass(canBeProcIP, 'addChBxErr');
                                chkPayProcVal = 1;
                            }
                                else if(paidFullIP.get("v.value") == true){
                                    document.getElementById('canProcErrId').innerHTML = '';
                                    $A.util.removeClass(canBeProcIP, 'addChBxErr');
                                    chkPayProcVal = 1;
                                    if(datePaidValue == undefined || datePaidValue == null){
                                        document.getElementById('paidDateErrId').innerHTML  = 'Enter date paid.';
                                        $A.util.addClass(datePaidIP, 'addERR');
                                        datePaidVal = 0;
                                    }
                                    else if(actualPaidVal > today){
                                        document.getElementById('paidDateErrId').innerHTML  = 'Date Paid cannot be in future.';
                                        $A.util.addClass(datePaidIP, 'addERR');
                                        datePaidVal = 0;
                                    }
                                        else{
                                            document.getElementById('paidDateErrId').innerHTML  = '';
                                            $A.util.removeClass(datePaidIP, 'addERR');
                                            datePaidVal = 1;
                                        }
                                }
                                    else if(otherIP.get("v.value") == true){
                                        document.getElementById('canProcErrId').innerHTML = '';
                                        $A.util.removeClass(canBeProcIP, 'addChBxErr');
                                        if(otherReasonIP.get("v.value") == undefined || otherReasonIP.get("v.value").length === 0){
                                            document.getElementById('otherReasonErrId').innerHTML  = 'Specify other reason.';
                                            $A.util.addClass(otherReasonIP, 'addERR');
                                            othReasonVal = 0;
                                        }
                                        else{
                                            document.getElementById('otherReasonErrId').innerHTML  = '';
                                            $A.util.removeClass(otherReasonIP, 'addERR');
                                            othReasonVal = 1;
                                        }
                                    }
                                        else{
                                            document.getElementById('canProcErrId').innerHTML = 'Specify the reason.';
                                            $A.util.addClass(canBeProcIP, 'addChBxErr');
                                            chkPayProcVal = 0;
                                        } 
        }
        else{
            document.getElementById('canProcErrId').innerHTML = '';
            $A.util.removeClass(canBeProcIP, 'addChBxErr');
            chkPayProcVal = 1;
        }
        
        //Add Payor Name to the list
        /*__________________________________________________________________________________________*/
        var lookupID = component.find("payeeValId1").get("v.value");
        var action = component.get("c.getPayorName");
        action.setParams({
            "payorId" : lookupID,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("Payor Success")
                var payorName = response.getReturnValue();
                console.log(payorName);
                component.set("v.receiptLog.Payor__r.Name", payorName)
                console.log(component.get("v.receiptLog.Payor__r.Name"));
                if(isDeduc == 1){
                    console.log("Is Deduction");
                    if(chkNoVal == 1 && dateRecVal == 1 && bankDepVal == 1 && bankLoc == 1 && paymAmtVal == 1 && 
                       chkPayProcVal == 1 && othReasonVal==1 && datePaidVal==1 && deducVal == 1 && grossAmtVal==1){
                        $A.enqueueAction(component.get('c.addPaymentToEvent'));
                        $A.enqueueAction(component.get('c.addDeductionToEvent'));
                        $A.enqueueAction(component.get('c.resetForm'));
                    }
                }
                else{
                    console.log("Is Payment");
                    if(chkNoVal == 1 && dateRecVal == 1 && bankDepVal == 1 && bankLoc == 1 && paymAmtVal == 1 && 
                       chkPayProcVal == 1 && othReasonVal==1 && datePaidVal==1){
                        $A.enqueueAction(component.get('c.addPaymentToEvent'));
                        $A.enqueueAction(component.get('c.resetForm'));
                    }
                }
            }
            else{
                console.log("No Payor");
                if(isDeduc == 1){
                    console.log("Is Deduction1");
                    if(chkNoVal == 1 && dateRecVal == 1 && bankDepVal == 1 && bankLoc == 1 && paymAmtVal == 1 && 
                       chkPayProcVal == 1 && othReasonVal==1 && datePaidVal==1 && deducVal == 1 && grossAmtVal==1){
                        $A.enqueueAction(component.get('c.addPaymentToEvent'));
                        $A.enqueueAction(component.get('c.addDeductionToEvent'));
                        $A.enqueueAction(component.get('c.resetForm'));
                    }
                }
                else{
                    console.log("Is Payment2");
                    if(chkNoVal == 1 && dateRecVal == 1 && bankDepVal == 1 && bankLoc == 1 && paymAmtVal == 1 && 
                       chkPayProcVal == 1 && othReasonVal==1 && datePaidVal==1){
                        console.log("Call Payment EVent");
                        $A.enqueueAction(component.get('c.addPaymentToEvent'));
                        $A.enqueueAction(component.get('c.resetForm'));
                    }
                }
            }
        });
        $A.enqueueAction(action);
        /*___________________________________________________________________________________________*/
    },
    
    addPaymentToEvent: function(component, event, helper){
        console.log("Add PAyment to Event");
        var index_nr;
        if(component.get("v.countReceipt") == 0){
            index_nr = 0;
        }
        else{
            index_nr = component.get("v.countReceipt");
        }
        if(!isNaN(component.get("v.receiptLog.Id")) || component.get("v.receiptLog.Id") == ''){
            component.set("v.receiptLog.Id", index_nr);
        }
        component.set("v.receiptLog.Amount_Remaining__c", component.find("paymentAmountID").get("v.value"));
        var depositAccIP = component.find("depositAccountId");
        var officeUnitIP = component.find("officeUnitId");
        var receiptList = component.get("v.receiptLog");
        const newReceipts = JSON.parse(JSON.stringify(receiptList));
        newReceipts.Deduction_Amount__c = 0;
        newReceipts.Status__c = 'New';
        
        component.set("v.countReceipt",index_nr +1);
        var evt = $A.get("e.c:ResultPayment");
        evt.setParams({ "Pass_Result_List": newReceipts, "Pass_Reset_Edit" : true, "Pass_OfficeUnit_VAL": officeUnitIP.get("v.value"), "Pass_DepositAcc_VAL": depositAccIP.get("v.value")});
        evt.fire();
    },
    
    addDeductionToEvent: function(component, event, helper){
        console.log("add deduction event")
        var index_nr;
        if(component.get("v.countReceipt") == 0){
            index_nr = 0;
        }
        else{
            index_nr = component.get("v.countReceipt");
        }
        
        if(!isNaN(component.get("v.receiptLog.Id")) || component.get("v.receiptLog.Id") == ''){
            component.set("v.receiptLog.Id", index_nr);
        }
        component.set("v.receiptLog.Amount_Remaining__c", component.find("deductionAmtID").get("v.value"));
        
        var depositAccIP = component.find("depositAccountId");
        var officeUnitIP = component.find("officeUnitId");
        var instNum = component.find("checkInstrumentNoId").get("v.value");
        
        var receiptList = component.get("v.receiptLog");
        const newReceipts = JSON.parse(JSON.stringify(receiptList));
        newReceipts.Payment_Amount__c = 0;
        newReceipts.Status__c = 'New';
        newReceipts.Payment_Type__c = 'Deduction';
        newReceipts.Instrument_Number__c = 'Deduction for '+ instNum;
        
        component.set("v.countReceipt",index_nr +1);
        var evt = $A.get("e.c:ResultPayment");
        evt.setParams({ "Pass_Result_List": newReceipts, "Pass_Reset_Edit" : true, "Pass_OfficeUnit_VAL": officeUnitIP.get("v.value"), "Pass_DepositAcc_VAL": depositAccIP.get("v.value")});
        evt.fire();
    },
    
    resetForm: function(component, event, helper){
        //reset the value in form
        component.set("v.receiptLog", { 
            'Id':'',
            'Payment_Type__c' : 'Check',
            'Instrument_Number__c' : '',
            'Date_Received__c' : null,
            'Deposit_Account__c' : 'None',
            'Bank_Deposit_Date__c':null,
            'Bank_Location__c' : 'None',
            'Payment_Exchange__c' : 'Division Payment',
            'Payor__c' : '',
            //'Payor__r.Name' : '',
            //'Payor__r' : '',
            'Add_Deduction__c' : false,
            'Gross_Amount__c' : '',
            'Payment_Amount__c' : '',
            'Deduction_Amount__c' :'',
            'Case_Assigned__c' : false,
            'Status__c' : '',
            'Office_Unit__c' : 'CCU',
            'Payment_Can_Be_Processed__c': true,
            'Not_Processed_Stale_Date__c': false,
            'Not_Processed_Insufficient_Signature_s__c':false,
            'Not_Processed_Amounts_Do_Not_Match__c': false,
            'Not_Processed_No_Amount__c': false,
            'Not_Processed_Limit_Exceeded__c':false,
            'Not_Processed_Post_Dated__c':false,
            'Not_Processed_Paid_In_Full__c':false,
            'Not_Processed_Paid_In_Full_Date__c':null,
            'Not_Processed_Other__c':false,
            'Not_Processed_Other_Reason__c':null,
            'Amount_Remaining__c':'0.00'
        });
        //component.set("v.receiptLog" : '');
        $("#chqNotProcessed").css("display","none");
        $("#BankDepositDateIdField").css("display","none");
        $("#PaidFullDateId").css("display","none");
        $("#OtherReason").css("display","none");
        $("#grossAmt").css("display","none"); 
        $("#deducAmt").css("display","none");
        //$('#payee01_typeahead').val("");
        //$("#payee01_typeahead").value = '';
        $A.get("e.c:ResetFormEvent").fire();
        //console.log("---- payee ----");
        //console.log(component.get("v.receiptLog.Payor__r.Name"));
    }
    
})