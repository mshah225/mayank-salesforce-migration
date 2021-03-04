/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-01-29
 *
 * Unit Tests for AdvisorPortalContact.cls
 */
@IsTest
private class AdvisorPortalContactTest {
    @IsTest
    private static void testCreateAdvisorPortalContact() {
        // Arrange
        Contact testContact = TestDataFactory.createContact('Stark');
        insert testContact;

        Case testCase = TestDataFactory.createCase('Test Case');
        testCase.Status = 'Outreach Required';
        testCase.ContactId = testContact.Id;

        Case testCase2 = TestDataFactory.createCase('Test Case 2');
        testCase2.Status = 'Outreach Required';
        testCase2.ContactId = testContact.Id;

        List<Case> testCases = new List<Case>();
        testCases.add(testCase);
        testCases.add(testCase2);

        insert testCases;

        // Act
        Test.startTest();
        AdvisorPortalContact testAdvisorPortalContact = new AdvisorPortalContact(
            [SELECT LastName FROM Contact WHERE Id = :testContact.Id]
        );
        testAdvisorPortalContact.addCase(new AdvisorPortalCase(testCase));
        testAdvisorPortalContact.addCases(new List<AdvisorPortalCase>{ new AdvisorPortalCase(testCase2) });
        Test.stopTest();

        // Assert
        System.assertEquals(false, testAdvisorPortalContact.isSelected, 'isSelected should default to false.');
        System.assertEquals(
            true,
            testAdvisorPortalContact.isOutreachCustomer,
            'isOutreachCustomer should have been set to true.'
        );
        System.assertEquals(
            'Stark',
            testAdvisorPortalContact.portalContact.LastName,
            'The Contact record should have been populated.'
        );
        System.assertEquals(
            2,
            testAdvisorPortalContact.cases.size(),
            '2 Advisor Portal Case records should have been added.'
        );
        System.assertEquals(
            2,
            testAdvisorPortalContact.getCases().size(),
            '2 Advisor Portal Case records should have been added.'
        );
    }
}
