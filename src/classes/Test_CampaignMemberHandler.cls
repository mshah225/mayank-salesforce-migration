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

	// Testing Primary Interests

	private static testMethod void testOpportunityPrimaryInterestAdd() {
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

		system.debug('GRF CampaignRecordTypeInfo: ' + CampaignRecordTypeInfo.get('Interest').getRecordTypeId());

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

        List<CampaignMember> cmListNew = new List<CampaignMember>([SELECT Id, opportunity__c FROM CampaignMember WHERE CampaignId = :camp.Id]);
        for (CampaignMember cm: cmListNew) {
        	system.assert(cm.Opportunity__c != null);
        }

        List<Opportunity> newOppList = new List<Opportunity>([SELECT Id, primary_interest__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        for (Opportunity o: newOppList) {
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

		system.debug('GRF CampaignRecordTypeInfo: ' + CampaignRecordTypeInfo.get('Interest').getRecordTypeId());

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
        for (Lead l: newLeadList) {
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

		system.debug('GRF Scholarship CampaignRecordTypeInfo: ' + CampaignRecordTypeInfo.get('Scholarship').getRecordTypeId());

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

        /*
        delete cmList;
        List<Opportunity> newOppList2 = new List<Opportunity>([SELECT Id, National_Merit_Semifinalist__c FROM Opportunity WHERE Contact__c IN :contactIds]);
        for (Opportunity o: newOppList2) {
        	system.assertEquals(false, o.National_Merit_Semifinalist__c, 'Opportunity National Merit Semifinalist was not set to false upon delete');
        }
        */        
	}

	
}