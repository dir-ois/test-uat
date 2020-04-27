public with sharing class x607_Methods {

	public static void afterUpdate(List<x607__c> newList, List<x607__c> oldList){
		Set<Id> submittedIds = new Set<Id>();
		Map<Id, String> positionTo607Type = new Map<Id, String>();
		for ( Integer i=0;i<newList.size();i++ ){
			if ( newList[i].Status__c == 'Submitted to Budget' &&  oldList[i].Status__c != 'Submitted to Budget' ){
				submittedIds.add(newList[i].Id);
			}
		}
		
		List<Id> positionAdditionIds = new List<Id>();
		List<Id> positionDeletionIds = new List<Id>();
		
		List<Position__c> positionAdditionUpdates = new List<Position__c>();
		List<Position__c> positionDeletionUpdates = new List<Position__c>();
		List<X607_Position_Modification__c> lineItems = [Select Id, Classification__c, Position__c, Position__r.Id, Serial__c, Type__c, Unit__c, X607__c, X607__r.Type__c from X607_Position_Modification__c where x607__c in :submittedIds]; 
		for ( X607_Position_Modification__c x : lineItems ){
			if ( x.Type__c == 'Addition' && x.Position__c != null){
				positionAdditionIds.add(x.Position__c);
			} else 
			if ( x.Type__c == 'Deletion' && x.Position__c != null ){
				positionDeletionIds.add(x.Position__c);
				positionTo607Type.put(x.Position__c, x.X607__r.Type__c);
			} /*else 
			if ( x.Type__c == 'Modification' ){
				Position__c p = x.Position__r;
				p.Expiration_Date__c = String.valueOf(x.Expiration_date__c);
				positionUpdates.add(p);
			}*/
		}
		
		for(Position__c pos : [select Id, IsActive__c from Position__c where Id in :positionAdditionIds]) {
			pos.IsActive__c = true;
			pos.Status__c = 'Vacant';
			positionAdditionUpdates.add(pos);
		}
		
		for(Position__c pos : [select Id, IsActive__c from Position__c where Id in :positionDeletionIds]) {
			pos.IsActive__c = false;
			if(positionTo607Type.containsKey(pos.Id)) {
				if(positionTo607Type.get(pos.Id) != null && positionTo607Type.get(pos.Id) == 'Abolishment') {
					pos.Status__c = 'Abolished';
				}
				else {
					pos.Status__c = 'CLOSED';
				}
			}
			else {
				pos.Status__c = 'CLOSED';
			}
			positionDeletionUpdates.add(pos);
		}
		
		update positionAdditionUpdates;
		update positionDeletionUpdates;
		/*Set<Id> submittedIds = new Set<Id>();
		for ( Integer i=0;i<newList.size();i++ ){
			if ( newList[i].Status__c == 'Submitted to Budget' &&  oldList[i].Status__c != 'Submitted to Budget' ){
				submittedIds.add(newList[i].Id);
			}
		}
		//if Status == 'Submitted to Budget' then upsert the Positions
		//Approval needs to assign Approvals to Helen
		List<Position__c> positionInserts = new List<Position__c>();
		List<Position__c> positionUpdates = new List<Position__c>();
		List<X607_Position_Modification__c> lineItems = [Select Id, Classification__c, Expiration_Date__c, Position__c, Position__r.Id, Serial__c, Type__c, Unit__c, X607__c from X607_Position_Modification__c where x607__c in :submittedIds]; 
		for ( X607_Position_Modification__c x : lineItems ){
			if ( x.Type__c == 'Addition' ){
				Position__c newP = new Position__c();
				newP.Classification__c = x.Classification__c;
				newP.Unit__c = x.Unit__c;
				newP.Serial_Number__c = decimal.valueOf(x.Serial__c);
				positionInserts.add(newP);
			} else 
			if ( x.Type__c == 'Deletion' ){
				Position__c p = x.Position__r;
				p.Status__c = 'Closed';
				positionUpdates.add(p);
			} else 
			if ( x.Type__c == 'Modification' ){
				Position__c p = x.Position__r;
				p.Expiration_Date__c = String.valueOf(x.Expiration_date__c);
				positionUpdates.add(p);
			}
		}
		insert positionInserts;
		
		update positionUpdates;
		Integer i=0;
		for ( X607_Position_Modification__c x : lineItems ){
			if ( x.Type__c == 'Addition' ){
				x.Position__c = positionInserts[i].Id;
				i++;
			}
		}		
		update lineItems;*/
	}

}