public with sharing class CRCampaignWidgetController 
{
	public Contact contact;
	public CampaignMember newParentCamMem { get;set; }
	public CampaignMember newChildCamMem { get;set; }
	public CampaignMember inActivateCamMem { get;set; }
	public CampaignMember activateParentCamMem { get;set; }
	public CampaignMember activateChildCamMem { get;set; }
	public Id cohortId;
	public Id selectedParentCampaign { get;set; }
	public Id selectedChildCampaign { get;set; }
	public String inActivateCMId { get;set; }
	public List<CampaignMember> currentCampaigns { get;set; }
	public List<CampaignMember> currentChildCams { get;set; }
	public List<CampaignMember> inActiveCampaigns { get;set; }
	public List<CampaignMember> sortList;
	public List<Campaign> parentCampaigns { get;set; }
	public List<Campaign> childCampaigns { get;set; }
	public List<Campaign> fixedChildCampaigns { get;set; }
	public Set<String> currentSet;
	public Set<String> inActiveSet;
	public Set<String> childSearchSet;
	public String searchString { get;set; }
	public String selectedParentCampaignName { get;set; }
	public String selectedChildCampaignName { get;set; }

	public CRCampaignWidgetController(ApexPages.StandardController controller) 
	{
		contact = [SELECT Id 
				   FROM Contact 
				   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
		cohortId = [SELECT Id
					FROM RecordType 
					WHERE Name = 'Cohort'].Id;
		currentCampaigns = [SELECT Id, Campaign.Name, Campaign.ParentId 
							FROM CampaignMember 
							WHERE ContactId = :contact.Id
							AND Campaign_Type__c = 'Corporate Relations'
							AND Status = 'Active'
							ORDER BY Campaign.Name];
		inActiveCampaigns = [SELECT Id, Campaign.Name 
							FROM CampaignMember 
							WHERE ContactId = :contact.Id
							AND Campaign_Type__c = 'Corporate Relations'
							AND Status = 'Inactive'
							ORDER BY Campaign.Name];
	}

	public List<CampaignMember> getSortList() 
	{
		sortList = new List<CampaignMember>();
		for (CampaignMember cm: currentCampaigns)
		{
			if (cm.Campaign.ParentId == null)
			{
				sortList.add(cm);
				for (CampaignMember ch: [SELECT Campaign.Name, Campaign.ParentId
										 FROM CampaignMember 
										 WHERE ContactId = :contact.Id 
										 AND Campaign_Type__c = 'Corporate Relations'
										 AND Status = 'Active' 
										 AND Campaign.ParentId = :cm.Campaign.Id
										 ORDER BY Campaign.Name])
				{
					sortList.add(ch);
				}
			}
		}	
		return sortList;
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
		String queryString = 'SELECT Id, Name FROM Campaign WHERE RecordTypeId = \'' + cohortId + '\' AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' AND ParentId = null AND isActive = true AND Type = \'Corporate Relations\'';
		parentCampaigns = Database.query(queryString);
	}

	public void childCampaignSearch()
	{
		currentChildCams = [SELECT CampaignId 
							FROM CampaignMember 
							WHERE ContactId = :contact.Id 
							AND Campaign.ParentId = :selectedParentCampaign
							AND Status = 'Active'];
		childSearchSet = new Set<String>();
		fixedChildCampaigns = new List<Campaign>();
		for (CampaignMember c: currentChildCams)
		{
			childSearchSet.add(c.CampaignId);
		}
		String queryString = 'SELECT Id, Name FROM Campaign WHERE RecordTypeId = \'' + cohortId + '\' AND ParentId = \'' + selectedParentCampaign + '\' AND isActive = true';
		childCampaigns = Database.query(queryString);
		for (Campaign cc: childCampaigns) 
		{
			if(!childSearchSet.contains(cc.Id))
			{
				fixedChildCampaigns.add(cc);
			}
		}
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

	public void childCamNameSearch() {
		selectedChildCampaignName = [SELECT Name 
								  	 FROM Campaign
								  	 WHERE Id = :selectedChildCampaign].Name;
	}

	public void assignToParentCampaign()
	{
		newParentCamMem = new CampaignMember();
		newParentCamMem.ContactId = contact.Id;
		newParentCamMem.CampaignId = selectedParentCampaign;
		newParentCamMem.Status = 'Active';
		searchString = null;
		childCampaignSearch();
	}

	public void assignToChildCampaign()
	{
		newChildCamMem = new CampaignMember();
		newChildCamMem.ContactId = contact.Id;
		newChildCamMem.CampaignId = selectedChildCampaign;
		newChildCamMem.Status = 'Active';
		childCamNameSearch();
		save();
	} 

	public PageReference inActivateCM() 
	{
		inActivateCamMem = [SELECT Id 
							FROM CampaignMember
							WHERE Id = :inActivateCMId];
		inActivateCamMem.Status = 'Inactive';
		try
		{
			update inActivateCamMem;
		}
		catch (Exception e)
		{

		}
		PageReference refresh = ApexPages.currentPage();
		refresh.setRedirect(true);
		return refresh;
	}

	public PageReference save() 
	{
		try
		{
			currentSet = new Set<String>();
			for (CampaignMember c: currentCampaigns)
			{
				currentSet.add(c.Campaign.Name);
			}
			inActiveSet = new Set<String>();
			for (CampaignMember ia: inActiveCampaigns)
			{
				inActiveSet.add(ia.Campaign.Name);
			}
			if (!inActiveSet.contains(selectedParentCampaignName))
			{
				if (!currentSet.contains(selectedParentCampaignName))
				{
					insert newParentCamMem;
				}
			}
			else
			{
				activateParentCamMem = [SELECT Id 
										FROM CampaignMember
										WHERE Campaign.Name = :selectedParentCampaignName];
				activateParentCamMem.Status = 'Active';
				update activateParentCamMem;
			}
			if(selectedChildCampaign != null)
			{
				if (!inActiveSet.contains(selectedChildCampaignName))
				{
					if (!currentSet.contains(selectedChildCampaignName))
					{
						insert newChildCamMem;
					}
				}
				else 
				{
					activateChildCamMem = [SELECT Id 
										   FROM CampaignMember
										   WHERE Campaign.Name = :selectedChildCampaignName];
					activateChildCamMem.Status = 'Active';
					update activateChildCamMem;
				}
			}
		}
		catch (Exception e)
		{

		}
		PageReference save = ApexPages.currentPage();
		save.setRedirect(true);
		return save;
	}
}