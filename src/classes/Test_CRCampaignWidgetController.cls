@isTest 
private class Test_CRCampaignWidgetController 
{	
	@testSetup static void setUpInactive() 
	{
		Id recId = [SELECT Id FROM RecordType WHERE Name = 'Cohort'].Id;

        Contact testContact = ContactService.createTestContact();
        insert testContact;

        Campaign testParentCampaign = new Campaign(
        	Name = 'Test Parent Campaign',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true);
        insert testParentCampaign;

        Campaign testParentCampaignTwo = new Campaign(
        	Name = 'Test Parent Campaign Two',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true);
        insert testParentCampaignTwo;

        Campaign testChildCampaign = new Campaign(
        	Name = 'Test Child Campaign',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true,
        	ParentId = testParentCampaign.Id);
        insert testChildCampaign;

        Campaign testChildCampaignTwo = new Campaign(
        	Name = 'Test Child Campaign Two',
        	RecordTypeId = recId,
        	Type = 'Corporate Relations',
        	IsActive = true,
        	ParentId = testParentCampaign.Id);
        insert testChildCampaignTwo;

        CampaignMemberStatus cmActive1 = new CampaignMemberStatus(
        	CampaignId = testParentCampaign.Id,
        	IsDefault = true,
        	SortOrder = 3,
        	Label = 'Active');
        insert cmActive1;

        CampaignMemberStatus cmInActive1 = new CampaignMemberStatus(
        	CampaignId = testParentCampaign.Id,
        	IsDefault = false,
        	SortOrder = 4,
        	Label = 'Inactive');
        insert cmInActive1;

        CampaignMemberStatus cmActive2 = new CampaignMemberStatus(
        	CampaignId = testChildCampaign.Id,
        	IsDefault = true,
        	SortOrder = 3,
        	Label = 'Active');
        insert cmActive2;

        CampaignMemberStatus cmInActive2 = new CampaignMemberStatus(
        	CampaignId = testChildCampaign.Id,
        	IsDefault = false,
        	SortOrder = 4,
        	Label = 'Inactive');
        insert cmInActive2;

        CampaignMemberStatus cmActive3 = new CampaignMemberStatus(
        	CampaignId = testParentCampaignTwo.Id,
        	IsDefault = true,
        	SortOrder = 3,
        	Label = 'Active');
        insert cmActive3;

        CampaignMemberStatus cmInActive3 = new CampaignMemberStatus(
        	CampaignId = testParentCampaignTwo.Id,
        	IsDefault = false,
        	SortOrder = 4,
        	Label = 'Inactive');
        insert cmInActive3;

        CampaignMemberStatus cmActive4 = new CampaignMemberStatus(
        	CampaignId = testChildCampaignTwo.Id,
        	IsDefault = true,
        	SortOrder = 3,
        	Label = 'Active');
        insert cmActive4;

        CampaignMemberStatus cmInActive4 = new CampaignMemberStatus(
        	CampaignId = testChildCampaignTwo.Id,
        	IsDefault = false,
        	SortOrder = 4,
        	Label = 'Inactive');
        insert cmInActive4;

        CampaignMember testParentCamMem = new CampaignMember(
        	CampaignId = testParentCampaign.Id,
        	ContactId = testContact.Id,
        	Status = 'Inactive');
        insert testParentCamMem;

        CampaignMember testParentCamMemTwo = new CampaignMember(
        	CampaignId = testParentCampaignTwo.Id,
        	ContactId = testContact.Id,
        	Status = 'Active');
        insert testParentCamMemTwo;

        CampaignMember testChildCamMem = new CampaignMember(
        	CampaignId = testChildCampaign.Id,
        	ContactId = testContact.Id,
        	Status = 'Inactive');
        insert testChildCamMem;

        CampaignMember testChildCamMemTwo = new CampaignMember(
        	CampaignId = testChildCampaignTwo.Id,
        	ContactId = testContact.Id,
        	Status = 'Active');
        insert testChildCamMemTwo;
    }

    @isTest static void testViewCampaigns() 
	{
        Contact testCont = [SELECT Id FROM Contact WHERE ASURite_ID__c = 'testuser'];
        PageReference campaignWidget = Page.CRCampaignWidget;
        Test.setCurrentPage(campaignWidget);
        System.currentPageReference().getParameters().put('id', testCont.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(testCont);
        CRCampaignWidgetController cr = new CRCampaignWidgetController(std);
		cr.getSortList();
		System.assert(true,cr.sortList.size() > 0);
	}

	@isTest static void testAssignToCampaign()
	{
        Contact testCont = [SELECT Id FROM Contact WHERE ASURite_ID__c = 'testuser'];
        Campaign testParentCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Parent Campaign'];
        Campaign testChildCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Child Campaign'];
        PageReference campaignWidget = Page.CRCampaignWidget;
        Test.setCurrentPage(campaignWidget);
        System.currentPageReference().getParameters().put('id', testCont.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(testCont);
        CRCampaignWidgetController cr = new CRCampaignWidgetController(std);
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
        Contact testCont = [SELECT Id FROM Contact WHERE ASURite_ID__c = 'testuser'];
        Campaign testParentCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Parent Campaign'];
        Campaign testChildCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Child Campaign'];
        PageReference campaignWidget = Page.CRCampaignWidget;
        Test.setCurrentPage(campaignWidget);
        System.currentPageReference().getParameters().put('id', testCont.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(testCont);
        CRCampaignWidgetController cr = new CRCampaignWidgetController(std);
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
        Contact testCont = [SELECT Id FROM Contact WHERE ASURite_ID__c = 'testuser'];
        Campaign testParentCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Parent Campaign'];
        Campaign testChildCampaign = [SELECT Id FROM Campaign WHERE Name = 'Test Child Campaign'];
        CampaignMember testChildCamMem = [SELECT Id FROM CampaignMember WHERE CampaignId = :testChildCampaign.Id];
        PageReference campaignWidget = Page.CRCampaignWidget;
        Test.setCurrentPage(campaignWidget);
        System.currentPageReference().getParameters().put('id', testCont.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(testCont);
        CRCampaignWidgetController cr = new CRCampaignWidgetController(std);
		cr.inActivateCMId = testChildCamMem.Id;
		cr.inActivateCM();
		System.assertEquals('Inactive',cr.inActivateCamMem.Status);
	}
}