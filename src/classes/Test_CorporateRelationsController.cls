@isTest
private class Test_CorporateRelationsController 
{	
	private static Campaign testCampaign;
	private static Campaign testChildCampaign;
	private static Account testAccount;
	private static Contact testContact;
	private static Relationship__c testR;
	private static CampaignMember testCM;
	private static NewCorporateRelationsContactController ncr;

	private static void setupData() 
	{
		testCampaign = new Campaign(
			Name = 'Test Campaign');
		insert testCampaign;

		testChildCampaign = new Campaign(
			Name = 'Test Child Campaign',
			ParentId = testCampaign.Id);
		insert testChildCampaign;

		testAccount = new Account(
			Name = 'Test Account');
		insert testAccount;

		testContact = new Contact(
			FirstName = 'John',
			LastName = 'Doe');
		insert testContact;

		testR = new Relationship__c(
			Account__c = testAccount.Id,
			Active_Relationship__c = true,
	        Contact__c = testContact.Id,
	        Title__c = 'Test Title',
    		Relationship_Type__c = 'Business Partner',
    		Relationship_Start_Date__c = Date.today());
		insert testR;

		testCM = new CampaignMember(
			CampaignId = testCampaign.Id,
			ContactId = testContact.Id);
		insert testCM;

		ncr = new NewCorporateRelationsContactController();
	}


	@isTest static void testSave() 
	{
		setupData();
		PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
		ncr.contact = testContact;
		ncr.relationship = testR;
		ncr.selectedParentId = testCampaign.Id;
		ncr.selectedChildId = testChildCampaign.Id;
		ncr.getCampaignOptions();
		ncr.populateChildCampaigns();
		PageReference confirmSave = new PageReference('/' + testContact.Id);
		System.assertEquals(confirmSave.getUrl(),ncr.save().getUrl());
	}
	
	@isTest static void testSaveAndNew() 
	{
		setupData();
		PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
		ncr.contact = testContact;
		ncr.relationship = testR;
		ncr.selectedParentId = testCampaign.Id;
		ncr.selectedChildId = testChildCampaign.Id;
		ncr.getCampaignOptions();
		ncr.populateChildCampaigns();
		PageReference confirmSave = ApexPages.currentPage();
		System.assertEquals(confirmSave.getUrl(),ncr.saveAndNew().getUrl());
	}

	@isTest static void testAddPageSave() 
	{
		setupData();
		PageReference crPage = Page.NewCorporateRelationsContact;
        Test.setCurrentPage(crPage);
		ncr.contact = testContact;
		ncr.relationship = testR;
		ncr.selectedParentId = testCampaign.Id;
		ncr.selectedChildId = testChildCampaign.Id;
		ncr.getCampaignOptions();
		ncr.populateChildCampaigns();
		ncr.page2();
		ncr.addPage();
		ncr.relationship = testR;
		ncr.selectedParentId = testCampaign.Id;
		ncr.selectedChildId = testChildCampaign.Id;
		PageReference confirmSave = new PageReference('/' + testContact.Id);
		System.assertEquals(confirmSave.getUrl(),ncr.save().getUrl());
	}
	
}