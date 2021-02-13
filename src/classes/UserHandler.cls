public without sharing class UserHandler implements ITrigger {
    public static Map<String, List<CollaborationGroupMember>> dupeMemberCheckMap;
    public void bulkBefore() {
        if (Trigger.isInsert) {
            List<User> newUsers = Trigger.new;
            Id communityProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
            Id communityCapProfile = [SELECT Id FROM Profile WHERE Name = 'ASU Community CAP'].Id;
            List<String> asurites = new List<String>();
            Map<String, Contact> asuritesToContact = new Map<String, Contact>();
            Map<String, User> asuritesToUser = new Map<String, User>();

            for (User newUser : newUsers) {
                if (newUser.UserPermissionsKnowledgeUser) {
                    newUser.Role_Knowledge__c = true;
                }

                if (newUser.FederationIdentifier != null && newUser.ProfileId == communityProfile) {
                    asurites.add(newUser.FederationIdentifier.split('@').get(0));
                    asuritesToUser.put(newUser.FederationIdentifier.split('@').get(0), newUser);
                    System.debug(newUser.FederationIdentifier.split('@').get(0));
                }
            }

            if (asurites.size() > 0) {
                List<Contact> newUserContactsByASURITE = [
                    SELECT Id, ASURITE_Id__c, CAP__c
                    FROM Contact
                    WHERE ASURITE_Id__c IN :asurites
                ];
                for (Integer x = 0; x < newUserContactsByASURITE.size(); x++) {
                    Contact c = newUserContactsByASURITE.get(x);
                    asuritesToContact.put(c.ASURITE_Id__c, c);
                }

                List<String> asuritesKeys = new List<String>(asuritesToContact.keySet());

                for (Integer x = 0; x < asuritesKeys.size(); x++) {
                    String asurite = asuritesKeys.get(x);
                    Contact c = asuritesToContact.get(asurite);
                    User u = asuritesToUser.get(asurite);
                    u.ContactId = c.Id;

                    if (c.CAP__c != null) {
                        u.ProfileId = communityCapProfile;
                    }
                }
            }

            //throw new ContactServiceException('This is the Contact: ' + );
        }
    }

    public void bulkAfter() {
        Boolean needsBatch = (System.isBatch() || System.isFuture());
        /**
         * If we are running asyncronously, call Chatter add syncronously,
         * else call the future wrapper to run asyncronously.
         */
        if (needsBatch) {
            addToChatterGroup(Trigger.newMap.keySet());
        } else {
            addToChatterGroupFuture(Trigger.newMap.keySet());
        }
    }

    public void beforeInsert(SObject so) {
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        User updatedUser = (User) so;
        User oldUser = (User) so;

        if (updatedUser.UserPermissionsKnowledgeUser) {
            updatedUser.Role_Knowledge__c = true;
        } else {
            updatedUser.Role_Knowledge__c = false;
        }
    }

    public void beforeDelete(SObject so) {
    }

    public void beforeFinally() {
    }

    public void afterInsert(SObject so) {
    }

    public void afterUpdate(SObject oldSo, SObject so) {
    }

    public void afterDelete(SObject so) {
    }

    public void andFinally() {
    }

    /**
     * Adds user to the chatter group as collaborationmember with EmailNotification using Custom Setting
     * @param The userIds which needs to be added to the respective chatter groups based on their roles
     * @return void
     */
    public static void addToChatterGroup(Set<Id> userIds) {
        Id collabGroupId;
        Map<String, String> chatterSettingsMap = new Map<String, String>(); // map to hold Role vs Group Name from custom setting
        Map<String, String> roleToEFrequency = new Map<String, String>(); // map to hold Role vs Email Frequency from custom setting
        Map<String, String> chatterGroupsMap = new Map<String, String>(); // map to store Chatter Group name vs Group Id using SOQL

        // query string to populate List of users with fields from fieldset and passed from trigger context
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : SObjectType.User.FieldSets.PeopleSoft_Role_Fieldset.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += ' Id, UserRole.Name, Profile.Name, isActive FROM User WHERE Id IN: userIds';

        // SOQL
        List<User> userList = Database.query(query);

        // using Custom Setting method to save SOQL call and using application cache
        // map to hold Role vs Group Name from custom setting
        for (Chatter_Auto_Add_Users__c caau : Chatter_Auto_Add_Users__c.getall().values()) {
            chatterSettingsMap.put(caau.PeopleSoft_Role__c, caau.Chatter_Group_Name__c);
            roleToEFrequency.put(caau.PeopleSoft_Role__c, caau.NotificationFrequency__c);
        }

        // map to store Chatter Group name vs Group Id using SOQL
        for (CollaborationGroup cg : [SELECT Id, Name FROM CollaborationGroup]) {
            chatterGroupsMap.put(cg.Name, cg.Id);
        }

        // Populate a map of all the groups and their members for checking duplicates while inserting Chatter group members
        dupeMemberCheckMap = new Map<String, List<CollaborationGroupMember>>();
        for (CollaborationGroupMember groupMember : [
            SELECT MemberId, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE CollaborationGroupId IN :chatterGroupsMap.values()
        ]) {
            if (!dupeMemberCheckMap.containsKey(groupMember.CollaborationGroup.Name)) {
                dupeMemberCheckMap.put(groupMember.CollaborationGroup.Name, new List<CollaborationGroupMember>());
            }
            dupeMemberCheckMap.get(groupMember.CollaborationGroup.Name).add(groupMember);
        }

        /*
         * Loop through the userList to decide which users need to be added to what groups
         * then add them to the main list for insertion.
         */
        //List <String> userRoleList ;//= new List<String>();

        List<CollaborationGroupMember> collabMembersToInsert = new List<CollaborationGroupMember>(); // list to perform final DML
        for (User user : userList) {
            if (user.isActive) {
                List<String> userRoleList = new List<String>();
                // get all the Fields from the FieldSets to get the Role(s) of User
                for (Schema.FieldSetMember fld : SObjectType.User.FieldSets.PeopleSoft_Role_Fieldset.getFields()) {
                    // check if the Checkbox is set true, if true add to userRoleList for further processing
                    if ((Boolean) user.get(fld.getFieldPath())) {
                        userRoleList.add(fld.getLabel());
                    }
                }
                Set<String> chatterGroupUsedSet = new Set<String>();
                // iterate over above list and get the Chatter groups from chatterSettingsMap and
                // add collaboration members into one single list for insertion
                for (String str : userRoleList) {
                    // roles
                    if (chatterSettingsMap.containsKey(str)) {
                        // check if role is in map of custom setting
                        String chatterGrpName = chatterSettingsMap.get(str);
                        // Loop through and add the collab member Ids to a set to check against.
                        Set<Id> dupeMemberIdSet = collabUserIdsToDupeCheck(chatterGrpName);
                        // do not create Collaboration member if the dupeSet has the User Id already present
                        // check if group has already been used in this transaction,
                        // as a chatter group can be common for multiple PeopleSoft roles
                        if (!dupeMemberIdSet.contains(user.Id) && !chatterGroupUsedSet.contains(chatterGrpName)) {
                            CollaborationGroupMember newCollabMember = new CollaborationGroupMember();
                            newCollabMember.MemberId = user.Id;
                            newCollabMember.CollaborationGroupId = chatterGroupsMap.get(chatterGrpName);
                            newCollabMember.NotificationFrequency = roleToEFrequency.get(str);
                            collabMembersToInsert.add(newCollabMember);

                            chatterGroupUsedSet.add(chatterGrpName); // to check if a group has been used in this transaction
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
                ErrorLogger.log(ex, new List<String>(), false);
            }
        }
    }

    public static Set<Id> collabUserIdsToDupeCheck(String groupName) {
        // Loop through and add the collab member Ids to a set to check against.
        Set<Id> dupeMemberIdSet = new Set<Id>();
        if (dupeMemberCheckMap.get(groupName) != null) {
            for (CollaborationGroupMember cgm : dupeMemberCheckMap.get(groupName)) {
                dupeMemberIdSet.add(cgm.MemberId);
            }
        }
        return dupeMemberIdSet;
    }

    @future
    public static void addToChatterGroupFuture(Set<Id> userIds) {
        addToChatterGroup(userIds);
    }
}
