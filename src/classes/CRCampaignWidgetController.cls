public with sharing class CRCampaignWidgetController 
{
	public Contact contact;
	public CampaignMember newCampaignMember {get;set; }
	public Id cohortId;
	public List<CampaignMember> currentCampaigns { get;set; }
	public List<Campaign> campaigns { get;set; }
	public String searchString { get;set; }
	public String selectedCampaign { get;set; }

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

	public void campaignSearch()
	{
		String queryString = 'SELECT Id, Name FROM Campaign WHERE RecordTypeId = \'' + cohortId + '\'AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
		campaigns = Database.query(queryString);
	}

	public void assignToCampaign()
	{
		newCampaignMember = new CampaignMember();
		newCampaignMember.ContactId = contact.Id;
		newCampaignMember.CampaignId = selectedCampaign;
		try
		{
			insert newCampaignMember;
		}
		catch (Exception e)
		{

		}
	}
}