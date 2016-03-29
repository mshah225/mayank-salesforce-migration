@isTest
private class Test_CampaignMemberManagementController {

    private static ApexPages.standardController std;
    private static CampaignMemberManagementController cm;
    
    @testSetup static void setUp()
    {
        List<Campaign> campaignList = new List<Campaign>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<CampaignMemberStatus> campaignMemberStatusList = new List<CampaignMemberStatus>();

        Id cohortRecId = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Cohort'
            AND SobjectType = 'Campaign'
        ].Id;

        Id interestRecId = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Interest'
            AND SobjectType = 'Campaign'
        ].Id;

        Id eventRecId = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Event'
            AND SobjectType = 'Campaign'
        ].Id;

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
        Location__c tempe = new Location__c(
            Name = 'Tempe Campus',
            Location_Code__c = 'TEMPE'
        );
        insert tempe;

        // Add the Contact to the Campaigns
        List<CampaignMember> camMemList =
            CampaignMemberService.createTestCampaignMembers(testContact.Id, camListWithIds);
        insert camMemList;

        // Create some test Campaigns the contact is not currently a part of for searching
        List<Campaign> events = CampaignService.createTestCampaignOfType(5, 'Event');

        for (Campaign eCam : events)
        {
            eCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);
            eCam.Requested__c = 'Barret The Honors College';
            eCam.Campus_Location__c = tempe.Id;
        }

        insert events;

        List<Campaign> interests = CampaignService.createTestCampaignOfType(5, 'Interest');

        for (Campaign iCam : events)
        {
            iCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);
            iCam.Requested__c = 'Barret The Honors College';
            iCam.Campus_Location__c = tempe.Id;
        }

        insert interests;

        // Create Corporate Relations Campaigns for Testing
        List<Campaign> tempCrCamList = new List<Campaign>();
        List<CampaignMember> crCamMemsToInsert = new List<CampaignMember>();

        List<Campaign> crs = CampaignService.createTestCampaignOfType(5, 'Corporate Relations');

        for (Campaign cCam : crs)
        {
            cCam.Name = cCam.Name + ' Parent CR';
            cCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);
            cCam.Type = 'Corporate Relations';
        }

        insert crs;

        // Query back for the CR Campaigns so we can create children
        List<Campaign> parents = [
            SELECT Id, Name, RecordType.Name
            FROM Campaign
            WHERE Name LIKE '%Parent CR'
        ];

        tempCrCamList.addAll(parents);

        List<Campaign> children =
            CampaignService.createTestCampaignOfType(5, 'Corporate Relations');

        for (Campaign child : children)
        {
            child.Name = child.Name = ' Child CR';
            child.Event_Start_Date__c = date.newinstance(2016, 3, 28);
            child.Type = 'Corporate Relations';
        }

        // Add the parent Campaigns to the children
        for (Integer i = 0; i < parents.size(); i++)
        {
            children[i].ParentId = parents[i].Id;
        }

        insert children;

        // Query back for children
        List<Campaign> childrenList = [
            SELECT Id, Name, RecordType.Name
            FROM Campaign
            WHERE Name LIKE '%Child CR'
        ];

        tempCrCamList.addAll(childrenList);

        crCamMemsToInsert =
            CampaignMemberService.createTestCampaignMembers(testContact.Id, tempCrCamList);
        insert crCamMemsToInsert;

        // CampaignMemberStatuses
//        CampaignMemberStatus cmActive1 = new CampaignMemberStatus(
//            CampaignId = testParentCampaign.Id,
//            IsDefault = true,
//            SortOrder = 3,
//            Label = 'Active'
//        );
//
//        campaignMemberStatusList.add(cmActive1);
//
//        CampaignMemberStatus cmInActive1 = new CampaignMemberStatus(
//            CampaignId = testParentCampaign.Id,
//            IsDefault = false,
//            SortOrder = 4,
//            Label = 'Inactive'
//        );
//
//        campaignMemberStatusList.add(cmInActive1);
//
//        CampaignMemberStatus cmActive2 = new CampaignMemberStatus(
//            CampaignId = testChildCampaign.Id,
//            IsDefault = true,
//            SortOrder = 3,
//            Label = 'Active'
//        );
//
//        campaignMemberStatusList.add(cmActive2);
//
//        CampaignMemberStatus cmInActive2 = new CampaignMemberStatus(
//            CampaignId = testChildCampaign.Id,
//            IsDefault = false,
//            SortOrder = 4,
//            Label = 'Inactive'
//        );
//
//        campaignMemberStatusList.add(cmInActive2);
//
//        CampaignMemberStatus cmActive3 = new CampaignMemberStatus(
//            CampaignId = testParentCampaignTwo.Id,
//            IsDefault = true,
//            SortOrder = 3,
//            Label = 'Active'
//        );
//
//        campaignMemberStatusList.add(cmActive3);
//
//        CampaignMemberStatus cmInActive3 = new CampaignMemberStatus(
//            CampaignId = testParentCampaignTwo.Id,
//            IsDefault = false,
//            SortOrder = 4,
//            Label = 'Inactive'
//        );
//
//        campaignMemberStatusList.add(cmInActive3);
//
//        CampaignMemberStatus cmActive4 = new CampaignMemberStatus(
//            CampaignId = testChildCampaignTwo.Id,
//            IsDefault = true,
//            SortOrder = 3,
//            Label = 'Active'
//        );
//
//        campaignMemberStatusList.add(cmActive4);
//
//        CampaignMemberStatus cmInActive4 = new CampaignMemberStatus(
//            CampaignId = testChildCampaignTwo.Id,
//            IsDefault = false,
//            SortOrder = 4,
//            Label = 'Inactive'
//        );
//
//        campaignMemberStatusList.add(cmInActive4);
//
//        insert campaignMemberStatusList;
    }
    
    @isTest static void testEventsAndInterest()
    {
        Contact tempContact = [SELECT Id, Name FROM Contact LIMIT 1];

        Campaign eventCam = [
            SELECT Id, Name
            FROM Campaign
            WHERE RecordType.Name = 'Event'
            AND Name LIKE '%Test Campaign%'
            LIMIT 1
        ];

        Campaign intCam = [
            SELECT Id, Name
            FROM Campaign
            WHERE RecordType.Name = 'Interest'
            AND Name LIKE '%Test Campaign%'
            LIMIT 1
        ];

        Location__c tempe = [
            SELECT Id, Name
            FROM Location__c
            WHERE Name = 'Tempe Campus'
        ];

        eventCam.Requested__c = 'Barret The Honors College';
        eventCam.Campus_Location__c = tempe.Id;
        eventCam.Event_Start_Date__c = date.newinstance(2016, 3, 28);

        Id[] fixedSearchResults = new Id[2];
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

    @isTest public static void testCorporateRelations()
    {
        Contact tempContact = [SELECT Id, Name FROM Contact LIMIT 1];

        Campaign crCamParent = [
            SELECT Id, Name
            FROM Campaign
            WHERE Name LIKE '%Parent CR'
            LIMIT 1
        ];

        Campaign crCamChild = [
            SELECT Id, Name
            FROM Campaign
            WHERE ParentId = :crCamParent.Id
        ];

        Id[] fixedSearchResults = new Id[2];
        fixedSearchResults[0] = crCamParent.Id;
        fixedSearchResults[1] = crCamChild.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        Test.setCurrentPage(Page.CampaignMemberManagement);
        System.currentPageReference().getParameters().put('Id', tempContact.Id);

        Test.startTest();

        std = new ApexPages.standardController(tempContact);
        cm = new CampaignMemberManagementController(std);

        cm.getActiveCRCamMems();

        Test.stopTest();
    }
}