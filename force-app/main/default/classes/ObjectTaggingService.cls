public with sharing class ObjectTaggingService {

    private static Set<Id> objectTagId = new Set<Id>();
    private static Set<Id> tagId = new Set<Id>();

    private static Map<Id, Contact> contactNameMap {
        get {
            if (contactNameMap == null) {
                contactNameMap = new Map<Id, Contact>();
                
                if (!objectTagId.isEmpty()) {
                    for (Contact ct : [
                        SELECT Id, FirstName, LastName
                        FROM Contact
                        WHERE Id IN :objectTagId
                    ]) {
                        contactNameMap.put(ct.Id, ct);
                    }
                }
            }
            
            return contactNameMap;
        }
        
        set;
    }

    private static Map<Id, Tag__c> tagMap {
        get {
            if (tagMap == null) {
                tagMap = new Map<Id, Tag__c>();
                
                if (!objectTagId.isEmpty()) {
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
            if (obTag.Contact__c != null) objectTagId.add(obTag.Contact__c);
            if(obTag.Tag__c != null) tagId.add(obTag.Tag__c);
        }
    }

    public static void createName(List<Object_Tag__c> obTagList) {
        
        for (Object_Tag__c obTag : obTagList) {
            String objectTagName = ((!contactNameMap.isEmpty() && (!String.isBlank(obTag.Contact__c) && contactNameMap.containsKey(obTag.Contact__c) && !String.isBlank(contactNameMap.get(obTag.Contact__c).FirstName))? contactNameMap.get(obTag.Contact__c).FirstName : '')
                    +''
                    +(!contactNameMap.isEmpty() && (!String.isBlank(obTag.Contact__c) && contactNameMap.containsKey(obTag.Contact__c) && !String.isBlank(contactNameMap.get(obTag.Contact__c).LastName)) ? contactNameMap.get(obTag.Contact__c).LastName : '')
                    +' - '
                    +(!tagMap.isEmpty() && (!String.isBlank(obTag.Tag__c) && tagMap.containsKey(obTag.Tag__c))? tagMap.get(obTag.Tag__c).Name: '')
                    +' - '
                    +datetime.now());
            
            if (obTag != null) {
                obTag.Name = objectTagName.length() >= 80 ? objectTagName.substring(0,80):objectTagName;
            }

            if (obTag.Contact_Tag_Key__c == null && obTag.Contact__c != null && obTag.Tag__c != null ) {
                obTag.Contact_Tag_Key__c = obTag.Contact__c +''+ obTag.Tag__c;
            }
        }   
        
    }

    public static void applyRelatedObject(List<Object_Tag__c> obTagList) {
        Map<String, Object_Tag_Mapping__mdt> relatedObjectMap = Object_Tag_Mapping__mdt.getAll();

        
        for (Object_Tag__c obTag : obTagList) {
            String firstThreeOfId = obTag.Related_Object_Id__c.left(3);
            for (Object_Tag_Mapping__mdt otm : relatedObjectMap.values()) {
                if (otm.Object_Prefix__c == firstThreeOfId) {
                    obTag.put(otm.Related_Field_Name__c, obTag.Related_Object_Id__c);
                } else {
                    obTag.put(otm.Related_Field_Name__c, null);
                }
            }
        }        
    }
}