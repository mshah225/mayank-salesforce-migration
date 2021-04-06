public without sharing class UserChatterGroupHandler implements Queueable {
    List<User> alteredUsers;
    Map<String, List<ChatterGroupDesc>> peopleSoftRoleToChatterGroups;
    Map<String, String> chatterGroupNameToId;
    Map<String, String> profileIdToName;
    Map<String, List<String>> userIdToPermSetNames;
    Map<String, List<Id>> existingChatterGroupToMembers;
    List<CollaborationGroupMember> collabMembersToInsert;
    List<String> variables;

    public UserChatterGroupHandler(List<User> alteredUsers) {
        this.alteredUsers = alteredUsers;
        chatterGroupNameToId = new Map<String, String>();
        profileIdToName = new Map<String, String>();
        userIdToPermSetNames = new Map<String, List<String>>();
        existingChatterGroupToMembers = new Map<String, List<Id>>();
        collabMembersToInsert = new List<CollaborationGroupMember>();
        variables = new List<String>();

        peopleSoftRoleToChatterGroups = new Map<String, List<ChatterGroupDesc>>();
    }

    public void execute(QueueableContext context) {
        run();
    }

    private void run() {
        // Load custom setting details
        for (Chatter_Auto_Add_Users__c caau : Chatter_Auto_Add_Users__c.getAll().values()) {
            if (!peopleSoftRoleToChatterGroups.containsKey(caau.PeopleSoft_Role__c)) {
                peopleSoftRoleToChatterGroups.put(caau.PeopleSoft_Role__c, new List<ChatterGroupDesc>());
            }
            peopleSoftRoleToChatterGroups.get(caau.PeopleSoft_Role__c).add(new ChatterGroupDesc(caau));
        }

        // Get lists for subsequent queries
        // All user ids
        List<Id> userIds = new List<Id>();
        List<Id> profileIds = new List<Id>();
        for (User u : alteredUsers) {
            userIds.add(u.Id);
            profileIds.add(u.ProfileId);
        }
        // Lists of perm set and chatter group names
        List<String> allPermSetNames = new List<String>();
        List<String> allChatterGrpNames = new List<String>();
        for (List<ChatterGroupDesc> cgds : peopleSoftRoleToChatterGroups.values()) {
            for (ChatterGroupDesc cgd : cgds) {
                allPermSetNames.addAll(cgd.requiredPermissionSetNames);
                allChatterGrpNames.add(cgd.chatterGroupName);
            }
        }

        // map to store Chatter Group name vs Group Id
        if (Test.isRunningTest()) {
            allChatterGrpNames.addAll(
                new List<String>{ '[Test] ASU Service', '[Test] ASU Recruitment', '[Test] ASU - Everyone' }
            );
        } else {
            allChatterGrpNames.addAll(new List<String>{ 'ASU Service', 'ASU Recruitment', 'ASU - Everyone' });
        }
        for (CollaborationGroup cg : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN :allChatterGrpNames]) {
            chatterGroupNameToId.put(cg.Name, cg.Id);
        }

        // Get perm set assignments for each user
        for (PermissionSetAssignment psa : [
            SELECT AssigneeId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userIds AND PermissionSet.Name IN :allPermSetNames
        ]) {
            if (!userIdToPermSetNames.containsKey(psa.AssigneeId)) {
                userIdToPermSetNames.put(psa.AssigneeId, new List<String>());
            }
            userIdToPermSetNames.get(psa.AssigneeId).add(psa.PermissionSet.Name);
        }
        for (Id uid : userIds) {
            if (!userIdToPermSetNames.containsKey(uid)) {
                userIdToPermSetNames.put(uid, new List<String>());
            }
        }

        // Existing users in each collab group
        for (CollaborationGroupMember groupMember : [
            SELECT MemberId, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE CollaborationGroupId IN :chatterGroupNameToId.values() AND MemberId IN :userIds
        ]) {
            if (!existingChatterGroupToMembers.containsKey(groupMember.CollaborationGroup.Name)) {
                existingChatterGroupToMembers.put(groupMember.CollaborationGroup.Name, new List<Id>());
            }
            existingChatterGroupToMembers.get(groupMember.CollaborationGroup.Name).add(groupMember.MemberId);
        }

        // Get profile names
        for (Profile p : [SELECT Id, Name FROM Profile WHERE Id IN :profileIds]) {
            profileIdToName.put(p.Id, p.Name);
        }

        /*
         * Loop through the userList to decide which users need to be added to what groups
         * then add them to the main list for insertion.
         */
        for (User user : alteredUsers) {
            if (user.isActive && user.EmployeeNumber != null && user.EmployeeNumber.length() != 0) {
                List<String> userRoleList = new List<String>();
                // get all the Fields from the FieldSets to get the Role(s) of User
                for (Schema.FieldSetMember fld : SObjectType.User.FieldSets.PeopleSoft_Role_Fieldset.getFields()) {
                    // check if the Checkbox is set true, if true add to userRoleList for further processing
                    if ((Boolean) user.get(fld.getFieldPath())) {
                        userRoleList.add(fld.getLabel());
                    }
                }
                // Also use profile name to match with groups to add
                userRoleList.add(profileIdToName.get(user.ProfileId));

                for (String str : userRoleList) {
                    if (peopleSoftRoleToChatterGroups.containsKey(str)) {
                        List<ChatterGroupDesc> chatterGroupsDescsForRole = peopleSoftRoleToChatterGroups.get(str);

                        for (ChatterGroupDesc eachGroupDesc : chatterGroupsDescsForRole) {
                            if (!existingChatterGroupToMembers.containsKey(eachGroupDesc.chatterGroupName)) {
                                existingChatterGroupToMembers.put(eachGroupDesc.chatterGroupName, new List<Id>());
                            }

                            // Check all reuqired perm sets for this peoplesoft role - chatter group pair
                            Boolean hasAllRequiredPermSets = true;
                            for (String permSetName : eachGroupDesc.requiredPermissionSetNames) {
                                if (!userIdToPermSetNames.get(user.Id).contains(permSetName)) {
                                    hasAllRequiredPermSets = false;
                                    break;
                                }
                            }

                            if (
                                !existingChatterGroupToMembers.get(eachGroupDesc.chatterGroupName).contains(user.Id) &&
                                hasAllRequiredPermSets
                            ) {
                                CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                                newCollabMember.MemberId = user.Id;
                                newCollabMember.CollaborationGroupId = chatterGroupNameToId.get(
                                    eachGroupDesc.chatterGroupName
                                );
                                newCollabMember.NotificationFrequency = eachGroupDesc.notificationFrequency;
                                collabMembersToInsert.add(newCollabMember);

                                existingChatterGroupToMembers.get(eachGroupDesc.chatterGroupName).add(user.Id);
                            }
                        }
                    }
                }

                // General additions based on profile name
                if (user.ProfileId != null && profileIdToName.get(user.ProfileId) != null) {
                    if (profileIdToName.get(user.ProfileId).contains('ASU Service')) {
                        String keyName = Test.isRunningTest() ? '[Test] ASU Service' : 'ASU Service';
                        if (chatterGroupNameToId.containsKey(keyName)) {
                            if (!existingChatterGroupToMembers.containsKey(keyName)) {
                                existingChatterGroupToMembers.put(keyName, new List<Id>());
                            }

                            if (!existingChatterGroupToMembers.get(keyName).contains(user.Id)) {
                                CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                                newCollabMember.MemberId = user.Id;
                                newCollabMember.CollaborationGroupId = chatterGroupNameToId.get(keyName);
                                newCollabMember.NotificationFrequency = 'D';
                                collabMembersToInsert.add(newCollabMember);
                                existingChatterGroupToMembers.get(keyName).add(user.Id);
                            }
                        }
                    }
                    if (profileIdToName.get(user.ProfileId).contains('ASU Recruit')) {
                        String keyName = Test.isRunningTest() ? '[Test] ASU Recruitment' : 'ASU Recruitment';
                        if (chatterGroupNameToId.containsKey(keyName)) {
                            if (!existingChatterGroupToMembers.containsKey(keyName)) {
                                existingChatterGroupToMembers.put(keyName, new List<Id>());
                            }

                            if (!existingChatterGroupToMembers.get(keyName).contains(user.Id)) {
                                CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                                newCollabMember.MemberId = user.Id;
                                newCollabMember.CollaborationGroupId = chatterGroupNameToId.get(keyName);
                                newCollabMember.NotificationFrequency = 'D';
                                collabMembersToInsert.add(newCollabMember);
                                existingChatterGroupToMembers.get(keyName).add(user.Id);
                            }
                        }
                    }
                    if (!profileIdToName.get(user.ProfileId).contains('ASU Community')) {
                        String keyName = Test.isRunningTest() ? '[Test] ASU - Everyone' : 'ASU - Everyone';
                        if (chatterGroupNameToId.containsKey(keyName)) {
                            if (!existingChatterGroupToMembers.containsKey(keyName)) {
                                existingChatterGroupToMembers.put(keyName, new List<Id>());
                            }

                            if (!existingChatterGroupToMembers.get(keyName).contains(user.Id)) {
                                CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                                newCollabMember.MemberId = user.Id;
                                newCollabMember.CollaborationGroupId = chatterGroupNameToId.get(keyName);
                                newCollabMember.NotificationFrequency = 'D';
                                collabMembersToInsert.add(newCollabMember);
                                existingChatterGroupToMembers.get(keyName).add(user.Id);
                            }
                        }
                    }
                }
            }
        }

        // If we find Chatter members to insert, do that here
        if (!collabMembersToInsert.isEmpty()) {
            try {
                insert collabMembersToInsert;
            } catch (Exception ex) {
                Map<Id, List<Id>> chatterGroupToUserId = new Map<Id, List<Id>>();
                for (CollaborationGroupMember cgm : collabMembersToInsert) {
                    if (!chatterGroupToUserId.containsKey(cgm.CollaborationGroupId)) {
                        chatterGroupToUserId.put(cgm.CollaborationGroupId, new List<Id>());
                    }
                    chatterGroupToUserId.get(cgm.CollaborationGroupId).add(cgm.MemberId);
                }
                for (Id groupId : chatterGroupToUserId.keySet()) {
                    variables.add(
                        ErrorLogger.convertListToJSON('groupId=' + groupId, chatterGroupToUserId.get(groupId))
                    );
                }

                ErrorLogger.log(ex, variables, false);
            }
        }
    }

    public static void handleChatterGroups(List<User> alteredUsers) {
        System.enqueueJob(new UserChatterGroupHandler(alteredUsers));
    }

    @TestVisible
    private class ChatterGroupDesc {
        public final String peopleSoftRole;
        public final String chatterGroupName;
        public final String notificationFrequency;
        public final List<String> requiredPermissionSetNames;

        public ChatterGroupDesc(Chatter_Auto_Add_Users__c customSetting) {
            peopleSoftRole = customSetting.PeopleSoft_Role__c;
            chatterGroupName = customSetting.Chatter_Group_Name__c;
            notificationFrequency = customSetting.NotificationFrequency__c;
            requiredPermissionSetNames = new List<String>();
            if (customSetting.Required_Permission_Sets__c != null) {
                for (String s : customSetting.Required_Permission_Sets__c.split(';')) {
                    requiredPermissionSetNames.add(s.trim());
                }
            }
        }
    }
}
