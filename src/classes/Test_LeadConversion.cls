@isTest
public class Test_LeadConversion
{
	static final Integer MAX_LEAD = 200;  // The number of leads to convert at once
	static final Integer QUERY_LIMIT_THRESHOLD = 85;  // The number of acceptable queries to run during lead conversion
	
	@testSetup
	static void setup()
	{
		List<Contact> contactData = ContactService.createMultipleTestContacts(MAX_LEAD);
		insert contactData;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c : contactData)
		{
			contactIds.add(c.Id);
		}

		String queryContacts = 'SELECT AccountId, FirstName, LastName, EMPLID__c FROM Contact WHERE Id IN :contactIds';
		contactData = Database.query(queryContacts);

		List<Opportunity> opportunityData = OpportunityService.createTestOpportunities(contactData);
		insert opportunityData;

		Account institution = new Account();
		institution.Name = 'Univesity of Arizona';
		institution.Type = 'HS';

		insert institution;

		List<Lead> leadData = LeadService.createTestLeadsToConvertByEMPLID(contactData);
		insert leadData;
	}

	/**
	 * Tests the maximum number of leads that can be coverted at one time.
	 */
	@isTest
	static void leadConversionLoadTest()
	{
		Integer soqlQueries;

		List<Lead> leadsToConvert = [SELECT Id FROM Lead LIMIT :MAX_LEAD];
		Account institution = [SELECT Id FROM Account WHERE Type = 'HS'];

		for (Lead singleLead : leadsToConvert)
		{
			singleLead.Last_Institution_Attended__c = institution.Id;
			singleLead.Convert_Perform_Conversion__c = true;
		}
		
		test.StartTest();

		update leadsToConvert;
		soqlQueries = Limits.getQueries();
			
		test.StopTest();

		// Acceptable query threshold is less than 85% of the maximum query limit
		System.assert(soqlQueries < QUERY_LIMIT_THRESHOLD, 'Exceeded the acceptable SOQL query limit during conversion of ' + MAX_LEAD + ' leads: ' + soqlQueries);

	}
}