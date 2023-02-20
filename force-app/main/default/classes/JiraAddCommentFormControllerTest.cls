@isTest
public with sharing class JiraAddCommentFormControllerTest {
    @isTest
    private static void testNoErrorLogged() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        JiraAddCommentFormController.submitForm('comment', 'TEST-003', 'Ready for QA Testing');
        Test.stopTest();

        System.assertEquals('TEST-003', mockCallout.mockIssue.key);
        System.assertEquals(JiraCallout.getStatusKey('Ready for QA Testing'), mockCallout.mockIssue.status);
        System.assertEquals(1, mockCallout.mockIssue.comments.size());
        System.assertEquals('comment', mockCallout.mockIssue.comments[0]);

        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }
}