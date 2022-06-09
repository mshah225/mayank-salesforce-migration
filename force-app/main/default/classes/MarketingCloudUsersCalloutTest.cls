@isTest
private class MarketingCloudUsersCalloutTest {
    private static final Boolean NO_ERRORS = true;
    private static final String INVALID_CONFIGURATION_NAME = 'notValid';

    @testSetup
    private static void insertTestData() {
        Marketing_Cloud_Utilities_Config__c testingConfiguration = new Marketing_Cloud_Utilities_Config__c();
        testingConfiguration.Name = MarketingCloudUsersController.CUSTOM_SETTING_BY_NAME;
        testingConfiguration.AccountId__c = MarketingCloudUsersCalloutMock.ACCOUNT_ID;
        testingConfiguration.Endpoint__c = 'https://test.example.com';
        insert testingConfiguration;

        Marketing_Cloud_Utilities_Config__c invalidConfiguration = new Marketing_Cloud_Utilities_Config__c();
        invalidConfiguration.Name = INVALID_CONFIGURATION_NAME;
        invalidConfiguration.AccountId__c = 'xyz';
        invalidConfiguration.Endpoint__c = 'https://test.example.com';
        insert invalidConfiguration;
    }

    @isTest
    private static void constructorGetsConfigValues() {
        Test.startTest();
        MarketingCloudUsersCallout service = new MarketingCloudUsersCallout(
            MarketingCloudUsersController.CUSTOM_SETTING_BY_NAME
        );
        Test.stopTest();
        System.assertNotEquals(null, service.apiConfiguration);
    }

    @isTest
    private static void constructorInvalidConfigValue() {
        Test.startTest();
        MarketingCloudUsersCallout service = new MarketingCloudUsersCallout('testValue');
        Test.stopTest();
        System.assertEquals(null, service.apiConfiguration);
    }

    @isTest
    private static void errorCalloutForBadAuthorization() {
        MarketingCloudUsersCallout service = new MarketingCloudUsersCallout(INVALID_CONFIGURATION_NAME);
        Test.setMock(HttpCalloutMock.class, new MarketingCloudUsersCalloutMock());

        String errorMessage;
        Test.startTest();
        try {
            List<MarketingCloudUsersCallout.MarketingCloudUser> retrievedUsers = service.getUsers();
        } catch (Exception e) {
            Test.stopTest();
            errorMessage = e.getMessage();
        }

        System.assertEquals('Error: Status Code: 400 Unauthorized', errorMessage);
    }

    @isTest
    private static void successfulCalloutForUsers() {
        MarketingCloudUsersCallout service = new MarketingCloudUsersCallout(
            MarketingCloudUsersController.CUSTOM_SETTING_BY_NAME
        );
        Test.setMock(HttpCalloutMock.class, new MarketingCloudUsersCalloutMock());

        Test.startTest();
        List<MarketingCloudUsersCallout.MarketingCloudUser> retrievedUsers = service.getUsers();
        Test.stopTest();

        System.assertEquals(MarketingCloudUsersCalloutMock.ACCOUNT_ID, String.valueOf(retrievedUsers.get(0).Id));
    }
}
