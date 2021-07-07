@isTest
private class MassHashUpdateBatchTest {
    @isTest
    private static void runAllBatchesWithoutErrors() {
        Test.startTest();
        new MassHashUpdateBatch();
        Test.stopTest();
    }

    @isTest
    private static void runExecuteWithoutErrors() {
        Test.startTest();
        new SubscriberHashUpdateBatch().execute(null, new List<Subscriber__c>());
        new SubscriptionHashUpdateBatch().execute(null, new List<Subscription__c>());
        new LeadHashUpdateBatch().execute(null, new List<Lead>());
        new ContactHashUpdateBatch().execute(null, new List<Contact>());
        new CampaignHashUpdateBatch().execute(null, new List<Campaign>());
        Test.stopTest();
    }
}
