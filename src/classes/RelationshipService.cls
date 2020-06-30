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
        Map<String, Relationships__c> settings = Relationships__c.getAll(); // Map of relationship types to their recip values
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
            if (settings.containsKey(relation.Relationship_Type__c)) {
                if (relation.Reciprocal_Relationship__c == null) {
                    rel = new Relationship__c(
                        Contact__c = relation.Related_Contact__c,
                        Related_Contact__c = relation.Contact__c,
                        Account__c = relation.Related_Account__c,
                        Related_Account__c = relation.Account__c,
                        Active_Relationship__c = relation.Active_Relationship__c,
                        Relationship_Type__c = settings.get(relation.Relationship_Type__c).Reciprocal__c,
                        Reciprocal_Relationship__c = relation.Id,
                        Relationship_Start_Date__c = relation.Relationship_Start_Date__c,
                        Relationship_End_Date__c = relation.Relationship_End_Date__c,
                        Title__c = relation.Title__c,
                        Primary_Parent__c = relation.Primary_Parent__c,
                        Source__c = relation.Source__c,
                        Source_Date__c = relation.Source_Date__c
                    );

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
                relation.addError('Relationship Type Not Found');
            }
        }

        // Insert Reciprocal relationships
        try {
            if (!sourceToRecip.isEmpty()) {
                insert sourceToRecip.values();
            }
        } catch (Exception e) {
            System.debug(e);
            //newRels[0].addError(Label.PrimaryRelationshipError);
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

        if (!relsToUpdate.isEmpty()) {
            update relsToUpdate;
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
        Map<String, Relationships__c> settings = Relationships__c.getAll(); // Map of relationship types to their recip values
        Map<Id, Relationship__c> recipToSource = new Map<Id, Relationship__c>(); // Id of recip relationship to it's source
        List<Relationship__c> relsToUpdate = new List<Relationship__c>();
        List<Relationship__c> relsWithoutRecips = new List<Relationship__c>();
        Relationship__c rel; // Temporary relationship

        for (Relationship__c relation : (List<Relationship__c>) newRels) {
            if (settings.containsKey(relation.Relationship_Type__c)) {
                if (relation.Reciprocal_Relationship__c != null) {
                    recipToSource.put(relation.Reciprocal_Relationship__c, relation);
                } else {
                    relsWithoutRecips.add(relation);
                }
            } else {
                relation.addError('Relationship Type Not Found');
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
                    Account__c,
                    Relationship_End_Date__c,
                    Reciprocal_Relationship__c,
                    Title__c,
                    Primary_Parent__c,
                    Sub_Type__c,
                    Source__c,
                    Source_Date__c
                FROM Relationship__c
                WHERE Id IN :recipToSource.keySet()
            ]) {
                rel = recipToSource.get(relation.Id);

                // Check for any differences in the fields
                if (
                    relation.contact__c != rel.Related_Contact__c ||
                    relation.Related_Contact__c != rel.Contact__c ||
                    relation.Account__c != rel.Related_Account__c ||
                    relation.Related_Account__c != rel.Account__c ||
                    relation.Active_Relationship__c != rel.Active_Relationship__c ||
                    relation.Relationship_Type__c != settings.get(rel.Relationship_Type__c).Reciprocal__c ||
                    relation.Relationship_Start_Date__c != rel.Relationship_Start_Date__c ||
                    relation.Relationship_End_Date__c != rel.Relationship_End_Date__c ||
                    relation.Reciprocal_Relationship__c != rel.Id ||
                    relation.Title__c != rel.Title__c ||
                    relation.Primary_Parent__c != rel.Primary_Parent__c ||
                    relation.Sub_Type__c != rel.Sub_Type__c ||
                    relation.Source__c != rel.Source__c ||
                    relation.Source_Date__c != rel.Source_Date__c
                ) {
                    relation.Contact__c = rel.Related_Contact__c;
                    relation.Related_Contact__c = rel.Contact__c;
                    relation.Account__c = rel.Related_Account__c;
                    relation.Related_Account__c = rel.Account__c;
                    relation.Active_Relationship__c = rel.Active_Relationship__c;
                    relation.Relationship_Type__c = settings.get(rel.Relationship_Type__c).Reciprocal__c;
                    relation.Relationship_Start_Date__c = rel.Relationship_Start_Date__c;
                    relation.Relationship_End_Date__c = rel.Relationship_End_Date__c;
                    relation.Reciprocal_Relationship__c = rel.Id;
                    relation.Title__c = rel.Title__c;
                    relation.Primary_Parent__c = rel.Primary_Parent__c;
                    relation.Sub_Type__c = rel.Sub_Type__c;
                    relation.Source__c = rel.Source__c;
                    relation.Source_Date__c = rel.Source_Date__c;

                    relsToUpdate.add(relation);
                }
            }

            try {
                if (!relsToUpdate.isEmpty()) {
                    update relsToUpdate;
                }
            } catch (Exception e) {
                System.debug(e);
                //newRels[0].addError(Label.PrimaryRelationshipError);
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

    /**
     * Verifies that a single contact object does not have more
     * than two primary guardians
     *
     * @param List<SObject> List of newly inserted relationships
     */
    public static boolean verifyTwoPrimary(List<Relationship__c> relList) {
        List<Id> contactList = new List<Id>();
        for (Relationship__c rel : relList) {
            if (rel.Primary_Parent__c && relatedContactIsDependentOfPrimaryParent(rel)) {
                contactList.add(rel.Related_Contact__c);
            }
        }
        List<Contact> contactsWithTwoPrimaryParents = [
            SELECT Id
            FROM Contact
            WHERE Rel_Parent_1__c != null AND Rel_Parent_2__c != null AND Id IN :contactList
        ];
        if (!contactsWithTwoPrimaryParents.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * When a relationship is updated, it checks if the primary parents changed
     * and if so it verifies that they still meet the two parent restriction
     *
     * @param List<Relationship__c> newRel List of newly inserted relationships
     * @param List<Relationship__c> oldRel List of old inserted relationships
     * @return if changes are valid
     */
    public static boolean checkChanges(Map<Id, Relationship__C> relMapOld, Map<Id, Relationship__C> relMapNew) {
        List<Relationship__c> relListAdded = new List<Relationship__c>();
        List<Relationship__c> relListRemoved = new List<Relationship__c>();

        for (Id relIds : relMapOld.keySet()) {
            if (primaryParentAddedAndIsActive(relMapOld.get(relIds), relMapNew.get(relIds))) {
                relListAdded.add(relMapNew.get(relIds));
            } else if (primaryParentRemovedOrIsNotActive(relMapOld.get(relIds), relMapNew.get(relIds))) {
                relListRemoved.add(relMapNew.get(relIds));
            }
        }

        Boolean validChange = verifyTwoPrimary(relListAdded);
        if (validChange) {
            removeParent(relListRemoved);
            updateContacts(relListAdded);
        }

        return validChange;
    }

    public static void updateContacts(List<Relationship__c> relList) {
        List<Id> contactList = new List<Id>();
        for (Relationship__c rel : relList) {
            if (rel.Primary_Parent__c && rel.Contact__c != null && rel.Related_Contact__c != null) {
                if (relatedContactIsDependentOfPrimaryParent(rel)) {
                    contactList.add(rel.Related_Contact__c);
                }
            }
        }
        if (!contactList.isEmpty()) {
            List<Contact> contactsToEdit = [
                SELECT Rel_Parent_1__c, Rel_Parent_2__c, Rel_Relationship_Id_1__c, Rel_Relationship_Id_2__c
                FROM Contact
                WHERE Id IN :contactList
            ];
            List<Contact> contactsToUpdate = new List<Contact>();
            for (Contact con : contactsToEdit) {
                for (Relationship__c rel : relList) {
                    if (contactMatchesPrimaryContact(rel, con)) {
                        if (con.Rel_Parent_1__c == null) {
                            con.Rel_Parent_1__c = rel.Related_Contact__c;
                            con.Rel_Relationship_Id_1__c = rel.Id;
                        } else {
                            con.Rel_Parent_2__c = rel.Related_Contact__c;
                            con.Rel_Relationship_Id_2__c = rel.Id;
                        }
                        contactsToUpdate.add(con);
                    } else if (contactMatchesRelatedContact(rel, con)) {
                        if (con.Rel_Parent_1__c == null) {
                            con.Rel_Parent_1__c = rel.Contact__c;
                            con.Rel_Relationship_Id_1__c = rel.Id;
                        } else {
                            con.Rel_Parent_2__c = rel.Contact__c;
                            con.Rel_Relationship_Id_2__c = rel.Id;
                        }
                        contactsToUpdate.add(con);
                    }
                }
            }
            update contactsToUpdate;
        }
    }

    public static void removeParent(List<Relationship__c> relList) {
        List<Id> contactIdList = new List<Id>();

        if (!relList.isEmpty()) {
            for (Relationship__c rel : relList) {
                contactIdList.add(rel.Contact__c);
            }

            List<Contact> contactList = [
                SELECT Id, Rel_Parent_1__c, Rel_Parent_2__c, Rel_Relationship_Id_1__c, Rel_Relationship_Id_2__c
                FROM Contact
                WHERE Id IN :contactIdList
            ];
            Map<Id, Contact> parent1ToContact = new Map<Id, Contact>();
            Map<Id, Contact> parent2ToContact = new Map<Id, Contact>();
            for (Contact con : contactList) {
                if (con.Rel_Parent_1__c != null) {
                    parent1ToContact.put(con.Rel_Parent_1__c, con);
                }
                if (con.Rel_Parent_2__c != null) {
                    parent2ToContact.put(con.Rel_Parent_2__c, con);
                }
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            for (Relationship__c rel : relList) {
                if (parent2ToContact.containsKey(rel.Related_Contact__c)) {
                    Contact relatedContact = parent2ToContact.get(rel.Related_Contact__c);
                    relatedContact.Rel_Parent_2__c = null;
                    relatedContact.Rel_Relationship_Id_2__c = null;
                    contactsToUpdate.add(relatedContact);
                } else if (parent1ToContact.containsKey(rel.Related_Contact__c)) {
                    Contact relatedContact = parent1ToContact.get(rel.Related_Contact__c);
                    if (relatedContact.Rel_Parent_2__c == null) {
                        relatedContact.Rel_Parent_1__c = null;
                        relatedContact.Rel_Relationship_Id_1__c = null;
                    } else {
                        relatedContact.Rel_Parent_1__c = relatedContact.Rel_Parent_2__c;
                        relatedContact.Rel_Relationship_Id_1__c = relatedContact.Rel_Relationship_Id_2__c;
                        relatedContact.Rel_Parent_2__c = null;
                        relatedContact.Rel_Relationship_Id_2__c = null;
                        parent2ToContact.remove(relatedContact.Rel_Parent_2__c);
                    }
                    contactsToUpdate.add(relatedContact);
                }
            }
            update contactsToUpdate;
        }
    }

    public static void updateNullCreatedByName(List<Relationship__c> newRelationships) {
        Set<Id> createdByUserIds = new Set<Id>();

        for (Relationship__c newRelationship : newRelationships) {
            createdByUserIds.add(newRelationship.CreatedById);
        }

        for (Relationship__c newRelationship : [
            SELECT
                Id,
                Relationship_Created_By__c,
                CreatedBy.Profile.Name,
                Source__c,
                Source_Date__c,
                Reciprocal_Relationship__r.Source__c,
                Reciprocal_Relationship__r.Source_Date__c
            FROM Relationship__c
            WHERE CreatedById IN :createdByUserIds
        ]) {
            if (newRelationship.Relationship_Created_By__c == null && newRelationship.CreatedBy.Profile.Name != null) {
                newRelationship.Relationship_Created_By__c = newRelationship.CreatedBy.Profile.Name;
                if (
                    newRelationship.Reciprocal_Relationship__r.Source__c != null &&
                    newRelationship.Source_Date__c == null &&
                    newRelationship.Source__c == null
                ) {
                    newRelationship.Source_Date__c = newRelationship.Reciprocal_Relationship__r.Source_Date__c;
                    newRelationship.Source__c = newRelationship.Reciprocal_Relationship__r.Source__c;
                }
            }
        }
    }

    public static void updateNullSubTypes(List<Relationship__c> newRelationships) {
        for (Relationship__c newRelationship : newRelationships) {
            if (
                newRelationship.Sub_Type__c == null &&
                newRelationship.Reciprocal_Relationship__c != null &&
                newRelationship.Reciprocal_Relationship__r.Sub_Type__c != null
            ) {
                Relationship_SubType__c reciprocalSubType = [
                    SELECT Reciprocal_SubType__c
                    FROM Relationship_SubType__c
                    WHERE Name = :newRelationship.Reciprocal_Relationship__r.Sub_Type__c
                    LIMIT 1
                ];
                if (reciprocalSubType.Reciprocal_SubType__c != null) {
                    newRelationship.Sub_Type__c = reciprocalSubType.Reciprocal_SubType__c;
                }
                if (newRelationship.Reciprocal_Relationship__r.Revoke_Status__c != null) {
                    newRelationship.Revoke_Status__c = newRelationship.Reciprocal_Relationship__r.Revoke_Status__c;
                }
            }
        }
    }

    public static void updateReciprocalRelationshipStatus(
        Map<Id, Relationship__c> relationshipsBeforeUpdate,
        Map<Id, Relationship__c> relationshipsAfterUpdate
    ) {
        Map<Id, Relationship__c> relationshipsAfterUpdateAmended = new Map<Id, Relationship__c>();

        for (Relationship__c rel : [
            SELECT Id, Revoke_Status__c, Reciprocal_Relationship__r.Revoke_Status__c
            FROM Relationship__c
            WHERE Id IN :relationshipsAfterUpdate.keySet()
        ]) {
            relationshipsAfterUpdateAmended.put(rel.Id, rel);
        }

        for (Id key : relationshipsAfterUpdateAmended.keySet()) {
            Relationship__c relationshipBefore = relationshipsBeforeUpdate.get(key);
            Relationship__c relationshipAfter = relationshipsAfterUpdateAmended.get(key);
            if (
                relationshipBefore.Revoke_Status__c != relationshipAfter.Revoke_Status__c &&
                relationshipAfter.Revoke_Status__c != relationshipAfter.Reciprocal_Relationship__r.Revoke_Status__c
            ) {
                relationshipAfter.Reciprocal_Relationship__r.Revoke_Status__c = relationshipAfter.Revoke_Status__c;
            }
        }
    }

    private static boolean relatedContactIsDependentOfPrimaryParent(Relationship__c rel) {
        return rel.Relationship_Type__c == 'Parent/Guardian';
    }

    private static boolean contactMatchesPrimaryContact(Relationship__c rel, Contact con) {
        if (!relatedContactIsDependentOfPrimaryParent(rel)) {
            return rel.Contact__c == con.Id;
        } else {
            return false;
        }
    }

    private static boolean contactMatchesRelatedContact(Relationship__c rel, Contact con) {
        if (relatedContactIsDependentOfPrimaryParent(rel)) {
            return rel.Related_Contact__c == con.Id;
        } else {
            return false;
        }
    }

    private static boolean primaryParentAddedAndIsActive(Relationship__c oldRel, Relationship__c newRel) {
        return (!oldRel.Primary_Parent__c && newRel.Primary_Parent__c) ||
            (newRel.Primary_Parent__c &&
            !oldRel.Active_Relationship__c &&
            newRel.Active_Relationship__c);
    }

    private static boolean primaryParentRemovedOrIsNotActive(Relationship__c oldRel, Relationship__c newRel) {
        return (oldRel.Primary_Parent__c && !newRel.Primary_Parent__c) || !newRel.Active_Relationship__c;
    }
}
