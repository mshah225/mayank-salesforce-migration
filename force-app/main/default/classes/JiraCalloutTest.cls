@isTest
private class JiraCalloutTest {
    @isTest
    private static void createNewIssue() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
        Test.startTest();
        String key1 = JiraCallout.createNewIssue('Summary', 'description', 'addUsers', 'Bug');
        String key2 = JiraCallout.createNewIssue('Summary', 'description', 'addUsers', 'New Development Request');
        Test.stopTest();
        System.assertEquals('TEST', key1);
        System.assertEquals('TEST', key2);
    }

    @isTest
    private static void addWatchers() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
        Test.startTest();
        JiraCallout.addWatchers('TEST', 'testWatcher');
        Test.stopTest();
        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void addComment() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
        Test.startTest();
        JiraCallout.addComment('TEST', 'comment');
        Test.stopTest();
        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void updateStatus() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
        Test.startTest();
        JiraCallout.updateStatus('TEST', 'Ready for QA Testing');
        Test.stopTest();
        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void getIssues() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
        Test.startTest();
        String issues = JiraCallout.getIssues('asurite');
        Test.stopTest();
        Map<String, Object> mapOfIssues = (Map<String, Object>) JSON.deserializeUntyped(issues);
        Integer numberOfIssues = (Integer) mapOfIssues.get('total');
        System.assertEquals(5, numberOfIssues);
    }

    @isTest
    private static void getWatchedIssues() {
        Test.setMock(HttpCalloutMock.class, new JiraCalloutMock());
        Test.startTest();
        String issues = JiraCallout.getWatchedIssues('asurite');
        Test.stopTest();
        Map<String, Object> mapOfIssues = (Map<String, Object>) JSON.deserializeUntyped(issues);
        Integer numberOfIssues = (Integer) mapOfIssues.get('total');
        System.assertEquals(5, numberOfIssues);
    }

    @isTest
    private static void testAllStatuses() {
        System.assertEquals('131', JiraCallout.getStatusKey('Open'));
        System.assertEquals('81', JiraCallout.getStatusKey('In Testing'));
        System.assertEquals('91', JiraCallout.getStatusKey('Technical Review'));
        System.assertEquals('11', JiraCallout.getStatusKey('New Development Request'));
        System.assertEquals('3', JiraCallout.getStatusKey('New'));
        System.assertEquals('4', JiraCallout.getStatusKey('Working'));
        System.assertEquals('2', JiraCallout.getStatusKey('Closed'));
        System.assertEquals('5', JiraCallout.getStatusKey('Escalated'));
        System.assertEquals('351', JiraCallout.getStatusKey('Ready For Work'));
        System.assertEquals('111', JiraCallout.getStatusKey('Done'));
        System.assertEquals('11', JiraCallout.getStatusKey('DefaultCode'));
    }

    @isTest
    private static void throwsErrorWhenReturnsNon400() {
        Boolean threwError = false;

        try {
            JiraCalloutMock mock = new JiraCalloutMock();
            mock.setThrowError(true);
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            String key1 = JiraCallout.createNewIssue('Summary', 'description', 'addUsers', 'Bug');
            Test.stopTest();
        } catch (Exception ex) {
            threwError = true;
        }

        System.assert(threwError, 'Should have thrown an error due to invalid JSON');
    }
}