public virtual class RegistrationSearchNewController{

    public List<Registration_Crafts__mdt> filtersList{get;set;}
    public RegistrationSearchNewController(){
    
        filtersList=[SELECT MasterLabel, DeveloperName, field_api_name__c FROM Registration_Crafts__mdt order by MasterLabel];
    
    }
    
    @testVisible
    private static Date convertToDate(String strDate){
        List<String> dateValue;
        Integer day = 1;
        Integer month = 1;
        Integer year = 2019;
        if(strDate != null && String.isNotBlank(strDate)){
            if (strDate.indexof('-')>=0){
            	dateValue = strDate.split('-');
                day = Integer.valueOf(dateValue.get(2));
            	month = Integer.valueOf(dateValue.get(1));
            	year = Integer.valueOf(dateValue.get(0));
            }else{
                dateValue = strDate.split('/');
                day = Integer.valueOf(dateValue.get(1)); 
                month = Integer.valueOf(dateValue.get(0));
                year = Integer.valueOf(dateValue.get(2));
            }
            return Date.newInstance(year,month,day);
        }
        return null;
    }
    
    
    public static string generateCraftWhereClause(list<String> filters, String subLevel){
        
        list<Registration_Crafts__mdt> crafts =[SELECT MasterLabel, field_api_name__c FROM Registration_Crafts__mdt order by MasterLabel];        
        
        //TODO CSK Throw Registration_Crafts__mdt into a keyvalue pair map
        Map<String, String> CraftsMap = new Map<String, String>();
        for(Registration_Crafts__mdt craft:crafts){
            CraftsMap.put(craft.MasterLabel, craft.field_api_name__c);
        }
        
        String licenseRegQueryCraftFilters = '';    
        String prefix = '';
        if (subLevel != ''){
            prefix = subLevel+'.';
        }
        
        if(filters.size()>0){
            //CSK loop through the filters lists checked by the user                   
            for(String filter:filters){
                system.debug('$$$$filter is '+filter);
                //CSK check the map to get the cooresponding field_api_name__c
                system.debug('$$$$filter field api name ' + CraftsMap.get(filter));
                if (licenseRegQueryCraftFilters == ''){
                    licenseRegQueryCraftFilters += ' AND ( ' + prefix+CraftsMap.get(filter) + ' = TRUE ' ;
                }else{
                	licenseRegQueryCraftFilters += ' OR ' + prefix+CraftsMap.get(filter) + ' = TRUE ' ;
                }
            }
        }
        if (licenseRegQueryCraftFilters != ''){
        	licenseRegQueryCraftFilters += ')';
        }
        system.debug('$$$$licenseRegQueryCraftFilters' + licenseRegQueryCraftFilters);
        
        return licenseRegQueryCraftFilters;
        
        
    }
    public static string generateCraftWhereClause2(list<String> filters, String subLevel){
        
        list<Registration_Crafts__mdt> crafts =[SELECT MasterLabel, field_api_name__c FROM Registration_Crafts__mdt order by MasterLabel];        
        
        //TODO CSK Throw Registration_Crafts__mdt into a keyvalue pair map
        Map<String, String> CraftsMap = new Map<String, String>();
        for(Registration_Crafts__mdt craft:crafts){
            CraftsMap.put(craft.MasterLabel, craft.field_api_name__c);
        }
        
        String licenseRegQueryCraftFilters = '';    
        String prefix = '';
        if (subLevel != ''){
            prefix = subLevel+'.';
        }
        
        if(filters.size()>0){
            //CSK loop through the filters lists checked by the user                   
            for(String filter:filters){
                system.debug('$$$$filter is '+filter);
                //CSK check the map to get the cooresponding field_api_name__c
                system.debug('$$$$filter field api name ' + CraftsMap.get(filter));
                if (licenseRegQueryCraftFilters == ''){
                    licenseRegQueryCraftFilters += ' ( ' + prefix+CraftsMap.get(filter) + ' = TRUE ' ;
                }else{
                	licenseRegQueryCraftFilters += ' OR ' + prefix+CraftsMap.get(filter) + ' = TRUE ' ;
                }
            }
        }
        if (licenseRegQueryCraftFilters != ''){
        	licenseRegQueryCraftFilters += ') AND';
        }
        system.debug('$$$$licenseRegQueryCraftFilters' + licenseRegQueryCraftFilters);
        
        return licenseRegQueryCraftFilters;
        
        
    }
    
    @RemoteAction
    public static List<Object> getKeys(String searchBy, String startDate, String endDate, String county, String city, list<String> filters){
        Date strDate;
        Date expDate;        
        Integer remainder = Limits.getLimitDmlRows() - Limits.getDmlRows();
        system.debug('@@@limits - '+remainder);
        system.debug('@@@getkey - '+filters);
        Id PWRecordTypeId=Schema.SObjectType.License_Registration__c.getRecordTypeInfosByDeveloperName().get('Public_Works').getRecordTypeId();
        system.debug('@@@Public Work Record Id - '+PWRecordTypeId);
        String query='select id, License_Registration_Number__c from License_registration__c ';
        query+='WHERE recordtypeid=:PWRecordTypeId AND (status__c=\'Active\' OR status__c=\'Expired\' OR status__c=\'Disqualified\')';
        query += generateCraftWhereClause(filters,'') ;      
        if(String.isNotBlank(searchBy)){
            searchBy = EncodingUtil.urlDecode(searchBy, 'UTF-8');
            query+=' AND (Legal_Entity_Name__c like \'%'+searchBy+'%\'';
            query+=' OR License_Registration_Number__c like \'%'+searchBy+'%\')';
            //query+=' OR (License__r.License_Number__c like \'%'+searchBy+'%\' AND recordtypeid=:LicenseRecordTypeId)';
            
        }
        
        if(String.isNotBlank(city) && city != NULL){
            city = EncodingUtil.urlDecode(city, 'UTF-8');
            query+=' AND Mailing_City__c LIKE \'%'+city+'%\'';
        }    
        
        if(String.isNotBlank(county) && county != NULL){
            county = EncodingUtil.urlDecode(county, 'UTF-8');            
            query+=' AND Physical_Business_County__c LIKE \'%'+county+'%\''; 
        }
        
        if(String.isNotBlank(startDate) && String.isBlank(endDate)){
            strDate=convertToDate(startDate);
            query+=' AND (Effective_Date__c>=:strDate AND Effective_Date__c!=null)';
        }
        
        
        if(String.isNotBlank(endDate) && String.isBlank(startDate)){
            expDate=convertToDate(endDate);
            query+=' AND (Expiration_Date__c <=:expDate AND Expiration_Date__c!=null)';
        }

        if(String.isNotBlank(endDate) && String.isNotBlank(startDate)) {
            strDate=convertToDate(startDate);
            expDate=convertToDate(endDate);
            query+=' AND ((Effective_Date__c>=:strDate AND Effective_Date__c <= :expDate AND Effective_Date__c!=null) OR (Expiration_Date__c <=:expDate AND Expiration_Date__c >= :strDate AND Expiration_Date__c != null))';      
        }
        query += ' LIMIT :remainder';
        Set<id> AllRegIds=new set<id>();
        set<id> RegIds = new Set<Id>();
        if(searchBy != Null && String.isNotBlank(searchBy)){
            String DBAQuery='SELECT Id, Registration__c FROM DBA__c WHERE ';
            DBAQuery += generateCraftWhereClause2(filters,'Registration__r') ;
            if(String.isNotBlank(searchBy) && searchBy != NULL){
                searchBy = EncodingUtil.urlDecode(searchBy, 'UTF-8');
                DBAQuery += ' (Legacy_Name__c LIKE \'%' + searchBy + '%\' OR Name LIKE \'%' + searchBy + '%\') AND  ';
            }
            if(String.isNotBlank(city) && city != NULL){
                city = EncodingUtil.urlDecode(city, 'UTF-8');
                DBAQuery+=' Registration__r.Mailing_City__c LIKE \'%'+city+'%\' AND ';
            }    
            
            if(String.isNotBlank(county) && county != NULL){
                county = EncodingUtil.urlDecode(county, 'UTF-8');            
                DBAQuery+=' Registration__r.Physical_Business_County__c LIKE \'%'+county+'%\' AND '; 
            }
            
            if(String.isNotBlank(startDate) && String.isBlank(endDate)){
                strDate=convertToDate(startDate);
                DBAQuery+=' (Registration__r.Effective_Date__c>=:strDate AND Registration__r.Effective_Date__c!=null) AND';
            }
            
            
            if(String.isNotBlank(endDate) && String.isBlank(startDate)){
                expDate=convertToDate(endDate);
                DBAQuery+=' (Registration__r.Expiration_Date__c <=:expDate AND Registration__r.Expiration_Date__c!=null) AND';
            }
    
            if(String.isNotBlank(endDate) && String.isNotBlank(startDate)) {
                strDate=convertToDate(startDate);
                expDate=convertToDate(endDate);
                DBAQuery+=' ((Registration__r.Effective_Date__c>=:strDate AND Registration__r.Effective_Date__c <= :expDate AND Registration__r.Effective_Date__c!=null) OR (Registration__r.Expiration_Date__c <=:expDate AND Registration__r.Expiration_Date__c >= :strDate AND Registration__r.Expiration_Date__c != null)) AND';      
            }
            
            searchBy = EncodingUtil.urlDecode(searchBy, 'UTF-8');
            DBAQuery += ' (Legacy_Name__c LIKE \'%' + searchBy + '%\' OR Name LIKE \'%' + searchBy + '%\') AND  ';
            DBAQuery += ' (Registration__r.status__c=\'Active\' OR Registration__r.status__c=\'Expired\' OR Registration__r.status__c=\'Disqualified\')';
            DBAQuery += ' LIMIT :remainder';
            
            // CSK - Query to obtain DBAs where name is like Input Label
            List<DBA__c> allDBAReg = Database.query(DBAQuery);
            
            
            for(DBA__c rl: allDBAReg) {
                if(rl.Registration__c != null){
                    RegIds.add(rl.Registration__c);
                }
            }
            system.debug('###reg ids from dba is '+regIds.size());
            AllRegIds.addAll(RegIds);
        }
        system.debug('@@@query is '+query);
        // CSK - This query includes Search Filters and record type = 'Public_Works'        
        List<License_Registration__c> lrList= Database.query(query);
		system.debug('@@@queryResult is '+lrList);
        remainder = Limits.getLimitDmlRows() - Limits.getDmlRows();
        Id LicenseRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByDeveloperName().get('License').getRecordTypeId();
        String CSLBQuery='select id,license__c from License_Registration__c where (';
        if(searchBy != Null && String.isNotBlank(searchBy)){
            searchBy = EncodingUtil.urlDecode(searchBy, 'UTF-8');
            CSLBQuery += ' License_Number__c like \'%'+searchBy+'%\' AND';
        } 
        if(String.isNotBlank(city) && city != NULL){
            city = EncodingUtil.urlDecode(city, 'UTF-8');
            CSLBQuery+=' Mailing_City__c LIKE \'%'+city+'%\' AND';
        }    
        
        if(String.isNotBlank(county) && county != NULL){
            county = EncodingUtil.urlDecode(county, 'UTF-8');            
            CSLBQuery+=' Physical_Business_County__c LIKE \'%'+county+'%\' AND'; 
        }
        if(String.isNotBlank(startDate) && String.isBlank(endDate)){
            strDate=convertToDate(startDate);
            CSLBQuery+=' (Effective_Date__c>=:strDate AND Effective_Date__c!=null) AND';
        }
        
        
        if(String.isNotBlank(endDate) && String.isBlank(startDate)){
            expDate=convertToDate(endDate);
            CSLBQuery+=' (Expiration_Date__c <=:expDate AND Expiration_Date__c!=null) AND';
        }

        if(String.isNotBlank(endDate) && String.isNotBlank(startDate)) {
            strDate=convertToDate(startDate);
            expDate=convertToDate(endDate);
            CSLBQuery+=' ((Effective_Date__c>=:strDate AND Effective_Date__c <= :expDate AND Effective_Date__c!=null) OR (Expiration_Date__c <=:expDate AND Expiration_Date__c >= :strDate AND Expiration_Date__c != null)) AND';      
        }
        CSLBQuery+=' recordtypeid=:LicenseRecordTypeId AND License_Type__c=\'CSLB\' AND (license__r.status__c=\'Active\' OR license__r.status__c=\'Expired\' OR license__r.status__c=\'Disqualified\')';
        CSLBQuery+= generateCraftWhereClause(filters,'');
        CSLBquery += ')'; //end of where query
        CSLBquery += ' LIMIT :remainder';
        
        system.debug('@@@CSLB query is '+CSLBquery);
        // CSK - This query includes License_Type__c='CSLB' and record type = 'License'       
        List<License_Registration__c> CSLBlrList= Database.query(CSLBQuery);
        //system.debug('@@@CSLBResult is '+CSLBlrList);
        set<id> CSLBRegids=new set<id>();
        for(License_Registration__c cslblr: CSLBlrList){
            CSLBRegids.add(cslblr.license__c);
            
        }
        AllRegIds.addAll(CSLBRegids);
        remainder = Limits.getLimitDmlRows() - Limits.getDmlRows();

        
        // CSK - This query includes Search Filters and record type = 'Public_Works'                
        AllRegIds.addAll(new Map<id,License_Registration__c>(lrList).keySet());
		system.debug('###count with lrlist '+AllRegIds.size());        
		system.debug('###count with regIDs '+AllRegIds.size());        
		// CSK - Add query results that include License_Type__c='CSLB' and record type = 'License'  
        system.debug('Heap after mapping CSLB - '+Limits.getHeapSize());
		system.debug('###count with CSLBRegids '+AllRegIds.size());        
        set<String> regNumSet=new set<String>();
        for(License_Registration__c lrRec:[select id,License_Registration_Number__c from License_Registration__c where Id IN:AllregIds]){
            regNumSet.add(lrRec.License_Registration_Number__c);
        }
        system.debug('@@@@ Results Size' + AllRegIds.size());
        if(allRegIds.size()>0 && filters.size()>0){
            
            List<String> l=new List<String>();
            for(String s: AllRegIds){
                l.add(s);
            }
            system.debug('Heap after l.add - '+Limits.getHeapSize());
            
        	system.debug('@filters '+filters);            
            List<registrationSearchResultWrapper> regWrapperList = RegistrationSearchNewController.queryRegulations( new List<String>(regNumSet) ,filters);
            system.debug(regwrapperList.size());
            if(regWrapperList.size()>0){
                set<id> filteredregIds=new set<id>();
                system.debug('@@@' + regwrapperList.size());
                for(registrationSearchResultWrapper wrapObj: regWrapperList){
                    filteredregIds.add(wrapObj.lr.id);
                }
                AllRegIds= filteredregIds;
            }else{
                return new List<Object>();
            }
        }
        
        regNumSet=new Set<String>();

        remainder = Limits.getLimitDmlRows() - Limits.getDmlRows();

        for(License_Registration__c lrRec:[select id,License_Registration_Number__c from License_Registration__c where Id IN:AllregIds LIMIT :remainder]){
            regNumSet.add(lrRec.License_Registration_Number__c);
        }
        system.debug('Heap after lrec - '+Limits.getHeapSize());
        List<Object> regInfo = new List<Object>();
        regInfo.add(AllRegIds);
        system.debug('Heap after all reg ids - '+Limits.getHeapSize());
        system.debug('@@@@ Results Size' + AllRegIds.size());
        regInfo.add(regNumSet);
        system.debug('Heap after reg num set - '+Limits.getHeapSize());
        //return AllRegIds;
        return regInfo;
    
    }
    
    @RemoteAction
    public static List<registrationSearchResultWrapper> queryRegulations(List<String> idList,list<String> filters) {
        
        Id LicenseRecordTypeId = Schema.SObjectType.License_Registration__c.getRecordTypeInfosByDeveloperName().get('License').getRecordTypeId();

        
        system.debug('@@@@number of ids ' +  idList.size());
        
        
        String licenseRegQuery='Select id,License_Registration_Number__c,name,status__c,Legal_Entity_Name__c, Mailing_Address_Line_1__c, Mailing_Address_Line_2__c, Mailing_City__c,Mailing_State__c,Mailing_Postal_Code__c,Mailing_Country__c,Account_Email__c,plumber__c,Electrical_Utility__c,Electrician__c,roofing__c,carpenter__c,Iron_Worker__c,Sheet_Metal_Worker__c,Plasterer_Tender__c,Bricklayer_Brick_Tender__c,Abestos__c,Boilermaker_Blacksmith__c,Carpet_Linoleum_Resilient_Tile_Layer__c,Cement_Mason__c,Driver_On_Off_Hauling__c,Drywall_Installer_Lather_Finisher__c,Elevator_Constructor__c,Field_Surveyor__c,General_Building__c,General_Engineering__c,Glazier__c,Inspector_Field_Soils_Material_Tester__c,Laborer__c,Landscape__c,Marble_Mason_Finisher__c,Operating_Engineer__c,Painter__c,Parking_Highway_Improvement__c,Stator_Rewinder__c,Teamster__c,Terrazzo_Worker_Finisher__c,Tile_Setter_Finisher__c,Water_Well_Driller__c,Effective_Date__c,Expiration_Date__c,Company_Type__c,County__c,Consultant__c,Physical_Business_County__c,';
        licenseRegQuery += ' (SELECT id,License_Number__c FROM Registrations__r WHERE recordtypeId=: LicenseRecordTypeId AND License_Type__c=\'CSLB\' LIMIT 1)';
        licenseRegQuery += ' FROM License_Registration__c';
        licenseRegQuery += ' WHERE (License_Registration_Number__c IN:idList or id IN:idList)'; 
        
        licenseRegQuery += ' AND (status__c=\'Active\' OR status__c=\'Expired\' OR status__c=\'Disqualified\') ';
        licenseRegQuery += ' ORDER BY Expiration_Date__c DESC';
        
        //TODO CSK incorporate the craft filters into the query
        
        system.debug('@@@@query is '+licenseRegQuery);
        system.debug('@@@@query WHERE CLAUSE is '+licenseRegQuery.right(300));
        
        List<License_Registration__c> lrList= Database.query(licenseRegQuery);        

        List<registrationSearchResultWrapper> rList=new List<registrationSearchResultWrapper>();
        list<Registration_Crafts__mdt> crafts= [SELECT MasterLabel, DeveloperName, field_api_name__c FROM Registration_Crafts__mdt order by MasterLabel];
        system.debug('Carfts Table - '+crafts);
        Map<id,list<DBA__c>> regIdDBAListMap=new Map<id,list<DBA__c>>();
        list<DBA__c> dbaList=[select id,
                                   name,
                                   Registration__c
                                    
                            from DBA__c 
                            where Registration__r.License_Registration_Number__c IN: idList];
        
        for(DBA__c dba:dbaList){
            
            List<DBA__c> dbaRegList=new List<DBA__c>();
            
            
            if(regIdDBAListMap.get(dba.Registration__c)!=null){
                dbaRegList=regIdDBAListMap.get(dba.Registration__c);
                
            }
            dbaRegList.add(dba);
            regIdDBAListMap.put(dba.Registration__c,dbaRegList);
            
            
        }
        

        
        set<String> regNumbers=new set<String>();
        
        for(License_Registration__c lr:lrList){
            system.debug('@@@@reg numbers size '+regNumbers.size());
            if(regNumbers.contains(lr.License_Registration_Number__c)){
                system.debug('@@@@found reg number');
                for(registrationSearchResultWrapper rswrap:rList){
                    
                    // CSK - As a result of no direct relationship b/t License_Registration__c results and history 
                    // Loop is required to build License History for All returned results
                    if(rswrap.lr.License_Registration_Number__c==lr.License_Registration_Number__c){
                        registrationHistory rh=new registrationHistory();
                        if(lr.Effective_Date__c!=null){
                            rh.EffectiveDate=lr.Effective_Date__c.format();
                        }
                        if(lr.Expiration_Date__c!=null){
                            rh.ExpirationDate=lr.Expiration_Date__c.format();
                        }
                        if(String.isNotBlank(rh.EffectiveDate) || String.isNotBlank(rh.ExpirationDate)){
                            rswrap.regHistory.add(rh);
                        }    
                        
                    
                    }
                
                }                
            
            }else{

                system.debug('@@@@not found reg number');
                registrationSearchResultWrapper rsw=new registrationSearchResultWrapper();
                rsw.lr=lr;

                if(lr.registrations__r.size()>0){
                   rsw.CSLB=lr.Registrations__r[0].License_Number__c;
                }
                //system.debug('CSLB is '+lr.Registrations__r[0].License_Number__c);
                List<String> craftsList=new List<String>();
                rsw.crafts= '';
                for(Registration_Crafts__mdt craft:crafts){
                    if(lr.get(craft.field_api_name__c)==true){
                        if (rsw.crafts == ''){
                            rsw.crafts = craft.MasterLabel;
                        }else{
                            rsw.crafts += ';'+craft.MasterLabel;
                        }
                	}
                }
                
                rsw.regLocList=regIdDBAListMap.get(lr.id);
                
                
                List<registrationHistory> rhList=new List<registrationHistory>();
                registrationHistory rh=new registrationHistory();
                if(lr.Effective_Date__c!=null){
                    rh.EffectiveDate=lr.Effective_Date__c.format();
                }
                if(lr.Expiration_Date__c!=null){
                    rh.ExpirationDate=lr.Expiration_Date__c.format();
                }
                if(String.isNotBlank(rh.EffectiveDate) || String.isNotBlank(rh.ExpirationDate)){
                    rhList.add(rh);
					rsw.regHistory=rhList;
                }
                
                regNumbers.add(lr.License_Registration_Number__c);
                system.debug('@@@adding reg number');
                rList.add(rsw);
            }
        
        }
        return rList;
        
    }
    
    public class registrationSearchResultWrapper{
    
        public License_Registration__c lr{get;set;}
        public String crafts{get;set;}
        public List<DBA__c> regLocList{get;set;}
        public List<DBA__c> regDBAs{get;set;}
        public List<registrationHistory> regHistory{get;set;}
        public String CSLB{get;set;}
        
        public registrationSearchResultWrapper(){
            //crafts='';
            CSLB='';
            regHistory=new List<registrationHistory>();

        }
        
    
    }
    
    
    public class registrationHistory{
    
        public String EffectiveDate{get;set;}
        public String ExpirationDate{get;set;}
        
        public registrationHistory(){
            EffectiveDate='';
            ExpirationDate='';
        }
    
    }
    
    
    
}