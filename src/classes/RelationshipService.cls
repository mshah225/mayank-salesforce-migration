public class RelationshipService {
    /**
     * When a relationship is inserted a "Reciprocal" (recip)
     * relationship must be created. The primary difference between the two relationships
     * is that the Contact__c and Related_Contact__c field values are flipped. The relationships
     * are linked 1:1 via the Reciprocal_Relationship__c field.
     * <p>
     * If a relationship is inserted and the Reciprocal_Relationship__c field is pre-populated,
     * we only need to update the recip to ensure that the values match.
     * </p>
     *
     * @param List<SObject> List of newly inserted relationships
     */
    public static void createReciprocal(List<Relationship__c> newRels) {
        Id contactToAccountRTID; // Id of contact to account record type
        ID accountToContactRTID; // Id of account to contact record type
        Map<Id, Id> recipRTIDMap = new Map<Id, Id>(); // Id of record type to it's reciprocal
        Map<String, Relationships__c> relationshipTypes = Relationships__c.getAll(); // Map of relationship types to their recip values
        Map<String, Relationship_SubType__c> relationshipSubTypes = Relationship_SubType__c.getAll();
        Relationship__c rel; // Temporary relationship
        Map<Id, Relationship__c> sourceToRecip = new Map<Id, Relationship__c>(); // Source Id to recip relationship object
        Map<Id, Id> sourceToRecipId = new Map<Id, Id>(); // Contains the source Id to the Id for it's reciprocal
        List<Relationship__c> relsToUpdate = new List<Relationship__c>();

        // Build reciprocal map
        contactToAccountRTID = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Relationship__c' AND Name = 'Contact to Account'
            LIMIT 1
        ]
        .Id;

        accountToContactRTID = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Relationship__c' AND Name = 'Account to Contact'
            LIMIT 1
        ]
        .Id;

        recipRTIDMap.put(contactToAccountRTID, accountToContactRTID);
        recipRTIDMap.put(accountToContactRTID, contactToAccountRTID);

        // Create reciprocal relationships
        for (Relationship__c relation : newRels) {
            if (relationshipTypes.containsKey(relation.Relationship_Type__c)) {
                if (relation.Reciprocal_Relationship__c == null) {
                    rel = new Relationship__c(
                        Contact__c = relation.Related_Contact__c,
                        Related_Contact__c = relation.Contact__c,
                        Account__c = relation.Related_Account__c,
                        Related_Account__c = relation.Account__c,
                        Active_Relationship__c = relation.Active_Relationship__c,
                        Reciprocal_Relationship__c = relation.Id,
                        Relationship_Created_By__c = relation.Relationship_Created_By__c,
                        Relationship_Start_Date__c = relation.Relationship_Start_Date__c,
                        Relationship_End_Date__c = relation.Relationship_End_Date__c,
                        Title__c = relation.Title__c,
                        Revoke_Status__c = relation.Revoke_Status__c,
                        Source__c = relation.Source__c,
                        Source_Date__c = relation.Source_Date__c
                    );

                    if (
                        relationshipTypes.get(relation.Relationship_Type__c) != null &&
                        relationshipTypes.get(relation.Relationship_Type__c).Reciprocal__c != null
                    ) {
                        rel.Relationship_Type__c = relationshipTypes.get(relation.Relationship_Type__c).Reciprocal__c;
                    } else {
                        rel.Relationship_Type__c = null;
                    }

                    if (
                        relationshipSubTypes.get(relation.Sub_Type__c) != null &&
                        relationshipSubTypes.get(relation.Sub_Type__c).Reciprocal_SubType__c != null
                    ) {
                        rel.Sub_Type__c = relationshipSubTypes.get(relation.Sub_Type__c).Reciprocal_SubType__c;
                    } else {
                        rel.Sub_Type__c = null;
                    }

                    if (recipRTIDMap.get(relation.RecordTypeId) == null) {
                        rel.RecordTypeId = relation.RecordTypeId;
                    } else {
                        rel.RecordTypeId = recipRTIDMap.get(relation.RecordTypeId);
                    }

                    sourceToRecip.put(relation.Id, rel);
                } else if (relation.Reciprocal_Relationship__c != null) {
                    // I am the recip and I have the Id of my source
                    // Map my source to my id in a queryable way (Map<Id, Id>)
                    sourceToRecipId.put(relation.Reciprocal_Relationship__c, relation.Id);
                }
            } else {
                relation.addError('Relationship type not found');
            }
        }

        // Insert Reciprocal relationships
        try {
            if (!sourceToRecip.isEmpty()) {
                insert sourceToRecip.values();
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Exception: ', e.getMessage()));
            ErrorLogger.log(e, vars, false);
        }

        if (!sourceToRecipId.isEmpty()) {
            for (Relationship__c relation : [
                SELECT Id, Reciprocal_Relationship__c
                FROM Relationship__c
                WHERE Id IN :sourceToRecipId.keySet()
            ]) {
                relation.Reciprocal_Relationship__c = sourceToRecipId.get(relation.Id);
                relsToUpdate.add(relation);
            }
        }

        try {
            if (!relsToUpdate.isEmpty()) {
                update relsToUpdate;
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Exception: ', e.getMessage()));
            ErrorLogger.log(e, vars, false);
        }
    }

    /**
     * When a relationship is updated (restricted by record type) the "Reciprocal" (recip)
     * relationship must be updated. The primary difference between the two relationships
     * is that the Contact__c and Related_Contact__c field values are flipped. The relationships
     * are linked 1:1 via the Reciprocal_Relationship__c field.
     *
     * @param List<SObject> List of newly inserted relationships
     */
    public static void updateReciprocal(List<SObject> newRels) {
        Map<String, Relationships__c> relationshipTypes = Relationships__c.getAll(); // Map of relationship types to their recip values
        Map<String, Relationship_SubType__c> relationshipSubTypes = Relationship_SubType__c.getAll();
        Map<Id, Relationship__c> recipToSource = new Map<Id, Relationship__c>(); // Id of recip relationship to it's source
        List<Relationship__c> relsToUpdate = new List<Relationship__c>();
        List<Relationship__c> relsWithoutRecips = new List<Relationship__c>();
        Relationship__c rel; // Temporary relationship

        for (Relationship__c relation : (List<Relationship__c>) newRels) {
            if (relationshipTypes.containsKey(relation.Relationship_Type__c)) {
                if (relation.Reciprocal_Relationship__c != null) {
                    recipToSource.put(relation.Reciprocal_Relationship__c, relation);
                } else {
                    relsWithoutRecips.add(relation);
                }
            } else {
                relation.addError('Relationship type not found');
            }
        }

        if (!recipToSource.isEmpty()) {
            for (Relationship__c relation : [
                SELECT
                    Contact__c,
                    Related_Contact__c,
                    RecordTypeId,
                    Related_Account__c,
                    Relationship_Start_Date__c,
                    Active_Relationship__c,
                    Relationship_Type__c,
                    Relationship_Created_By__c,
                    Account__c,
                    Relationship_End_Date__c,
                    Reciprocal_Relationship__c,
                    Title__c,
                    Revoke_Status__c,
                    Sub_Type__c,
                    Source__c,
                    Source_Date__c
                FROM Relationship__c
                WHERE Id IN :recipToSource.keySet()
            ]) {
                rel = recipToSource.get(relation.Id);

                // Ensure field values are set to corresponding reciprocal field values
                relation.Contact__c = rel.Related_Contact__c;
                relation.Related_Contact__c = rel.Contact__c;
                relation.Account__c = rel.Related_Account__c;
                relation.Related_Account__c = rel.Account__c;
                relation.Active_Relationship__c = rel.Active_Relationship__c;
                relation.Relationship_Created_By__c = rel.Relationship_Created_By__c;
                relation.Relationship_Start_Date__c = rel.Relationship_Start_Date__c;
                relation.Relationship_End_Date__c = rel.Relationship_End_Date__c;
                relation.Reciprocal_Relationship__c = rel.Id;
                relation.Title__c = rel.Title__c;
                relation.Revoke_Status__c = rel.Revoke_Status__c;
                relation.Source__c = rel.Source__c;
                relation.Source_Date__c = rel.Source_Date__c;

                if (
                    relationshipTypes.get(rel.Relationship_Type__c) != null &&
                    relationshipTypes.get(rel.Relationship_Type__c).Reciprocal__c != null
                ) {
                    relation.Relationship_Type__c = relationshipTypes.get(rel.Relationship_Type__c).Reciprocal__c;
                } else {
                    relation.Relationship_Type__c = null;
                }

                if (
                    relationshipSubTypes.get(rel.Sub_Type__c) != null &&
                    relationshipSubTypes.get(rel.Sub_Type__c).Reciprocal_SubType__c != null
                ) {
                    relation.Sub_Type__c = relationshipSubTypes.get(rel.Sub_Type__c).Reciprocal_SubType__c;
                } else {
                    relation.Sub_Type__c = null;
                }

                relsToUpdate.add(relation);
            }

            try {
                if (!relsToUpdate.isEmpty()) {
                    update relsToUpdate;
                }
            } catch (Exception e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('Exception: ', e.getMessage()));
                ErrorLogger.log(e, vars, false);
            }
        }

        if (!relsWithoutRecips.isEmpty()) {
            createReciprocal(relsWithoutRecips);
        }
    }

    /**
     * When a relationship is deleted, the reciprocal also needs to be deleted
     *
     * @param List<SObject> List of old inserted relationships
     */
    public static void deleteReciprocal(List<Relationship__c> oldRels) {
        Set<Id> relsToDelete = new Set<Id>();

        for (Relationship__c relation : oldRels) {
            if (relation.Reciprocal_Relationship__c != null) {
                relsToDelete.add(relation.Reciprocal_Relationship__c);
            }
        }

        if (!relsToDelete.isEmpty()) {
            List<Relationship__c> relationsToDelete = new List<Relationship__c>();
            for (Id idForRel : relsToDelete) {
                relationsToDelete.add(new Relationship__c(id = idForRel));
            }
            delete relationsToDelete;
        }
    }

    /**
     * Creates a new relationship between an account and contact
     *
     * @param c contact Id
     * @param a accojnt Id
     * @param rt record type id
     * @param title title of relationship
     * @return relationship object
     */
    public static Relationship__c createContactAccountRelationship(
        Id contactId,
        Id accountId,
        Id recordTypeId,
        String title
    ) {
        Relationship__c r = new Relationship__c(
            Related_Account__c = accountId,
            Contact__c = contactId,
            Relationship_Type__c = 'Employee',
            RecordTypeId = recordTypeID,
            Title__c = title
        );

        return r;
    }

    public static void insertCreatedByProfileName(List<Relationship__c> newRelationships) {
        Set<Id> newRelationshipIds = new Set<Id>();
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();

        for (Relationship__c newRelationship : newRelationships) {
            newRelationshipIds.add(newRelationship.Id);
        }

        for (Relationship__c newRelationship : [
            SELECT Id, Relationship_Created_By__c, CreatedBy.Profile.Name
            FROM Relationship__c
            WHERE Id IN :newRelationshipIds
        ]) {
            if (newRelationship.Relationship_Created_By__c == null && newRelationship.CreatedBy.Profile.Name != null) {
                newRelationship.Relationship_Created_By__c = newRelationship.CreatedBy.Profile.Name;
                relationshipsToUpdate.add(newRelationship);
            }
        }

        try {
            if (relationshipsToUpdate.size() > 0) {
                update relationshipsToUpdate;
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('Exception: ', e.getMessage()));
            ErrorLogger.log(e, vars, false);
        }
    }
}
