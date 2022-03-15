@isTest
public class AttachmentServiceTest {
    /**
     * Setup data for tests: Case with attachments, case with emails with attachments,
     * case with attachments and emails with attachments, case without emails or attachments,
     * case with emails without attachments, case with attachments and emails without attachments,
     * and account with attachments
     */

    @testSetup
    static void testSetup() {
        List<SObject> attachments = new List<SObject>();
        List<Case> parentCases = new List<Case>();
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        Account parentAccount = TestDataFactory.createAccount('Test Account');

        // Create Grandparents
        for (Case c : TestDataFactory.createCases(6)) {
            parentCases.add(c);
        }

        insert parentCases;

        // Create Parents
        // case with emails with attachments
        for (EmailMessage em : TestDataFactory.createEmailMessages(3, parentCases[0].Id)) {
            emailMessages.add(em);
        }

        // case with attachments and emails with attachments
        for (EmailMessage em : TestDataFactory.createEmailMessages(3, parentCases[1].Id)) {
            emailmessages.add(em);
        }

        // case with emails without attachments
        for (EmailMessage em : TestDataFactory.createEmaiLMessages(3, parentCases[2].Id)) {
            emailmessages.add(em);
        }

        // case with attachments and emails without attachments
        for (EmailMessage em : TestDataFactory.createEmaiLMessages(3, parentCases[3].Id)) {
            emailmessages.add(em);
        }

        insert emailMessages;
        insert parentAccount;

        // Create Children
        // case with attachments and emails with attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentCases[1].Id)) {
            attachments.add(a);
        }

        // case with attachments and emails without attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentCases[3].Id)) {
            attachments.add(a);
        }

        // Case with attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentCases[4].Id)) {
            attachments.add(a);
        }

        // account with attachments
        for (Attachment a : TestDataFactory.createAttachments(3, parentAccount.Id)) {
            attachments.add(a);
        }

        // Email Messages with attachments
        for (EmailMessage em : emailMessages) {
            if (em.parentId == parentCases[0].Id || em.parentId == parentCases[1].Id) {
                for (Attachment a : TestDataFactory.createAttachments(3, em.Id)) {
                    attachments.add(a);
                }
            }
        }
        insert attachments;
    }

    /**
     * Test to see if the service can correctly retrieve cases that need to be udpated
     * based on the provided attachment list.
     */
    public static testMethod void Test_updateCasesFromAttachments() {
        List<Attachment> attachments = [SELECT Id, ParentId FROM Attachment];
        AttachmentService.updateCasesFromAttachments(attachments);

        Set<Id> caseIds = new Set<Id>();
        for (Attachment att : attachments) {
            caseIds.add(att.ParentId);
        }

        System.debug(caseIds.size());
        System.debug(caseIds);

        Integer numberOfCases = [SELECT COUNT() FROM Case WHERE Id IN :caseIds];
        system.assertEquals(4, numberOfCases);
    }

    /**
     * Test to see if the service can correctly handle exceptions
     * (will log a error and return null)
     */
    public static testMethod void Test_updateCasesFromAttachments_ExceptionHandling() {
        List<Attachment> attachments = [SELECT Id FROM Attachment];
        AttachmentService.updateCasesFromAttachments(attachments);
        List<Case> errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];

        system.assertEquals(1, errorCases.size());
        // Clean up error cases so that we can easily test other methods' exception handling
        if (errorCases.size() > 0) {
            delete errorCases;
        }
    }

    /**
     * Test attachment Services ability to count the number of attachments per case
     */
    public static testMethod void Test_setCaseNumberOfFiles() {
        Integer counter = 0;
        Map<Id, Case> casesToUpdate = new Map<Id, Case>([SELECT Id FROM Case]);
        casesToUpdate = AttachmentService.setCaseNumberOfFiles(casesToUpdate);

        for (Case c : casesToUpdate.values()) {
            if (c.Attachments__c > 0) {
                counter += 1;
            }
        }

        system.assertEquals(4, counter);
    }

    /**
     * Tests setCaseNumberOfFiles ability to handle exceptions
     */
    public static testMethod void Test_setCaseNumberOfFiles_ExceptionHandling() {
        Integer counter = 0;
        Map<Id, Case> casesToUpdate = AttachmentService.setCaseNumberOfFiles(null);
        List<Case> errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];

        system.assertEquals(null, casesToUpdate);
        system.assertEquals(1, errorCases.size());
        delete errorCases;
    }
}
