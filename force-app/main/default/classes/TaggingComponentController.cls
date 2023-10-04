public class TaggingComponentController {    

    private static final boolean debug = false; // Toggle debug error reporting
    
    /*This method fetches all the tags which are a part of contacts in a Map on page load by taking the recordId as parameter*/
    @AuraEnabled
    public static Map<String, Object_Tag__c> contactTags(Id recordId) {
        
        Map<String,Object_Tag__c> objTagMap = new Map<String,Object_Tag__c>();

        String recordIdPrefix = (String)recordId;
        recordIdPrefix = recordIdPrefix.left(3);

        List<Object_Tag_Mapping__mdt> tagMap = [
            SELECT Related_Field_Name__c, DeveloperName
            FROM Object_Tag_Mapping__mdt 
            WHERE Object_Prefix__c =: recordIdPrefix
            AND Use_Related_Object__c = true
            LIMIT 1
        ];
        
        if (tagMap.size() > 0) {
            String queryStr = 'SELECT ' + tagMap[0].Related_Field_Name__c + ' FROM ' + tagMap[0].DeveloperName + ' WHERE Id = \'' + recordId + '\'';
            recordId = (String)Database.query(queryStr)[0].get(tagMap[0].Related_Field_Name__c);
        }
       
        List<Object_Tag__c> objectTagList = [
            SELECT Contact__r.Name, Tag__r.Name, Tag__r.Background_Color__c, isActive__c,isVerified__c, Tag__r.Tag_Api_Name__c,Tag__r.Tag_Label_Color__c, Tag__r.Priority__c, Tag__r.Tag_Description__c, Tag__r.Removeable__c,Tag__r.Tag_Icon_URL__c, CP_Stage__c,Verified_Image__c,Verification__c 
            FROM Object_Tag__c 
            WHERE Related_Object_Id__c =: recordId 
            AND isActive__c=true ORDER 
            BY Tag__r.Priority__c ASC ,Tag__r.Name ASC
        ];
        
        for (Object_Tag__c obListItem : objectTagList) {
            objTagMap.put(obListItem.Tag__r.Name, obListItem);
        }
        
        return objTagMap;
    }
    
    /*This method fetches all the tags which can be serached on the UI and takes the tagSearch String as the parameter*/
    @AuraEnabled
    public static List<String> fetchTags(String tagSearch, Id recordId) {
        
        List<String> tagListToReturn = new  List<String>(); 
        
        try {
            List<Id>tagsForObject = new List<Id>();

            String recordIdPrefix = (String)recordId;
            recordIdPrefix = recordIdPrefix.left(3);

            List<Object_Tag_Mapping__mdt> tagMap = [
                SELECT Related_Field_Name__c, DeveloperName
                FROM Object_Tag_Mapping__mdt 
                WHERE Object_Prefix__c =: recordIdPrefix
                AND Use_Related_Object__c = true
                LIMIT 1
            ];
            
            if (tagMap.size() > 0) {
                String queryStr = 'SELECT ' + tagMap[0].Related_Field_Name__c + ' FROM ' + tagMap[0].DeveloperName + ' WHERE Id = \'' + recordId + '\'';
                recordId = (String)Database.query(queryStr)[0].get(tagMap[0].Related_Field_Name__c);
            }
        
            List<Object_Tag__c> objectTagList = [
                SELECT Contact__r.Name, Tag__r.Name, Tag__r.Background_Color__c, isActive__c,isVerified__c, Tag__r.Tag_Api_Name__c,Tag__r.Tag_Label_Color__c, Tag__r.Priority__c, Tag__r.Tag_Description__c, Tag__r.Removeable__c,Tag__r.Tag_Icon_URL__c, CP_Stage__c,Verified_Image__c,Verification__c 
                FROM Object_Tag__c 
                WHERE Related_Object_Id__c =: recordId 
                AND isActive__c=true ORDER 
                BY Tag__r.Priority__c ASC ,Tag__r.Name ASC
            ];
            
            for (Object_Tag__c obListItem : objectTagList) {
                tagsForObject.add(obListItem.Tag__r.Id);
            }
            
            String tagSearchKey = '%' + tagSearch + '%';       
                       
            for(Tag__c conTag :[
                SELECT Name,Searchable__c 
                FROM Tag__c 
                WHERE Name Like :tagSearchKey 
                AND Searchable__c= true  
                AND Id NOT IN: tagsForObject
            ]){
                
                tagListToReturn.add(conTag.Name);
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('TagSearch', tagSearch));
            vars.add(ErrorLogger.convertIdToJSON('RecordID', recordId));
            ErrorLogger.log(ex, vars, debug);
            tagListToReturn = null;
        }  

        return tagListToReturn;
    }
    
    /*Method is used to uncheck the checkbox on ContactTag__c Object when a tag is removed on the UI or create a new tag if not available on the UI .It takes 2 parameters tag label and recordId.*/
    @AuraEnabled
    public static String updateTag(String tag, Id recordId){
        
        String returnResult; 
        Tag__c parentTag; 
       
        parentTag = [
            SELECT Id, Name, Searchable__c, RecordType.DeveloperName  
            FROM Tag__c
            WHERE Name LIKE :tag
        ]; 
       
       	String recordIdPrefix = (String)recordId;
        recordIdPrefix = recordIdPrefix.left(3);

        List<Object_Tag_Mapping__mdt> tagMap = [
            SELECT Related_Field_Name__c, DeveloperName
            FROM Object_Tag_Mapping__mdt 
            WHERE Object_Prefix__c =: recordIdPrefix
            AND Use_Related_Object__c = true
            LIMIT 1
        ];
       
       if (tagMap.size() > 0) {
            String queryStr = 'SELECT ' + tagMap[0].Related_Field_Name__c + ' FROM ' + tagMap[0].DeveloperName + ' WHERE Id = \'' + recordId + '\'';
            recordId = (String)Database.query(queryStr)[0].get(tagMap[0].Related_Field_Name__c);
        }
        
        List<Object_Tag__c> objectTaggedList = [
            SELECT Id, isActive__c FROM Object_Tag__c WHERE Related_Object_Id__c =:recordId AND Tag__r.Name =:tag
        ];

        Id recordTypeIdForObjectTag = Schema.SObjectType.Object_Tag__c.getRecordTypeInfosByDeveloperName().get(parentTag.RecordType.DeveloperName).getRecordTypeId();
        
        List<Object_Tag__c> updateTag = new List<Object_Tag__c>();

        if(!objectTaggedList.isEmpty()) {
            
            for(Object_Tag__c cc: objectTaggedList) {
                if (cc.isActive__c == false) {
                    cc.isActive__c = true;
                }
                updateTag.add(cc);
            }
        } else {
            
            Object_Tag__c addtag = new Object_Tag__c();
            addtag.RecordTypeId = recordTypeIdForObjectTag;
            addtag.Related_Object_Id__c = recordId;
            addtag.Tag__c = parentTag.Id;
            addtag.isActive__c = true;
            updateTag.add(addtag);  
        }
        
        try {
            if(!updateTag.isEmpty()) {
                upsert updateTag;
                update updateTag;
                returnResult ='Success';
            } else {
                returnResult = 'Error';
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('TagsToUpdate', updateTag));
            vars.add(ErrorLogger.convertIdToJSON('RecordID', recordId));
            ErrorLogger.log(ex, vars, debug);
            returnResult = 'Error';
        }  
        
        
        
        return returnResult;
    }
    
    
    /*Method is used to uncheck the checkbox on ContactTag__c Object when a tag is removed on the UI. It takes 3 parameters tag label,recordId and tagRemovalReason*/
    @AuraEnabled
    public static String removeTag(String tag, Id recordId, String tagRemovalReason) {
        
        String returnResult; 

        String recordIdPrefix = (String)recordId;
        recordIdPrefix = recordIdPrefix.left(3);

        List<Object_Tag_Mapping__mdt> tagMap = [
            SELECT Related_Field_Name__c, DeveloperName
            FROM Object_Tag_Mapping__mdt 
            WHERE Object_Prefix__c =: recordIdPrefix
            AND Use_Related_Object__c = true
            LIMIT 1
        ];
        
        if (tagMap.size() > 0) {
            String queryStr = 'SELECT ' + tagMap[0].Related_Field_Name__c + ' FROM ' + tagMap[0].DeveloperName + ' WHERE Id = \'' + recordId + '\'';
            recordId = (String)Database.query(queryStr)[0].get(tagMap[0].Related_Field_Name__c);
        }
        
        List<Object_Tag__c> removeTag = new List<Object_Tag__c>();
        for (Object_Tag__c cc: [
            SELECT Tag__r.Name, isActive__c 
            FROM Object_Tag__c 
            WHERE Related_Object_Id__c =: recordId AND Tag__r.Name =: tag AND Tag__r.Removeable__c = true
        ]) {
            cc.isActive__c = false;
            cc.Tag_Removal_Reason__c = tagRemovalReason;
            removeTag.add(cc);
        }

        try {
            if (!removeTag.isEmpty()) {
                update removeTag;
                returnResult ='Success';
            }
            else {
                returnResult = 'Error';
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('TagsToRemove', removeTag));
            vars.add(ErrorLogger.convertIdToJSON('RecordID', recordId));
            ErrorLogger.log(ex, vars, debug);
            returnResult = 'Error';
        }   
         
        return returnResult;
    } 
    
    /*This method is used to get all the tagRemovalReason onto the picklist filed on the frontEnds*/
    @AuraEnabled
    public static String tagRemovalReason() {
        
        Map<String,String> pickListValues = new Map<String,String>();

        try {
            
            Schema.DescribeFieldResult fieldResult = Object_Tag__c.Tag_Removal_Reason__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry pickListVal : ple) {
                pickListValues.put(pickListVal.getLabel(),pickListVal.getValue());
            } 

            return SYSTEM.JSON.serialize(pickListValues);
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertMapToJSON('RemovalPickListReasons', pickListValues));
            ErrorLogger.log(ex, vars, debug);
            return null;
        }  
    } 
    
}