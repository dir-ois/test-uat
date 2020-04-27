public with sharing class GenerateFieldHistory {
	/*
	private static Map<String,Map<String,Schema.SObjectField>> fieldMaps = new Map<String,Map<String,Schema.SObjectField>>();
	private static List<Case_History__c> newHistList = new List<Case_History__c>();
	private static List<Attachments_Plus__c> newAttPlusList = new List<Attachments_Plus__c>();
	//private static Map<String, History_Object_Configuration__c> histMap = new Map<String, History_Object_Configuration__c>();
	private static Map<Id, sObject> sObjMap = new Map<Id, sObject>();
	private static Map<String, Set<String>> filterMap = new Map<String, Set<String>>();
	private static Map<String, Attachment_Configuration__c> startsWithMap = new Map<String, Attachment_Configuration__c>();
	private static Map<String, Attachment_Configuration__c> containsMap = new Map<String, Attachment_Configuration__c>();
	private static Map<String, Attachment_Configuration__c> equalsMap = new Map<String, Attachment_Configuration__c>();
	private static String pathToParent;
	
	public static void checkHistoryConfig(List<sObject> newList, Map<Id, sObject> oldMap){
		String sObjectName = newList[0].getSObjectType().getDescribe().getName();
		History_Object_Configuration__c hist = (History_Object_Configuration__c)selectSObjectHistory(sObjectName);
		if(hist != null){
			pathToParent = hist.Path_to_Case__c;
			getSObjectMap(newList, hist, sObjectName);
			if(sObjectname == 'Task' || sObjectName == 'Event'){
				checkActivityUpdate(newList, OldMap, hist, sObjectName);
			}
			else if(sObjectName == 'Attachment'){
				getFilterMap(hist);
				checkAttachmentInsert(newList, hist, sObjectName);
			}
			else{
				checkFieldUpdate(newList, OldMap, hist, sObjectName);
			}
			if(!newHistList.isEmpty()){
				insert newHistList;
				newHistList = new List<Case_History__c>(); 
			}
			system.debug('****************newAttPlusList: '+newAttPlusList);
			if(!newAttPlusList.isEmpty()){
				insert newAttPlusList;
				newAttPlusList = new List<Attachments_Plus__c>();
			}
		}
	}
	
	private static void getFilterMap(History_Object_Configuration__c hist){
		for(Attachment_Configuration__c ac : hist.History_Field_Configuration1__r){
			if(ac.Attachment_Operator__c != null && ac.Attachment_Criteria__c != null){
				Set<String> tempSet = new Set<String>();
				if(!filterMap.containsKey(ac.Attachment_Operator__c)){
					tempSet.add(ac.Attachment_Criteria__c);
					filterMap.put(ac.Attachment_Operator__c, tempSet);
				}
				else{
					tempSet = filterMap.get(ac.Attachment_Operator__c);
					tempSet.add(ac.Attachment_Criteria__c);
					filterMap.put(ac.Attachment_Operator__c, tempSet);
				}
				system.debug('********************ac.Attachment_Operator__c: '+ac.Attachment_Operator__c);
				system.debug('********************ac.Attachment_Criteria__c: '+ac.Attachment_Criteria__c);
				if(ac.Attachment_Operator__c == 'Starts With' && !startsWithMap.containsKey(ac.Attachment_Criteria__c)){
					system.debug('********************HERE!: ');
					startsWithMap.put(ac.Attachment_Criteria__c, ac);
				}
				if(ac.Attachment_Operator__c == 'Contains' && !containsMap.containsKey(ac.Attachment_Criteria__c)){
					containsMap.put(ac.Attachment_Criteria__c, ac);
				}
				if(ac.Attachment_Operator__c == 'Equals' && !equalsMap.containsKey(ac.Attachment_Criteria__c)){
					equalsMap.put(ac.Attachment_Criteria__c, ac);
				}
			}
		}
	}
	
	private static void checkAttachmentInsert(List<sObject> newList, History_Object_Configuration__c hist, String sObjectName){
		List<Id> idList = new List<Id>();
		List<History_Object_Configuration__c> hocList = [SELECT Id, Name, Active__c, Object_API_Name__c, Object_Name__c, Path_to_Case__c FROM History_Object_Configuration__c WHERE Active__c = true];
		Map<String, History_Object_Configuration__c> histMap = new Map<String, History_Object_Configuration__c>();
		String thisObjName;
		for(History_Object_Configuration__c h : hocList){
			if(!histMap.containsKey(h.Object_API_Name__c)){
				histMap.put(h.Object_API_Name__c, h);
			}
		}
		//thisObjName = s.getSObjectType().getDescribe().getName();
		for(sObject s : sObjMap.values()){
			idList.add(string.valueOf(s.get('parentId')));
			Id pId = (Id)s.get('parentId');
			thisObjName = pId.getSObjectType().getDescribe().getName();
			
			//SchemaGlobalDescribe.findObjectNameFromRecordIdPrefix(prefix);
			system.debug('**************thisObjName22: '+thisObjName);
			//This will need to move when support for mutliple atts comes
		}
		String operator;
		String idVar;
		String queryStr = 'SELECT Id, Name, ';
		if(idList.size() == 1){
			operator = '=';
			idVar = '\''+idList[0]+'\'';
		}
		else{
			//Not Supported currently
			operator = 'IN';
			idVar = string.valueOf(idList);
		}
		system.debug('*************thisObjNameAtt: '+thisObjName);
		system.debug('*************sObjectNameAtt: '+sObjectName);
		History_Object_Configuration__c thisHist = histMap.get(thisObjName);
		if(thisHist == null){
			return;
		}
		pathToParent = thisHist.Path_to_Case__c;
		if(thisObjName == 'DIR_Case__c'){ //use prefix to find name comparison
			queryStr = queryStr.replace('Id,','');
			pathToParent = 'Id';
		}
		else if(pathToParent == null || pathToParent == ''){
			pathToParent = 'parentId';
		}
		else{
			pathToParent += '.Id';
		}
		queryStr += pathToParent+' FROM '+thisObjName+' WHERE Id '+operator+' '+idVar;
		system.debug('****************queryStrqueryStr: '+queryStr);
		List<sObject> sObjectList = database.query(queryStr);
		Map<String, sObject> parentSObjMap = new Map<String, sObject>();
		for(sObject s : sObjectList){
			parentSObjMap.put(s.Id, s);
		}
		//Map<Id, sObject> parentSObjMap = new Map<Id, sObject>([SELECT Id, Name FROM sObject WHERE Id IN: idList]);
		for(sObject s : sObjMap.values()){
			//String thisObjName = s.getSObjectType().getDescribe().getName();
			//History_Object_Configuration__c thisHist = histMap.get(thisObjName);
			Attachment att = (Attachment)s;
			//pathToParent = thisHist.Path_to_Case__c;
			sObject parentsObj = parentSObjMap.get(string.valueOf(s.get('parentId')));
			system.debug('***************parentsObj: '+parentsObj);
			system.debug('***************parentSObjMap: '+parentSObjMap);
			String parentId = getParentId(parentsObj, parentsObj.getSObjectType().getDescribe().getName());
			system.debug('***************ATTparentId: '+parentId);
			system.debug('***************filterMap: '+filterMap);
			for(String str : filterMap.keySet()){
				Set<String> tempSet = filterMap.get(str);
				for(String cStr : tempSet){
					String compareString = cStr;
					String attName = att.Name;
					Boolean createAP = false;
					Map<String, Attachment_Configuration__c> acConfigMap = new Map<String, Attachment_Configuration__c>();
					system.debug('********************startsWithMap: '+startsWithMap);
					system.debug('********************containsMap: '+containsMap);
					system.debug('********************equalsMap: '+equalsMap);
					if(str == 'Starts With'){
						acConfigMap = startsWithMap;
						system.debug('*********************HERE????: '+acConfigMap);
						if(cStr.length() > attName.length()){
							cStr = cStr.subString(0, attName.length());
						}
						system.debug('*********************attName: '+attName);
						system.debug('*********************cStr: '+cStr);
						if(attName.subString(0, cStr.length()) == cStr){
							createAP = true;
						}
					}
					else if(str == 'Contains' && attName.contains(cStr)){
						acConfigMap = containsMap;
						createAP = true;
					}
					else if(str == 'Equals' && attName == cStr){
						acConfigMap = equalsMap;
						createAP = true;
					}
					if(createAP = true){
						system.debug('************acConfigMap: '+acConfigMap);
						Attachment_Configuration__c thisAC = acConfigMap.get(cStr);
						if(thisAC != null){
							system.debug('************thisAC: '+thisAC);
							Attachments_Plus__c ap = new Attachments_Plus__c(
								Attachment_ID__c = att.Id,
								Attachment_Name__c = att.Name,
								Attorney_Client_Privilege__c = thisAC.Attorney_Client_Privilege__c,
								//Case_Management__c,
								Confidential__c = thisAC.Confidential__c,
								//Description__c =,
								Not_Subject_to_PRA__c = thisAC.Not_Subject_to_PRA__c,
								Object__c = thisObjName,
								Parent_Record_ID__c = parentId,
								Record_ID__c = string.valueOf(sObjMap.get(att.Id).get('parentId')),
								Type__c = thisAC.Type__c
							);
							newAttPlusList.add(ap);
						}
					}
				}
			}
			
		}
	}
	
	private static void checkActivityUpdate(List<sObject> newList, Map<Id, sObject> oldMap, History_Object_Configuration__c hist, String sObjectName){
		SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
		Map<String,Schema.SObjectField> sObjFieldMap;
		sObjFieldMap = sObjectType.getDescribe().fields.getMap();
		Map<String, String> statusMap = new Map<String, String>();
		Set<String> eventTypes = new Set<String>();
		for(Activity_Configuration__c ac : hist.Activity_Configuration__r){
			if(sObjectName == 'Task'){
				statusMap.put(ac.Activity_Type__c, ac.Tracked_Statuses__c);
			}
			else if(sObjectName == 'Event'){
				eventTypes.add(ac.Activity_Type__c);
			}
		}
		for(sObject newSObject : newList){
			sObject oldSObject = oldMap.get(newSObject.Id);
			Map<String, String> newFieldValues = new Map<String, String>();
			Map<String, String> oldFieldValues = new Map<String, String>();
			String parentId = getParentId(newSObject, sObjectName);
			for(String s : sObjFieldMap.keySet()){
				newFieldValues.put(s, String.valueOf(newSObject.get(s)));
				oldFieldValues.put(s, String.valueOf(oldSObject.get(s)));
			}
			if(!statusMap.isEmpty()){
				String activityType = string.valueOf(newSObject.get('type'));
				if(statusMap.containsKey(activityType)){
					String trackedStatuses = statusMap.get(activityType);
					String newVal = newFieldValues.get('status');
					String oldVal = oldFieldValues.get('status');
					if(newVal != oldVal){
						Case_History__c newHist = new Case_History__c(
							Case_Management__c = parentId,
							Field_Name__c = 'Status Change For: '+activityType,
							Type__c = sObjectName,
							New_Value__c = newVal,
							Old_Value__c = oldVal,
							Object__c = sObjectName,
							Record_ID__c = newFieldValues.get('id')
						);
						newHistList.add(newHist);
					}
				}
			}
			else if(!eventTypes.isEmpty()){
				String eventType = string.valueOf(newSObject.get('type'));
				if(eventTypes.contains(eventType)){
					Case_History__c newHist = new Case_History__c(
						Case_Management__c = parentId,
						Field_Name__c = 'Status for: '+eventType,
						Type__c = sObjectName,
						New_Value__c = newFieldValues.get('status'),
						Old_Value__c = oldFieldValues.get('status'),
						Object__c = sObjectName,
						Record_ID__c = newFieldValues.get('id')
					);
					newHistList.add(newHist);
				}
			}
		}
	}
	
	private static void checkFieldUpdate(List<sObject> newList, Map<Id, sObject> oldMap, History_Object_Configuration__c hist, String sObjectName){
		SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
		Map<String,Schema.SObjectField> sObjFieldMap;
		sObjFieldMap = sObjectType.getDescribe().fields.getMap();
		for(sObject newSObject : newList){
			String rtId;
			try{
				rtId = string.valueOf(sObjMap.get(newSObject.Id).get('RecordTypeId'));
			}
			catch(exception ex){}
			sObject oldSObject = oldMap.get(newSObject.Id);
			Map<String, String> newFieldValues = new Map<String, String>();
			Map<String, String> oldFieldValues = new Map<String, String>();
			for(String s : sObjFieldMap.keySet()){
				newFieldValues.put(s, String.valueOf(newSObject.get(s)));
				oldFieldValues.put(s, String.valueOf(oldSObject.get(s)));
			}
			for(History_Field_Configuration__c hc : hist.History_Field_Configuration__r){
				if((hc.Tracked_Record_Types__c == null || hc.Tracked_Record_Types__c == 'ALL') 
				|| (hc.Tracked_Record_Types__c != null && rtId != null && hc.Tracked_Record_Types__c.contains(rtId))){
					String newVal = newFieldValues.get(hc.API_Field_Name__c.tolowerCase());
					String oldVal = oldFieldValues.get(hc.API_Field_Name__c.tolowerCase());
					if(newVal != oldVal){
						String parentId = getParentId(newSObject, sObjectName);
						Case_History__c newHist = new Case_History__c(
							Case_Management__c = parentId,
							Field_Name__c = hc.API_Field_Name__c,
							Type__c = 'Field Update',
							New_Value__c = newVal,
							Old_Value__c = oldVal,
							Object__c = sObjectName,
							Record_ID__c = newFieldValues.get('id')
						);
						newHistList.add(newHist);
					}
				}
			}
		}
	}
	
	private static String getParentId(sObject newSObject, String sObjectName){
		sObject tempSobj = sObjMap.get(newSObject.Id);
		if(tempSobj == null){
			tempSobj = newSObject;
		}
		String idVal;
		system.debug('***************sObjectName: '+sObjectName);
		if(sObjectName == 'Attachment'){
			idVal = 'parentId';
		}
		else if(sObjectName == 'Task' || sObjectName == 'Event'){
			idVal = 'WhatId';
		}
		else{
			idVal = 'Id';
		}
		system.debug('***************idVal: '+idVal);
		system.debug('***************tempSobj38: '+tempSobj);
		String parentId = string.valueOf(tempSobj.get(idVal));
		if(pathToParent.contains('.Id')){
			String tempPathToParent = pathToParent.replace('.Id', '');
			List<String> tempList = tempPathToParent.split('\\.');
			if(tempList.size() == 1){
				parentId = string.valueOf(tempSobj.getsObject(tempList[0]).get('Id'));
			}
			else if(tempList.size() == 2){
				parentId = string.valueOf(tempSobj.getsObject(tempList[0]).getsObject(tempList[1]).get('Id'));
			}
			else if(tempList.size() == 3){
				parentId = string.valueOf(tempSobj.getsObject(tempList[0]).getsObject(tempList[1]).getsObject(tempList[2]).get('Id'));
			}
		}
		return parentId;
	}
	
	private static void getSObjectMap(List<sObject> newList, History_Object_Configuration__c hist, String sObjectName){
		String queryStr;
		system.debug('***************pathToParent: '+pathToParent);
		system.debug('***************sObjectName: '+sObjectName);
		if(pathToParent == null || pathToParent == ''){
			if(sObjectName == 'Attachment'){
				pathToParent = 'parentId';
			}
			else if(sObjectName == 'Task' || sObjectName == 'Event'){
				pathToParent = 'WhatId';
			}
			else{
				pathToParent = 'Id';
			}
			queryStr = 'SELECT '+pathToParent;
		}
		else{
			pathToParent += '.Id';
			queryStr = 'SELECT Id, '+pathToParent;
		}
		List<Id> idList = new List<Id>();
		for(sObject newSObject : newList){
			idList.add(newSObject.Id);
		}
		String operator;
		String idVar;
		if(idList.size() == 1){
			operator = '=';
			idVar = '\''+idList[0]+'\'';
		}
		else{
			operator = 'IN';
			idVar = string.valueOf(idList);
		}
		if(sObjectName != 'Task' && sObjectName != 'Event'){
			queryStr += ', Name';
		}
		queryStr += ', RecordTypeId FROM '+sObjectName+' WHERE Id '+operator+' '+idVar;
		//Map<Id, sObject> sObjMap;
		try{
			sObjMap = new Map <Id, sObject>(database.query(queryStr));
		}
		catch(exception e){
			if(e.getMessage().contains('RecordTypeId')){
				queryStr = queryStr.replace('RecordTypeId', 'CreatedDate');
			}
		}
		finally{
			if(sObjMap == null || sObjMap.isEmpty()){
				sObjMap = new Map <Id, sObject>(database.query(queryStr));
			}
		}
	}
	
	public static SObject selectSObjectHistory(String sObjectName){
		
		SObjectType sObjectType = Schema.getGlobalDescribe().get('History_Object_Configuration__c');
		Map<String,Schema.SObjectField> fldObjMap;
		
		fldObjMap = sObjectType.getDescribe().fields.getMap();
		
		if (fieldMaps.containsKey('History_Object_Configuration__c')) {
			fldObjMap = fieldMaps.get('History_Object_Configuration__c');
		}
		else {
			fldObjMap = sObjectType.getDescribe().fields.getMap();
			fieldMaps.put('History_Object_Configuration__c', fldObjMap);
		}
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
		String queryStr = 'SELECT ';
		for(Schema.SObjectField s : fldObjMapValues){
			Schema.DescribeFieldResult fieldResult= s.getDescribe();
		   
			String fieldName = fieldResult.getName();
			if (fieldResult.isAccessible()) {
		   		queryStr += fieldName + ',';
		   		
			}
		   
		}
		queryStr += ''
		+'(SELECT Id, Name, Active__c, API_Field_Name__c, History_Object_Configuration__c, Tracked_Record_Types__c FROM History_Field_Configuration__r WHERE Active__c = true),'
		+'(SELECT Id, Name, Active__c, Attachment_Criteria__c, Attachment_Operator__c,  History_Object_Configuration__c, Type__c, Attorney_Client_Privilege__c, Not_Subject_to_PRA__c, Confidential__c FROM History_Field_Configuration1__r WHERE Active__c = true),'
	  	+'(SELECT Id, Name, Active__c, Activity_Status__c, Activity_Type__c, Tracked_Statuses__c, History_Object_Configuration__c FROM Activity_Configuration__r WHERE Active__c = true)';
		queryStr += ' FROM History_Object_Configuration__c WHERE Object_API_Name__c = \''+sObjectName+'\' AND Active__c = true LIMIT 1';
		System.debug(queryStr);
		sObject tempSObject;
		try{
			tempSObject = Database.query(queryStr);
		}
		catch(exception e){
			system.debug('**************ERROR ON: '+sObjectName);
			return null;
		}
		return tempSObject;
	}
	*/
}