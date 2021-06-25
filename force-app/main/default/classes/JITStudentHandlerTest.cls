@isTest
public with sharing class JITStudentHandlerTest {
    @testSetup
    static void setUpData() {
        Contact testContact = ContactService.createTestContact();
        testContact.ASURite_ID__c = 'testJIT';

        insert testContact;
    }

    @isTest
    static void testServiceCenterUserCreation() {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');
        attributes.put('User.FirstName', 'Crazy');
        attributes.put('User.LastName', 'Test');

        JITStudentHandler jit = new JITStudentHandler();

        User testUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(testUser);
        System.assertNotEquals(null, testUser);
    }

    @isTest
    static void testServiceCenterUserCreationNoName() {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');

        JITStudentHandler jit = new JITStudentHandler();

        User testUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(testUser);
        System.assertNotEquals(null, testUser);
    }

    @isTest
    static void testServiceCenterDuplicateUser() {
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.FederationIdentifier', 'testJIT@asu.edu');
        attributes.put('User.FirstName', 'Testing');
        attributes.put('User.LastName', 'User');
        Map<String, String> attributesForDuplicate = new Map<String, String>();
        attributesForDuplicate.put('User.FederationIdentifier', 'testJIT@asu.edu');
        JITStudentHandler jit = new JITStudentHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);
        Database.upsert(runTestUser);

        User runTestUserDuplicate = jit.createUser(null, null, null, null, attributesForDuplicate, null);
        Database.upsert(runTestUserDuplicate);

        System.assertEquals(runTestUser.Id, runTestUserDuplicate.Id);

        System.debug(runTestUser);
        System.debug(runTestUserDuplicate);
    }

    @isTest
    static void testServiceCenterUserCreationNoFedID() {
        Map<String, String> attributes = new Map<String, String>();

        JITStudentHandler jit = new JITStudentHandler();

        User runTestUser = jit.createUser(null, null, null, null, attributes, null);

        System.debug(runTestUser);
        System.assertEquals(null, runTestUser);
    }
}
