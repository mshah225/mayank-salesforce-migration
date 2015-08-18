public class ChatterAutoAddUsers
{
    @future
    public static void AddToServiceGroup(Set<Id> userIds)
    {
        List<User> userList = [SELECT Id, ProfileId, isActive FROM User WHERE Id IN :userIds];
        List<CollaborationGroupMember> collabMembersToInsert = new List<CollaborationGroupMember>();
        CollaborationGroupMember newCollabMember;

        List<CollaborationGroup> recGroup = [SELECT Id FROM CollaborationGroup WHERE Name =
                'ASU Recruitment' LIMIT 1];
        List<CollaborationGroup> servGroup = [SELECT Id FROM CollaborationGroup WHERE Name =
                'ASU Service' LIMIT 1];
        List<CollaborationGroup> allGroup = [SELECT Id FROM CollaborationGroup WHERE Name =
                'ASU - Everyone' LIMIT 1];

        List<CollaborationGroupMember> recGroupMembers;
        List<CollaborationGroupMember> servGroupMembers;
        List<CollaborationGroupMember> allGroupMembers;

        Map<String, String> chatterSettingsMap = new Map<String, String>();
        Map<String, String> chatterGroupsMap = new Map<String, String>();
        Map<String, String> profilesMap = new Map<String, String>();

        Set<Id> recGroupMemberIds = new Set<Id>();
        Set<Id> servGroupMemberIds = new Set<Id>();
        Set<Id> allGroupMemberIds = new Set<Id>();

        Id commId = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
        Id commCapId = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'].Id;
        Id collabGroupId;
        Boolean foundGroups;

        if (recGroup.size() > 0)
        {
            recGroupMembers = [
                SELECT MemberId
                FROM CollaborationGroupMember
                WHERE CollaborationGroupId = :recGroup[0].Id
            ];

            foundGroups = true;

            for (CollaborationGroupMember cgm : recGroupMembers)
            {
                recGroupMemberIds.add(cgm.MemberId);
            }
        }

        if (servGroup.size() > 0)
        {
            servGroupMembers = [
                SELECT MemberId
                FROM CollaborationGroupMember
                WHERE CollaborationGroupId = :servGroup[0].Id
            ];

            foundGroups = true;

            for (CollaborationGroupMember cgm : servGroupMembers)
            {
                servGroupMemberIds.add(cgm.MemberId);
            }
        }

        if (allGroup.size() > 0)
        {
            allGroupMembers = [
                SELECT MemberId
                FROM CollaborationGroupMember
                WHERE CollaborationGroupId = :allGroup[0].Id
            ];

            foundGroups = true;

            for (CollaborationGroupMember cgm : allGroupMembers)
            {
                allGroupMemberIds.add(cgm.MemberId);
            }
        }

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

        for (Chatter_Auto_Add_Users__c caau : chatterSettingsList) {
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

        for (User u : userList)
        {
            newCollabMember = new CollaborationGroupMember();
            newCollabMember.MemberId = u.Id;

            if (chatterSettingsMap.containsKey(profilesMap.get(u.ProfileId)))
            {
                String groupName = chatterSettingsMap.get(profilesMap.get(u.ProfileId));

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
                        (u.Id)))
                {
                    collabGroupId = chatterGroupsMap.get(groupName);
                    newCollabMember.CollaborationGroupId = collabGroupId;
                    collabMembersToInsert.add(newCollabMember);
                }
            }
            else if (profilesMap.get(u.ProfileId).contains('ASU Service') && (!servGroupMemberIds
                    .contains(u.Id)))
            {
                if (chatterGroupsMap.containsKey('ASU Service'))
                {
                    newCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU Service');
                    collabMembersToInsert.add(newCollabMember);
                }
            }
            else if (profilesMap.get(u.ProfileId).contains('ASU Recruit') && !recGroupMemberIds
                    .contains(u.Id))
            {
                if (chatterGroupsMap.containsKey('ASU Recruitment'))
                {
                    newCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU Recruitment');
                    collabMembersToInsert.add(newCollabMember);
                }
            }

            if ((u.ProfileId != commId || u.ProfileId != commCapId) && (!allGroupMemberIds
                    .contains(u.Id)))
            {
                CollaborationGroupMember otherCollabMember = new CollaborationGroupMember();
                otherCollabMember.MemberId = u.Id;
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
}