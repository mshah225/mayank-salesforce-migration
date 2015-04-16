public class ContactService 
{	
	public static Contact createTestContact() 
	{
		Contact testContact = new Contact();
        testContact.FirstName = 'Jonny';
        testContact.LastName = 'Test';
        testContact.MailingPostalCode = '85282';
        testContact.Email = 'test@nomail.com';
        testContact.Birthdate = Date.newInstance(1989, 8, 12);
        testContact.Self_Service_PIN__c = 57483638;
        testContact.PIN_lockout__c = true;
        testContact.ASURite_ID__c = 'jontest';
		return testContact;
	}
}