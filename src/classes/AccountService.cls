public class AccountService 
{
    /**
    * Creates a test account with the SF Mastered Org RecordType. Usually for unit testing.
    * @return A test account with required fields.
    */
    public static Account createTestSFMasteredAccount()
    {
        Id sfMasteredId = [SELECT Id FROM RecordType WHERE Name = 'SF Mastered Org' LIMIT 1].Id;
        Account a = new Account();
        a.RecordTypeId = sfMasteredId;
        a.Name = 'Test Account';
        return a;
    }

    /**
    * Creates a number of test accounts with the SF Mastered Org RecordType. Usually for unit testing.
    * @param The number of accounts to create
    * @return A list of the accounts with required fields
    */
    public static List<Account> createTestSFMasteredAccounts(Integer numOfAccounts)
    {
        List<Account> accountList = new List<Account>();
        Id sfMasteredId = [SELECT Id FROM RecordType WHERE Name = 'SF Mastered Org' LIMIT 1].Id;

        for(Integer x = 0; x < numOfAccounts; x++)
        {
            Account a = new Account();
            a.RecordTypeId = sfMasteredId;
            a.Name = 'Test Account ' + x;
            accountList.add(a);
        }

        return accountList;
    }

    /**
    * Creates a test Account that represents an Institution
    * @return institution An Account object
    */
    public static Account createTestInstitution()
    {
        Account institution = new Account();
        institution.Name = 'Univesity of Arizona';
        institution.Type = 'HS';

        return institution;
    }
}