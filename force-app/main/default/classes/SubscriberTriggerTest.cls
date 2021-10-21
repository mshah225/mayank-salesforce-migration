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

    @isTest
    private static void retriveSubscriberTest() {
        String fieldsToString;
        List<Subscriber__c> subscriberList = new List<Subscriber__c>();
        List<Id> subscriberIds = new List<Id>();

        Contact con = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '415.555.1212');
        List<Contact> conList = new List<Contact>{ con };
        insert con;

        List<Subscriber__c> subscriberCon = [SELECT Name FROM Subscriber__c WHERE Contact__c = :con.Id];

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        Subscription__c parentSubscription = new Subscription__c(
            Subscription_Type__c = 'Business Unit',
            Name = 'ParentSub',
            Subscription_Description__c = 'Parent Sub Description',
            Available_for_Opt_In__c = true,
            Subscriber_Private_in_Salesforce__c = false
        );
        insert parentSubscription;

        List<Subscription__c> subscriptionList = new List<Subscription__c>();
        for (Integer i = 0; i < 1; i++) {
            Subscription__c subscription = new Subscription__c(
                Subscription_Type__c = 'List',
                Name = 'Sub' + i,
                Subscription_Description__c = 'Sub Description' + i,
                Subscriber_Private_in_Salesforce__c = false,
                Parent_Subscription__c = parentSubscription.Id
            );
            subscriptionList.add(subscription);
        }
        insert subscriptionList;

        List<Subscriber__c> subscribers = new List<Subscriber__c>();

        for (Subscription__c subscription : subscriptionList) {
            for (Contact contact : contacts) {
                Subscriber__c subscriber = new Subscriber__c(
                    Subscription__c = subscription.Id,
                    Contact__c = contact.Id,
                    Subscriber_Status__c = 'Subscribed'
                );
                subscribers.add(subscriber);
            }
        }
        for (Subscriber__c sub : subscribers) {
            subscriberIds.add(sub.Id);
            sub.HashSubscriberID__c = null;
        }
        insert subscribers;

        Test.startTest();
        fieldsToString = SubscriberService.subscriberFieldsToString();
        subscriberList = SubscriberService.getSubscribers(con.Id);
        SubscriberService.setHashIdNotFuture(subscriberIds);
        Test.stopTest();

        System.assertEquals(subscriberList.size(), subscriberCon.size());
    }
}
