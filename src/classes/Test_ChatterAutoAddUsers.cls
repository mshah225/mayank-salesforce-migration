@isTest(SeeAllData=true)
public with sharing class Test_ChatterAutoAddUsers
{
    @isTest static void testRecruitmentAutoAdd()
    {
        Id testId;
        Id recProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'ASU Recruiting User'
            LIMIT 1
        ].Id;

        User testRecUser = UserService.createTestUser();
        testRecUser.FirstName = 'Test';
        testRecUser.LastName = 'Rec';
        testRecUser.ProfileId = recProfileId;

        insert testRecUser;

        User assertUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test Rec'
        ];

        Set<Id> recSet = new Set<Id>{assertUser.Id};

        Test.startTest();

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
        Id testId;
        Id servProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'ASU Service%'
            LIMIT 1
        ].Id;

        User testServUser = UserService.createTestUser();
        testServUser.FirstName = 'Test';
        testServUser.LastName = 'Serv';
        testServUser.ProfileId = servProfileId;

        insert testServUser;

        User assertUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test Serv'
        ];

        Set<Id> servSet = new Set<Id>{assertUser.Id};

        Test.startTest();

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
        Id testId;
        Id knowProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'ASU Knowledge User'
            LIMIT 1
        ].Id;

        User testKnowUser = UserService.createTestUser();
        testKnowUser.FirstName = 'Test';
        testKnowUser.LastName = 'Know';
        testKnowUser.ProfileId = knowProfileId;

        insert testKnowUser;

        User assertUser = [
            SELECT Id
            FROM User
            WHERE Name = 'Test Know'
        ];

        Set<Id> knowSet = new Set<Id>{assertUser.Id};

        Test.startTest();

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
}