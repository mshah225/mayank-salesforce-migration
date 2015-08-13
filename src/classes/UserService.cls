public class UserService
{
    public static User createTestUser()
  	{
		User testUser = new User();
		testUser.FirstName = 'Test';
		testUser.LastName = 'User';
		testUser.Username = 'test.user@test.example.com';
		testUser.Email = 'test.user@test.example.com';
		testUser.Alias = 'testuser';
		testUser.CommunityNickname = 'testuserCom';
		testUser.TimeZoneSidKey = 'America/Phoenix';
		testUser.LocaleSidKey = 'en_US';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';

		return testUser;
  	}

  	public static List<User> createMultipleTestUsers(Integer numUsers)
  	{
  		List<User> userList = new List<User>();

  		for (Integer i = 0; i < numUsers; i++)
  		{
  			User tUser = createTestUser();
  			tUser.FirstName = 'Test' + i;
			tUser.LastName = 'User' + i;
			tUser.Username = 'test.user' + i + '@test.example.com';
			tUser.Email = 'test.user' + i + '@test.example.com';
			tUser.Alias = 'test' + i;
			tUser.CommunityNickname = 'testuser' + i;
			userList.add(tUser);
  		}
  		return userList;
  	}

    @future
    public static void addUsersToChatterGroups(Id newUserProfileId, Id newUserId, Id
            oldUserProfileId, Id oldUserId)
    {
        Id recGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'ASU Recruitment'].Id;
        Id servGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'ASU Service'].Id;
        Id knowGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Knowledge Users'].Id;
        Id allGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'ASU - Everyone'].Id;
        Id crGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Corporate Relations'].Id;
        Id commId = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
        Id commCapId = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'].Id;

        List<CollaborationGroupMember> recGroupMembers = [SELECT MemberId FROM
                CollaborationGroupMember WHERE CollaborationGroupId = :recGroupId];
        List<CollaborationGroupMember> servGroupMembers = [SELECT MemberId FROM
                CollaborationGroupMember WHERE CollaborationGroupId = :servGroupId];
        List<CollaborationGroupMember> allGroupMembers = [SELECT MemberId FROM
                CollaborationGroupMember WHERE CollaborationGroupId = :allGroupId];

        Set<Id> recGroupMemberIds = new Set<Id>();
        for (CollaborationGroupMember cgm : recGroupMembers)
        {
            recGroupMemberIds.add(cgm.MemberId);
        }

        Set<Id> servGroupMemberIds = new Set<Id>();
        for (CollaborationGroupMember cgm : servGroupMembers)
        {
            servGroupMemberIds.add(cgm.MemberId);
        }

        Set<Id> allGroupMemberIds = new Set<Id>();
        for (CollaborationGroupMember cgm : allGroupMembers)
        {
            allGroupMemberIds.add(cgm.MemberId);
        }

        Map<String, String> chatterSettingsMap = new Map<String, String>();
        Map<String, String> chatterGroupsMap = new Map<String, String>();
        Map<String, String> profilesMap = new Map<String, String>();
        List<CollaborationGroupMember> collabMembersToInsert = new List<CollaborationGroupMember>();

        List<Chatter_Auto_Add_Users__c> chatterSettingsList = [
                SELECT Profile__c, Chatter_Group_Name__c
                FROM Chatter_Auto_Add_Users__c
        ];

        List<CollaborationGroup> chatterGroups = [
                SELECT Id, Name
                FROM CollaborationGroup
        ];

        List<Profile> profilesList = [
                SELECT Id, Name
                FROM Profile
        ];

        for (Chatter_Auto_Add_Users__c caau : chatterSettingsList)
        {
            chatterSettingsMap.put(caau.Profile__c, caau.Chatter_Group_Name__c);
        }

        for (CollaborationGroup cg : chatterGroups)
        {
            chatterGroupsMap.put(cg.Name, cg.Id);
        }

        for (Profile p : profilesList)
        {
            profilesMap.put(p.Id, p.Name);
        }

        CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
        newCollabMember.MemberId = newUserId;
        Id collabGroupId;

        if (chatterSettingsMap.containsKey(profilesMap.get(newUserProfileId)))
        {
            String groupName = chatterSettingsMap.get(profilesMap.get(newUserProfileId));

            Id groupIdToCheck = [
                SELECT Id
                FROM CollaborationGroup
                WHERE Name = :groupName
            ].Id;

            List<CollaborationGroupMember> checkDupeGroupMembers = [
                SELECT MemberId
                FROM CollaborationGroupMember
                WHERE CollaborationGroupId = :groupIdToCheck
            ];

            Set<Id> checkDupeGroupMemberIds = new Set<Id>();
            for (CollaborationGroupMember cgm : checkDupeGroupMembers)
            {
                checkDupeGroupMemberIds.add(cgm.MemberId);
            }

            if (chatterGroupsMap.containsKey(groupName) && (!checkDupeGroupMemberIds.contains
                    (newUserId) || !checkDupeGroupMemberIds.contains(oldUserId)))
            {
                collabGroupId = chatterGroupsMap.get(groupName);
                newCollabMember.CollaborationGroupId = collabGroupId;
                collabMembersToInsert.add(newCollabMember);
            }
        }
        else if (profilesMap.get(newUserProfileId).contains('ASU Service') && (!servGroupMemberIds
                .contains(newUserId) || !servGroupMemberIds.contains(oldUserId)))
        {
            if (chatterGroupsMap.containsKey('ASU Service'))
            {
                newCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU Service');
                collabMembersToInsert.add(newCollabMember);
            }
        }
        else if (profilesMap.get(newUserProfileId).contains('ASU Recruit') &&
                (!recGroupMemberIds.contains(newUserId) || !recGroupMemberIds.contains(oldUserId)))
        {
            if (chatterGroupsMap.containsKey('ASU Recruitment'))
            {
                newCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU Recruitment');
                collabMembersToInsert.add(newCollabMember);
            }
        }

        if ((newUserProfileId != commId || newUserProfileId != commCapId) && (!allGroupMemberIds
                .contains(newUserId) || !allGroupMemberIds.contains(oldUserId)))
        {
            CollaborationGroupMember otherCollabMember = new CollaborationGroupMember();
            otherCollabMember.MemberId = newUserId;
            otherCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU - Everyone');
            collabMembersToInsert.add(otherCollabMember);
        }

        if (collabMembersToInsert.size() > 0)
        {
            try
            {
                insert collabMembersToInsert;
            }
            catch (Exception e)
            {
                System.debug('!!!!!!!!!!!!!!!!!' + e);
            }
        }
	}
}
