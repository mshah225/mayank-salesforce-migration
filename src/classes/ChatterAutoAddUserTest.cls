@isTest(seeAllData = true)
private class ChatterAutoAddUserTest
{
    private static Set<Id> userIdRec;
    private static Set<Id> userIdService;
    private static Set<Id> userIdKnow;
    
    private static void setUp()
    {
        List<Profile> recProfileList = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'ASU Recruit%'
        ];

        Id recProfileId = recProfileList[0].Id;

        List<Profile> servProfileList = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'ASU Serv%'
        ];

        Id servProfileId = servProfileList[0].Id;


        List<Profile> knowProfileList = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'ASU Know%'
        ];

        Id knowProfileId = knowProfileList[0].Id;

        List<User> testUsers = UserService.createMultipleTestUsers(3);
        testUsers[0].ProfileId = recProfileId;
        testUsers[1].ProfileId = servProfileId;
        testUsers[2].ProfileId = knowProfileId;

        userIdRec = new Set<Id>();
        userIdRec.add(testUsers[0].Id);

        userIdService = new Set<Id>();
        userIdService.add(testUsers[1].Id);

        userIdKnow = new Set<Id>();
        userIdKnow.add(testUsers[2].Id);

        insert testUsers;
    }

    @isTest static void testAutoAdd()
    {
        setUp();
        Test.startTest();
        ChatterAutoAddUsers.AddToServiceGroup(userIdRec);
        ChatterAutoAddUsers.AddToServiceGroup(userIdService);
        ChatterAutoAddUsers.AddToServiceGroup(userIdKnow);
        Test.stopTest();
    }
}