public class OpportunityService 
{
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

	public static Integer generateOpportunityAssignmentNumber()
	{
		Double randNumber = Math.random()*100;

		return randNumber.intValue();
	}
}