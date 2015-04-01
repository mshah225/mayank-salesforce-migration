public with sharing class CRCampaignWidgetController 
{
	public Contact contact;
	public CampaignMember newParentCamMem { get;set; }
	public CampaignMember newChildCamMem { get;set; }
	public Id cohortId;
	public Id selectedParentCampaign { get;set; }
	public Id selectedChildCampaign { get;set; }
	public List<CampaignMember> currentCampaigns { get;set; }
	public List<Campaign> parentCampaigns { get;set; }
	public List<Campaign> childCampaigns { get;set; }
	public String searchString { get;set; }
	public String selectedParentCampaignName { get;set; }

	public CRCampaignWidgetController() 
	{
		contact = [SELECT Id 
				   FROM Contact 
				   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
		cohortId = [SELECT Id
					FROM RecordType 
					WHERE Name = 'Cohort'].Id;
		currentCampaigns = [SELECT Id, Campaign.Name 
							FROM CampaignMember 
							WHERE ContactId = :contact.Id];
	}

	public void parentCampaignSearch()
	{
		if (parentCampaigns != null)
		{
			parentCampaigns = null;
		}
		if (childCampaigns != null) 
		{ 
			childCampaigns = null;
		}
		if (selectedParentCampaignName != null) 
		{ 
			selectedParentCampaignName = null; 
		}
		String queryString = 'SELECT Id, Name FROM Campaign WHERE RecordTypeId = \'' + cohortId + '\' AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' AND ParentId = null AND isActive = true';
		parentCampaigns = Database.query(queryString);
	}

	public void childCampaignSearch()
	{
		String queryString = 'SELECT Id, Name FROM Campaign WHERE RecordTypeId = \'' + cohortId + '\' AND ParentId = \'' + selectedParentCampaign + '\' AND isActive = true';
		childCampaigns = Database.query(queryString);
	}

	public void parentCamNameSearch() {
		if (parentCampaigns != null)
		{
			parentCampaigns.clear();
		}
		selectedParentCampaignName = [SELECT Name 
								  	  FROM Campaign
								  	  WHERE Id = :selectedParentCampaign].Name;
	}

	public void assignToParentCampaign()
	{
		newParentCamMem = new CampaignMember();
		newParentCamMem.ContactId = contact.Id;
		newParentCamMem.CampaignId = selectedParentCampaign;
		searchString = null;
		childCampaignSearch();
	}

	public PageReference assignToChildCampaign()
	{
		newChildCamMem = new CampaignMember();
		newChildCamMem.ContactId = contact.Id;
		newChildCamMem.CampaignId = selectedChildCampaign;
		try
		{
			insert newParentCamMem;
			insert newChildCamMem;
		}
		catch (Exception e)
		{

		}
		PageReference save = ApexPages.currentPage();
		save.setRedirect(true);
		return save;
	} 
}