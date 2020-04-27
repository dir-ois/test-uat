/******************************************************************************
* @author         Sapient
* @date           December 2018
* @description    
********************************************************************************************************/
@SuppressWarnings('sf:ClassWithOnlyPrivateConstructorsShouldBeFinal')
public without sharing class LRHandlerChangeSectionStatus {

    private static LRHandlerChangeSectionStatus classInstance = null;
    public boolean stopRecursion {get; set;}
    String className = 'LRHandlerChangeSectionStatus';
    private LRHandlerChangeSectionStatus() {
        stopRecursion = false;
    }

    public static LRHandlerChangeSectionStatus getInstance(){
        if (null == classInstance) {
            classInstance = new LRHandlerChangeSectionStatus();
        }
        return classInstance;
    }

    Set<Id> updatedDocumentRegLst = new Set<Id>();
    Set<Id> updatedDefectRegLst = new Set<Id>();
    
    Set<License_Registration__c> updatedRegLst = new Set<License_Registration__c>();
    Map<String,String> secAttFeildMap = new Map<String,String>();
    Map<String,Registration_Defects_Mapping__mdt> secDefFeildMap = new Map<String,Registration_Defects_Mapping__mdt>();
    Map<String,String> secStatusMap = new Map<String,String>();
    Map<String,String> secActualStatusMap = new Map<String,String>();
    Map<String,Map<String, List<Id>>> sectionMap = new Map<String,Map<String, List<Id>>>();
    
    /******************************************************************************
    * @author           Sapient
    * @LastModifiedDate 2018-12-19             
    * @description      Update Section Statuses based on certain field Values
    * @VersionHistory   20181219_HB : Added custom debugs
    ******************************************************************************/
    public void ChangeSectionStatusOnUpdate(list<License_Registration__c> newList,map<id, License_Registration__c> oldMap) {
        System.debug('inside ChangeSectionStatusOnUpdate');
        Logger.debug('######## Entering ChangeSectionStatusOnUpdate Method');
        if(stopRecursion == null || !stopRecursion) {
            stopRecursion = true;

            for(Registration_Defects_Mapping__mdt rdm: [Select MasterLabel,Field_API__c,Reviewed_Field__c FROM Registration_Defects_Mapping__mdt])
                secDefFeildMap.put(rdm.MasterLabel,rdm);

            sectionMap = new Map<String,Map<String, List<Id>>>();

            for(Registration_Attachments_Mapping__mdt ram: [Select MasterLabel,FieldAPI__c FROM Registration_Attachments_Mapping__mdt])
                secAttFeildMap.put(ram.MasterLabel,ram.FieldAPI__c);

            checkSectionStatusOnUpdate(newList,oldMap);

            if(!updatedRegLst.isEmpty()) {
                  updateSectionsStaus();
            }
            stopRecursion = false;
            
        }
        Logger.debug('######## Exiting ChangeSectionStatusOnUpdate Method');
        Logger.pop();
        

    }

    /******************************************************************************
    * @author           Sapient
    * @LastModifiedDate 2018-12-19             
    * @description      Update Section Statuses based on certain field Values
    * @VersionHistory   20181219_HB : Added custom debugs
    ******************************************************************************/
    private void checkSectionStatusOnUpdate(list<License_Registration__c> newList,map<id, License_Registration__c> oldMap) {
        System.debug('inside checkSectionStatusOnUpdate');
        Logger.debug('######## Entering checkSectionStatusOnUpdate Method');
        for(License_Registration__c lr: newList) {

            if(lr.VIP_Template_Status__c != oldMap.get(lr.Id).VIP_Template_Status__c) {
            system.debug('entering inside IF**');
                updatedDocumentRegLst.add(lr.Id);
                updatedRegLst.add(lr);
                updatedDefectRegLst.add(lr.Id);
                sectionMap.put(lr.VIP_Template__c,new Map<String, List<Id>>());
            }
            else {
            system.debug('entering inside else**');
            System.debug(secAttFeildMap.keySet());
            System.debug(secDefFeildMap.keySet());
                for(String att: secAttFeildMap.keyset()){
                    if(lr.get(secAttFeildMap.get(att)) != oldMap.get(lr.Id).get(secAttFeildMap.get(att)))
                    {
                        updatedDocumentRegLst.add(lr.Id);
                        updatedRegLst.add(lr);
                        sectionMap.put(lr.VIP_Template__c,new Map<String, List<Id>>());
                        break;
                    }
                    
                }
                for(String def: secDefFeildMap.keyset()){
                    if(lr.get(secDefFeildMap.get(def).Field_API__c) != oldMap.get(lr.Id).get(secDefFeildMap.get(def).Field_API__c)
                            || lr.get(secDefFeildMap.get(def).Reviewed_Field__c) != oldMap.get(lr.Id).get(secDefFeildMap.get(def).Reviewed_Field__c)
                            )
                    {
                        updatedDefectRegLst.add(lr.Id);
                        updatedRegLst.add(lr);
                        sectionMap.put(lr.VIP_Template__c,new Map<String, List<Id>>());
                        break;
                    }                       
                }
            }
        }
        Logger.debug('######## Exiting checkSectionStatusOnUpdate Method'); 
        Logger.pop();
    }
    

    /******************************************************************************
    * @author           Sapient
    * @LastModifiedDate 2018-12-19             
    * @description      Update Section Statuses based on certain field Values
    * @VersionHistory   20181219_HB : Added custom debugs
    ******************************************************************************/
    private  void updateSectionsStaus() {
        System.debug('inside updateSectionStatus');
        Logger.debug('######## Entering updateSectionsStaus Method');
        if(!sectionMap.isEmpty()) {
            //Getting all Internal and external Sections for the Car Wash Template
            for(VIPForm__VIP_Category__c obj : [SELECT Name, Id,VIPForm__Name_Displayed__c,VIPForm__Template__c FROM VIPForm__VIP_Category__c WHERE 
            VIPForm__Template__c = :sectionMap.keyset() and (NOT Name like '%Renewal%')])
            {
                if(!sectionMap.get(obj.VIPForm__Template__c).containsKey(obj.VIPForm__Name_Displayed__c)) {
                  sectionMap.get(obj.VIPForm__Template__c).put(obj.VIPForm__Name_Displayed__c,new List<Id>());
                }
                sectionMap.get(obj.VIPForm__Template__c).get(obj.VIPForm__Name_Displayed__c).add(obj.Id);
            }
            
            for(License_Registration__c reg: updatedRegLst ) {
                //get the current statuses of each section related to particular registration record
                secStatusMap = new Map<String,String>();
                secActualStatusMap = new Map<String,String>();
                
                if(!String.Isblank(reg.VIP_Template_Status__c)) {
                    
                    List<object> meta = (List<object>) JSON.deserializeUntyped(reg.VIP_Template_Status__c);
                    
                    for(Object result :meta){
                        Map<String,Object> mpParsed = (Map<String,Object>)result;
                        secActualStatusMap.put((string)mpParsed.get('categoryId'),(string)mpParsed.get('categoryStatus')); 
                        
                        //system.debug('category Id**'+(string)mpParsed.get('categoryId'));
                        //system.debug('category status***'+(string)mpParsed.get('categoryStatus'));
                        
                        Map<String,Object> statusParsed = (Map<String,Object>)mpParsed.get('categoryStatusLabels');
                        if(statusParsed != NULL) {
                            secStatusMap.put((string)mpParsed.get('categoryId'),(string)statusParsed.get('complete'));        
                        }
                    }
                }
                if(sectionMap.containsKey(reg.VIP_Template__c))
                {
                  Logger.debug('######## Entering updateMissingDocumentStatus Method of ' + reg.Id);
                  Map<String, List<Id>> tempsectionMap = sectionMap.get(reg.VIP_Template__c);
                  /***Missing req Document Status**/
                  if(updatedDocumentRegLst.contains(reg.Id) ) {
                        updateMissingDocumentStatus(reg,tempsectionMap);
                  }
                  
                  /*Update rejection Defect Section Status */
                  if(updatedDefectRegLst.contains(reg.Id)) {
                        updateDefectListStatus(reg,tempsectionMap);
                  }
                }
            }
        }               
        Logger.debug('######## Exiting updateSectionsStaus Method');
        Logger.pop();
    }
    
    /******************************************************************************
    * @author           Sapient
    * @LastModifiedDate 2018-12-19             
    * @description      Missing Document required section Status
    * @VersionHistory   20181219_HB : Added custom debugs
    ******************************************************************************/
    private void updateMissingDocumentStatus(License_Registration__c reg,Map<String, List<Id>> tempsectionMap) {
        System.debug('inside updateMissingDocumentStatus');
        Logger.debug('######## Entering updateMissingDocumentStatus Method of ' + reg.Id);
        for(String att: secAttFeildMap.keyset()) {
            Logger.debug('current section** '+ att);
            if(tempsectionMap.containsKey(att))
            {
                  for(Id sectionId : tempsectionMap.get(att)) 
                  {
                        Logger.debug('sectionId***'+sectionId + ' of ' + reg.Id);
                        Logger.debug('updateMissingDocumentStatus section status of '+ att +'**'+secActualStatusMap.get(sectionId) + ' for ' + reg.Id);
                        if(reg.get(secAttFeildMap.get(att)) == FALSE
                              && secActualStatusMap.get(sectionId) != 'Missing Required Data'
                              && secActualStatusMap.get(sectionId) != NULL 
                              && secActualStatusMap.get(sectionId)!= '')
                        {
                        
                              Logger.debug('Before calling document status change for'+ att + ' of ' + reg.Id);
                              VIPForm.VIP_FormWizardUtil.populateCategoryStatus(reg.Id,sectionId,'','In Progress',
                              'Missing Required Document','Missing Required Document');
                              Logger.debug('After calling document status change for'+ att + ' of ' + reg.Id);
                        
                        }else if(reg.get(secAttFeildMap.get(att)) == TRUE
                              && (secStatusMap.containsKey(sectionId) 
                                    && secStatusMap.get(sectionId)== 'Missing Required Document')){
                        
                              Logger.debug('Before calling complete status change for'+ att + ' of ' + reg.Id);
                              VIPForm.VIP_FormWizardUtil.populateCategoryStatus(reg.Id,sectionId,'','In Progress','Completed','Completed');
                              Logger.debug('Before calling complete status change for'+ att + ' of ' + reg.Id);
                        }
                  }
            }
        }
        Logger.debug('######## Exiting updateMissingDocumentStatus Method of ' + reg.Id);
        Logger.pop();
    }


    /******************************************************************************
    * @author           Sapient
    * @LastModifiedDate 2018-12-19             
    * @description      Update Defect Section Status
    * @VersionHistory   20181219_HB : Added custom debugs
    ******************************************************************************/
    private void updateDefectListStatus(License_Registration__c reg,Map<String, List<Id>> tempsectionMap) {
        System.debug('inside updateDefectListStatus');

        for(String def: secDefFeildMap.keyset()) {
            
            if(tempsectionMap.containsKey(def))
            {
                  for(Id sectionId : tempsectionMap.get(def)) 
                  {
                        if(reg.get(secDefFeildMap.get(def).Field_API__c) == TRUE
                              && reg.get(secDefFeildMap.get(def).Reviewed_Field__c) == FALSE
                              && secActualStatusMap.get(sectionId) != 'Missing Required Data'
                              ) {
                        
                              //Logger.debug('Before calling defect status change for'+ def);
                              VIPForm.VIP_FormWizardUtil.populateCategoryStatus(reg.Id,sectionId,'',
                              'In Progress','Defect Identified','Defect Identified');
                              //Logger.debug('After calling defect status change for'+ def);
                        }else if(secStatusMap.containsKey(sectionId)
                              && reg.get(secDefFeildMap.get(def).Field_API__c) == FALSE && ((
                                    secAttFeildMap.containsKey(def) && reg.get(secAttFeildMap.get(def)) == TRUE
                                    && secStatusMap.get(sectionId) == 'Missing Required Document'
                                    ) 
                                    ||  secStatusMap.get(sectionId)== 'Defect Identified')
                                    ) {
                              //Logger.debug('Before calling defect complete status change for'+ def);
                              VIPForm.VIP_FormWizardUtil.populateCategoryStatus(reg.Id,sectionId,'','In Progress','Completed','Completed');
                              //Logger.debug('Before calling defect complete status change for'+ def);
                        }
                  }
            }
         }
        Logger.debug('######## Exiting updateDefectListStatus Method');
        Logger.pop();
        
    }

}