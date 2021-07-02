@IsTest
private class JITUserHandlerTest {
    @testSetup
    static void createTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        User testUser = (User) userCreator.create(1)[0];
        testUser.ProfileId = p.Id;

        insert testUser;

        Contact testContact = ContactService.createTestContact();
        testContact.ASURite_ID__c = 'testJIT';

        insert testContact;
    }

    @isTest
    static void testUserCreation() {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');
        attributes.put('User.FirstName', 'Testing');
        attributes.put('User.LastName', 'User');

        JITUserHandler jit = new JITUserHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(runTestUser);
        System.assertNotEquals(null, runTestUser);
    }

    @isTest
    static void testUserCreationNoName() {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');

        JITUserHandler jit = new JITUserHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(runTestUser);
        System.assertNotEquals(null, runTestUser);
    }

    @isTest
    static void testDuplicateUser() {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');
        attributes.put('User.FirstName', 'Testing');
        attributes.put('User.LastName', 'User');
        Map<String, String> attributesForDuplicate = new Map<String, String>();
        attributesForDuplicate.put('User.FederationIdentifier', 'testJIT@asu.edu');
        JITUserHandler jit = new JITUserHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);
        Database.upsert(runTestUser);

        User runTestUserDuplicate = jit.createUser(null, null, null, null, attributesForDuplicate, null);
        Database.upsert(runTestUserDuplicate);

        System.assertEquals(runTestUser.Id, runTestUserDuplicate.Id);

        System.debug(runTestUser);
        System.debug(runTestUserDuplicate);
    }

    @isTest
    static void testUserCreationNoFedID() {
        Map<String, String> attributes = new Map<String, String>();

        JITUserHandler jit = new JITUserHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(runTestUser);
        System.assertEquals(null, runTestUser);
    }
}
