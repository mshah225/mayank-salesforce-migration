public with sharing class LeadService 
{
	public static Lead createTestLead() 
	{
		Lead testLead = new Lead();
        testLead.FirstName = 'Jonny';
        testLead.LastName = 'Test';
        testLead.Email = 'test@nomail.com';
        testLead.Company = 'Test Company';
		return testLead;
	}
}