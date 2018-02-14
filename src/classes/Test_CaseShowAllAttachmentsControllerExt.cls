@isTest
private class Test_CaseShowAllAttachmentsControllerExt {
    
    private static Case testCase;

    private static void setUp(){
        testCase = new Case();

        Contact testContact = new Contact();
        testContact.FirstName= 'Test';
        testContact.LastName = 'Guy';
        testContact.Salutation = 'Mr.';
        insert testContact;

        testCase.ContactId = testContact.Id;

        insert testCase;
    }

    private static List<Attachment> createEmailMessagesAndAttachments(Integer emails){
        List<EmailMessage> emailsToInsert = new List<EmailMessage>();
        List<Attachment> attachToInsert = new List<Attachment>();
        //Create test email messages
        for(Integer i = 0; i < emails; i++){
            EmailMessage emailMsg = new EMailMessage();
            emailMsg.ParentId = testCase.Id;
            emailMsg.FromName = 'Test Guy' + i;
            emailMsg.FromAddress = 'test' + i + '@example.com';
            emailMsg.Subject = 'Testing ' + i;
            emailMsg.ToAddress = 'sendto' + i + '@example.com';
            emailsToInsert.add(emailMsg);

            Attachment attach = new Attachment();
            attach.ParentId = testCase.Id;
            attach.Name = 'Test Attach ' + i;
            String body = 'Test body';
            Blob blobby = Blob.valueOf(body);
            attach.Body = blobby;
            attachToInsert.add(attach);
        }

        insert emailsToInsert;
        insert attachToInsert;

        return attachToInsert;
    }

    @isTest 
    private static void testConstructor() {
        setUp();
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        Test.startTest();
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        Test.stopTest();
    }
    
    @isTest 
    private static void testGetAllAttachments() {
        setUp();
        Attachment[] expectedAttachments = createEmailMessagesAndAttachments(10);
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        Test.startTest();
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        Attachment[] allAttachments = testControllerExt.getAllAttachments();
        for(Integer i = 0; i < allAttachments.size(); i++){
            //System.assertEquals(allAttachments[i].Id, expectedAttachments[i].Id);
        }
        Test.stopTest();
    }
    
    @isTest 
    private static void testGetContactName() {
        setUp();
        ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
        Test.startTest();
        CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
        String result = testControllerExt.getContactName();
        System.assertEquals('Test Guy', result);
        Test.stopTest();
    }
    
    @isTest 
    private static void deleteAttachmentSuccess() {
        setUp();
        Attachment[] expectedAttachments = createEmailMessagesAndAttachments(10);
        
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
        Attachment[] expectedAttachments = createEmailMessagesAndAttachments(10);
        
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
}