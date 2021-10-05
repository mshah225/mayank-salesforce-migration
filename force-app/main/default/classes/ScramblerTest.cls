@isTest
private class ScramblerTest {
    @isTest
    private static void testEmailScramble() {
        String testEmail = 'testEmail@test.com';
        testEmail = Scrambler.scrambleEmailOrUsername(testEmail);

        System.assertEquals('"testEmail@test.com.' + UserInfo.getUserName().substringAfterLast('.') + '"', testEmail);
    }

    @isTest
    private static void testEmailScrambleDouble() {
        // This test is simulating what happens if the scrambling process is run twice
        String testEmail = 'testEmail@test.com';
        testEmail = Scrambler.scrambleEmailOrUsername(testEmail);
        testEmail = testEmail.replace('"', ''); // remove added quotes
        testEmail = Scrambler.scrambleEmailOrUsername(testEmail);

        System.assertEquals('"testEmail@test.com.' + UserInfo.getUserName().substringAfterLast('.') + '"', testEmail);
    }

    @isTest
    private static void testEmailScrambleNull() {
        String testEmail = null;
        testEmail = Scrambler.scrambleEmailOrUsername(testEmail);

        System.assertEquals('', testEmail);
    }

    @isTest
    private static void testEmailScrambleEmpty() {
        String testEmail = '';
        testEmail = Scrambler.scrambleEmailOrUsername(testEmail);

        System.assertEquals('', testEmail);
    }

    @isTest
    private static void testDateScramble() {
        Date dateToScramble = Date.today();
        dateToScramble = Scrambler.scrambleDate(dateToScramble);

        System.assertNotEquals(Date.today(), dateToScramble);
    }

    @isTest
    private static void testDateScrambleNull() {
        Date dateToScramble = null;
        dateToScramble = Scrambler.scrambleDate(dateToScramble);

        System.assertEquals(null, dateToScramble);
    }
}
