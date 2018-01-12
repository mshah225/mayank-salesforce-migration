@isTest
private class SubscriptionCenterTest {
    private static final Integer SUBSCRIBED_COUNT = 5;
    private static Integer NOT_SUBSCRIBED_COUNT = 10;

    @testSetup
    private static void testSetup() {
        Integer i = 0;

        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(SUBSCRIBED_COUNT);
        for (Subscription__c subscription : subscriptions) {
            i++;
            subscription.Name = 'Subscribed Sub ' + i;
            subscription.Available_for_Opt_In__c = true;
        }
        insert subscriptions;

        i = 0;
        List<Subscription__c> availableSubscriptions = TestDataFactory.createTestSubscriptions(NOT_SUBSCRIBED_COUNT);
        for (Subscription__c subscription : availableSubscriptions) {
            i++;
            subscription.Name = 'Available Sub ' + i;
            subscription.Available_for_Opt_In__c = true;
        }
        insert availableSubscriptions;

        // Rename the Parent subs so they're unique
        List<Subscription__c> parentSubList = new List<Subscription__c>();
        i = 0;
        for (Subscription__c sub : [SELECT Id, Name FROM Subscription__c WHERE Subscription_Type__c = 'Business Unit']) {
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
    private static void testMain() {
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', String.valueOf(subscriber));

        controller = new SubscriptionCenterController();

        Integer subCounter = 0;
        for (String key : controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }
        System.assertEquals(SUBSCRIBED_COUNT, subCounter);

        List<SubscriptionCenterController.SubscriberWrapper> availableSubList = new List<SubscriptionCenterController.SubscriberWrapper>();
        Integer availableSubCounter = 0;

        for (String key: controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        System.assertEquals(NOT_SUBSCRIBED_COUNT, availableSubCounter);

        System.debug('notSubbedBuSubIdToWrapperMap: ' + controller.notSubbedBuSubIdToWrapperMap);

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
        System.assertEquals(SUBSCRIBED_COUNT + NOT_SUBSCRIBED_COUNT, subCounter);
        System.assertEquals(0, availableSubCounter);
    }

    @isTest
    private static void testUnsubParent() {
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', String.valueOf(subscriber));

        controller = new SubscriptionCenterController();

        // Unsubscribe any subscribed Parent subs
        for (String key : controller.subbedBuSubIdToWrapperMap.keySet()) {
            controller.subbedBuSubIdToWrapperMap.get(key).subscriberStatus = 'Unsubscribed';
        }
        controller.updateSubscriptions();

        // Confirm that all Child subs have been unsubscribed
        List<Subscriber__c> subList = new List<Subscriber__c>([
            SELECT Id 
            FROM Subscriber__c 
            WHERE Subscriber_Status__c = 'Subscribed'
        ]);
        System.assertEquals(0, subList.size());
    }

    @isTest
    private static void testSubParent() {
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', String.valueOf(subscriber));

        controller = new SubscriptionCenterController();

        Integer subCounter = 0;
        for (String key : controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }
        System.assertEquals(SUBSCRIBED_COUNT, subCounter);

        Set<Id> unsubbedParentSubIds = new Set<Id>();
        // Subscribe any unsubscribed Parent subs
        for (String key : controller.notSubbedBuSubIdToWrapperMap.keySet()) {
            controller.notSubbedBuSubIdToWrapperMap.get(key).subscriberStatus = 'Subscribed';
            unsubbedParentSubIds.add(key);
        }
        controller.updateSubscriptions();

        // Confirm that Parent subs have been subscribed
        List<Subscriber__c> subList = new List<Subscriber__c>([
            SELECT Id 
            FROM Subscriber__c 
            WHERE Subscription__c IN :unsubbedParentSubIds 
                AND Subscriber_Status__c = 'Subscribed'
        ]);
        System.assert(subList.size() > 0);
    }

    @isTest
    private static void testLead() {
        SubscriptionCenterController controller;
        Lead l = TestDataFactory.createLead('Sub');
        l.Email = 'tes9845345t@test.test';
        l.Company = 'None';
        l.Status = 'Prospect';
        l.Contact_Preference__c = 'Email';
        insert l;
        List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id, Contact__c, Lead__c FROM Subscriber__c]);
        for (Subscriber__c sub : subList) {
            sub.Contact__c = null;
            sub.Lead__c = l.Id;
        }
        update subList;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', String.valueOf(l.Id));

        controller = new SubscriptionCenterController();

        Integer subCounter = 0;
        for (String key : controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }
        System.assertEquals(SUBSCRIBED_COUNT, subCounter);

        List<SubscriptionCenterController.SubscriberWrapper> availableSubList = new List<SubscriptionCenterController.SubscriberWrapper>();
        Integer availableSubCounter = 0;

        for (String key : controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        System.assertEquals(NOT_SUBSCRIBED_COUNT, availableSubCounter);

        System.debug('notSubbedBuSubIdToWrapperMap: ' + controller.notSubbedBuSubIdToWrapperMap);

        availableSubList[0].subscriberStatus = 'Subscribed';
        controller.updateSubscriptions();

        subCounter = 0;
        for (String key : controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }

        availableSubCounter = 0;
        for (String key : controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        System.assertEquals(SUBSCRIBED_COUNT + NOT_SUBSCRIBED_COUNT, subCounter);
        System.assertEquals(0, availableSubCounter);
    }

    @isTest
    private static void testDirectUnsubscribe() {
        SubscriptionCenterController controller;
        Id subscriberId = [SELECT Id FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed' LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('subscriberId', String.valueOf(subscriberId));

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([
            SELECT Id, Subscriber_Status__c 
            FROM Subscriber__c 
            WHERE Id = :subscriberId
        ]);
        System.assertEquals('Unsubscribed', subCheck[0].Subscriber_Status__c);
    }

    @isTest
    private static void testDirectUnsubscribeCampaign() {
        Subscriber__c subscriber = [
            SELECT Id, Subscription__c, Contact__c 
            FROM Subscriber__c 
            WHERE Subscriber_Status__c = 'Subscribed' 
            LIMIT 1
        ];
        Campaign testCampaign = TestDataFactory.createCampaign(
            'sub', Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Communication').getRecordTypeId());
        testCampaign.Subscription__c = subscriber.Subscription__c;
        insert testCampaign;

        SubscriptionCenterController controller;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('campaignId', String.valueOf(testCampaign.Id));
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber.Contact__c);

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([
            SELECT Id, Subscriber_Status__c 
            FROM Subscriber__c 
            WHERE Id = :subscriber.Id
        ]);
        System.assertEquals('Unsubscribed', subCheck[0].Subscriber_Status__c);
    }

    @isTest
    private static void testDirectUnsubscribeSubIds() {
        Subscriber__c subscriber = [
            SELECT Id, Subscription__c, Contact__c 
            FROM Subscriber__c 
            WHERE Subscriber_Status__c = 'Subscribed' 
            LIMIT 1
        ];

        SubscriptionCenterController controller;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('subscriptionId', subscriber.Subscription__c);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber.Contact__c);

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([
            SELECT Id, Subscriber_Status__c 
            FROM Subscriber__c 
            WHERE Id = :subscriber.Id]);
        System.assertEquals('Unsubscribed', subCheck[0].Subscriber_Status__c);
    }

    @isTest
    private static void testOptOut() {
        SubscriptionCenterController controller;
        Id subscriberId = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', String.valueOf(subscriberId));

        controller = new SubscriptionCenterController();
        controller.toggleOptOut();

        List<Subscriber__c> subCheck = new List<Subscriber__c>([
            SELECT Id 
            FROM Subscriber__c 
            WHERE Subscriber_Status__c = 'Subscribed'
        ]);
        Boolean contactHasOptedOutOfEmail = [
            SELECT Id, HasOptedOutOfEmail 
            FROM Contact 
            WHERE Id = :subscriberId
        ].HasOptedOutOfEmail;
        System.assertEquals(0, subCheck.size());
        System.assertEquals(true, contactHasOptedOutOfEmail);
    }

    @isTest
    private static void testFilterAvailableSubs() {
        SubscriptionCenterController controller;
        Id subscriberId = [SELECT Id FROM Contact LIMIT 1].Id;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', String.valueOf(subscriberId));

        controller = new SubscriptionCenterController();

        List<SubscriptionCenterController.SubscriberWrapper> availableSubList = 
            new List<SubscriptionCenterController.SubscriberWrapper>();
        Integer availableSubCounter = 0;
        for (String key : controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
            availableSubList = controller.availableSubsByParentSubIdMap.get(key);
        }
        System.assertEquals(NOT_SUBSCRIBED_COUNT, availableSubCounter);

        controller.searchTerms = 'Available Sub ' + (NOT_SUBSCRIBED_COUNT - 1);
        controller.filterAvailableSubscriptions();

        availableSubCounter = 0;
        for (String key : controller.availableSubsByParentSubIdMap.keySet()) {
            availableSubCounter += controller.availableSubsByParentSubIdMap.get(key).size();
        }
        System.assertEquals(1, availableSubCounter);
    }

    @isTest
    private static void testSubscriberWrapperConstructors() {
        SubscriptionCenterController controller;
        Subscriber__c subscriber = [
            SELECT Id, Subscription__c, Contact__c, Lead__c, Subscriber_Status__c, 
                Subscription__r.Subscription_Center_Description__c, Subscription__r.Name
            FROM Subscriber__c 
            LIMIT 1
        ];

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber.Contact__c);

        controller = new SubscriptionCenterController();
        SubscriptionCenterController.SubscriberWrapper sw = 
            new SubscriptionCenterController.SubscriberWrapper(subscriber);
        System.assertEquals(subscriber.Subscriber_Status__c, sw.subscriberStatus);
    }
}