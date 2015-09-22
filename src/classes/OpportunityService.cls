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
	
    public static Opportunity createOpportunity()
    {
        Id undergradProspectId = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;
        Account a = AccountService.createAccount();
        insert a;

        Contact c = ContactService.createTestContact();
        insert c;

        Opportunity o = new Opportunity();
        o.Contact__c = c.Id;
        o.RecordTypeId = undergradProspectId;
        o.StageName = 'Prospect';
        o.CloseDate = Date.today();
        o.Name = 'Test Opportunity';
        o.AccountId = a.Id;
        return o;
    }

    public static List<Opportunity> createMultipleOpportunities(Integer numOfOpps)
    {
        List<Opportunity> oppList = new List<Opportunity>();

        List<Account> accountList = AccountService.createMultipleAccounts(numOfOpps);
        insert accountList;
        List<Contact> contactList = ContactService.createMultipleTestContacts(numOfOpps);
        insert contactList;

        for (Integer i = 0; i < numOfOpps; i++)
        {
            Id undergradProspectId = [SELECT Id FROM RecordType WHERE Name = 'Undergraduate Prospect' LIMIT 1].Id;

            Opportunity o = new Opportunity();
            o.Contact__c = contactList[i].Id;
            o.RecordTypeId = undergradProspectId;
            o.StageName = 'Prospect';
            o.CloseDate = Date.today();
            o.Name = 'Test Opportunity ' + i;
            o.AccountId = accountList[i].Id;
            oppList.add(o);
        }

        return oppList;
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