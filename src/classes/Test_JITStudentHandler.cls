@isTest
public with sharing class Test_JITStudentHandler
{
    @testSetup static void setUpData()
    {
        Contact testContact = ContactService.createTestContact();
        testContact.ASURite_ID__c = 'testJIT';

        insert testContact;
    }

    @isTest static void testJITServiceCenterJustFedId()
    {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');

        JITStudentHandler jit = new JITStudentHandler();

        User testUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(testUser);
        System.assertNotEquals(null, testUser);
    }

    @isTest static void testServiceCenterUserCreation()
    {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');
        attributes.put('User.FirstName', 'Crazy');
        attributes.put('User.LastName', 'Test');

        JITStudentHandler jit = new JITStudentHandler();

        User testUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(testUser);
        System.assertNotEquals(null, testUser);
    }
}