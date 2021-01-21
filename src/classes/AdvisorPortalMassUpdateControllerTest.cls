/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-15
 *
 *
 */
@IsTest
private class AdvisorPortalMassUpdateControllerTest {
    @IsTest
    static void testClosedCaseStatuses() {
        // Act
        Test.startTest();
        List<String> closedStatuses = AdvisorPortalMassUpdateController.populateClosedCaseStatusOptions();
        Test.stopTest();

        // Assert
        System.assertEquals(5, closedStatuses.size());
        System.assert(closedStatuses.contains('In Person Meeting'));
    }

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
    static void testStudentIntentions() {
        // Act
        Test.startTest();
        List<String> studentIntentionOptions = AdvisorPortalMassUpdateController.populateStudentIntentionOptions();
        Test.stopTest();

        // Assert
        System.assertEquals(3, studentIntentionOptions.size());
        System.assert(studentIntentionOptions.contains('Enrolled'));
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
}
