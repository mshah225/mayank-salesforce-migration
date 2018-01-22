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
        contactToAccountRTID = [SELECT Id
                                FROM RecordType
                                WHERE SObjectType = 'Relationship__c'
                                AND Name = 'Contact to Account' LIMIT 1].Id;
        
        accountToContactRTID = [SELECT Id
                                FROM RecordType
                                WHERE SObjectType = 'Relationship__c'
                                AND Name = 'Account to Contact' LIMIT 1].Id;
        
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
                        Title__c = relation.Title__c
                    );
                    
                    if (recipRTIDMap.get(relation.RecordTypeId) == null) {
                        rel.RecordTypeId = relation.RecordTypeId;
                    } else {
                        rel.RecordTypeId = recipRTIDMap.get(relation.RecordTypeId);
                    }
                    
                    sourceToRecip.put(relation.Id, rel);
                } else if (relation.Reciprocal_Relationship__c != null) {
                    //I am the recip and I have the Id of my source
                    //Map my source to my id in a queryable way (Map<Id, Id>)
                    sourceToRecipId.put(relation.Reciprocal_Relationship__c, relation.Id);
                }
            } else {
                relation.addError('Relationship Type Not Found');
            }
        }
        
        // Insert Reciprocal relationships
        if (!sourceToRecip.isEmpty()) {
            insert sourceToRecip.values();
        }
        
        if (!sourceToRecipId.isEmpty()) {
            for (Relationship__c relation : [SELECT Id, Reciprocal_Relationship__c 
                                      FROM Relationship__c
                                      WHERE Id IN :sourceToRecipId.keySet()]) {
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
        Map<Id, Relationship__c> recipToSource =  new Map<Id, Relationship__c>(); // Id of recip relationship to it's source
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
                for (Relationship__c relation : [SELECT Contact__c,  Related_Contact__c, RecordTypeId, Related_Account__c,
                                          Relationship_Start_Date__c, Active_Relationship__c, Relationship_Type__c,
                                          Account__c, Relationship_End_Date__c, Reciprocal_Relationship__c, Title__c
                                          FROM Relationship__c
                                          WHERE Id IN :recipToSource.keySet()]) {
                                              rel = recipToSource.get(relation.Id);
                                              
                                              // Check for any differences in the fields
                                              if (relation.contact__c != rel.Related_Contact__c ||
                                                  relation.Related_Contact__c != rel.Contact__c ||
                                                  relation.Account__c != rel.Related_Account__c ||
                                                  relation.Related_Account__c != rel.Account__c ||
                                                  relation.Active_Relationship__c != rel.Active_Relationship__c ||
                                                  relation.Relationship_Type__c != settings.get(rel.Relationship_Type__c).Reciprocal__c ||
                                                  relation.Relationship_Start_Date__c != rel.Relationship_Start_Date__c ||
                                                  relation.Relationship_End_Date__c != rel.Relationship_End_Date__c ||
                                                  relation.Reciprocal_Relationship__c != rel.Id ||
                                                  relation.Title__c != rel.Title__c) {
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
                                                      
                                                      relsToUpdate.add(relation);
                                              }
                                          }
                
                if (!relsToUpdate.isEmpty()) {
                    update relsToUpdate;
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
    public static Relationship__c createContactAccountRelationship(Id contactId, Id accountId, Id recordTypeId, String title) {
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
    public static boolean verifyTwoPrimary(List<Relationship__c> rel) {
        List<Id> contactList = new List<Id>();
        for (Relationship__c relLst : rel) {
            if (relLst.Primary_Parent__c) {
                contactList.add(relLst.Contact__c);
            }
        }
        AggregateResult[] groupedResults = [SELECT Contact__c 
                                            FROM Relationship__c 
                                            WHERE Primary_Parent__c = true AND Contact__c IN :contactList 
                                            GROUP BY Contact__c HAVING COUNT(Id) >= 2];
        if (!groupedResults.isEmpty()) {
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
        
        for(Id relIds : relMapOld.keySet()) {
            if (!relMapOld.get(relIds).Primary_Parent__c && relMapNew.get(relIds).Primary_Parent__c) {
                relListAdded.add(relMapNew.get(relIds));
            } else if (relMapOld.get(relIds).Primary_Parent__c && !relMapNew.get(relIds).Primary_Parent__c) {
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
                contactList.add(rel.Contact__c);
            }
        }
        if (!contactList.isEmpty()) {
            List<Contact> contactsToEdit = [SELECT Rel_Parent_1__c, Rel_Parent_2__c, Rel_Parent_Email_1__c,
                                            Rel_Parent_Email_2__c, Rel_Parent_FirstName_1__c, Rel_Parent_FirstName_2__c,
                                            Rel_Parent_LastName_1__c, Rel_Parent_LastName_2__c
                                            FROM Contact 
                                            WHERE Id IN :contactList 
                                            ];
            List<Contact> contactsToUpdate = new List<Contact>();
            for (Contact con : contactsToEdit) {
                for (Relationship__c rel : relList) {
                    if (con.Id == rel.Contact__c) {
                        if (con.Rel_Parent_1__c == null) {
                            con.Rel_Parent_1__c = rel.Related_Contact__c;
                        } else {
                            con.Rel_Parent_2__c = rel.Related_Contact__c;
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
            
            List<Contact>  contactList = [SELECT Id, Rel_Parent_1__c, Rel_Parent_2__c
                                          FROM Contact
                                          WHERE Id IN :contactIdList];
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
                    contactsToUpdate.add(relatedContact);
                } else if (parent1ToContact.containsKey(rel.Related_Contact__c)) {
                    Contact relatedContact = parent1ToContact.get(rel.Related_Contact__c);
                    if (relatedContact.Rel_Parent_2__c == null) {
                        relatedContact.Rel_Parent_1__c = null;
                    } else {
                        relatedContact.Rel_Parent_1__c = relatedContact.Rel_Parent_2__c;
                        relatedContact.Rel_Parent_2__c = null;
                        parent2ToContact.remove(relatedContact.Rel_Parent_2__c);
                    }
                    contactsToUpdate.add(relatedContact);
                }
            }
            update contactsToUpdate;
        }
    }
}