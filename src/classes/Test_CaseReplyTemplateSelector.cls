@isTest
private class Test_CaseReplyTemplateSelector {
	
	private static testMethod void testDefaultEmailTemplate() {
		CaseReplyTemplateSelector crtl = new CaseReplyTemplateSelector();
		Test.startTest();
		Case c = new Case();
        c.Subject = 'I\'m testing my class';
        insert c;
		EmailTemplate et = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'Case_Management_Default_Template'];
		System.AssertNotEquals(null, crtl.getDefaultEmailTemplateId(c.Id));
		Test.stopTest();
	}
}