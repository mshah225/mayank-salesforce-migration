@isTest
private class Test_SubscriberTrigger {

/*
    // Create Test Subscriptions
    static List<Subscription__c> createTestSubscriptions(Integer qty)
    {
        List<Subscription__c> subscriptionList = new List<Subscription__c>();
        for (Integer i=0; i<qty; i++)
        {
            Subscription__c subscription = new Subscription__c(
                Subscription_Type__c = 'List',
                Name = 'Sub' + i,
                Subscription_Description__c = 'Sub Description' + i,
                Subscriber_Private_in_Salesforce__c = false
            );
            subscriptionList.add(subscription);
        }
        return subscriptionList;
    }

    // Create Test Group/Queue
    static Group createTestGroupAndQueue()
    {
        Group testGroup = new Group(Name = 'TestQueue', Type = 'Queue');
        insert testGroup;

        QueueSobject testQueue1 = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Subscription__c');
        QueueSobject testQueue2 = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Subscriber__c');
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueue1;
            insert testQueue2;
        }
        return testGroup;
    }
*/

    @isTest static void nonPrivateSubscriptionInsert()
    {
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        for (Subscription__c subscription: subscriptions)
        {
            subscription.Subscriber_Private_in_Salesforce__c = false;
        }
        insert subscriptions;

        List<Contact> contacts = ContactService.createTestContacts(5);
        insert contacts;

        List<Subscriber__c> subscribers = TestDataFactory.createTestSubscribers(contacts, subscriptions);
        Test.startTest();
        insert subscribers;
        Test.stopTest();

        for (Subscriber__c subscriber: [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c])
        {
            System.assertEquals(subscriber.OwnerId, subscriber.Apex_Owner_Should_Be__c, 'OwnerId was not set as expected');
        } 

    }

    @isTest static void privateSubscriptionInsert()
    {
        Group testGroup = TestDataFactory.createTestGroupAndQueue(new List<String>{'Subscription__c','Subscriber__c'});
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(1);
        for (Subscription__c subscription: subscriptions)
        {
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

        for (Subscriber__c subscriber: [SELECT Id, OwnerId, Apex_Owner_Should_Be__c FROM Subscriber__c])
        {
            System.assertEquals(subscriber.OwnerId, subscriber.Apex_Owner_Should_Be__c, 'OwnerId was not set as expected');
        }

    }


}