({

    doInit: function (component, event, helper) {
        
        if(!component.get("v.isMove")){
            helper.createFormElements(component);
        }
        else{
            var options = [{label: "Select one", value: ""}];
            var fileTypeOptionsToMove = component.get("v.fileTypeOptionsToMove");

            for(var fileType in fileTypeOptionsToMove){
                
                options.push({label : fileType, value : fileType});
            }
            component.find("moveOptions").set("v.options", options);
            component.find("Private").set("v.disabled",true);
        }
        	
    },
    handleCancel: function (component, event, helper) {
        
        component.find("fileDialog").notifyClose();
    },
    edit: function (component, event, helper) {

        helper.editAttachment(component);
    },
    move: function (component, event, helper) {

        helper.editAttachment(component);
    },
    save: function (component, event, helper) {    
        
        $A.util.removeClass(component.find("dialogSpinner"), "slds-hide");
        setTimeout(function(){ helper.saveAttachment(component); }, 5);    
    },
    onMoveOptionSelect : function(component, event, helper) {
        
		var selectedoption = component.find("moveOptions").get("v.value");
        var disableMove = $A.util.isUndefined(selectedoption) || $A.util.isEmpty(selectedoption);
        component.find("move").set("v.disabled", disableMove);
        
        if(disableMove){
            return;
        }
        else{
            var fileTypeOptionsToMove = component.get("v.fileTypeOptionsToMove");
            component.set("v.isEdit",true);
            component.set('v.configDetails',fileTypeOptionsToMove[selectedoption].details);
            component.set('v.headerInfoWrapper',fileTypeOptionsToMove[selectedoption].columns);
			helper.createFormElements(component);
            component.find("Private").set("v.disabled",false);
        }
    },
    handleUploadFinished: function (component, event) {
        
        var fileInfo = event.getParam("files");
        if(!$A.util.isUndefined(fileInfo) && !$A.util.isEmpty(fileInfo) && fileInfo.length > 0) {
            
            component.find("fileUploader").set('v.disabled',true);
            var fileName = fileInfo[0].name;
            component.set('v.fileExtension',fileName.split('.').pop()); 
            component.find('File_Name').set('v.value',fileName.substring(0, fileName.lastIndexOf('.')));
            component.set('v.internalcontentDocId',fileInfo[0].documentId);
            
            var deleteInternalRecords = $A.get("e.c:A_Plus_DeleteInternalRecords");
            deleteInternalRecords.setParams({"internalcontentDocId": fileInfo[0].documentId,"fileType": component.get('v.fileType')});
            deleteInternalRecords.fire();
            
            component.set("v.isNoFilePresent", false); 
        }
    }
})