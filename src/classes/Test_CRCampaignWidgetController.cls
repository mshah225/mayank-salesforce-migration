@isTest 
private class Test_CRCampaignWidgetController 
{	
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
	private static Id recId;
	private static CRCampaignWidgetController cr;

	private static void setUp() 
	{
		recId = [SELECT Id FROM RecordType WHERE Name = 'Cohort'].Id;

        testContact = new Contact(
        	FirstName = 'Jonny',
        	LastName = 'Test',
        	ASURite_ID__c = 'jontest');
        insert testContact;

        testParentCampaign = new Campaign(
        	Name = 'Test Parent Campaign',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true);
        insert testParentCampaign;

        testChildCampaign = new Campaign(
        	Name = 'Test Child Campaign',
        	RecordTypeId = recId,
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

        PageReference campaignWidget = Page.CRCampaignWidget;
        Test.setCurrentPage(campaignWidget);
        System.currentPageReference().getParameters().put('id', testContact.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(testContact);
        cr = new CRCampaignWidgetController(std);
    }

    private static void setUpInactive() 
	{
		recId = [SELECT Id FROM RecordType WHERE Name = 'Cohort'].Id;

        testContact = new Contact(
        	FirstName = 'Jonny',
        	LastName = 'Test',
        	ASURite_ID__c = 'jontest');
        insert testContact;

        testParentCampaign = new Campaign(
        	Name = 'Test Parent Campaign',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true);
        insert testParentCampaign;

        testParentCampaignTwo = new Campaign(
        	Name = 'Test Parent Campaign Two',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true);
        insert testParentCampaignTwo;

        testChildCampaign = new Campaign(
        	Name = 'Test Child Campaign',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true,
        	ParentId = testParentCampaign.Id);
        insert testChildCampaign;

        testChildCampaignTwo = new Campaign(
        	Name = 'Test Child Campaign Two',
        	RecordTypeId = recId,
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

        PageReference campaignWidget = Page.CRCampaignWidget;
        Test.setCurrentPage(campaignWidget);
        System.currentPageReference().getParameters().put('id', testContact.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(testContact);
        cr = new CRCampaignWidgetController(std);
    }

    @isTest static void testViewCampaigns() 
	{
		setUp();
		cr.getSortList();
		System.assert(true,cr.sortList.size() > 0);
	}

	@isTest static void testAssignToCampaign()
	{
		setUp();
		cr.searchString = 'Test Parent';
		cr.parentCampaignSearch();
		System.assert(true,cr.parentCampaigns.size() > 0);
		cr.selectedParentCampaign = testParentCampaign.Id;
		cr.assignToParentCampaign();
		System.assert(true,cr.fixedChildCampaigns.size() > 0);
		cr.selectedChildCampaign = testChildCampaign.Id;
		cr.parentCamNameSearch();
		cr.childCamNameSearch();
		cr.assignToChildCampaign();
	}

	@isTest static void testActivate()
	{
		setUpInactive();
		cr.searchString = 'Test Parent';
		cr.parentCampaignSearch();
		cr.selectedParentCampaign = testParentCampaign.Id;
		cr.assignToParentCampaign();
		cr.selectedChildCampaign = testChildCampaign.Id;
		cr.parentCamNameSearch();
		cr.childCamNameSearch();
		cr.assignToChildCampaign();
		System.assertEquals('Active',cr.activateChildCamMem.Status);
	}
	
	@isTest static void testInactivate()
	{
		setUp();
		cr.inActivateCMId = testChildCamMem.Id;
		cr.inActivateCM();
		System.assertEquals('Inactive',cr.inActivateCamMem.Status);
	}
}