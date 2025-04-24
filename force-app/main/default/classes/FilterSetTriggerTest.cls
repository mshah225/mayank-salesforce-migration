@isTest
public without sharing class FilterSetTriggerTest {
    private static final String testUsr1Alias = 'testUsr1';
    private static final String testUsr2Alias = 'testUsr2';

    @TestSetup
    private static void setup() {
        User user1 = new User(
            FirstName = 'CaseOwner',
            LastName = 'TestUser',
            Username = 'caseowner.testuser@test.test',
            Email = 'caseowner.testuser@test.test',
            Alias = testUsr1Alias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileID('Standard User'),
            LanguageLocaleKey = 'en_US'
        );
        User user2 = new User(
            FirstName = 'TransferTo',
            LastName = 'TestUser',
            Username = 'caseowner.testuser2@test.test',
            Email = 'caseowner.testuser2@test.test',
            Alias = testUsr2Alias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = RecordIdHelper.getProfileID('Standard User'),
            LanguageLocaleKey = 'en_US'
        );
        insert new List<User>{ user1, user2 };
    }

    @isTest
    private static void testUniqueNamesPerUser() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];

        insert new Filter_Set__c(Name = 'My Filter Set', Value__c = '{}', OwnerId = testUser.Id);

        Exception thrownException;

        Test.startTest();
        System.runAs(testUser) {
            // Try and fail
            try {
                insert new Filter_Set__c(Name = 'My Filter Set', Value__c = '{}');
            } catch (Exception ex) {
                thrownException = ex;
            }
        }
        Test.stopTest();

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            System.DmlException.class,
            'Expected to throw an exception of type System.DmlException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('Filter Names must be unique'),
            'Expected error message to contain "Filter Names must be unique", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testDuplicateNamesMultipleUsers() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUsr2Alias LIMIT 1];

        insert new Filter_Set__c(Name = 'My Filter Set', Value__c = '{}', OwnerId = testUser.Id);

        Exception thrownException;

        Test.startTest();
        System.runAs(testUser2) {
            // Try and succeed
            try {
                insert new Filter_Set__c(Name = 'My Filter Set', Value__c = '{}');
            } catch (Exception ex) {
                thrownException = ex;
            }
        }
        Test.stopTest();

        // Assert
        Assert.areEqual(null, thrownException, 'No error expected - but an error was thrown');
    }

    @isTest
    private static void testOnlyOwnerCanRename() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE Alias = :testUsr2Alias LIMIT 1];

        Filter_Set__c fs = new Filter_Set__c(Name = 'My Filter Set', Value__c = '{}', OwnerId = testUser.Id);
        insert fs;

        Exception thrownException;

        System.runAs(testUser) {
            // Try and succeed
            try {
                fs.Name = 'New Name User 1';
                update fs;
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        Assert.areEqual(null, thrownException, 'No error expected - but an error was thrown');

        System.runAs(testUser2) {
            // Try and fail
            try {
                fs.Name = 'New Name User 2';
                update fs;
            } catch (Exception ex) {
                thrownException = ex;
            }
        }

        // Assert
        Assert.isInstanceOfType(
            thrownException,
            System.DmlException.class,
            'Expected to throw an exception of type System.DmlException, but actually threw ' +
            thrownException?.getTypeName()
        );
        Assert.isTrue(
            thrownException?.getMessage()?.contains('You do not own this filter set'),
            'Expected error message to contain "You do not own this filter set", but it instead said "' +
                thrownException?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testAutoCreateFilterSetUserAssociationForOwner() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUsr1Alias LIMIT 1];

        Filter_Set__c fs = new Filter_Set__c(Name = 'My Filter Set', Value__c = '{}', OwnerId = testUser.Id);
        insert fs;

        List<Filter_Set_User_Association__c> fsuas = [SELECT Id, Filter_Set__c, User__c FROM Filter_Set_User_Association__c];

        Assert.areEqual(1, fsuas.size());
        Assert.areEqual(testUser.Id, fsuas[0].User__c);
        Assert.areEqual(fs.Id, fsuas[0].Filter_Set__c);
    }
}