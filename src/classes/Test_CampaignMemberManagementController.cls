@isTest
private class Test_CampaignMemberManagementController {

    private static ApexPages.standardController std;
    private static CampaignMemberManagementController cm;
    private static Campaign interest;
    private static Campaign event;
    private static Contact testContact;

    private static Campaign testParentCampaign;
    private static Campaign testParentCampaignTwo;
    private static Campaign testChildCampaign;
    private static Campaign testChildCampaignTwo;
    private static CampaignMember testParentCamMem;
    private static CampaignMember testParentCamMemTwo;
    private static CampaignMember testChildCamMem;
    private static CampaignMember testChildCamMemTwo;
    private static CampaignMemberStatus cmActive1;
    private static CampaignMemberStatus cmInActive1;
    private static CampaignMemberStatus cmActive2;
    private static CampaignMemberStatus cmInActive2;
    private static CampaignMemberStatus cmActive3;
    private static CampaignMemberStatus cmInActive3;
    private static CampaignMemberStatus cmActive4;
    private static CampaignMemberStatus cmInActive4;
    private static Id cohortRecId;
    private static Id eventRecId;
    private static Id interestRecId;
    
    private static void setUp() { 
        cohortRecId = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Cohort'
            AND SobjectType = 'Campaign'
        ].Id;
        interestRecId = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Interest'
            AND SobjectType = 'Campaign'
        ].Id;
        eventRecId = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Event'
            AND SobjectType = 'Campaign'
        ].Id;

        testContact = ContactService.createTestContact();

        insert testContact;        
        
        interest = new Campaign(
            Name = 'Test interest',
            RecordTypeId = interestRecId,
            isActive = true);

        insert interest;

        event = new Campaign(
            Name = 'Test event',
            RecordTypeId = eventRecId,
            isActive = true);

        insert event;

        testParentCampaign = new Campaign(
            Name = 'Test Parent Campaign',
            RecordTypeId = cohortRecId,
            Type = 'Corporate Relations',
            IsActive = true);

        insert testParentCampaign;

        testChildCampaign = new Campaign(
            Name = 'Test Child Campaign',
            RecordTypeId = cohortRecId,
            Type = 'Corporate Relations',
            IsActive = true,
            ParentId = testParentCampaign.Id);

        insert testChildCampaign;

        cmActive1 = new CampaignMemberStatus(
            CampaignId = testParentCampaign.Id,
            IsDefault = true,
            SortOrder = 3,
            Label = 'Active');

        insert cmActive1;

        cmInActive1 = new CampaignMemberStatus(
            CampaignId = testParentCampaign.Id,
            IsDefault = false,
            SortOrder = 4,
            Label = 'Inactive');

        insert cmInActive1;

        cmActive2 = new CampaignMemberStatus(
            CampaignId = testChildCampaign.Id,
            IsDefault = true,
            SortOrder = 3,
            Label = 'Active');

        insert cmActive2;

        cmInActive2 = new CampaignMemberStatus(
            CampaignId = testChildCampaign.Id,
            IsDefault = false,
            SortOrder = 4,
            Label = 'Inactive');

        insert cmInActive2;

        testParentCamMem = new CampaignMember(
            CampaignId = testParentCampaign.Id,
            ContactId = testContact.Id,
            Status = 'Active');

        insert testParentCamMem;

        testChildCamMem = new CampaignMember(
            CampaignId = testChildCampaign.Id,
            ContactId = testContact.Id,
            Status = 'Active');

        insert testChildCamMem;

        Test.setCurrentPage(Page.CampaignMemberManagement);
        System.currentPageReference().getParameters().put('Id', testContact.Id);
        std = new ApexPages.standardController(testContact);
        cm = new CampaignMemberManagementController(std);
    }

    private static void setUpInactive() 
    {
        cohortRecId = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Cohort'
            AND SobjectType = 'Campaign'].Id;

        testContact = new Contact(
            FirstName = 'Jonny',
            LastName = 'Test',
            ASURite_ID__c = 'jontest');

        insert testContact;

        testParentCampaign = new Campaign(
            Name = 'Test Parent Campaign',
            RecordTypeId = cohortRecId,
            Type = 'Corporate Relations',
            IsActive = true);

        insert testParentCampaign;

        testParentCampaignTwo = new Campaign(
            Name = 'Test Parent Campaign Two',
            RecordTypeId = cohortRecId,
            Type = 'Corporate Relations',
            IsActive = true);

        insert testParentCampaignTwo;

        testChildCampaign = new Campaign(
            Name = 'Test Child Campaign',
            RecordTypeId = cohortRecId,
            Type = 'Corporate Relations',
            IsActive = true,
            ParentId = testParentCampaign.Id);

        insert testChildCampaign;

        testChildCampaignTwo = new Campaign(
            Name = 'Test Child Campaign Two',
            RecordTypeId = cohortRecId,
            Type = 'Corporate Relations',
            IsActive = true,
            ParentId = testParentCampaign.Id);

        insert testChildCampaignTwo;

        cmActive1 = new CampaignMemberStatus(
            CampaignId = testParentCampaign.Id,
            IsDefault = true,
            SortOrder = 3,
            Label = 'Active');

        insert cmActive1;

        cmInActive1 = new CampaignMemberStatus(
            CampaignId = testParentCampaign.Id,
            IsDefault = false,
            SortOrder = 4,
            Label = 'Inactive');

        insert cmInActive1;

        cmActive2 = new CampaignMemberStatus(
            CampaignId = testChildCampaign.Id,
            IsDefault = true,
            SortOrder = 3,
            Label = 'Active');

        insert cmActive2;

        cmInActive2 = new CampaignMemberStatus(
            CampaignId = testChildCampaign.Id,
            IsDefault = false,
            SortOrder = 4,
            Label = 'Inactive');

        insert cmInActive2;

        cmActive3 = new CampaignMemberStatus(
            CampaignId = testParentCampaignTwo.Id,
            IsDefault = true,
            SortOrder = 3,
            Label = 'Active');

        insert cmActive3;

        cmInActive3 = new CampaignMemberStatus(
            CampaignId = testParentCampaignTwo.Id,
            IsDefault = false,
            SortOrder = 4,
            Label = 'Inactive');

        insert cmInActive3;

        cmActive4 = new CampaignMemberStatus(
            CampaignId = testChildCampaignTwo.Id,
            IsDefault = true,
            SortOrder = 3,
            Label = 'Active');

        insert cmActive4;

        cmInActive4 = new CampaignMemberStatus(
            CampaignId = testChildCampaignTwo.Id,
            IsDefault = false,
            SortOrder = 4,
            Label = 'Inactive');

        insert cmInActive4;

        testParentCamMem = new CampaignMember(
            CampaignId = testParentCampaign.Id,
            ContactId = testContact.Id,
            Status = 'Inactive');

        insert testParentCamMem;

        testParentCamMemTwo = new CampaignMember(
            CampaignId = testParentCampaignTwo.Id,
            ContactId = testContact.Id,
            Status = 'Active');

        insert testParentCamMemTwo;

        testChildCamMem = new CampaignMember(
            CampaignId = testChildCampaign.Id,
            ContactId = testContact.Id,
            Status = 'Inactive');

        insert testChildCamMem;

        testChildCamMemTwo = new CampaignMember(
            CampaignId = testChildCampaignTwo.Id,
            ContactId = testContact.Id,
            Status = 'Active');

        insert testChildCamMemTwo;

        Test.setCurrentPage(Page.CampaignMemberManagement);
        System.currentPageReference().getParameters().put('Id', testContact.Id);
        std = new ApexPages.standardController(testContact);
        cm = new CampaignMemberManagementController(std);
    }
    
    @isTest static void Test_CampaignMemberMangementController() {
        setUp();
        cm.getEventList();
        cm.getInterestList();     
        cm.getScholarList();
        cm.getCohortList();
        cm.getoSourceList();
        cm.getMarkCommList();
        cm.getPartCourseList();
        cm.eSearchString = 'test';
        cm.doEventSearch();
        cm.getEventSearchResults();
        cm.elId = cm.eventSearchResults[0].Id;
        cm.AddToEvent();
        cm.iSearchString = 'test';
        cm.doInterestSearch();
        cm.getInterestSearchResults();
        cm.intId = cm.interestSearchResults[0].Id;
        cm.AddInterest();

        CampaignMember checkEventTestContact = [
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :testContact.Id
            AND CampaignId = :event.Id
        ];
        CampaignMember checkIntTestContact = [
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :testContact.Id
            AND CampaignId = :interest.Id
        ];

        Test.startTest();
        System.AssertEquals(checkEventTestContact.ContactId, testContact.Id);
        System.AssertEquals(checkIntTestContact.ContactId, testContact.Id);
        Test.stopTest();
    }

    @isTest static void testViewCampaigns() 
    {
        setUp();
        cm.getSortList();

        System.assert(true,cm.sortList.size() > 0);
    }

    @isTest static void testAssignToCampaign()
    {
        setUp();
        cm.searchString = 'Test Parent';
        cm.parentCampaignSearch();
        System.assert(true,cm.parentCampaigns.size() > 0);
        cm.selectedParentCampaign = testParentCampaign.Id;
        cm.assignToParentCampaign();
        System.assert(true,cm.fixedChildCampaigns.size() > 0);
        cm.selectedChildCampaign = testChildCampaign.Id;
        cm.parentCamNameSearch();
        cm.childCamNameSearch();
        cm.assignToChildCampaign();
    }

    @isTest static void testActivate()
    {
        setUpInactive();
        cm.searchString = 'Test Parent';
        cm.parentCampaignSearch();
        cm.selectedParentCampaign = testParentCampaign.Id;
        cm.assignToParentCampaign();
        cm.selectedChildCampaign = testChildCampaign.Id;
        cm.parentCamNameSearch();
        cm.childCamNameSearch();
        cm.assignToChildCampaign();

        System.assertEquals('Active',cm.activateChildCamMem.Status);
    }

    @isTest static void testInactivate()
    {
        setUp();
        cm.inActivateCMId = testChildCamMem.Id;
        cm.inActivateCM();

        System.assertEquals('Inactive',cm.inActivateCamMem.Status);
    }
}