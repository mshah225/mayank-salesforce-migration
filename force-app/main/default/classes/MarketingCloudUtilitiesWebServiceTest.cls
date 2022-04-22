@isTest
private class MarketingCloudUtilitiesWebServiceTest {
    private static final Boolean NO_ERRORS = true;
    private static final String INVALID_CONFIGURATION_NAME = 'notValid';

    @testSetup
    private static void insertTestData() {
        Marketing_Cloud_Utilities_Config__c testingConfiguration = new Marketing_Cloud_Utilities_Config__c();
        testingConfiguration.Name = MarketingCloudUtilitiesController.CUSTOM_SETTING_BY_NAME;
        testingConfiguration.AccountId__c = MarketingCloudUtilitiesMockCallout.ACCOUNT_ID;
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
        MarketingCloudUtilitiesWebService service = new MarketingCloudUtilitiesWebService(
            MarketingCloudUtilitiesController.CUSTOM_SETTING_BY_NAME
        );
        Test.stopTest();
        System.assertNotEquals(null, service.apiConfiguration);
    }

    @isTest
    private static void constructorInvalidConfigValue() {
        Test.startTest();
        MarketingCloudUtilitiesWebService service = new MarketingCloudUtilitiesWebService('testValue');
        Test.stopTest();
        System.assertEquals(null, service.apiConfiguration);
    }

    @isTest
    private static void errorCalloutForBadAuthorization() {
        MarketingCloudUtilitiesWebService service = new MarketingCloudUtilitiesWebService(INVALID_CONFIGURATION_NAME);
        Test.setMock(HttpCalloutMock.class, new MarketingCloudUtilitiesMockCallout());

        String errorMessage;
        Test.startTest();
        try {
            List<MarketingCloudUtilitiesWebService.MarketingCloudUser> retrievedUsers = service.getUsers();
        } catch (Exception e) {
            Test.stopTest();
            errorMessage = e.getMessage();
        }

        System.assertEquals('Error: Status Code: 400 Unauthorized', errorMessage);
    }

    @isTest
    private static void successfulCalloutForUsers() {
        MarketingCloudUtilitiesWebService service = new MarketingCloudUtilitiesWebService(
            MarketingCloudUtilitiesController.CUSTOM_SETTING_BY_NAME
        );
        Test.setMock(HttpCalloutMock.class, new MarketingCloudUtilitiesMockCallout());

        Test.startTest();
        List<MarketingCloudUtilitiesWebService.MarketingCloudUser> retrievedUsers = service.getUsers();
        Test.stopTest();

        System.assertEquals(MarketingCloudUtilitiesMockCallout.ACCOUNT_ID, String.valueOf(retrievedUsers.get(0).Id));
    }
}
