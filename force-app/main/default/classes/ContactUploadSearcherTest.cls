@isTest
public with sharing class ContactUploadSearcherTest {
    @TestSetup
    static void setup() {
        Contact con = new Contact(
            FirstName = 'TestContact',
            LastName = 'ContactUploadSearcherTestContact',
            Email = 'TestContact.ContactUploadSearcherTestContact@test.test',
            ASURite_ID__c = 'TEST',
            EMPLID__c = '123456'
        );
        insert con;
    }

    @isTest
    private static void testFirstNameAndEmailMatch() {
        Contact emailContact = [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 1];
        Contact_Upload_Detail__c emailCUD = new Contact_Upload_Detail__c(
            First_Name__c = emailContact.FirstName,
            Email__c = emailContact.Email
        );

        Contact leadEmailContact = new Contact(
            FirstName = 'TestLeadEmailContact',
            LastName = 'ContactUploadSearcherTestLeadEmailContact',
            Lead_Email__c = 'TestLeadEmailContact.TestLeadEmailContact@test.test'
        );
        Contact secondaryLeadEmailContact = new Contact(
            FirstName = 'TestSecondaryLeadEmailContact',
            LastName = 'ContactUploadSearcherTestSecondaryLeadEmailContact',
            Lead_Secondary_Email__c = 'TestSecondaryLeadEmailContact.TestSecondaryLeadEmailContact@test.test'
        );
        Contact personalEmailContact = new Contact(
            FirstName = 'TestPersonalEmailContact',
            LastName = 'ContactUploadSearcherTestPersonalEmailContact',
            Personal_Email__c = 'TestPersonalEmailContact.TestPersonalEmailContact@test.test'
        );
        Contact asuGmailContact = new Contact(
            FirstName = 'TestASUGmailContact',
            LastName = 'ContactUploadSearcherTestASUGmailContact',
            ASU_Gmail__c = 'TestASUGmailContact.TestASUGmailContact@test.test'
        );
        Contact epoEmailContact = new Contact(
            FirstName = 'TestEPOEmailContact',
            LastName = 'ContactUploadSearcherTestEPOEmailContact',
            EPO_Email__c = 'TestEPOEmailContact.TestEPOEmailContact@test.test'
        );
        Contact asuEmailContact = new Contact(
            FirstName = 'TestASUEmailContact',
            LastName = 'ContactUploadSearcherTestASUEmailContact',
            ASU_Email__c = 'TestASUEmailContact.TestASUEmailContact@test.test'
        );
        List<Contact> allContacts = new List<Contact>{
            leadEmailContact,
            secondaryLeadEmailContact,
            personalEmailContact,
            asuGmailContact,
            epoEmailContact,
            asuEmailContact
        };
        insert allContacts;
        allContacts.add(emailContact);
        leadEmailContact.Email = 'newToSetToAvoidAutoSet@test.test';
        update leadEmailContact; // Must update to make Email != Lead_Email__c

        Contact_Upload_Detail__c leadEmailCUD = new Contact_Upload_Detail__c(
            First_Name__c = leadEmailContact.FirstName,
            Email__c = leadEmailContact.Lead_Email__c
        );
        Contact_Upload_Detail__c secondaryLeadEmailCUD = new Contact_Upload_Detail__c(
            First_Name__c = secondaryLeadEmailContact.FirstName,
            Email__c = secondaryLeadEmailContact.Lead_Secondary_Email__c
        );
        Contact_Upload_Detail__c personalEmailCUD = new Contact_Upload_Detail__c(
            First_Name__c = personalEmailContact.FirstName,
            Email__c = personalEmailContact.Personal_Email__c
        );
        Contact_Upload_Detail__c asuGmailCUD = new Contact_Upload_Detail__c(
            First_Name__c = asuGmailContact.FirstName,
            Email__c = asuGmailContact.ASU_Gmail__c
        );
        Contact_Upload_Detail__c epoEmailCUD = new Contact_Upload_Detail__c(
            First_Name__c = epoEmailContact.FirstName,
            Email__c = epoEmailContact.EPO_Email__c
        );
        Contact_Upload_Detail__c asuEmailCUD = new Contact_Upload_Detail__c(
            First_Name__c = asuEmailContact.FirstName,
            Email__c = asuEmailContact.ASU_Email__c
        );

        Test.startTest();
        ContactUploadSearcher searcher = new ContactUploadSearcher(
            new List<Contact_Upload_Detail__c>{
                emailCUD,
                leadEmailCUD,
                secondaryLeadEmailCUD,
                personalEmailCUD,
                asuGmailCUD,
                epoEmailCUD,
                asuEmailCUD
            }
        );
        searcher.searchContactsToMatch();
        Test.stopTest();

        System.assertEquals(7, searcher.matchedContacts.size());
        for (Contact c : searcher.matchedContacts) {
            Boolean matchesOneOfInserted = false;
            for (Contact compareTo : allContacts) {
                if (compareTo.LastName == c.LastName) {
                    matchesOneOfInserted = true;
                    allContacts.remove(allContacts.indexOf(compareTo)); // we should have 1-to-1 match - no duplicates
                    break;
                }
            }
            System.assert(matchesOneOfInserted, 'Could not find matching contact');
        }
    }

    @isTest
    private static void testASURITEMatch() {
        Contact c = [SELECT Id, ASURite_ID__c, LastName FROM Contact LIMIT 1];
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(ASURite__c = c.ASURite_ID__c);

        Test.startTest();
        ContactUploadSearcher searcher = new ContactUploadSearcher(new List<Contact_Upload_Detail__c>{ cud });
        searcher.searchContactsToMatch();
        Test.stopTest();

        System.assertEquals(c.LastName, searcher.matchedContacts[0].LastName);
    }

    @isTest
    private static void testEMPLIDMatch() {
        Contact c = [SELECT Id, EMPLID__c, LastName FROM Contact LIMIT 1];
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(EMPLID__c = c.EMPLID__c);

        Test.startTest();
        ContactUploadSearcher searcher = new ContactUploadSearcher(new List<Contact_Upload_Detail__c>{ cud });
        searcher.searchContactsToMatch();
        Test.stopTest();

        System.assertEquals(c.LastName, searcher.matchedContacts[0].LastName);
    }

    @isTest
    private static void testSubscriptionBasedQuery() {
        Contact c = [SELECT Id, EMPLID__c, LastName FROM Contact LIMIT 1];

        Subscription__c subscription = new Subscription__c(
            Name = 'Test Subscription',
            Subscription_Type__c = 'List',
            Subscriber_Private_in_Salesforce__c = false
        );
        Subscription__c subscription2 = new Subscription__c(
            Name = 'Test Subscription',
            Subscription_Type__c = 'List',
            Subscriber_Private_in_Salesforce__c = false
        );
        insert new List<Subscription__c>{ subscription, subscription2 };
        Subscriber__c subscriber = new Subscriber__c(Contact__c = c.Id, Subscription__c = subscription.Id);
        insert subscriber;

        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            EMPLID__c = c.EMPLID__c,
            Subscription__c = subscription.Id
        );
        Contact_Upload_Detail__c cud2 = new Contact_Upload_Detail__c(
            EMPLID__c = c.EMPLID__c,
            Subscription__c = subscription2.Id
        );

        Test.startTest();
        ContactUploadSearcher searcher = new ContactUploadSearcher(new List<Contact_Upload_Detail__c>{ cud });
        searcher.searchContactsToMatch();

        ContactUploadSearcher searcher2 = new ContactUploadSearcher(new List<Contact_Upload_Detail__c>{ cud2 });
        searcher2.searchContactsToMatch();
        Test.stopTest();

        System.assertEquals(c.LastName, searcher.matchedContacts[0].LastName);
        System.assertEquals(0, searcher2.matchedContacts.size()); // Should be unable to find using this subscription
    }

    @isTest
    private static void testCreateNewContact() {
        Contact c = [SELECT Id, EMPLID__c, LastName FROM Contact LIMIT 1];

        String newContactFirstName = 'newContactFirstName';
        String newContactLastName = 'newContactLastName';
        String newContactEmail = 'newContactFirstName.newContactLastName@test.test';
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            First_Name__c = newContactFirstName,
            Last_Name__c = newContactLastName,
            Email__c = newContactEmail
        );

        Test.startTest();
        ContactUploadSearcher searcher = new ContactUploadSearcher(new List<Contact_Upload_Detail__c>{ cud });
        searcher.searchAndCreateContacts();
        Test.stopTest();

        c = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id != :c.Id LIMIT 1];

        System.assertEquals(newContactFirstName, c.FirstName);
        System.assertEquals(newContactLastName, c.LastName);
        System.assertEquals(newContactEmail.toLowerCase(), c.Email.toLowerCase());
    }

    @isTest
    private static void addTestCoverageForUnused() {
        Contact_Upload_Detail__c cud = new Contact_Upload_Detail__c(
            First_Name__c = 'TestCUD',
            Last_Name__c = 'TestCUD',
            Birthdate__c = '2021-07-19',
            Postal_Code__c = '12345',
            Phone__c = 'TESTPHONE'
        );

        Test.startTest();
        ContactUploadSearcher searcher = new ContactUploadSearcher(new List<Contact_Upload_Detail__c>{ cud });
        searcher.mapFirstLastBirthdateAndPostalIfPresent(cud);
        searcher.mapFirstLastAndPhoneIfPresent(cud);
        Test.stopTest();

        // No asserts since this is unused code
    }
}
