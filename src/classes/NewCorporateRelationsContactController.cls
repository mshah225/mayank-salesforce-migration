public with sharing class NewCorporateRelationsContactController 
{	
	public Account account { get;set; }
	public Contact contact { get;set; }
	public RecordType cohortRecordType { get;set; }
	public Relationship__c relationship { get;set; }
	public Boolean showCancel { get;set; }
	public Boolean clickedAccount { get;set; }
	public Integer page { get;set; }
	public List<Relationship__c> relationshipList { get;set; }
	public List<CampaignMember> campaignMemberList { get;set; }
	public List<SelectOption> campaignOptions;
	public List<SelectOption> childCampaignOptions { get;set; }
	public List<SelectOption> relTypeOptions;
	public List<Campaign> cohortCampaigns;
	public List<Campaign> childCohortCampaigns;
	public Set<String> currentSet;
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
        if (childCohortCampaigns == null)
        {
        	childCampaignOptions.add(new SelectOption( '' ,'--Select--'));
        }
        else 
        {
        	childCampaignOptions.add(new SelectOption( '' ,'None'));
        }
        for (Campaign c : childCohortCampaigns ) 
        {
            childCampaignOptions.add(new SelectOption(c.Id , c.Name));
        }
    }

    public List<SelectOption> getRelTypeOptions()
	{       
	   	Schema.DescribeFieldResult fieldResult =
	 Relationship__c.Relationship_Type__c.getDescribe();
	   	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	   	relTypeOptions = new List<SelectOption>();
		relTypeOptions.add(new SelectOption('', '--Select--')); 
	   	for (Schema.PicklistEntry f : ple)
	   	{
	      	if (f.getValue() == 'Employee' || f.getValue() == 'Member' || f.getValue() == 'Volunteer')
	      	{
	      		relTypeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
	      	}
	   	}       
	   	return relTypeOptions;
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
	    if (selectedChildId != null)
	    {
	    	CampaignMember cNew = new CampaignMember();
	    	cNew.CampaignId = selectedChildId;
	    	if (!currentSet.contains(selectedChildId)) 
	    	{
	    		campaignMemberList.add(cNew);
	    		currentSet.add(selectedChildId);
	    	}
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

	public PageReference page4()
	{
		page = 4;
		return ApexPages.currentPage();
	}

	public PageReference page5()
	{
		page = 5;
		return ApexPages.currentPage();
	}

	public PageReference page6()
	{
		page = 6;
		return ApexPages.currentPage();
	}

	public void addPage() 
	{
		if(!validateRT())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Relationship Type.'));
			return;
		}
		if(!validateDA())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Department Affiliation.'));
			return;
		}
		addRelationship();
		addParentCampaignMember();
		addCampaignMember();
		showCancel = true;
		relationship = null;
		relationship = new Relationship__c();
		selectedParentId = null;
		selectedChildId = null;
		childCampaignOptions = null;
	}

	public void addRelationshipPage() 
	{
		if(!validateRT())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Relationship Type.'));
			return;
		}
		if(!validateDA())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Department Affiliation.'));
			return;
		}
		addRelationship();
		addParentCampaignMember();
		addCampaignMember();
		relationship = null;
		relationship = new Relationship__c();
		page = 4;
	}

	public void addCampaignPage()
	{
		if(!validateRT())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Relationship Type.'));
			return;
		}
		if(!validateDA())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Department Affiliation.'));
			return;
		}
		addRelationship();
		addParentCampaignMember();
		addCampaignMember();
		relationship = null;
		relationship = new Relationship__c();
		selectedParentId = null;
		selectedChildId = null;
		childCampaignOptions = null;
		page = 5;
	}

	public Boolean validateRT()
	{
		if (relationship.Relationship_Type__c == null)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	public Boolean validateDA()
	{
		if (selectedParentId == null)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	public void click() 
	{
		clickedAccount = true;
	}

	public void backToRelationship()
	{
		page4();
	}

	public void cancelAccount()
	{
		page2();
	}

	public PageReference insertAccount()
	{
		try
		{
			insert account;
			page = 2;
			return ApexPages.currentPage();
		}
		catch (Exception e)
		{

		}
		return null;
	}

	public PageReference insertRelationship()
	{
		if(!validateRT())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Relationship Type.'));
			return null;
		}
		addRelationship();
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
	}

	public PageReference insertCampaignMember()
	{
		if(!validateDA())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Department Affiliation.'));
			return null;
		}
		addParentCampaignMember();
		addCampaignMember();
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
	}

	public PageReference cancelAndSaveCampaignMember() 
	{
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
	}

	public PageReference cancelAndSaveRelationship() 
	{
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
	}

	public PageReference cancelAndSave()
	{
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
	}

	public PageReference relationshipSaveAndNew()
	{
		if(!validateRT())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Relationship Type.'));
			return null;
		}
		addRelationship();
		saveToDatabase();
		PageReference submit = ApexPages.currentPage();
		submit.setRedirect(true);
		return submit;
	}

	public PageReference campaignMemberSaveAndNew()
	{
		if(!validateDA())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Department Affiliation.'));
			return null;
		}
		addParentCampaignMember();
		addCampaignMember();
		saveToDatabase();
		PageReference submit = ApexPages.currentPage();
		submit.setRedirect(true);
		return submit;
	}

	public PageReference saveAndNew() 
	{
		if(!validateRT())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Relationship Type.'));
			return null;
		}
		if(!validateDA())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Department Affiliation.'));
			return null;
		}
		addRelationship();
		addParentCampaignMember();
		addCampaignMember();
		saveToDatabase();
		PageReference submit = ApexPages.currentPage();
		submit.setRedirect(true);
		return submit;
	}

	public PageReference save() 
	{
		if(!validateRT())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Relationship Type.'));
			return null;
		}
		if(!validateDA())
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Department Affiliation.'));
			return null;
		}
		addRelationship();
		addParentCampaignMember();
		addCampaignMember();
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
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
}