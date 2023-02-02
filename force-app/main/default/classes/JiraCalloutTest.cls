@isTest
private class JiraCalloutTest {
    @isTest
    private static void createNewIssue() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        String key1 = JiraCallout.createTicket('Summary', 'description', 'Bug', 'TEST-COMPONENT');
        Test.stopTest();

        System.assertEquals('SFE-49392', key1);
        System.assertEquals(mockCallout.mockIssue.key, key1);
        System.assertEquals('17074', mockCallout.mockIssue.projectId);
        System.assertEquals('Summary', mockCallout.mockIssue.summary);
        System.assertEquals('description', mockCallout.mockIssue.description);
        System.assertEquals('Bug', mockCallout.mockIssue.issueType);
        System.assertEquals(1, mockCallout.mockIssue.components.size());
        System.assertEquals('TEST-COMPONENT', mockCallout.mockIssue.components[0]);
    }

    @isTest
    private static void addWatchers() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        JiraCallout.addWatchers('SFE-49392', 'testWatcher');
        Test.stopTest();

        System.assertEquals('SFE-49392', mockCallout.mockIssue.key);
        System.assertEquals(1, mockCallout.mockIssue.watchers.size());
        System.assertEquals(JiraCallout.getJiraAccountId('testWatcher'), mockCallout.mockIssue.watchers[0]);

        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void addComment() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        JiraCallout.addComment('SFE-49392', 'comment');
        Test.stopTest();

        System.assertEquals('SFE-49392', mockCallout.mockIssue.key);
        System.assertEquals(1, mockCallout.mockIssue.comments.size());
        System.assertEquals('comment', mockCallout.mockIssue.comments[0]);

        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void addComponent() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        JiraCallout.addComponent('SFE-49392', 'TEST-COMPONENT');
        Test.stopTest();

        System.assertEquals('SFE-49392', mockCallout.mockIssue.key);
        System.assertEquals(1, mockCallout.mockIssue.components.size());
        System.assertEquals('TEST-COMPONENT', mockCallout.mockIssue.components[0]);

        List<Case> allCases = [SELECT Id FROM Case];
        System.assert(allCases.isEmpty());
    }

    @isTest
    private static void updateStatus() {
        JiraCalloutMock mockCallout = new JiraCalloutMock();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        Test.startTest();
        JiraCallout.updateStatus('SFE-49392', 'Ready for QA Testing');
        Test.stopTest();

        System.assertEquals('SFE-49392', mockCallout.mockIssue.key);
        System.assertEquals(JiraCallout.getStatusKey('Ready for QA Testing'), mockCallout.mockIssue.status);

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
    private static void throwsErrorWhenReturnsNon200() {
        Boolean threwError = false;

        try {
            JiraCalloutMock mock = new JiraCalloutMock();
            mock.setThrowError(true);
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            String key1 = JiraCallout.createTicket('Summary', 'description', 'addUsers', '');
            Test.stopTest();
        } catch (Exception ex) {
            threwError = true;
        }

        System.assert(threwError, 'Should have thrown an error due to invalid JSON');
    }
}