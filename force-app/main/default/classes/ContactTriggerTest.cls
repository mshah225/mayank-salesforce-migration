@isTest
public with sharing class ContactTriggerTest {
    static Id ExtMasteredContactRTId;
    static Id SFMasteredContactRTId;
    static Id ExtMasteredContactAccountRTId;
    static Id SFMasteredContactAccountRTId;
    static Integer TRIGGERLOAD = 5;

    @testSetup
    static void setup() {
        Account bucketAcct = new Account();
        bucketAcct.name = 'Arizona State University';
        insert bucketAcct;
    }

    static testMethod void testSFMasteredContactCreation() {
        getRecordTypeIDs();

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

        Map<Id, Contact> contactsByAccountId = new Map<Id, Contact>();
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();

        //Confirm that the contacts have the right record types
        for (Contact testContact : sfMasteredContacts) {
            System.assertEquals(SFMasteredContactRTId, testContact.RecordTypeId);
            sfMasteredIds.add(testContact.Id);
            contactsByAccountId.put(testContact.AccountId, testContact);
        }

        List<Account> sfMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :sfMasteredIds]
        );

        //Confirm that we have an equal number of contacts and accts
        System.assertEquals(sfMasteredContacts.size(), sfMasteredAccounts.size());

        //Confirm that each acct has the right record type
        for (Account testAccount : sfMasteredAccounts) {
            accountsByContactId.put(testAccount.Contact__c, testAccount);
            System.assertEquals(SFMasteredContactAccountRTId, testAccount.RecordTypeId);
        }

        //Confirm that each account has all the right data
        for (Contact c : sfMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assertEquals(c.Id, a.Contact__c);
            System.assertEquals(a.Id, c.AccountId);
            System.assertEquals(a.Name, c.FirstName + ' ' + c.LastName);
            System.assertEquals(a.OwnerId, c.OwnerId);
        }

        // This is not really necessary, but bumps up test coverage for the TriggerFactory class
        delete sfMasteredContacts;
    }

    static testMethod void testSFMasteredContactUpdate() {
        getRecordTypeIDs();

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

        Map<Id, Contact> contactsByAccountId = new Map<Id, Contact>();
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();

        //Confirm that the contacts have the right record types
        for (Contact testContact : sfMasteredContacts) {
            System.assertEquals(SFMasteredContactRTId, testContact.RecordTypeId);
            sfMasteredIds.add(testContact.Id);
            contactsByAccountId.put(testContact.AccountId, testContact);
        }

        List<Account> sfMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :sfMasteredIds]
        );

        //Confirm that we have an equal number of contacts and accts
        System.assertEquals(sfMasteredContacts.size(), sfMasteredAccounts.size());

        //Confirm that each acct has the right record type
        for (Account testAccount : sfMasteredAccounts) {
            accountsByContactId.put(testAccount.Contact__c, testAccount);
            System.assertEquals(SFMasteredContactAccountRTId, testAccount.RecordTypeId);
        }

        //Confirm that each account has all the right data
        for (Contact c : sfMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assertEquals(c.Id, a.Contact__c);
            System.assertEquals(a.Id, c.AccountId);
            System.assertEquals(a.Name, c.FirstName + ' ' + c.LastName);
            System.assertEquals(a.OwnerId, c.OwnerId);
        }
    }

    static testMethod void testExtMasteredContactCreation() {
        getRecordTypeIDs();

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

        Map<Id, Contact> contactsByAccountId = new Map<Id, Contact>();
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();

        //Confirm that the contacts have the right record types
        for (Contact testContact : extMasteredContacts) {
            System.assertEquals(ExtMasteredContactRTId, testContact.RecordTypeId);
            extMasteredIds.add(testContact.Id);
            contactsByAccountId.put(testContact.AccountId, testContact);
        }

        List<Account> extMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :extMasteredIds]
        );

        //Confirm that we have an equal number of contacts and accts
        System.assertEquals(extMasteredContacts.size(), extMasteredAccounts.size());

        //Confirm that each acct has the right record type
        for (Account testAccount : extMasteredAccounts) {
            accountsByContactId.put(testAccount.Contact__c, testAccount);
            System.assertEquals(ExtMasteredContactAccountRTId, testAccount.RecordTypeId);
        }

        //Confirm that each account has all the right data
        for (Contact c : extMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assertEquals(c.Id, a.Contact__c);
            System.assertEquals(a.Id, c.AccountId);
            System.assertEquals(a.Name, c.FirstName + ' ' + c.LastName);
            System.assertEquals(a.OwnerId, c.OwnerId);
        }

        // This is not really necessary, but bumps up test coverage for the TriggerFactory class
        delete extMasteredContacts;
    }

    static testMethod void testExtMasteredContactUpdate() {
        getRecordTypeIDs();

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

        Map<Id, Contact> contactsByAccountId = new Map<Id, Contact>();
        Map<Id, Account> accountsByContactId = new Map<Id, Account>();

        //Confirm that the contacts have the right record types
        for (Contact testContact : extMasteredContacts) {
            System.assertEquals(ExtMasteredContactRTId, testContact.RecordTypeId);
            extMasteredIds.add(testContact.Id);
            contactsByAccountId.put(testContact.AccountId, testContact);
        }

        List<Account> extMasteredAccounts = new List<Account>(
            [SELECT Id, Name, OwnerId, RecordTypeId, Contact__c FROM Account WHERE Contact__c IN :extMasteredIds]
        );

        //Confirm that we have an equal number of contacts and accts
        System.assertEquals(extMasteredContacts.size(), extMasteredAccounts.size());

        //Confirm that each acct has the right record type
        for (Account testAccount : extMasteredAccounts) {
            accountsByContactId.put(testAccount.Contact__c, testAccount);
            System.assertEquals(ExtMasteredContactAccountRTId, testAccount.RecordTypeId);
        }

        //Confirm that each account has all the right data
        for (Contact c : extMasteredContacts) {
            Account a = accountsByContactId.get(c.Id);
            System.assertEquals(c.Id, a.Contact__c);
            System.assertEquals(a.Id, c.AccountId);
            System.assertEquals(a.Name, c.FirstName + ' ' + c.LastName);
            System.assertEquals(a.OwnerId, c.OwnerId);
        }
    }

    static List<Contact> createContacts(Integer qty, boolean createEmplId) {
        List<Contact> testContacts = new List<Contact>();
        for (integer i = 0; i < qty; i++) {
            Contact c = new Contact(LastName = 'LName' + i, FirstName = 'FName' + i);
            if (createEmplId) {
                c.EMPLID__c = i.format();
            }
            testContacts.add(c);
        }

        return testContacts;
    }

    static void getRecordTypeIDs() {
        List<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, sObjectType, DeveloperName FROM RecordType WHERE sObjectType IN ('Account', 'Contact')]
        );
        for (RecordType rt : recordTypeList) {
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
            }
        }
    }
}
