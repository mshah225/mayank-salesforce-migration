/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-02-12
 *
 * Unit Tests for AdvisorPortalMassTransferController
 */
@IsTest
private class AdvisorPortalMassTransferControllerTest {
    @TestSetup
    static void setUpTest() {
        User testUser = TestDataFactory.createUser('Testing', [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id);
        insert testUser;
    }

    @IsTest
    static void testTransferCases() {
        // Arrange
        Contact testContact = TestDataFactory.createContact('Stark');
        insert testContact;

        List<Case> testCases = TestDataFactory.createCases(5);
        for (Case testCase : testCases) {
            testCase.ContactId = testContact.Id;
        }
        insert testCases;

        // Act
        Test.startTest();
        AdvisorPortalMassTransferController.transferCases(
            testCases,
            [SELECT Id FROM User WHERE LastName = 'Testing']
            .Id
        );
        Test.stopTest();

        // Assert
        User assertUser = [SELECT Id FROM User WHERE LastName = 'Testing'];
        List<Case> assertCases = [SELECT OwnerId FROM Case];
        for (Case assertCase : assertCases) {
            System.assertEquals(
                assertUser.Id,
                assertCase.OwnerId,
                'The case should have been transferred to the Test User.'
            );
        }
    }
}
