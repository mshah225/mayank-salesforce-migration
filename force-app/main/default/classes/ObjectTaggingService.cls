public with sharing class ObjectTaggingService {

    private Map<Id, Contact> contactNameMap {
        get {
            if (contactNameMap == null) {
                contactNameMap = new Map<Id, Contact>();
                
                if (!contactTagId.isEmpty()) {
                    for (Contact ct : [
                        SELECT Id, FirstName, LastName
                        FROM Contact
                        WHERE Id IN :contactTagId
                    ]) {
                        contactNameMap.put(ct.Id, ct);
                    }
                }
            }
            
            return contactNameMap;
        }
        
        set;
    }

    private Map<Id, Tag__c> tagMap {
        get {
            if (tagMap == null) {
                tagMap = new Map<Id, Tag__c>();
                
                if (!contactTagId.isEmpty()) {
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


    public ObjectTaggingService() {

    }


    private void updateName(Contact_Tag__c con) {
        
        String contactTagName = ((!contactNameMap.isEmpty() && (!String.isBlank(con.Contact__c) && contactNameMap.containsKey(con.Contact__c) && !String.isBlank(contactNameMap.get(con.Contact__c).FirstName))? contactNameMap.get(con.Contact__c).FirstName : '')
                +''
                +(!contactNameMap.isEmpty() && (!String.isBlank(con.Contact__c) && contactNameMap.containsKey(con.Contact__c) && !String.isBlank(contactNameMap.get(con.Contact__c).LastName)) ? contactNameMap.get(con.Contact__c).LastName : '')
                +' - '
                +(!tagMap.isEmpty() && (!String.isBlank(con.Tag__c) && tagMap.containsKey(con.Tag__c))? tagMap.get(con.Tag__c).Name: '')
                +' - '
                +datetime.now());
        
        if(con != null)
        {
            con.Name = contactTagName.length() >= 80 ? contactTagName.substring(0,80):contactTagName;
        }
        
    }
}