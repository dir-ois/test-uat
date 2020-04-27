({
    clearSearchValues : function(component) {
        component.set('v.searchValues', []);
    },
    
    parseInputKeyUp : function(component, event) {
        event.preventDefault();
        event.stopPropagation();
        var helper = this;
		
		console.log('parseInputKeyUp');

        var activeRecordId = component.get('v.activeRecordId');
        var searchValues = component.get('v.searchValues');
        
        var which = event.which;
        console.log(which);
        if (which == 38 || which == 40 || which == 13 || which == 27) {
            if (which == 27) {
                helper.clearSearchValues(component);
                return;
            }
            
            if (which == 13) {
                if (activeRecordId) {
                	helper.onRecordSelect(component, activeRecordId, component.get("v.activeRecordName"));
					$(".tt-menu").css("display", "none");
                }
                return;
            }
            
            if (!activeRecordId) {
                if (searchValues.length) {
                	component.set('v.activeRecordId', searchValues[0].Id);
                    component.set("v.activeRecordName", searchValues[0].Name);
                }
                return;
            }
            
            if (which == 38) {
                var i = searchValues.map(function(e){return e.Id}).indexOf(activeRecordId);
                if (i > 0) {
                    component.set('v.activeRecordId', searchValues[i-1].Id);
                    component.set("v.activeRecordName", searchValues[i-1].Name);
                }
            }
            if (which == 40) {
                var i = searchValues.map(function(e){return e.Id}).indexOf(activeRecordId);
                if (i < searchValues.length-1) {
                    component.set('v.activeRecordId', searchValues[i+1].Id);
                    component.set('v.activeRecordName', searchValues[i+1].Name);
                }
            }
        } else {
	        var query = event.target.value;
            helper.searchValues(component, query);
        }
    },
    
    onRecordSelect : function(component, recordId, recordName) {
        console.log(recordId);
        var helper = this;
        var unicId = component.get("v.unicId");
        var inputElement = $('[id="'+unicId+'_typeahead"]');
        inputElement.val(recordName);
		 if(unicId === 'payee01'){
			console.log("pass payee Id");
             var evt = $A.get("e.c:requireJSLoaded");
             evt.setParams({ "Pass_Lookup_Id":recordId});
             evt.fire();
         }else{
             var evt = $A.get("e.c:requireJSLoaded");
             evt.setParams({ "Pass_Lookup_Id_Deputy": recordId});
             evt.fire();
			console.log("pass deputy Id");
		 }
        $(".tt-menu").css("display", "none");
        helper.clearSearchValues(component);
    },
    
    searchValues : function(component, query) {
        var type = component.get("v.type");
        
        var action = component.get('c.getCurrentValue');
        var paramObj = {
            "searchVal" : query,
            "typeVal" : type
        };
        action.setParams(paramObj);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                component.set('v.searchValues', result);
            } else if (state === "ERROR") {
                var errorMessage = 'Unknown error';
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = "Error message: " + errors[0].message;
                }
                
                console.log(errorMessage);
            }
        });
        
        $A.enqueueAction(action); 
    }
    
})