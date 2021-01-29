@isTest
private class CaseShowAllAttachmentsControllerExtTest {
    private static Case testCase;

    private static void setUp() {
        List<Contact> testContact = new ContactFactory.DefaultContact().create();
        insert testContact;

        CaseFactory.DefaultCase defineDefaultCaseType = new CaseFactory.DefaultCase();
        defineDefaultCaseType.setRelatedObject('ContactId', testContact[0]);
        List<Case> testCaseInList = defineDefaultCaseType.create();
        testCase = testCaseInList[0];
        insert testCase;
    }

    private static List<Attachment> createEmailMessagesAndAttachments(Integer noOfEmailsAndAttachments) {
        EmailMessageFactory.DefaultEmailMessage defineDefaultEmailMessage = new EmailMessageFactory.DefaultEmailMessage();
        defineDefaultEmailMessage.setRelatedObject('ParentId', testCase);
        List<EmailMessage> emailMessagesToInsert = defineDefaultEmailMessage.create(noOfEmailsAndAttachments);
        insert emailMessagesToInsert;

        AttachmentFactory.DefaultAttachment defineDefaultAttachment = new AttachmentFactory.DefaultAttachment();
        defineDefaultAttachment.setRelatedObject('ParentId', emailMessagesToInsert);
        List<Attachment> attachmentsToInsert = defineDefaultAttachment.create(noOfEmailsAndAttachments);
        insert attachmentsToInsert;

        return attachmentsToInsert;
    }

    @isTest
    private static void createCaseShowAllAttachmentsControllerExt() {
        setUp();
        ApexPages.StandardController standardCaseController = new ApexPages.StandardController(testCase);
        Test.startTest();
        CaseShowAllAttachmentsControllerExt testShowAllAttachmentsControllerExt = new CaseShowAllAttachmentsControllerExt(
            standardCaseController
        );
        Test.stopTest();
        System.assertEquals(testShowAllAttachmentsControllerExt.caseId, testCase.Id);
        System.assertEquals(testShowAllAttachmentsControllerExt.caseParentId, testCase.ParentId);
    }

    @isTest
    private static void testGetAllAttachments() {
        setUp();
        List<Attachment> expectedAttachments = createEmailMessagesAndAttachments(10);
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);

        Test.startTest();
        List<Attachment> allAttachments = testControllerExt.getAllAttachmentsOnCaseAndCaseParent();
        Test.stopTest();

        Set<Id> retrievedAttachmentIds = new Set<Id>();
        for (Attachment eachAttachment : allAttachments) {
            retrievedAttachmentIds.add(eachAttachment.Id);
        }
        for (Attachment attachmentToMatch : expectedAttachments) {
            System.assert(retrievedAttachmentIds.contains(attachmentToMatch.Id));
        }
    }

    @isTest
    private static void deleteAttachmentSuccess() {
        setUp();
        List<Attachment> expectedAttachments = createEmailMessagesAndAttachments(10);

        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);

        testControllerExt.attachmentIdOnCase = expectedAttachments[0].Id;
        Test.startTest();
        testControllerExt.deleteSelectedAttachmentOnCase();
        Test.stopTest();

        List<Attachment> shouldBeEmpty = [SELECT Id FROM Attachment WHERE ID = :testControllerExt.attachmentIdOnCase];
        System.assert(shouldBeEmpty.isEmpty());
    }

    @isTest
    private static void deleteAttachmentNoId() {
        setUp();
        List<Attachment> expectedAttachments = createEmailMessagesAndAttachments(10);

        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);

        testControllerExt.attachmentIdOnCase = null;
        Test.startTest();
        testControllerExt.deleteSelectedAttachmentOnCase();
        Test.stopTest();

        List<Attachment> allAttachmentsOnCase = [SELECT Id FROM Attachment];
        System.assert(!allAttachmentsOnCase.isEmpty());
        System.assertEquals(10, allAttachmentsOnCase.size());

        Boolean errorMessageFound = false;
        for (ApexPages.Message pageMessage : ApexPages.getMessages()) {
            if (
                pageMessage.getDetail()
                    .contains(
                        'There was a problem deleting the attachment. Please try again or contact the administrator.'
                    )
            ) {
                errorMessageFound = true;
            }
        }
        System.assert(errorMessageFound, 'Error message was not correct on page.');
    }

    @isTest
    private static void testNoAttachmentsOnCase() {
        setUp();
        List<Attachment> retrieveAttachmentList;
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        Test.startTest();
        retrieveAttachmentList = testControllerExt.getAllAttachmentsOnCaseAndCaseParent();
        Test.stopTest();
        System.assertEquals(retrieveAttachmentList.size(), 0);
    }
}
