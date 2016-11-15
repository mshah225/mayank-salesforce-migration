@isTest
private class Test_SubscriptionCenter {
    
    @testSetup
    static void testSetup() {
        Id subscriptionCenterRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Subscription Center' LIMIT 1].Id;
        Id mcBuPublicGroupId = [SELECT Id FROM Group WHERE Type = 'Regular' LIMIT 1].Id;
        List<Campaign> campaigns = new List<Campaign>();
        List<CampaignMember> members = new List<CampaignMember>();
        CampaignMember tempMember;
        Campaign businessUnit;
        Contact subscriber;
        Marketing_Cloud_Business_Unit__c mcBu;
        
        mcBu = new Marketing_Cloud_Business_Unit__c();
        mcBu.Business_Unit_Public_Group_ID__c = mcBuPublicGroupId;
        mcBu.Name = 'Fake Bu';
        
        insert mcBu;
        
        for (Campaign c : TestDataFactory.createCampaigns(5, subscriptionCenterRecordTypeId)) {
            c.IsActive = true;
            c.Visible_on_Subscription_Center__c = true;
            c.Marketing_Cloud_Business_Unit__c = mcBu.Id;
            
            campaigns.add(c);
        }
        
        insert campaigns;
        
        //Index 0 is Bu
        campaigns[0].Visible_on_Subscription_Center__c = true;
        
        //Index 1 is Bu send
        campaigns[1].parentId = campaigns[0].Id;
        campaigns[1].Visible_on_Subscription_Center__c = false;
        
        //Index 2/3 are cats
        campaigns[2].parentId = campaigns[0].Id;
        campaigns[2].Visible_on_Subscription_Center__c = true;
        campaigns[3].parentId = campaigns[0].Id;
        campaigns[3].Visible_on_Subscription_Center__c = true;
        
        //Index 4 is cat (index 2) send
        campaigns[4].parentId = campaigns[2].Id;
        campaigns[4].Visible_on_Subscription_Center__c = false;
        
        update campaigns;
        
        //Contact to subscribe to all campaigns
        subscriber = TestDataFactory.createContact('Bobertopolus'); // @param is contact lastname
        
        insert subscriber;
        
        businessUnit = [SELECT Id, (SELECT Id FROM ChildCampaigns) FROM Campaign WHERE ParentId = null];
        
        tempMember = TestDataFactory.createCampaignMember('', subscriber.Id, businessUnit.Id, true);
        members.add(tempMember);
        
        for (Campaign c : businessUnit.childCampaigns) {
            tempMember = TestDataFactory.createCampaignMember('', subscriber.Id, c.Id, true);
            members.add(tempMember);
        }
        
        for (CampaignMember cm : members) {
            cm.IsSubscribed__c = true;
        }
        
        
        insert members;
    }
    
    /**
     * Tests the basic functionality of the subscription center
     */
    public static testMethod void Test_Main () {
        List<Case> errorCases;
        SubscriptionCenterController controller;
        User guestUser = [SELECT Id FROM User WHERE Profile.Name = 'Unsubscribe Profile'];
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;
        
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subId', string.valueOf(subscriber));
        
        controller = new SubscriptionCenterController();
        
        system.runAs(guestUser) {
	        // Test 1 - Run Init to populate sub tree
	        controller.Init();
        }
        
        // Test 1a - verify no errors occured
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(0, errorCases.size());
        
        //Test 1b - verify correct number of campaign members
        system.assertEquals(3, controller.subTree.getRecordsToUpsert().size());
        
        //Test 1c - verify subTree.show
        system.assert(controller.subTree.show);
        
        //Test 1d - verify Bu.show and sub.show
        //Test 2 - Unsubscribe from all campaigns
        for (SubscriptionCenterController.BusinessUnit bu : controller.subTree.buSubs.values()) {
            system.assert(bu.show);
            bu.sub.subscriber.IsSubscribed__c = false;
            system.assert(bu.show); //Should still show since cats are still subscribed
            
            for (SubscriptionCenterController.Subscription s : bu.catSubs.values()) {
                system.assert(s.show);
                s.subscriber.IsSubscribed__c = false;
                system.assert(!s.show); // Subscription should not be shown now that it is unsubscribed
            }
            
            system.assert(!bu.show); //Should not be shown now that all cats are unsubscribed
        }
        
        system.assert(!controller.subtree.show);
        
        //Test 3 - Verify update action
        // - UpsertSubtree calls Init() to repopulate subtree
        // - Check subtree to make sure all subscribers are unsubscribed
        system.runAs(guestUser) {
            controller.upsertSubtree();
        }
        
        for (SubscriptionCenterController.BusinessUnit bu : controller.subTree.buSubs.values()) {
            // Test 3a - Verifiy bu subscriber is unsubscribed
            system.assert(!bu.sub.subscriber.isSubscribed__c);
            
            for (SubscriptionCenterController.Subscription s : bu.catSubs.values()) {
                // Test 3b - Verify cat subscribers are unsubscribed
                system.assert(!s.subscriber.isSubscribed__c);
            }
        }
    }
    
    /**
     * Tests subscription centers ability to handle contacts with no existing campaign members
     */
    public static testMethod void Test_NewContact () {
        User guestUser = [SELECT Id FROM User WHERE Profile.Name = 'Unsubscribe Profile'];
        Contact subscriber = TestDataFactory.createContact('Nuts2Dalbey');
        List<Case> errorCases;
        SubscriptionCenterController controller;
        
        insert subscriber;
        
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subId', string.valueOf(subscriber.Id));
        
        controller = new SubscriptionCenterController();
        
        system.runAs(guestUser) {
            // Test 4 - Test init function on contact with no exiting campaign members
            controller.Init();
        }
        
        // Test 4a - Verify no errors occured
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(0, errorCases.size());
        
        // Test 4b - Verify subtree is not shown (new campaign members default to isSubscribed = false)
        system.assert(!controller.subTree.show);
        
        // Test 4c - Verify all subscriptions are false and that nothing should be shown
        for (SubscriptionCenterController.BusinessUnit bu : controller.subTree.buSubs.values()) {
            system.assert(!bu.sub.subscriber.isSubscribed__c);
            system.assert(!bu.show);
            
            for (SubscriptionCenterController.Subscription s : bu.catSubs.values()) {
                system.assert(!s.subscriber.isSubscribed__c);
                system.assert(!s.show);
            }
        }
    }
    
    /**
     * Tests subscription centers ability to handle leads with no existing campaign members
     */
    public static testMethod void Test_NewLead () {
        User guestUser = [SELECT Id FROM User WHERE Profile.Name = 'Unsubscribe Profile'];
        Lead subscriber = TestDataFactory.createLead('Nuts2Dalbey');
        List<Case> errorCases;
        SubscriptionCenterController controller;
        
        insert subscriber;
        
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subId', string.valueOf(subscriber.Id));
        
        controller = new SubscriptionCenterController();
        
        system.runAs(guestUser) {
            // Test 5 - Test init function on contact with no exiting campaign members
            controller.Init();
        }
        
        // Test 5a - Verify no errors occured
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(0, errorCases.size());
        
        // Test 5b - Verify subtree is not shown (new campaign members default to isSubscribed = false)
        system.assert(!controller.subTree.show);
        
        // Test 5c - Verify all subscriptions are false and that nothing should be shown
        for (SubscriptionCenterController.BusinessUnit bu : controller.subTree.buSubs.values()) {
            system.assert(!bu.sub.subscriber.isSubscribed__c);
            system.assert(!bu.show);
            
            for (SubscriptionCenterController.Subscription s : bu.catSubs.values()) {
                system.assert(!s.subscriber.isSubscribed__c);
                system.assert(!s.show);
            }
        }
    }
    
    /**
     * Tests subscription centers search function
     */
    public static testMethod void Test_DoSearch () {
        User guestUser = [SELECT Id FROM User WHERE Profile.Name = 'Unsubscribe Profile'];
        List<Case> errorCases;
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;
        List<Id> fakeResults = new List<Id>();
        
        for (Campaign c : [SELECT Id FROM Campaign]) {
            fakeResults.add(c.Id);
        }
        
        Test.setFixedSearchResults(fakeResults);
        
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subId', string.valueOf(subscriber));
        
        controller = new SubscriptionCenterController();
        
        system.runAs(guestUser) {
            controller.Init();
        }
        
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(0, errorCases.size());
        
        // Test 6 - verify search functionality
        controller.searchInput = 'Description For'; // Text retrieved from TestDataFactory
        
        system.runAs(guestUser) {
            controller.doSearch();
        }
        
        // Test 6a - Verify correct number of returned campaigns
        system.assertEquals(3, controller.searchResults.size());
        
        //Test 7 - Verify upsertSearchResults
        for (SubscriptionCenterController.Subscription s : controller.searchResults) {
            s.subscriber.isSubscribed__c = false;
        }
        
        system.runAs(guestUser) {
            controller.upsertSearchResults();
        }
        
        // Test 7a - verify no errors
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(0, errorCases.size());
        
        // Test 7b - Verify values in subtree
        for (SubscriptionCenterController.BusinessUnit bu : controller.subTree.buSubs.values()) {
            system.assert(!bu.sub.subscriber.isSubscribed__c);
            
            for (SubscriptionCenterController.Subscription s : bu.catSubs.values()) {
                system.assert(!s.subscriber.isSubscribed__c);
            }
        }
        
        // Test 7c - Subscribe to all search results, update and verify
        for (SubscriptionCenterController.Subscription s : controller.searchResults) {
            s.subscriber.isSubscribed__c = true;
        }
        
        system.runAs(guestUser) {
            controller.upsertSearchResults();
        }
        
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(0, errorCases.size());
        
        for (SubscriptionCenterController.BusinessUnit bu : controller.subTree.buSubs.values()) {
            system.assert(bu.sub.subscriber.isSubscribed__c);
            
            for (SubscriptionCenterController.Subscription s : bu.catSubs.values()) {
                system.assert(s.subscriber.isSubscribed__c);
            }
        }
        
        // Test 8 - Test DoSearche's exception handling
        // Due to limitations in SF, we cannot force an exception in this method during testing
        // (SOSL searchs don't actually run). However, due to other limitations in SF, we cannot
        // remove the exception handling code from this method (single character search strings
        // will throw an exception. Even if wildcards are included meaning we cannot simply use
        // string.size() to verify).
        
        // Test 9 - Test upsertSearchResult's abilityt o handle exceptions
        controller.searchResults = null;
        
        system.runAs(guestUser) {
            controller.upsertSearchResults();
        }
        
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(1, errorCases.size());
    }
    
    /**
     * Tests the basic error handling functionality of the subscription center
     */
    public static testMethod void Test_Init_ExceptionHandling () {
        List<Case> errorCases;
        SubscriptionCenterController controller;
        
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        
        controller = new SubscriptionCenterController();
        controller.Init();
        
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(1, errorCases.size());
        
        delete errorCases;
    }
    
    /**
     * Tests upsertSubtree's error handling ability
     */
    public static testMethod void Test_UpsertSubtree_ExceptionHandling () {
        List<Case> errorCases;
        SubscriptionCenterController controller;
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id;
        
        PageReference subscriptionCenterPage = Page.SubscriptionCenter;
        Test.setCurrentPage(subscriptionCenterPage);
        ApexPages.CurrentPage().getParameters().put('subId', string.valueOf(subscriber));
        
        controller = new SubscriptionCenterController();
        
        controller.upsertSubtree();
        
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        
        system.assertEquals(1, errorCases.size());
        
        delete errorCases;
    }
}