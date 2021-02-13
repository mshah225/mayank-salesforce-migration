@isTest
private class JiraWebserviceCalloutTest {
    @isTest
    private static void createNewIssue() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpMockCallout());
        Test.startTest();
        String key = JIRAWebserviceCallout.createNewIssue('Summary', 'description', 'addUsers', 'Bug');
        Test.stopTest();
        System.assertEquals('TEST', key);
    }

    @isTest
    private static void addWatchers() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpMockCallout());
        Test.startTest();
        JIRAWebserviceCallout.addWatchers('TEST', 'testWatcher');
        Test.stopTest();
        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void addComment() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpMockCallout());
        Test.startTest();
        JIRAWebserviceCallout.addComment('TEST', 'comment');
        Test.stopTest();
        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void updateStatus() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpMockCallout());
        Test.startTest();
        JIRAWebserviceCallout.updateStatus('TEST', 'Ready for QA Testing');
        Test.stopTest();
        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void getIssues() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpMockCallout());
        Test.startTest();
        String issues = JIRAWebserviceCallout.getIssues('asurite');
        Test.stopTest();
        Map<String, Object> mapOfIssues = (Map<String, Object>) JSON.deserializeUntyped(issues);
        Integer numberOfIssues = (Integer) mapOfIssues.get('total');
        System.assertEquals(5, numberOfIssues);
    }

    @isTest
    private static void getWatchedIssues() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpMockCallout());
        Test.startTest();
        String issues = JIRAWebserviceCallout.getWatchedIssues('asurite');
        Test.stopTest();
        Map<String, Object> mapOfIssues = (Map<String, Object>) JSON.deserializeUntyped(issues);
        Integer numberOfIssues = (Integer) mapOfIssues.get('total');
        System.assertEquals(5, numberOfIssues);
    }
}
