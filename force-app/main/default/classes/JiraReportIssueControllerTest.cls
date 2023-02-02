@isTest
public with sharing class JiraReportIssueControllerTest {
    @isTest
    private static void testJiraKey() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());

        Test.startTest();
        String keyBug = JiraReportIssueController.createNewDevelopmentRequest('Summary', 'description', 'addUsers');
        String keyNew = JiraReportIssueController.createBugReport('Summary', 'description', 'addUsers');
        String keyImport = JiraReportIssueController.createDataImport('Summary', 'description', 'addUsers');
        Test.stopTest();

        System.assertEquals('SFE-49392', keyNew);
        System.assertEquals('SFE-49392', keyBug);
        System.assertEquals('SFE-49392', keyImport);
    }
}