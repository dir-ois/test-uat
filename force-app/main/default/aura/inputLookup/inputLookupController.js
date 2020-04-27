({
    onInputKeyUp: function(component, event, helper){
        helper.parseInputKeyUp(component, event);
		var unicId = component.get('v.unicId');
        $("."+ unicId + "_tt-menu").css("display", "block");
    },
    
    onRecordClick: function(component, event, helper){
        var recordId = event.target.dataset.id;
        var recordName = event.target.dataset.name;
        helper.onRecordSelect(component, recordId, recordName);
        $(".tt-menu").css("display", "none");
    },
    
    letsReset : function(component, event, helper){
        var unicId = component.get("v.unicId"); //getting unique id
        var inputElement = $('[id="'+unicId+'_typeahead"]'); //preparing ID of the input Field
        inputElement.val(""); //Setting the field value blank
    }
})