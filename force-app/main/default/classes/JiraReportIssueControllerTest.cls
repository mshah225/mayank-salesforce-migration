@isTest
public with sharing class JiraReportIssueControllerTest {
    @isTest
    private static void testCreateNDR() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        String key = JiraReportIssueController.createNewDevelopmentRequest('Summary', 'description', 'addUsers');
        Test.stopTest();

        System.assertEquals(mockCallout.mockIssue.key, key);
        System.assertEquals('Summary', mockCallout.mockIssue.summary);
        System.assertEquals('description', mockCallout.mockIssue.description);
        System.assertEquals('Task', mockCallout.mockIssue.issueType);
        System.assertEquals(JiraCallout.getStatusKey('New Development Request'), mockCallout.mockIssue.status);
        System.assertEquals(1, mockCallout.mockIssue.watchers.size());
        System.assertEquals(JiraCallout.getJiraAccountId('testWatcher'), mockCallout.mockIssue.watchers[0]);
    }

    @isTest
    private static void testCreateBug() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        String key = JiraReportIssueController.createBugReport('Summary', 'description', 'addUsers,addUsers2');
        Test.stopTest();

        System.assertEquals(mockCallout.mockIssue.key, key);
        System.assertEquals('Summary', mockCallout.mockIssue.summary);
        System.assertEquals('description', mockCallout.mockIssue.description);
        System.assertEquals('Bug', mockCallout.mockIssue.issueType);
        System.assertEquals(JiraCallout.getStatusKey('Ready For Work'), mockCallout.mockIssue.status);
        System.assertEquals(2, mockCallout.mockIssue.watchers.size());
        System.assertEquals(JiraCallout.getJiraAccountId('addUsers'), mockCallout.mockIssue.watchers[0]);
        System.assertEquals(JiraCallout.getJiraAccountId('addUsers2'), mockCallout.mockIssue.watchers[1]);
    }

    @isTest
    private static void testCreateDataImport() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        String key = JiraReportIssueController.createDataImport('Summary', 'description', '');
        Test.stopTest();

        System.assertEquals(mockCallout.mockIssue.key, key);
        System.assertEquals('Summary', mockCallout.mockIssue.summary);
        System.assertEquals('description', mockCallout.mockIssue.description);
        System.assertEquals('Task', mockCallout.mockIssue.issueType);
        System.assertEquals(JiraCallout.getStatusKey('Open'), mockCallout.mockIssue.status);
        System.assertEquals(0, mockCallout.mockIssue.watchers.size());
        System.assertEquals(1, mockCallout.mockIssue.components.size());
        System.assertEquals('DATA IMPORT', mockCallout.mockIssue.components[0]);
    }
}