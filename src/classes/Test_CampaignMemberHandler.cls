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
        Contact contact = contactList[0];

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test PSMajor 2', 'PSMajors');

		List<Opportunity> oppList = createOpportunities(contactList);
		insert oppList;
        Opportunity opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        system.assert(opp.Primary_Interest__c == null);

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp1.Id);
        system.assert(cm1.Is_Primary_Interest__c == false);
        
        System.debug('TEST 1');
        insert cm1;

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

    	system.assert(cm1.Opportunity__c == opp.Id);
        system.assert(cm1.Is_Primary_Interest__c == true);
    	system.assertEquals(camp1.Id, opp.primary_interest__c);

        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        system.assert(cm2.Is_Primary_Interest__c == false);

        Test.startTest();
        System.debug('TEST 2');
        insert cm2;
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];

        system.assert(cm1.Opportunity__c == opp.Id);
        system.assert(cm1.Is_Primary_Interest__c == true);
        system.assertEquals(camp1.Id, opp.primary_interest__c);

        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        System.debug('TEST 3');
        update cm1;
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];
        system.assert(cm1.Opportunity__c == opp.Id);
        system.assert(cm1.Is_Primary_Interest__c == true);
        system.assertEquals(camp1.Id, opp.primary_interest__c);

        CampaignMember cm3 = createCampaignMemberNoInsert(contact, camp3.Id);
        system.assert(cm3.Is_Primary_Interest__c == false);

        System.debug('TEST 4');
        insert cm3;
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm3 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp3.Id LIMIT 1];

        system.assert(cm3.Opportunity__c == opp.Id);
        system.assert(cm3.Is_Primary_Interest__c == true);
        system.assertEquals(camp3.Id, opp.primary_interest__c);

        Test.stopTest();
	}

	private static testMethod void testOpportunityPrimaryInterestRemove() {
        List<Contact> contactList = createContacts(1);
        insert contactList;

        Set<Id> contactIds = new Set<Id>();
        for (Contact c: contactList) {
            contactIds.add(c.Id);
        }
        // Re-select Contacts to get AccountId values
        contactList = [SELECT Id, LastName, AccountId FROM Contact WHERE Id IN :contactIds];
        Contact contact = contactList[0];

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        List<Opportunity> oppList = createOpportunities(contactList);
        insert oppList;
        Opportunity opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        system.assert(opp.Primary_Interest__c == null);

        CampaignMember cm1 = createCampaignMemberNoInsert(contact, camp1.Id);
        system.assert(cm1.Is_Primary_Interest__c == false);
        
        Test.startTest();
        System.debug('INSERTING 1');
        insert cm1;

        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

        system.assert(cm1.Opportunity__c == opp.Id);
        system.assert(cm1.Is_Primary_Interest__c == true);
        system.assertEquals(camp1.Id, opp.primary_interest__c);

        System.debug('DELETING 1');
        delete cm1;
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        system.assertEquals(opp.primary_interest__c, null);

        CampaignMember cm2 = createCampaignMemberNoInsert(contact, camp2.Id);
        system.assert(cm2.Is_Primary_Interest__c == false);

        System.debug('INSERTING 2');
        insert cm2;
        opp = [SELECT Id, Primary_interest__c FROM Opportunity WHERE Contact__c = :contact.Id LIMIT 1];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];
        System.debug('OPP: ' + opp);
        Test.stopTest();

        system.assertEquals(opp.primary_interest__c, camp2.Id);
	}

	private static testMethod void testLeadPrimaryInterestAdd()
    {
        List<Lead> leadList = createLeads(1);
        Lead l = leadList[0];
        insert l;

        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        system.assert(l.Primary_Interest__c == null);

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');
        Campaign camp3 = createCampaign('Test PSMajor 2', 'PSMajors');


        CampaignMember cm1 = createCampaignMemberNoInsert(l, camp1.Id);
        system.assert(cm1.Is_Primary_Interest__c == false);
        
        insert cm1;

        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

        system.assert(cm1.Is_Primary_Interest__c == true);
        system.assertEquals(camp1.Id, l.primary_interest__c);

        CampaignMember cm2 = createCampaignMemberNoInsert(l, camp2.Id);
        system.assert(cm2.Is_Primary_Interest__c == false);

        insert cm2;
        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];

        system.assert(cm1.Is_Primary_Interest__c == true);
        system.assertEquals(camp1.Id, l.primary_interest__c);

        Test.startTest();
        cm1.Last_Member_Status_Change__c = Datetime.now().addDays(-1);
        update cm1;
        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];
        system.assert(cm1.Is_Primary_Interest__c == true);
        system.assertEquals(camp1.Id, l.primary_interest__c);

        CampaignMember cm3 = createCampaignMemberNoInsert(l, camp3.Id);
        system.assert(cm3.Is_Primary_Interest__c == false);

        insert cm3;
        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        cm3 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp3.Id LIMIT 1];

        system.assert(cm3.Is_Primary_Interest__c == true);
        system.assertEquals(camp3.Id, l.primary_interest__c);

        Test.stopTest();
	}

	private static testMethod void testLeadPrimaryInterestRemove() {
        List<Lead> leadList = createLeads(1);
        Lead l = leadList[0];
        insert l;

        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        system.assert(l.Primary_Interest__c == null);

        Campaign camp1 = createCampaign('Test PSMajor 1', 'PSMajors');
        Campaign camp2 = createCampaign('Test Non PSMajor 2', 'Academic');

        CampaignMember cm1 = createCampaignMemberNoInsert(l, camp1.Id);
        system.assert(cm1.Is_Primary_Interest__c == false);
        
        insert cm1;

        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        cm1 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp1.Id LIMIT 1];

        system.assert(cm1.Is_Primary_Interest__c == true);
        system.assertEquals(camp1.Id, l.primary_interest__c);   

        delete cm1;
        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        system.assertEquals(l.primary_interest__c, null); 

        CampaignMember cm2 = createCampaignMemberNoInsert(l, camp2.Id);
        system.assert(cm2.Is_Primary_Interest__c == false);

        insert cm2;
        l = [SELECT Id, primary_interest__c FROM Lead WHERE Id = :l.Id];
        cm2 = [SELECT Id, Is_Primary_Interest__c, Opportunity__c, ContactId FROM CampaignMember WHERE CampaignId = :camp2.Id LIMIT 1];

        system.assertEquals(l.primary_interest__c, camp2.Id); 
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