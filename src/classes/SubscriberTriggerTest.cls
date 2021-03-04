@isTest
private class SubscriberTriggerTest {
    @isTest
    private static void nonPrivateSubscriptionInsert() {
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        for (Subscription__c subscription : subscriptions) {
            subscription.Subscriber_Private_in_Salesforce__c = false;
        }
        insert subscriptions;

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<Subscriber__c> subscribers = TestDataFactory.createTestSubscribers(contacts, subscriptions);
        Test.startTest();
        insert subscribers;
        Test.stopTest();

        for (Subscriber__c subscriber : [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c]) {
            System.assertEquals(
                subscriber.Apex_Owner_Should_Be__c,
                subscriber.OwnerId,
                'OwnerId was not set as expected'
            );
        }
    }

    @isTest
    private static void privateSubscriptionInsert() {
        Group testGroup = TestDataFactory.createTestGroupAndQueue(
            new List<String>{ 'Subscription__c', 'Subscriber__c' }
        );
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        for (Subscription__c subscription : subscriptions) {
            subscription.OwnerId = testGroup.Id;
            subscription.Subscriber_Private_in_Salesforce__c = true;
        }
        insert subscriptions;

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<Subscriber__c> subscribers = TestDataFactory.createTestSubscribers(contacts, subscriptions);
        Test.startTest();
        insert subscribers;
        Test.stopTest();

        for (Subscriber__c subscriber : [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c]) {
            System.assertEquals(
                subscriber.Apex_Owner_Should_Be__c,
                subscriber.OwnerId,
                'OwnerId was not set as expected'
            );
        }
    }
}
