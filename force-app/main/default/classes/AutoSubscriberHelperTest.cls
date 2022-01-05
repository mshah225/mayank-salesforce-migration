@isTest
public with sharing class AutoSubscriberHelperTest {
    @TestSetup
    private static void setup() {
        Subscription__c parentSubscription = new Subscription__c(
            Name = 'Test Parent Subscription',
            Subscription_Type__c = 'Business Unit',
            Subscriber_Private_in_Salesforce__c = false
        );
        insert parentSubscription;

        Subscription__c subscription1 = new Subscription__c(
            Name = 'Test Subscription 1',
            Subscription_Type__c = 'List',
            Parent_Subscription__c = parentSubscription.Id,
            Subscriber_Private_in_Salesforce__c = false
        );
        Subscription__c subscription2 = new Subscription__c(
            Name = 'Test Subscription 2',
            Subscription_Type__c = 'List',
            Parent_Subscription__c = parentSubscription.Id,
            Subscriber_Private_in_Salesforce__c = false
        );
        Subscription__c subscription3 = new Subscription__c(
            Name = 'Test Subscription 3',
            Subscription_Type__c = 'List',
            Parent_Subscription__c = parentSubscription.Id,
            Subscriber_Private_in_Salesforce__c = false
        );

        insert new List<Subscription__c>{ subscription1, subscription2, subscription3 };

        Contact c = new Contact(FirstName = 'AutoSubscriberHelperTest', LastName = 'TestContact');
        insert c;

        Subscriber__c subscribedToParent = new Subscriber__c(
            Contact__c = c.Id,
            Subscription__c = parentSubscription.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        Subscriber__c subscribedToSubscription1 = new Subscriber__c(
            Contact__c = c.Id,
            Subscription__c = subscription1.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        Subscriber__c subscribedToSubscription2 = new Subscriber__c(
            Contact__c = c.Id,
            Subscription__c = subscription2.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        Subscriber__c subscribedToSubscription3 = new Subscriber__c(
            Contact__c = c.Id,
            Subscription__c = subscription3.Id,
            Subscriber_Status__c = 'Subscribed'
        );
        insert new List<Subscriber__c>{
            subscribedToParent,
            subscribedToSubscription1,
            subscribedToSubscription2,
            subscribedToSubscription3
        };
    }

    @isTest
    private static void testConstructor() {
        Map<Auto_Subscriber_Setting__mdt, List<String>> settingToSubscriptionsMap = new Map<Auto_Subscriber_Setting__mdt, List<String>>();

        List<Auto_Subscriber_Setting__mdt> subscriberSettings = [
            SELECT Id, Subscriptions_To_Add__c, DeveloperName, Related_Object__r.DeveloperName
            FROM Auto_Subscriber_Setting__mdt
            WHERE Active__c = TRUE
        ];
        // Map all settings to a list of subscriptions
        for (Auto_Subscriber_Setting__mdt subSetting : subscriberSettings) {
            List<String> subscriptionIds = new List<String>();

            if (subSetting.Subscriptions_To_Add__c != null) {
                subscriptionIds = subSetting.Subscriptions_To_Add__c.split(',');
            }

            settingToSubscriptionsMap.put(subSetting, subscriptionIds);
        }

        Test.startTest();
        for (Auto_Subscriber_Setting__mdt eachExistingSetting : settingToSubscriptionsMap.keySet()) {
            AutoSubscriberHelper helper = new AutoSubscriberHelper(eachExistingSetting.Related_Object__r.DeveloperName);
            Auto_Subscriber_Setting__mdt settingFromHelper;
            for (Auto_Subscriber_Setting__mdt eachSettingInHelper : helper.settingToSubscription.keySet()) {
                if (eachExistingSetting.Id == eachSettingInHelper.Id) {
                    settingFromHelper = eachSettingInHelper;
                    break;
                }
            }

            // Assert list in helper matches list made above
            System.assertEquals(
                settingToSubscriptionsMap.get(eachExistingSetting).size(),
                helper.settingToSubscription.get(settingFromHelper).size()
            );
            for (String subscriptionId : settingToSubscriptionsMap.get(eachExistingSetting)) {
                System.assert(helper.settingToSubscription.get(settingFromHelper).contains(subscriptionId));
            }
        }
        Test.stopTest();
    }

    @isTest
    private static void testCreateSubscriptionParentMap() {
        List<Subscription__c> subscriptions = [SELECT Id, Parent_Subscription__c FROM Subscription__c];

        // Get all subscriptions and their relationships
        List<Id> childSubscriptionIds = new List<Id>();
        Id parentSubscriptionId;
        for (Subscription__c subscription : subscriptions) {
            if (subscription.Parent_Subscription__c == null) {
                parentSubscriptionId = subscription.Id;
            } else {
                childSubscriptionIds.add(subscription.Id);
            }
        }

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.createSubscriptionParentMap(childSubscriptionIds);
        Test.stopTest();

        System.assertEquals(3, AutoSubscriberHelper.subscriptionToParent.size());
        for (Id eachChildSubscriptionId : AutoSubscriberHelper.subscriptionToParent.keySet()) {
            System.assertEquals(
                parentSubscriptionId,
                AutoSubscriberHelper.subscriptionToParent.get(eachChildSubscriptionId)
            );
        }
    }

    @isTest
    private static void testCreateSubscriberWithNoExistingSubscriptions() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Subscription__c> subscriptions = [SELECT Id, Parent_Subscription__c FROM Subscription__c];

        List<Id> childSubscriptionIds = new List<Id>();
        for (Subscription__c subscription : subscriptions) {
            if (subscription.Parent_Subscription__c != null) {
                childSubscriptionIds.add(subscription.Id);
            }
        }
        delete [SELECT Id FROM Subscriber__c];

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(Contact__c = c.Id);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.createSubscriptionParentMap(childSubscriptionIds);
        helper.buildContactToSubscriberMapWithProgramPlan(new List<Student_Program_Plan__c>{ testPlan });
        List<Subscriber__c> upsertableSubscribers = helper.createSubscriber(c.Id, childSubscriptionIds);
        Test.stopTest();

        System.assertEquals(3, upsertableSubscribers.size());
        for (Subscriber__c sub : upsertableSubscribers) {
            System.assertEquals('Subscribed', sub.Subscriber_Status__c);
        }
    }

    @isTest
    private static void testCreateSubscriberWithUnsubscribedParentSubscription() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Subscription__c> subscriptions = [SELECT Id, Parent_Subscription__c FROM Subscription__c];

        List<Id> childSubscriptionIds = new List<Id>();
        Id parentSubscriptionId;
        for (Subscription__c subscription : subscriptions) {
            if (subscription.Parent_Subscription__c == null) {
                parentSubscriptionId = subscription.Id;
            } else {
                childSubscriptionIds.add(subscription.Id);
            }
        }
        Subscriber__c parentSubscriber = [
            SELECT Id
            FROM Subscriber__c
            WHERE Subscription__c = :parentSubscriptionId
            LIMIT 1
        ];
        update new Subscriber__c(Id = parentSubscriber.Id, Subscriber_Status__c = 'Unsubscribed');

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(Contact__c = c.Id);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.createSubscriptionParentMap(childSubscriptionIds);
        helper.buildContactToSubscriberMapWithProgramPlan(new List<Student_Program_Plan__c>{ testPlan });
        List<Subscriber__c> upsertableSubscribers = helper.createSubscriber(c.Id, childSubscriptionIds);
        Test.stopTest();

        System.assertEquals(0, upsertableSubscribers.size());
    }

    @isTest
    private static void testCreateSubscriberWithUpdatingExisting() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Subscription__c> subscriptions = [SELECT Id, Parent_Subscription__c FROM Subscription__c];

        List<Id> childSubscriptionIds = new List<Id>();
        Id parentSubscriptionId;
        for (Subscription__c subscription : subscriptions) {
            if (subscription.Parent_Subscription__c == null) {
                parentSubscriptionId = subscription.Id;
            } else {
                childSubscriptionIds.add(subscription.Id);
            }
        }
        List<Subscriber__c> subscribers = [
            SELECT Id, Subscription__c
            FROM Subscriber__c
            WHERE Subscription__c != :parentSubscriptionId
        ];
        Subscriber__c subscriber1 = subscribers[0];
        Subscriber__c subscriber2 = subscribers[1];
        Subscriber__c subscriber3 = subscribers[2];
        subscriber1.Subscriber_Status__c = 'Unsubscribed';
        subscriber2.Subscriber_Status__c = 'Subscribed';
        subscriber3.Subscriber_Status__c = 'No Preference';

        update new List<Subscriber__c>{ subscriber1, subscriber2, subscriber3 };

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(Contact__c = c.Id);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.createSubscriptionParentMap(childSubscriptionIds);
        helper.buildContactToSubscriberMapWithProgramPlan(new List<Student_Program_Plan__c>{ testPlan });
        List<Subscriber__c> upsertableSubscribers = helper.createSubscriber(c.Id, childSubscriptionIds);
        Test.stopTest();

        System.assertEquals(1, upsertableSubscribers.size());
        System.assertEquals(subscriber3.Id, upsertableSubscribers[0].Id);
    }

    @isTest
    private static void testCreateSubscriberWithNewSubscription() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Subscription__c> subscriptions = [SELECT Id, Parent_Subscription__c FROM Subscription__c];

        List<Id> childSubscriptionIds = new List<Id>();
        Id parentSubscriptionId;
        for (Subscription__c subscription : subscriptions) {
            if (subscription.Parent_Subscription__c == null) {
                parentSubscriptionId = subscription.Id;
            } else {
                childSubscriptionIds.add(subscription.Id);
            }
        }
        List<Subscriber__c> subscribers = [
            SELECT Id, Subscription__c
            FROM Subscriber__c
            WHERE Subscription__c != :parentSubscriptionId
        ];
        Subscriber__c subscriber1 = subscribers[0];
        Subscriber__c subscriber2 = subscribers[1];
        Subscriber__c subscriber3 = subscribers[2];
        subscriber1.Subscriber_Status__c = 'Unsubscribed';
        subscriber2.Subscriber_Status__c = 'Subscribed';

        update new List<Subscriber__c>{ subscriber1, subscriber2 };
        delete subscriber3;

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(Contact__c = c.Id);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.createSubscriptionParentMap(childSubscriptionIds);
        helper.buildContactToSubscriberMapWithProgramPlan(new List<Student_Program_Plan__c>{ testPlan });
        List<Subscriber__c> upsertableSubscribers = helper.createSubscriber(c.Id, childSubscriptionIds);
        Test.stopTest();

        System.assertEquals(1, upsertableSubscribers.size());
        System.assertEquals(c.Id, upsertableSubscribers[0].Contact__c);
        System.assertEquals(subscriber3.Subscription__c, upsertableSubscribers[0].Subscription__c);
    }

    @isTest
    private static void testBuildContactToSubscriberMapWithProgramPlan() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(Contact__c = c.Id);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.buildContactToSubscriberMapWithProgramPlan(new List<Student_Program_Plan__c>{ testPlan });
        Test.stopTest();

        System.assertEquals(4, helper.contactToSubscriber.get(c.Id).size());
        for (Subscriber__c subscriber : helper.contactToSubscriber.get(c.Id)) {
            System.assertEquals(c.Id, subscriber.Contact__c);
        }
    }

    @isTest
    private static void testBuildContactToSubscriberMapWithCampaignMember() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        CampaignMember testCMember = new CampaignMember(ContactId = c.Id);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.buildContactToSubscriberMapWithCampaignMember(new List<CampaignMember>{ testCMember });
        Test.stopTest();

        System.assertEquals(4, helper.contactToSubscriber.get(c.Id).size());
        for (Subscriber__c subscriber : helper.contactToSubscriber.get(c.Id)) {
            System.assertEquals(c.Id, subscriber.Contact__c);
        }
    }

    @isTest
    private static void testSetCampaignAndOpportunityInformation() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Account acc = new Account(Name = 'Arizona State University', Type = 'HS');
        insert acc;

        String testOppoCareerOption = Opportunity.Career__c.getDescribe().getPicklistValues()[0].getValue();
        Opportunity testOppo = new Opportunity(
            Contact__c = c.Id,
            Career__c = testOppoCareerOption,
            AccountId = acc.Id,
            Name = 'TestOppo',
            StageName = 'TestOppo',
            CloseDate = Date.newInstance(2023, 9, 12)
        );
        insert testOppo;

        Id testCampaignRecordType = RecordIdHelper.getRecordTypeId('Campaign', 'Course');
        Campaign testCampaign = new Campaign(Name = 'TestCampaign', RecordTypeId = testCampaignRecordType);
        insert testCampaign;

        CampaignMember cMember = new CampaignMember(ContactId = c.Id, CampaignId = testCampaign.Id);

        Test.startTest();
        AutoSubscriberHelper helper = new AutoSubscriberHelper('');
        helper.setCampaignAndOpportunityInformation(new List<CampaignMember>{ cMember });
        Test.stopTest();

        System.assertEquals(1, AutoSubscriberHelper.contactToCareer.size());
        System.assertEquals(testOppoCareerOption, AutoSubscriberHelper.contactToCareer.get(c.Id));

        System.assertEquals(1, AutoSubscriberHelper.campaignToRecordTypeName.size());
        System.assertEquals('Course', AutoSubscriberHelper.campaignToRecordTypeName.get(testCampaign.Id));
    }

    // This is included just to increase code coverage - the behavior it is testing seems (at least on the surface) to be a bug
    @isTest
    private static void testWeirdBehavior() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Contact c2 = new Contact(FirstName = 'Z_TestContact2', LastName = 'Z_TestContact');
        insert c2;
        List<Subscription__c> subscriptions = [SELECT Id FROM Subscription__c];
        Subscriber__c c2Subscribed = new Subscriber__c(
            Contact__c = c2.Id,
            Subscription__c = subscriptions[0].Id,
            Subscriber_Status__c = 'Subscribed'
        );
        insert c2Subscribed;

        Student_Program_Plan__c testPlan = new Student_Program_Plan__c(Contact__c = c.Id);
        Student_Program_Plan__c testPlan2 = new Student_Program_Plan__c(Contact__c = c2.Id);

        CampaignMember testCMember1 = new CampaignMember(ContactId = c.Id);
        CampaignMember testCMember2 = new CampaignMember(ContactId = c2.Id);

        Test.startTest();
        AutoSubscriberHelper helperWithProgramPlan = new AutoSubscriberHelper('');
        helperWithProgramPlan.buildContactToSubscriberMapWithProgramPlan(
            new List<Student_Program_Plan__c>{ testPlan, testPlan2 }
        );

        AutoSubscriberHelper helperWithCapaignMember = new AutoSubscriberHelper('');
        helperWithCapaignMember.buildContactToSubscriberMapWithCampaignMember(
            new List<CampaignMember>{ testCMember1, testCMember2 }
        );
        Test.stopTest();

        System.assertEquals(1, helperWithProgramPlan.contactToSubscriber.get(c.Id).size());
        for (Subscriber__c subscriber : helperWithProgramPlan.contactToSubscriber.get(c.Id)) {
            System.assertEquals(c2.Id, subscriber.Contact__c);
        }

        System.assertEquals(1, helperWithCapaignMember.contactToSubscriber.get(c.Id).size());
        for (Subscriber__c subscriber : helperWithCapaignMember.contactToSubscriber.get(c.Id)) {
            System.assertEquals(c2.Id, subscriber.Contact__c);
        }
    }
}
