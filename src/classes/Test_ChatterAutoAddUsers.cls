@isTest(SeeAllData=true)
public with sharing class Test_ChatterAutoAddUsers {
    /*
    @isTest static void testRecruitmentAutoAdd()
    {
        Test.startTest();

        Id testId;

        List<Profile> recProfileList = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'ASU Recruit%'
        ];

        User testRecUser = UserService.createTestUser();
        testRecUser.FirstName = 'Test';
        testRecUser.LastName = 'Rec';
        testRecUser.ProfileId = recProfileList[0].Id;

        insert testRecUser;

        User assertUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test Rec'
        ];

        Set<Id> recSet = new Set<Id>{assertUser.Id};
        ChatterAutoAddUsers.addToChatterGroupFuture(recSet);

        Test.stopTest();

        List<CollaborationGroup> groups = [
            SELECT Id, Name
            FROM CollaborationGroup
        ];

        for (CollaborationGroup cg : groups)
        {
            if (cg.Name == 'ASU Recruitment')
            {
                testId = cg.Id;
            }
        }

        CollaborationGroupMember testCollabRecMember = [
            SELECT Id, MemberId
            FROM CollaborationGroupMember
            WHERE MemberId = :assertUser.Id
            AND CollaborationGroupId = :testId
        ];

        System.assertNotEquals(null, testCollabRecMember);
    }

    @isTest static void testServiceAutoAdd()
    {
        Test.startTest();

        Id testId;

        List<Profile> servProfileList = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'ASU Service%'
        ];

        User testServUser = UserService.createTestUser();
        testServUser.FirstName = 'Test';
        testServUser.LastName = 'Serv';
        testServUser.ProfileId = servProfileList[0].Id;

        insert testServUser;

        User assertUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test Serv'
        ];

        Set<Id> servSet = new Set<Id>{assertUser.Id};
        ChatterAutoAddUsers.addToChatterGroupFuture(servSet);

        Test.stopTest();

        List<CollaborationGroup> groups = [
            SELECT Id, Name
            FROM CollaborationGroup
        ];

        for (CollaborationGroup cg : groups)
        {
            if (cg.Name == 'ASU Service')
            {
                testId = cg.Id;
            }
        }

        CollaborationGroupMember testCollabServMember = [
            SELECT Id, MemberId
            FROM CollaborationGroupMember
            WHERE MemberId = :assertUser.Id
            AND CollaborationGroupId = :testId
        ];

        System.assertNotEquals(null, testCollabServMember);
    }

    @isTest static void testKnowledgeAutoAdd()
    {
        Test.startTest();

        Id testId;

        List<Profile> knowProfileList = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'ASU Knowledge%'
        ];

        User testKnowUser = UserService.createTestUser();
        testKnowUser.FirstName = 'Test';
        testKnowUser.LastName = 'Know';
        testKnowUser.ProfileId = knowProfileList[0].Id;

        insert testKnowUser;

        User assertUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test Know'
        ];

        Set<Id> knowSet = new Set<Id>{assertUser.Id};
        ChatterAutoAddUsers.addToChatterGroupFuture(knowSet);

        Test.stopTest();

        List<CollaborationGroup> groups = [
            SELECT Id, Name
            FROM CollaborationGroup
        ];

        for (CollaborationGroup cg : groups)
        {
            if (cg.Name == 'Knowledge Users')
            {
                testId = cg.Id;
            }
        }

        CollaborationGroupMember testCollabKnowMember = [
            SELECT Id, MemberId
            FROM CollaborationGroupMember
            WHERE MemberId = :assertUser.Id
            AND CollaborationGroupId = :testId
        ];

        System.assertNotEquals(null, testCollabKnowMember);
    }
    */
}
