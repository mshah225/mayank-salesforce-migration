public class AccountService 
{
    public static Account createAccount()
    {
        Id sfMasteredId = [SELECT Id FROM RecordType WHERE Name = 'SF Mastered Org' LIMIT 1].Id;
        Account a = new Account();
        a.RecordTypeId = sfMasteredId;
        a.Name = 'Test Account';
        return a;
    }

    public static List<Account> createMultipleAccounts(Integer numOfAccounts)
    {
        List<Account> accountList = new List<Account>();
        for(Integer x = 0; x < numOfAccounts; x++)
        {
            Id sfMasteredId = [SELECT Id FROM RecordType WHERE Name = 'SF Mastered Org' LIMIT 1].Id;
            Account a = new Account();
            a.RecordTypeId = sfMasteredId;
            a.Name = 'Test Account ' + x;
            accountList.add(a);
        }

        return accountList;
    }
}