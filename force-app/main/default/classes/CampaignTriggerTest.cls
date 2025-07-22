@isTest
public with sharing class CampaignTriggerTest {
    private static void setDefaultFeatureFlags() {
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Master', true);
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Autoset Start Time', true);
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Autoset End Time', true);
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Autoset Registration Time', true);
    }

    @isTest
    private static void testInsert() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(Name = 'Test Campaign');

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, HashCampaignID__c FROM Campaign];
        System.assertEquals(Hasher.hashId(c.Id), c.HashCampaignID__c);
    }

    @isTest
    private static void testPadPercentage() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(Name = 'Test Campaign');
        insert c;
        delete c;
        undelete c;
        update c;
    }

    // Test special case of time at noon
    @isTest
    private static void testNoonEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Event starts at noon',
            Normalized_Event_Start_Time__c = Time.newInstance(12, 0, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('noon', c.Event_Start_Time__c);
    }

    // Test scenario where event start is on the hour
    @isTest
    private static void test8amEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Event starts at 8 a.m.',
            Normalized_Event_Start_Time__c = Time.newInstance(8, 0, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('8 a.m.', c.Event_Start_Time__c);
    }

    // Test scenaro where event start has an hour and minute component, and is a.m.
    @isTest
    private static void test830amEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Event starts at 8:30 a.m.',
            Normalized_Event_Start_Time__c = Time.newInstance(8, 30, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('8:30 a.m.', c.Event_Start_Time__c);
    }

    // Test scenaro p.m.
    @isTest
    private static void test830pmEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Event starts at 8:30 p.m.',
            Normalized_Event_Start_Time__c = Time.newInstance(20, 30, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('8:30 p.m.', c.Event_Start_Time__c);
    }

    // Test scenaro 12:15 a.m. (just after midnight)
    @isTest
    private static void test1215amEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Event starts just after midnight',
            Normalized_Event_Start_Time__c = Time.newInstance(0, 15, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('12:15 a.m.', c.Event_Start_Time__c);
    }

    // Test scenaro 12:15 p.m. (just after noon)
    @isTest
    private static void test1215pmEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Event starts just after noon',
            Normalized_Event_Start_Time__c = Time.newInstance(12, 15, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('12:15 p.m.', c.Event_Start_Time__c);
    }

    // Test scenario for end time
    @isTest
    private static void test830amEventEndTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Event ends at 8:30 a.m.',
            Normalized_Event_End_Time__c = Time.newInstance(8, 30, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_End_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('8:30 a.m.', c.Event_End_Time__c);
    }

    // Test scenaro for registration time
    @isTest
    private static void test830amRegistrationTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(
            Name = 'Registration starts at 8:30 a.m.',
            Normalized_Registration_Time__c = Time.newInstance(8, 30, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Registration_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('8:30 a.m.', c.Registration_Time__c);
    }

    // Test scenaro on update
    @isTest
    private static void testUpdateEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(Name = 'Test event', Normalized_Event_Start_Time__c = Time.newInstance(8, 30, 0, 0));
        insert c;

        c.Normalized_Event_Start_Time__c = Time.newInstance(10, 30, 0, 0);

        Test.startTest();
        update c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual('10:30 a.m.', c.Event_Start_Time__c);
    }

    // Test scenaro on update (empty time)
    @isTest
    private static void testClearEventStartTime() {
        setDefaultFeatureFlags();
        Campaign c = new Campaign(Name = 'Test event', Normalized_Event_Start_Time__c = Time.newInstance(8, 30, 0, 0));
        insert c;

        c.Normalized_Event_Start_Time__c = null;

        Test.startTest();
        update c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual(null, c.Event_Start_Time__c);
    }

    // Test each auto flag being turned off
    @isTest
    private static void testDisabledFeatureFlags() {
        setDefaultFeatureFlags();
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Autoset Start Time', false);
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Autoset End Time', false);
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Autoset Registration Time', false);
        Campaign c = new Campaign(
            Name = 'Test event',
            Normalized_Event_Start_Time__c = Time.newInstance(8, 30, 0, 0),
            Normalized_Event_End_Time__c = Time.newInstance(8, 30, 0, 0),
            Normalized_Registration_Time__c = Time.newInstance(8, 30, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c, Event_End_Time__c, Registration_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual(null, c.Event_Start_Time__c);
        Assert.areEqual(null, c.Event_End_Time__c);
        Assert.areEqual(null, c.Registration_Time__c);
    }

    // Test master feature flag toggle being false
    @isTest
    private static void testDisabledMasterFeatureFlag() {
        setDefaultFeatureFlags();
        FeatureFlagService.overrideTestDefault('Campaign Trigger', 'Master', false);
        Campaign c = new Campaign(
            Name = 'Test event',
            Normalized_Event_Start_Time__c = Time.newInstance(8, 30, 0, 0),
            Normalized_Event_End_Time__c = Time.newInstance(8, 30, 0, 0),
            Normalized_Registration_Time__c = Time.newInstance(8, 30, 0, 0)
        );

        Test.startTest();
        insert c;
        Test.stopTest();

        c = [SELECT Id, Event_Start_Time__c, Event_End_Time__c, Registration_Time__c FROM Campaign WHERE Id = :c.Id];

        Assert.areEqual(null, c.Event_Start_Time__c);
        Assert.areEqual(null, c.Event_End_Time__c);
        Assert.areEqual(null, c.Registration_Time__c);
    }
}