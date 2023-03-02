/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-08
 *
 * Unit Tests for AdvisorPortalMassEmailControllerTest
 */
@IsTest
private class AdvisorPortalMassEmailControllerTest {
    @IsTest
    static void testCreatePortalEmails() {
        Contact testContact = new Contact(FirstName = 'Mister', LastName = 'Stark');
        insert testContact;

        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            testCases.add(
                new Case(
                    ContactId = testContact.Id,
                    Subject = 'test-subj-' + i,
                    Status = 'New',
                    CreatedDate = System.today().addDays(-5)
                )
            );
        }
        testCases[4].Subject = 'Latest Email Case test-41';
        testCases[4].CreatedDate = System.today();
        insert testCases;

        Map<Id, Case[]> mapping = new Map<Id, Case[]>();
        mapping.put(testContact.Id, testCases);

        Test.startTest();
        AdvisorPortalMassEmailModalController.createPortalEmails(
            mapping,
            'Test Subject',
            'Testing some email body text.'
        );
        Test.stopTest();

        Integer emailsFoundWithOnlyContact = 0;
        Case assertNewestCase = [SELECT Id FROM Case WHERE Subject = 'Latest Email Case test-41' LIMIT 1];
        List<Portal_Email__c> assertPortalEmails = [
            SELECT Subject__c, Additional_Message_Text__c, Contact__c, Case__c, Status__c
            FROM Portal_Email__c
        ];
        System.assertEquals(
            5,
            assertPortalEmails.size(),
            '5 Portal Emails should have been created, one for each Case (none for the Contact).'
        );

        for (Portal_Email__c email : assertPortalEmails) {
            if (String.isNotBlank(email.Contact__c) && String.isBlank(email.Case__c)) {
                emailsFoundWithOnlyContact++;
            }

            if (email.Case__c == assertNewestCase.Id) {
                System.assertEquals(
                    'New',
                    email.Status__c,
                    'The status should be set to \'New\' for the most recent Case.'
                );
            } else {
                System.assertEquals('Duplicate', email.Status__c, 'The status should have been set to \'Duplicate\'.');
            }

            System.assert(String.isNotBlank(email.Subject__c));
            System.assert(String.isNotBlank(email.Additional_Message_Text__c));
        }

        System.assertEquals(0, emailsFoundWithOnlyContact, 'No email should have been created for the Contact.');
    }

    @isTest
    static void testCreatePortalEmailsStr() {
        Contact testContact = new Contact(FirstName = 'Mister', LastName = 'Stark');
        insert testContact;

        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            testCases.add(
                new Case(
                    ContactId = testContact.Id,
                    Subject = 'test-subj-' + i,
                    Status = 'New',
                    CreatedDate = System.today().addDays(-5)
                )
            );
        }
        testCases[4].Subject = 'Latest Email Case test-41';
        testCases[4].CreatedDate = System.today();
        insert testCases;

        Map<Id, Case[]> mapping = new Map<Id, Case[]>();
        mapping.put(testContact.Id, testCases);

        List<String> contactWrappersJSONList = new List<String>();
        AdvisorPortalContact advisorPortalContact = new AdvisorPortalContact(testContact);
        for (Case c : testCases) {
            AdvisorPortalCase advisorCase = new AdvisorPortalCase(c);
            advisorPortalContact.addCase(advisorCase);
        }
        contactWrappersJSONList.add(JSON.serialize(advisorPortalContact));

        Test.startTest();
        AdvisorPortalMassEmailModalController.createPortalEmailsStr(
            contactWrappersJSONList,
            'Test Subject',
            'Testing some email body text.'
        );
        Test.stopTest();

        Integer emailsFoundWithOnlyContact = 0;
        Case assertNewestCase = [SELECT Id FROM Case WHERE Subject = 'Latest Email Case test-41' LIMIT 1];
        List<Portal_Email__c> assertPortalEmails = [
            SELECT Subject__c, Additional_Message_Text__c, Contact__c, Case__c, Status__c
            FROM Portal_Email__c
        ];
        System.assertEquals(
            5,
            assertPortalEmails.size(),
            '5 Portal Emails should have been created, one for each Case (none for the Contact).'
        );

        for (Portal_Email__c email : assertPortalEmails) {
            if (String.isNotBlank(email.Contact__c) && String.isBlank(email.Case__c)) {
                emailsFoundWithOnlyContact++;
            }

            if (email.Case__c == assertNewestCase.Id) {
                System.assertEquals(
                    'New',
                    email.Status__c,
                    'The status should be set to \'New\' for the most recent Case.'
                );
            } else {
                System.assertEquals('Duplicate', email.Status__c, 'The status should have been set to \'Duplicate\'.');
            }

            System.assert(String.isNotBlank(email.Subject__c));
            System.assert(String.isNotBlank(email.Additional_Message_Text__c));
        }

        System.assertEquals(0, emailsFoundWithOnlyContact, 'No email should have been created for the Contact.');
    }

    @IsTest
    static void testCreatePortalEmailsNoCases() {
        Contact testContact = new Contact(FirstName = 'Mister', LastName = 'Stark');
        insert testContact;

        Map<Id, Case[]> mapping = new Map<Id, Case[]>();
        mapping.put(testContact.Id, new List<Case>());

        Test.startTest();
        AdvisorPortalMassEmailModalController.createPortalEmails(
            mapping,
            'Test Subject',
            'Testing some email body text.'
        );
        Test.stopTest();

        Integer emailsFoundWithOnlyContact = 0;
        List<Portal_Email__c> assertPortalEmails = [
            SELECT Subject__c, Additional_Message_Text__c, Contact__c, Case__c, Status__c
            FROM Portal_Email__c
        ];
        System.assertEquals(1, assertPortalEmails.size(), '1 Portal Email should have been created for the contact.');

        System.assertEquals(
            'New',
            assertPortalEmails[0].Status__c,
            'The status should be set to \'New\' for the only Contact portal email.'
        );
        System.assert(String.isNotBlank(assertPortalEmails[0].Subject__c));
        System.assert(String.isNotBlank(assertPortalEmails[0].Additional_Message_Text__c));
    }

    @isTest
    static void testCreatePortalEmailsStrNoCases() {
        Contact testContact = new Contact(FirstName = 'Mister', LastName = 'Stark');
        insert testContact;

        List<String> contactWrappersJSONList = new List<String>();
        AdvisorPortalContact advisorPortalContact = new AdvisorPortalContact(testContact);
        contactWrappersJSONList.add(JSON.serialize(advisorPortalContact));

        Test.startTest();
        AdvisorPortalMassEmailModalController.createPortalEmailsStr(
            contactWrappersJSONList,
            'Test Subject',
            'Testing some email body text.'
        );
        Test.stopTest();

        Integer emailsFoundWithOnlyContact = 0;
        List<Portal_Email__c> assertPortalEmails = [
            SELECT Subject__c, Additional_Message_Text__c, Contact__c, Case__c, Status__c
            FROM Portal_Email__c
        ];
        System.assertEquals(1, assertPortalEmails.size(), '1 Portal Email should have been created for the contact.');

        System.assertEquals(
            'New',
            assertPortalEmails[0].Status__c,
            'The status should be set to \'New\' for the only Contact portal email.'
        );
        System.assert(String.isNotBlank(assertPortalEmails[0].Subject__c));
        System.assert(String.isNotBlank(assertPortalEmails[0].Additional_Message_Text__c));
    }
}