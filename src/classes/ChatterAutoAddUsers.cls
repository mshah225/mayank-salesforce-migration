public class ChatterAutoAddUsers {
    public static Map<String, List<CollaborationGroupMember>> dupeMemberCheckMap;

    public static void addToChatterGroup(Set<Id> userIds) {
        CollaborationGroupMember newCollabMember;
        Id collabGroupId;
        List<CollaborationGroupMember> collabMembersToInsert = new List<CollaborationGroupMember>();
        Map<String, String> chatterSettingsMap = new Map<String, String>();
        Map<String, String> chatterGroupsMap = new Map<String, String>();

        List<User> userList = [SELECT Id, ProfileId, Profile.Name, isActive FROM User WHERE Id IN :userIds];

        // Populate the custom setting and map.
        List<Chatter_Auto_Add_Users__c> chatterSettingsList = [
            SELECT Profile__c, Chatter_Group_Name__c
            FROM Chatter_Auto_Add_Users__c
        ];

        for (Chatter_Auto_Add_Users__c caau : chatterSettingsList) {
            chatterSettingsMap.put(caau.Profile__c, caau.Chatter_Group_Name__c);
        }

        // Populate the chatter group map with all chatter group names.
        List<CollaborationGroup> chatterGroups = [SELECT Id, Name FROM CollaborationGroup];

        for (CollaborationGroup cg : chatterGroups) {
            chatterGroupsMap.put(cg.Name, cg.Id);
        }

        // Populate a map of all the groups and their members for later.
        dupeMemberCheckMap = new Map<String, List<CollaborationGroupMember>>();

        for (CollaborationGroup cg : chatterGroups) {
            List<CollaborationGroupMember> groupMembers = [
                SELECT MemberId
                FROM CollaborationGroupMember
                WHERE CollaborationGroupId = :cg.Id
            ];

            dupeMemberCheckMap.put(cg.Name, groupMembers);
        }

        /*
         * Loop through the userList to decide which users need to be added to what groups
         * then add them to the main list for insertion.
         */
        for (User u : userList) {
            // Check for Chatter Settings first
            if (chatterSettingsMap.containsKey(u.Profile.Name)) {
                // Get the group name that belongs to the users Profile
                String groupName = chatterSettingsMap.get(u.Profile.Name);

                /*
                 * Pass the groupname to the helper method and return the Ids of
                 * the collaboration members for dupe checking.
                 */
                Set<Id> dupeMemberIdSet = collabUserIdsToDupeCheck(groupName);

                // Check if the current user is already in the group, if not add them.
                if (chatterGroupsMap.containsKey(groupName) && (!dupeMemberIdSet.contains(u.Id))) {
                    collabGroupId = chatterGroupsMap.get(groupName);

                    newCollabMember = new CollaborationGroupMember();
                    newCollabMember.MemberId = u.Id;
                    newCollabMember.CollaborationGroupId = collabGroupId;
                    collabMembersToInsert.add(newCollabMember);
                }
            } else if (u.Profile.Name.contains('ASU Service')) {
                // Check if Service Profile
                if (chatterGroupsMap.containsKey('ASU Service')) {
                    /*
                     * Pass the groupname to the helper method and return the Ids of
                     * the collaboration members for dupe checking.
                     */
                    Set<Id> dupeMemberIdSet = collabUserIdsToDupeCheck('ASU Service');

                    if (!dupeMemberIdSet.contains(u.Id)) {
                        newCollabMember = new CollaborationGroupMember();
                        newCollabMember.MemberId = u.Id;
                        newCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU Service');
                        collabMembersToInsert.add(newCollabMember);
                    }
                }
            } else if (u.Profile.Name.contains('ASU Recruit')) {
                // Check if Recruitment Profile
                if (chatterGroupsMap.containsKey('ASU Recruitment')) {
                    /*
                     * Pass the groupname to the helper method and return the Ids of
                     * the collaboration members for dupe checking.
                     */
                    Set<Id> dupeMemberIdSet = collabUserIdsToDupeCheck('ASU Recruitment');

                    if (!dupeMemberIdSet.contains(u.Id)) {
                        newCollabMember = new CollaborationGroupMember();
                        newCollabMember.MemberId = u.Id;
                        newCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU Recruitment');
                        collabMembersToInsert.add(newCollabMember);
                    }
                }
            }

            // Check if in ASU Everyone Group
            if (!u.Profile.Name.contains('ASU Community')) {
                if (chatterGroupsMap.containsKey('ASU - Everyone')) {
                    // Loop through and add the collab member Ids to a set to check against.
                    Set<Id> dupeMemberIdSet = collabUserIdsToDupeCheck('ASU - Everyone');

                    if (!dupeMemberIdSet.contains(u.Id)) {
                        CollaborationGroupMember otherCollabMember = new CollaborationGroupMember();
                        otherCollabMember.MemberId = u.Id;
                        otherCollabMember.CollaborationGroupId = chatterGroupsMap.get('ASU - Everyone');
                        collabMembersToInsert.add(otherCollabMember);
                    }
                }
            }
        }

        // If we find Chatter members to insert, do that here
        if (collabMembersToInsert.size() > 0) {
            try {
                insert collabMembersToInsert;
            } catch (Exception e) {
                System.debug('!!!ERROR!!! ' + e.getMessage());
            }
        }
    }

    public static Set<Id> collabUserIdsToDupeCheck(String groupName) {
        // Create a list to store the collab members of the current group.
        List<CollaborationGroupMember> tempDupeMembers = new List<CollaborationGroupMember>();
        tempDupeMembers.addAll(dupeMemberCheckMap.get(groupName));

        // Loop through and add the collab member Ids to a set to check against.
        Set<Id> dupeMemberIdSet = new Set<Id>();

        for (CollaborationGroupMember cgm : tempDupeMembers) {
            dupeMemberIdSet.add(cgm.MemberId);
        }

        return dupeMemberIdSet;
    }

    @future
    public static void addToChatterGroupFuture(Set<Id> userIds) {
        addToChatterGroup(userIds);
    }
}
