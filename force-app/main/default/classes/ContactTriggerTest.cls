@isTest
public with sharing class ContactTriggerTest {
    private static final Integer TRIGGERLOAD = 5;

    @TestSetup
    static void setup() {
        Account bucketAcct = new Account();
        bucketAcct.name = 'Arizona State University';
        insert bucketAcct;
    }

    @isTest
    private static void testSFMasteredContactCreation() {
        // Set up the Contacts
        Set<Id> sfMasteredIds = new Set<Id>();
        List<Contact> sfMasteredContacts = createContacts(TRIGGERLOAD, false);

        Test.startTest();
        insert sfMasteredContacts;
        Test.stopTest();

        sfMasteredContacts = [
            SELECT Id, RecordTypeId, FirstName, LastName, OwnerId, AccountId
            FROM Contact
            LIMIT :TRIGGERLOAD
        ];

        //Confirm that the contacts have the right record types
        for (Contact testContact : sfMasteredContacts) {
            System.assertEquals(RecordIdHelper.getRecordTypeId('Contact', 'SF_Mastered'), testContact.RecordTypeId);
            sfMasteredIds.add(testContact.Id);
        }

        List<Account> sfMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :sfMasteredIds]
        );

        // Map each contact id to its account
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();
        for (Account testAccount : sfMasteredAccounts)
            accountsByContactId.put(testAccount.Contact__c, testAccount);

        // Confirm that we have an equal number of contacts and accts
        System.assertEquals(sfMasteredContacts.size(), sfMasteredAccounts.size());

        // Confirm that each account has all the right data
        for (Contact c : sfMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assert(checkSynced(c, a));
        }
    }

    @isTest
    private static void testSFMasteredContactUpdate() {
        // Set up the Contacts
        Set<Id> sfMasteredIds = new Set<Id>();
        List<Contact> sfMasteredContacts = createContacts(TRIGGERLOAD, false);
        insert sfMasteredContacts;

        for (Contact testContact : sfMasteredContacts) {
            testContact.FirstName = 'Updated';
        }

        Test.startTest();
        update sfMasteredContacts;
        Test.stopTest();

        sfMasteredContacts = [
            SELECT Id, RecordTypeId, FirstName, LastName, OwnerId, AccountId
            FROM Contact
            LIMIT :TRIGGERLOAD
        ];

        //Confirm that the contacts have the right record types
        for (Contact testContact : sfMasteredContacts) {
            System.assertEquals(RecordIdHelper.getRecordTypeId('Contact', 'SF_Mastered'), testContact.RecordTypeId);
            sfMasteredIds.add(testContact.Id);
        }

        List<Account> sfMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :sfMasteredIds]
        );

        // Map each contact id to its account
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();
        for (Account testAccount : sfMasteredAccounts)
            accountsByContactId.put(testAccount.Contact__c, testAccount);

        // Confirm that we have an equal number of contacts and accts
        System.assertEquals(sfMasteredContacts.size(), sfMasteredAccounts.size());

        // Confirm that each account has all the right data
        for (Contact c : sfMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assert(checkSynced(c, a));
        }
    }

    @isTest
    private static void testExtMasteredContactCreation() {
        // Set up the Contacts
        Set<Id> extMasteredIds = new Set<Id>();
        List<Contact> extMasteredContacts = createContacts(TRIGGERLOAD, true);

        Test.startTest();
        insert extMasteredContacts;
        Test.stopTest();

        extMasteredContacts = [
            SELECT Id, RecordTypeId, FirstName, LastName, OwnerId, AccountId
            FROM Contact
            LIMIT :TRIGGERLOAD
        ];

        //Confirm that the contacts have the right record types
        for (Contact testContact : extMasteredContacts) {
            System.assertEquals(
                RecordIdHelper.getRecordTypeId('Contact', 'External_Mastered'),
                testContact.RecordTypeId
            );
            extMasteredIds.add(testContact.Id);
        }

        List<Account> extMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :extMasteredIds]
        );

        // Map each contact id to its account
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();
        for (Account testAccount : extMasteredAccounts)
            accountsByContactId.put(testAccount.Contact__c, testAccount);

        // Confirm that we have an equal number of contacts and accts
        System.assertEquals(extMasteredContacts.size(), extMasteredAccounts.size());

        // Confirm that each account has all the right data
        for (Contact c : extMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assert(checkSynced(c, a));
        }
    }

    @isTest
    private static void testExtMasteredContactUpdate() {
        // Set up the Contacts
        Set<Id> extMasteredIds = new Set<Id>();
        List<Contact> extMasteredContacts = createContacts(TRIGGERLOAD, true);
        insert extMasteredContacts;

        for (Contact testContact : extMasteredContacts) {
            testContact.FirstName = 'Updated';
        }

        Test.startTest();
        update extMasteredContacts;
        Test.stopTest();

        extMasteredContacts = [
            SELECT Id, RecordTypeId, FirstName, LastName, OwnerId, AccountId
            FROM Contact
            LIMIT :TRIGGERLOAD
        ];

        //Confirm that the contacts have the right record types
        for (Contact testContact : extMasteredContacts) {
            System.assertEquals(
                RecordIdHelper.getRecordTypeId('Contact', 'External_Mastered'),
                testContact.RecordTypeId
            );
            extMasteredIds.add(testContact.Id);
        }

        List<Account> extMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :extMasteredIds]
        );

        // Map each contact id to its account
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();
        for (Account testAccount : extMasteredAccounts)
            accountsByContactId.put(testAccount.Contact__c, testAccount);

        // Confirm that we have an equal number of contacts and accts
        System.assertEquals(extMasteredContacts.size(), extMasteredAccounts.size());

        // Confirm that each account has all the right data
        for (Contact c : extMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assert(checkSynced(c, a));
        }
    }

    @isTest
    private static void testSettingSelfServicePin() {
        List<Contact> sfMasteredContacts = createContacts(TRIGGERLOAD, false);

        Test.startTest();
        insert sfMasteredContacts;
        Test.stopTest();

        sfMasteredContacts = [SELECT Id, Self_Service_PIN__c FROM Contact LIMIT :TRIGGERLOAD];

        for (Contact c : sfMasteredContacts) {
            System.assertNotEquals(null, c.Self_Service_PIN__c);
        }
    }

    @isTest
    private static void testSettingHashId() {
        List<Contact> sfMasteredContacts = createContacts(TRIGGERLOAD, false);

        Test.startTest();
        insert sfMasteredContacts;
        Test.stopTest();

        sfMasteredContacts = [SELECT Id, HashContactID__c FROM Contact LIMIT :TRIGGERLOAD];

        for (Contact c : sfMasteredContacts) {
            System.assertNotEquals(null, c.HashContactID__c);
        }
    }

    @isTest
    private static void testSyncUser() {
        Set<Id> sfMasteredIds = new Set<Id>();
        List<Contact> extMasteredContacts = createContacts(TRIGGERLOAD, true);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert extMasteredContacts;
        }
        extMasteredContacts = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT :TRIGGERLOAD];

        List<User> contactUsers = createUsers(extMasteredContacts);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert contactUsers;
        }

        for (Integer i = 0; i < extMasteredContacts.size(); i++) {
            Contact con = extMasteredContacts[i];
            con.FirstName = 'Changed-FName-' + i;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            update extMasteredContacts;
            Test.stopTest();
        }

        Set<Id> testUserIdSet = new Set<Id>();
        for (User u : contactUsers)
            testUserIdSet.add(u.Id);
        contactUsers = [
            SELECT Id, ContactId, FirstName, LastName
            FROM User
            WHERE Id IN :testUserIdSet
            LIMIT :TRIGGERLOAD
        ];

        // Map each contact id to its user
        Map<Id, User> usersByContactId = new Map<Id, User>();
        for (User testUser : contactUsers)
            usersByContactId.put(testUser.ContactId, testUser);

        // Confirm that we have an equal number of contacts and users
        System.assertEquals(extMasteredContacts.size(), contactUsers.size());

        // Confirm that each user has all the right data
        for (Contact c : extMasteredContacts) {
            User u = usersByContactId.get(c.Id);
            System.assert(checkSynced(c, u));
        }
    }

    @isTest
    private static void testDontSyncUser() {
        Set<Id> sfMasteredIds = new Set<Id>();
        List<Contact> extMasteredContacts = createContacts(TRIGGERLOAD, false);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert extMasteredContacts;
        }
        extMasteredContacts = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT :TRIGGERLOAD];

        List<User> contactUsers = createUsers(extMasteredContacts);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert contactUsers;
        }

        for (Integer i = 0; i < extMasteredContacts.size(); i++) {
            Contact con = extMasteredContacts[i];
            con.FirstName = 'Changed-FName-' + i;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            update extMasteredContacts;
            Test.stopTest();
        }

        Set<Id> testUserIdSet = new Set<Id>();
        for (User u : contactUsers)
            testUserIdSet.add(u.Id);
        contactUsers = [
            SELECT Id, ContactId, FirstName, LastName
            FROM User
            WHERE Id IN :testUserIdSet
            LIMIT :TRIGGERLOAD
        ];

        // Map each contact id to its user
        Map<Id, User> usersByContactId = new Map<Id, User>();
        for (User testUser : contactUsers) {
            System.debug(testUser);
            usersByContactId.put(testUser.ContactId, testUser);
        }

        // Confirm that we have an equal number of contacts and users
        System.assertEquals(extMasteredContacts.size(), contactUsers.size());

        // Confirm that each user has not been synced
        for (Contact c : extMasteredContacts) {
            User u = usersByContactId.get(c.Id);
            System.assert(!checkSynced(c, u));
        }
    }

    private static List<Contact> createContacts(Integer qty, boolean createEmplId) {
        List<Contact> testContacts = new List<Contact>();
        for (integer i = 0; i < qty; i++) {
            Contact c = new Contact(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Email = 'test.' + i + '.contact.trigger@test.test'
            );
            if (createEmplId) {
                c.EMPLID__c = i.format();
            }
            testContacts.add(c);
        }

        return testContacts;
    }

    private static List<User> createUsers(List<Contact> contacts) {
        List<User> userList = new List<User>();

        for (Integer i = 0; i < contacts.size(); i++) {
            Contact con = contacts[i];
            userList.add(
                new User(
                    FirstName = con.FirstName,
                    LastName = con.LastName,
                    Username = con.Email,
                    Email = con.Email,
                    Alias = 'testUsr' + i,
                    CommunityNickname = 'testUsr' + i,
                    TimeZoneSidKey = 'America/Phoenix',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'ISO-8859-1',
                    LanguageLocaleKey = 'en_US',
                    ProfileId = RecordIdHelper.getProfileId('ASU Community'),
                    ContactId = con.Id
                )
            );
        }

        return userList;
    }

    private static Boolean checkSynced(Contact c, Account a) {
        return c.Id == a.Contact__c &&
            a.Id == c.AccountId &&
            a.Name == c.FirstName + ' ' + c.LastName &&
            a.OwnerId == c.OwnerId &&
            ((c.RecordTypeId == RecordIdHelper.getRecordTypeId('Contact', 'SF_Mastered') &&
            RecordIdHelper.getRecordTypeId('Account', 'SF_Mastered_Contact') == a.RecordTypeId) ||
            (c.RecordTypeId == RecordIdHelper.getRecordTypeId('Contact', 'External_Mastered') &&
            RecordIdHelper.getRecordTypeId('Account', 'External_Mastered_Contact') == a.RecordTypeId) ||
            (c.RecordTypeId != RecordIdHelper.getRecordTypeId('Contact', 'SF_Mastered') &&
            c.RecordTypeId != RecordIdHelper.getRecordTypeId('Contact', 'External_Mastered')));
    }

    private static Boolean checkSynced(Contact c, User u) {
        return c.Id == u.ContactId && c.FirstName == u.FirstName && c.LastName == u.LastName;
    }
}
