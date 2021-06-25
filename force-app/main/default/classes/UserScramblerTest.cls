@isTest
private class UserScramblerTest {
    private static User createUser() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ASU Service - Enrollment Analysis' LIMIT 1].Id;
        UserFactory.DefaultUser userMaker = new UserFactory.DefaultUser();
        User userToInsert = (User) userMaker.create(1)[0];
        userToInsert.isActive = true;
        userToInsert.ProfileId = profileId;
        insert userToInsert;

        return userToInsert;
    }

    @IsTest
    private static void deactiveUser() {
        User userToScramble = createUser();
        UserScrambler scramble = new UserScrambler(userToScramble);
        test.startTest();
        scramble.scrambleFields();
        test.stopTest();

        System.assertEquals(false, userToScramble.isActive);
    }
}
