@isTest
public class SandboxHelperTest {
    // Unique ID for the test user to avoid conflicts
    private static String uniqueId = String.valueOf(System.currentTimeMillis()).right(5);

    // Sets up test data. Creates a test user with the necessary profile and attributes.
    @testSetup
    static void setup() {
        // Create a test user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
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
        );
        insert testUser;
    }

    // Tests the isSandbox method of the SandboxHelper class.
    @isTest
    static void testIsSandbox() {
        // Test for sandbox environment
        Test.startTest();
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.assertEquals(isSandbox, SandboxHelper.isSandbox, 'Expected isSandbox to be ' + isSandbox + '.');
        Test.stopTest();
    }

    // Tests the sandboxName method of the SandboxHelper class.
    @isTest
    static void testSandboxName() {
        // Mocking the actual sandbox name dynamically based on the environment
        Test.startTest();
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        if (isSandbox) {
            String expectedSandboxName = System.DomainParser.parse(URL.getOrgDomainUrl().toExternalForm())
                .getSandboxName();
            System.assertEquals(
                expectedSandboxName,
                SandboxHelper.sandboxName,
                'Expected sandboxName to be "' + expectedSandboxName + '".'
            );
        } else {
            System.assertEquals('', SandboxHelper.sandboxName, 'Expected sandboxName to be an empty string.');
        }

        Test.stopTest();
    }

    // Tests the sandboxInstanceName method of the SandboxHelper class.
    @isTest
    static void testSandboxInstanceName() {
        Test.startTest();
        String instanceName = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
        System.assertEquals(
            instanceName,
            SandboxHelper.sandboxInstanceName,
            'Expected sandboxInstanceName to be ' + instanceName + '.'
        );
        Test.stopTest();
    }

    // Tests the hasValidSandboxField method of the SandboxHelper class.
    @isTest
    static void testHasValidSandboxField() {
        Test.startTest();

        Boolean hasField = ObjectHelper.fieldExistsOnObject('User', SandboxHelper.sandboxFieldName);
        System.assertEquals(
            hasField,
            SandboxHelper.hasValidSandboxField,
            'Expected hasValidSandboxField to be ' + hasField + '.'
        );

        Test.stopTest();
    }

    // Tests the sandboxFieldName method of the SandboxHelper class.
    @isTest
    static void testSandboxFieldName() {
        Test.startTest();
        String sandboxName = 'dev';
        SandboxHelper.sandboxName = sandboxName;
        System.assertEquals(
            'Sandbox_' + sandboxName.toUpperCase() + '__c',
            SandboxHelper.sandboxFieldName,
            'Expected sandboxFieldName to be "Sandbox_DEV__c".'
        );
        Test.stopTest();
    }
}