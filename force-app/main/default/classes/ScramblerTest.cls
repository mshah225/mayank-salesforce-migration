@isTest
private class ScramblerTest {
    @isTest
    private static void testEmailScramble() {
        String testEmail = 'testEmail@test.com';
        testEmail = Scrambler.scrambleEmailOrUsername(testEmail);

        System.assertEquals('"testEmail@test.com.' + Scrambler.getSandboxDomain() + '"', testEmail);
    }

    @isTest
    private static void testCarefulEmailScramble() {
        String testEmail = 'testEmail@test.com';
        testEmail = Scrambler.carefullyScrambleEmailOrUsername(testEmail).replace('"', '');

        System.assertEquals('testEmail@test.com.' + Scrambler.getSandboxDomain(), testEmail);

        testEmail = Scrambler.carefullyScrambleEmailOrUsername(testEmail).replace('"', '');

        System.assertEquals('testEmail@test.com.' + Scrambler.getSandboxDomain(), testEmail);
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
