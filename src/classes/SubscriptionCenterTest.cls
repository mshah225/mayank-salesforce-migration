@isTest
private class SubscriptionCenterTest {
    private static final Integer SUBSCRIBED_COUNT = 5;
    private static final Integer NOT_SUBSCRIBED_COUNT = 10;

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
        for (Subscription__c sub : [
            SELECT Id, Name
            FROM Subscription__c
            WHERE Subscription_Type__c = 'Business Unit'
        ]) {
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
        String subscriber = [SELECT HashContactId__c FROM Contact LIMIT 1].HashContactId__c;
        String decodedHashContact = EncodingUtil.urlDecode(subscriber, 'UTF-8');
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', decodedHashContact);

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
    private static void findMatchOnContactId() {
        String subscriberKey = [SELECT Id FROM Contact LIMIT 1].Id;

        Test.setCurrentPage(Page.SubscriptionCenter);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriberKey);

        SubscriptionCenterController controller = new SubscriptionCenterController();

        Integer subCounter = 0;
        for (String key : controller.subsByParentSubIdMap.keySet()) {
            subCounter += controller.subsByParentSubIdMap.get(key).size();
        }
        System.assertEquals(SUBSCRIBED_COUNT, subCounter);
    }

    @isTest
    private static void testUnsubParent() {
        SubscriptionCenterController controller;
        String subscriber = [SELECT HashContactId__c FROM Contact LIMIT 1].HashContactId__c;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        subscriber = EncodingUtil.urlDecode(subscriber, 'UTF-8');
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber);

        controller = new SubscriptionCenterController();

        // Unsubscribe any subscribed Parent subs
        for (String key : controller.subbedBuSubIdToWrapperMap.keySet()) {
            controller.subbedBuSubIdToWrapperMap.get(key).subscriberStatus = 'Unsubscribed';
        }
        controller.updateSubscriptions();

        // Confirm that all Child subs have been unsubscribed
        List<Subscriber__c> subList = new List<Subscriber__c>(
            [SELECT Id FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed']
        );
        System.assertEquals(0, subList.size());
    }

    @isTest
    private static void testSubParent() {
        SubscriptionCenterController controller;
        String subscriber = [SELECT HashContactId__c FROM Contact LIMIT 1].HashContactId__c;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        subscriber = EncodingUtil.urlDecode(subscriber, 'UTF-8');
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber);

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
        List<Subscriber__c> subList = new List<Subscriber__c>(
            [
                SELECT Id
                FROM Subscriber__c
                WHERE Subscription__c IN :unsubbedParentSubIds AND Subscriber_Status__c = 'Subscribed'
            ]
        );
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
        Test.startTest();
        insert l;
        List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id, Contact__c, Lead__c FROM Subscriber__c]);
        for (Subscriber__c sub : subList) {
            sub.Contact__c = null;
            sub.Lead__c = l.Id;
        }
        update subList;
        Test.stopTest();
        String leadHash = [SELECT HashLeadId__c FROM Lead LIMIT 1].HashLeadId__c;
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        leadHash = EncodingUtil.urlDecode(leadHash, 'UTF-8');
        ApexPages.CurrentPage().getParameters().put('subscriberKey', leadHash);

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
        Subscriber__c subscriberIn = [
            SELECT HashSubscriberId__c
            FROM Subscriber__c
            WHERE Subscriber_Status__c = 'Subscribed'
            LIMIT 1
        ];

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        String decodedHashId = EncodingUtil.urlDecode(subscriberIn.HashSubscriberId__c, 'UTF-8');
        ApexPages.CurrentPage().getParameters().put('subscriberId', decodedHashId);

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>(
            [SELECT Id, Subscriber_Status__c FROM Subscriber__c WHERE Id = :subscriberIn.Id]
        );
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
        Test.startTest();
        Campaign testCampaign = TestDataFactory.createCampaign(
            'sub',
            Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Communication').getRecordTypeId()
        );
        testCampaign.Subscription__c = subscriber.Subscription__c;
        insert testCampaign;
        Test.stopTest();

        SubscriptionCenterController controller;

        testCampaign = [SELECT HashCampaignId__c FROM Campaign LIMIT 1];
        String decodedHashedContactId = EncodingUtil.urlDecode(Hasher.hashId(subscriber.Contact__c), 'UTF-8');
        String decodedHashedCampaignId = EncodingUtil.urlDecode(testCampaign.HashCampaignId__c, 'UTF-8');
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('campaignId', decodedHashedCampaignId);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriber.Contact__c);

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>(
            [SELECT Id, Subscriber_Status__c FROM Subscriber__c WHERE Id = :subscriber.Id]
        );
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

        String decodedContactHash = EncodingUtil.urlDecode(Hasher.hashId(subscriber.Contact__c), 'UTF-8');
        String decodedSubscriptionHash = EncodingUtil.urlDecode(Hasher.hashId(subscriber.Subscription__c), 'UTF-8');

        SubscriptionCenterController controller;

        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('action', 'unsubscribe');
        ApexPages.CurrentPage().getParameters().put('subscriptionId', decodedSubscriptionHash);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', decodedContactHash);

        controller = new SubscriptionCenterController();
        controller.doUnsubscribe();

        List<Subscriber__c> subCheck = new List<Subscriber__c>(
            [SELECT Id, Subscriber_Status__c FROM Subscriber__c WHERE Id = :subscriber.Id]
        );
        System.assertEquals('Unsubscribed', subCheck[0].Subscriber_Status__c);
    }

    @isTest
    private static void testOptOut() {
        SubscriptionCenterController controller;
        String subscriberId = [SELECT HashContactId__c FROM Contact LIMIT 1].HashContactId__c;
        String decodedHashedContact = EncodingUtil.urlDecode(subscriberId, 'UTF-8');
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', decodedHashedContact);

        controller = new SubscriptionCenterController();
        controller.toggleOptOut();

        List<Subscriber__c> subCheck = new List<Subscriber__c>(
            [SELECT Id FROM Subscriber__c WHERE Subscriber_Status__c = 'Subscribed']
        );
        Boolean contactHasOptedOutOfEmail = [
            SELECT Id, HasOptedOutOfEmail
            FROM Contact
            WHERE HashContactId__c = :subscriberId
        ]
        .HasOptedOutOfEmail;
        System.assertEquals(0, subCheck.size());
        System.assertEquals(true, contactHasOptedOutOfEmail);
    }

    @isTest
    private static void testFilterAvailableSubs() {
        SubscriptionCenterController controller;
        String subscriberId = [SELECT HashContactId__c FROM Contact LIMIT 1].HashContactId__c;
        subscriberId = EncodingUtil.urlDecode(subscriberId, 'UTF-8');
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', subscriberId);

        controller = new SubscriptionCenterController();

        List<SubscriptionCenterController.SubscriberWrapper> availableSubList = new List<SubscriptionCenterController.SubscriberWrapper>();
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
            SELECT
                Id,
                Subscription__c,
                Contact__c,
                Contact__r.HashContactId__c,
                Lead__c,
                Subscriber_Status__c,
                Subscription__r.Subscription_Center_Description__c,
                Subscription__r.Name
            FROM Subscriber__c
            LIMIT 1
        ];
        String decodedContactHash = EncodingUtil.urlDecode(subscriber.Contact__r.HashContactId__c, 'UTF-8');
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subscriberKey', decodedContactHash);

        controller = new SubscriptionCenterController();
        SubscriptionCenterController.SubscriberWrapper sw = new SubscriptionCenterController.SubscriberWrapper(
            subscriber
        );
        System.assertEquals(subscriber.Subscriber_Status__c, sw.subscriberStatus);
    }
}
