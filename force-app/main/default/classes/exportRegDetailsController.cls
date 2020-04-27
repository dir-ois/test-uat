global class exportRegDetailsController{
    
    public List<String> regIdList {get;set;}
    public List<License_Registration__c> regList {get;set;}
    
    public exportRegDetailsController() 
    {
            regIdList = new List<String>();
            String listReg = apexpages.currentpage().getparameters().get('myList');
            system.debug('reg list is '+listReg);
            if(String.isNotBlank(listReg) && listReg.contains(','))
                regIdList =  listReg.split(',');
            else{
                list<String> lis=new List<String>();
                lis.add(listReg);
                regIdList=lis;
            }
            
            System.debug('regIdList-'+regIdList);
            if(regIdList!=null && regIdList.size()>0){
            regList = [select id,status__c,License_Registration_Number__c,Effective_Date__c,Expiration_Date__c,Legal_Entity_Name__c,County__c,Mailing_Address_Line_1__c,
                    Mailing_Address_Line_2__c,Mailing_City__c,Mailing_Country__c,Mailing_Postal_Code__c,
                    Boilermaker_Blacksmith__c,Bricklayer_Brick_Tender__c,Carpet_Linoleum_Resilient_Tile_Layer__c,Drywall_Installer_Lather_Finisher__c,
                    Electrician__c,Field_Surveyor__c,Glazier__c,Marble_Mason_Finisher__c,Painter__c,Plasterer_Tender__c,Plumber__c,Roofing__c,Sheet_Metal_Worker__c,
                    Terrazzo_Worker_Finisher__c,Tile_Setter_Finisher__c,Water_Well_Driller__c,Iron_Worker__c,Electrical_Utility__c,Landscape__c,Stator_Rewinder__c,
                    Driver_On_Off_Hauling__c,Teamster__c,Abestos__c,Inspector_Field_Soils_Material_Tester__c,Carpenter__c,Cement_Mason__c,Elevator_Constructor__c,Laborer__c,
                    Parking_Highway_Improvement__c,Operating_Engineer__c,General_Engineering__c,General_Building__c,Crafts__c ,
                    (select id,name from DBAS__r)
                    from License_Registration__c where id in : regIdList];
                    
            for(License_Registration__c reg: regList){
                
                reg.Crafts__c ='';
                
                if(reg.Boilermaker_Blacksmith__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Boilermaker-Blacksmith' + ',';
                }
                if(reg.Bricklayer_Brick_Tender__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Bricklayer/Brick Tender' + ',';
                }
                if(reg.Carpet_Linoleum_Resilient_Tile_Layer__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Carpet, Linoleum, Resilient Tile Layer' + ',';
                }
                if(reg.Drywall_Installer_Lather_Finisher__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Drywall Installer/Lather/Finisher' + ',';
                }
                if(reg.Electrician__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Electrician' + ',';
                }
                if(reg.Field_Surveyor__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Field Surveyor' + ',';
                }
                if(reg.Glazier__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Glazier' + ',';
                }
                if(reg.Marble_Mason_Finisher__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Marble Mason/Finisher' + ',';
                }
                if(reg.Painter__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Painter' + ',';
                }
                if(reg.Plasterer_Tender__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Plasterer/Tender' + ',';
                }                
                if(reg.Plumber__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Plumber' + ',';
                }                
                if(reg.Roofing__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Roofing' + ',';
                }                
                if(reg.Sheet_Metal_Worker__c){ 
                    reg.Crafts__c =  reg.Crafts__c + 'Sheet Metal Worker' + ',';
                }                
                if(reg.Terrazzo_Worker_Finisher__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Terrazzo Worker/Finisher' + ',';
                } 
                if(reg.Tile_Setter_Finisher__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Tile Setter/Finisher' + ',';
                }
                if(reg.Water_Well_Driller__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Water Well Driller' + ',';
                }
                if(reg.Iron_Worker__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Iron Worker' + ',';
                }
                if(reg.Electrical_Utility__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Electrical Utility' + ',';
                }
                if(reg.Landscape__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Landscape' + ',';
                }
                if(reg.Stator_Rewinder__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Stator Rewinder' + ',';
                }
                if(reg.Driver_On_Off_Hauling__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Driver (On/Off Hauling)' + ',';
                }                
                if(reg.Teamster__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Teamster' + ',';
                }                
                if(reg.Abestos__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Abestos' + ',';
                }                
                if(reg.Inspector_Field_Soils_Material_Tester__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Inspector/Field Soils,Material Tester' + ',';
                }                
                if(reg.Carpenter__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Carpenter' + ',';
                }                
                if(reg.Cement_Mason__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Cement Mason' + ',';
                }  
                if(reg.Elevator_Constructor__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Elevator Constructor' + ',';
                }
                if(reg.Laborer__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Laborer' + ',';
                }
                if(reg.Parking_Highway_Improvement__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Parking/Highway/Improvement' + ',';
                }
                if(reg.Operating_Engineer__c){
                    reg.Crafts__c =  reg.Crafts__c + 'Operating Engineer' + ',';
                }
                if(reg.General_Engineering__c){
                    reg.Crafts__c =  reg.Crafts__c + 'General Engineering' + ',';
                }
                if(reg.General_Building__c){
                    reg.Crafts__c =  reg.Crafts__c + 'General Building' + ',';
                }
                
                if(reg.Crafts__c!=''){
                    reg.Crafts__c =  reg.Crafts__c.removeEnd(',');
                }
            }        
            
            System.debug('regList'+regList);
            }
    }
}