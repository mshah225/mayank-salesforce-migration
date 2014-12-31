@isTest
private class Test_NewCase {

    static testMethod void newCaseTest() {
    	Test.startTest();
    	Contact contact = new Contact();
        ApexPages.StandardController standard = new ApexPages.StandardController(contact);
        NewCase nc = new NewCase(standard);
        nc = new NewCase();
        Case testCase = new Case();
        testCase.Subject = 'test';
        testCase.Description = 'testing';
        PageReference expected = new PageReference('/studentSC?Confirm=case');
        PageReference result = nc.SubmitCase();
        System.AssertEquals(expected.getURL(), result.getURL());
        Test.stopTest();
    }
}