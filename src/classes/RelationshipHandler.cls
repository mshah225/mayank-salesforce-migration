public without sharing class RelationshipHandler implements ITrigger
{
    public void bulkBefore() {}

    public void bulkAfter()
    {
        Set<Id> recipRelationshipIdSet = new Set<Id>();
        List<RecordType> recordTypeList = new List<RecordType>();
        Map<Id, String> recordTypeNamesById = new Map<Id, String>();
        Map<String, Id> recordTypeIdsByName = new Map<String, Id>();
        Map<String, String> recipRelationshipTypes = new Map<String, String>();

        //If we have inserted / updated records
        //Build a lists of all existing reciprocal relations on the items
        //two maps associating record type IDs and Names,
        //and a map linking the Relationship's name with its Reciprocal (both ways)
        if (Trigger.isInsert || Trigger.isUpdate)
        {
            //Get ahold of all existing reciprocal relationships on the records
            for (Relationship__c r: (List<Relationship__c>)Trigger.new)
            {
                if (r.Reciprocal_Relationship__c != null)
                {
                    recipRelationshipIdSet.add(r.Reciprocal_Relationship__c);
                }
            }

            // Build Lookup Maps for the RecordTypes
            recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Relationship__c']);
            for (RecordType rt: recordTypeList)
            {
                recordTypeIdsByName.put(rt.DeveloperName, rt.Id);
                recordTypeNamesById.put(rt.Id, rt.DeveloperName);
            }

            // Build a Lookup Map for the Reciprocal Relationship Types (including the ability to look up by Name or Reciprocal Name)
            List<Relationships__c> relCustomSettings = Relationships__c.getAll().values();
            for (Relationships__c relCS: relCustomSettings)
            {
                recipRelationshipTypes.put(relCS.Reciprocal__c, relCS.Name);
                recipRelationshipTypes.put(relCS.Name, relCS.Reciprocal__c);
            }
        }
        //If we have deleted records
        //Build a lists of all existing reciprocal relations on the deleted items
        else if (Trigger.isDelete)
        {
            for (Relationship__c r: (List<Relationship__c>)Trigger.old)
            {
                if (r.Reciprocal_Relationship__c != null)
                {
                    recipRelationshipIdSet.add(r.Reciprocal_Relationship__c);
                }
            }           
        }

        if (Trigger.IsInsert)
        {
            //Contains all Relationships which our inserted relationships list as reciprocals
            Map<Id, Relationship__c> existingRecipRelationshipMap = new Map<Id, Relationship__c>([SELECT Id, Reciprocal_Relationship__c FROM Relationship__c WHERE Id IN :recipRelationshipIdSet]);

            List<Relationship__c> recipRelationshipsToUpdate = new List<Relationship__c>();
            List<Relationship__c> recipRelationshipsToInsert = new List<Relationship__c>();

            //For all inserted relationships:
            for (Relationship__c r: (List<Relationship__c>)Trigger.new)
            {
                //If we have no reciprocal
                if (r.Reciprocal_Relationship__c == null)
                {
                    //Get the reciprocal Relationship type for this Relationship
                    String recipRelationshipType = recipRelationshipTypes.get(r.Relationship_Type__c);

                    //If our Relationship has a Record Type with a corresponding "Reciprocal Record Type", get that Record Type
                    //For example, Account to Account Record Type has a corresponding "Account to Account Reciprocal" Record Type
                    Relationship__c recipRel = new Relationship__c();
                    if (recordTypeIdsByName.containsKey(recordTypeNamesById.get(r.RecordTypeId) + '_Reciprocal'))
                    {
                        recipRel.RecordTypeId = recordTypeIdsByName.get(recordTypeNamesById.get(r.RecordTypeId) + '_Reciprocal');
                    }
                    // If there is no corresponding "reciprocal" record type defined, skip it
                    else
                    {
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

                    //If we have no reciprocal Relationship type, just use the inserted Relationship's type; else use the reciprocal.
                    recipRel.Relationship_Type__c = (recipRelationshipType == null? r.Relationship_Type__c : recipRelationshipType);
                    recipRelationshipsToInsert.add(recipRel);
                }
                //If we DO have an existing reciprocal
                else 
                {
                    //If the reciprocal our inserted relationship claims it has actually exists
                    //Get that reciprocal and link it up to our inserted relationship
                    if (existingRecipRelationshipMap.containsKey(r.Reciprocal_Relationship__c))
                    {
                        Relationship__c recipRel = existingRecipRelationshipMap.get(r.Reciprocal_Relationship__c);
                        recipRel.Reciprocal_Relationship__c = r.Id;
                        recipRelationshipsToUpdate.add(recipRel);
                    }
                }
            }

            //Insert / update as needed
            if (recipRelationshipsToInsert.size() > 0)
            {
                insert recipRelationshipsToInsert;
            }

            if (recipRelationshipsToUpdate.size() > 0)
            {
                update recipRelationshipsToUpdate;
            }
        }

        if (Trigger.isUpdate)
        {
            List<Relationship__c> recipRelationshipsToUpdate = new List<Relationship__c>();

            //Get a list of all reciprocal relationships that our updated relationships claim to have
            Map<Id, Relationship__c> recipRelationshipMap = new Map<Id, Relationship__c>([SELECT Id, RecordTypeId, Account__c, Related_Account__c, Related_Contact__c, Contact__c, Active_Relationship__c, Relationship_Start_Date__c, Relationship_End_Date__c, Relationship_Type__c FROM Relationship__c WHERE Id IN :recipRelationshipIdSet]);
            
            //For all the updated relationships
            for (Relationship__c r: (List<Relationship__c>)Trigger.new)
            {
                //Get the reciprocal our updated relationship claims to have
                Relationship__c recipRelationship = recipRelationshipMap.get(r.Reciprocal_Relationship__c);

                //If the reciprocal relationship actually exists
                //For each of the reciprocal relationship's linked fields (account, contact, relationship, start and end dates), make sure they are synced between the Relationship and the Reciprocal
                if (recipRelationship != null)
                {
                    Boolean updateMade = false;
                    if (recipRelationship.Account__c != r.Related_Account__c)
                    {
                        recipRelationship.Account__c = r.Related_Account__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Related_Account__c != r.Account__c)
                    {
                        recipRelationship.Related_Account__c = r.Account__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Related_Contact__c != r.Contact__c)
                    {
                        recipRelationship.Related_Contact__c = r.Contact__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Contact__c != r.Related_Contact__c)
                    {
                        recipRelationship.Contact__c = r.Related_Contact__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Active_Relationship__c != r.Active_Relationship__c)
                    {
                        recipRelationship.Active_Relationship__c = r.Active_Relationship__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Relationship_Start_Date__c != r.Relationship_Start_Date__c)
                    {
                        recipRelationship.Relationship_Start_Date__c = r.Relationship_Start_Date__c;
                        updateMade = true;
                    }
                    if (recipRelationship.Relationship_End_Date__c != r.Relationship_End_Date__c)
                    {
                        recipRelationship.Relationship_End_Date__c = r.Relationship_End_Date__c;
                        updateMade = true;
                    }

                    //Update the reciprocal relationship type
                    string recipRelationshipType = recipRelationshipTypes.get(r.Relationship_Type__c);
                    if (recipRelationship.Relationship_Type__c != (recipRelationshipType == null? r.Relationship_Type__c : recipRelationshipType))
                    {
                        recipRelationship.Relationship_Type__c = (recipRelationshipType == null? r.Relationship_Type__c : recipRelationshipType);
                        updateMade = true;
                    }

                    if (updateMade)
                    {
                        recipRelationshipsToUpdate.add(recipRelationship);
                    }
                }   
            }

            //Update anything we have to
            if (recipRelationshipsToUpdate.size() > 0)
            {
                update recipRelationshipsToUpdate;
            }
        }

        if (Trigger.IsDelete)
        {
            //Get all the reciprocal relationships that we need to delete and delete them
            List<Relationship__c> recipRelationshipsToDelete = new List<Relationship__c>([SELECT Id FROM Relationship__c WHERE Id IN :recipRelationshipIdSet]);
            if (recipRelationshipsToDelete.size() > 0)
            {
                delete recipRelationshipsToDelete;
            }
        }
    }
       
    public void beforeInsert(SObject so) {}
    
    public void beforeUpdate(SObject oldSo, SObject so) {}

    public void beforeDelete(SObject so) {}
    
    public void beforeFinally() {}
    
    public void afterInsert(SObject so) {}

    public void afterUpdate(SObject oldSo, SObject so) {}

    public void afterDelete(SObject so) {}

    public void andFinally() {}
}