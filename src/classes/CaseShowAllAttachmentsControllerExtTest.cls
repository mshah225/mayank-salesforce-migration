@isTest
private class CaseShowAllAttachmentsControllerExtTest {
    
    private static Case testCase;

    private static void setUp(){
        Contact testContact = (Contact) new ContactFactory.DefaultContact().create()[0];
        insert testContact;
        
        CaseFactory.DefaultCase defineDefaultCaseType = new CaseFactory.DefaultCase();
        defineDefaultCaseType.setRelatedObject('ContactId', testContact);
        testCase = (Case) defineDefaultCaseType.create()[0];
        insert testCase;
    }

    private static List<Attachment> createEmailMessagesAndAttachments(Integer noOfEmailsAndAttachments) {
        EmailMessageFactory.DefaultEmailMessage defineDefaultEmailMessage = new EmailMessageFactory.DefaultEmailMessage();
        defineDefaultEmailMessage.setRelatedObject('ParentId', testCase);
        List<EmailMessage> emailMessagesToInsert = (List<EmailMessage>) defineDefaultEmailMessage.create(noOfEmailsAndAttachments);
        insert emailMessagesToInsert;
        
        AttachmentFactory.DefaultAttachment defineDefaultAttachment = new AttachmentFactory.DefaultAttachment();
        defineDefaultAttachment.setRelatedObject('ParentId', emailMessagesToInsert);
        List<Attachment> attachmentsToInsert = (List<Attachment>) defineDefaultAttachment.create(noOfEmailsAndAttachments);
        insert attachmentsToInsert;

        return attachmentsToInsert;
    }

    @isTest 
    private static void testConstructor() {
        setUp();
        ApexPages.StandardController standardCaseController = new ApexPages.StandardController(testCase);
        Test.startTest();
        CaseShowAllAttachmentsControllerExt testShowAllAttachmentsControllerExt = new CaseShowAllAttachmentsControllerExt(standardCaseController);
        Test.stopTest();
        System.assertEquals(testShowAllAttachmentsControllerExt.caseId, testCase.Id);
    }
    
    @isTest 
    private static void testGetAllAttachments() {
        setUp();
        List<Attachment> expectedAttachments = createEmailMessagesAndAttachments(10);
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        
        Test.startTest();
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        List<Attachment> allAttachments = testControllerExt.getAllAttachments();
        Test.stopTest();
        
        Set<Id> expectedAttachmentIds = new Set<Id>();
        for (Attachment expectedAttachment : expectedAttachments) {
            expectedAttachmentIds.add(expectedAttachment.Id);
        }
        for (Attachment attachmentToMatch : allAttachments){
            System.assert(expectedAttachmentIds.contains(attachmentToMatch.Id));
        }
    }
    
    @isTest 
    private static void deleteAttachmentSuccess() {
        setUp();
        List<Attachment> expectedAttachments = createEmailMessagesAndAttachments(10);
        
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        
        testControllerExt.attId = expectedAttachments[0].Id;
        Test.startTest();
        testControllerExt.deleteAttachment();
        Test.stopTest();
        
        List<Attachment> shouldBeEmpty = [SELECT Id FROM Attachment WHERE ID = :testControllerExt.attId];
        System.assert(shouldBeEmpty.isEmpty());
    }
    
    @isTest 
    private static void deleteAttachmentNoId() {
        setUp();
        List<Attachment> expectedAttachments = createEmailMessagesAndAttachments(10);
        
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        
        testControllerExt.attId = null;
        Test.startTest();
        testControllerExt.deleteAttachment();
        Test.stopTest();
        
        List<Attachment> shouldBeEmpty = [SELECT Id FROM Attachment];
        System.assert(!shouldBeEmpty.isEmpty());
        System.assertEquals(10, shouldBeEmpty.size());
        
        Boolean errorMessageFound = false;
        for (ApexPages.Message pageMessage :  ApexPages.getMessages()) {
            if (pageMessage.getDetail().contains('There was a problem deleting the attachment. Please try again or contact the administrator.')) {
                errorMessageFound = true;
            }
        }
        System.assert(errorMessageFound, 'Error message was not correct on page.');
    }

    @isTest
    private static void testNoAttachmentsOnCase() {
        setup();
        List<Attachment> retrieveAttachmentList;
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        Test.startTest();
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        retrieveAttachmentList = testControllerExt.getAllAttachments();
        Test.stopTest();
        System.assertEquals(retrieveAttachmentList.size(), 0);
    }
    
    //negative tests for getAllAttachments
    // add asserts
    // check email message without parent and case without parent case
    // test data factory
}