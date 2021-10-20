@isTest
public with sharing class MarketingCloudViewEmailControllerTest {
    @TestSetup
    static void setup() {
        Contact c = new Contact(LastName = 'TestContact');
        insert c;

        Lead l = new Lead(LastName = 'TestLead', Company = 'TestLead');
        insert l;

        et4ae5__SendDefinition__c sd = new et4ae5__SendDefinition__c(et4ae5__JobId__c = 'TEST_JOB_ID_184');
        insert sd;

        et4ae5__IndividualEmailResult__c emailResult = new et4ae5__IndividualEmailResult__c(
            et4ae5__SendDefinition__c = sd.Id,
            View_Email_URL__c = '',
            et4ae5__Lead__c = l.Id,
            et4ae5__Contact__c = c.Id
        );
        insert emailResult;

        ExactTargetApiConfig__c config = new ExactTargetApiConfig__c(
            Name = 'dataext',
            ClientId__c = MarketingCloudEmailLinkMockCallout.CLIENT_ID,
            ClientSecret__c = MarketingCloudEmailLinkMockCallout.CLIENT_SECRET,
            Endpoint__c = 'TEST_ENDPOINT'
        );
        insert config;
    }

    @isTest
    private static void testRetrieveUrlWithContact() {
        et4ae5__IndividualEmailResult__c emailResult = [SELECT Id FROM et4ae5__IndividualEmailResult__c LIMIT 1];
        emailResult.et4ae5__Lead__c = null;
        update emailResult;

        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());
        Test.setCurrentPage(Page.MarketingCloudViewEmail);
        Test.startTest();
        MarketingCloudViewEmailController controller = new MarketingCloudViewEmailController(
            new ApexPages.StandardController(emailResult)
        );
        controller.viewEmailAndStoreLink();
        Test.stopTest();

        emailResult = [SELECT Id, View_Email_URL__c FROM et4ae5__IndividualEmailResult__c LIMIT 1];
        System.assertEquals('https://view.testreply.asu.edu/?qs=testDocumentId', emailResult.View_Email_URL__c);
    }

    @isTest
    private static void testRetrieveUrlWithLead() {
        et4ae5__IndividualEmailResult__c emailResult = [SELECT Id FROM et4ae5__IndividualEmailResult__c LIMIT 1];
        emailResult.et4ae5__Contact__c = null;
        update emailResult;

        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());
        Test.setCurrentPage(Page.MarketingCloudViewEmail);
        Test.startTest();
        MarketingCloudViewEmailController controller = new MarketingCloudViewEmailController(
            new ApexPages.StandardController(emailResult)
        );
        controller.viewEmailAndStoreLink();
        Test.stopTest();

        emailResult = [SELECT Id, View_Email_URL__c FROM et4ae5__IndividualEmailResult__c LIMIT 1];
        System.assertEquals('https://view.testreply.asu.edu/?qs=testDocumentId', emailResult.View_Email_URL__c);
    }

    @isTest
    private static void testDefaultUrl() {
        et4ae5__IndividualEmailResult__c emailResult = [SELECT Id FROM et4ae5__IndividualEmailResult__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmailLinkMockCallout());
        MarketingCloudEmailLinkMockCallout.VIEW_EMAIL_URL = '';
        Test.setCurrentPage(Page.MarketingCloudViewEmail);
        Test.startTest();
        MarketingCloudViewEmailController controller = new MarketingCloudViewEmailController(
            new ApexPages.StandardController(emailResult)
        );
        ApexPages.PageReference pr = controller.viewEmailAndStoreLink();
        Test.stopTest();

        System.assertEquals(Page.et4ae5__ierImage.getUrl(), pr.getUrl());
    }
}
