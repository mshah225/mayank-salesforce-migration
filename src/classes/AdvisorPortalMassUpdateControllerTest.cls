@IsTest
private class AdvisorPortalMassUpdateControllerTest {
    @IsTest
    static void testRecommendedActions() {
        // Act
        Test.startTest();
        Map<String, String> actions = AdvisorPortalMassUpdateController.populateRecommendedActionOptions();
        Test.stopTest();

        // Assert
        System.assert(actions.size() > 0);
    }

    @IsTest
    static void testReturnTermOptions() {
        // Act
        Test.startTest();
        Map<String, String> termOptions = AdvisorPortalMassUpdateController.populateReturnTermOptions();
        Test.stopTest();

        // Assert
        System.assert(termOptions.size() > 0);
    }

    @IsTest
    static void testStudentRiskOptions() {
        // Act
        Test.startTest();
        Map<String, String> riskOptions = AdvisorPortalMassUpdateController.populateStudentRiskOptions();
        Test.stopTest();

        // Assert
        System.assert(riskOptions.size() > 0);
    }

    @IsTest
    static void testReasonNotReturningOptions() {
        // Act
        Test.startTest();
        Map<String, String> returningOptions = AdvisorPortalMassUpdateController.populateReasonNotReturningOptions();
        Test.stopTest();

        // Assert
        System.assert(returningOptions.size() > 0);
    }

    @IsTest
    static void testUpdateCases() {
        // Arrange
        Case testCase = TestDataFactory.createCase('Test Case');
        insert testCase;

        // Act
        Test.startTest();
        testCase.Subject = 'Updated Subject';
        AdvisorPortalMassUpdateController.updateCases(new List<Case>{ testCase });
        Test.stopTest();

        // Assert
        System.assertEquals('Updated Subject', [SELECT Subject FROM Case WHERE Id = :testCase.Id].Subject);
    }

    @IsTest
    static void testLoadMetadata() {
        // Act
        Test.startTest();
        Map<String, Map<String, List<String>>> metadata = AdvisorPortalMassUpdateController.getCustomMetadata();
        Test.stopTest();

        // Assert
        System.assert(metadata.get('caseStatus').containsKey('In Person Meeting'));
        System.assert(metadata.get('caseStatus').containsKey('Closed: Administratively Resolved (No Outreach)'));

        System.assert(metadata.get('studentIntent').get('Not returning temporarily').contains('notReturning'));
        System.assert(metadata.get('studentIntent').get('Not returning temporarily').contains('returnTerm'));

    }
}
