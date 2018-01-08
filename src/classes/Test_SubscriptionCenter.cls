@isTest
private class Test_SubscriptionCenter {

    private static final String UNSUB = 'Unsubscribed';
    private static final String SUB = 'Subscribed';
    private static final String NA = 'No Preference';

    static Integer subscribedCount = 5;
    static Integer notSubscribedCount = 10;

    @testSetup
    static void testSetup() {
        Integer i = 0;

        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(subscribedCount);
        for (Subscription__c subscription: subscriptions)
        {
            i++;
            subscription.Name = 'Subscribed Sub ' + i;
            subscription.Available_for_Opt_In__c = true;
        }
        insert subscriptions;

        i = 0;
        List<Subscription__c> availableSubscriptions = TestDataFactory.createTestSubscriptions(notSubscribedCount);
        for (Subscription__c subscription: availableSubscriptions)
        {
            i++;
            subscription.Name = 'Available Sub ' + i;
            subscription.Available_for_Opt_In__c = true;
        }
        insert availableSubscriptions;

        // Rename the Parent subs so they're unique
        List<Subscription__c> parentSubList = new List<Subscription__c>();
        i = 0;
        for (Subscription__c sub: [SELECT Id, Name FROM Subscription__c WHERE Subscription_Type__c = 'Business Unit']) {
            i++;
            sub.Name = 'Parent' + i;
            parentSubList.add(sub);
        }
        update parentSubList;

        List<Contact> contacts = ContactService.createTestContacts(1);
        insert contacts;

        List<Subscriber__c> subscribers = TestDataFactory.createTestSubscribers(contacts, subscriptions);
        insert subscribers;

    }

    @isTest
    static void testMain() {
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', string.valueOf(subscriber));

        controller = new SubscriptionCenterController();

        Integer subCounter = 0;
        for (String key: controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }
        system.assertEquals(subscribedCount, subCounter);

        List<SubscriptionCenterController.SubscriberWrapper> availableSubList = new List<SubscriptionCenterController.SubscriberWrapper>();
        Integer availableSubCounter = 0;

        for (String key: controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        system.assertEquals(notSubscribedCount, availableSubCounter);

        system.debug('notSubbedBuSubIdToWrapperMap: ' + controller.notSubbedBuSubIdToWrapperMap);

        availableSubList[0].subscriberStatus = 'Subscribed';
        controller.updateSubscriptions();

        subCounter = 0;
        for (String key: controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }

        availableSubCounter = 0;
        for (String key: controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        system.assertEquals(subscribedCount + notSubscribedCount, subCounter);
        system.assertEquals(0, availableSubCounter);
    }

    @isTest
    static void testUnsubParent() {
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', string.valueOf(subscriber));

        controller = new SubscriptionCenterController();

        // Unsubscribe any subscribed Parent subs
        for (String key: controller.subbedBuSubIdToWrapperMap.keySet()) {
            controller.subbedBuSubIdToWrapperMap.get(key).subscriberStatus = 'Unsubscribed';
        }
        controller.updateSubscriptions();

        // Confirm that all Child subs have been unsubscribed
        List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed']);
        System.assertEquals(0, subList.size());
    }

    @isTest
    static void testSubParent() {
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', string.valueOf(subscriber));

        controller = new SubscriptionCenterController();

        Integer subCounter = 0;
        for (String key: controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }
        system.assertEquals(subscribedCount, subCounter);

        Set<Id> unsubbedParentSubIds = new Set<Id>();
        // Subscribe any unsubscribed Parent subs
        for (String key: controller.notSubbedBuSubIdToWrapperMap.keySet()) {
            controller.notSubbedBuSubIdToWrapperMap.get(key).subscriberStatus = 'Subscribed';
            unsubbedParentSubIds.add(key);
        }
        controller.updateSubscriptions();

        // Confirm that Parent subs have been subscribed
        List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id FROM Subscriber__c WHERE Subscription__c IN :unsubbedParentSubIds AND Subscriber_Status__c = 'Subscribed']);
        System.assert(subList.size() > 0);
    }

    @isTest
    static void testLead() {
        SubscriptionCenterController controller;
        Lead l = TestDataFactory.createLead('Sub');
        l.Email = 'tes9845345t@test.test';
        l.Company = 'None';
        l.Status = 'Prospect';
        l.Contact_Preference__c = 'Email';
        insert l;
        List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id, Contact__c, Lead__c FROM Subscriber__c]);
        for (Subscriber__c sub: subList) {
            sub.Contact__c = null;
            sub.Lead__c = l.Id;
        }
        update subList;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', string.valueOf(l.Id));

        controller = new SubscriptionCenterController();

        Integer subCounter = 0;
        for (String key: controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }
        system.assertEquals(subscribedCount, subCounter);

        List<SubscriptionCenterController.SubscriberWrapper> availableSubList = new List<SubscriptionCenterController.SubscriberWrapper>();
        Integer availableSubCounter = 0;

        for (String key: controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        system.assertEquals(notSubscribedCount, availableSubCounter);

        system.debug('notSubbedBuSubIdToWrapperMap: ' + controller.notSubbedBuSubIdToWrapperMap);

        availableSubList[0].subscriberStatus = 'Subscribed';
        controller.updateSubscriptions();

        subCounter = 0;
        for (String key: controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }

        availableSubCounter = 0;
        for (String key: controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        system.assertEquals(subscribedCount + notSubscribedCount, subCounter);
        system.assertEquals(0, availableSubCounter);
    }

    @isTest
    static void testDirectUnsubscribe() {
        SubscriptionCenterController controller;
        Id subscriberId = [SELECT Id FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed' LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('subscriberId', string.valueOf(subscriberId));

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([SELECT Id, Subscriber_Status__c FROM Subscriber__c WHERE Id = :subscriberId]);
        system.assertEquals('Unsubscribed', subCheck[0].Subscriber_Status__c);
    }

    @isTest
    static void testDirectUnsubscribeCampaign() {
        Subscriber__c subscriber = [SELECT Id, Subscription__c, Contact__c FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed' LIMIT 1];
        Campaign testCampaign = TestDataFactory.createCampaign('sub', Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Communication').getRecordTypeId());
        testCampaign.Subscription__c = subscriber.Subscription__c;
        insert testCampaign;

        SubscriptionCenterController controller;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('campaignId', string.valueOf(testCampaign.Id));
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber.Contact__c);

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([SELECT Id, Subscriber_Status__c FROM Subscriber__c WHERE Id = :subscriber   .Id]);
        system.assertEquals('Unsubscribed', subCheck[0].Subscriber_Status__c);
    }

    @isTest
    static void testDirectUnsubscribeSubIds() {
        Subscriber__c subscriber = [SELECT Id, Subscription__c, Contact__c FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed' LIMIT 1];

        SubscriptionCenterController controller;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('subscriptionId', subscriber.Subscription__c);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber.Contact__c);

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([SELECT Id, Subscriber_Status__c FROM Subscriber__c WHERE Id = :subscriber   .Id]);
        system.assertEquals('Unsubscribed', subCheck[0].Subscriber_Status__c);
    }

    @isTest
    static void testOptOut() {
        SubscriptionCenterController controller;
        Id subscriberId = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', string.valueOf(subscriberId));

        controller = new SubscriptionCenterController();
        controller.toggleOptOut();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([SELECT Id FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed']);
        Boolean contactHasOptedOutOfEmail = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id = :subscriberId].HasOptedOutOfEmail;
        system.assertEquals(0, subCheck.size());
        system.assertEquals(true, contactHasOptedOutOfEmail);
    }



    @isTest
    static void testFilterAvailableSubs() {
        SubscriptionCenterController controller;
        Id subscriberId = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', string.valueOf(subscriberId));

        controller = new SubscriptionCenterController();

        List<SubscriptionCenterController.SubscriberWrapper> availableSubList = new List<SubscriptionCenterController.SubscriberWrapper>();
        Integer availableSubCounter = 0;
        for (String key: controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        system.assertEquals(notSubscribedCount, availableSubCounter);

        controller.searchTerms = 'Available Sub ' + (notSubscribedCount - 1);
        controller.filterAvailableSubscriptions();

        availableSubCounter = 0;
        for (String key: controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
        }
        system.assertEquals(1, availableSubCounter);
    }

    @isTest
    static void testSubscriberWrapperConstructors() {
        SubscriptionCenterController controller;
        Subscriber__c subscriber = [SELECT Id, Subscription__c, Contact__c, Lead__c, Subscriber_Status__c,
                                           Subscription__r.Subscription_Center_Description__c,
                                           Subscription__r.Name
                                    FROM Subscriber__c LIMIT 1];

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber.Contact__c);

        controller = new SubscriptionCenterController();

        SubscriptionCenterController.SubscriberWrapper sw = new SubscriptionCenterController.SubscriberWrapper(subscriber);
        System.assertEquals(subscriber.Subscriber_Status__c, sw.subscriberStatus);
    }

}