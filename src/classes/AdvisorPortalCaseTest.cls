/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-06
 *
 * Unit Tests for AdvisorPortalCase.cls
 */
@IsTest
private class AdvisorPortalCaseTest {
    @IsTest
    private static void testCreateAdvisorPortalCase() {
        // Arrange
        Case testCase = TestDataFactory.createCase('Test Case');
        insert testCase;

        // Act
        Test.startTest();
        AdvisorPortalCase testAdvisorPortalCase = new AdvisorPortalCase(testCase);
        Test.stopTest();

        // Assert
        System.assertEquals(false, testAdvisorPortalCase.isSelected, 'isSelected should default to false.');
        System.assertEquals(
            'Test Case',
            testAdvisorPortalCase.portalCase.Subject,
            'The Advisor Portal Case wrapper should have been populated with the testCase values.'
        );
    }
}
