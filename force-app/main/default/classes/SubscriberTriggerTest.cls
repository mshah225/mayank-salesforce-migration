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
    private static void test() {
        String res;
        List<Subscriber__c> l = new List<Subscriber__c>();
        List<Id> subscriberIds = new List<Id>();

        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        insert subscriptions;

        Contact con = new Contact(FirstName = 'Joe', LastName = 'Smith', Phone = '415.555.1212');
        List<Contact> conList = new List<Contact>{ con };
        insert con;
        List<Subscriber__c> subCon = TestDataFactory.createTestSubscribers(conList, subscriptions);
        insert subCon;
        List<Subscriber__c> subc = [SELECT Name FROM Subscriber__c WHERE Contact__c = :con.Id];

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<Subscriber__c> subscribers = TestDataFactory.createTestSubscribers(contacts, subscriptions);
        for (Subscriber__c sub : subscribers) {
            subscriberIds.add(sub.Id);
            sub.HashSubscriberID__c = null;
        }
        insert subscribers;

        Test.startTest();
        res = SubscriberService.subscriberFieldsToString();
        l = SubscriberService.getSubscribers(con.Id);
        SubscriberService.setHashIdNotFuture(subscriberIds);
        Test.stopTest();

        System.assertEquals(l.size(), subc.size());
    }
}
