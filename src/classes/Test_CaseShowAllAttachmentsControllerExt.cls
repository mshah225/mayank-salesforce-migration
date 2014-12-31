@isTest
private class Test_CaseShowAllAttachmentsControllerExt {
	
	private static Case testCase;
	private static String testContactName;

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
		setUp();

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

	@isTest static void testConstructor() {
		setUp();
		ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
		Test.startTest();
		CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
		Test.stopTest();
	}
	
	@isTest static void testGetAllAttachments() {
		Attachment[] expectedAttachments = createEmailMessagesAndAttachments(10);
		ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
		Test.startTest();
		CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
		Attachment[] allAttachments = testControllerExt.getAllAttachments();
		for(Integer i = 0; i < allAttachments.size(); i++){
			System.assertEquals(allAttachments[i].Id, expectedAttachments[i].Id);
		}
		Test.stopTest();
	}
	
	@isTest static void testGetContactName() {
		setUp();
		ApexPages.StandardController stanController = new ApexPages.StandardController(testCase);
		Test.startTest();
		CaseShowAllAttachmentsControllerExt testControllerExt = new CaseShowAllAttachmentsControllerExt(stanController);
		String result = testControllerExt.getContactName();
		System.assertEquals(testContactName, result);
		Test.stopTest();
	}
}