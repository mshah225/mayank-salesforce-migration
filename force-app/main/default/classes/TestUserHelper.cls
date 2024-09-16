/**
 * This ia a helper class that test classes can use to create commonly needed test users
 * It's primarily purpose is for creating users that you can the use later in the test to
 * System.runAs()
 *
 * The general flow is:
 * 1. In the @TestSetup function you need to call the create* function for each user you need to runAs.
 * 2. In @TestSetup you insert these users.
 * 3. In each @isTest function, you call the get* function to get the user you previously created.
 *
 */
@isTest
public class TestUserHelper {
    private static String testSysAdminAlias = 'testUsr';
    private static String testStandardUserAlias = 'testUsr1';

    private static List<User> testUsers {
        get {
            if (testUsers == null) {
                List<String> testAliases = new List<String>{ testSysAdminAlias, testStandardUserAlias };
                testUsers = new List<User>([SELECT Id, Alias, Email FROM User WHERE Alias IN :testAliases]);
            }
            return testUsers;
        }
        set;
    }

    /**
     * System admin user - this is used in many cases where permissions don't really matter
     */
    public static User getTestSysAdmin() {
        for (User u : testUsers)
            if (u.Alias == testSysAdminAlias)
                return u;
        throw new TestUserHelperCannotFindUserException(
            'Cannot find user with alias=' +
                testSysAdminAlias +
                '.  Did you remember to create and insert this user in the @TestSetup function?'
        );
    }
    public static User createTestSysAdmin() {
        User u = new User(
            FirstName = 'Anri',
            LastName = 'Guardiana',
            Username = 'anri.guardiana@test.test',
            Email = 'anri.guardiana@test.test',
            Alias = testSysAdminAlias,
            CommunityNickname = testSysAdminAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = '00ed00000017IobAAE' // System Administrator
        );
        return u;
    }

    /**
     * Standard user - this is used in many cases where permissions don't really matter, but it matters
     * that the user is NOT a system admin (since sys admin users have various overrides)
     */
    public static User getTestStandardUser() {
        for (User u : testUsers)
            if (u.Alias == testStandardUserAlias)
                return u;
        throw new TestUserHelperCannotFindUserException(
            'Cannot find user with alias=' +
                testStandardUserAlias +
                '.  Did you remember to create and insert this user in the @TestSetup function?'
        );
    }
    public static User createTestStandardUser() {
        User u = new User(
            FirstName = 'Tao',
            LastName = 'Firecaster',
            Username = 'tao.firecaster@test.test',
            Email = 'tao.firecaster@test.test',
            Alias = testStandardUserAlias,
            CommunityNickname = testStandardUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = '00ed00000017IogAAE' // Standard User
        );
        return u;
    }

    public class TestUserHelperCannotFindUserException extends Exception {
    }
}
