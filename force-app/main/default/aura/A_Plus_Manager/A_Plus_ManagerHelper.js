({
    formDataTypeSections: function (component) {
        
		$A.util.removeClass(component.find("loadspinner"), "slds-hide");
        var action = component.get('c.fetchHeadersAndData');
        var relatedRecId = component.get('v.recordId');

        action.setParams({
            relatedRecordId: relatedRecId,
            fileType: '',
            searchKey: component.get('v.searchKey')
        });

        action.setCallback(this, $A.getCallback(function (response) {   
            var state = response.getState();
            if (state === "SUCCESS") {

                var headersAndDataInfo = response.getReturnValue();  
                var isNotConfigured = $A.util.isUndefined(headersAndDataInfo) || $A.util.isEmpty(headersAndDataInfo);
                component.set('v.isNotConfigured',isNotConfigured);  
                
                if(isNotConfigured){
                    return;
                }
                
                var counter = 0;
				
                var accordionAndchildComponents = [["lightning:accordion",{}]];     
                
                for (var filetype in headersAndDataInfo) {
                    counter = counter + 1;
                    accordionAndchildComponents.push(['c:A_Plus_TypeSection', {
                                                        recordId: relatedRecId,
                                                        fileType: filetype,
                                                        index: counter,
                                                        searchKey: '',
                                                        filesInfoWrapper: headersAndDataInfo[filetype],
                        								headersAndDataInfo : headersAndDataInfo
                                                    }]);
                }
                
                $A.createComponents(
                        accordionAndchildComponents,
                         function(components, status, errorMessage){
                             if (status === "SUCCESS") {
                                 
                                 var acccordion = components[0];
                                 var accordionBody = []; 
                                 for(var index = 1; index < components.length; index = index + 1){     
                                     accordionBody.push(components[index]);
                                 }
                                 acccordion.set("v.body", accordionBody);     
                                 component.set("v.body", '');
                                 component.set("v.body", acccordion);                    
                                 
                             }
                         }
                 );
                

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            $A.util.addClass(component.find("loadspinner"), "slds-hide");
        }));
        
        $A.enqueueAction(action);
    }
})