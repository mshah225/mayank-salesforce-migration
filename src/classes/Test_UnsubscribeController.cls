@isTest
public class Test_UnsubscribeController {
    @testSetup
    static void testSetup() {
        Id unsubscribeGuestUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Unsubscribe Profile' LIMIT 1].Id;
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

        businessUnit = [SELECT Id, (SELECT Id FROM ChildCampaigns) FROM Campaign WHERE ParentId = NULL];

        tempMember = TestDataFactory.createCampaignMember('', subscriber.Id, businessUnit.Id, true);
        members.add(tempMember);

        for (Campaign c : businessUnit.childCampaigns) {
            tempMember = TestDataFactory.createCampaignMember('', subscriber.Id, c.Id, true);
            members.add(tempMember);
        }

        insert members;
    }

    /**
     * Tests the Unsubscribe Controllers ability to unsubscribe campaign members
     * from category level campaigns
     */
    public static testMethod void Test_UnsubscribeFromCategory() {
        // Send campaigns are not visible in sub center
        // Send campaigns are children of cat campaigns and cat campaigns are children of BU Campaigns
        // So cat level send campaigns should have a parent and grandparent
        Campaign sendCampaign = [SELECT Id, parentId FROM Campaign WHERE parentId != NULL AND parent.parentId != NULL];
        Id unsubscribeGuestUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Unsubscribe Profile' LIMIT 1].Id;
        User guestUser = [SELECT Id FROM User WHERE ProfileId = :unsubscribeGuestUserProfileId]; // User who is not logged into SF
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id; // Should only be 1 existing contact created in testSetup
        List<CampaignMember> membersToSubscribe = new List<CampaignMember>(); // List of members to se IsSubscribed = true
        List<Case> errorCases; // Used to check for exceptions
        Campaign categoryCampaign; // Category campaign to unsubscribe from
        Campaign businessUnit;
        unsubscribeController controller; // not instantiated until test begins

        // Ensure all campaign members are subscribed
        for (CampaignMember cm : [SELECT Id, IsSubscribed__c FROM CampaignMember]) {
            cm.IsSubscribed__c = true;
            membersToSubscribe.add(cm);
        }

        update membersToSubscribe;

        PageReference unsubscribePage = Page.unsubscribe;
        Test.setCurrentPage(unsubscribePage);
        ApexPages.CurrentPage().getParameters().put('subId', string.valueOf(subscriber));
        ApexPages.CurrentPage().getParameters().put('campaignId', string.valueOf(sendCampaign.Id));

        System.runAs(guestUser) {
            Test.startTest();
            controller = new unsubscribeController();
            controller.optOutOfEmails();
            test.stopTest();
        }

        businessUnit = [
            SELECT Id, (SELECT Id FROM ChildCampaigns), (SELECT Id, IsSubscribed__c FROM CampaignMembers)
            FROM Campaign
            WHERE ParentId = NULL
        ];

        categoryCampaign = [
            SELECT Id, (SELECT Id, isSubscribed__c FROM CampaignMembers WHERE contactId = :subscriber)
            FROM Campaign
            WHERE Id = :sendCampaign.parentId
        ];

        // Verify no exceptions occured
        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        system.assertEquals(0, errorCases.size());

        // Verify subscriber was successfully unsubscribed from the category
        for (CampaignMember cm : categoryCampaign.campaignMembers) {
            system.assert(!cm.IsSubscribed__c);
        }

        // Verify that the Business Unit campaign member and the campaign member for the other category
        // Are not affected
        for (CampaignMember cm : businessUnit.campaignMembers) {
            system.assert(cm.IsSubscribed__c);
        }

        categoryCampaign = [
            SELECT Id, (SELECT Id, isSubscribed__c FROM CampaignMembers WHERE contactId = :subscriber)
            FROM Campaign
            WHERE
                Id != :sendCampaign.parentId
                AND parentId = :businessUnit.Id
                AND Visible_on_Subscription_Center__c = TRUE
        ];

        for (CampaignMember cm : CategoryCampaign.campaignMembers) {
            system.assert(cm.IsSubscribed__c);
        }
    }

    /**
     * Tests the Unsubscribe Controllers ability to unsubscribe campaign members
     * from Business unit Level send campaigns
     */
    public static testMethod void Test_UnsubscribeFromBusinessUnit() {
        // Business Units are top level (no parent)
        // Send campaigns are not visible to the subscription center
        Campaign sendCampaign = [
            SELECT Id, parentId
            FROM Campaign
            WHERE parentId != NULL AND parent.parentId = NULL AND Visible_on_Subscription_Center__c = FALSE
        ];
        Id subscriber = [SELECT Id FROM Contact LIMIT 1].Id; // Should only be 1 existing contact created in testSetup
        Id unsubscribeGuestUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Unsubscribe Profile' LIMIT 1].Id;
        User guestUser = [SELECT Id FROM User WHERE ProfileId = :unsubscribeGuestUserProfileId]; // User who is not logged into SF
        List<CampaignMember> membersToSubscribe = new List<CampaignMember>();
        List<Case> errorCases; // Used to verify correct number of exceptiosn occur
        Campaign businessUnit;
        unsubscribeController controller; // not instantiated until test begins

        // Ensure all campaign members are subscribed
        for (CampaignMember cm : [SELECT Id, IsSubscribed__c FROM CampaignMember]) {
            cm.IsSubscribed__c = true;
            membersToSubscribe.add(cm);
        }

        update membersToSubscribe;

        // Set up the page
        PageReference unsubscribePage = Page.unsubscribe;
        Test.setCurrentPage(unsubscribePage);
        ApexPages.CurrentPage().getParameters().put('subId', string.valueOf(subscriber));
        ApexPages.CurrentPage().getParameters().put('campaignId', string.valueOf(sendCampaign.Id));

        System.runAs(guestUser) {
            Test.startTest();
            controller = new unsubscribeController();
            controller.optOutOfEmails();
            test.stopTest();
        }

        //ToDo: verify that businessUnit and all category campaigns have been unsubscribed
        businessUnit = [
            SELECT
                Id,
                (SELECT Id, IsSubscribed__c FROM CampaignMembers WHERE contactId = :subscriber),
                (SELECT Id FROM ChildCampaigns WHERE Visible_on_Subscription_Center__c = TRUE)
            FROM Campaign
            WHERE parentId = NULL
        ];

        for (CampaignMember cm : businessUnit.campaignMembers) {
            system.assert(!cm.IsSubscribed__c);
        }

        for (Campaign c : businessUnit.childCampaigns) {
            for (Campaign cc : [
                SELECT Id, (SELECT Id, IsSubscribed__c FROM CampaignMembers WHERE ContactId = :subscriber)
                FROM Campaign
                WHERE Id = :c.Id
            ]) {
                for (CampaignMember cm : cc.campaignMembers) {
                    system.assert(!cm.IsSubscribed__c);
                }
            }
        }
    }

    /**
     * Tests the Unsubscribe Controllers ability handle exceptions
     */
    public static testMethod void Test_ExceptionHandling() {
        Id unsubscribeGuestUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Unsubscribe Profile' LIMIT 1].Id;
        User guestUser = [SELECT Id FROM User WHERE ProfileId = :unsubscribeGuestUserProfileId]; // User who is not logged into SF
        UnsubscribeController controller = new UnsubscribeController();
        List<Case> errorCases;

        System.runAs(guestUser) {
            Test.startTest();
            controller.optOutOfEmails();
            Test.stopTest();
        }

        errorCases = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];

        system.assertEquals(1, errorCases.size());
    }
}
