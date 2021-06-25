@isTest
public class ErrorLoggerTest {
    private static Exception ex;
    private static User userWithContact;
    private static User userWithoutContact;
    private static User siteGuestUser;
    private static Map<Id, User> userMap;
    private static List<Case> exceptionCases;
    private static String subject;
    private static Boolean debug;
    private static String description;
    private static Contact testContact;
    private static String className;

    @testSetup
    static void setup() {
        List<lead> testLeads = TestDataFactory.createLeads(3);
        insert testLeads;

        Contact userContact = TestDataFactory.createContact('contactForUser');
        insert userContact;

        Contact testContact = TestDataFactory.createContact('testContact');
        insert testContact;

        User userWithContact = TestDataFactory.createCommunityUser('CommunityUser', userContact.Id);
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
        testContact = [SELECT Id FROM Contact WHERE lastName = 'testContact'];
        userMap = new Map<Id, User>();
        userMap.put(userWithContact.Id, userWithContact);
        userMap.put(userWithoutContact.Id, userWithoutContact);
        className = 'Test_ErrorLogger';
        subject = className + ' Apex Exception: ' + ex.getTypeName() + ' Date: ' + System.today();
        description = 'userMap: ' + String.valueOf(userMap);
    }

    private static Boolean executeErrorLogger() {
        ErrorLogger el = new ErrorLogger();
        el.setClassName(className);
        el.setException(ex);
        el.setDetails(description);
        return el.log();
    }

    private static Boolean executeErrorLoggerWithoutClassName() {
        ErrorLogger el = new ErrorLogger();
        el.setException(ex);
        el.setDetails(description);
        return el.log();
    }

    @isTest
    private static void checkErrorLoggerToString() {
        setupTestVariables();
        String debugLog = '';

        Test.startTest();
        System.runAs(userWithContact) {
            ErrorLogger el = new ErrorLogger();
            el.setException(ex);
            el.setDetails(description);
            debugLog = el.toString();
        }
        Test.stopTest();

        String compareDebugLog =
            ex.getTypeName() +
            '\n' +
            ex.getMessage() +
            '\n' +
            ex.getStackTraceString() +
            '\n' +
            'User Description: \n' +
            description +
            '\n';
        System.assert(debugLog.contains(compareDebugLog));
    }

    private static void validateCreatedCaseAndContactId(Integer numberOfCasesCreated, Id caseContactId) {
        List<Case> exceptionCases;
        exceptionCases = [SELECT Id, ContactId FROM Case WHERE Subject = :subject];

        System.assertEquals(numberOfCasesCreated, exceptionCases.size());

        for (Case c : exceptionCases) {
            System.assertEquals(caseContactId, c.ContactId);
        }
    }

    @isTest
    private static void checkDebugWithCaseForUserWithContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithContact) {
            debug = executeErrorLogger();
        }
        Test.stopTest();
        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, userWithContact.ContactId);
    }

    @isTest
    public static void checkDuplicateDebugCaseForUserWithContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithContact) {
            executeErrorLogger();
            debug = executeErrorLogger();
        }
        Test.stopTest();
        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, userWithContact.ContactId);
    }

    @isTest
    private static void checkDebugWithCaseForUserWithoutContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            debug = executeErrorLogger();
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, null);
    }

    @isTest
    public static void checkDuplicateDebugCaseForUserWithoutContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            executeErrorLogger();
            debug = executeErrorLogger();
        }
        Test.stopTest();
        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(2, null);
    }

    @isTest
    private static void checkDebugWithCaseForSiteGuestUser() {
        setupTestVariables();

        Test.startTest();
        System.runAs(siteGuestUser) {
            debug = executeErrorLogger();
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
            executeErrorLogger();
            debug = executeErrorLogger();
        }
        Test.stopTest();
        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(2, null);
    }

    @isTest
    private static void checkErrorLoggerExceptionHandler() {
        setupTestVariables();

        Test.startTest();
        ErrorLogger el = new ErrorLogger();
        Id nonExistingValidContactId = ID.valueOf('0035B00000Jskt2QAB');
        el.setContactId(nonExistingValidContactId);
        debug = el.log();
        Test.stopTest();

        System.assertEquals(false, debug);
        List<Case> exceptionCases = [SELECT Id, ContactId FROM Case WHERE Subject = :subject];
        System.assertEquals(true, exceptionCases.isEmpty());
    }

    @isTest
    private static void checkPassedInContactIdForUserWithoutContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            ErrorLogger el = new ErrorLogger();
            el.setClassName(className);
            el.setException(ex);
            el.setDetails(description);
            el.setContactId(userWithContact.ContactId);
            debug = el.log();
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, userWithContact.ContactId);
    }

    @isTest
    private static void checkPassedInContactIdForUserWithContact() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithoutContact) {
            ErrorLogger el = new ErrorLogger();
            el.setClassName(className);
            el.setException(ex);
            el.setDetails(description);
            el.setContactId(testContact.Id);
            debug = el.log();
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, testContact.Id);
    }

    @isTest
    private static void checkDuplicateCaseDescription() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithContact) {
            executeErrorLogger();
            ErrorLogger el = new ErrorLogger();
            el.setClassName(className);
            el.setException(ex);
            el.setDetails(description);
            debug = el.log();
        }
        Test.stopTest();

        System.assertEquals(true, debug);

        List<Case> exceptionCases = [SELECT Id, Description, ContactId FROM Case WHERE Subject = :subject];

        System.assertEquals(1, exceptionCases.size());

        for (Case c : exceptionCases) {
            System.assertEquals(userWithContact.ContactId, c.ContactId);
        }

        String timeStamp = String.valueOf(DateTime.now().dateGMT());
        System.assert(
            exceptionCases[0].description.indexOf(timeStamp) < exceptionCases[0].description.lastIndexOf(timeStamp)
        );
    }

    @isTest
    private static void checkCaseDeDuplicationWithClassName() {
        setupTestVariables();

        Test.startTest();
        System.runAs(userWithContact) {
            executeErrorLogger();
            ErrorLogger el = new ErrorLogger();
            el.setClassName('testClass');
            el.setException(ex);
            el.setDetails(description);
            debug = el.log();
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, userWithContact.ContactId);

        subject = 'testClass Apex Exception: ' + ex.getTypeName() + ' Date: ' + System.today();

        validateCreatedCaseAndContactId(1, userWithContact.ContactId);
    }

    @isTest
    private static void checkCaseDeDuplicationWithoutClassName() {
        setupTestVariables();
        subject = 'Apex Exception: ' + ex.getTypeName() + ' Date: ' + System.today();
        Test.startTest();
        System.runAs(userWithContact) {
            executeErrorLoggerWithoutClassName();
            debug = executeErrorLoggerWithoutClassName();
        }
        Test.stopTest();

        System.assertEquals(true, debug);
        validateCreatedCaseAndContactId(1, userWithContact.ContactId);
    }

    /**
     * Tests for converting SObjects to JSON strings
     */
    public static testMethod void Test_convertSObjectToJSON() {
        string fakeName = 'SObject';
        Lead fakeValue = [SELECT Id FROM Lead LIMIT 1];
        string result = ErrorLogger.convertSObjectToJSON(fakeName, fakeValue);
        string expected = '{' + fakeName + ':{' + String.valueOf(fakeValue) + '}}';

        system.assertEquals(expected, result);
    }

    /**
     * Tests for converting Id values to JSON strings
     */
    public static testMethod void Test_convertIdToJSON() {
        string fakeName = 'objectId';
        Id fakeValue = userinfo.getUserId();
        string result = ErrorLogger.convertIdToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting Double values to JSON strings
     */
    public static testMethod void Test_convertDoubleToJSON() {
        string fakeName = 'myBankAccount';
        double fakeValue = 0.00;
        string result = ErrorLogger.convertDoubleToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting Integer values to JSON strings
     */
    public static testMethod void Test_convertIntegerToJSON() {
        string fakeName = 'longestRelationshipInDays';
        integer fakeValue = 3;
        string result = ErrorLogger.convertIntegerToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting Boolean values to JSON strings
     */
    public static testMethod void Test_convertBooleanToJSON() {
        string fakeName = 'amIGettingFiredForDoingThis';
        boolean fakeValue = true;
        string result = ErrorLogger.convertBooleanToJSON(fakeName, fakeValue);

        system.assertEquals('{' + fakeName + ':' + fakeValue + '}', result);
    }

    /**
     * Tests for converting maps to JSON strings - ID to Integer overload
     */
    public static testMethod void Test_convertMapToJSON_Id_To_Int() {
        string expected;
        string result;
        string fakeName = 'leadMap';
        Map<Id, Integer> fakeMap;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null map
        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected, result);

        // Test 2 - validate a non-null map with 0 entries
        fakeMap = new Map<Id, Integer>();

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected, result);

        // Test 3 - validate a non null map containing 3 values
        for (Lead l : testLeads) {
            fakeMap.put(l.Id, 1);
        }

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeMap) + ']}';
        system.assertEquals(expected, result);
    }

    /**
     * Tests for converting maps to JSON strings - ID to SObject overload
     */
    public static testMethod void Test_convertMapToJSON_Id_To_SObject() {
        string expected;
        string result;
        string fakeName = 'leadMap';
        Map<Id, Lead> fakeMap;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null map
        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected, result);

        // Test 2 - validate a non-null map with 0 entries
        fakeMap = new Map<Id, Lead>();

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected, result);

        // Test 3 - validate a non null map containing 3 values
        for (Lead l : testLeads) {
            fakeMap.put(l.Id, l);
        }

        result = ErrorLogger.convertMapToJSON(fakeName, fakeMap);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeMap) + ']}';
        system.assertEquals(expected, result);
    }

    /**
     * Tests for converting sets to JSON strings - ID overload
     */
    public static testMethod void Test_convertSetToJSON_Id() {
        string expected;
        string result;
        string fakeName = 'leadSet';
        Set<Id> fakeSet;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null set
        result = ErrorLogger.convertSetToJSON(fakeName, fakeSet);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected, result);

        // Test 2 - validate a non-null set with 0 entries
        fakeSet = new Set<Id>();

        result = ErrorLogger.convertSetToJSON(fakeName, fakeSet);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected, result);

        // Test 3 - validate a non null set containing 3 values
        for (Lead l : testLeads) {
            fakeSet.add(l.Id);
        }

        result = ErrorLogger.convertSetToJSON(fakeName, fakeSet);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeSet) + ']}';
        system.assertEquals(expected, result);
    }

    /**
     * Tests for converting lists to JSON strings - ID overload
     */
    public static testMethod void Test_convertListToJSON_Id() {
        string expected;
        string result;
        string fakeName = 'leadList';
        List<Id> fakeList;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null set
        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected, result);

        // Test 2 - validate a non-null set with 0 entries
        fakeList = new List<Id>();

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected, result);

        // Test 3 - validate a non null set containing 3 values
        for (Lead l : testLeads) {
            fakeList.add(l.Id);
        }

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeList) + ']}';
        system.assertEquals(expected, result);
    }

    /**
     * Tests for converting lists to JSON strings - SObject overload
     */
    public static testMethod void Test_convertListToJSON_SObject() {
        string expected;
        string result;
        string fakeName = 'leadList';
        List<Lead> fakeList;
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 3];

        // Test 1 - validate a null set
        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':null}';
        system.assertEquals(expected, result);

        // Test 2 - validate a non-null set with 0 entries
        fakeList = new List<Lead>();

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':{size:0, objects[]}}';
        system.assertEquals(expected, result);

        // Test 3 - validate a non null set containing 3 values
        fakeList = testLeads;

        result = ErrorLogger.convertListToJSON(fakeName, fakeList);
        expected = '{' + fakeName + ':[' + string.valueOf(fakeList) + ']}';
        system.assertEquals(expected, result);
    }
}
