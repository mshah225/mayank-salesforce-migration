@isTest
private class UserScramblerTest {
    private static final String testUserAlias = 'testUsr';

    @TestSetup
    private static void setup() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user@test.test',
            Email = 'test.user@test.test',
            Alias = testUserAlias,
            CommunityNickname = testUserAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('ASU Service - Enrollment Analysis'),
            isActive = true
        );

        insert testUser;
    }

    @IsTest
    private static void testScrambleFields() {
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias LIMIT 1];

        UserScrambler scrambler = new UserScrambler(testUser);

        User scrambledUser = (User) scrambler.scrambleFields();

        System.assertEquals(false, scrambledUser.isActive);
    }

    @IsTest
    private static void testToCsvString() {
        User testUser = [SELECT Id, isActive FROM User WHERE Alias = :testUserAlias LIMIT 1];
        String expectedString = testUser.Id + ',false\n';

        System.assert(testUser.isActive, 'User should be active prior to scrambling');

        UserScrambler scrambler = new UserScrambler(testUser);

        String csvString = scrambler.toCsvString();

        System.assertEquals(expectedString, csvString);
    }
}
