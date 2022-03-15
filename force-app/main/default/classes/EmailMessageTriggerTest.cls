@isTest
public class EmailMessageTriggerTest {
    private static Integer numberOfCases;

    static {
        numberOfCases = 3;
    }

    @testSetup
    public static void testSetup() {
        List<Contact> contacts = TestDataFactory.createContacts(numberOfCases);

        // Lets make sure contacts have emails
        for (Contact c : contacts) {
            c.email = c.firstName + '.' + c.lastName + '@test.com';
        }

        insert contacts;

        List<Case> cases = TestDataFactory.createCases(contacts.size());

        for (integer x = 0; x < contacts.size(); x++) {
            cases[x].contactId = contacts[x].id;
            if (math.mod(x, 2) == 0) {
                cases[x].recordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
            }
        }

        insert cases;

        List<EmailMessage> messages = new List<EmailMessage>();

        for (Case c : cases) {
            messages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = c.contact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    parentId = c.Id
                )
            );
        }

        insert messages;
    }

    /*
     * Tests the trigger's ability to set the status of advisor cases
     */
    public static testMethod void test_setAdvisorStatus() {
        for (Case c : [SELECT Status, RecordTypeId FROM Case]) {
            if (c.recordTypeId == RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach')) {
                system.assertEquals('Email Sent', c.status);
            } else {
                system.assertEquals('New', c.status);
            }
        }
    }

    /*
     * This test provides code coverage for the trigger events that have no code in them.
     *
     * <p>
     * note: cannot test update on email message as all fields are read only once the record is inserted.
     * </p>
     */
    public static testMethod void Test_deleteUndelete() {
        List<EmailMessage> messages = [SELECT Id FROM EmailMessage LIMIT 2];

        delete messages;
        undelete messages;
    }

    /*
     * This tests the services ability to log errors.
     */
    public static testMethod void Test_ExceptionHandling() {
        List<Case> errorCases;
        Test.startTest();
        EmailMessageService.updateCasesFromEmailMessages(null);

        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];

        system.assertEquals(1, errorCases.size());

        delete errorCases;

        EmailMessageService.setAdvisorCaseStatus(null);

        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];

        system.assertEquals(1, errorCases.size());

        delete errorCases;
        Test.stopTest();
    }
}
