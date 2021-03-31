public with sharing class UserChatterGroupHandler implements Queueable {
    List<User> alteredUsers;
    Map<String, List<String>> chatterSettingsMap;
    Map<String, String> roleToEFrequency;
    Map<String, String> chatterGroupsMap;
    Map<String, String> profileIdToName;
    Map<String, List<Id>> chatterGroupToMembers;
    List<CollaborationGroupMember> collabMembersToInsert;
    List<String> variables;

    public UserChatterGroupHandler(List<User> alteredUsers) {
        this.alteredUsers = alteredUsers;
        chatterSettingsMap = new Map<String, List<String>>();
        roleToEFrequency = new Map<String, String>();
        chatterGroupsMap = new Map<String, String>();
        profileIdToName = new Map<String, String>();
        chatterGroupToMembers = new Map<String, List<Id>>();
        collabMembersToInsert = new List<CollaborationGroupMember>();
        variables = new List<String>();
    }

    public void execute(QueueableContext context) {
        run();
    }

    public void run() {
        // Load custom setting details
        for (Chatter_Auto_Add_Users__c caau : Chatter_Auto_Add_Users__c.getAll().values()) {
            if (!chatterSettingsMap.containsKey(caau.PeopleSoft_Role__c)) {
                chatterSettingsMap.put(caau.PeopleSoft_Role__c, new List<String>());
            }

            chatterSettingsMap.get(caau.PeopleSoft_Role__c).add(caau.Chatter_Group_Name__c);
            roleToEFrequency.put(caau.PeopleSoft_Role__c, caau.NotificationFrequency__c);
        }

        // map to store Chatter Group name vs Group Id using SOQL
        for (CollaborationGroup cg : [SELECT Id, Name FROM CollaborationGroup]) {
            chatterGroupsMap.put(cg.Name, cg.Id);
        }

        // Existing users in each collab group
        for (CollaborationGroupMember groupMember : [
            SELECT MemberId, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE CollaborationGroupId IN :chatterGroupsMap.values()
        ]) {
            if (!chatterGroupToMembers.containsKey(groupMember.CollaborationGroup.Name)) {
                chatterGroupToMembers.put(groupMember.CollaborationGroup.Name, new List<Id>());
            }
            chatterGroupToMembers.get(groupMember.CollaborationGroup.Name).add(groupMember.MemberId);
        }

        // Get profile names
        for (User user : alteredUsers) {
            profileIdToName.put(user.ProfileId, null);
        }
        for (Profile p : [SELECT Id, Name FROM Profile WHERE Id IN :profileIdToName.keySet()]) {
            profileIdToName.put(p.Id, p.Name);
        }

        /*
         * Loop through the userList to decide which users need to be added to what groups
         * then add them to the main list for insertion.
         */
        for (User user : alteredUsers) {
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

            // iterate over above list and get the Chatter groups from chatterSettingsMap and
            // add collaboration members into one single list for insertion
            for (String str : userRoleList) {
                // roles
                if (chatterSettingsMap.containsKey(str)) {
                    // check if role is in map of custom setting

                    List<String> chatterGroupsForRole = chatterSettingsMap.get(str);

                    for (String chatterGrpName : chatterGroupsForRole) {
                        // do not create Collaboration member if the dupeSet has the User Id already present
                        // check if group has already been used in this transaction,
                        // as a chatter group can be common for multiple PeopleSoft roles
                        if (chatterGroupToMembers.get(chatterGrpName) == null) {
                            chatterGroupToMembers.put(chatterGrpName, new List<Id>());
                        }

                        if (!chatterGroupToMembers.get(chatterGrpName).contains(user.Id)) {
                            CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                            newCollabMember.MemberId = user.Id;
                            newCollabMember.CollaborationGroupId = chatterGroupsMap.get(chatterGrpName);
                            newCollabMember.NotificationFrequency = roleToEFrequency.get(str);
                            collabMembersToInsert.add(newCollabMember);

                            chatterGroupToMembers.get(chatterGrpName).add(user.Id);
                        }
                    }
                }
            }

            // General additions based on profile name
            if (user.ProfileId != null && profileIdToName.get(user.ProfileId) != null) {
                if (profileIdToName.get(user.ProfileId).contains('ASU Service')) {
                    String keyName = Test.isRunningTest() ? '[Test] ASU Service' : 'ASU Service';
                    if (chatterGroupsMap.containsKey(keyName)) {
                        if (chatterGroupToMembers.get(keyName) == null) {
                            chatterGroupToMembers.put(keyName, new List<Id>());
                        }

                        if (!chatterGroupToMembers.get(keyName).contains(user.Id)) {
                            CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                            newCollabMember.MemberId = user.Id;
                            newCollabMember.CollaborationGroupId = chatterGroupsMap.get(keyName);
                            newCollabMember.NotificationFrequency = 'D';
                            collabMembersToInsert.add(newCollabMember);
                            chatterGroupToMembers.get(keyName).add(user.Id);
                        }
                    }
                }
                if (profileIdToName.get(user.ProfileId).contains('ASU Recruit')) {
                    String keyName = Test.isRunningTest() ? '[Test] ASU Recruitment' : 'ASU Recruitment';
                    if (chatterGroupsMap.containsKey(keyName)) {
                        if (chatterGroupToMembers.get(keyName) == null) {
                            chatterGroupToMembers.put(keyName, new List<Id>());
                        }

                        if (!chatterGroupToMembers.get(keyName).contains(user.Id)) {
                            CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                            newCollabMember.MemberId = user.Id;
                            newCollabMember.CollaborationGroupId = chatterGroupsMap.get(keyName);
                            newCollabMember.NotificationFrequency = 'D';
                            collabMembersToInsert.add(newCollabMember);
                            chatterGroupToMembers.get(keyName).add(user.Id);
                        }
                    }
                }
                if (!profileIdToName.get(user.ProfileId).contains('ASU Community')) {
                    String keyName = Test.isRunningTest() ? '[Test] ASU - Everyone' : 'ASU - Everyone';
                    if (chatterGroupsMap.containsKey(keyName)) {
                        if (chatterGroupToMembers.get(keyName) == null) {
                            chatterGroupToMembers.put(keyName, new List<Id>());
                        }

                        if (!chatterGroupToMembers.get(keyName).contains(user.Id)) {
                            CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                            newCollabMember.MemberId = user.Id;
                            newCollabMember.CollaborationGroupId = chatterGroupsMap.get(keyName);
                            newCollabMember.NotificationFrequency = 'D';
                            collabMembersToInsert.add(newCollabMember);
                            chatterGroupToMembers.get(keyName).add(user.Id);
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
                        ErrorLogger.convertListToJSON('groupId:' + groupId, chatterGroupToUserId.get(groupId))
                    );
                }

                ErrorLogger.log(ex, variables, false);
            }
        }
    }

    public static void handleChatterGroups(List<User> alteredUsers) {
        System.enqueueJob(new UserChatterGroupHandler(alteredUsers));
    }
}
