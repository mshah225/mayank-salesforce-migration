public class ContactService 
{	
    /**
    * Creates a test contact. Usually for unit testing.
    * @return A test contact object with all required fields.
    */
	public static Contact createTestContact() 
	{
		Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.MailingPostalCode = '85282';
        testContact.Email = 'test.user@test.example.com';
        testContact.Birthdate = Date.newInstance(1989, 8, 12);
        testContact.Self_Service_PIN__c = 57483638;
        testContact.PIN_lockout__c = true;
        testContact.ASURite_ID__c = 'testuser';

		return testContact;
	}

    /**
    * Creates a number of test contacts. Usually for unit testing.
    * @param The number of contacts to create
    * @return A list of the contacts with all required fields;
    */
    public static List<Contact> createMultipleTestContacts(Integer numOfContacts)
    {
        List<Contact> contactList = new List<Contact>();

        for (Integer i = 0; i < numOfContacts; i++)
        {
            Contact con = createTestContact();
            con.FirstName = 'Test' + i;
            con.LastName = 'Contact' + i;
            con.Email = 'test.user' + i + '@test.example.com';
            con.ASURite_ID__c = 'testuser' + i;
            contactList.add(con);
        }

        return contactList;
    }
    
    /**
    * The currently logged in contact somewhere. Usually the service center.
    * @return The logged in contact
    */
    public static Contact getLoggedInContact()
    {
        String userAlias = null;
        Contact loggedInContact = null;

        try
        {
            userAlias = [SELECT Alias 
                         FROM User 
                         WHERE Id = :UserInfo.getUserId()].Alias;
            loggedInContact = [SELECT Id, Name 
                               FROM Contact 
                               WHERE ASURITE_Id__c = :userAlias];
        }
        catch (Exception e)
        {
            System.debug('!!!ERROR!!!: An error occurred trying to get the logged in Contact\n' + e.getStackTraceString());
        }

        System.Debug('User Alias: ' + userAlias);
        System.Debug('Contact: ' + loggedInContact);

        return loggedInContact;
    }
}