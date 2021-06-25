@isTest
private class Test_CampaignMemberManagementController {
    private static ApexPages.standardController std;
    private static CampaignMemberManagementController cm;

    @testSetup
    static void setUp() {
        List<Campaign> campaignList = new List<Campaign>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<CampaignMemberStatus> campaignMemberStatusList = new List<CampaignMemberStatus>();

        Id crRecId = [SELECT Id FROM RecordType WHERE Name = 'Corporate Relations' AND SobjectType = 'Campaign'].Id;

        Contact testContact = ContactService.createTestContact();
        insert testContact;

        // Create some test Campaigns to add the Contact to
        List<Campaign> camList = CampaignService.createTestCampaigns();
        insert camList;

        // After insert, query back for those Campaigns to grab the Ids too
        List<Campaign> camListWithIds = [
            SELECT Id, Name, RecordType.Name, RecordTypeId
            FROM Campaign
            WHERE Status = 'Active'
        ];

        // Create test Location__c
        Location__c tempe = new Location__c(Name = 'Tempe Campus', Location_Code__c = 'TEMPE');
        insert tempe;

        // Add the Contact to the Campaigns
        List<CampaignMember> camMemList = CampaignMemberService.createTestCampaignMembers(
            testContact.Id,
            camListWithIds
        );
        insert camMemList;

        // Create some test Campaigns the contact is not currently a part of for searching
        List<Campaign> events = CampaignService.createTestCampaignOfType(5, 'Event');

        for (Campaign eCam : events) {
            eCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);
            eCam.Requested__c = 'Barret The Honors College';
            eCam.Campus_Location__c = tempe.Id;
        }

        insert events;

        List<Campaign> interests = CampaignService.createTestCampaignOfType(5, 'Interest');

        for (Campaign iCam : events) {
            iCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);
            iCam.Requested__c = 'Barret The Honors College';
            iCam.Campus_Location__c = tempe.Id;
        }

        insert interests;

        // Create Corporate Relations Campaigns for Testing
        List<Campaign> tempCrCamList = new List<Campaign>();
        List<CampaignMember> crCamMemsToInsert = new List<CampaignMember>();

        List<Campaign> crs = CampaignService.createTestCampaignOfType(5, 'Corporate Relations');

        for (Campaign cCam : crs) {
            cCam.Name = cCam.Name + ' Parent CR';
            cCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);
            cCam.Type = 'Corporate Relations';
            cCam.RecordTypeId = crRecId;
        }

        insert crs;

        // Query back for the CR Campaigns so we can create children
        List<Campaign> parents = [SELECT Id, Name, RecordType.Name FROM Campaign WHERE Name LIKE '%Parent CR'];

        tempCrCamList.addAll(parents);

        // Create multiple child campaigns for each parent
        for (Campaign parent : parents) {
            List<Campaign> tempChildren = CampaignService.createTestCampaignOfType(2, 'Corporate Relations');

            for (Campaign child : tempChildren) {
                child.Name = child.Name = ' Child CR';
                child.Event_Start_Date__c = date.newinstance(2016, 3, 28);
                child.Type = 'Corporate Relations';
                child.RecordTypeId = crRecId;
                child.ParentId = parent.Id;
            }

            tempCrCamList.addAll(tempChildren);
        }

        upsert tempCrCamList;

        // Query back for the inserted campaigns so we have the ids
        List<Campaign> camsToAddStatuses = [
            SELECT Id, Name, RecordType.Name
            FROM Campaign
            WHERE RecordType.Name = 'Corporate Relations' AND Id NOT IN :camListWithIds
        ];

        List<CampaignMemberStatus> cmStatuses = new List<CampaignMemberStatus>();

        for (Campaign camToAddStatusToAdd : camsToAddStatuses) {
            CampaignMemberStatus cmActive1 = new CampaignMemberStatus(
                CampaignId = camToAddStatusToAdd.Id,
                IsDefault = true,
                SortOrder = 3,
                Label = 'Active'
            );

            CampaignMemberStatus cmInactive1 = new CampaignMemberStatus(
                CampaignId = camToAddStatusToAdd.Id,
                IsDefault = true,
                SortOrder = 4,
                Label = 'Inactive'
            );

            cmStatuses.add(cmActive1);
            cmStatuses.add(cmInactive1);
        }

        camsToAddStatuses[0].Status = 'Active';
        camsToAddStatuses[13].Status = 'Inactive';
        insert cmStatuses;

        // Add the contact to only the back 5 campaigns, so we get some results during search.
        List<Campaign> camsToAddToContact = new List<Campaign>();

        for (Integer i = 9; i < 15; i++) {
            camsToAddToContact.add(camsToAddStatuses[i]);
        }

        crCamMemsToInsert = CampaignMemberService.createTestCampaignMembers(testContact.Id, camsToAddToContact);
        insert crCamMemsToInsert;

        // Add test Subscription records
        List<Subscription__c> subscriptions = TestDataFactory.createTestSubscriptions(5);
        for (Subscription__c subscription : subscriptions) {
            subscription.Subscriber_Private_in_Salesforce__c = false;
        }
        insert subscriptions;

        // Add test Subscriber records
        List<Subscriber__c> subscribers = TestDataFactory.createTestSubscribers(
            new List<Contact>{ testContact },
            subscriptions
        );
        insert subscribers;

        // Add test Business Units (Marketing Cloud)
        List<et4ae5__Business_Unit__c> buList = TestDataFactory.createBusinessUnits(1);
        for (et4ae5__Business_Unit__c bu : buList) {
            bu.IER_Private_in_Salesforce__c = false;
        }
        insert buList;

        // Add test Email Send Definitions (Marketing Cloud)
        List<et4ae5__SendDefinition__c> sdList = TestDataFactory.createEmailSends(5, 'Send Definition');
        for (et4ae5__SendDefinition__c sd : sdList) {
            sd.et4ae5__Business_Unit__c = buList[0].Id;
        }
        insert sdList;

        // Add test Individual Email Results (Marketing Cloud)
        List<et4ae5__IndividualEmailResult__c> ierList = TestDataFactory.createTestIERs(
            new List<Contact>{ testContact },
            sdList
        );
        insert ierList;
    }

    @isTest
    static void testEventsAndInterest() {
        Contact tempContact = [SELECT Id, Name FROM Contact LIMIT 1];

        Campaign eventCam = [
            SELECT Id, Name
            FROM Campaign
            WHERE RecordType.Name = 'Event' AND Name LIKE '%Test Campaign%'
            LIMIT 1
        ];

        Campaign intCam = [
            SELECT Id, Name
            FROM Campaign
            WHERE RecordType.Name = 'Interest' AND Name LIKE '%Test Campaign%'
            LIMIT 1
        ];

        Location__c tempe = [SELECT Id, Name FROM Location__c WHERE Name = 'Tempe Campus'];

        eventCam.Requested__c = 'Barret The Honors College';
        eventCam.Campus_Location__c = tempe.Id;
        eventCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);

        Id[] fixedSearchResults = new List<Id>(2);
        fixedSearchResults[0] = eventCam.Id;
        fixedSearchResults[1] = intCam.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        Test.setCurrentPage(Page.CampaignMemberManagement);
        System.currentPageReference().getParameters().put('Id', tempContact.Id);

        Test.startTest();

        std = new ApexPages.standardController(tempContact);
        cm = new CampaignMemberManagementController(std);

        cm.getEventList();
        cm.getInterestList();
        cm.getScholarList();
        cm.getCohortList();
        cm.getoSourceList();
        cm.getMarkCommList();
        cm.getPartCourseList();
        cm.getDepartmentsColleges();
        cm.getSelectedEventCamMemStatuses();

        // Test add to event
        cm.eSearchString = '';
        cm.doEventSearch();
        cm.eSearchString = 'test';
        cm.deptColl = 'Barret The Honors College';
        cm.tempCampaign.Campus_Location__c = tempe.Id;
        cm.camStartDate = date.newinstance(2016, 3, 28);
        cm.doEventSearch();
        cm.elId = cm.eventSearchResults[0].Id;
        cm.AddToEvent();
        cm.camMemEvent.Status = 'Sent';
        cm.AddToEvent();

        // Test add to interest
        cm.iSearchString = '';
        cm.doInterestSearch();
        cm.iSearchString = 'test';
        cm.doInterestSearch();
        cm.intId = cm.interestSearchResults[0].Id;
        cm.AddInterest();

        CampaignMember checkEventTestContact = [
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :tempContact.Id
            LIMIT 1
        ];

        CampaignMember checkIntTestContact = [
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :tempContact.Id
            LIMIT 1
        ];

        Test.stopTest();

        System.AssertEquals(checkEventTestContact.ContactId, tempContact.Id);
        System.AssertEquals(checkIntTestContact.ContactId, tempContact.Id);
    }

    @isTest
    public static void testCorporateRelations() {
        Contact tempContact = [SELECT Id, Name FROM Contact LIMIT 1];

        List<Campaign> crCamParents = [SELECT Id, Name FROM Campaign WHERE Name LIKE '%Parent CR' AND ParentId = NULL];

        List<Campaign> crChilds = [SELECT Id, Name FROM Campaign WHERE ParentId IN :crCamParents];

        List<Campaign> allCRCams = new List<Campaign>();
        allCRCams.addAll(crCamParents);
        allCRCams.addAll(crChilds);

        Integer listSize = crCamParents.size() + crChilds.size();

        Id[] fixedSearchResults = new List<Id>(listSize);

        for (Integer i = 0; i < listSize; i++) {
            fixedSearchResults[i] = allCRCams[i].Id;
        }

        Test.setFixedSearchResults(fixedSearchResults);
        Test.setCurrentPage(Page.CampaignMemberManagement);
        System.currentPageReference().getParameters().put('Id', tempContact.Id);

        Test.startTest();

        std = new ApexPages.standardController(tempContact);
        cm = new CampaignMemberManagementController(std);

        // Search for and assign to parent campaign
        cm.getActiveCRCamMems();
        cm.searchString = '';
        cm.parentCampaignSearch();
        cm.searchString = 'test';
        cm.parentCampaignSearch();
        cm.selectedParentCampaign = cm.parentCampaigns[0].Id;
        cm.selectedParentCampaignName = cm.parentCampaigns[0].Name;
        cm.assignToParentCampaign();

        // Search for and assign to child campaign
        cm.selectedChildCampaign = cm.fixedChildCampaigns[0].Id;
        cm.selectedChildCampaignName = cm.fixedChildCampaigns[0].Name;
        cm.assignToChildCampaign();

        // Remove CampaignMember from CR Campaign
        cm.inActivateCMId = cm.activeCrCamMems[0].Id;
        cm.inActivateCM();

        // Reactivate the CampaignMember
        cm.inActivateCMId = cm.activeCrCamMems[0].Id;
        cm.assignToParentCampaign();

        Test.stopTest();

        Id tempParentId = [SELECT Id FROM CampaignMember WHERE Id = :cm.activeCrCamMems[0].Id].Id;

        System.assertNotEquals(null, tempParentId);
    }

    @isTest
    public static void testSubscriptions() {
        Contact tempContact = [SELECT Id, Name FROM Contact LIMIT 1];

        List<Campaign> crCamParents = [SELECT Id, Name FROM Campaign WHERE Name LIKE '%Parent CR' AND ParentId = NULL];

        List<Campaign> crChilds = [SELECT Id, Name FROM Campaign WHERE ParentId IN :crCamParents];

        List<Campaign> allCRCams = new List<Campaign>();
        allCRCams.addAll(crCamParents);
        allCRCams.addAll(crChilds);

        Integer listSize = crCamParents.size() + crChilds.size();

        Id[] fixedSearchResults = new List<Id>(listSize);

        for (Integer i = 0; i < listSize; i++) {
            fixedSearchResults[i] = allCRCams[i].Id;
        }

        Test.setFixedSearchResults(fixedSearchResults);
        Test.setCurrentPage(Page.CampaignMemberManagement);
        System.currentPageReference().getParameters().put('Id', tempContact.Id);

        Test.startTest();

        std = new ApexPages.standardController(tempContact);
        cm = new CampaignMemberManagementController(std);

        Test.stopTest();

        System.assertEquals(cm.getSubscriberList().size(), 6);
    }

    @isTest
    public static void testMarketingCommunications() {
        Contact tempContact = [SELECT Id, Name FROM Contact LIMIT 1];

        List<Campaign> crCamParents = [SELECT Id, Name FROM Campaign WHERE Name LIKE '%Parent CR' AND ParentId = NULL];

        List<Campaign> crChilds = [SELECT Id, Name FROM Campaign WHERE ParentId IN :crCamParents];

        List<Campaign> allCRCams = new List<Campaign>();
        allCRCams.addAll(crCamParents);
        allCRCams.addAll(crChilds);

        Integer listSize = crCamParents.size() + crChilds.size();

        Id[] fixedSearchResults = new List<Id>(listSize);

        for (Integer i = 0; i < listSize; i++) {
            fixedSearchResults[i] = allCRCams[i].Id;
        }

        Test.setFixedSearchResults(fixedSearchResults);
        Test.setCurrentPage(Page.CampaignMemberManagement);
        System.currentPageReference().getParameters().put('Id', tempContact.Id);

        Test.startTest();

        std = new ApexPages.standardController(tempContact);
        cm = new CampaignMemberManagementController(std);

        Test.stopTest();

        System.assertEquals(cm.allMessageList.size(), 5);
        System.assertEquals(cm.getFilteredMessageList().size(), 5);

        System.assertEquals(cm.getCommFilterOptions().size(), 2);
        cm.commFilterType = 'Sent';
        cm.commFilterStartDate = Date.today().addDays(1);
        cm.commFilterEndDate = Date.today().addDays(2);
        cm.commFilterStartDate = Date.today().addDays(-5);
        cm.commFilterEndDate = Date.today().addDays(-4);
        System.assertEquals(cm.getfilteredMessageList().size(), 0);

        cm.commFilterType = 'Opened';
        cm.commFilterStartDate = Date.today().addDays(1);
        cm.commFilterEndDate = Date.today().addDays(2);
        cm.commFilterStartDate = Date.today().addDays(-5);
        cm.commFilterEndDate = Date.today().addDays(-4);
        System.assertEquals(cm.getfilteredMessageList().size(), 0);

        cm.clearCommFilter();
        System.assert(cm.commFilterStartDate == null);
        System.assertEquals(cm.getFilteredMessageList().size(), 5);
    }
}
