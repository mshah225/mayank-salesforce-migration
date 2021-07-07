@isTest
private class BatchApplySubscriberPrivacyTest {
    @isTest
    private static void BatchSubscriptionPrivacyChange() {
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        for (Subscription__c subscription : subscriptions) {
            subscription.Subscriber_Private_in_Salesforce__c = false;
        }
        insert subscriptions;

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<Subscriber__c> subscribers = TestDataFactory.createTestSubscribers(contacts, subscriptions);
        insert subscribers;

        for (Subscriber__c subscriber : [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c]) {
            System.assertEquals(
                subscriber.Apex_Owner_Should_Be__c,
                subscriber.OwnerId,
                'OwnerId was not initially set as expected'
            );
        }

        Group testGroup = TestDataFactory.createTestGroupAndQueue(
            new List<String>{ 'Subscription__c', 'Subscriber__c' }
        );

        Set<Id> subscriptionTestIds = new Set<Id>();
        for (Subscription__c subscription : subscriptions) {
            subscription.OwnerId = testGroup.Id;
            subscription.Subscriber_Private_in_Salesforce__c = true;
            subscriptionTestIds.add(subscription.Id);
        }
        update subscriptions;

        for (Subscription__c subscription : [
            SELECT Id, Subscriber_Privacy_Changed__c
            FROM Subscription__c
            WHERE Id IN :subscriptionTestIds
        ]) {
            System.assert(
                subscription.Subscriber_Privacy_Changed__c,
                'Subscriber_Privacy_Changed__c was not set to true'
            );
        }

        Test.startTest();
        BatchApplySubscriberPrivacy batch = new BatchApplySubscriberPrivacy();
        Database.executeBatch(batch);
        Test.stopTest();

        for (Subscriber__c subscriber : [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c]) {
            System.assertEquals(
                subscriber.Apex_Owner_Should_Be__c,
                subscriber.OwnerId,
                'OwnerId was not set as expected by BatchApplySubscriberPrivacy'
            );
        }

        for (Subscription__c subscription : [
            SELECT Id, Subscriber_Privacy_Changed__c
            FROM Subscription__c
            WHERE Id IN :subscriptionTestIds
        ]) {
            System.assertEquals(
                false,
                subscription.Subscriber_Privacy_Changed__c,
                'Subscriber_Privacy_Changed__c was not re-set to false'
            );
        }
    }
}
