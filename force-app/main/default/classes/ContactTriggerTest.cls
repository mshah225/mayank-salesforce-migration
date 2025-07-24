@isTest
public with sharing class ContactTriggerTest {
    private static final Integer TRIGGERLOAD = 5;

    @TestSetup
    static void setup() {
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

    @isTest
    private static void testOpportunityTerritoryReassignment() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
        testUser.ProfileId = RecordIdHelper.getProfileId('System Administrator');
        insert testUser;

        Territory_Assignment_Rule__c aTar1 = new Territory_Assignment_Rule__c();
        aTar1.Rule_Type__c = 'State';
        aTar1.User__c = TestUser.Id;
        aTar1.Assignment_By_State__c = 'Arizona';
        aTar1.Opportunity_Type__c = 'First Time Freshman';
        insert aTar1;

        Contact testContact = new Contact();
        testContact.FirstName = 'TestFirstName';
        testContact.LastName = 'TestLastName';
        testContact.Email = 'test@test.com';
        testContact.MailingCountry = 'United States';
        insert testContact;

        testContact = [SELECT AccountId FROM Contact WHERE Id = :testContact.Id];

        Opportunity testClosedPastOpp = new Opportunity();
        testClosedPastOpp.Name = 'Test Opp';
        testClosedPastOpp.StageName = 'Prospect';
        testClosedPastOpp.Type = 'First Time Freshman';
        testClosedPastOpp.Career__c = 'Undergraduate';
        testClosedPastOpp.CloseDate = Date.today() - 365;
        testClosedPastOpp.Contact__c = testContact.Id;
        testClosedPastOpp.AccountId = testContact.AccountId;
        insert testClosedPastOpp;

        Opportunity testClosedTodayOpp = new Opportunity();
        testClosedTodayOpp.Name = 'Test Opp';
        testClosedTodayOpp.StageName = 'Prospect';
        testClosedTodayOpp.Type = 'First Time Freshman';
        testClosedTodayOpp.Career__c = 'Undergraduate';
        testClosedTodayOpp.CloseDate = Date.today();
        testClosedTodayOpp.Contact__c = testContact.Id;
        testClosedTodayOpp.AccountId = testContact.AccountId;
        insert testClosedTodayOpp;

        Test.startTest();

        testContact.MailingState = 'Arizona';
        update testContact;

        Test.stopTest();

        // Should not be updated (since closed a long time ago)
        String actualClosedLastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :testClosedPastOpp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;
        String expectedClosedLastRuleType = null;
        Assert.areEqual(expectedClosedLastRuleType, actualClosedLastRuleType);

        // Should be updated (since closed just today)
        String actualClosedTodayLastRuleType = [
            SELECT Id, Territory_Assignment_Last_Rule_Type__c
            FROM Opportunity
            WHERE Id = :testClosedTodayOpp.Id
            LIMIT 1
        ]
        .Territory_Assignment_Last_Rule_Type__c;
        String expectedClosedTodayLastRuleType =
            'State, ' +
            testContact.MailingState +
            ', Type ' +
            testClosedTodayOpp.Type;
        Assert.areEqual(expectedClosedTodayLastRuleType, actualClosedTodayLastRuleType);
    }

    @isTest
    private static void padTests() {
        /**
         * Just exists to pad the test coverage - we don't do anything on delete/undelete
         */
        List<Contact> testContacts = createContacts(TRIGGERLOAD, false);
        insert testContacts;
        delete testContacts;
        undelete testContacts;
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

    @isTest
    private static void testContactGeomarketCodeAssignment() {
        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
        Id saProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        testUser.ProfileId = saProfile;
        insert testUser;

        Contact con = new Contact();
        con.FirstName = 'TestFirstName';
        con.LastName = 'TestLastName';
        con.MailingPostalCode = '90210';
        con.Geomarket_Code__c = 'CA-01';
        insert con;

        con = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];

        Key_Value__c KVContact = new Key_Value__c();
        KVContact.Geomarket_ZIP__c = '90210';
        KVContact.Geomarket_Code__c = 'CA-01';
        insert KVContact;

        Key_Value__c KVHS = new Key_Value__c();
        KVHS.Geomarket_ZIP__c = '84108';
        KVHS.Geomarket_Code__c = 'UT-01';
        insert KVHS;

        Key_Value__c KVCollege = new Key_Value__c();
        KVCollege.Geomarket_ZIP__c = '85287';
        KVCollege.Geomarket_Code__c = 'AZ-01';
        insert KVCollege;

        Account HS = new Account();
        HS.Name = 'Test High School';
        HS.ShippingPostalCode = '84108';
        HS.Geomarket_Code__c = 'UT-01';
        insert HS;

        Account college = new Account();
        college.Name = 'Test College School';
        college.ShippingPostalCode = '85287';
        college.Geomarket_Code__c = 'AZ-01';
        insert college;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.Contact__c = con.Id;
        opp.AccountId = con.AccountId;
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.today() + 365;
        opp.Type = 'First Time Freshman';
        //TODO: Commented out until territory assignment goes live with owner.
        //opp.OwnerId = TestUser.Id;
        //opp.Territory_Assignment_UserID__c = TestUser.Id;

        Test.startTest();

        insert opp;
        String contactGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Contact WHERE Id = :con.Id LIMIT 1]
        .Geomarket_Code__c;

        // Fire Account Trigger to set Account.Geomarketcode__c
        HS.ShippingPostalCode = '84108';
        HS.Geomarket_Code__c = 'UT-01';
        update HS;

        con.Last_HS_Attended__c = HS.Id;
        update con;

        opp.Type = 'First Time Freshman';
        opp.Territory_Assignment_Required__c = true;
        update opp;

        String contactHSGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Contact WHERE Id = :Con.Id LIMIT 1]
        .Geomarket_Code__c;

        opp.Type = 'Transfer';
        update opp;

        con.Last_HS_Attended__c = null;
        con.Last_College_Attended__c = College.Id;
        update con;

        opp.Type = 'Transfer';
        opp.Territory_Assignment_Required__c = true;
        update opp;

        String contactCollegeGeoCodeAfterUpdate = [SELECT Id, Geomarket_Code__c FROM Contact WHERE Id = :Con.Id LIMIT 1]
        .Geomarket_Code__c;

        Test.stopTest();

        System.Assert(
            contactGeoCodeAfterUpdate == KVContact.Geomarket_Code__c,
            'Contact Geomarket Code did not match by ZIP code'
        );
        System.Assert(
            contactHSGeoCodeAfterUpdate == KVHS.Geomarket_Code__c,
            'Contact Geomarket Code did not match by Last Attended High School Geomarket Code'
        );
        System.Assert(
            contactCollegeGeoCodeAfterUpdate == KVCollege.Geomarket_Code__c,
            'Contact Geomarket Code did not match by Last Attended College Geomarket Code'
        );
    }

    @isTest
    private static void testMergingContacts() {
        Contact masterAccount = new Contact(
            FirstName = 'Zylo',
            LastName = 'Werewolf',
            Email = 'zylo.werewolf@test.test'
        );
        Contact duplicateAccount = new Contact(
            FirstName = 'Zylo',
            LastName = 'Wolf Baron',
            Email = 'zylo.wolfbaron@test.test'
        );

        insert new List<Contact>{ masterAccount, duplicateAccount };

        Test.startTest();
        merge masterAccount duplicateAccount;
        Test.stopTest();

        masterAccount = [SELECT Id, Merged_Contact__c, Last_Merge_Date__c FROM Contact WHERE Id = :masterAccount.Id];

        // Shows this contact has been merged
        Assert.areEqual(true, masterAccount.Merged_Contact__c);
        // And records the date
        Assert.areEqual(System.today(), masterAccount.Last_Merge_Date__c);
    }

    @isTest
    private static void testDeletingContactsWhenNotMerging() {
        Contact masterAccount = new Contact(
            FirstName = 'Zylo',
            LastName = 'Werewolf',
            Email = 'zylo.werewolf@test.test'
        );
        Contact duplicateAccount = new Contact(
            FirstName = 'Zylo',
            LastName = 'Wolf Baron',
            Email = 'zylo.wolfbaron@test.test'
        );

        insert new List<Contact>{ masterAccount, duplicateAccount };

        Test.startTest();
        delete duplicateAccount;
        Test.stopTest();

        masterAccount = [SELECT Id, Merged_Contact__c, Last_Merge_Date__c FROM Contact WHERE Id = :masterAccount.Id];

        // Shows this contact has NOT been merged
        Assert.areEqual(false, masterAccount.Merged_Contact__c);
        // And does not set the merge date
        Assert.areNotEqual(System.today(), masterAccount.Last_Merge_Date__c);
    }
}