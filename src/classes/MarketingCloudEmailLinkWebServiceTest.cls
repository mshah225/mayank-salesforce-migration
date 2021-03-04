@isTest
private class MarketingCloudEmailLinkWebServiceTest {
    private static final Boolean NO_ERRORS = true;
    private static final String INVALID_CONFIGURATION_NAME = 'notValid';

    @testSetup
    private static void insertTestData() {
        ExactTargetApiConfig__c testingConfiguration = new ExactTargetApiConfig__c();
        testingConfiguration.Name = MarketingCloudViewEmailController.CUSTOM_SETTING_BY_NAME;
        testingConfiguration.ClientId__c = MarketingCloudEmailLinkMockCallout.CLIENT_ID;
        testingConfiguration.ClientSecret__c = MarketingCloudEmailLinkMockCallout.CLIENT_SECRET;
        testingConfiguration.Endpoint__c = 'https://test.example.com';
        insert testingConfiguration;

        ExactTargetApiConfig__c invalidConfiguration = new ExactTargetApiConfig__c();
        invalidConfiguration.Name = INVALID_CONFIGURATION_NAME;
        invalidConfiguration.ClientId__c = 'test';
        invalidConfiguration.ClientSecret__c = 'test';
        invalidConfiguration.Endpoint__c = 'https://test.example.com';
        insert invalidConfiguration;

        BusinessUnitFactory.DefaultBusinessUnit businessUnits = new BusinessUnitFactory.DefaultBusinessUnit();
        List<et4ae5__Business_Unit__c> units = businessUnits.create(2);
        insert units;

        SendDefinitionFactory.DefaultSendDefinition sendDefinitions = new SendDefinitionFactory.DefaultSendDefinition();
        sendDefinitions.setRelatedBusinessUnits(units);
        insert sendDefinitions.create(4);
    }

    @isTest
    private static void constructorGetsConfigValues() {
        Test.startTest();
        MarketingCloudEmailLinkWebService service = new MarketingCloudEmailLinkWebService(
            MarketingCloudViewEmailController.CUSTOM_SETTING_BY_NAME
        );
        Test.stopTest();
        System.assertNotEquals(null, service.apiConfiguration);
    }

    @isTest
    private static void constructorInvalidConfigValue() {
        Test.startTest();
        MarketingCloudEmailLinkWebService service = new MarketingCloudEmailLinkWebService('testValue');
        Test.stopTest();
        System.assertEquals(null, service.apiConfiguration);
    }

    @isTest
    private static void errorCalloutForBadAuthorization() {
        MarketingCloudEmailLinkWebService service = new MarketingCloudEmailLinkWebService(INVALID_CONFIGURATION_NAME);
        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());

        String errorMessage;
        Test.startTest();
        try {
            String retrievedEmailLink = service.retrieveViewEmailUrl('jobId1', 'ThisIsTheSubscriberKey');
        } catch (Exception e) {
            Test.stopTest();
            errorMessage = e.getMessage();
        }

        System.assertEquals('Error: Status Code: 400 Unauthorized', errorMessage);
    }

    @isTest
    private static void successfulCalloutForEmailLink() {
        MarketingCloudEmailLinkWebService service = new MarketingCloudEmailLinkWebService(
            MarketingCloudViewEmailController.CUSTOM_SETTING_BY_NAME
        );
        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());

        Test.startTest();
        String retrievedEmailLink = service.retrieveViewEmailUrl('jobId1', 'ThisIsTheSubscriberKey');
        Test.stopTest();

        System.assertEquals(MarketingCloudEmailLinkMockCallout.VIEW_EMAIL_URL, retrievedEmailLink);
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
}
