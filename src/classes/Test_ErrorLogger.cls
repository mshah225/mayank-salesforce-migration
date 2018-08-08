@isTest
public class Test_ErrorLogger {
    private static Exception ex;
    private static User userWithContact;
    private static User userWithoutContact;
    private static User siteGuestUser;
    private static List<String> vars;
    private static Map<Id,User> userMap;
    private static List<Case> exceptionCases;
    private static String subject;
    private static Boolean debug;

    @testSetup
    static void setup() {
        List<lead> testLeads = TestDataFactory.createLeads(3);
        insert testLeads;

        Contact testContact = TestDataFactory.createContact('contactForUser');
        insert testContact;

        User userWithContact = TestDataFactory.createCommunityUser('CommunityUser',testContact.Id);
        insert userWithContact;

        Id profileId = [SELECT Id FROM Profile WHERE name = 'ASU Service - ASU Salesforce Support'].Id;
        User userWithoutContact = TestDataFactory.createUser('UserWithoutContact', profileId);
        insert userWithoutContact;

        profileId = [SELECT Id FROM Profile WHERE name = 'My ASU Profile'].Id;
        User siteGuestUser = TestDataFactory.createUser('siteGuestUser', profileId);
        insert siteGuestUser;
    }

    private static void setupTestVariables() {
        ex = TestDataFactory.createException();
        userWithContact = [SELECT Id, contactId FROM User WHERE lastName = 'CommunityUser'];
        userWithoutContact = [SELECT Id FROM User WHERE lastName = 'UserWithoutContact'];
        siteGuestUser = [SELECT Id FROM User WHERE lastName = 'siteGuestUser'];
        vars = new List<String>();
        userMap = new Map<Id,User>();
        subject = 'Apex Exception: ' + ex.getTypeName() + ' Date: ' + System.today();

        userMap.put(userWithContact.Id, userWithContact);
        userMap.put(userWithoutContact.Id, userWithoutContact);

        vars.add(ErrorLogger.convertBooleanToJSON('boolean', true));
        vars.add(ErrorLogger.convertIntegerToJSON('integer', 1));
        vars.add(ErrorLogger.convertStringToJSON('string', 'true'));
        vars.add(ErrorLogger.convertMapToJSON('userMap',userMap));
    }

    @isTest
    private static void checkDebugWithoutCaseForUserWithContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithContact) {
            debug = ErrorLogger.log(ex, vars, true);
        }
        Test.stopTest();

        System.assertEquals(false, debug);
    }

    @isTest
    private static void checkDebugWithCaseForUserWithContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithContact) {
            debug = ErrorLogger.log(ex, vars, false);
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, userWithContact.contactId);
    }

    @isTest
    public static void checkDuplicateDebugCaseForUserWithContact(){
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithContact) {
            ErrorLogger.log(ex, vars, false);
            debug = ErrorLogger.log(ex, vars, false);
        }
        Test.stopTest();
        System.assertEquals(false, debug);
        validateCreatedCaseAndContactId(1, userWithContact.contactId);
    }

    @isTest
    private static void checkDebugWithoutCaseForUserWithoutContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            debug = ErrorLogger.log(ex, vars, true);
        }
        Test.stopTest();

        System.assertEquals(false, debug);
    }

    @isTest
    private static void checkDebugWithCaseForUserWithoutContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            debug = ErrorLogger.log(ex, vars, false);
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, null);
    }

    @isTest
    public static void checkDuplicateDebugCaseForUserWithoutContact(){
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            ErrorLogger.log(ex, vars, false);
            debug = ErrorLogger.log(ex, vars, false);
        }
        Test.stopTest();
        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(2, null);
    }

    @isTest
    private static void checkDebugWithoutCaseForSiteGuestUser() {
        setupTestVariables();

        Test.startTest();
        System.runAs(siteGuestUser) {
            debug = ErrorLogger.log(ex, vars, true);
        }
        Test.stopTest();

        System.assertEquals(false, debug);
    }

    @isTest
    private static void checkDebugWithCaseForSiteGuestUser() {
        setupTestVariables();

        Test.startTest();
        System.runAs(siteGuestUser) {
            debug = ErrorLogger.log(ex, vars, false);
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, null);
    }

    @isTest
    private static void checkDuplicateDebugCaseForSiteGuestUser() {
        setupTestVariables();

        Test.startTest();
        System.runAs(siteGuestUser) {
            ErrorLogger.log(ex, vars, false);
            debug = ErrorLogger.log(ex, vars, false);
        }
        Test.stopTest();
        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(2, null);
    }

    @isTest
    private static void checkErrorLoggerExceptionHandler() {
        setupTestVariables();

        Test.startTest();
        debug = ErrorLogger.log(ex, vars, false, null, null);
        Test.stopTest();

        System.assertEquals(null, debug);
    }

    @isTest
    private static void checkPassedInContactId() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            debug = ErrorLogger.log(ex, vars, false, userWithContact.contactId);
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, userWithContact.contactId);
    }

    private static void validateCreatedCaseAndContactId(Integer numberOfCasesCreated, Id caseContactId) {
        List<Case> exceptionCases;

        exceptionCases = [SELECT Id, ContactId FROM Case WHERE Subject = :subject];
        if (exceptionCases != null) {
            System.assertEquals(numberOfCasesCreated, exceptionCases.size());
        }
        System.debug(exceptionCases);

        if (exceptionCases.size() > 0) {
            for (Case c : exceptionCases) {
                System.assertEquals(caseContactId, c.contactId);
            }

        }
        delete exceptionCases;
    }

    /**
     * Tests for converting SObjects to JSON strings
     */
    public static testmethod void Test_convertSObjectToJSON() {
        string fakeName = 'SObject';
        Lead fakeValue = [SELECT Id FROM Lead LIMIT 1];
        string result = ErrorLogger.convertSObjectToJSON(fakeName, fakeValue);
        string expected = '{' + fakeName + ':{' + String.valueOf(fakeValue) + '}}';

        system.assertEquals(expected, result);
    }

    /**
     * Tests for converting Id values to JSON strings
     */
    public static testmethod void Test_convertIdToJSON() {
        string fakeName = 'objectId';
        Id fakeValue = userinfo.getUserId();
        string result = ErrorLogger.convertIdToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting Double values to JSON strings
     */
    public static testmethod void Test_convertDoubleToJSON() {
        string fakeName = 'myBankAccount';
        double fakeValue = 0.00;
        string result = ErrorLogger.convertDoubleToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting Integer values to JSON strings
     */
    public static testmethod void Test_convertIntegerToJSON() {
        string fakeName = 'longestRelationshipInDays';
        integer fakeValue = 3;
        string result = ErrorLogger.convertIntegerToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting Boolean values to JSON strings
     */
    public static testmethod void Test_convertBooleanToJSON() {
        string fakeName = 'amIGettingFiredForDoingThis';
        boolean fakeValue = true;
        string result = ErrorLogger.convertBooleanToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting maps to JSON strings - ID to Integer overload
     */
    public static testmethod void Test_convertMapToJSON_Id_To_Int() {
        string expected;
        string result;
        string fakeName = 'leadMap';
        Map<Id,Integer> fakeMap;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null map
        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected,result);

        // Test 2 - validate a non-null map with 0 entries
        fakeMap = new Map<Id,Integer>();

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected,result);

        // Test 3 - validate a non null map containing 3 values
        for (Lead l : testLeads) {
            fakeMap.put(l.Id,1);
        }

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeMap) + ']}';
        system.assertEquals(expected,result);
    }

    /**
     * Tests for converting maps to JSON strings - ID to SObject overload
     */
    public static testmethod void Test_convertMapToJSON_Id_To_SObject() {
        string expected;
        string result;
        string fakeName = 'leadMap';
        Map<Id,Lead> fakeMap;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null map
        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected,result);

        // Test 2 - validate a non-null map with 0 entries
        fakeMap = new Map<Id,Lead>();

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected,result);

        // Test 3 - validate a non null map containing 3 values
        for (Lead l : testLeads) {
            fakeMap.put(l.Id,l);
        }

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeMap) + ']}';
        system.assertEquals(expected,result);
    }

    /**
     * Tests for converting sets to JSON strings - ID overload
     */
    public static testmethod void Test_convertSetToJSON_Id() {
        string expected;
        string result;
        string fakeName = 'leadSet';
        Set<Id> fakeSet;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null set
        result = ErrorLogger.convertSetToJSON(fakeName, fakeSet);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected,result);

        // Test 2 - validate a non-null set with 0 entries
        fakeSet = new Set<Id>();

        result = ErrorLogger.convertSetToJSON(fakeName, fakeSet);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected,result);

        // Test 3 - validate a non null set containing 3 values
        for (Lead l : testLeads) {
            fakeSet.add(l.Id);
        }

        result = ErrorLogger.convertSetToJSON(fakeName, fakeSet);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeSet) + ']}';
        system.assertEquals(expected,result);
    }

    /**
     * Tests for converting lists to JSON strings - ID overload
     */
    public static testmethod void Test_convertListToJSON_Id() {
        string expected;
        string result;
        string fakeName = 'leadList';
        List<Id> fakeList;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null set
        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected,result);

        // Test 2 - validate a non-null set with 0 entries
        fakeList = new List<Id>();

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected,result);

        // Test 3 - validate a non null set containing 3 values
        for (Lead l : testLeads) {
            fakeList.add(l.Id);
        }

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeList) + ']}';
        system.assertEquals(expected,result);
    }

    /**
     * Tests for converting lists to JSON strings - SObject overload
     */
    public static testmethod void Test_convertListToJSON_SObject() {
        string expected;
        string result;
        string fakeName = 'leadList';
        List<Lead> fakeList;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null set
        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected,result);

        // Test 2 - validate a non-null set with 0 entries
        fakeList = new List<Lead>();

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected,result);

        // Test 3 - validate a non null set containing 3 values
        fakeList = testLeads;

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeList) + ']}';
        system.assertEquals(expected,result);
    }

    public static testmethod void Test_CreateDefaultCar() {
        List<Case_Assignment_Rule__c> cars;

        // Test to see if Car is being created correctly.
        delete [SELECT Id FROM Case_Assignment_Rule__c WHERE Origin__c = 'Error Logger'];
        insert ErrorLogger.createDefaultCar();

        cars = [SELECT Id FROM Case_Assignment_Rule__c WHERE Origin__c = 'Error Logger'];

        system.assertEquals(1, cars.size());

        // Test to see if the car is created again, with a different priority
        insert ErrorLogger.createDefaultCar();

        cars = [SELECT Priority__c FROM Case_Assignment_Rule__c WHERE Origin__c = 'Error Logger' ORDER BY Priority__c DESC];

        system.assertEquals(2, cars.size());
        system.assertEquals(2, integer.valueOf(cars[0].priority__c));
    }
}
