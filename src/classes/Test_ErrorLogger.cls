@isTest
public class Test_ErrorLogger {
    @testSetup
    static void setup() {
        List<lead> testLeads = TestDataFactory.createLeads(3);
        insert testLeads;
        
        test.startTest();
        Contact testContact = TestDataFactory.createContact('contactForUser');
        insert testContact;
        test.stopTest();
        
        User userWithContact = TestDataFactory.createCommunityUser('CommunityUser',testContact.Id);
        insert userWithContact;
        
        Id profileId = [SELECT Id FROM Profile WHERE name = 'ASU Service - ASU Salesforce Support'].Id;
        User userWithoutContact = TestDataFactory.createUser('UserWithoutContact', profileId);
        insert userWithoutContact;
        
        profileId = [SELECT Id FROM Profile WHERE name = 'My ASU Profile'].Id;
        User siteGuestUser = TestDataFactory.createUser('siteGuestUser', profileId);
        insert siteGuestUser;
    }
    
    /**
     * Tests for logging errors as cases or emails.
     */
    public static testmethod void Test_log() {
        Exception ex = TestDataFactory.createException();
        User userWithContact = [SELECT Id, contactId FROM User WHERE lastName = 'CommunityUser'];
        User userWithoutContact = [SELECT Id FROM User WHERE lastName = 'UserWithoutContact'];
        User siteGuestUser = [SELECT Id FROM User WHERE lastName = 'siteGuestUser'];
        List<String> vars = new List<String>();
        Map<Id,User> userMap = new Map<Id,User>();
        List<Case> exceptionCases;
        String subject = 'Apex Exception: ' + ex.getTypeName() + ' Date: ' + system.today();
        
        //Create some variables to pass to the logger
        userMap.put(userWithContact.Id, userWithContact);
        userMap.put(userWithoutContact.Id, userWithoutContact);
        
        vars.add(ErrorLogger.convertBooleanToJSON('boolean', true));
        vars.add(ErrorLogger.convertIntegerToJSON('integer', 1));
        vars.add(ErrorLogger.convertStringToJSON('string', 'true'));
        vars.add(ErrorLogger.convertMapToJSON('userMap',userMap));
        
        
        Test.startTest();
        system.runAs(userWithContact) {
            // Test 1 : Debug mode enabled
            system.assertEquals(false, ErrorLogger.log(ex, vars, true));
            
            // Test 2 : User with associated Contact, Debug disabled
            system.assertEquals(true, ErrorLogger.log(ex, vars, false));
            
            // Test 3 : User with assocaited Contact has existing open case 
            // debug disabled
            system.assertEquals(false, ErrorLogger.log(ex, vars, false));
        }
        
        // Test 4 : Verify case information is correct
        // Test 4a : Implicity verify subject
        exceptionCases = [SELECT Id, contactId FROM Case WHERE Subject = :subject];
        
        // Test 4b : Ensure that exactly 1 case was inserted
        if (exceptionCases != null) {
            system.assertEquals(1, exceptionCases.size());
        }
        
        if (exceptionCases.size() > 0) {
            // Test 4c : Ensure contact ID is correct
            system.assertEquals(userWithContact.contactId, exceptionCases[0].contactId); 
        }
        
        // Clean up for next test
        delete exceptionCases;
        
        Test.stopTest();
    }
    
        /**
     * Tests for logging errors as cases or emails.
     */
    public static testmethod void Test_logTwo() {
        Exception ex = TestDataFactory.createException();
        User userWithContact = [SELECT Id, contactId FROM User WHERE lastName = 'CommunityUser'];
        User userWithoutContact = [SELECT Id FROM User WHERE lastName = 'UserWithoutContact'];
        User siteGuestUser = [SELECT Id FROM User WHERE lastName = 'siteGuestUser'];
        List<String> vars = new List<String>();
        Map<Id,User> userMap = new Map<Id,User>();
        List<Case> exceptionCases;
        String subject = 'Apex Exception: ' + ex.getTypeName() + ' Date: ' + system.today();
        
        //Create some variables to pass to the logger
        userMap.put(userWithContact.Id, userWithContact);
        userMap.put(userWithoutContact.Id, userWithoutContact);
        
        vars.add(ErrorLogger.convertBooleanToJSON('boolean', true));
        vars.add(ErrorLogger.convertIntegerToJSON('integer', 1));
        vars.add(ErrorLogger.convertStringToJSON('string', 'true'));
        vars.add(ErrorLogger.convertMapToJSON('userMap',userMap));
        
        
        Test.startTest();
        
        system.runAs(userWithoutContact) {
            // Test 5 : Debug mode enabled
            system.assertEquals(false, ErrorLogger.log(ex, vars, true));
            
            // Test 6 : User without associated Contact, Debug disabled
            system.assertEquals(true, ErrorLogger.log(ex, vars, false));
            
            // Test 7 : User without assocaited Contact should allow
            // duplicate cases. debug disabled
            system.assertEquals(true, ErrorLogger.log(ex, vars, false));
        }
        
        // Test 8 : Verify case information is correct
        // Test 8a : Implicity verify subjects
        exceptionCases = [SELECT Id, contactId FROM Case WHERE Subject = :subject];
        
        // Test 8b : Ensure that exactly 2 cases were inserted
        if (exceptionCases != null) {
            system.assertEquals(2, exceptionCases.size());
        }
        
        if (exceptionCases.size() > 0) {
            // Test 8c : Ensure contact ID null for cases
            for (Case c : exceptionCases) {
                system.assertEquals(null, c.contactId); 
            }
        }
        
        delete exceptionCases;
        Test.stopTest();
    }
    
    /**
    * Tests for logging errors as cases or emails.
    */
    public static testmethod void Test_logThree() {
        Exception ex = TestDataFactory.createException();
        User userWithContact = [SELECT Id, contactId FROM User WHERE lastName = 'CommunityUser'];
        User userWithoutContact = [SELECT Id FROM User WHERE lastName = 'UserWithoutContact'];
        User siteGuestUser = [SELECT Id FROM User WHERE lastName = 'siteGuestUser'];
        List<String> vars = new List<String>();
        Map<Id,User> userMap = new Map<Id,User>();
        List<Case> exceptionCases;
        String subject = 'Apex Exception: ' + ex.getTypeName() + ' Date: ' + system.today();
        
        //Create some variables to pass to the logger
        userMap.put(userWithContact.Id, userWithContact);
        userMap.put(userWithoutContact.Id, userWithoutContact);
        
        vars.add(ErrorLogger.convertBooleanToJSON('boolean', true));
        vars.add(ErrorLogger.convertIntegerToJSON('integer', 1));
        vars.add(ErrorLogger.convertStringToJSON('string', 'true'));
        vars.add(ErrorLogger.convertMapToJSON('userMap',userMap));
        
        
        Test.startTest();
        
        system.runAs(siteGuestUser) {
            // Test 9 : Debug mode enabled
            system.assertEquals(false, ErrorLogger.log(ex, vars, true));
            
            // Test 10 : Site Guest User, Debug disabled
            Boolean troll = ErrorLogger.log(ex, vars, false);
            system.assertEquals(true, troll);
            
            // Test 11 : Site Guest User should allow duplicate cases. debug disabled
            system.assertEquals(true, ErrorLogger.log(ex, vars, false));
        }
        
        // Test 12 : Verify case information is correct
        // Test 12a : Implicity verify subjects
        exceptionCases = [SELECT Id, contactId FROM Case WHERE Subject = :subject];
        
        // Test 12b : Ensure that exactly 2 cases were inserted
        if (exceptionCases != null) {
            system.assertEquals(2, exceptionCases.size());
        }
        
        if (exceptionCases.size() > 0) {
            // Test 12c : Ensure contact ID null for cases
            for (Case c : exceptionCases) {
                system.assertEquals(null, c.contactId); 
            }
        }
        
        // Test 13 : Pass a null case to force an exception in the logger
        // Logger will send an email and unfortuantely, we have no way to
        // Verify if email was sent or what the content of the email is
        system.assertEquals(null, ErrorLogger.log(ex, vars, false, null, null));
        
        delete exceptionCases;
        
        // Test 14 : Pass a contact Id and verify that the contact Id is filled out correctly
        system.runAs(userWithoutContact) {
            ErrorLogger.log(ex, vars, false, userWithContact.contactId);
        }
        
        exceptionCases = [SELECT Id, contactId FROM Case WHERE Subject = :subject];
        
        system.assertEquals(userWithContact.contactId, exceptionCases[0].contactId);
        
        Test.stopTest();
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
