@isTest
public with sharing class MarketingCloudUtilitiesControllerTest {
    @TestSetup
    static void setup() {
        Marketing_Cloud_Utilities_Config__c config = new Marketing_Cloud_Utilities_Config__c();
        config.Name = 'users';
        config.AccountId__c = MarketingCloudUtilitiesMockCallout.ACCOUNT_ID;
        config.Endpoint__c = 'TEST_ENDPOINT';
        insert config;
    }

    @isTest
    private static void testRetrieveUsers() {
        Test.setMock(HttpCalloutMock.class, new MarketingCloudUtilitiesMockCallout());

        Test.startTest();
        List<MarketingCloudUtilitiesWebService.MarketingCloudUser> users = MarketingCloudUtilitiesController.getUsersFromMarketingCloud();
        Test.stopTest();

        System.assertEquals(1, users.size());
    }
}
