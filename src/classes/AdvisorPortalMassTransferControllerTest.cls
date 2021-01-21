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

    @IsTest
    static void testCheckIfAllowedToUse() {
        User allowedUser1 = TestDataFactory.createUser(
            'test-mass-transfer-r1',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        User allowedUser2 = TestDataFactory.createUser(
            'test-mass-transfer-r2',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        User unallowedUser1 = TestDataFactory.createUser(
            'test-mass-transfer-r3',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );

        User unallowedUser2 = TestDataFactory.createUser(
            'test-mass-transfer-r4',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );

        User unallowedUser3 = TestDataFactory.createUser(
            'test-mass-transfer-r5',
            [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        insert new List<User>{ allowedUser1, allowedUser2, unallowedUser1, unallowedUser2, unallowedUser3 };

        Success_Resource__c allowedUser1Resource = new Success_Resource__c(
            Resource__c = allowedUser1.Id,
            Role__c = 'Department Manager',
            IsActive__c = true,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        Success_Resource__c allowedUser2Resource = new Success_Resource__c(
            Resource__c = allowedUser2.Id,
            Role__c = 'College Manager',
            IsActive__c = true,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        Success_Resource__c unallowedUserResource1 = new Success_Resource__c(
            Resource__c = unallowedUser1.Id,
            Role__c = 'User',
            IsActive__c = true,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        Success_Resource__c unallowedUserResource2 = new Success_Resource__c(
            Resource__c = unallowedUser2.Id,
            Role__c = 'College Manager',
            IsActive__c = false,
            RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        insert new List<Success_Resource__c>{
            allowedUser1Resource,
            allowedUser2Resource,
            unallowedUserResource1,
            unallowedUserResource2
        };

        System.runAs(allowedUser1) {
            Boolean isAllowed = AdvisorPortalMassTransferController.checkIfAllowedToUse();
            System.assert(isAllowed, 'Department Manager\'s should be allowed to use this feature');
        }
        System.runAs(allowedUser2) {
            Boolean isAllowed = AdvisorPortalMassTransferController.checkIfAllowedToUse();
            System.assert(isAllowed, 'College Manager\'s should be allowed to use this feature');
        }
        System.runAs(unallowedUser1) {
            Boolean isAllowed = AdvisorPortalMassTransferController.checkIfAllowedToUse();
            System.assert(!isAllowed, 'User\'s should not be allowed to use this feature');
        }
        System.runAs(unallowedUser2) {
            Boolean isAllowed = AdvisorPortalMassTransferController.checkIfAllowedToUse();
            System.assert(!isAllowed, 'Should not consider inactive Success_Resources');
        }
        System.runAs(unallowedUser3) {
            Boolean isAllowed = AdvisorPortalMassTransferController.checkIfAllowedToUse();
            System.assert(!isAllowed, 'Default (if no Success_Resources) should be to not allow');
        }
    }
}
