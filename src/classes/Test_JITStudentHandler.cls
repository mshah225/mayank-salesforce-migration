@isTest
public with sharing class Test_JITStudentHandler
{
    @isTest static void testJITServiceCenterJustFedId()
    {
        Contact testContact = ContactService.createTestContact();
        testContact.ASURite_ID__c = 'testus';
        insert testContact;

        Map<String, String> chatterUserMap = new Map<String, String>();
        chatterUserMap.put('User.FederationIdentifier', 'testus@asu.edu');

        JITStudentHandler jit = new JITStudentHandler();

        Test.startTest();
        User testUser = jit.createUser(null, null, null, null, chatterUserMap, null);
        Test.stopTest();

        System.debug(testUser);
        System.assertNotEquals(null, testUser);
    }

    @isTest static void testServiceCenterUserCreation()
    {
        Map<String, String> chatterUserMap = new Map<String, String>();
        chatterUserMap.put('User.Username', 'thesetestresultsdoe@asu.edu');
        chatterUserMap.put('User.FederationIdentifier', 'testus@asu.edu');
        chatterUserMap.put('User.Email', 'testus@asu.edu');
        chatterUserMap.put('User.FirstName', 'Crazy');
        chatterUserMap.put('User.LastName', 'Test');

        JITStudentHandler jit = new JITStudentHandler();

        Test.startTest();
        User testUser = jit.createUser(null, null, null, null, chatterUserMap, null);
        Test.stopTest();

        System.debug(testUser);
        System.assertEquals('thesetestresultsdoe@asu.edu', testUser.UserName);
        System.assertEquals('Crazy', testUser.FirstName);
        System.assertEquals('Test', testUser.LastName);
    }
}