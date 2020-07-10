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
        insert testCase;

        // Act
        Test.startTest();
        AdvisorPortalContact testAdvisorPortalContact = new AdvisorPortalContact([SELECT LastName FROM Contact WHERE Id = :testContact.Id]);
        testAdvisorPortalContact.addCase(new AdvisorPortalCase(testCase));
        Test.stopTest();

        // Assert
        System.assertEquals(false, testAdvisorPortalContact.isSelected, 'isSelected should default to false.');
        System.assertEquals(true, testAdvisorPortalContact.isOutreachCustomer, 'isOutreachCustomer should have been set to true.');
        System.assertEquals('Stark', testAdvisorPortalContact.portalContact.LastName, 'The Contact record should have been populated.');
        System.assertEquals(1, testAdvisorPortalContact.cases.size(), 'An Advisor Portal Case record should have been added.');
    }
}