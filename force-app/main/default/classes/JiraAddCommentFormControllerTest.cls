@isTest
public with sharing class JiraAddCommentFormControllerTest {
    @isTest
    private static void testNoErrorLogged() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());

        Test.startTest();
        JiraAddCommentFormController.submitForm('comment', 'TEST', 'Ready for QA Testing');
        Test.stopTest();

        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }
}
