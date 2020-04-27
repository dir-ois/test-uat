({
    doInit : function(component, event, helper) {
       
    },
    
    getReceiptsFromEvent: function(cmp, event, helper) {
        console.log("C----------getReceiptsFromEvent----------C");
        var ShowResultValue = event.getParam("Pass_Result_List");
        var officeUnit_Val = event.getParam("Pass_OfficeUnit_VAL");
        var depositAccount_val = event.getParam("Pass_DepositAcc_VAL");
        
        var resetEdit = event.getParam("Pass_Reset_Edit");
        if(resetEdit){
            cmp.set("v.receiptPending", null);
        }
        
        if(officeUnit_Val != null && depositAccount_val != null){
            cmp.set("v.officeUnit", officeUnit_Val);
            cmp.set("v.depositeAcc", depositAccount_val);
        }
        
        // set the handler attributes based on event data
        if(ShowResultValue != null){
            cmp.set("v.receiptPending", null);
            var newReceipt = ShowResultValue;
            var receipts = cmp.get("v.receipts");
            receipts.push(newReceipt);
            cmp.set("v.receipts", receipts);
            console.log(receipts);
        }
        
    },
    
    getRctCaseDetails: function(component, event, helper){
        console.log("C----------getRctCaseDetails----------C");
        var getRctCase = event.getParam("Pass_RctCase_Details");
        var currRctCase = JSON.parse(JSON.stringify(getRctCase));
        console.log("Receipts & Cases from EVent");
        console.log(currRctCase);
        if(currRctCase != null){
            var newRctCase = currRctCase;
            var getReceiptCases = component.get("v.receiptCases");
            var receiptCases = JSON.parse(JSON.stringify(getReceiptCases));
            console.log("Existing receiptCases");
            console.log(receiptCases);
            console.log("New newRctCase");
            console.log(newRctCase);
            var check = 0;
            if(receiptCases.length == 0 && check == 0){
                receiptCases.push(newRctCase);
            }
            else{
                for(var i=0; i<receiptCases.length; i++){
                    if(receiptCases[i].rctIndex == newRctCase.rctIndex ){
                        receiptCases[i] = newRctCase
                        check = 1
                        //console.log("Case is added");
                    }
                }
                if(check != 1){
                    receiptCases.push(newRctCase);
                    //console.log("Case is not added");
                }
            }
                       
            component.set("v.receiptCases",receiptCases);
            component.set("v.allCaseList", currRctCase.allCaseList);
            component.set("v.receipts", currRctCase.allReceipts);
            console.log("After Component Set");
            console.log(receiptCases);
            console.log(currRctCase.allCaseList);
            console.log(currRctCase.allReceipts);
        }
        //Indicate the presence of Case to the Payment
        helper.getAllRecordTypes(component, event);
    },
    
    deleteReceipt:  function(component, event, helper) {
        console.log("C----------deleteReceipt----------C");
        var self = this;  // self reference
        var index = event.currentTarget.dataset.index;
        helper.removeReceipt(component, index, event);
    },
    
    
    editReceipt: function(component, event, helper){
        console.log("C----------editReceipt----------C");
        var self = this;  // safe reference
        var index = event.currentTarget.dataset.index;
        helper.editThisReceipt(component, index, event);
    },
    
    
    saveReceiptCase: function(component, event, helper){
        console.log("C----------saveReceiptCase----------C");
        component.set("v.btnDisable",true);
        var BtnPressed = event.getSource().getLocalId();
        if (BtnPressed == "saveReceiptsBtn"){
            var redirect = true;
        }
        else if (BtnPressed == "saveNewReceiptBtn"){
            var redirect = false;
        }
        //var getRctCaseMap = component.get("v.receiptCases");
        //var receiptCaseMap = JSON.parse(JSON.stringify(getRctCaseMap));
        //console.log(receiptCaseMap);
        var getReceipts = component.get("v.receipts");
        var receipts = JSON.parse(JSON.stringify(getReceipts));
		console.log(receipts);
        var getAllCases = component.get("v.allCaseList");
        var allCases = JSON.parse(JSON.stringify(getAllCases));
		console.log(allCases);
        
        helper.insertReceiptCase(component, receipts, allCases, redirect);
    },
    
    cancelReceipts: function(cmp, event, helper){
        console.log("C----------cancelReceipts----------C");
        component.set("v.btnDisable",true);
        window.location.pathname = "/home/home.jsp"
    },
    
    openDialog: function(component, event, helper){
        console.log("C----------openDialog----------C");
        var self = this;  // safe reference
        component.set("v.btnDisable",false);
        var index = event.currentTarget.dataset.index;
        console.log(index);
        helper.openCaseDetail(component, event, index);
    }
    
})