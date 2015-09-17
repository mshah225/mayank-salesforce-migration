@IsTest
private class Test_JITUserHandler
{
    @testSetup static void createTestData()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User testUser = UserService.createTestUser();
        testUser.ProfileId = p.Id;

        insert testUser;

        Contact testContact = ContactService.createTestContact();
        testContact.ASURite_ID__c = 'testJIT';

        insert testContact;
    }

    @isTest static void testUserCreation()
    {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');
        attributes.put('User.FirstName', 'Testing');
        attributes.put('User.LastName', 'User');

        JITUserHandler jit = new JITUserHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(runTestUser);
        System.assertNotEquals(null, runTestUser);
    }

    @isTest static void testUserCreationNoName()
    {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');

        JITUserHandler jit = new JITUserHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(runTestUser);
        System.assertNotEquals(null, runTestUser);
    }
}