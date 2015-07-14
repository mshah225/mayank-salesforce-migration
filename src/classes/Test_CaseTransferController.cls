@isTest
private class Test_CaseTransferController {
	
	@testSetup static void setUpData()
	{
		Case_Assignment_Rule__c one = new Case_Assignment_Rule__c(
			CTPColumn__c = 'Colleges', 
			CTPGroup__c = 'Engineering', 
			CTPVisible__c = true, 
			Email_Address__c = 'default@email.com', 
			Functional_Group__c = 'Engineering', 
			Label__c = 'Engineering (Default)',
			Category__c = 'Eng',
			Sub_Category__c = 'SubEng');
		insert one;

		Case_Assignment_Rule__c two = new Case_Assignment_Rule__c(
			CTPColumn__c = 'Colleges', 
			CTPGroup__c = 'Engineering', 
			CTPVisible__c = true, 
			Email_Address__c = 'default@email.com', 
			Functional_Group__c = 'Engineering', 
			Label__c = 'School of blah blah');
		insert two;

		Case_Assignment_Rule__c three = new Case_Assignment_Rule__c(
			CTPColumn__c = 'Service Departments', 
			CTPGroup__c = 'University Registrar Services', 
			CTPVisible__c = true, 
			Email_Address__c = 'default@email.com', 
			Functional_Group__c = 'University Registrar Services', 
			Label__c = 'University Registrar Services (Default)');
		insert three;

		Case_Assignment_Rule__c four = new Case_Assignment_Rule__c(
			CTPColumn__c = 'Service Departments', 
			CTPGroup__c = 'University Registrar Services', 
			CTPVisible__c = true, 
			Email_Address__c = 'default@email.com', 
			Functional_Group__c = 'University Registrar Services', 
			Label__c = 'School of blah blah');
		insert four;

		Case testCase = new Case(
			Subject = 'subject',
			Description = 'desc');
		insert testCase;

		User testUser = UserService.createTestUser();
		Id pId = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Service%' LIMIT 1].Id;
		testUser.ProfileId = pId;
		insert testUser;

		PageReference pageRef = page.CaseTransfer;
		Test.setCurrentPage(pageRef);
	}

	@isTest static void testTransferToDept() 
	{
		Case caseToTest = [SELECT Id FROM Case LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
		CaseTransferController ctc = new CaseTransferController(sc);
		Test.startTest();
		ctc.getColumnList();
		Case_Assignment_Rule__c testCar = [SELECT Id, Label__c, CTPGroup__c 
										   FROM Case_Assignment_Rule__c 
										   WHERE Label__c = 'Engineering (Default)'];

		ctc.page3();
		ctc.selectedId = testCar.Id;
		ctc.selectedCARLabel = testCar.Label__c;
		ctc.selectedGroupName = testCar.CTPGroup__c;
		ctc.page4();
		ctc.transferCase();
		Test.stopTest();
	}

	@isTest static void testTransferToUser()
	{
		Case caseToTest = [SELECT Id FROM Case LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
		CaseTransferController ctc = new CaseTransferController(sc);
		Test.startTest();
		User testUser = [SELECT Id, Name
						 FROM User
						 WHERE Name = 'Test User'];

		ctc.page2();
		ctc.selectedId = testUser.Id;
		ctc.page4();
		ctc.transferCase();
		Test.stopTest();
	}

	@isTest static void testTransferToUserWithSearch()
	{
		Case caseToTest = [SELECT Id FROM Case LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
		CaseTransferController ctc = new CaseTransferController(sc);
		Test.startTest();
		User testUser = [SELECT Id, Name
						 FROM User
						 WHERE Name = 'Test User'];

		ctc.page2();
		ctc.page1();
		ctc.page2();
		ctc.searchString = 'Test';
		ctc.searchUsers();
		ctc.selectedId = testUser.Id;
		ctc.page4();
		ctc.transferCase();
		Test.stopTest();
	}
}