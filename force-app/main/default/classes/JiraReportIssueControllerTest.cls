@isTest
public with sharing class JiraReportIssueControllerTest {
    @isTest
    private static void testJiraKey() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());

        Test.startTest();
        String keyBug = JiraReportIssueController.callout('Summary', 'description', 'addUsers', 'New');
        String keyNew = JiraReportIssueController.callout('Summary', 'description', 'addUsers', 'Bug');
        Test.stopTest();

        System.assertEquals('TEST', keyNew);
        System.assertEquals('TEST', keyBug);
    }
}
