@isTest
public with sharing class OmniChannelControllerTest {
    private static final String testUserAlias = 'testUsr';

    @TestSetup
    static void setup() {
        User testUser = new User(
            FirstName = 'John',
            LastName = 'McTesterson',
            Username = 'john.mctesterson@test.test',
            Email = 'john.mctesterson@test.test',
            Alias = testUserAlias,
            CommunityNickname = testUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = IDHelper.getProfileId('Standard User')
        );
        insert testUser;
    }

    @isTest
    private static void testUpdateOmniChannelInfo() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        String expectedMessage = 'I\'m out of office for the summer backpacking in the Alps.  Call me again in September.';

        System.runAs(testUser) {
            Test.startTest();
            omnichannelController.loggedInStatus = false;
            omnichannelController.outOfOfficeMessage = expectedMessage;
            omnichannelController.updateOmniChannelInfo();
            Test.stopTest();
        }

        User updatedUser = [
            SELECT omniChannel_loggedIn__c, Out_Of_Office_Message__c
            FROM User
            WHERE Alias = :testUserAlias
        ];

        System.assertEquals(false, updatedUser.omniChannel_loggedIn__c);
        System.assertEquals(expectedMessage, updatedUser.Out_Of_Office_Message__c);
    }

    @isTest
    private static void testErrorCatching() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias];

        String expectedMessage = 'Very long message. Too long....';
        for (Integer i = 0; i < 32769; i++) {
            expectedMessage += '.';
        }

        Boolean correctErrorThrown = false;
        System.runAs(testUser) {
            Test.startTest();
            omnichannelController.outOfOfficeMessage = expectedMessage;
            try {
                omnichannelController.updateOmniChannelInfo();
            } catch (AuraHandledException handledException) {
                correctErrorThrown = true;
            }
            Test.stopTest();
        }

        System.assert(
            correctErrorThrown,
            'Any thrown errors should be caught and re-thrown in an AuraHandledException wrapper'
        );
    }
}
