({ 
    getAllRecordTypes: function(component, event){
        console.log("getAllRecordTypes")
        var action = component.get("c.getRecTypeIds");
        action.setCallback(this, function(response){
            var state = response.getState();
            component.set("v.cpRecTypes",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    editThisReceipt: function(component, selIndex, event){
        console.log("H----------editThisReceipt----------H");
        //get the receipt values for all fields and add them in receiptLog for editing.
        var currentRct = component.get("v.receipts");
        var receipts = JSON.parse(JSON.stringify(currentRct));
        var editRct = [];
        
        //Get the Receipt details that has to be edited. If a deduction receipt is available, get both the payment and deduction receipt for the same instrument.
        receipts.forEach(function(item, index, object){
            if(item.Id == selIndex){
                console.log(item);
                if(item.Add_Deduction__c === false){
                    console.log("Edit RCT with no Deduction");
                    editRct.push(item);
                    console.log("List of RCT to be edited");
        			console.log(editRct);
                    //this.clearCases(component, clearindex);
                    //this.clearRctandCases(component, clearindex);
                }
                else if(item.Add_Deduction__c === true && item.Payment_Type__c === 'Deduction'){
                    console.log("Edit this deduction record");
                    console.log("Edit it's corresponding payment record");
                    //console.log(receipts);
                    var deducInstNum = item.Instrument_Number__c;
                    var pmtInstNum = deducInstNum.replace("Deduction for ","");
                    
                    receipts.forEach(function(itemDeduct, index, object){
                        if(itemDeduct.Instrument_Number__c == pmtInstNum || itemDeduct.Instrument_Number__c == deducInstNum){
                            editRct.push(itemDeduct);
                            console.log("List of RCT to be edited");
        					console.log(editRct);
                            //this.clearCases(component, clearindex);
                            //this.clearRctandCases(component, clearindex);
                        }
                    });
                   
                }
                    else if(item.Add_Deduction__c === true && item.Payment_Type__c != 'Deduction'){
                        console.log("Edit this Payment record");
                        console.log("Edit it's corresponding deduction record");
                        //console.log(receipts);
                        var pmtInstNum = item.Instrument_Number__c;
                        var deducInstNum = "Deduction for ".concat(pmtInstNum);
                        receipts.forEach(function(itemDeduct, index, object){
                            if(itemDeduct.Instrument_Number__c == pmtInstNum || itemDeduct.Instrument_Number__c == deducInstNum){
                                editRct.push(itemDeduct);
                            	console.log("List of RCT to be edited");
        						console.log(editRct); 
                                //this.clearCases(component, clearindex);
                                //this.clearRctandCases(component, clearindex);
                            }
                    	});
                    }  
            }
        });
        
        //Combine the Payment and Deduction receipt into 1 receipt list, that has to be sent to the Receipt Log Form
        var modifReceipt;
        var tempDeducAmt;
        var clearIndex;
        //Store the deduction amount in a temp variable 
        for(var i = 0;i < editRct.length ;i++){
            if(editRct[i].Add_Deduction__c === true && editRct[i].Payment_Type__c === 'Deduction'){
                tempDeducAmt = editRct[i].Deduction_Amount__c;
            }
           
        }
        //Assign the receipt details to the variable 
        for(var j = 0;j < editRct.length ;j++){
            if(editRct[j].Add_Deduction__c === false){
                    modifReceipt = editRct[j];
            }
            else if(editRct[j].Add_Deduction__c === true && editRct[j].Payment_Type__c != 'Deduction'){
                modifReceipt = editRct[j];
                modifReceipt.Deduction_Amount__c = tempDeducAmt;
            } 
        }
        console.log("List to be filled back in ReceiptLog to edit");
        console.log(modifReceipt);
        //Remove both the Payment and Deduction receipts from the Grid and populate to the form above
        //Also remove the cases that's been allocated. The cases has to be reallocated if a receipt is edited
        if (editRct.length > 0){
            for(var k = 0;k < receipts.length ;k++){
                for(var m = 0;m < editRct.length ;m++){
                    if(receipts[k].Id == editRct[m].Id){
                        receipts.splice(k,1);
                        clearIndex = k;
                    	this.clearCases(component, clearIndex);
                    	this.clearRctandCases(component, clearIndex);
                    }
                }
            }
        }
        
        console.log("receipts after Splicing");
        console.log(receipts);
        console.log("modifReceipt after Splicing");
        console.log(modifReceipt);
        component.set("v.receipts", receipts);
        var evt = $A.get("e.c:EditPayments");
        evt.setParams({ "Pass_Modif_Payment": modifReceipt});
        evt.fire();
    },
    
    removeReceipt: function(component, index, event) {
        console.log("H----------removeReceipt----------H");
        var allReceipts = component.get("v.receipts");
        var receipts = JSON.parse(JSON.stringify(allReceipts));
        var clearindex;
        //console.log(receipts);
        //console.log(index);
        for(var i = 0;i < receipts.length ;i++){
            if(receipts[i].Id == index){
                console.log(receipts[i]);
                if(receipts[i].Add_Deduction__c === false){
                    //console.log("no deduction");
                    clearindex = i;
                    receipts.splice(i,1);
                    this.clearCases(component, clearindex);
                    this.clearRctandCases(component, clearindex);
                }
                else if(receipts[i].Add_Deduction__c === true && receipts[i].Payment_Type__c === 'Deduction'){
                    //console.log("Delete this deduction record");
                    //console.log("Delete it's corresponding payment record");
                    //console.log(receipts);
                    var deducInstNum = receipts[i].Instrument_Number__c;
                    var pmtInstNum = deducInstNum.replace("Deduction for ","");
                    var i = receipts.length;
                    while (i--)
                    {
                        //console.log(receipts[i].Instrument_Number__c);
                        if(receipts[i].Instrument_Number__c == pmtInstNum || receipts[i].Instrument_Number__c == deducInstNum){
                            clearindex = i;
                            receipts.splice(i,1);
                            this.clearCases(component, clearindex);
                            this.clearRctandCases(component, clearindex);
                        }
                    }
                }
                    else if(receipts[i].Add_Deduction__c === true && receipts[i].Payment_Type__c != 'Deduction'){
                        //console.log("Delete this Payment record");
                        //console.log("Delete it's corresponding deduction record");
                        //console.log(receipts);
                        var pmtInstNum = receipts[i].Instrument_Number__c;
                        var deducInstNum = "Deduction for ".concat(pmtInstNum);
                        var i = receipts.length;
                        while (i--)
                        {
                            //console.log(receipts[i].Instrument_Number__c);
                            if(receipts[i].Instrument_Number__c == pmtInstNum || receipts[i].Instrument_Number__c == deducInstNum){
                                clearindex = i;
                                receipts.splice(i,1);
                                this.clearCases(component, clearindex);
                                this.clearRctandCases(component, clearindex);
                            }
                        }
                    }  
            }
        }
        component.set("v.receipts", receipts);
        console.log("Receipts remaining");
        console.log(receipts);
    },
        
    clearCases: function(component, index){
        console.log("H------clearCases-------H")
        console.log(index);
        var allCases = component.get("v.allCaseList");
        var caseList = JSON.parse(JSON.stringify(allCases));
        console.log(caseList);
        if(caseList!=[]){
            var i = caseList.length;
            while (i--){
                if(caseList[i].caseIndex == index){
                    console.log("Delete Cases");
                    caseList.splice(i,1);
                }
            }
        }
        component.set("v.allCaseList", caseList);
        console.log("Cases remaining");
        console.log(caseList);
    },
    
    clearRctandCases: function(component, index){
        console.log("H------clearRctandCases-------H")
        console.log(index);
        var allRctCases = component.get("v.receiptCases");
        var rctCases = JSON.parse(JSON.stringify(allRctCases));
        console.log(rctCases);
        if(rctCases!=[]){
            var i = rctCases.length;
            while (i--){
                var allRcts = rctCases[i].allReceipts;
                var j = allRcts.length;
                while (j--){
                    if(allRcts[j].Id == index){
                        console.log("Delete Rcts in RctCases");
                        allRcts.splice(j,1);
                    }
                }
                console.log(allRcts);
                var allCases = rctCases[i].allCaseList;
                var k = allCases.length;
                while (k--){
                    if(allCases[k].caseIndex == index){
                        console.log("Delete Cases in RctCases");
                        allCases.splice(k,1);
                    }
                }
                console.log(allCases);
                if(rctCases[i].rctIndex == index){
                    console.log("Delete Rcts and its Cases");
                    rctCases.splice(i,1);
                }
                
            }
        }
        component.set("v.receiptCases", rctCases);
        console.log("Rcts and Cases remaining");
        console.log(rctCases);
    },
    
    openCaseDetail: function(component, event, index){
        console.log("H----------openCaseDetail----------H");
        var receipts = component.get("v.receipts");
        var currentRctList = JSON.parse(JSON.stringify(receipts));
        var receiptCases = component.get("v.receiptCases");
        var currentReceiptCases = JSON.parse(JSON.stringify(receiptCases));
        console.log(currentRctList);
        console.log(currentReceiptCases);
        var evt = $A.get("e.c:RIndexToCase");
        evt.setParams({"Pass_Rct_Index": index, "Pass_Current_RList": currentRctList, "Pass_Current_RctCaseList": currentReceiptCases});
        evt.fire();
        document.getElementById("CasesModal").style.display = "block";
        //console.log("open modal");
    },
    
    insertReceiptCase: function(component, receipts, allCases, redirect){ 
        console.log("H------------insertReceiptCase------------H")
        var isEditing = component.get("v.editPage");
        var newReceiptCaseObj = [];
        var newReceiptObj = [];
        for(var i = 0; i < receipts.length; i++) {
            console.log(receipts[i]['Id']);
            var auxRctObj = {
                "Receipt_Index__c" : receipts[i]['Id'],
                "Payment_Type__c" : receipts[i]['Payment_Type__c'],
                "Instrument_Number__c" : receipts[i]['Instrument_Number__c'],
                "Date_Received__c" : receipts[i]['Date_Received__c'],
                "Deposit_Account__c" : receipts[i]['Deposit_Account__c'],
                "Bank_Deposit_Date__c": receipts[i]['Bank_Deposit_Date__c'],
                "Bank_Location__c" : receipts[i]['Bank_Location__c'],
                "Payment_Exchange__c" : receipts[i]['Payment_Exchange__c'],
                "Payor__c" : receipts[i]['Payor__c'],
                "Add_Deduction__c" : receipts[i]['Add_Deduction__c'],
            	"Gross_Amount__c" : receipts[i]['Gross_Amount__c'],
                "Payment_Amount__c" :receipts[i]['Payment_Amount__c'],
                "Deduction_Amount__c" : receipts[i]['Deduction_Amount__c'],
                "Case_Assigned__c" : receipts[i]['Case_Assigned__c'],
                "Status__c" : receipts[i]['Status__c'],
                "Office_Unit__c" : receipts[i]['Office_Unit__c'],
                "Payment_Can_Be_Processed__c" : receipts[i]['Payment_Can_Be_Processed__c'],
                "Not_Processed_Stale_Date__c" : receipts[i]['Not_Processed_Stale_Date__c'],
                "Not_Processed_Insufficient_Signature_s__c" : receipts[i]['Not_Processed_Insufficient_Signature_s__c'],
                "Not_Processed_Amounts_Do_Not_Match__c" : receipts[i]['Not_Processed_Amounts_Do_Not_Match__c'],
                "Not_Processed_No_Amount__c" : receipts[i]['Not_Processed_No_Amount__c'],
                "Not_Processed_Limit_Exceeded__c" : receipts[i]['Not_Processed_Limit_Exceeded__c'],
                "Not_Processed_Post_Dated__c" :receipts[i]['Not_Processed_Post_Dated__c'],
                "Not_Processed_Paid_In_Full__c" : receipts[i]['Not_Processed_Paid_In_Full__c'],
                "Not_Processed_Paid_In_Full_Date__c" : receipts[i]['Not_Processed_Paid_In_Full_Date__c'],
                "Not_Processed_Other__c" : receipts[i]['Not_Processed_Other__c'],
                "Not_Processed_Other_Reason__c" : receipts[i]['Not_Processed_Other_Reason__c'],
            }
            console.log(auxRctObj);
            newReceiptObj.push(auxRctObj);
        }
        var receiptStr = JSON.stringify(newReceiptObj);
        console.log(receiptStr);
        
        var newCaseObj = [];
        if(allCases != undefined && allCases != null){
            console.log("All Cases Case Payments");
            console.log(allCases);
            for (var j = 0; j < allCases.length; j++){
                var getRecTypes = component.get("v.cpRecTypes");
        		var cpRecTypes = JSON.parse(JSON.stringify(getRecTypes));
                console.log(cpRecTypes);
                for (var k=0; k<cpRecTypes.length; k++){
                    if(allCases[j].recType.includes(cpRecTypes[k].Name)){
                        allCases[j].recTypeID = cpRecTypes[k].Id;
                        break;
                    }
                    else{
                        allCases[j].recTypeID = cpRecTypes[0].Id;
                    }
                }
                
                var auxCaseObj = {
                    CP_Index__c: allCases[j]['caseIndex'],
                    case__c: allCases[j]['IdCase'],
                    Payment_Amount__c: allCases[j]['allocatedAmount'],
                    RecordTypeId: allCases[j]['recTypeID'],
                    Receipt__c: '',
                    Status__c: 'New',
                    Deduction_Payment__c: ''
                }
                console.log(auxCaseObj);
                newCaseObj.push(auxCaseObj);
            }
        }
        var caseStr = JSON.stringify(newCaseObj);
        console.log(caseStr);
        
        var action1 = component.get("c.saveReceiptCaseServer");
        action1.setParams({
            "receipts" : receiptStr,
            "casePmts" : caseStr,
            "isEdited" : isEditing
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (component.isValid() && state === "SUCCESS") {
                console.log(response.getReturnValue());
                $("#lbl_SaveErr").css("display","none");
                if(redirect == true){
                    window.location.pathname = "/a2r/o";
                }
                else{
                    location.reload();
                }
            }
            else{
                $("#lbl_SaveErr").css("display","block");
                $("#lbl_SaveErr").text("Sorry, something went wrong. Please contact the System Administrator");
            }
        });
        $A.enqueueAction(action1);  
    }
    
})