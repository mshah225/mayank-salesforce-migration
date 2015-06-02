@isTest
private class Test_ViewAllCasesController 
{
	@testSetup static void setup()
	{
		Contact testContact = ContactService.createTestContact();
		insert testContact;

		User testUser = UserService.createTestUser();
		testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
		testUser.ContactId = testContact.Id;
		insert testUser;

		List<Case> testCases = CaseService.createTestCases(10, testContact);

		// Set the first three testCases to closed
		Integer i = 0;
		for (Case c : testCases)
		{
			if (i < 3)
			{
				c.Status = 'New';
				i++;
			}
			else
			{
				c.Status = 'Closed: Resolved';
			}
		}

		insert testCases;
	}

	@isTest static void testViewCase()
	{
		User testUser = [SELECT Id FROM User WHERE Alias = 'testuser'];
		Case testCase = [SELECT Id FROM Case WHERE Status = 'New' LIMIT 1];

		PageReference viewAllCasesPage = Page.viewAllCases;
		Test.setCurrentPage(viewAllCasesPage);
		ViewAllCasesController vac = null;
		PageReference viewCasePageResult = null;
		PageReference viewCasePageExpected = Page.viewcase;
		viewCasePageExpected.getParameters().put('id', testCase.Id);
		viewCasePageExpected.getParameters().put('source', 'viewAllCases');

		Test.startTest();
		System.runAs(testUser)
		{
			vac = new ViewAllCasesController();
			System.currentPageReference().getParameters().put('caseId', testCase.Id);
			viewCasePageResult = vac.viewCase();
		}
		Test.stopTest();

		System.assertEquals(viewCasePageExpected.getUrl(), viewCasePageResult.getUrl());
	}

	@isTest static void testGetOpenCases()
	{
		User testUser = [SELECT Id FROM User WHERE Alias = 'testuser'];

		PageReference viewAllCasesPage = Page.viewAllCases;
		Test.setCurrentPage(viewAllCasesPage);
		ViewAllCasesController vac = null;
		List<Case> openCases = null;

		Test.startTest();
		System.runAs(testUser)
		{
			vac = new ViewAllCasesController();

			openCases = vac.getOpenCases();
		}
		Test.stopTest();

		System.assertEquals(3, openCases.size());
	}

	@isTest static void testGetClosedCases()
	{
		User testUser = [SELECT Id FROM User WHERE Alias = 'testuser'];

		PageReference viewAllCasesPage = Page.viewAllCases;
		Test.setCurrentPage(viewAllCasesPage);
		ViewAllCasesController vac = null;
		List<Case> closedCases = null;

		Test.startTest();
		System.runAs(testUser)
		{
			vac = new ViewAllCasesController();

			closedCases = vac.getClosedCases();
		}
		Test.stopTest();

		System.assertEquals(7, closedCases.size());
	}

	@isTest static void testGetSource()
	{
		User testUser = [SELECT Id FROM User WHERE Alias = 'testuser'];

		PageReference viewAllCasesPage = Page.viewAllCases;
		Test.setCurrentPage(viewAllCasesPage);
		ViewAllCasesController vac = null;
		List<Case> closedCases = null;
		String viewAllCaseSource = null;
		String studentSCSource = null;

		Test.startTest();
		System.runAs(testUser)
		{
			vac = new ViewAllCasesController();
			System.currentPageReference().getParameters().put('source', 'viewAllCases');
			viewAllCaseSource = vac.getSource();

			System.currentPageReference().getParameters().put('source', 'studentSC');
			studentSCSource = vac.getSource();
		}
		Test.stopTest();

		System.assertEquals('viewAllCases', viewAllCaseSource);
		System.assertEquals('studentSC', studentSCSource);
	}
}