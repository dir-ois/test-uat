({
	createFormElements: function (component) {
        
        var isEdit = component.get("v.isEdit");
        var fileInfo = {File_Name : '',Private : false,Description : ''};     
        
        if(isEdit){
            
            fileInfo = component.get("v.fileInfo");
            fileInfo.Private = (fileInfo.Private == 'utility:check' || fileInfo.Private == true);
        }
        
        var requiredFields = ['File_Name'];

        var fileFields = component.get('v.headerInfoWrapper');
        var supportedDataTypes = {
            'picklist': 'ui:inputSelect',
            'text': 'ui:inputText',
            'checkbox': 'ui:inputCheckbox',
            'formatteddate': 'ui:inputDate'    
        };

		component.set("v.body", '');
        var body = component.get("v.body");
		
        for (var index = 0; index < fileFields.length; index = index + 1) {

            var fieldType = supportedDataTypes[fileFields[index].type.toLowerCase()];

            if (!$A.util.isUndefined(fieldType) && !$A.util.isEmpty(fieldType)) {

                if (!isEdit) {
                    if (fieldType == 'ui:inputCheckbox') {
                        fileInfo[fileFields[index].fieldName] = false;
                    } else {
                        fileInfo[fileFields[index].fieldName] = '';
                    }
                } else {
                    if (fieldType == 'ui:inputCheckbox') {
                        fileInfo[fileFields[index].fieldName] = (fileInfo[fileFields[index].fieldName] === 'utility:check');
                    }
                }


                var fieldAttributes = {
                    label: fileFields[index].label,
                    required: fileFields[index].required,
                    value: component.getReference('v.fileInfo.' + fileFields[index].fieldName)
                };

                if (fileFields[index].required) {
                    fieldAttributes['aura:id'] = fileFields[index].fieldName;
                    requiredFields.push(fileFields[index].fieldName);
                }

                if (fieldType == 'ui:inputSelect') {
                    fieldAttributes.options = JSON.parse(fileFields[index].values);
                }
                
                if (fieldType == 'ui:inputDate') {
                    fieldAttributes.displayDatePicker = true;
                }
                
                $A.createComponent(
                    fieldType,
                    fieldAttributes,
                    function (formElement) {
                        if (component.isValid()) {
                            body.push(formElement);
                        }
                    }
                );

                component.set("v.body", body);
            }
        }
        component.set("v.requiredFields", requiredFields);
        component.set('v.fileInfo', fileInfo);
    },

    editAttachment: function (component) {
        
		$A.util.removeClass(component.find("dialogSpinner"), "slds-hide");
        var requiredFields = component.get('v.requiredFields');

        for (var index = 0; index < requiredFields.length; index = index + 1) {

            var fieldValue = component.find(requiredFields[index]).get('v.value');

            if ($A.util.isUndefined(fieldValue) || $A.util.isEmpty(fieldValue)) {
                $A.util.addClass(component.find("dialogSpinner"), "slds-hide");
                alert('Please fill the required fields.');
                return;
            }
        }

        var fileInfo = component.get('v.fileInfo');
        var fileType = component.get('v.fileType');
        var isMove = component.get('v.isMove');
        var action = component.get('c.updateAttachment');
        var attId = fileInfo.id;
        delete fileInfo.id;
        delete fileInfo.linkId;

        action.setParams({
            fileInfoJSON: JSON.stringify(fileInfo),
            attachId: attId,
            fileType: !isMove ? fileType : component.find("moveOptions").get("v.value"),
            relatedRecordId: component.get('v.recordId'),
            configDetails : JSON.stringify(component.get('v.configDetails')),
            isMove : isMove
        });

        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				
                var fetchAttachmentinfo = $A.get("e.c:A_Plus_FetchAttachmentInfo");
                fetchAttachmentinfo.setParams({
                    "fileType": fileType
                });
                fetchAttachmentinfo.fire();
                
                if(isMove){
                    
                    var fetchAttachmentinfoMoveType = $A.get("e.c:A_Plus_FetchAttachmentInfo");
                    fetchAttachmentinfoMoveType.setParams({
                        "fileType": component.find("moveOptions").get("v.value")
                    });
                    fetchAttachmentinfoMoveType.fire();
                }

                component.find("fileDialog").notifyClose();

            } else if (state === "ERROR") {
                var errors = response.getError();  
                console.error(errors);
                alert('An error occured. Please reach out to administrator.');
            }
            $A.util.addClass(component.find("dialogSpinner"), "slds-hide");
        }));
        $A.enqueueAction(action);

    },

    saveAttachment: function (component) {

        var requiredFields = component.get('v.requiredFields');  
   
        for (var index = 0; index < requiredFields.length; index = index + 1) {

            var fieldValue = component.find(requiredFields[index]).get('v.value');

            if ($A.util.isUndefined(fieldValue) || $A.util.isEmpty(fieldValue)) {
                $A.util.addClass(component.find("dialogSpinner"), "slds-hide");
                alert('Please fill the required fields.');
                return;
            }
        }
        var fileInfo = component.get('v.fileInfo');

        delete fileInfo.linkId;

        var action = component.get('c.uploadFile');
        action.setParams({
            fileInfoJSON: JSON.stringify(fileInfo),
            internalcontentDocId: component.get('v.internalcontentDocId'),  
            fileType: component.get('v.fileType'),
            relatedRecordId: component.get('v.recordId'),
            fileName: fileInfo.File_Name + '.' + component.get('v.fileExtension'),
            configDetails : JSON.stringify(component.get('v.configDetails'))
        });

        action.setCallback(this, $A.getCallback(function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {

                var fetchAttachmentinfo = $A.get("e.c:A_Plus_FetchAttachmentInfo");
                fetchAttachmentinfo.setParams({
                    "fileType": component.get('v.fileType')
                });
                fetchAttachmentinfo.fire();

                component.find("fileDialog").notifyClose();   

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                alert('An error occured. Please reach out to administrator.');
            }
            $A.util.addClass(component.find("dialogSpinner"), "slds-hide");
        }));
        $A.enqueueAction(action);
    }
})