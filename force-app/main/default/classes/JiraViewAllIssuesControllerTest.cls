@isTest
public with sharing class JiraViewAllIssuesControllerTest {
    private final static String testUserLastName = 'TestUserFbBtnSrv';

    @TestSetup
    static void setup() {
        User u = new User(
            Username = 'test.user@test.example.com',
            LastName = testUserLastName,
            Email = 'test.user@test.example.com',
            Alias = 'testUsr',
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = IDHelper.getPID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        insert u;
    }

    @isTest
    private static void testGetIssuesForUser() {
        User u = [SELECT Id FROM User WHERE LastName = :testUserLastName];

        List<JiraViewAllIssuesController.JiraIssue> issueList = null;

        System.runAs(u) {
            Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
            Test.startTest();
            issueList = JiraViewAllIssuesController.getIssuesForUser();
            Test.stopTest();
        }

        System.assertEquals(5, issueList.size());
        for (JiraViewAllIssuesController.JiraIssue issue : issueList) {
            if (issue.issueId == '297241') {
                System.assertEquals('UTOTRN-96', issue.key);
                System.assertEquals('Task', issue.issueType);
                System.assertEquals('Ready for Work', issue.status);
                System.assertEquals('Learning History - Justin Sanchez', issue.summary);
            } else if (issue.issueId == '394979') {
                System.assertEquals('SFE-17360', issue.key);
                System.assertEquals('Task', issue.issueType);
                System.assertEquals('Ready for Work', issue.status);
                System.assertEquals('Create singular component for Submit Bug / Submit NDR', issue.summary);
            } else if (issue.issueId == '394161') {
                System.assertEquals('SFE-17267', issue.key);
                System.assertEquals('Bug', issue.issueType);
                System.assertEquals('In Testing', issue.status);
                System.assertEquals('10/12 Dev Deployment', issue.summary);
            } else if (issue.issueId == '392543') {
                System.assertEquals('SFE-17021', issue.key);
                System.assertEquals('Bug', issue.issueType);
                System.assertEquals('In Testing', issue.status);
                System.assertEquals('Create Community and Page Layout', issue.summary);
            } else if (issue.issueId == '392524') {
                System.assertEquals('SFE-17014', issue.key);
                System.assertEquals('Epic', issue.issueType);
                System.assertEquals('In Progress', issue.status);
                System.assertEquals('Lightning Community for Jira Forms', issue.summary);
            } else {
                System.assert(false, 'Should have a case for all issueId\'s.  This should never run.');
            }
        }
    }
    @isTest
    private static void testGetWatchedIssuesForUser() {
        User u = [SELECT Id FROM User WHERE LastName = :testUserLastName];

        List<JiraViewAllIssuesController.JiraIssue> issueList = null;

        System.runAs(u) {
            Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
            Test.startTest();
            issueList = JiraViewAllIssuesController.getWatchedIssuesForUser();
            Test.stopTest();
        }

        System.assertEquals(5, issueList.size());
        for (JiraViewAllIssuesController.JiraIssue issue : issueList) {
            if (issue.issueId == '297241') {
                System.assertEquals('UTOTRN-96', issue.key);
                System.assertEquals('Task', issue.issueType);
                System.assertEquals('Ready for Work', issue.status);
                System.assertEquals('Learning History - Justin Sanchez', issue.summary);
            } else if (issue.issueId == '394979') {
                System.assertEquals('SFE-17360', issue.key);
                System.assertEquals('Task', issue.issueType);
                System.assertEquals('Ready for Work', issue.status);
                System.assertEquals('Create singular component for Submit Bug / Submit NDR', issue.summary);
            } else if (issue.issueId == '394161') {
                System.assertEquals('SFE-17267', issue.key);
                System.assertEquals('Bug', issue.issueType);
                System.assertEquals('In Testing', issue.status);
                System.assertEquals('10/12 Dev Deployment', issue.summary);
            } else if (issue.issueId == '392543') {
                System.assertEquals('SFE-17021', issue.key);
                System.assertEquals('Bug', issue.issueType);
                System.assertEquals('In Testing', issue.status);
                System.assertEquals('Create Community and Page Layout', issue.summary);
            } else if (issue.issueId == '392524') {
                System.assertEquals('SFE-17014', issue.key);
                System.assertEquals('Epic', issue.issueType);
                System.assertEquals('In Progress', issue.status);
                System.assertEquals('Lightning Community for Jira Forms', issue.summary);
            } else {
                System.assert(false, 'Should have a case for all issueId\'s.  This should never run.');
            }
        }
    }
}
