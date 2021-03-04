// TODO : Exception handling on all DML statements : SP
public without sharing class ContactHandler implements ITrigger {
    private Map<Id, Account> existingAccountMap = new Map<Id, Account>();
    private List<Account> accountList;
    private Set<Id> accountIdsToUpdate = new Set<Id>();
    private static Id ExtMasteredContactRTId;
    private static Id SFMasteredContactRTId;
    private static Id ExtMasteredContactAccountRTId;
    private static Id SFMasteredContactAccountRTId;
    private static Id relationshipContactToAccountRTID;
    private static Id bucketAccountId;
    private Map<Id, Id> contactToAccountRTIdMap = new Map<Id, Id>();
    private Map<Id, Id> accountIdsByContactId = new Map<Id, Id>();
    private static Map<Contact, Account> newContactToNewAccountMap;
    private Map<Id, User> contactIdToUserMap = new Map<Id, User>();
    private List<Account> accountsToUpdate = new List<Account>();
    private List<User> usersToUpdate = new List<User>();
    private List<Contact> contactsToCheckIfUpdate = new List<Contact>();
    private List<Relationship__c> bizcardRelationships = new List<Relationship__c>();
    private Map<String, List<CampaignMember>> bizcardCampaignMembers = new Map<String, List<CampaignMember>>();

    public void bulkBefore() {
        // Create a map of Contact to Account
        newContactToNewAccountMap = new Map<Contact, Account>();

        if (Trigger.IsInsert || Trigger.IsUpdate) {
            // If any of the necessary Record Type IDs are null...
            if (
                ExtMasteredContactRTId == null ||
                SFMasteredContactRTId == null ||
                ExtMasteredContactAccountRTId == null ||
                SFMasteredContactAccountRTId == null
            ) {
                // ...get the necessary RecordType IDs
                List<RecordType> recordTypeList = new List<RecordType>(
                    [
                        SELECT Id, sObjectType, DeveloperName
                        FROM RecordType
                        WHERE sObjectType IN ('Account', 'Contact', 'Relationship__c')
                    ]
                );

                // For each Record Type in our list...
                for (RecordType rt : recordTypeList) {
                    // Determine whether the Record Type is Contact, Account, or Relationship,
                    // and store its ID based to its Developer Name
                    if (rt.SobjectType == 'Contact') {
                        if (rt.DeveloperName == 'External_Mastered') {
                            ExtMasteredContactRTId = rt.Id;
                        } else if (rt.DeveloperName == 'SF_Mastered') {
                            SFMasteredContactRTId = rt.Id;
                        }
                    } else if (rt.SobjectType == 'Account') {
                        if (rt.DeveloperName == 'External_Mastered_Contact') {
                            ExtMasteredContactAccountRTId = rt.Id;
                        } else if (rt.DeveloperName == 'SF_Mastered_Contact') {
                            SFMasteredContactAccountRTId = rt.Id;
                        }
                    } else if (rt.SobjectType == 'Relationship__c') {
                        if (rt.DeveloperName == 'Contact_to_Account') {
                            relationshipContactToAccountRTID = rt.Id;
                        }
                    }
                }
            }

            // Populate a Map that we use to translate from Contact Record Type ID to Account
            // Record Type ID
            contactToAccountRTIdMap.put(ExtMasteredContactRTId, ExtMasteredContactAccountRTId);
            contactToAccountRTIdMap.put(SFMasteredContactRTId, SFMasteredContactAccountRTId);

            // Get the Id for the old bucket Account to check
            if (bucketAccountId == null) {
                List<Account> bucketAccountList = new List<Account>(
                    [SELECT Id FROM Account WHERE Name = 'Arizona State University']
                );

                if (bucketAccountList.size() > 0) {
                    bucketAccountId = bucketAccountList[0].Id;
                }
            }

            // For each sObject triggering on Before Insert or Before Update
            for (SObject so : Trigger.new) {
                // Store the triggering sObject as a Contact
                Contact c = (Contact) so;

                if (c.EMPLID__c == null && c.RecordTypeId != SFMasteredContactRTId) {
                    c.RecordTypeId = SFMasteredContactRTId;
                } else if (c.EMPLID__c != null && c.RecordTypeId != ExtMasteredContactRTId) {
                    c.RecordTypeId = ExtMasteredContactRTId;
                }

                // If we are inserting a new Contact...
                if (Trigger.IsInsert) {
                    System.debug('Trigger fired...');
                    // If the Contact was created using the VisionE/Scan application...
                    if (c.eContacts__Created_By_eContacts__c) {
                        System.debug('Account ID: ' + c.AccountId);
                        // Store the Contact's Account lookup as the Business Card Account
                        c.Bizcard_Account__c = c.AccountId;
                        c.AccountId = null;

                        // Populate the Corporate Relations Account Owner
                        Id userId = UserInfo.getUserId();
                        List<User> userList = [SELECT Id, Name FROM User WHERE Id = :userId];
                        System.debug('USER LIST: ' + userList);
                        System.debug('CRCO: ' + c.Corporate_Relations_Contact_Owner__c);
                        c.Corporate_Relations_Contact_Owner__c = userList[0].Id;
                    } else {
                        // Otherwise, create an Account from the Contact and store it in our map
                        // of new Contacts to new Accounts
                        Account a = createAccount(c);
                        newContactToNewAccountMap.put(c, a);
                    }

                    // If we are updating an existing Contact which wasn't created by the VisionE/Scan
                    // application...
                } else if (Trigger.IsUpdate) {
                    // If the Account ID is null, or if its the same as the ASU Account ID
                    if (c.AccountId == null || c.AccountId == bucketAccountId) {
                        // Create a new Account from the Contact, and store it in our map of new
                        // Contacts to new Accounts
                        Account a = createAccount(c);
                        newContactToNewAccountMap.put(c, a);
                    } else {
                        // Otherwise, add the Contact to our list of Contacts to check on Update
                        contactsToCheckIfUpdate.add(c);
                    }
                }
            }

            // If there were any new Accounts created...
            if (newContactToNewAccountMap.size() > 0) {
                // Insert the new Accounts
                insert newContactToNewAccountMap.values();

                // For each triggering sObject...
                for (SObject so : Trigger.New) {
                    // Store the triggering Contact
                    Contact c = (Contact) so;

                    // If the Account for this Contact exists in our map of new Contacts to new
                    // Accounts...
                    if (newContactToNewAccountMap.get(c) != null) {
                        // Store the account and set it on the Contact
                        Account a = newContactToNewAccountMap.get(c);
                        c.AccountId = a.Id;
                    }
                }
            }

            // If there are any Contacts to check on Update...
            if (contactsToCheckIfUpdate.size() > 0) {
                // Create a set of IDs for existing accounts
                Set<Id> existingAccountIds = new Set<Id>();

                // Add the Account ID of each Contact being updated to our set of existing Account
                // IDs
                for (Contact c : contactsToCheckIfUpdate) {
                    existingAccountIds.add(c.AccountId);
                }

                // Populate a map of all of the existing Accounts for the Contacts being updated
                existingAccountMap = new Map<Id, Account>(
                    [SELECT Id, Name, Contact__c, OwnerId, RecordType.Name FROM Account WHERE Id IN :existingAccountIds]
                );
            }
        }

        // Get map of <Id,User> to update users' first/last names
        if (Trigger.IsUpdate) {
            List<Id> contactIdsToUpdateRelatedUsers = new List<Id>();

            for (SObject updatedObject : Trigger.new) {
                Contact updatedContact = (Contact) updatedObject;
                if (
                    updatedContact.RecordTypeId == ExtMasteredContactRTId && // Only External Mastered Type contacts
                    (updatedContact.FirstName != ((Contact) Trigger.oldMap.get(updatedContact.Id)).FirstName || // With name changes
                    updatedContact.LastName != ((Contact) Trigger.oldMap.get(updatedContact.Id)).LastName)
                ) {
                    contactIdsToUpdateRelatedUsers.add(updatedContact.Id);
                }
            }

            usersToUpdate = [
                SELECT ContactId, FirstName, LastName
                FROM User
                WHERE ContactId IN :contactIdsToUpdateRelatedUsers
            ];

            // store in map so we can update later as we update each contact
            for (User userToSearchForLater : usersToUpdate) {
                contactIdToUserMap.put(userToSearchForLater.ContactId, userToSearchForLater);
            }
        }
    }

    public void beforeInsert(SObject so) {
        Contact c = (Contact) so;
        //Automatically generate a PIN for a new contact
        c.Self_Service_PIN__c = ContactService.generateRandomPin(c.Birthdate);
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        // Store the triggering sObject as a Contact
        Contact alteredContact = (Contact) so;

        // Store the Account ID of the triggering Contact
        Account associatedAccount = existingAccountMap.get(alteredContact.AccountId);

        // If an Account exists for the triggering contact, and its information doesn't match up
        // with the Contact, add it to our set of Accounts to update
        if (
            associatedAccount != null &&
            (associatedAccount.Name != alteredContact.FirstName + ' ' + alteredContact.LastName ||
            associatedAccount.OwnerId != alteredContact.OwnerId ||
            associatedAccount.RecordTypeId != contactToAccountRTIdMap.get(alteredContact.RecordTypeID) ||
            associatedAccount.Contact__c != alteredContact.Id)
        ) {
            associatedAccount.Name = alteredContact.FirstName + ' ' + alteredContact.LastName;
            associatedAccount.OwnerId = alteredContact.OwnerId;
            associatedAccount.RecordTypeId = contactToAccountRTIdMap.get(alteredContact.RecordTypeID);
            associatedAccount.Contact__c = alteredContact.Id;

            accountsToUpdate.add(associatedAccount);
        }

        // Get the user we will be updating
        User associatedUser = contactIdToUserMap.get(alteredContact.Id);

        // Update the user's first and last name to match
        if (associatedUser != null) {
            associatedUser.FirstName = alteredContact.FirstName;
            associatedUser.LastName = alteredContact.LastName;
        }
    }

    public void beforeDelete(SObject so) {
    }

    public void beforeFinally() {
        // If there are any Accounts to update, update them.
        if (accountsToUpdate.size() > 0) {
            update accountsToUpdate;
        }
    }

    public void bulkAfter() {
        // On After Insert...
        if (Trigger.IsInsert) {
            // Create a list to store our Business Card Contact IDs
            List<Id> bizcardContactIds = new List<Id>();
            List<Id> conIDList = new List<Id>();
            // For each triggering sObject...
            for (SObject so : Trigger.New) {
                // Store the sObject as a Contact
                Contact c = (Contact) so;
                conIdList.add(c.Id);
                // If there are any new Contact/Account pairs
                if (newContactToNewAccountMap.get(c) != null) {
                    // Store the Account associated with the Contact
                    Account a = newContactToNewAccountMap.get(c);

                    // Set the Contact lookup field on the Account to the ID of the triggering
                    // Contact
                    a.Contact__c = c.Id;
                }

                // If the triggering contact was created by the VisionE/Scan application, add the
                // Contact's ID to our list of Business Card Contact IDs.
                if (c.eContacts__Created_By_eContacts__c) {
                    System.debug('Contact ID added to list...');
                    bizcardContactIds.add(c.Id);
                    System.debug('Contact IDs: ' + bizcardContactIds);
                }
            }
            if (conIdList.size() > 0) {
                setHashId(conIdList);
            }
            // If any Contacts were created by the VisionE/Scan application...
            if (bizcardContactIds.size() > 0) {
                // Populate a list of all the Contacts created by the VisionE/Scan application
                List<Contact> contacts = [
                    SELECT Id, Bizcard_Account__c, Title, CreatedBy.UserRole.Name
                    FROM Contact
                    WHERE Id IN :bizcardContactIds
                ];

                // For each Contact that was created by the VisionE/Scan application...
                for (Contact c : contacts) {
                    System.debug('Contact ' + c);

                    // Create a Relationship between the Contact and its Account, and add it to our
                    // list of Business Card Relationships.
                    if (c.Bizcard_Account__c != null) {
                        bizcardRelationships.add(
                            RelationshipService.createContactAccountRelationship(
                                c.Id,
                                c.Bizcard_Account__c,
                                relationshipContactToAccountRTID,
                                c.Title
                            )
                        );
                    }

                    System.debug('Business Card Relationships: ' + bizcardRelationships);

                    // Create a Campaign Member object and assign it the ID of the Contact
                    CampaignMember cm = new CampaignMember(ContactId = c.Id);

                    System.debug('CREATED BY: ' + c.CreatedBy);

                    // If the map of Business Card Campaign Members is empty, add the Name of the User
                    // who created the Contact to the map, and map it to an empty list of Campaign Members.
                    if (bizcardCampaignMembers.get(c.CreatedBy.UserRole.Name) == null) {
                        bizcardCampaignMembers.put(c.CreatedBy.UserRole.Name, new List<CampaignMember>());
                    }

                    // Add the existing Campaign Member to the empty list we just created in the
                    // Business Card Campaign Members map
                    bizcardCampaignMembers.get(c.CreatedBy.UserRole.Name).add(cm);
                }
            }
        }

        // If there are any new Contact/Account pairs, update them.
        if (newContactToNewAccountMap.size() > 0) {
            update newContactToNewAccountMap.values();
        }

        // If any Relationship objects were created linking a Contact to an Account (because a
        // Contact was created by the VisionE/Scan application), insert those Relationships.
        if (bizcardRelationships.size() > 0) {
            insert bizcardRelationships;
        }

        // If there are any Business Card Campaign Members...
        if (bizcardCampaignMembers.size() > 0) {
            System.debug('Bizcard Campaign Members: ' + bizcardCampaignMembers);

            // Create a set of roles from the map
            Set<String> roleNames = bizcardCampaignMembers.keySet();

            // Create a list of Campaign Members to insert
            List<CampaignMember> cmsToInsert = new List<CampaignMember>();

            // Create a list of Business Card Campaign Links whose roles match those in the map of
            // Business Card Campaign Members
            List<Bizcard_Campaign_Link__c> campaignLinks = [
                SELECT Id, Role__c, Campaign__c
                FROM Bizcard_Campaign_Link__c
                WHERE Role__c IN :roleNames
            ];

            // For each Business Card Campaign Link...
            for (Bizcard_Campaign_Link__c bcl : campaignLinks) {
                // ...iterate through the Business Card Campaign Members associated with it, and
                // set the CampaignID of the Campaign Member to the Campaign ID of the Campaign
                // Link, and then add it to the list of Campaign Members to Insert
                for (CampaignMember cm : bizcardCampaignMembers.get(bcl.Role__c)) {
                    cm.CampaignId = bcl.Campaign__c;
                    cmsToInsert.add(cm);
                }
            }

            // If there are any Campaign Members to insert, insert them.
            if (cmsToInsert.size() > 0) {
                insert cmsToInsert;
            }
        }
    }

    public void afterInsert(SObject so) {
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        /*
        // If the Email Opt-out value has changed, call Marketing Cloud to reflect the change
        Contact newCon = (Contact)so;
        Contact oldCon = (Contact)oldSo;
        if (newCon.HasOptedOutOfEmail && !oldCon.HasOptedOutOfEmail)
            SetMarketingCloudSubStatus(newCon.Id, false);
        else if (!newCon.HasOptedOutOfEmail && oldCon.HasOptedOutOfEmail)
            SetMarketingCloudSubStatus(newCon.Id, true);
        */
    }

    public void afterDelete(SObject so) {
    }

    public void andFinally() {
        if (Trigger.IsUpdate) {
            if (usersToUpdate != null && usersToUpdate.size() > 0) {
                update usersToUpdate;
            }
        }
    }

    private Account createAccount(Contact c) {
        // Create the new 1:1 Account record for this Contact
        Account a = new Account(
            Name = c.FirstName + ' ' + c.LastName,
            RecordTypeId = contactToAccountRTIdMap.get(c.RecordTypeID),
            OwnerId = c.OwnerId
        );

        return a;
    }

    @future(callout=true)
    static void SetMarketingCloudSubStatus(String subscriberKey, Boolean subStatus) {
        if (!subStatus) {
            et4ae5.jsButtonMethods.performUnsub(subscriberKey, 'contact');
        } else {
            et4ae5.jsButtonMethods.performResub(subscriberKey, 'contact');
        }
    }

    private static void setHashId(List<Id> contactIdList) {
        if (System.isFuture() || System.isBatch()) {
            setHashIdNow(contactIdList);
        } else {
            setHashIdFuture(contactIdList);
        }
    }

    @future
    private static void setHashIdFuture(List<Id> contactIdList) {
        setHashIdNow(contactIdList);
    }

    private static void setHashIdNow(List<Id> contactIdList) {
        List<Contact> conList = new List<Contact>();
        for (Id i : contactIdList) {
            Contact c = new Contact(Id = i, HashContactID__c = Hasher.hashId(i));
            conList.add(c);
        }
        update conList;
    }
}
