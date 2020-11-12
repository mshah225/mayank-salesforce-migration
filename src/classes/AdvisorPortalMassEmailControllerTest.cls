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
        // Arrange
        Contact testContact = TestDataFactory.createContact('Stark');
        insert testContact;

        List<Case> testCases = TestDataFactory.createCases(5);
        for (Case c : testCases) {
            c.CreatedDate = System.today().addDays(-5);
            c.ContactId = testContact.Id;
        }
        testCases[4].Subject = 'Latest Email Case';
        testCases[4].CreatedDate = System.today();
        insert testCases;

        // Act
        Test.startTest();
        AdvisorPortalMassEmailModalController.createPortalEmails(
            testCases,
            'Test Subject',
            'Testing some email body text.'
        );
        Test.stopTest();

        // Assert
        Integer emailsFoundWithOnlyContact = 0;
        Case assertNewestCase = [SELECT Id FROM Case WHERE Subject = 'Latest Email Case' LIMIT 1];
        List<Portal_Email__c> assertPortalEmails = [
            SELECT Subject__c, Additional_Message_Text__c, Contact__c, Case__c, Status__c
            FROM Portal_Email__c
        ];
        System.assertEquals(
            6,
            assertPortalEmails.size(),
            '6 Portal Emails should have been created, 1 for the Contact and 5 for each Case.'
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

        System.assertEquals(1, emailsFoundWithOnlyContact, 'Only 1 email should have been created for the Contact.');
    }
}
