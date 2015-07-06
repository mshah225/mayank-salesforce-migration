@isTest
public class Test_CampaignMemberHandler {
	
	private static List<Contact> createContacts(Integer qty) {
		List<Contact> contactList = new List<Contact>();
		for (Integer i=0; i<qty; i++) {
		    Contact con = new Contact();
		    con.FirstName = 'FName' + i;
		    con.LastName = 'LName' + i;
		    contactList.add(con);
		}

		return contactList;
	}

	private static List<Opportunity> createOpportunities(List<Contact> contactList) {
		List<Opportunity> oppList = new List<Opportunity>();

		for (Contact c: contactList) {
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opp ' + c.LastName;
		    opp.Contact__c = c.Id;
		    opp.AccountId = c.AccountId;
		    opp.StageName = 'Prospect';
		    opp.CloseDate = date.today() + 365;
		    opp.Type = 'First Time Freshman';
		    oppList.add(opp);
		}

		return oppList;
	}

	private static List<Lead> createLeads(Integer qty) {
		List<Lead> leadList = new List<Lead>();
		for (Integer i=0; i<qty; i++) {
			Lead l = new Lead(LastName='LName'+i, 
							  FirstName='FName'+i,
							  Company='Company', 
							  Email='test'+i+'@test.test', 
							  LeadSource='Email');
			leadList.add(l);
		}
		return leadList;
	}

	private static Campaign createCampaign(String name, String type)
	{
		Id interestId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;
		Campaign c = new Campaign(
			Name = name,
			RecordTypeId = interestId,
			Type = type
		);

		insert c;
		return c;
	}

	private static CampaignMember createCampaignMember(SObject attachObject, Id campId)
	{
		CampaignMember cm = new CampaignMember(
		    CampaignId = campId,
		    Status = 'Interested'
		);
        
        if(attachObject.getSObjectType().getDescribe().getName() == 'Contact')
        {
            cm.ContactId = attachObject.Id;
        }
        else if(attachObject.getSObjectType().getDescribe().getName() == 'Lead')
        {
            cm.LeadId = attachObject.Id;
        }

		insert cm;
		return cm;
	}

	private static CampaignMember createCampaignMemberNoInsert(SObject attachObject, Id campId)
	{
		CampaignMember cm = new CampaignMember(
		    CampaignId = campId,
		    Status = 'Interested'
		);
        
        if(attachObject.getSObjectType().getDescribe().getName() == 'Contact')
        {
            cm.ContactId = attachObject.Id;
        }
        else if(attachObject.getSObjectType().getDescribe().getName() == 'Lead')
        {
            cm.LeadId = attachObject.Id;
        }

		return cm;
	}

	// Testing Primary Interests
	private static testMethod void testOpportunityPrimaryInterestAdd() 
    {
		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		insert oppList;
        
		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Campaign camp = new Campaign(Name = 'PI Test',
									 Type = 'PSMajors',
									 RecordTypeId = CampaignRecordTypeInfo.get('Interest').getRecordTypeId(),
                            		 IsActive = TRUE);            
        insert camp;

    	CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId=camp.Id, HasResponded=true, IsDefault=true, Label='Interested', SortOrder=99);
	    insert cms;
     

		List<CampaignMember> cmList = new List<CampaignMember>();
        for (Contact c: contactList) {
        	CampaignMember cm = new CampaignMember(ContactId = c.Id,
        										   CampaignId = camp.Id,
        										   Status = 'Interested');
        	cmList.add(cm);
        }
        
        Test.startTest();
        insert cmList;
        Test.stopTest();

        List<CampaignMember> cmListNew = new List<CampaignMember>([SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp.Id]);
        for (CampaignMember cm: cmListNew) 
        {
        	system.assert(cm.Opportunity__c != null);
        }

        List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        for (Opportunity o: newOppList) 
        {
        	system.assertEquals(camp.Id, o.primary_interest__c);
        }
	}

	private static testMethod void testOpportunityPrimaryInterestRemove() {
		
	}

	private static testMethod void testLeadPrimaryInterestAdd() {
		List<Lead> leadList = createLeads(1);
		insert leadList;

		Set<Id> leadIds = new Set<Id>();
		for (Lead l: leadList) {
			leadIds.add(l.Id);
		}


		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Campaign camp = new Campaign(Name = 'PI Test',
									 Type = 'PSMajors',
									 RecordTypeId = CampaignRecordTypeInfo.get('Interest').getRecordTypeId(),
                            		 IsActive = TRUE);            
        insert camp;

    	CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId=camp.Id, HasResponded=true, IsDefault=true, Label='Interested', SortOrder=99);
	    insert cms;
     

		List<CampaignMember> cmList = new List<CampaignMember>();
        for (Lead l: leadList) {
        	CampaignMember cm = new CampaignMember(LeadId = l.Id,
        										   CampaignId = camp.Id,
        										   Status = 'Interested');
        	cmList.add(cm);
        }

        Test.startTest();
        insert cmList;
        Test.stopTest();

        List<Lead> newLeadList = new List<Lead>([SELECT Id, primary_interest__c FROM Lead WHERE Id IN :leadIds]);
        for (Lead l: newLeadList) 
        {
        	system.assertEquals(camp.Id, l.primary_interest__c);
        }		
	}

	private static testMethod void testLeadPrimaryInterestRemove() {
		
	}

	// Testing Scholarships
	private static testMethod void testOpportunityScholarshipAdd() {
		List<Contact> contactList = createContacts(1);
		insert contactList;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c: contactList) {
			contactIds.add(c.Id);
		}

		// Re-select Contacts to get AccountId values
		contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];

		List<Opportunity> oppList = createOpportunities(contactList);
		insert oppList;

		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Campaign; 
		Map<String,Schema.RecordTypeInfo> CampaignRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

		Campaign camp = new Campaign(Name = 'National Achievement Finalist',
									 Type = 'Scholarship - ASU',
									 RecordTypeId = CampaignRecordTypeInfo.get('Scholarship').getRecordTypeId(),
                            		 IsActive = true);            
        insert camp;

    	//CampaignMemberStatus cms = new CampaignMemberStatus(CampaignId=camp.Id, HasResponded=true, IsDefault=true, Label='Interested', SortOrder=99);
	    //insert cms;
     
		List<CampaignMember> cmList = new List<CampaignMember>();
        for (Contact c: contactList) {
        	CampaignMember cm = new CampaignMember(ContactId = c.Id,
        										   CampaignId = camp.Id);
        	cmList.add(cm);
        }

        Test.startTest();
        insert cmList;
        Test.stopTest();

        List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, National_Merit_Semifinalist__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        for (Opportunity o: newOppList) {
        	system.assertEquals(true, o.National_Merit_Semifinalist__c, 'Opportunity National Merit Semifinalist was not set to true upon insert');
        }
	}

	private static testMethod void insertContactPSMajorExistingPSMajor()
	{
		//Inserting PSMajor CM w/ Contact, no preexisting Primary
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMember(contact, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting PSMajor CM w/ Contact, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
        System.assert(cm2.Is_Primary_Interest__c == TRUE);
    }

    private static testMethod void insertContactNonPSMajorExistingPSMajor()
    {
		//Inserting PSMajor CM w/ Contact, no preexisting Primary
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMember(contact, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting Non-PSMajor Cm w/ Contact, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test Non-PSMajor', 'Academic');
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

    private static testMethod void insertContactPSMajorExistingNonPSMajor()
    {
		//Inserting Non PSMajor CM w/ Contact, no preexisting Primary
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMember(contact, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting PSMajor CM w/ Contact, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
        System.assert(cm2.Is_Primary_Interest__c == TRUE);
    }

    private static testMethod void insertContactNonPSMajorExistingNonPSMajor()
    {
		//Inserting Non PSMajor CM w/ Contact, no preexisting Primary
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMember(contact, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting Non PSMajor CM w/ Contact, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        CampaignMember cm2 = createCampaignMember(contact, camp2.Id);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
        System.assert(cm2.Is_Primary_Interest__c == TRUE);
    }

    private static testMethod void updateContactPSMajorNoPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);

        //Updating Non PSMajor CM w/ Contact, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

   	private static testMethod void updateContactPSMajorNonPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);

        //Updating Non PSMajor CM w/ Contact, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Is_Primary_Interest__c = TRUE;
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

    private static testMethod void updateContactPSMajorPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == TRUE);

        cm1.Status = 'Required';
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
   } 

    private static testMethod void updateContactPSMajorPSMajorPrimaryPreexistingChangeStatus()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == TRUE);

        cm2.Status = 'No Longer Interested';
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
   } 

	private static testMethod void updateContactNonPSMajorNoPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == TRUE);

        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

   	private static testMethod void updateContactNonPSMajorNonPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == TRUE);

        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

    private static testMethod void updateContactNonPSMajorPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);

        //Updating Non PSMajor CM w/ Contact, PSMajor preexisting primary
        cm2.Status = 'Required';
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
	    System.assert(cm2.Is_Primary_Interest__c == FALSE);
	} 

	private static testMethod void deleteContactPSMajorReassignPSMajor()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Campaign camp3 = createCampaign('Test PSMajor 3', 'PSMajors');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
		CampaignMember cm3 = createCampaignMemberNoInsert(contact, camp3.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
		System.assert(cm3.Is_Primary_Interest__c == FALSE);
		List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	cmsToUpdate.add(cm3);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		cm3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm3.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
		System.assert(cm3.Is_Primary_Interest__c == TRUE);

		delete cm3;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
	}

	private static testMethod void deleteContactPSMajorReassignNonPSMajor()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
		List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);

		delete cm1;
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm2.Is_Primary_Interest__c == TRUE);
	}

	private static testMethod void deleteContactNonPSMajorReassignNonPSMajor()
	{
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Campaign camp3 = createCampaign('Test Non PSMajor 3', 'Academic');
		Contact contact = ContactService.createTestContact();
		insert contact;
		CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
		CampaignMember cm3 = createCampaignMemberNoInsert(contact, camp3.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
		System.assert(cm3.Is_Primary_Interest__c == FALSE);
		List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	cmsToUpdate.add(cm3);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		cm3 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm3.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
		System.assert(cm3.Is_Primary_Interest__c == TRUE);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
		cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;

		delete cm3;
		cm1 = [SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Status, Last_Member_Status_Change__c, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.debug('CM1 Delete ' + cm1);
		System.debug('CM2 Delete ' + cm2);
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
	}

	private static testMethod void insertLeadPSMajorExistingPSMajor()
	{
		//Inserting PSMajor CM w/ Lead, no preexisting Primary
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMember(lead, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting PSMajor CM w/ Lead, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
        System.assert(cm2.Is_Primary_Interest__c == TRUE);
    }

    private static testMethod void insertLeadNonPSMajorExistingPSMajor()
    {
		//Inserting PSMajor CM w/ Lead, no preexisting Primary
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMember(lead, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting Non-PSMajor Cm w/ Lead, preexisting PSMajor Primary
        Campaign camp2 = createCampaign('Test Non-PSMajor', 'Academic');
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

    private static testMethod void insertLeadPSMajorExistingNonPSMajor()
    {
		//Inserting Non PSMajor CM w/ Lead, no preexisting Primary
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMember(lead, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting PSMajor CM w/ Lead, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
        System.assert(cm2.Is_Primary_Interest__c == TRUE);
    }

    private static testMethod void insertLeadNonPSMajorExistingNonPSMajor()
    {
		//Inserting Non PSMajor CM w/ Lead, no preexisting Primary
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMember(lead, camp.Id);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);

		//Inserting Non PSMajor CM w/ Lead, preexisting Non PSMajor Primary
        Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
        CampaignMember cm2 = createCampaignMember(lead, camp2.Id);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
        System.assert(cm2.Is_Primary_Interest__c == TRUE);
    }

    private static testMethod void updateLeadPSMajorNoPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);

        //Updating Non PSMajor CM w/ Lead, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

   	private static testMethod void updateLeadPSMajorNonPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);

        //Updating Non PSMajor CM w/ Lead, no preexisting primary
        cm1.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Is_Primary_Interest__c = TRUE;
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

    private static testMethod void updateLeadPSMajorPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test PSMajor 2', 'PSMajors');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == TRUE);

        cm1.Status = 'Required';
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
   } 

	private static testMethod void updateLeadNonPSMajorNoPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == TRUE);

        cm1.Is_Primary_Interest__c = FALSE;
        cm2.Is_Primary_Interest__c = FALSE;
        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

   	private static testMethod void updateLeadNonPSMajorNonPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test Non PSMajor', 'Academic');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == TRUE);

        cm1.Status = 'Required';
        cm2.Last_Member_Status_Change__c = Datetime.now().addDays(-2);
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
    }

    private static testMethod void updateLeadNonPSMajorPSMajorPrimaryPreexisting()
	{
		Campaign camp = createCampaign('Test PSMajor', 'PSMajors');
		Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
		Lead lead = LeadService.createTestLead();
		insert lead;
		CampaignMember cm1 = createCampaignMemberNoInsert(lead, camp.Id);
		CampaignMember cm2 = createCampaignMemberNoInsert(lead, camp2.Id);
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
		System.assert(cm1.Is_Primary_Interest__c == FALSE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);
       	List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	insert cmsToUpdate;
		cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
		cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
		System.assert(cm2.Is_Primary_Interest__c == FALSE);

        //Updating Non PSMajor CM w/ Lead, PSMajor preexisting primary
        cm2.Status = 'Required';
       	cmsToUpdate = new List<CampaignMember>();
       	cmsToUpdate.add(cm1);
       	cmsToUpdate.add(cm2);
       	update cmsToUpdate;
        cm1 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm1.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c FROM CampaignMember WHERE Id = :cm2.Id];
		System.assert(cm1.Is_Primary_Interest__c == TRUE);
        System.assert(cm2.Is_Primary_Interest__c == FALSE);
   }
}