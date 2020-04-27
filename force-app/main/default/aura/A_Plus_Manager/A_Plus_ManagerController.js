({
    formDataTypeSections: function (component, event, helper) {                               
        
        helper.formDataTypeSections(component);           
    },
    onSearchClear: function (component, event, helper) {                
        var searchKey = component.get('v.searchKey').trim();
        if($A.util.isUndefined(searchKey) || $A.util.isEmpty(searchKey)){
            helper.formDataTypeSections(component);
        }
    }
})