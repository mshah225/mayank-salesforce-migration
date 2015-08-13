public class ChatterAutoAddUsers
{
    @future
    public static void AddToServiceGroup(Set<Id> userIds)
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
        List<CollaborationGroupMember> knowGroupMembers = [SELECT MemberId FROM
                CollaborationGroupMember WHERE CollaborationGroupId = :knowGroupId];
        List<CollaborationGroupMember> allGroupMembers = [SELECT MemberId FROM
                CollaborationGroupMember WHERE CollaborationGroupId = :allGroupId];
        List<CollaborationGroupMember> crGroupMembers = [SELECT MemberId FROM
                CollaborationGroupMember WHERE CollaborationGroupId = :crGroupId];

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

        Set<Id> knowGroupMemberIds = new Set<Id>();
        for (CollaborationGroupMember cgm : knowGroupMembers)
        {
            knowGroupMemberIds.add(cgm.MemberId);
        }

        Set<Id> allGroupMemberIds = new Set<Id>();
        for (CollaborationGroupMember cgm : allGroupMembers)
        {
            allGroupMemberIds.add(cgm.MemberId);
        }

        Set<Id> crGroupMemberIds = new Set<Id>();
        for (CollaborationGroupMember cgm : crGroupMembers)
        {
            crGroupMemberIds.add(cgm.MemberId);
        }

        List<Profile> recProfIds = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Recruit%'];
        List<Profile> servProfIds = [SELECT Id FROM Profile WHERE Name LIKE 'ASU Service%'];
        Id knowProfId = [SELECT Id FROM Profile WHERE Name = 'ASU Knowledge User'].Id;
        Id crProfId = [SELECT Id FROM Profile WHERE Name = 'ASU Corporate Relations'].Id;

        List<User> userList = [SELECT Id, ProfileId, isActive FROM User WHERE Id IN :userIds];
        List<CollaborationGroupMember> collabMembersToInsert = new List<CollaborationGroupMember>();

        for (User u : userList)
        {
            for (Profile rp : recProfIds)
            {
                if (u.ProfileId == rp.Id && !recGroupMemberIds.contains(u.Id))
                {
                    collabMembersToInsert.add(new CollaborationGroupMember(CollaborationGroupId =
                            recGroupId, MemberId = u.Id));
                }
            }

            for (Profile sp : servProfIds)
            {
                if (u.ProfileId == sp.Id && !servGroupMemberIds.contains(u
                        .Id))
                {
                    collabMembersToInsert.add(new CollaborationGroupMember(CollaborationGroupId =
                            servGroupId, MemberId = u.Id));
                }
            }

            if (u.ProfileId == crProfId && !crGroupMemberIds.contains(u
                    .Id))
            {
                collabMembersToInsert.add(new CollaborationGroupMember(CollaborationGroupId =
                        crGroupId, MemberId = u.Id));
            }

            if (u.ProfileId == knowProfId && !knowGroupMemberIds.contains(u
                    .Id))
            {
                collabMembersToInsert.add(new CollaborationGroupMember(CollaborationGroupId =
                        knowGroupId, MemberId = u.Id));
            }

            if ((u.ProfileId != commId || u.ProfileId != commCapId) && !allGroupMemberIds.contains(u
                    .Id))
            {
                collabMembersToInsert.add(new CollaborationGroupMember(CollaborationGroupId =
                        allGroupId, MemberId = u.Id));
            }
        }

        if (collabMembersToInsert.size() > 0)
        {
            try
            {
                insert collabMembersToInsert;
            }
            catch (Exception e)
            {
                System.debug('!!!!!!!!!!!!!!!!' + e);
            }
        }
    }
}