@isTest
private class SubscriberTriggerTest {
    @TestSetup
    private static void setup() {
        et4ae5__Business_Unit__c businessUnit = new et4ae5__Business_Unit__c(
            et4ae5__Business_Unit_ID__c = 'T000001',
            et4ae5__Enabled__c = true,
            Name = 'TestBU'
        );
        insert businessUnit;

        Subscription__c parentSubscription = new Subscription__c(
            Subscription_Type__c = 'Business Unit',
            Business_Unit__c = businessUnit.Id,
            Name = 'TestParentSubscription',
            Subscription_Description__c = 'Test Parent Subscription Description',
            Available_for_Opt_In__c = true,
            Subscriber_Private_in_Salesforce__c = false
        );
        insert parentSubscription;

        Subscription__c subscription = new Subscription__c(
            Subscription_Type__c = 'List',
            Name = 'TestSubscription',
            Subscription_Description__c = 'Test Subscription Description',
            Parent_Subscription__c = parentSubscription.Id,
            Subscriber_Private_in_Salesforce__c = false
        );
        insert subscription;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(
                new Contact(
                    FirstName = 'Test-' + i,
                    LastName = 'Test-Contact',
                    Email = 'test.contact.' + i + '@test.test'
                )
            );
        }
        insert contacts;

        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            leads.add(
                new Lead(
                    LastName = 'Test-' + i + '-Lead',
                    Company = 'Test-' + i + '-Lead',
                    Email = 'test.lead.' + i + '@test.test'
                )
            );
        }
        insert leads;
    }

    @isTest
    private static void testNonPrivateSubscriberOwnerMatchSubscription() {
        List<Contact> contacts = [SELECT Id FROM Contact];

        Subscription__c subscription = [SELECT Id FROM Subscription__c WHERE Parent_Subscription__c != NULL LIMIT 1];
        subscription.Subscriber_Private_in_Salesforce__c = false;
        update subscription;

        List<Subscriber__c> subscribers = new List<Subscriber__c>();
        for (Contact c : contacts) {
            subscribers.add(
                new Subscriber__c(
                    Subscription__c = subscription.Id,
                    Contact__c = c.Id,
                    Subscriber_Status__c = 'Subscribed'
                )
            );
        }

        Test.startTest();
        insert subscribers;
        Test.stopTest();

        Set<Id> subscriberIds = new Set<Id>();
        for (Subscriber__c subscriber : subscribers) {
            subscriberIds.add(subscriber.Id);
        }

        subscribers = [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c WHERE Id IN :subscriberIds];
        System.assert(!subscribers.isEmpty());
        for (Subscriber__c subscriber : subscribers) {
            System.assertEquals(
                subscriber.Apex_Owner_Should_Be__c,
                subscriber.OwnerId,
                'OwnerId was not set as expected'
            );
        }
    }

    @isTest
    private static void testPrivateSubscriberOwnerMatchSubscription() {
        User runasUser = new User(Id = UserInfo.getUserId());

        Group testGroup = new Group(Name = 'TestQueueIER', Type = 'Queue');
        insert testGroup;

        List<QueueSObject> queueSObjects = new List<QueueSObject>();
        queueSObjects.add(new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Subscription__c'));
        queueSObjects.add(new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Subscriber__c'));
        System.runAs(runasUser) {
            insert queueSObjects;
        }

        List<Contact> contacts = [SELECT Id FROM Contact];

        Subscription__c subscription = [SELECT Id FROM Subscription__c WHERE Parent_Subscription__c != NULL LIMIT 1];
        subscription.OwnerId = testGroup.Id;
        subscription.Subscriber_Private_in_Salesforce__c = true;
        update subscription;

        List<Subscriber__c> subscribers = new List<Subscriber__c>();
        for (Contact c : contacts) {
            subscribers.add(
                new Subscriber__c(
                    Subscription__c = subscription.Id,
                    Contact__c = c.Id,
                    Subscriber_Status__c = 'Subscribed'
                )
            );
        }

        Test.startTest();
        insert subscribers;
        Test.stopTest();

        Set<Id> subscriberIds = new Set<Id>();
        for (Subscriber__c subscriber : subscribers) {
            subscriberIds.add(subscriber.Id);
        }

        subscribers = [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c WHERE Id IN :subscriberIds];
        System.assert(!subscribers.isEmpty());
        for (Subscriber__c subscriber : subscribers) {
            System.assertEquals(subscription.OwnerId, subscriber.OwnerId, 'OwnerId was not set as expected');
        }
    }

    @isTest
    private static void testAutoSubscribeToParentForNewSubscriber() {
        Subscription__c subscription = [
            SELECT Id, Parent_Subscription__c
            FROM Subscription__c
            WHERE Parent_Subscription__c != NULL
            LIMIT 1
        ];

        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Lead l = [SELECT Id FROM Lead LIMIT 1];

        Subscriber__c contactSubscriber = new Subscriber__c(
            Subscription__c = subscription.Id,
            Contact__c = c.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        Subscriber__c leadSubscriber = new Subscriber__c(
            Subscription__c = subscription.Id,
            Lead__c = l.Id,
            Subscriber_Status__c = 'Subscribed'
        );

        Test.startTest();
        insert new List<Subscriber__c>{ contactSubscriber, leadSubscriber };
        Test.stopTest();

        List<Subscriber__c> subscribers = [
            SELECT Id, Subscriber_Status__c
            FROM Subscriber__c
            WHERE Subscription__c = :subscription.Parent_Subscription__c AND (Contact__c = :c.Id OR Lead__c = :l.Id)
        ];
        System.assertEquals(2, subscribers.size(), 'Didn\'t create parent subscriptions');
        for (Subscriber__c sub : subscribers) {
            System.assertEquals('Subscribed', sub.Subscriber_Status__c, 'Didn\'t auto-subscriber to parent');
        }
    }

    @isTest
    private static void testAutoSubscribeToParentForExistingSubscriber() {
        Subscription__c subscription, parentSubscription;
        List<Subscription__c> subscriptions = [SELECT Id, Parent_Subscription__c FROM Subscription__c];
        for (Subscription__c sub : subscriptions) {
            if (sub.Parent_Subscription__c != null) {
                subscription = sub;
            } else {
                parentSubscription = sub;
            }
        }

        // Add extra child subscription to ensure parent doesn't get double updated
        Subscription__c subscription2 = new Subscription__c(
            Subscription_Type__c = 'List',
            Name = 'TestSubscription',
            Subscription_Description__c = 'Test Subscription Description',
            Parent_Subscription__c = parentSubscription.Id,
            Subscriber_Private_in_Salesforce__c = false
        );
        insert subscription2;

        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Lead l = [SELECT Id FROM Lead LIMIT 1];

        Subscriber__c contactParentSubscriber = new Subscriber__c(
            Subscription__c = parentSubscription.Id,
            Contact__c = c.Id,
            Subscriber_Status__c = 'Unsubscribed'
        );
        Subscriber__c leadParentSubscriber = new Subscriber__c(
            Subscription__c = parentSubscription.Id,
            Lead__c = l.Id,
            Subscriber_Status__c = 'Unsubscribed'
        );
        insert new List<Subscriber__c>{ contactParentSubscriber, leadParentSubscriber };

        SubscriberService.parentSubsSynced = false; // Reset so it can run parentSubSync after inserting child

        // Two for contact, two for lead
        Subscriber__c contactSubscriber = new Subscriber__c(
            Subscription__c = subscription.Id,
            Contact__c = c.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        Subscriber__c contactSubscriber2 = new Subscriber__c(
            Subscription__c = subscription2.Id,
            Contact__c = c.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        Subscriber__c leadSubscriber = new Subscriber__c(
            Subscription__c = subscription.Id,
            Lead__c = l.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        Subscriber__c leadSubscriber2 = new Subscriber__c(
            Subscription__c = subscription2.Id,
            Lead__c = l.Id,
            Subscriber_Status__c = 'Subscribed'
        );

        Test.startTest();
        insert new List<Subscriber__c>{ contactSubscriber, contactSubscriber2, leadSubscriber, leadSubscriber2 };
        Test.stopTest();

        List<Subscriber__c> subscribers = [
            SELECT Id, Subscriber_Status__c
            FROM Subscriber__c
            WHERE Subscription__c = :subscription.Parent_Subscription__c AND (Contact__c = :c.Id OR Lead__c = :l.Id)
        ];
        System.assertEquals(2, subscribers.size(), 'Didn\'t create parent subscriptions');
        for (Subscriber__c sub : subscribers) {
            System.assertEquals('Subscribed', sub.Subscriber_Status__c, 'Didn\'t auto-subscriber to parent');
        }
    }

    @isTest
    private static void testAutoSubscribeToParentUponUnDeletion() {
        Subscription__c subscription = [
            SELECT Id, Parent_Subscription__c
            FROM Subscription__c
            WHERE Parent_Subscription__c != NULL
            LIMIT 1
        ];

        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Subscriber__c subscriber = new Subscriber__c(
            Subscription__c = subscription.Id,
            Contact__c = c.Id,
            Subscriber_Status__c = 'Subscribed'
        );

        // Use start and stop test to ensure completes @future calls
        Test.startTest();
        insert subscriber;
        Test.stopTest();
        delete subscriber;

        // Delete auto created parent
        Subscriber__c parentSubscriber = [
            SELECT Id
            FROM Subscriber__c
            WHERE Subscription__c = :subscription.Parent_Subscription__c AND Contact__c = :c.Id
        ];
        delete parentSubscriber;

        SubscriberService.parentSubsSynced = false; // Reset so it can run parentSubSync after undeleting child

        undelete subscriber;

        List<Subscriber__c> subscribers = [
            SELECT Id, Subscriber_Status__c
            FROM Subscriber__c
            WHERE Subscription__c = :subscription.Parent_Subscription__c AND Contact__c = :c.Id
        ];
        System.assertEquals(1, subscribers.size(), 'Didn\'t create parent subscriptions');
        for (Subscriber__c sub : subscribers) {
            System.assertEquals('Subscribed', sub.Subscriber_Status__c, 'Didn\'t auto-subscriber to parent');
        }
    }

    @isTest
    private static void testSetHashId() {
        Subscription__c subscription = [SELECT Id FROM Subscription__c LIMIT 1];

        List<Contact> contacts = [SELECT Id FROM Contact];

        List<Subscriber__c> subscribers = new List<Subscriber__c>();
        for (Contact c : contacts) {
            subscribers.add(
                new Subscriber__c(
                    Subscription__c = subscription.Id,
                    Contact__c = c.Id,
                    Subscriber_Status__c = 'Subscribed'
                )
            );
        }

        Test.startTest();
        insert subscribers;
        Test.stopTest();

        subscribers = [SELECT Id, HashSubscriberID__c FROM Subscriber__c];
        System.assert(!subscribers.isEmpty());
        for (Subscriber__c subscriber : subscribers) {
            System.assertEquals(
                Hasher.hashId(subscriber.Id),
                subscriber.HashSubscriberID__c,
                'Didn\'t properly set hash id'
            );
        }
    }

    @isTest
    private static void testSetHashIdFuture() {
        Test.startTest();
        insertSubscriptionsInFuture(); // to ensure doesn't call future method within future context
        Test.stopTest();

        List<Subscriber__c> subscribers = [SELECT Id, HashSubscriberID__c FROM Subscriber__c];
        System.assert(!subscribers.isEmpty());
        for (Subscriber__c subscriber : subscribers) {
            System.assertEquals(
                Hasher.hashId(subscriber.Id),
                subscriber.HashSubscriberID__c,
                'Didn\'t properly set hash id'
            );
        }
    }

    @future
    private static void insertSubscriptionsInFuture() {
        Subscription__c subscription = [SELECT Id FROM Subscription__c LIMIT 1];

        List<Contact> contacts = [SELECT Id FROM Contact];

        List<Subscriber__c> subscribers = new List<Subscriber__c>();
        for (Contact c : contacts) {
            subscribers.add(
                new Subscriber__c(
                    Subscription__c = subscription.Id,
                    Contact__c = c.Id,
                    Subscriber_Status__c = 'Subscribed'
                )
            );
        }
        insert subscribers;
    }
}
