/*
* Name: Test_ChangeCaseOwnerController.cls
* Written by: Mathew Ruff
* Date Created: Feb. 26nd 2015
* 
* Last Updated: Feb. 26th 2015
* What was Changed: Adding queues to page based off completed naming convention (prefix) in DEV.
*/
@isTest(seeAllData = true)
private class Test_ChangeCaseOwnerController {

	private static ChangeCaseOwnerController ccoc;
	private static ApexPages.StandardController sc;
	private static Case testCase;

	static testMethod void setUp() {
		testCase = new Case();
    	testCase.Subject = 'new case';
    	testCase.Description = 'description';
    	insert testCase;

    	sc = new ApexPages.StandardController(testCase);
		PageReference changeOwner = Page.ChangeCaseOwner;
		Test.setCurrentPage(changeOwner);
		ccoc = new ChangeCaseOwnerController(sc);
	}

	static testMethod void testQueue() {
		setUp();
		ccoc.getADM();
		ccoc.getBBSS();
		ccoc.getC();
		ccoc.getDA();
		ccoc.getEDU();
		ccoc.getENG();
		ccoc.getESM();
		ccoc.getFA();
		ccoc.getGRADED();
		ccoc.getHELP();
		ccoc.getHONORS();
		ccoc.getHS();
		ccoc.getIM();
		ccoc.getJOUR();
		ccoc.getLETTERS();
		ccoc.getLIBARTS();
		ccoc.getLIBRARY();
		ccoc.getNC();
		ccoc.getNURSING();
		ccoc.getONLINE();
		ccoc.getPP();
		ccoc.getPRES();
		ccoc.getSBS();
		ccoc.getSCI();
		ccoc.getSUS();
		ccoc.getTECHSTUDIO();
		ccoc.getURS();
		ccoc.getWPC();
		ccoc.queueId = ccoc.bbss[0].Id;
		Test.startTest();
		ccoc.assignOwnerToQueue();
		Test.stopTest();
		System.AssertEquals(testCase.OwnerId,ccoc.queueId);
	}	
}