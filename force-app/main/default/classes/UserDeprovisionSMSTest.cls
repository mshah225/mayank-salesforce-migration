/**
 * This is a second test class for the user deprovisioner specifically for testing all the SMS-related stuff during user deprovisioning.
 *
 * SMS Magic has a bunch of weird restrictions with creating test data, it isn't documented HOW to do it, and it's tough to determine
 * precisely how to do it... so instead of creating a test user, we instead use SeeAllData=true and find an existing user and use them.
 *
 * If you use SeeAllData for ANY methods, then you can no longer use a @TestSetup method to setup test data.  If we do this and then use a
 * static testSetup method, we are more likely to have governor issues, mixed DML issues, and future/queueable issues. So to isolate these
 * issues, these tests are a separate file.
 */
@isTest
public class UserDeprovisionSMSTest {
    private static User findTestUser() {
        Set<Id> hasLicense = new Set<Id>();
        for (smagicinteract__License__c license : [
            SELECT smagicinteract__User__c
            FROM smagicinteract__License__c
            WHERE Active__c = TRUE AND smagicinteract__Status__c = TRUE
        ]) {
            hasLicense.add(license.smagicinteract__User__c);
        }

        Set<Id> hasSenderIdAssigned = new Set<Id>();
        for (smagicinteract__SenderId_Profile_Map__c senderIdAssignment : [
            SELECT smagicinteract__User__c
            FROM smagicinteract__SenderId_Profile_Map__c
        ]) {
            hasSenderIdAssigned.add(senderIdAssignment.smagicinteract__User__c);
        }

        Set<Id> hasVisibilities = new Set<Id>();
        for (smagicinteract__Sender_Visibility__c visibility : [
            SELECT smagicinteract__User__c
            FROM smagicinteract__Sender_Visibility__c
        ]) {
            hasVisibilities.add(visibility.smagicinteract__User__c);
        }

        List<User> goodOptions = [
            SELECT Id, Deprovision_User__c
            FROM User
            WHERE Id IN :hasLicense AND Id IN :hasSenderIdAssigned AND Id IN :hasVisibilities
        ];

        if (goodOptions.isEmpty())
            return null;

        User useMe = goodOptions[0];

        // Ensure user is allowed to be deprovisioned
        useMe.Sandbox_Delagated_Administrator__c = false;
        useMe.Role_Administrator_Developer__c = false;
        update useMe;

        // Minimal config
        UserDeprovisionOrganizer.deprovisionUserConfiguration = new Map<String, Deprovision_User_Configuration__c>{
            'Change UserRoleId To' => new Deprovision_User_Configuration__c(
                Name = 'Change UserRoleId To',
                Id__c = '00Ed00000017bQ5EAI',
                Name__c = 'Z Unassigned (Temporary Role)'
            ),
            'Change ProfileId To' => new Deprovision_User_Configuration__c(
                Name = 'Change ProfileId To',
                Id__c = '00ed00000019yCpAAI',
                Name__c = 'ASU Chatter User'
            )
        };

        return useMe;
    }

    @isTest(SeeAllData=true)
    public static void testUnassignSMSLicense() {
        // Find a user configured for SMS Magic
        User testUser = findTestUser();

        // No test user found in environment - cannot run these tests :(
        if (testUser == null)
            return;

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        // Check they have an SMS license and sender id assignment
        List<smagicinteract__SenderId_Profile_Map__c> senderIdAssignments = [
            SELECT Id, smagicinteract__senderid_lookup__r.Id
            FROM smagicinteract__SenderId_Profile_Map__c
            WHERE smagicinteract__User__c = :testUser.Id
        ];
        List<smagicinteract__SMS_SenderId__c> senderIds = new List<smagicinteract__SMS_SenderId__c>();
        for (smagicinteract__SenderId_Profile_Map__c senderIdAssignment : senderIdAssignments) {
            senderIds.add(senderIdAssignment.smagicinteract__senderid_lookup__r);
        }
        List<smagicinteract__Sender_Visibility__c> senderVisibilities = [
            SELECT Id
            FROM smagicinteract__Sender_Visibility__c
            WHERE smagicinteract__User__c = :testUser.Id
        ];
        List<smagicinteract__License__c> smsLicenses = [
            SELECT Id
            FROM smagicinteract__License__c
            WHERE smagicinteract__User__c = :testUser.Id
        ];

        Integer senderIdCount = senderIdAssignments.size(), senderVisibilityCount = senderVisibilities.size();

        // Do it
        Test.startTest();
        update testUser;
        Test.stopTest();

        // Get updated user
        testUser = [SELECT Id, FirstName, LastName, Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Check sender id was renamed
        senderIds = [
            SELECT Id, smagicinteract__Label__c
            FROM smagicinteract__SMS_SenderId__c
            WHERE Id IN :new Map<Id, smagicinteract__SMS_SenderId__c>(senderIds).keySet()
        ];
        Assert.isFalse(senderIds.isEmpty(), 'Should NOT have deleted SMS Sender Ids');
        for (smagicinteract__SMS_SenderId__c senderId : senderIds) {
            Assert.isFalse(
                senderId.smagicinteract__Label__c.contains(testUser.FirstName + ' ' + testUser.LastName),
                'SMS Sender Id should have been renamed to remove user\'s name, but it was not'
            );
        }

        // Check Sender Id assignment was deleted
        senderIdAssignments = [
            SELECT Id, smagicinteract__senderid_lookup__r.smagicinteract__senderId__c
            FROM smagicinteract__SenderId_Profile_Map__c
            WHERE Id IN :new Map<Id, smagicinteract__SenderId_Profile_Map__c>(senderIdAssignments).keySet()
        ];
        Assert.isTrue(senderIdAssignments.isEmpty(), 'Should have deleted user-sender id mappings');
        // and processing notes indicate user was unassigned
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Unassigned ' + senderIdCount + ' Sender Ids'),
            'Number of sender ids unassigned should be recorded on the user'
        );
        // Includes each phone number
        for (smagicinteract__SenderId_Profile_Map__c senderIdAssignment : senderIdAssignments) {
            Assert.isTrue(
                testUser.Processing_Notes__c.contains(
                    senderIdAssignment.smagicinteract__senderid_lookup__r.smagicinteract__senderId__c
                ),
                'Should contain phone numbers for sender ids that were removed, but is missing this one'
            );
        }

        // Removed sender visbilities
        senderVisibilities = [
            SELECT Id
            FROM smagicinteract__Sender_Visibility__c
            WHERE Id IN :new Map<Id, smagicinteract__Sender_Visibility__c>(senderVisibilities).keySet()
        ];
        Assert.isTrue(senderIdAssignments.isEmpty(), 'Should have deleted user-sender id mappings');
        // and processing notes indicate SMS licenses were removed
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Removed ' + senderVisibilityCount + ' Sender Visibilities'),
            'Number of Sender Visibilities removed should be recorded on the user'
        );

        // License was deactivated
        smsLicenses = [
            SELECT Id, Active__c
            FROM smagicinteract__License__c
            WHERE Id IN :new Map<Id, smagicinteract__License__c>(smsLicenses).keySet()
        ];

        Assert.isFalse(smsLicenses.isEmpty(), 'Should NOT have deleted SMS licenses');
        for (smagicinteract__License__c smsLicense : smsLicenses) {
            Assert.isFalse(smsLicense.Active__c, 'License should have been deactivated but it was not');
        }
        // and processing notes indicate SMS licenses were removed
        Assert.isTrue(
            testUser.Processing_Notes__c.contains('Removed ' + smsLicenses.size() + ' SMS Licenses'),
            'Number of SMS licenses removed should be recorded on the user'
        );
    }

    @isTest(SeeAllData=true)
    public static void testErrorUnassigningSenderId() {
        // Find a user configured for SMS Magic
        User testUser = findTestUser();

        // No test user found in environment - cannot run these tests :(
        if (testUser == null)
            return;

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        Datetime startTime = System.now();

        // Do it
        Test.startTest();

        update testUser;

        // Delete data the deprovisioners rely on
        System.runAs(new User(Id = UserInfo.getUserId())) {
            delete UserDeprovisionOrganizer.getSMSMagicSenderIdsAssignments(new List<Id>{ testUser.Id })
                .get(testUser.Id);
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Error while deleting the smagicinteract__SenderId_Profile_Map__c objects during user deprovisioning'
            ),
            'Should contain exception details on user, but instead said ' + testUser.Processing_Notes__c
        );

        // Check for error logger case
        List<Case> errorLoggerCases = [
            SELECT Id, Subject, Description
            FROM Case
            WHERE
                Subject LIKE 'Apex Exception: UserDeprovisionOrganizer.DatabaseErrorException%'
                AND CreatedDate = TODAY
            ORDER BY CreatedDate DESC
        ];

        // Need to search since with ViewAllData there are other ErrorLogger cases we need to ignore
        Boolean createdErrorCase = false;
        for (Case errorLoggerCase : errorLoggerCases) {
            if (errorLoggerCase.Description.contains('smagicinteract__SenderId_Profile_Map__c')) {
                createdErrorCase = true;
                break;
            }
        }

        Assert.isTrue(
            createdErrorCase,
            'Should have created error logger case with object type in description, but it did not'
        );
    }

    @isTest(SeeAllData=true)
    public static void testErrorRemovingSenderVisbilities() {
        // Find a user configured for SMS Magic
        User testUser = findTestUser();

        // No test user found in environment - cannot run these tests :(
        if (testUser == null)
            return;

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        Datetime startTime = System.now();

        // Do it
        Test.startTest();

        update testUser;

        // Delete data the deprovisioners rely on
        System.runAs(new User(Id = UserInfo.getUserId())) {
            delete UserDeprovisionOrganizer.getSMSMagicSenderVisbilities(new List<Id>{ testUser.Id }).get(testUser.Id);
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Error while deleting the smagicinteract__Sender_Visibility__c objects during user deprovisioning'
            ),
            'Should contain exception details on user, but instead said ' + testUser.Processing_Notes__c
        );

        // Check for error logger case
        List<Case> errorLoggerCases = [
            SELECT Id, Subject, Description
            FROM Case
            WHERE
                Subject LIKE 'Apex Exception: UserDeprovisionOrganizer.DatabaseErrorException%'
                AND CreatedDate = TODAY
            ORDER BY CreatedDate DESC
        ];

        // Need to search since with ViewAllData there are other ErrorLogger cases we need to ignore
        Boolean createdErrorCase = false;
        for (Case errorLoggerCase : errorLoggerCases) {
            if (errorLoggerCase.Description.contains('smagicinteract__Sender_Visibility__c')) {
                createdErrorCase = true;
                break;
            }
        }

        Assert.isTrue(
            createdErrorCase,
            'Should have created error logger case with object type in description, but it did not'
        );
    }

    @isTest(SeeAllData=true)
    public static void testErrorDeactivatingSmsLicense() {
        // Find a user configured for SMS Magic
        User testUser = findTestUser();

        // No test user found in environment - cannot run these tests :(
        if (testUser == null)
            return;

        // Mark as needing to deprovision
        testUser.Deprovision_User__c = true;

        UserDeprovisioner.FORCE_LOCK = true; // Prevent deprovisioners from refreshing data

        Datetime startTime = System.now();

        // Do it
        Test.startTest();

        update testUser;

        // Delete data the deprovisioners rely on
        System.runAs(new User(Id = UserInfo.getUserId())) {
            delete UserDeprovisionOrganizer.getSMSMagicLicenses(new List<Id>{ testUser.Id }).get(testUser.Id);
        }

        Test.stopTest();

        // Get updated user
        testUser = [SELECT Processing_Notes__c FROM User WHERE Id = :testUser.Id];

        // Processing notes were updated to include error details
        Assert.isTrue(
            testUser.Processing_Notes__c.contains(
                'Error while updating the smagicinteract__License__c objects during user deprovisioning'
            ),
            'Should contain exception details on user, but instead said ' + testUser.Processing_Notes__c
        );

        // Check for error logger case
        List<Case> errorLoggerCases = [
            SELECT Id, Subject, Description
            FROM Case
            WHERE
                Subject LIKE 'Apex Exception: UserDeprovisionOrganizer.DatabaseErrorException%'
                AND CreatedDate = TODAY
            ORDER BY CreatedDate DESC
        ];

        // Need to search since with ViewAllData there are other ErrorLogger cases we need to ignore
        Boolean createdErrorCase = false;
        for (Case errorLoggerCase : errorLoggerCases) {
            if (errorLoggerCase.Description.contains('smagicinteract__License__c')) {
                createdErrorCase = true;
                break;
            }
        }

        Assert.isTrue(
            createdErrorCase,
            'Should have created error logger case with object type in description, but it did not'
        );
    }
}