@isTest(seeAllData = true)
private class ChatterAutoAddUserTest
{
    private static Set<Id> userIdRec;
    private static Set<Id> userIdService;
    private static Set<Id> userIdKnow;
    
    private static void setUp()
    {
        Id recProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Recruiting User' LIMIT 1].Id;
        Id servProfileId = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Service%' LIMIT 1].Id;
        Id knowProfileId = [SELECT Id FROM Profile WHERE Name = 'ASU Knowledge User' LIMIT 1].Id;

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