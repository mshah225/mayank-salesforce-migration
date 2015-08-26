@isTest
public with sharing class Test_JITUserHandler
{
    @isTest static void testChatterFreeUserCreationJustFedId()
    {
        Contact testContact = ContactService.createTestContact();
        testContact.ASURite_ID__c = 'testus';
        insert testContact;

        Map<String, String> chatterUserMap = new Map<String, String>();
        chatterUserMap.put('User.FederationIdentifier', 'testus@asu.edu');

        JITUserHandler jit = new JITUserHandler();

        Test.startTest();
        User testUser = jit.createUser(null, null, null, null, chatterUserMap, null);
        Test.stopTest();

        System.debug(testUser);
        System.assertNotEquals(null, testUser);
    }

    @isTest static void testChatterFreeUserCreation()
    {
        Map<String, String> chatterUserMap = new Map<String, String>();
        chatterUserMap.put('User.Username', 'thesetestresultsdoe@asu.edu');
        chatterUserMap.put('User.FederationIdentifier', 'testus@asu.edu');
        chatterUserMap.put('User.Email', 'testus@asu.edu');
        chatterUserMap.put('User.FirstName', 'Crazy');
        chatterUserMap.put('User.LastName', 'Test');

        JITUserHandler jit = new JITUserHandler();

        Test.startTest();
        User testUser = jit.createUser(null, null, null, null, chatterUserMap, null);
        Test.stopTest();

        System.debug(testUser);
        System.assertEquals('thesetestresultsdoe@asu.edu', testUser.UserName);
        System.assertEquals('Crazy', testUser.FirstName);
        System.assertEquals('Test', testUser.LastName);
    }

    @isTest static void testDupeCheck()
    {
        User dupeUser = UserService.createTestUser();
        dupeUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU View All Data'].Id;
        dupeUser.FederationIdentifier = 'testus@admin.asu.edu';
        insert dupeUser;

        Map<String, String> chatterUserMap = new Map<String, String>();
        chatterUserMap.put('User.Username', 'thesetestresultsdoe@asu.edu');
        chatterUserMap.put('User.FederationIdentifier', 'testus@asu.edu');
        chatterUserMap.put('User.Email', 'testus@asu.edu');
        chatterUserMap.put('User.FirstName', 'Crazy');
        chatterUserMap.put('User.LastName', 'Test');

        JITUserHandler jit = new JITUserHandler();

        Test.startTest();
        User testUser = jit.createUser(null, null, null, null, chatterUserMap, null);
        Test.stopTest();

        System.debug(testUser);
        System.assertEquals('test.user@test.example.com', testUser.UserName);
    }
}