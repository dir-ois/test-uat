({	
    init: function (component, event, helper) {   
		 var fileType = component.get('v.fileType');                 
         var headersAndDataInfo = component.get('v.headersAndDataInfo');   
         var actions = [
                        { label: 'Info', name: 'View' }, 
                        { label: 'Edit', name: 'Edit' },
                        { label: 'Delete', name: 'Delete' },
                        { label: 'View/Share/Download', name: 'Share' }
                    ];
             
         for (var filetypeOption in headersAndDataInfo) {      
             if(fileType != filetypeOption){
                 actions.push({ label: 'Move', name: 'Move' });
             	 break;
             }
         }
             
        var headeractions = [{ type: 'action', typeAttributes: { rowActions: actions, menuAlignment: "auto" } }]; 
         var columns = component.get('v.filesInfoWrapper').columns;
         var columnsTobedisplayed = [{label: 'File Name', fieldName: 'File_Name', type: 'text'},
                                     {label: 'Private', fieldName: 'Private', type: 'checkbox',cellAttributes : {iconName: { 'fieldName' : 'Private'}}}
                                    ];
        
         for(var index = 0; index < columns.length; index = index + 1){
             if(columns[index].showInSummary){
                 
                 if(columns[index].type == 'checkbox'){
                     columns[index].cellAttributes = {iconName: { fieldName: columns[index].fieldName}};
                 }
                 
                 columnsTobedisplayed.push(columns[index]);
             }
         }
         component.set('v.columns',headeractions.concat(columnsTobedisplayed));
         
    },
    onSearchClear: function (component, event, helper) {   
        var searchKey = component.get('v.searchKey').trim();
        if($A.util.isUndefined(searchKey) || $A.util.isEmpty(searchKey)){
            helper.fetchData(component,event);
        }
    },
    handleShowModal: function(component, event, helper) {
        
        var modalBody;
        var filesInfoWrapper = component.get('v.filesInfoWrapper');
        
        $A.createComponent("c:A_Plus_FileDialog", { headerInfoWrapper : filesInfoWrapper.columns,
                                                    configDetails : filesInfoWrapper.details,
                                                    isEdit : false,
                                                    isMove : false,
                                                    fileType : component.get('v.fileType'),
                                                    recordId : component.get('v.recordId'),
                                                    fileInfo : {}},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('fileDialog').showCustomModal({
                                       header: "Upload File",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "",
                                       closeCallback: function() {
                                           
                                           helper.deleteInternalRecords(component);
                                       }
                                   })
                                   
                               }
                               
                           });
    },
    
	handleRowAction: function (component, event, helper) {
        
        var action = event.getParam('action');
        var row = event.getParam('row');
         
        switch (action.name) {
            case 'View':
                 	var redirectToRecord = $A.get("e.force:navigateToSObject");
                    redirectToRecord.setParams({"recordId": row.id});
                    redirectToRecord.fire();
                	break;
            case 'Delete':
                	$A.util.removeClass(component.find("sectionSpinner"), "slds-hide");
                    var action = component.get('c.deleteAttachment');     
                	action.setParams({ attachId: row.id});
                    action.setCallback(this, $A.getCallback(function (response) { 
                        var state = response.getState();
                        
                        if (state === "SUCCESS") {                 
                        	 helper.fetchData(component,event);
                        } else if (state === "ERROR") {
                            var errors = response.getError();
                            console.error(errors);
                            alert('An error occured. Please reach out to administrator.');
                        }
                        $A.util.addClass(component.find("sectionSpinner"), "slds-hide");
                    }));
                    $A.enqueueAction(action); 
                    break;
             case 'Share':
                	var redirectToRecord = $A.get("e.force:navigateToSObject");  
                    redirectToRecord.setParams({"recordId": row.linkId});
                    redirectToRecord.fire();
                    break;
             case 'Edit':
                    var modalBody;
                	var filesInfoWrapper = component.get('v.filesInfoWrapper');
                	$A.createComponent("c:A_Plus_FileDialog", 
                                       {headerInfoWrapper : filesInfoWrapper.columns,
                                        configDetails : filesInfoWrapper.details,
                                        fileType : component.get('v.fileType'),
                                        isEdit : true,
                                        isMove : false,
                                        fileInfo : row,
                                        recordId : component.get('v.recordId')
                                       },
                                   function(content, status) {
                                       if (status === "SUCCESS") {
                                           modalBody = content;
                                           component.find('fileDialog').showCustomModal({
                                               header: "Edit File",
                                               body: modalBody, 
                                               showCloseButton: true,
                                               cssClass: "",
                                               closeCallback: function() {
                                                   
                                               }
                                           })
                                           
                                       }
                                       
                                   });
                    break;
            case 'Move':
                var modalBody;
                var fileType = component.get('v.fileType');                 
                var headersAndDataInfo = component.get('v.headersAndDataInfo');   
                var fileTypeOptionsToMove = {};
                
                for (var filetypeOption in headersAndDataInfo) {
                    
                    if(fileType != filetypeOption && filetypeOption != 'Related Files'){ 
                        fileTypeOptionsToMove[filetypeOption] = headersAndDataInfo[filetypeOption];
                    }
                }
                
                $A.createComponent("c:A_Plus_FileDialog", 
                                   {
                                    isMove : true,
                                    isEdit : true,
                                    fileInfo : row,
                                    recordId : component.get('v.recordId'),
                                    fileType : fileType,   
                                    fileTypeOptionsToMove : fileTypeOptionsToMove   
                                   },
                                   function(content, status) {
                                       if (status === "SUCCESS") {
                                           modalBody = content;
                                           component.find('fileDialog').showCustomModal({
                                               header: "Move File",
                                               body: modalBody, 
                                               showCloseButton: true,
                                               cssClass: "",
                                               closeCallback: function() {
                                                   
                                               }
                                           })
                                           
                                       }
                                       
                                   });
                break;
        }
   },
   fetchAttachmentinfo: function (component, event, helper) {
       
       if(event.getParam("fileType") === component.get('v.fileType')){
          helper.fetchData(component,event); 
       }
       
   },
   search : function (component, event, helper) {
       
       helper.fetchData(component,event); 
   },
   setInternalcontentDocId: function (component, event) {
       
       if(event.getParam("fileType") === component.get('v.fileType')){
           	
            component.set('v.internalcontentDocId',event.getParam("internalcontentDocId")); 
       }
   }
})