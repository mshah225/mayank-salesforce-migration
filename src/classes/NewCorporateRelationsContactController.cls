public with sharing class NewCorporateRelationsContactController 
{	
	public Account account { get;set; }
	public Contact contact { get;set; }
	public RecordType cohortRecordType { get;set; }
	public Relationship__c relationship { get;set; }
	public Integer page { get;set; }
	public List<Account> allAccounts;
	public List<Relationship__c> relationshipList { get;set; }
	public List<CampaignMember> campaignMemberList { get;set; }
	public List<SelectOption> campaignOptions;
	public List<SelectOption> childCampaignOptions { get;set; }
	public List<Campaign> cohortCampaigns;
	public List<Campaign> childCohortCampaigns;
	public Set<String> currentSet;
	public Set<String> accountSet;
	public String selectedParentId { get;set; }
	public String selectedChildId { get;set; }

	public NewCorporateRelationsContactController() 
	{
		page = 1;
		account = new Account();
		contact = new Contact();
		cohortRecordType = new RecordType();
		currentSet = new Set<String>();
		relationship = new Relationship__c();
		relationshipList = new List<Relationship__c>();
		campaignMemberList = new List<CampaignMember>();
		cohortRecordType = [SELECT Id 
							FROM RecordType 
							WHERE Name = 'Cohort'];
		allAccounts = [SELECT Name
					   FROM Account];
		accountSet = new Set<String>();
	}

	public List<SelectOption> getCampaignOptions() 
	{
		cohortCampaigns = [SELECT Id, Name, RecordTypeId 
					       FROM Campaign 
					       WHERE RecordTypeId = :cohortRecordType.Id 
					       AND IsActive = true
					       AND ParentId = null 
					       ORDER BY Name ASC];
        campaignOptions = new List<SelectOption>();
        campaignOptions.add(new SelectOption( '' ,'--Select--'));
        for (Campaign c : cohortCampaigns ) 
        {
            campaignOptions.add(new SelectOption(c.Id , c.Name));
        }
        return campaignOptions;
    }

    public void populateChildCampaigns() 
    {
        childCohortCampaigns = [SELECT Id, Name, RecordTypeId 
					       		FROM Campaign 
					       		WHERE RecordTypeId = :cohortRecordType.Id 
					       		AND IsActive = true 
					       		AND ParentId = :selectedParentId
					       		ORDER BY Name ASC];
        childCampaignOptions = new List<SelectOption>();
        childCampaignOptions.add(new SelectOption( '' ,'--Select--'));
        for (Campaign c : childCohortCampaigns ) 
        {
            childCampaignOptions.add(new SelectOption(c.Id , c.Name));
        }
    }

    public void saveToDatabase() 
    {
    	try 
    	{
			contact.SF_First_Name__c = contact.FirstName;
            contact.SF_First_Name_Updated__c = Datetime.now();
            contact.SF_Last_Name__c = contact.LastName;
            contact.SF_Last_Name_Updated__c = Datetime.now();
            contact.SF_Mobile__c = contact.MobilePhone;
            contact.SF_Mobile_Updated__c = Datetime.now();
            contact.SF_Mailing_Street__c = contact.MailingStreet;
            contact.SF_Mailing_City__c = contact.MailingCity;
            contact.SF_Mailing_Country__c = contact.MailingCountryCode;
            contact.SF_Mailing_State__c = contact.MailingStateCode;
            contact.SF_Mailing_ZIP__c = contact.MailingPostalCode;
            contact.SF_Mailing_Address_Updated__c = Datetime.now();
            contact.SF_Birthdate__c = contact.Birthdate;
            contact.SF_Birthdate_Updated__c = Datetime.now();
            insert contact; 

	        for (Relationship__c r: relationshipList) 
	        {
	            r.Active_Relationship__c = true;
	            r.Contact__c = contact.Id;
	        }
            insert relationshipList;

	        for (CampaignMember c: campaignMemberList) 
	        {   
	            c.ContactId = contact.Id;
	        }
            insert campaignMemberList;
		} 
		catch (exception e) 
		{

		}
    }

    public void addRelationship() 
    {
    	Relationship__c rNew = new Relationship__c();
    	rNew.Title__c = relationship.Title__c;
    	rNew.Account__c = relationship.Account__c;
    	rNew.Relationship_Type__c = relationship.Relationship_Type__c;
    	rNew.Relationship_Start_Date__c = relationship.Relationship_Start_Date__c;
    	relationshipList.add(rNew);
    }

    public void addParentCampaignMember() 
    {
    	CampaignMember pNew = new CampaignMember();
    	pNew.CampaignId = selectedParentId;
    	if (!currentSet.contains(selectedParentId)) 
    	{
    		campaignMemberList.add(pNew);
    		currentSet.add(selectedParentId);
    	}
    }

    public void addCampaignMember() 
    {
    	CampaignMember cNew = new CampaignMember();
    	cNew.CampaignId = selectedChildId;
    	if (!currentSet.contains(selectedChildId)) 
    	{
    		campaignMemberList.add(cNew);
    		currentSet.add(selectedChildId);
    	}
    }

    public PageReference page2()
    {
		page = 2;
		return ApexPages.currentPage();
	}

	public PageReference page3()
	{
		page = 3;
		return ApexPages.currentPage();
	}

	public void addPage() 
	{
		addRelationship();
		addParentCampaignMember();
		addCampaignMember();
		relationship = null;
		relationship = new Relationship__c();
		selectedParentId = null;
		selectedChildId = null;
		childCampaignOptions = null;
	}

	public PageReference cancelAccount()
	{
		page = 2;
		return ApexPages.currentPage();
	}

	public PageReference insertAccount()
	{
		for (Account a: allAccounts)
		{
			if (a.Name != null)
			{
				accountSet.add(a.Name);
			}

		}
		try
		{
			if (!accountSet.contains(account.Name))
			{
				insert account;
				page = 2;
				return ApexPages.currentPage();
			}
			else
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Account already exists. You can press the \'Back\' button to return to the previous page and search for the Account you\'re looking for.'));
				return null;
			}
		}
		catch (Exception e)
		{

		}
		return null;
	}

	public PageReference save() 
	{
		addRelationship();
		addParentCampaignMember();
		addCampaignMember();
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
	}

	public PageReference saveAndNew() 
	{
		addRelationship();
		addCampaignMember();
		saveToDatabase();
		PageReference submit = ApexPages.currentPage();
		submit.setRedirect(true);
		return submit;
	}	
}