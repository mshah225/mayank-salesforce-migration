@isTest
private class MarketingCloudViewEmailControllerTest {
    private static ApexPages.StandardController emailResultController;
    private static et4ae5__IndividualEmailResult__c ierForTesting;
    
    private static void setupTestData() {
        IndividualEmailResultFactory.DefaultIndividualEmailResult emailResults 
            = new IndividualEmailResultFactory.DefaultIndividualEmailResult();
        
        ContactFactory.DefaultContact contactFactory = new ContactFactory.DefaultContact();
        List<Contact> contacts = contactFactory.create();
        insert contacts;
        emailResults.setRealtedContacts(contacts);
        
        LeadFactory.DefaultLead leadFactory = new LeadFactory.DefaultLead();
        List<Lead> leads = leadFactory.create();
        insert leads;
        emailResults.setRealtedLeads(leads);
        
        BusinessUnitFactory.DefaultBusinessUnit businessUnits = new BusinessUnitFactory.DefaultBusinessUnit();
        List<et4ae5__Business_Unit__c> units = businessUnits.create();
        insert units;
        
        SendDefinitionFactory.DefaultSendDefinition sendDefinitionFactory = new SendDefinitionFactory.DefaultSendDefinition();
        sendDefinitionFactory.setRelatedBusinessUnits(units);
        List<et4ae5__SendDefinition__c> sendDefinitions = sendDefinitionFactory.create();
        insert sendDefinitions;
        
        emailResults.setRealtedSendDefinitions(sendDefinitions);
        List<et4ae5__IndividualEmailResult__c> testIersCreated = emailResults.create();
        ierForTesting = testIersCreated.get(0);
        insert ierForTesting;
        
        emailResultController = new ApexPages.StandardController(ierForTesting);
    }
    
    @testSetup
    private static void insertTestData() {
        ExactTargetApiConfig__c testingConfiguration = new ExactTargetApiConfig__c();
        testingConfiguration.Name = MarketingCloudViewEmailController.CUSTOM_SETTING_BY_NAME;
        testingConfiguration.ClientId__c = MarketingCloudEmailLinkMockCallout.CLIENT_ID;
        testingConfiguration.ClientSecret__c = MarketingCloudEmailLinkMockCallout.CLIENT_SECRET;
        testingConfiguration.Endpoint__c = 'https://test.example.com';
        insert testingConfiguration;
    }
    
    @isTest
    private static void successControllerGetRecord() {
         setupTestData();
         
         Test.startTest();
         MarketingCloudViewEmailController controllerUnderTest = new MarketingCloudViewEmailController(emailResultController);
         Test.stopTest();
         
         System.assertEquals(ierForTesting.Id, controllerUnderTest.individualEmailResult.Id);
    }
    
    @isTest
    private static void successReturnCachedLink() {
        setupTestData();
        String emailUrl = 'http://test.example.com';
        ierForTesting.View_Email_URL__c = emailUrl;
        update ierForTesting;
        MarketingCloudViewEmailController controllerUnderTest = new MarketingCloudViewEmailController(emailResultController);
        
        Test.startTest();
        PageReference cachedEmailLink = controllerUnderTest.viewEmailAndStoreLink();
        Test.stopTest();
        
        System.assertEquals(emailUrl, cachedEmailLink.getUrl());
    }
    
    @isTest
    private static void successCalloutForLinkAndStore() {
        setupTestData();
        ierForTesting = [
            SELECT et4ae5__SendDefinition__r.et4ae5__JobId__c, View_Email_URL__c, 
                et4ae5__Lead__c, et4ae5__Contact__c
            FROM et4ae5__IndividualEmailResult__c
        ];
        
        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());
        MarketingCloudViewEmailController controllerUnderTest = new MarketingCloudViewEmailController(emailResultController);
        
        Test.startTest();
        PageReference returnedLinkToEmail = controllerUnderTest.viewEmailAndStoreLink();
        Test.stopTest();
        
        String returnedEmailUrl = returnedLinkToEmail.getUrl();
        String httpsVersionOfLink = MarketingCloudEmailLinkMockCallout.VIEW_EMAIL_URL.replace('http:', 'https:');
        String emailUrlStoredOnRecord = [
            SELECT View_Email_URL__c 
            FROM et4ae5__IndividualEmailResult__c 
            WHERE Id = :ierForTesting.Id
        ].View_Email_URL__c;
        
        System.assertEquals(httpsVersionOfLink, returnedEmailUrl);
        System.assertEquals(httpsVersionOfLink, emailUrlStoredOnRecord);
    }
    
    @isTest
    private static void errorReturnsLinkToIerImagePage() {
        setupTestData();
        ierForTesting.et4ae5__Contact__c = null;
        ierForTesting.et4ae5__Lead__c = null;
        update ierForTesting;
        
        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());
        MarketingCloudViewEmailController controllerWithoutEnoughData = new MarketingCloudViewEmailController(emailResultController);
        
        Test.startTest();
        PageReference linkToIerImagePage = controllerWithoutEnoughData.viewEmailAndStoreLink();
        Test.stopTest();
        
        System.assertEquals(Page.et4ae5__ierImage.getUrl(), linkToIerImagePage.getUrl());
    }
}