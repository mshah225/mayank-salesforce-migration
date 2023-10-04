public with sharing class ObjectTaggingService {
    private static final boolean debug = false; // Toggle debug error reporting

    private static Set<Id> objectTagId = new Set<Id>();
    private static Set<Id> tagId = new Set<Id>();

    private static Map<Id, Tag__c> tagMap {
        get {
            if (tagMap == null) {
                tagMap = new Map<Id, Tag__c>();
                
                if (!tagId.isEmpty()) {
                    for (Tag__c t : [
                        SELECT Id,Name
                        FROM Tag__c
                        WHERE Id IN :tagId
                    ]) {
                        tagMap.put(t.Id, t);
                    }
                }
            }
            
            return tagMap;
        }
        
        set;
    }

    public static void initData (List<Object_Tag__c> obTagList) {

        for (Object_Tag__c obTag : obTagList) {
            if (obTag.Tag__c != null) {
                tagId.add(obTag.Tag__c);
            }
        }
    }

    public static void createName(List<Object_Tag__c> obTagList) {
        

        try {
            for (Object_Tag__c obTag : obTagList) {
                String objectTagName;
                if (obTag.Derived_Name__c == null) {
                    objectTagName = 
                        'PLACEHOLDER'
                        + ' - '
                        + (!tagMap.isEmpty() && (!String.isBlank(obTag.Tag__c) && tagMap.containsKey(obTag.Tag__c))? tagMap.get(obTag.Tag__c).Name: '')
                        + ' - '
                        + datetime.now();
                } else {
                    objectTagName = 
                        obTag.Derived_Name__c
                        + ' - '
                        + (!tagMap.isEmpty() && (!String.isBlank(obTag.Tag__c) && tagMap.containsKey(obTag.Tag__c))? tagMap.get(obTag.Tag__c).Name: '')
                        + ' - '
                        + datetime.now();
                }            
                
                if (obTag != null) {
                    obTag.Name = objectTagName.length() >= 80 ? objectTagName.substring(0,80):objectTagName;
                }

                if (obTag.Object_Tag_Key__c == null && obTag.Related_Object_Id__c != null && obTag.Tag__c != null ) {
                    obTag.Object_Tag_Key__c = obTag.Related_Object_Id__c + obTag.Tag__c + obTag.RecordTypeId;
                }
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('ObjectTagList', obTagList));
            ErrorLogger.log(ex, vars, debug);
        }  
        
    }

    public static void fixName(List<Object_Tag__c> obTagList) {
        
        List<Object_Tag__c> namesToFix = new List<Object_Tag__c>();

        for (Object_Tag__c obTag : obTagList) {
            if (obTag.Name.indexOf('PLACEHOLDER') > -1) {
                namesToFix.add(obTag);
            }
        }
        
        createName(namesToFix);        
    }

    public static void applyRelatedObject(List<Object_Tag__c> obTagList) {

        try {
            Map<String, Object_Tag_Mapping__mdt> relatedObjectMap = Object_Tag_Mapping__mdt.getAll();
            
            for (Object_Tag__c obTag : obTagList) {
                String firstThreeOfId = obTag.Related_Object_Id__c.left(3);
                for (Object_Tag_Mapping__mdt otm : relatedObjectMap.values()) {
                    if (otm.Use_Related_Object__c == true) {
                        continue;
                    } else if (otm.Object_Prefix__c == firstThreeOfId) {
                        obTag.put(otm.Related_Field_Name__c, obTag.Related_Object_Id__c);
                    } else {
                        obTag.put(otm.Related_Field_Name__c, null);
                    }
                }
            }      
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('ObjectTagList', obTagList));
            ErrorLogger.log(ex, vars, debug);
        }  
    }

    public static void updateCreationDateTime(List<Object_Tag__c obTagList) {
        for (Object_Tag__c obTag : obTagList) {
            obTag.Tag_Added_Date__c = datetime.now();
        } 
    }

    public static void updateCreationOrRemovalDate(Map<Id, Object_Tag__c> newTags, Map<Id, Object_Tag__c> oldTags) {
        try {
            for (Id tagId : newTags.keyset()) {
                if (newTags.get(tagId).isActive__c == true && oldTags.get(tagId).isActive__c == false) {
                    newTags.get(tagId).Tag_Added_Date__c = datetime.now();
                } else if (newTags.get(tagId).isActive__c == false && oldTags.get(tagId).isActive__c == true) {
                    newTags.get(tagId).Tag_Removal_Date__c = datetime.now();
                }
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertMapToJSON('NewObjectTags', newTags));
            vars.add(ErrorLogger.convertMapToJSON('OldObjectTags', oldTags));
            ErrorLogger.log(ex, vars, debug);
        }  
    }
}