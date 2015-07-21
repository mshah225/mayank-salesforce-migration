public class OpportunityService 
{
	/**
	 * Creates an Opportunity with all required fields, usually for unit testing
	 * @param  contactData A Contact
	 * @return testOpportunity An Opportunity tied to the provided Contact
	 */
	public static Opportunity createTestOpportunity(Contact contactData)
	{
		Opportunity testOpportunity = new Opportunity();
		testOpportunity.Name = 'Test Opportunity';
		testOpportunity.Contact__c = contactData.Id;
		testOpportunity.AccountId = contactData.AccountId;
		testOpportunity.StageName = 'Prospect';
		testOpportunity.CloseDate = Date.today() + 365;
		testOpportunity.Type = 'First Time Freshman';
		testOpportunity.Career__c = 'Undergraduate';

		return testOpportunity;
	}

	/**
	 * Creates a list of Opportunities with all required fields, usually for unit testing
	 * @param  contactData A list of Contacts
	 * @return testOppportunities A list of Opportunities tied to the provided Contact data
	 */
	public static List<Opportunity> createTestOpportunities(List<Contact> contactData)
	{
		List<Opportunity> testOpportunities = new List<Opportunity>();

		Opportunity singleOpportunity;

		for (Contact singleContact : contactData)
		{
			singleOpportunity = createTestOpportunity(singleContact);

			testOpportunities.add(singleOpportunity);
		}

		return testOpportunities;
	}

	/**
	 * Generates a random number for Territory Assignment
	 * @return randNumber A random Integer between 0 and 100
	 */
	public static Integer generateOpportunityAssignmentNumber()
	{
		Double randNumber = Math.random()*100;

		return randNumber.intValue();
	}
}