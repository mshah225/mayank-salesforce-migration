public class ContactService {
    /**
     * Returns all the fields on Case in a String
     * @return A string containing all the Case fields
     */
    public static String contactFieldsToString() {
        String contactFields = null;

        Map<String, SObjectField> contactFieldMap = ObjectService.getObjectFieldMap('Contact');

        contactFields = ObjectService.objectFieldsToString(contactFieldMap);

        return contactFields;
    }

    /**
     * Creates a test contact. Usually for unit testing.
     * @return A test contact object with all required fields.
     */
    public static Contact createTestContact() {
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.MailingPostalCode = '85282';
        testContact.Email = 'test.user@test.example.com';
        testContact.Birthdate = Date.newInstance(1989, 8, 12);
        testContact.Self_Service_PIN__c = 57483638;
        testContact.PIN_lockout__c = true;
        testContact.ASURite_ID__c = 'testuser';

        return testContact;
    }

    /**
     * Creates a number of test contacts. Usually for unit testing.
     * @param The number of contacts to create
     * @return A list of the contacts with all required fields;
     */
    public static List<Contact> createTestContacts(Integer numOfContacts) {
        List<Contact> contactList = new List<Contact>();

        for (Integer i = 0; i < numOfContacts; i++) {
            Contact con = createTestContact();
            con.FirstName = 'Test' + i;
            con.LastName = 'Contact' + i;
            con.Email = 'test.user' + i + '@test.example.com';
            con.ASURite_ID__c = ObjectService.getGuid().substring(0, 10);
            Integer tempEmplId = 1200000000 + i;
            con.EMPLID__c = String.valueOf(tempEmplId);
            contactList.add(con);
        }

        return contactList;
    }

    /**
     * The currently logged in contact somewhere. Usually the service center.
     * @return The logged in contact
     */
    public static Contact getLoggedInContact() {
        Id loggedInContactId = null;
        Contact loggedInContact = null;
        String EmployeeId;
        List<Contact> lstLoggedInContact;
        String contactFields = contactFieldsToString() + ', Country_of_Citizenship__r.Name ';

        String selectContactInfoByLoggedInUser;
        try {
            //Try community user
            loggedInContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            //Try Employee User
            if (loggedInContactId == null) {
                EmployeeId = [SELECT EmployeeNumber FROM User WHERE Id = :userInfo.getUserId()].EmployeeNumber;
                if (EmployeeId != null && EmployeeId != '') {
                    lstLoggedInContact = [SELECT Id FROM Contact WHERE EmplId__c = :EmployeeId LIMIT 1];
                    if (lstLoggedInContact != null && lstLoggedInContact.size() > 0) {
                        loggedInContactId = lstLoggedInContact[0].Id;
                    }
                }
            }
            if (loggedInContactId != null) {
                selectContactInfoByLoggedInUser =
                    'SELECT ' +
                    contactFields +
                    ' ' +
                    'FROM Contact ' +
                    'WHERE Id = :loggedInContactId';

                loggedInContact = Database.query(selectContactInfoByLoggedInUser);
            }
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the logged in Contact\n' + e.getMessage()
            );
        }

        return loggedInContact;
    }

    public static Id getLoggedInContactId() {
        Id loggedInContactId = null;
        String employeeId = null;
        List<Contact> loggedInContactList;

        try {
            loggedInContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            if (loggedInContactId == null) {
                employeeId = [SELECT EmployeeNumber FROM User WHERE Id = :userInfo.getUserId()].EmployeeNumber;
                if (employeeId != null && employeeId != '') {
                    loggedInContactList = [SELECT Id FROM Contact WHERE EmplId__c = :employeeId LIMIT 1];
                    if (loggedInContactList != null && loggedInContactList.size() > 0) {
                        loggedInContactId = loggedInContactList[0].Id;
                    }
                }
            }
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the logged in Contact ID\n' + e.getMessage()
            );
        }

        return loggedInContactId;
    }

    /**
     * The contact to view as in the service center.
     * @param The asurite from the My ASU webservice you want to view as
     * @return The contact and all of its fields
     */
    public static Contact getContactToViewAs(String asurite) {
        //Id viewAsContactId = null;
        Contact viewAsContact = null;
        String contactFields = contactFieldsToString() + ', Country_of_Citizenship__r.Name ';
        System.debug(asurite);

        try {
            String selectContactInfoByAsurite =
                'SELECT ' +
                contactFields +
                ' ' +
                'FROM Contact ' +
                'WHERE ASURite_Id__c = :asurite';

            viewAsContact = Database.query(selectContactInfoByAsurite);
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact by ASURITE\n' + e.getMessage()
            );
        }

        return viewAsContact;
    }

    /**
     * Random pin generator. Generates a random pin for new contact creation.
     * @param dob The Contact's date of birth field
     * @return An autogenerated PIN
     */
    public static Decimal generateRandomPin(Date dateOfBirth) {
        Double rand = Math.random();
        String randString = String.valueOf(rand);
        randString = randString.subString(3, 9);
        Decimal randPin = Math.round(Decimal.valueOf(randString));

        while (!isPinValid(randPin, dateOfBirth)) {
            randPin = randPin + 1000;
        }

        return randPin;
    }

    /**
     * IVR Pin validator. Take a pin and the contact's date of birth and determines whether the pin is valid based on the rules described in SFE-573.
     * @param pinNum The PIN to be validated
     * @param dob The Contact's date of birth field
     * @return A boolean indicating the validitiy of a pin
     */
    public static Boolean isPinValid(Decimal pinNum, Date dob) {
        Decimal randPin = (Decimal) pinNum;

        //Pin length check
        if (randPin.precision() < 6 || randPin.precision() > 10) {
            return false;
        }

        //Repeating digit check
        Pattern pinDupliPattern = Pattern.compile('.*([0-9])\\1{4,}.*');
        Matcher dupliMatches = pinDupliPattern.matcher(randPin.toPlainString());
        if (dupliMatches.matches()) {
            return false;
        }

        //Sequential digit check
        Pattern consecNumbers = Pattern.compile(
            '.*(01234|12345|23456|34567|45678|56789|67890|09876|98765|87654|76543|65432|54321|43210).*'
        );
        Matcher consecMatches = consecNumbers.Matcher(randPin.toPlainString());
        if (consecMatches.matches()) {
            return false;
        }

        //Contains birthdate check
        if (dob != null) {
            Integer dobYear = dob.year();
            Pattern dobPattern = Pattern.compile('.*(' + dobYear + ').*');
            Matcher dobYearMatches = dobPattern.matcher(randPin.toPlainString());

            if (dobYearMatches.matches()) {
                return false;
            }
        }

        return true;
    }

    /**
     * Get all of the information pertaining to the provided contact Id or emplId
     * If emplId is provided and contactId is not, query on emplId. Else always query
     * on the provided contactId.
     * @param contactId A Contact ID
     * @param emplId the contacts EMPLID__c
     * @return contactInfo The corresponding Contact
     */
    public static Contact getContactInformation(String contactId, String emplId) {
        List<Contact> contactInformationList = new List<Contact>();
        Contact contactInfo = null;
        String contactFields = contactFieldsToString() + ', Country_of_Citizenship__r.Name ';
        String contactInfoQuery;

        // Get the list of cases associated with our set of contacts
        try {
            contactInfoQuery = '' + 'SELECT ' + contactFields + ' ' + 'FROM Contact ';
            if (!String.isBlank(emplId)) {
                contactInfoQuery += 'WHERE EMPLID__c = :emplId';
            } else {
                contactInfoQuery += 'WHERE Id = :contactId';
            }

            contactInformationList = Database.query(contactInfoQuery);

            if (!contactInformationList.isEmpty()) {
                return contactInformationList[0];
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact\'s information\n' + e.getMessage()
            );
        }

        return contactInfo;
    }

    /**
     * Get all of the information pertaining to the provided contact Id; overloaded for
     * backward comptibility
     * @param contactId A Contact ID
     * @return contactInfo The corresponding Contact
     */
    public static Contact getContactInformation(Id contactId) {
        return getContactInformation(contactId, '');
    }

    public class ContactServiceException extends Exception {
    }

    /** Everything above here is pre trigger refactor and we likely should work towards removing it */

    /**
     * Set the self service pin (Self_Service_PIN__c) on the contacts.
     *
     * @param contacts The list of contacts that need their Self_Service_PIN__c set
     */
    public static void setSelfServicePins(List<Contact> contacts) {
        for (Contact con : contacts) {
            con.Self_Service_PIN__c = generateRandomPin(con.Birthdate);
        }
    }

    /**
     * Set the record type on each contact depending on if it has EMPLID__c specified.
     *
     * @param contacts The list of contacts
     */
    public static void setRecordTypes(List<Contact> contacts) {
        Id extMasteredContactRecTypeId = RecordIdHelper.getRecordTypeId('Contact', 'External_Mastered');
        Id sfMasteredContactRecTypeId = RecordIdHelper.getRecordTypeId('Contact', 'SF_Mastered');

        for (Contact con : contacts)
            con.RecordTypeId = (con.EMPLID__c == null ? sfMasteredContactRecTypeId : extMasteredContactRecTypeId);
    }

    /**
     * For each contact, if the Contact is Externally_Mastered and its firstname/lastname changes, then update
     * the firstname/lastname of the Users that lookup to this Contact (User.Contact__c == Contact.Id).
     *
     * @param contacts The new list of contacts
     * @param oldContactsMap The map of old contacts
     */
    public static void syncUsers(List<Contact> contacts, Map<Id, Contact> oldContactsMap) {
        Id extMasteredContactRecTypeId = RecordIdHelper.getRecordTypeId('Contact', 'External_Mastered');
        Set<Id> contactIdsToUpdateRelatedUsers = new Set<Id>();
        Map<Id, User> contactIdToUserMap = new Map<Id, User>();

        // Get a set of contact ids to search user
        for (Contact newCon : contacts) {
            Contact oldCon = oldContactsMap.get(newCon.Id);
            if (
                newCon.RecordTypeId == extMasteredContactRecTypeId &&
                (newCon.FirstName != oldCon.FirstName ||
                newCon.LastName != oldCon.LastName)
            )
                contactIdsToUpdateRelatedUsers.add(newCon.Id);
        }

        // Map each contact id to its associated user
        List<User> usersToUpdate = [
            SELECT ContactId, FirstName, LastName
            FROM User
            WHERE ContactId IN :contactIdsToUpdateRelatedUsers
        ];
        for (User u : usersToUpdate)
            contactIdToUserMap.put(u.ContactId, u);

        // Update the name on the user
        for (Contact con : contacts) {
            // Update each user's first and last name to match
            if (contactIdToUserMap.containsKey(con.Id)) {
                User associatedUser = contactIdToUserMap.get(con.Id);

                associatedUser.FirstName = con.FirstName;
                associatedUser.LastName = con.LastName;
            }
        }

        // Update the users
        if (!usersToUpdate.isEmpty())
            update usersToUpdate;
    }

    /**
     * The first half of the account sync process.  Handles setting the Bizcard_Account__c lookup when needed
     * and creating a new account if needed.  Should be run in the before trigger since it'll set the AccountId
     * lookup on the Contact
     *
     * @param contacts The new list of contacts
     */
    public static void beforeTriggerSyncAccounts(List<Contact> contacts) {
        Map<Contact, Account> contactToNewAccountMap = new Map<Contact, Account>(); // Map of new accounts

        // Get the Id for the old bucket Account to check against
        Id bucketAccountId = null;
        List<Account> bucketAccountList = [SELECT Id FROM Account WHERE Name = 'Arizona State University' LIMIT 1];
        if (!bucketAccountList.isEmpty())
            bucketAccountId = bucketAccountList[0].Id;

        /** Preparation complete - now let's do the sync */

        for (Contact con : contacts) {
            // Make a new account if needed
            if (con.AccountId == null || con.AccountId == bucketAccountId)
                contactToNewAccountMap.put(con, createAccount(con)); // Create an Account for the Contact
        }

        // Insert new contacts
        if (!contactToNewAccountMap.isEmpty())
            insert contactToNewAccountMap.values();

        // Set Account lookup on Contact for all newly created Accounts
        for (Contact con : contacts)
            if (contactToNewAccountMap.containsKey(con))
                con.AccountId = contactToNewAccountMap.get(con).Id;
    }

    /**
     * The second half of the account sync process.  Handles setting the Bizcard_Account__c lookup when needed
     * and creating a new account if needed. Should be run in the after trigger since the Contacts need to have
     * their Ids set so that we can update the Accounts' Contact__c lookups
     *
     * @param contacts The new list of contacts
     */
    public static void afterTriggerSyncAccounts(List<Contact> contacts) {
        // Ids for all the Contact's accounts.  At this point AccountId  must lookup to the 1-to-1 contact's account
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Id> contactIdToAccountIdMap = new Map<Id, Id>();
        for (Contact con : contacts) {
            accountIds.add(con.AccountId);
            contactIdToAccountIdMap.put(con.Id, con.AccountId);
        }

        // Get all the accounts for these contacts
        List<Account> accountList = [
            SELECT Id, Name, OwnerId, RecordTypeId, Contact__c
            FROM Account
            WHERE Id IN :accountIds
        ];

        // Map contact id to its associated account
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (Account acc : accountList)
            accountMap.put(acc.Id, acc);

        // And now modify each account if it has fallen out of sync
        List<Account> accountsToUpdate = new List<Account>();
        for (Contact con : contacts) {
            // If this contact has an account
            if (contactIdToAccountIdMap.containsKey(con.Id)) {
                Id accountId = contactIdToAccountIdMap.get(con.Id);
                // and we got the Account's details
                if (accountMap.containsKey(accountId)) {
                    Account acc = accountMap.get(accountId);
                    // Check if the Account disagrees with the Contact - if so bring Account into alignment
                    if (
                        acc != null &&
                        (acc.Name != con.FirstName + ' ' + con.LastName ||
                        acc.OwnerId != con.OwnerId ||
                        acc.RecordTypeId != getAccountRecordTypeForContactRecordType(con.RecordTypeID) ||
                        acc.Contact__c != con.Id)
                    ) {
                        acc.Name = con.FirstName + ' ' + con.LastName;
                        acc.OwnerId = con.OwnerId;
                        acc.RecordTypeId = getAccountRecordTypeForContactRecordType(con.RecordTypeID);
                        acc.Contact__c = con.Id;

                        accountsToUpdate.add(acc);
                    }
                }
            }
        }

        if (!accountsToUpdate.isEmpty())
            update accountsToUpdate;
    }

    /**
     * Set the HashContactID__c on each of the contacts. Does this asynchronously if not running in the future or as a batch
     *
     * @param contacts List of Contacts that need their hash contact id set
     */
    public static void setHashIds(List<Contact> contacts) {
        List<Id> contactIdList = new List<Id>();
        for (Contact con : contacts)
            contactIdList.add(con.Id);
        // Set it in the future
        if (System.isFuture() || System.isBatch())
            setHashIdsNow(contactIdList);
        else
            setHashIdsFuture(contactIdList);
    }

    @future
    private static void setHashIdsFuture(List<Id> contactIds) {
        setHashIdsNow(contactIds);
    }

    private static void setHashIdsNow(List<Id> contactIds) {
        List<Contact> contactsWithNewHashes = new List<Contact>();
        for (Id contactId : contactIds) {
            String hashId = Hasher.hashId(contactId);
            Contact con = new Contact(Id = contactId, HashContactID__c = hashId);
            contactsWithNewHashes.add(con);
        }
        update contactsWithNewHashes;
    }

    /**
     * Make a new Account for the specified Contact
     *
     * @param c The contact
     *
     * @return The new account
     */
    private static Account createAccount(Contact c) {
        // Create the new 1:1 Account record for this Contact
        Account a = new Account(
            Name = c.FirstName + ' ' + c.LastName,
            RecordTypeId = getAccountRecordTypeForContactRecordType(c.RecordTypeID),
            OwnerId = c.OwnerId
        );

        return a;
    }

    /**
     * Get the account record type id for the specified contact record type id
     *
     * @param contactRecordTypeId The contact record type id
     *
     * @return The account record type id
     */
    private static Id getAccountRecordTypeForContactRecordType(Id contactRecordTypeId) {
        Id extMasteredContactRecTypeId = RecordIdHelper.getRecordTypeId('Contact', 'External_Mastered');
        Id sfMasteredContactRecTypeId = RecordIdHelper.getRecordTypeId('Contact', 'SF_Mastered');
        Id extMasteredContactAccountRecTypeId = RecordIdHelper.getRecordTypeId('Account', 'External_Mastered_Contact');
        Id sfMasteredContactAccountRecTypeId = RecordIdHelper.getRecordTypeId('Account', 'SF_Mastered_Contact');

        Map<Id, Id> contactToAccountRTIdMap = new Map<Id, Id>();
        contactToAccountRTIdMap.put(extMasteredContactRecTypeId, extMasteredContactAccountRecTypeId);
        contactToAccountRTIdMap.put(sfMasteredContactRecTypeId, sfMasteredContactAccountRecTypeId);

        return contactToAccountRTIdMap.get(contactRecordTypeId);
    }
}