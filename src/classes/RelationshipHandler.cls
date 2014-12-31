public without sharing class RelationshipHandler 
    implements ITrigger 
{
    public void bulkBefore()
    {
    }


    public void bulkAfter()
    {
        Set<Id> recipRelationshipIdSet = new Set<Id>();
        List<RecordType> recordTypeList = new List<RecordType>();
        Map<Id, String> recordTypeNamesById = new Map<Id, String>();
        Map<String, Id> recordTypeIdsByName = new Map<String, Id>();
        Map<String, String> recipRelationshipTypes = new Map<String, String>();


        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Relationship__c r: (List<Relationship__c>)Trigger.new) {
                if (r.Reciprocal_Relationship__c != null)
                    recipRelationshipIdSet.add(r.Reciprocal_Relationship__c);
            }
            // Build Lookup Maps for the RecordTypes
            recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Relationship__c']);
            for (RecordType rt: recordTypeList) {
                recordTypeIdsByName.put(rt.DeveloperName, rt.Id);
                recordTypeNamesById.put(rt.Id, rt.DeveloperName);
            }

            // Build a Lookup Map for the Reciprocal Relationship Types (including the ability to look up by Name or Reciprocal Name)
            List<Relationships__c> relCustomSettings = Relationships__c.getAll().values();
            for (Relationships__c relCS: relCustomSettings) {
                recipRelationshipTypes.put(relCS.Reciprocal__c, relCS.Name);
                recipRelationshipTypes.put(relCS.Name, relCS.Reciprocal__c);
            }

        }
        else if (Trigger.isDelete) {
             for (Relationship__c r: (List<Relationship__c>)Trigger.old) {
                if (r.Reciprocal_Relationship__c != null)
                    recipRelationshipIdSet.add(r.Reciprocal_Relationship__c);
            }           
        }

        if (Trigger.IsInsert) {

            // Contains any Relationships listing one of our inserted Relationships as its reciprocal
            Map<Id, Relationship__c> existingRecipRelationshipMap = new Map<Id, Relationship__c>([SELECT Id, Reciprocal_Relationship__c FROM Relationship__c WHERE Id IN :recipRelationshipIdSet]);

            List<Relationship__c> recipRelationshipsToUpdate = new List<Relationship__c>();
            List<Relationship__c> recipRelationshipsToInsert = new List<Relationship__c>();

            for (Relationship__c r: (List<Relationship__c>)Trigger.new) {
                if (r.Reciprocal_Relationship__c == null) {
                    // Create reciprocal relationship record
                    //Relationships__c relationshipSetting = Relationships__c.getValues(r.Relationship_Type__c);
                    string recipRelationshipType = recipRelationshipTypes.get(r.Relationship_Type__c);

                    Relationship__c recipRel = new Relationship__c();
                    if (recordTypeIdsByName.containsKey(recordTypeNamesById.get(r.RecordTypeId) + '_Reciprocal')) {
                        recipRel.RecordTypeId = recordTypeIdsByName.get(recordTypeNamesById.get(r.RecordTypeId) + '_Reciprocal');
                    }
                    else {
                        // If there is no corresponding "reciprocal" record type defined, skip it
                        continue;
                    }
                    recipRel.Reciprocal_Relationship__c = r.Id;
                    recipRel.Account__c = r.Related_Account__c;
                    recipRel.Related_Account__c = r.Account__c;
                    recipRel.Contact__c = r.Related_Contact__c;
                    recipRel.Related_Contact__c = r.Contact__c;
                    recipRel.Active_Relationship__c = r.Active_Relationship__c;
                    recipRel.Relationship_Start_Date__c = r.Relationship_Start_Date__c;
                    recipRel.Relationship_End_Date__c = r.Relationship_End_Date__c;
                    recipRel.Relationship_Type__c = (recipRelationshipType == null? r.Relationship_Type__c : recipRelationshipType);
                    recipRelationshipsToInsert.add(recipRel);
                }
                else {
                    if (existingRecipRelationshipMap.containsKey(r.Reciprocal_Relationship__c)) {
                        Relationship__c recipRel = existingRecipRelationshipMap.get(r.Reciprocal_Relationship__c);
                        recipRel.Reciprocal_Relationship__c = r.Id;
                        recipRelationshipsToUpdate.add(recipRel);
                    }
                }
            }

            if (recipRelationshipsToInsert.size() > 0)
                insert recipRelationshipsToInsert;

            if (recipRelationshipsToUpdate.size() > 0)
                update recipRelationshipsToUpdate;

        }

        if (Trigger.isUpdate) {
            List<Relationship__c> recipRelationshipsToUpdate = new List<Relationship__c>();
            Map<Id, Relationship__c> recipRelationshipMap = new Map<Id, Relationship__c>([SELECT Id, RecordTypeId, Account__c, Related_Account__c, Related_Contact__c, Contact__c, Active_Relationship__c, Relationship_Start_Date__c, Relationship_End_Date__c, Relationship_Type__c FROM Relationship__c WHERE Id IN :recipRelationshipIdSet]);
            
            for (Relationship__c r: (List<Relationship__c>)Trigger.new) {
                Relationship__c recipRelationship = recipRelationshipMap.get(r.Reciprocal_Relationship__c);
                if (recipRelationship != null) {
                    Boolean updateMade = false;
                    if (recipRelationship.Account__c != r.Related_Account__c) {
                        recipRelationship.Account__c = r.Related_Account__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Related_Account__c != r.Account__c) {
                        recipRelationship.Related_Account__c = r.Account__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Related_Contact__c != r.Contact__c) {
                        recipRelationship.Related_Contact__c = r.Contact__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Contact__c != r.Related_Contact__c) {
                        recipRelationship.Contact__c = r.Related_Contact__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Active_Relationship__c != r.Active_Relationship__c) {
                        recipRelationship.Active_Relationship__c = r.Active_Relationship__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Relationship_Start_Date__c != r.Relationship_Start_Date__c) {
                        recipRelationship.Relationship_Start_Date__c = r.Relationship_Start_Date__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Relationship_End_Date__c != r.Relationship_End_Date__c) {
                        recipRelationship.Relationship_End_Date__c = r.Relationship_End_Date__c;
                        updateMade = true;
                    }

                    //Relationships__c relationshipSetting = Relationships__c.getValues(r.Relationship_Type__c);
                    string recipRelationshipType = recipRelationshipTypes.get(r.Relationship_Type__c);

                    if (recipRelationship.Relationship_Type__c != (recipRelationshipType == null? r.Relationship_Type__c : recipRelationshipType)) {
                        recipRelationship.Relationship_Type__c = (recipRelationshipType == null? r.Relationship_Type__c : recipRelationshipType);
                        updateMade = true;
                    }
                    if (updateMade)
                        recipRelationshipsToUpdate.add(recipRelationship);
                }   
            }
            if (recipRelationshipsToUpdate.size() > 0)
                update recipRelationshipsToUpdate;

        }

        if (Trigger.IsDelete) {
            List<Relationship__c> recipRelationshipsToDelete = new List<Relationship__c>([SELECT Id FROM Relationship__c WHERE Id IN :recipRelationshipIdSet]);
            if (recipRelationshipsToDelete.size() > 0)
                delete recipRelationshipsToDelete;
        }

    }
       
    public void beforeInsert(SObject so)
    {
    }
    
    public void beforeUpdate(SObject oldSo, SObject so)
    {
    }

    public void beforeDelete(SObject so)
    {
    }
    
    public void beforeFinally()
    {

    }
    
    public void afterInsert(SObject so)
    {
    }

    public void afterUpdate(SObject oldSo, SObject so)
    {
    }

    public void afterDelete(SObject so)
    {
    }

    public void andFinally()
    {
    }

    }