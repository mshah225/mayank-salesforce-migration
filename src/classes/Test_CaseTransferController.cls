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

		PageReference pageRef = page.CaseTransfer;
		Test.setCurrentPage(pageRef);
	}

	@isTest static void test_method_one() 
	{
		Case caseToTest = [SELECT Id FROM Case LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(caseToTest);
		CaseTransferController ctc = new CaseTransferController(sc);
		Test.startTest();
		ctc.getColumnList();
		Case_Assignment_Rule__c testCar = [SELECT Id, Label__c, CTPGroup__c 
										   FROM Case_Assignment_Rule__c 
										   WHERE Label__c = 'Engineering (Default)'];
		ctc.selectedCARId = testCar.Id;
		ctc.selectedCARLabel = testCar.Label__c;
		ctc.selectedGroupName = testCar.CTPGroup__c;
		ctc.showChatterBox();
		ctc.transferCase();
		Test.stopTest();
	}
}