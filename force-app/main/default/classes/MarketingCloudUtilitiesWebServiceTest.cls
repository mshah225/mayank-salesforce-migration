@isTest
private class MarketingCloudUtilitiesWebServiceTest {
    private static final Boolean NO_ERRORS = true;
    private static final String INVALID_CONFIGURATION_NAME = 'notValid';

    @testSetup
    private static void insertTestData() {
        ExactTargetApiConfig__c testingConfiguration = new ExactTargetApiConfig__c();
        testingConfiguration.Name = MarketingCloudUserController.CUSTOM_SETTING_BY_NAME;
        testingConfiguration.AccountId__c = MarketingCloudUtilitiesMockCallout.ACCOUNT_ID;
        testingConfiguration.Endpoint__c = 'https://test.example.com';
        insert testingConfiguration;

        ExactTargetApiConfig__c invalidConfiguration = new ExactTargetApiConfig__c();
        invalidConfiguration.Name = INVALID_CONFIGURATION_NAME;
        testingConfiguration.AccountId__c = '';
        testingConfiguration.Endpoint__c = 'https://test.example.com';
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
    private static void errorCalloutForBadAuthorization() {
        MarketingCloudUtilitiesWebService service = new MarketingCloudUtilitiesWebService(INVALID_CONFIGURATION_NAME);
        Test.setMock(HttpCalloutMock.class, new MarketingCloudUtilitiesMockCallout());

        String errorMessage;
        Test.startTest();
        try {
            String retrievedUsers = service.getUsers();
        } catch (Exception e) {
            Test.stopTest();
            errorMessage = e.getMessage();
        }

        System.assertEquals('Error: Status Code: 400 Unauthorized', errorMessage);
    }

    /*
    @isTest
    private static void successfulCalloutForUsers() {
        MarketingCloudUtilitiesWebService service = new MarketingCloudUtilitiesWebService(
            MarketingCloudUtilitiesController.CUSTOM_SETTING_BY_NAME
        );
        Test.setMock(HttpCalloutMock.class, new MarketingCloudUtilitiesMockCallout());

        Test.startTest();
        String retrievedUsers = service.getUsers();
        Test.stopTest();

        System.assertEquals(MarketingCloudUtilitiesMockCallout.VIEW_EMAIL_URL, retrievedEmailLink);
    }

    @isTest
    private static void errorCalloutForNoUnitRecordsFound() {
        MarketingCloudEmailLinkWebService service = new MarketingCloudEmailLinkWebService(
            MarketingCloudViewEmailController.CUSTOM_SETTING_BY_NAME
        );
        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());

        String errorMessage;
        Test.startTest();
        try {
            String retrievedEmailLink = service.retrieveViewEmailUrl('aWrongJobId', 'ThisIsTheSubscriberKey');
        } catch (Exception e) {
            Test.stopTest();
            errorMessage = e.getMessage();
        }

        System.assertEquals('Error: List has no rows for assignment to SObject', errorMessage);
    }
    */
}
