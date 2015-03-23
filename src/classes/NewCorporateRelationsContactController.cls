public with sharing class NewCorporateRelationsContactController {
	
	public Contact contact { get;set; }
	public Campaign campaign { get;set; }
	public CampaignMember campaignMember { get;set; }
	public RecordType cohortRecordType { get;set; }
	public Relationship__c relationship { get;set; }
	public List<SelectOption> campaignOptions;
	public List<SelectOption> childCampaignOptions { get;set; }
	public List<Campaign> cohortCampaigns;
	public List<Campaign> childCohortCampaigns;
	public String selectedParentId { get;set; }
	public String selectedChildId { get;set; }

	public NewCorporateRelationsContactController() {
		contact = new Contact();
		campaign = new Campaign();
		campaignMember = new CampaignMember();
		cohortRecordType = new RecordType();
		relationship = new Relationship__c();
		cohortRecordType = [SELECT Id 
							FROM RecordType 
							WHERE Name = 'Cohort'];
		cohortCampaigns = [SELECT Id, Name, RecordTypeId 
					       FROM Campaign 
					       WHERE RecordTypeId = :cohortRecordType.Id 
					       AND IsActive = true 
					       ORDER BY Name ASC];
	}

	public List<SelectOption> getCampaignOptions() {
        campaignOptions = new List<SelectOption>();
        campaignOptions.add(new SelectOption( '' ,'--Select--'));
        for(Campaign c : cohortCampaigns ) {
            campaignOptions.add(new SelectOption(c.Id , c.Name));
        }
        return campaignOptions;
    }

    public void populateChildCampaigns() {
        childCohortCampaigns = [SELECT Id, Name, RecordTypeId 
					       FROM Campaign 
					       WHERE RecordTypeId = :cohortRecordType.Id 
					       AND IsActive = true 
					       AND ParentId = :selectedParentId
					       ORDER BY Name ASC];
        childCampaignOptions = new List<SelectOption>();
        childCampaignOptions.add(new SelectOption( '' ,'--Select--'));
        for(Campaign c : childCohortCampaigns ) {
            childCampaignOptions.add(new SelectOption(c.Id , c.Name));
        }
    }

    public void saveToDatabase() {
    	try {
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

            relationship.Active_Relationship__c = true;
            relationship.Contact__c = contact.Id;
            insert relationship;

            campaignMember.CampaignId = selectedChildId;
            campaignMember.ContactId = contact.Id;
            insert campaignMember;
		} catch(exception e) {

		}
    }

	public PageReference save() {
		saveToDatabase();
		PageReference submit = new PageReference('/' + contact.Id);
		submit.setRedirect(true);
		return submit;
	}

	public PageReference saveAndNew() {
		saveToDatabase();
		PageReference submit = new PageReference(ApexPages.currentPage().getUrl());
		submit.setRedirect(true);
		return submit;
	}	
}