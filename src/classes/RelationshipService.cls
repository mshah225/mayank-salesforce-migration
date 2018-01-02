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
    public static void createReciprocal(List<SObject> newRels) {
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
        for (Relationship__c r : (List<Relationship__c>) newRels) {
            if (settings.get(r.Relationship_Type__c) != null) {
                if (r.Reciprocal_Relationship__c == null) {
                    rel = new Relationship__c(
                        Contact__c = r.Related_Contact__c,
                        Related_Contact__c = r.Contact__c,
                        Account__c = r.Related_Account__c,
                        Related_Account__c = r.Account__c,
                        Active_Relationship__c = r.Active_Relationship__c,
                        Relationship_Type__c = settings.get(r.Relationship_Type__c).Reciprocal__c,
                        Reciprocal_Relationship__c = r.Id,
                        Relationship_Start_Date__c = r.Relationship_Start_Date__c,
                        Relationship_End_Date__c = r.Relationship_End_Date__c,
                        Title__c = r.Title__c
                    );
                    
                    // RecordTypeId = r.RecordTypeId,
                    if (recipRTIDMap.get(r.RecordTypeId) == null) {
                        rel.RecordTypeId = r.RecordTypeId;
                    } else {
                        rel.RecordTypeId = recipRTIDMap.get(r.RecordTypeId);
                    }
                    
                    sourceToRecip.put(r.Id, rel);
                } else if (r.Reciprocal_Relationship__c != null) {
                    //I am the recip and I have the Id of my source
                    //Map my source to my id in a queryable way (Map<Id, Id>)
                    sourceToRecipId.put(r.Reciprocal_Relationship__c, r.Id);
                }
            } else {
                r.addError('Relationship Type Not Found');
            }
        }
        
        // Insert Reciprocal relationships
        if (sourceToRecip.size() > 0) {
            system.debug('(createReciprocal) Rows Before Insert Recip: ' + limits.getDmlRows());
            insert sourceToRecip.values();
        }
        
        if (sourceToRecipId.size() > 0) {
            for (Relationship__c r : [SELECT Id, Reciprocal_Relationship__c 
                                      FROM Relationship__c
                                      WHERE Id IN :sourceToRecipId.keySet()]) {
                                          r.Reciprocal_Relationship__c = sourceToRecipId.get(r.Id);
                                          relsToUpdate.add(r);
                                      }
        }
        
        if (relsToUpdate.size() > 0) {
            system.debug('(createReciprocal) Rows Before update rels: ' + limits.getDmlRows());
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
        
            for (Relationship__c r : (List<Relationship__c>) newRels) {
                if (settings.get(r.Relationship_Type__c) != null) {
                    if (r.Reciprocal_Relationship__c != null) {
                        recipToSource.put(r.Reciprocal_Relationship__c, r);
                    } else {
                        relsWithoutRecips.add(r);
                    }
                } else {
                    r.addError('Relationship Type Not Found');   
                }
            }
            
            if (recipToSource.size() > 0) {
                for (Relationship__c r : [SELECT Contact__c,  Related_Contact__c, RecordTypeId, Related_Account__c,
                                          Relationship_Start_Date__c, Active_Relationship__c, Relationship_Type__c,
                                          Account__c, Relationship_End_Date__c, Reciprocal_Relationship__c, Title__c
                                          FROM Relationship__c
                                          WHERE Id IN :recipToSource.keySet()]) {
                                              rel = recipToSource.get(r.Id);
                                              
                                              // Check for any differences in the fields
                                              if (r.contact__c != rel.Related_Contact__c
                                                  || r.Related_Contact__c != rel.Contact__c
                                                  || r.Account__c != rel.Related_Account__c
                                                  || r.Related_Account__c != rel.Account__c
                                                  || r.Active_Relationship__c != rel.Active_Relationship__c
                                                  || r.Relationship_Type__c != settings.get(rel.Relationship_Type__c).Reciprocal__c
                                                  || r.Relationship_Start_Date__c != rel.Relationship_Start_Date__c
                                                  || r.Relationship_End_Date__c != rel.Relationship_End_Date__c
                                                  || r.Reciprocal_Relationship__c != rel.Id
                                                  || r.Title__c != rel.Title__c) {
                                                      r.Contact__c = rel.Related_Contact__c;
                                                      r.Related_Contact__c = rel.Contact__c;
                                                      r.Account__c = rel.Related_Account__c;
                                                      r.Related_Account__c = rel.Account__c;
                                                      r.Active_Relationship__c = rel.Active_Relationship__c;
                                                      r.Relationship_Type__c = settings.get(rel.Relationship_Type__c).Reciprocal__c;
                                                      r.Relationship_Start_Date__c = rel.Relationship_Start_Date__c;
                                                      r.Relationship_End_Date__c = rel.Relationship_End_Date__c;
                                                      r.Reciprocal_Relationship__c = rel.Id;
                                                      r.Title__c = rel.Title__c;
                                                      
                                                      relsToUpdate.add(r);
                                              }
                                          }
                
                system.debug('relsToUpdate.size(): ' + relsToUpdate.size());
                if (relsToUpdate.size() > 0) {
                    system.debug('(updateReciprocal) Rows after update recipt: ' + limits.getDmlRows());
                    update relsToUpdate;
                    system.debug('(updateReciprocal) Rows after update recipt: ' + limits.getDmlRows());
                }
            }
            
            if (relsWithoutRecips.size() > 0) {
                createReciprocal(relsWithoutRecips);
            }
    }
    
    // Method for deleting Reciprocal
    public static void deleteReciprocal(List<SObject> oldRels) {
        Set<Id> relsToDelete = new Set<Id>();
        
        for (Relationship__c r : (List<Relationship__c>) oldRels) {
            if (r.Reciprocal_Relationship__c != null) {
                relsToDelete.add(r.Reciprocal_Relationship__c);
            }
        }
        
        if (relsToDelete.size() > 0) {
            system.debug('(deleteReciprocal) Rows Before delete: ' + limits.getDmlRows());
            delete [SELECT Id FROM Relationship__c WHERE Id IN :relsToDelete];
        }
    }
    
    public static Relationship__c createContactAccountRelationship(Id c, Id a, Id rt, String title) {
        Relationship__c r = new Relationship__c(
            Related_Account__c = a,
            Contact__c = c,
            Relationship_Type__c = 'Employee',
            RecordTypeId = rt,
            Title__c = title
        );
        
        return r;
    }
    
    public static boolean verifyTwoPrimary(List<sObject> newRel) {
        List<Relationship__c> rel = (List<Relationship__c>) newRel;
        List<Id> contactList = new List<Id>();
        for(Relationship__c relLst : rel) {
            if(relLst.Primary_Parent__c) {
                contactList.add(relLst.Contact__c);
            }
        }
        AggregateResult[] groupedResults = [SELECT Contact__c 
                                            FROM Relationship__c 
                                            WHERE Primary_Parent__c = true AND Contact__c IN: contactList 
                                            GROUP BY Contact__c HAVING COUNT(Id) >= 2];
        if(groupedResults.size() > 0) {
            return false;
        } else {
            return true;
        }
    }
    
    public static boolean checkChanges(List<sObject> oldRel, List<sObject> newRel) {
        List<Relationship__c> relListAdded = new List<Relationship__c>();
        List<Relationship__c> relListRemoved = new List<Relationship__c>();
        List<Relationship__c> relListOld = (List<Relationship__c>) oldRel;
        List<Relationship__c> relListNew = (List<Relationship__c>) newRel;
        
        for(Integer i = 0; i < relListOld.size(); i++) {
            if(!relListOld.get(i).Primary_Parent__c && relListNew.get(i).Primary_Parent__c) {
                relListAdded.add(relListNew.get(i));
            } else if (relListOld.get(i).Primary_Parent__c && !relListNew.get(i).Primary_Parent__c) {
                relListRemoved.add(relListNew.get(i));
            }
        }
        
        Boolean validChange = verifyTwoPrimary(relListAdded);
        if(validChange) {
            removeParent(relListRemoved);
            updateContacts(relListAdded);
        }
        
        return validChange;
    }
    
    public static void updateContacts(List<sObject> newRel) {
        List<Relationship__c> relList = (List<Relationship__c>) newRel;
        List<Id> contactList = new List<Id>();
        for(Relationship__c rel : relList) {
            if(rel.Primary_Parent__c && rel.Contact__c != null && rel.Related_Contact__c != null) {
                contactList.add(rel.Contact__c);
            }
        }
        if(contactList.size() > 0) {
            List<Contact> contactsToEdit = [SELECT Rel_Parent_1__c, Rel_Parent_2__c, Rel_Parent_Email_1__c,
                                            Rel_Parent_Email_2__c, Rel_Parent_FirstName_1__c, Rel_Parent_FirstName_2__c,
                                            Rel_Parent_LastName_1__c, Rel_Parent_LastName_2__c
                                            FROM Contact 
                                            WHERE Id IN: contactList 
                                            ];
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Contact c : contactsToEdit) {
                for(Relationship__c r : relList) {
                    if(c.Id == r.Contact__c) {
                        if(c.Rel_Parent_1__c == null) {
                            c.Rel_Parent_1__c = r.Related_Contact__c;
                        } else {
                            c.Rel_Parent_2__c = r.Related_Contact__c;
                        }
                        contactsToUpdate.add(c);
                    }
                }
            }
            update contactsToUpdate;
        }
    }
    
    public static void removeParent(List<Relationship__c> relList) {
        List<Id> contactIdList = new List<Id>();
        for(Relationship__c r : relList) {
            contactIdList.add(r.Contact__c);
        }
        
        List<Contact>  contactList = [Select Id, Rel_Parent_1__c, Rel_Parent_2__c
                              From Contact
                              WHERE Id IN: contactIdList];

        Map<Id, Contact> parent1ToContact = new Map<Id, Contact>();
        Map<Id, Contact> parent2ToContact = new Map<Id, Contact>();
        for (Contact c : contactList) {
            if (c.Rel_Parent_1__c != null) {
                parent1ToContact.put(c.Rel_Parent_1__c, c);
            }
            if (c.Rel_Parent_2__c != null) {
                parent2ToContact.put(c.Rel_Parent_2__c, c);
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Relationship__c r : relList) {
            if (parent1ToContact.containsKey(r.Id)) {
                Contact relatedContact = parent1ToContact.get(r.Id);
                if (relatedContact.Rel_Parent_2__c == null) {
                    relatedContact.Rel_Parent_1__c = null;
                } else {
                    relatedContact.Rel_Parent_1__c = relatedContact.Rel_Parent_2__c;
                    relatedContact.Rel_Parent_2__c;
                    parent2ToContact.remove(relatedContact.Rel_Parent_2__c);
                }
                contactsToUpdate.add(c);
            }
        }
        update contactsToUpdate;
    }
}