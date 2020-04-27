({
    doInit: function(component, event, helper){
        
    },
    
    getRctDetails: function(component, event, helper){
        console.log("C----------getRctDetails----------C");
        var currIndex = event.getParam("Pass_Rct_Index");
        component.set("v.Rindex", currIndex);
        //console.log(currIndex);
        
        var evtReceiptList = event.getParam("Pass_Current_RList");
        var currReceiptList = JSON.parse(JSON.stringify(evtReceiptList));
        component.set("v.receiptList", currReceiptList);
        //console.log(currReceiptList);
        
        var evtRctCaseList = event.getParam("Pass_Current_RctCaseList");
        var currRctCaseList = JSON.parse(JSON.stringify(evtRctCaseList));
        //console.log(currRctCaseList);
        
        //Add current Receipt to link Case
        for(var i = 0;i < currReceiptList.length ;i++){
            if(currReceiptList[i].Id == currIndex){
                var currReceipt = JSON.parse(JSON.stringify(currReceiptList[i]));
                component.set("v.receipt", currReceipt);
                console.log(currReceipt);
                
                if(currReceipt.Payment_Type__c == 'Deduction'){
                    $('#lbl_PaymDeduc').text("Deduction Amount: $"+currReceipt.Deduction_Amount__c);
                    //component.set("v.totAlloc", currReceipt.Deduction_Amount__c);
                }
                else{
                    $('#lbl_PaymDeduc').text("Net Amount: $"+currReceipt.Payment_Amount__c);
                    //component.set("v.totAlloc", currReceipt.Payment_Amount__c);
                }
            }
        }
        
        //Add current Receipt Case to the open dialog
        
        if(currRctCaseList.length > 0){
            for(var j=0; j<currRctCaseList.length; j++){
                if(currRctCaseList[j].rctIndex == currIndex){
                    var caseDetail = currRctCaseList[j].casesList;
                    console.log("Case Detail Added");
                    console.log(caseDetail);
                    component.set("v.casesMap", caseDetail);  
                    var ids = ""
                    for(var k=0; k<caseDetail.length; k++){
                        var ids = ids+ "," +caseDetail[k].caseDetail.IdCase;
                    }
                    
                    component.set("v.ids", ids);
                }
            }
        }
    },
    
    addCases: function(component, event, helper){
        console.log('C----------addCases----------C');
        var cases = [];
        var casesArray = component.find("allChk"); 
        console.log(casesArray);
        
        if(casesArray.length >= 1){
            console.log("casesArray length >= 1");
            console.log(casesArray.length);
            for(var cmp in casesArray){
                if(casesArray[cmp].get("v.value") === true){
                    var id = casesArray[cmp].get("v.class").split(" ")[0].split("caseId-")[1];
                    cases.push(id);
                    casesArray[cmp].set("v.value", true);
                }
            }
        }else if(casesArray.length == null){
            console.log("casesArray length is Null");
            console.log(casesArray.length);
            if(casesArray.get("v.value") === true){
                var id = casesArray.get("v.class").split(" ")[0].split("caseId-")[1];
                cases.push(id);
                casesArray.set("v.value", true);
            }
        }
        
        console.log("Cases Added");
        console.log(cases);
        ///Add the selected cases and send them to the event
        var evt = $A.get("e.c:CaseEvent");
        evt.setParams({ "Pass_Case_Result_List": cases});
        evt.fire();
    },
    
    getCasesFromEvent: function(component, event, helper) {
        console.log("C----------getCasesFromEvent----------C");
        var CaseListMap = component.get("v.casesMap");
        console.log("CaseListMap");
        console.log(CaseListMap);
        
        if(CaseListMap != null){
            var caseMapArr = JSON.parse(JSON.stringify(CaseListMap));
            console.log("caseMapArr");
            console.log(caseMapArr);
            
            if (caseMapArr.length>0)
            {
                var getReceipt = component.get("v.receipt");
                var currReceipt = JSON.parse(JSON.stringify(getReceipt));
                
                if(currReceipt.Payment_Type__c == 'Deduction'){
                    currReceipt.Amount_Remaining__c = currReceipt.Deduction_Amount__c;
                }
                else{
                    currReceipt.Amount_Remaining__c = currReceipt.Payment_Amount__c;
                }
                component.set("v.receipt", currReceipt);
            }
            
        }
        var ids = "";
        if(component.get("v.ids") != null){
            ids = component.get("v.ids");
            //console.log("ids");
            //console.log(ids);
        }
        var ShowResultValue = event.getParam("Pass_Case_Result_List");
        
        // set the handler attributes based on event data
        if(ShowResultValue != null){
            var cases = ShowResultValue;
            //console.log("cases");
            //console.log(cases);
            var finalIDs
            
            if(ids != cases){
                //multiple cases
                var idsList = ids.split(",");
                //console.log("idsList");
                //console.log(idsList);
                for(var i = 0;i < cases.length ;i++){
                    idsList.push(cases[i]);
                }
                finalIDs = idsList.join();
            }
            else{
                finalIDs = cases;
            }
            
            
            component.set("v.ids", finalIDs);
            //console.log(finalIDs);
            helper.getCases(component, finalIDs);
        }
    },
    
    searchKeyChange: function(component, event, helper){
        console.log("C-----------searchKeyChange--------------C");
        var which = event.which;
        if(which == 13){
            // get elements when enter key is pressed
            var search = event.currentTarget.value;
            helper.searchCases(component, search);
        }
    },
    
    selectAll: function(component, Event, helper){
        console.log("C-----------selectAll--------------C");
        var chkForAll = component.find("headChk1");
        var casesArray = component.find("allChk");
        if(chkForAll.get("v.value") === true){
            if(casesArray.length > 1){
                for(var k in casesArray){
                    casesArray[k].set("v.value", true);
                }
            }else if(casesArray.length == null){
                casesArray.set("v.value", true);
            }
        }else{
            if(casesArray.length > 1){
                for(var m in casesArray){
                    casesArray[m].set("v.value", false);
                }
            }else if(casesArray.length == null){
                casesArray.set("v.value", false);
            }
        }
    },
    
    delCase: function(component, event, helper){
        console.log("C----------delCase----------C");
        var self = this;  // safe reference
        var selIndex = event.currentTarget.dataset.index;
        
        var CaseListMap = component.get("v.casesMap");
        var caseMapArr = JSON.parse(JSON.stringify(CaseListMap));
        
        var i = caseMapArr.length;
        while (i--){
            if(caseMapArr[i].index == selIndex){
                var value = Number(caseMapArr[i].caseDetail.allocatedAmount);
                caseMapArr.splice(i, 1);;
            }
        }
        component.set("v.casesMap", caseMapArr);
        
        var caseids = null;
        for(var i = 0;i < caseMapArr.length ;i++){
            if(caseids == null){
                caseids = ',' + caseMapArr[i].caseDetail.IdCase;
            }
            else{
                caseids = caseids + ',' + caseMapArr[i].caseDetail.IdCase;
            }
        }
        console.log("Remaining Case IDs");
        console.log(caseids);
        
        //Update Amount Remaining
        var getReceipt = component.get("v.receipt");
        var currReceipt = JSON.parse(JSON.stringify(getReceipt));
        var amtBal = currReceipt.Amount_Remaining__c;
        var newBal = (amtBal*1000 + value*1000)/1000;
        currReceipt.Amount_Remaining__c = newBal;
        component.set("v.receipt", currReceipt);
        
        component.set("v.ids", caseids);
        var evt = $A.get("e.c:CaseEvent");
        evt.setParams({ "Pass_Case_Result_List": caseids});
        evt.fire();
    },
    
    saveAllocAmt: function(component, event, helper){
        console.log("C----------saveAllocAmt----------C");
        var self = this;
        var selIndex = event.currentTarget.dataset.index;
        var value = event.target.value;
        console.log(value);
        if(value == NaN || value == ''){
            value = 0;
        }
        var preValue;
        var CaseListMap = component.get("v.casesMap");
        var caseMapArr = JSON.parse(JSON.stringify(CaseListMap));
        
        for(var i = 0;i < caseMapArr.length ;i++){
            if(caseMapArr[i].index == selIndex){
                preValue = caseMapArr[i].caseDetail.allocatedAmount;
                caseMapArr[i].caseDetail.allocatedAmount = value;
            }
        }
        component.set("v.casesMap", caseMapArr);
        
        /// Update Amount Remaining
        var getReceipt = component.get("v.receipt");
        var currReceipt = JSON.parse(JSON.stringify(getReceipt));            
        var amtBal = currReceipt.Amount_Remaining__c;
        var newBal = (amtBal*1000 + preValue*1000 - value*1000)/1000;
        if(newBal < 0){
            $("#lbl_AmtBal").css("color","red");
            $("#lbl_AllocErr").css("display","block");
            $("#lbl_AllocErr").text("Allocation amount exceeds total available amount");
        }
        else{
            $("#lbl_AmtBal").css("color","green");
            $("#lbl_AllocErr").css("display","none");
        }
        currReceipt.Amount_Remaining__c = newBal;
        component.set("v.receipt", currReceipt);
    },
    
    saveRctCase: function(component, event, helper){
        console.log("C----------saveRctCase----------C");
        /// Get the Index of the corresponding Receipt Log from the Receipt Grid (Integer)
        var getIndex = component.get("v.Rindex");
        var currIndex = JSON.parse(JSON.stringify(getIndex));
        console.log("currIndex");
        console.log(currIndex);
        
        /// Get the details of the current receipt for which the cases are assigned (List)
        var getReceipt = component.get("v.receipt");
        var currReceipt = JSON.parse(JSON.stringify(getReceipt));
        console.log("currReceipt");
        console.log(currReceipt);
        
        /// Get the list of all receipts entered so far (Array of List)
        var getAllReceipt = component.get("v.receiptList");
        var currAllReceipt = JSON.parse(JSON.stringify(getAllReceipt));
        console.log("currAllReceipt");
        console.log(currAllReceipt);
        
        /// Get the list of all Cases added to the current receipt so far (Array of List)
        var getCaseList = component.get("v.casesMap");
        var currCaseList = JSON.parse(JSON.stringify(getCaseList));
        console.log("currCaseList");
        console.log(currCaseList);
        
        /// Get the list of all cases, that has been already added to this case. 
        /// This will be empty if no cases had been added already to this receipt.
        var getOldAllCase = component.get("v.allCaseList");
        var currOldAllCases = JSON.parse(JSON.stringify(getOldAllCase));
        console.log("currOldAllCases");
        console.log(currOldAllCases);
        
        /// Exit if no case is added
        if (currCaseList == null || currCaseList == []){
            console.log("###Exit if no case is added###");
            document.getElementById("CasesModal").style.display = "none";
        }
        else{
            if(currReceipt.Amount_Remaining__c == 0 || 
               currReceipt.Amount_Remaining__c == currReceipt.Payment_Amount__c || 
               currReceipt.Amount_Remaining__c == currReceipt.Deduction_Amount__c){
                /// Update the Amount remaining to the receipt
                console.log("###Update the Amount remaining to the receipt###");
                for(var j=0; j<currAllReceipt.length; j++){
                    if(currAllReceipt[j].Id == currReceipt.Id){
                        currAllReceipt[j].Amount_Remaining__c = currReceipt.Amount_Remaining__c
                    }
                }
                if(currOldAllCases == null){
                    var allCases = [];
                }
                else{
                    var allCases = currOldAllCases;
                }
                if(currCaseList.length>0){
                    if(allCases.length>0){
                        for(var i = allCases.length-1; i>=0; i--){
                            if(allCases[i].caseIndex == currIndex){
                                allCases.splice(i,1);
                            }
                        }
                    }
                    for(var i=0; i<currCaseList.length; i++){
                        currCaseList[i].caseDetail.caseIndex = currIndex;
                        allCases.push(currCaseList[i].caseDetail);
                    }
                    component.set("v.allCaseList", allCases);
                }
                /// All cases that's been added
                console.log("###All cases that's been added###");
                var getAllCase = component.get("v.allCaseList");
                var currAllCases = JSON.parse(JSON.stringify(getAllCase));
                console.log("allCaseList");
                console.log(currAllCases);
               
                if((currReceipt.Amount_Remaining__c != currReceipt.Payment_Amount__c ||
                    currReceipt.Amount_Remaining__c != currReceipt.Deduction_Amount__c)
                   && currAllCases.length>0){
                    /// Update the cases to the event and Save
                    console.log("###Update the cases to the event and Save###");
                    if(currCaseList.length != 0 && currReceipt.Amount_Remaining__c == 0){
                        console.log("Inside update cases");
                        console.log(currIndex);
                        console.log(currReceipt);
                        console.log(currCaseList);
                        console.log(currAllReceipt);
                        console.log(currAllCases);
                        currReceipt.Case_Assigned__c = true;
                        console.log("Test1");
                        for(var i=0; i<currAllReceipt.length; i++){
                            if(currAllReceipt[i].Id == currIndex){
                                currAllReceipt[i].Case_Assigned__c = true;
                            }
                    	}
                        console.log("Test2");
                        var rctCaseMap = {rctIndex: currIndex, rctDetail: currReceipt, casesList: currCaseList, allReceipts:currAllReceipt ,allCaseList: currAllCases};
                        console.log("Update the cases to the event and Save");
                        console.log(rctCaseMap);
                        var evt = $A.get("e.c:ReceiptCasePayment");
                        evt.setParams({"Pass_RctCase_Details": rctCaseMap});
                        evt.fire();
                        $("#lbl_AllocErr").css("display","None");
                        $('#searchInputId').val("");
                        component.set("v.cases", null);
                        component.set("v.casesMap", null);
                        component.set("v.ids", null);
                        document.getElementById("CasesModal").style.display = "none";
                    }
                    /// If added cases but amount not allocated
                    else if (currCaseList.length != 0 && currReceipt.Amount_Remaining__c != 0){
                        console.log("###If added cases but amount not allocated###");
                        $("#lbl_AmtBal").css("color","green");
                        $("#lbl_AllocErr").css("display","block");
                        $("#lbl_AllocErr").text("Allocate amount to each cases");
                    }
                    /// When all the cases, that's been added already is deleted
                        else if (currCaseList.length == 0 && currReceipt.Amount_Remaining__c != 0){
                            console.log("###When all the cases, that's been added already is deleted###");
                            currReceipt.Case_Assigned__c = false;
                        	currAllReceipt[currIndex].Case_Assigned__c = false;
                            var rctCaseMap = {rctIndex: currIndex, rctDetail: currReceipt, casesList: currCaseList, allReceipts:currAllReceipt ,allCaseList: currAllCases};
                            //var rctCaseMap = {allReceipts:currAllReceipt ,allCaseList: currAllCases};
                            console.log("When all the cases, that's been added already is deleted");
                            console.log(rctCaseMap);
                            var evt = $A.get("e.c:ReceiptCasePayment");
                            evt.setParams({"Pass_RctCase_Details": rctCaseMap});
                            evt.fire();
                            $("#lbl_AllocErr").css("display","None");
                            $('#searchInputId').val("");
                            component.set("v.cases", null);
                            component.set("v.casesMap", null);
                            component.set("v.ids", null);
                            document.getElementById("CasesModal").style.display = "none";
                        }
                }
                /// Exit if no case is added
                else{
                    console.log("###Exit if no case is added###");
                    document.getElementById("CasesModal").style.display = "none";
                }
            }
            
            /*** Only partial of total available amount is allocated. 
            Add cases only when all the cases and total allocation amount is known. 
            This should match the Payment or deduction amount. ***/
            else if(currReceipt.Amount_Remaining__c > 0 && 
                    (currReceipt.Amount_Remaining__c < currReceipt.Payment_Amount__c ||
                     currReceipt.Amount_Remaining__c < currReceipt.Deduction_Amount__c)){
                console.log("###Only partial of total available amount is allocated###");
                $("#lbl_AmtBal").css("color","green");
                $("#lbl_AllocErr").css("display","block");
                $("#lbl_AllocErr").text("Partial allocation of amount is not possible");
            }
            /*** Total amount allocated on cases cannot exceed the Payment Amount or Deduction Amount ***/
                else if(currReceipt.Amount_Remaining__c < 0){
                    console.log("###Total amount allocated on cases cannot exceed the Amount###");
                    $("#lbl_AmtBal").css("color","red");
                    $("#lbl_AllocErr").css("display","block");
                    $("#lbl_AllocErr").text("Allocation amount exceeds total available amount");
                }
        }
        
    },
    
    closeDialog: function(component, event, helper){
        console.log("C-----------closeDialog--------------C");
        $('#searchInputId').val("");
        component.set("v.cases", null);
        component.set("v.casesMap", null);
        component.set("v.ids", null);
        $("#lbl_AllocErr").css("display","None");
        document.getElementById("CasesModal").style.display = "none";
    }
})