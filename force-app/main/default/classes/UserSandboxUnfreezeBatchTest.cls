@isTest
public class UserSandboxUnfreezeBatchTest {
    // Sets up test data. Creates test users and freezes their logins.
    @testSetup
    static void setup() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> users = new List<User>();

        // Determine which sandbox field to set based on SandboxHelper
        String sandboxField = SandboxHelper.sandboxFieldName;

        if (String.isBlank(sandboxField)) {
            System.debug('Sandbox field name is blank. Ensure the SandboxHelper is set up correctly.');
            return;
        }

        // Create a unique identifier for usernames
        String uniqueId = String.valueOf(System.currentTimeMillis()).right(5);

        // Create five users with the relevant sandbox field set to true and unique usernames
        users.add(
            new User(
                FirstName = 'Test',
                LastName = 'User1',
                Email = 'testuser1@example.com',
                Username = 'testuser1.' + uniqueId + '@example.com',
                Alias = 'tuser1',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                Sandbox_DEV__c = true,
                IsActive = true
            )
        );
        users.add(
            new User(
                FirstName = 'Test',
                LastName = 'User2',
                Email = 'testuser2@example.com',
                Username = 'testuser2.' + uniqueId + '@example.com',
                Alias = 'tuser2',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                Sandbox_DEV__c = true,
                IsActive = true
            )
        );
        users.add(
            new User(
                FirstName = 'Test',
                LastName = 'User3',
                Email = 'testuser3@example.com',
                Username = 'testuser3.' + uniqueId + '@example.com',
                Alias = 'tuser3',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                Sandbox_DEV__c = true,
                IsActive = true
            )
        );
        users.add(
            new User(
                FirstName = 'Test',
                LastName = 'User4',
                Email = 'testuser4@example.com',
                Username = 'testuser4.' + uniqueId + '@example.com',
                Alias = 'tuser4',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                Sandbox_DEV__c = true,
                IsActive = true
            )
        );
        users.add(
            new User(
                FirstName = 'Test',
                LastName = 'User5',
                Email = 'testuser5@example.com',
                Username = 'testuser5.' + uniqueId + '@example.com',
                Alias = 'tuser5',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                Sandbox_DEV__c = true,
                IsActive = true
            )
        );

        insert users;

        // Update the UserLogin records to set IsFrozen = true
        List<UserLogin> userLoginsToUpdate = new List<UserLogin>();
        for (User user : users) {
            UserLogin ul = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId = :user.Id LIMIT 1];
            ul.IsFrozen = true;
            userLoginsToUpdate.add(ul);
        }
        update userLoginsToUpdate;
    }

    // Tests the schedulable execution in production environment.
    @isTest
    static void testSchedulableExecutionInProduction() {
        // Mock production values
        SandboxHelper.isSandbox = false;
        SandboxHelper.sandboxName = '';

        // Query the specific users we created
        List<User> users = [SELECT Id FROM User WHERE Email LIKE 'testuser%.example.com%'];
        Set<Id> userIds = new Set<Id>();
        for (User user : users) {
            userIds.add(user.Id);
        }

        // Query UserLogin records for the specific users
        List<UserLogin> userLogins = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId IN :userIds];

        // Verify that the user logins are initially frozen
        for (UserLogin ul : userLogins) {
            System.assertEquals(true, ul.IsFrozen, 'UserLogin should be initially frozen.');
        }

        Test.startTest();
        UserSandboxUnfreezeBatch batch = new UserSandboxUnfreezeBatch();
        batch.execute(null);
        Test.stopTest();

        // Verify that the specific user logins remain frozen after the scheduled job runs
        userLogins = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId IN :userIds];
        for (UserLogin ul : userLogins) {
            System.assertEquals(
                true,
                ul.IsFrozen,
                'UserLogin should be frozen after schedulable execution in production.'
            );
        }
    }

    // Tests the schedulable execution in sandbox environment.
    @isTest
    static void testSchedulableExecutionInSandbox() {
        // Mock sandbox values
        SandboxHelper.isSandbox = true;
        SandboxHelper.sandboxName = 'dev';

        // Query the specific users we created
        List<User> users = [SELECT Id FROM User WHERE Email LIKE 'testuser%.example.com%'];
        Set<Id> userIds = new Set<Id>();
        for (User user : users) {
            userIds.add(user.Id);
        }

        // Query UserLogin records for the specific users
        List<UserLogin> userLogins = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId IN :userIds];

        // Verify that the user logins are initially frozen
        for (UserLogin ul : userLogins) {
            System.assertEquals(true, ul.IsFrozen, 'UserLogin should be initially frozen.');
        }

        Test.startTest();
        UserSandboxUnfreezeBatch batch = new UserSandboxUnfreezeBatch();
        batch.execute(null);
        Test.stopTest();

        // Verify that the specific user logins are unfrozen after the scheduled job runs
        userLogins = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId IN :userIds];
        for (UserLogin ul : userLogins) {
            System.assertEquals(
                false,
                ul.IsFrozen,
                'UserLogin should be unfrozen after schedulable execution in sandbox.'
            );
        }
    }

    // Tests the schedulable execution in an invalid sandbox environment.
    @isTest
    static void testSchedulableExecutionInvalidSandbox() {
        // A sandbox is "invalid" if it doesn't have a corresponding Sandbox_<ORGNAME>__c field

        // Mock sandbox values
        SandboxHelper.isSandbox = true;
        SandboxHelper.sandboxName = 'meow';

        // Query the specific users we created
        List<User> users = [SELECT Id FROM User WHERE Email LIKE 'testuser%.example.com%'];
        Set<Id> userIds = new Set<Id>();
        for (User user : users) {
            userIds.add(user.Id);
        }

        // Query UserLogin records for the specific users
        List<UserLogin> userLogins = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId IN :userIds];

        // Verify that the user logins are initially frozen
        for (UserLogin ul : userLogins) {
            System.assertEquals(true, ul.IsFrozen, 'UserLogin should be initially frozen.');
        }

        Test.startTest();
        UserSandboxUnfreezeBatch batch = new UserSandboxUnfreezeBatch();
        batch.execute(null);
        Test.stopTest();

        // Verify that the specific user logins remain frozen after the scheduled job runs
        userLogins = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId IN :userIds];
        for (UserLogin ul : userLogins) {
            System.assertEquals(
                true,
                ul.IsFrozen,
                'UserLogin should be frozen after schedulable execution in an invalid sandbox.'
            );
        }
    }
}