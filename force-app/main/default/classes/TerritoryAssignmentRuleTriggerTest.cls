@isTest
public class TerritoryAssignmentRuleTriggerTest {
    private static final String testUserAlias1 = 'testUsr1';
    private static final String testUserAlias2 = 'testUsr2';

    @TestSetup
    private static void setup() {
        User testUser1 = new User(
            FirstName = 'Test Territory Assignment Rule',
            LastName = 'User',
            Username = 'test.tar.user.1@test.test',
            Email = 'test.tar.user.1@test.test',
            Alias = testUserAlias1,
            CommunityNickname = testUserAlias1,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('Standard User')
        );

        User testUser2 = new User(
            FirstName = 'Test Territory Assignment Rule 2',
            LastName = 'User',
            Username = 'test.tar.user.2@test.test',
            Email = 'test.tar.user.2@test.test',
            Alias = testUserAlias2,
            CommunityNickname = testUserAlias2,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('Standard User')
        );

        insert new List<User>{ testUser1, testUser2 };
    }

    @isTest
    private static void testDeferReassignment() {
        List<String> testUserAliasList = new List<String>{ testUserAlias1, testUserAlias2 };
        List<User> testUsers = [SELECT Id FROM User WHERE Alias IN :testUserAliasList ORDER BY Alias ASC];

        // Setup TAR
        Territory_Assignment_Rule__c tar = new Territory_Assignment_Rule__c(
            Rule_Type__c = 'Geomarket',
            Opportunity_Type__c = 'Transfer',
            Geomarket__c = 'US-63',
            User__c = testUsers[0].Id
        );
        insert tar;

        // Change owner on TAR
        tar.User__c = testUsers[1].Id;

        Test.startTest();
        update tar;
        Test.stopTest();

        tar = [
            SELECT Id, Defer_Territory_Assignment__c, Previous_User_ID__c
            FROM Territory_Assignment_Rule__c
            WHERE Id = :tar.Id
        ];

        // Should defer reassign since set to another user
        System.assert(tar.Defer_Territory_Assignment__c);
        System.assertEquals(testUsers[0].Id, tar.Previous_User_ID__c);
    }

    @isTest
    private static void testDontDeferReassignment() {
        List<String> testUserAliasList = new List<String>{ testUserAlias1, testUserAlias2 };
        List<User> testUsers = [SELECT Id FROM User WHERE Alias IN :testUserAliasList ORDER BY Alias ASC];

        // Setup TAR
        Territory_Assignment_Rule__c tar = new Territory_Assignment_Rule__c(
            Rule_Type__c = 'Geomarket',
            Opportunity_Type__c = 'Transfer',
            Geomarket__c = 'US-63',
            User__c = testUsers[0].Id
        );
        insert tar;

        // Change owner on TAR
        tar.User__c = null;

        Test.startTest();
        update tar;
        Test.stopTest();

        tar = [
            SELECT Id, Defer_Territory_Assignment__c, Previous_User_ID__c
            FROM Territory_Assignment_Rule__c
            WHERE Id = :tar.Id
        ];

        // Should not defer reassign since set to null
        System.assert(!tar.Defer_Territory_Assignment__c);
        System.assertEquals(null, tar.Previous_User_ID__c);
    }

    @isTest
    private static void testTerritoryAssignmentRule() {
        Territory_Assignment_Rule__c testRule = new Territory_Assignment_Rule__c();
        List<User> userList = [SELECT Id FROM User LIMIT 2];
        testRule.User__c = userList[0].Id;
        insert testRule;

        testRule.User__c = userList[1].Id;
        update testRule;
        List<Territory_Assignment_Rule__c> ruleList = [SELECT User__c FROM Territory_Assignment_Rule__c];
        System.assertEquals(userList[1].Id, ruleList[0].User__c);
    }
}