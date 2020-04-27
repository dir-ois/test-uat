({
    initPicklists: function(component){
		var action = component.get("c.getDepositAccount");
        var inputsel = component.find("depositAccountId");
        var opts=[];
        action.setCallback(this, function(a) {
            
            for(var i=0;i< a.getReturnValue().length;i++){
                
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputsel.set("v.options", opts);
        });
        $A.enqueueAction(action);
		
		var action1 = component.get("c.getPaymentTypes");
        var inputsel1 = component.find("paymentTypesId");
        var opts1=[];
        action1.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
        });
        $A.enqueueAction(action1);

		var action2 = component.get("c.getBankLocation");
        var inputsel2 = component.find("bankLocationId");
        var opts2=[];
        action2.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts2.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputsel2.set("v.options", opts2);
        });
        $A.enqueueAction(action2);

		var action4 = component.get("c.getPaymentExchange");
        var inputsel4 = component.find("paymentExchangeId");
        var opts4=[];
        action4.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                if(a.getReturnValue()[i] != 'Reversal' && a.getReturnValue()[i] != 'Party to Party'){
                    opts4.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
            }
            inputsel4.set("v.options", opts4);
        });
        $A.enqueueAction(action4);

		var action5 = component.get("c.getOfficeUnit");
        var inputsel5 = component.find("officeUnitId");
        var opts5=[];
        action5.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts5.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputsel5.set("v.options", opts5);
        });
        $A.enqueueAction(action5);
		
	},
    
    /*resetForm: function(component, event){
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
            'Payor__r.Name' : '',
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
        
        component.set("v.totalAmt","$0.00");
        component.set("v.receiptLog.Payor__r.Name","");
        component.set("receiptLog.Payor__c.Name","");
        $('#payee01_typeahead').val("");
        //$("#payee01_typeahead").value = '';
        console.log("payee ----")
        $("#chqNotProcessed").css("display","none");
        $("#BankDepositDateIdField").css("display","none");
        $("#PaidFullDateId").css("display","none");
        $("#OtherReason").css("display","none");
    }*/

	getEditFieldsSet: function(component, event, receiptLog) {
        var action = component.get("c.getFields");
        var self = this;
        var typeName = "Receipt__c";
        var fsName = "ReceiptFieldSet";

		action.setParams({
			"typeName" : typeName,
			"fsName" : fsName
		});

		action.setCallback(this, function(response) {
				var state = response.getState();
				if (component.isValid() && state === "SUCCESS") {
					var fields = response.getReturnValue();
					var newList = []
					for(var i = 0; i < fields.length; i++){
						var val = receiptLog[fields[i].fieldPath];
						var pickListV = [];
						if(fields[i].fieldPath == 'Payment_Can_Be_Processed__c'){
							pickListV = ["Yes","No"];
						}
						var aux = {
									"fieldPath" : fields[i].fieldPath,
									"label" : fields[i].label,
									"type" : fields[i].type,
									"value" : val,
									"auraIndex" : "index-" + i,
									"pickListV" : pickListV
									};
						newList.push(aux);
					}
					component.set("v.fsValues", newList);

				}
			});

        $A.enqueueAction(action);      
    }
    

})