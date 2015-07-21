public class LeadService 
{
	/**
	 * Creates a Lead with all required fields, usually for unit testing
	 * @return testLead A lead with all required fields
	 */
	public static Lead createTestLead() 
	{
		Lead testLead = new Lead();
        testLead.FirstName = 'Jonny';
        testLead.LastName = 'Test';
        testLead.Email = 'test@nomail.com';
        testLead.Company = 'Test Company';

		return testLead;
	}

	/**
	 * Generates a list of test leads that are matched to contacts by the Contact.EMPLID__c
	 * @param  contactData A list of contacts
	 * @return testLeads A list of leads that are matched to contacts by EMPLID
	 */
	public static List<Lead> createTestLeadsToConvertByEMPLID(List<Contact> contactData)
	{
		List<Lead> testLeads = new List<Lead>();

		Lead singleLead;
		for (Contact singleContact : contactData)
		{
			singleLead = createTestLead();
			singleLead.FirstName = singleContact.FirstName;
			singleLead.LastName = singleContact.LastName;
			singleLead.EMPLID__c = singleContact.EMPLID__c;
			singleLead.IsConverted = false;
			singleLead.Convert_Contact__c = singleContact.Id;

			testLeads.add(singleLead);
		}

		return testLeads;
	}
}