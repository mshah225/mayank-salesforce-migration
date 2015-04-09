@isTest
private class Test_FeedbackController
{	
	private static Contact testContact;
	private static Case testCase;
	private static User testUser;
	private static FeedbackController fc;

	static void setUp() 
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='ASU Community'];

		testContact = new Contact(
			FirstName = 'John',
			LastName = 'Doe',
			ASURITE_Id__c = 'testing');
		insert testContact;

		testUser = new User(
			FirstName = 'John',
			LastName = 'Doe',
			Alias = 'testing',
			Username = 'username@test.com',
	        Email = 'test@nomail.com',
	        CommunityNickname = 'testingNick',
	        TimeZoneSidKey = 'America/Phoenix',
	        LocaleSidKey = 'en_US',
	        EmailEncodingKey = 'ISO-8859-1',
	        LanguageLocaleKey = 'en_US',
	        ProfileId = p.Id,
	        ContactId = testContact.Id);
		insert testUser;

		testCase = new Case(
			Description = 'Test Description');

		fc = new FeedbackController();
	}

	@isTest static void testFeedbackCase() 
	{
		setUp();
		fc.c = testCase;
		fc.comments = testCase.Description;
		PageReference setPage = Page.feedback;
		Test.setCurrentPage(setPage);
		PageReference submitTest = new PageReference('/studentSC?Confirm=feedback');
		System.runAs(testUser) 
		{
			System.assertEquals(fc.submit().getUrl(),submitTest.getUrl());
		}
	}
}