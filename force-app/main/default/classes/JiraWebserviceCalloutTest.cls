@isTest
private class JiraWebserviceCalloutTest {
    @isTest
    private static void createNewIssue() {
        Test.setMock(HttpCalloutMock.class, new JiraHttpMockCallout());
        Test.startTest();
        String key1 = JIRAWebserviceCallout.createNewIssue('Summary', 'description', 'addUsers', 'Bug');
        String key2 = JIRAWebserviceCallout.createNewIssue(
            'Summary',
            'description',
            'addUsers',
            'New Development Request'
        );
        Test.stopTest();
        System.assertEquals('TEST', key1);
        System.assertEquals('TEST', key2);
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

    @isTest
    private static void testAllStatuses() {
        System.assertEquals('131', JIRAWebserviceCallout.getStatusKey('Open'));
        System.assertEquals('81', JIRAWebserviceCallout.getStatusKey('In Testing'));
        System.assertEquals('91', JIRAWebserviceCallout.getStatusKey('Technical Review'));
        System.assertEquals('11', JIRAWebserviceCallout.getStatusKey('New Development Request'));
        System.assertEquals('3', JIRAWebserviceCallout.getStatusKey('New'));
        System.assertEquals('4', JIRAWebserviceCallout.getStatusKey('Working'));
        System.assertEquals('2', JIRAWebserviceCallout.getStatusKey('Closed'));
        System.assertEquals('5', JIRAWebserviceCallout.getStatusKey('Escalated'));
        System.assertEquals('351', JIRAWebserviceCallout.getStatusKey('Ready For Work'));
        System.assertEquals('111', JIRAWebserviceCallout.getStatusKey('Done'));
        System.assertEquals('11', JIRAWebserviceCallout.getStatusKey('DefaultCode'));
    }
}
