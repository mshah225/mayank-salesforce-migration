public without sharing class UserDeprovisionOrganizer {
    private List<User> newUsers;
    private Map<Id, User> oldUsersMap;
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;

    private List<Id> userToDeprovisionIds;
    private List<Case> allUserCases;
    private List<GroupMember> allUserPublicGroupMemberships;
    private List<CollaborationGroupMember> allUserChatterGroupMemberships;
    private List<PermissionSetAssignment> allUserPermissionSetAssignments;
    private List<UserPackageLicense> allUserPackageLicenses;

    private Map<Id, List<Case>> userToDeprovisionCaseMap;
    private Map<Id, String> userToDeprovisionGroupMembershipMap;
    private Map<Id, String> userToDeprovisionChatterGroupMembershipMap;
    private Map<Id, String> userToDeprovisionPermissionSetMap;
    private Map<Id, String> userToDeprovisionPackageLicenseMap;

    public void setOldUsersMap(Map<Id, SObject> oldUsersMap) {
        this.oldUsersMap = (Map<Id, User>) oldUsersMap;
    }

    public void setNewUsers(List<SObject> newUsers) {
        this.newUsers = (List<User>) newUsers;
    }

    public void deprovisionUsersAfterUpdate() {
        List<UserDeprovisioner> userDeprovisionersList = new List<UserDeprovisioner>();
        List<User> deprovisionedUsersWithProcessingNotes = new List<User>();
        userToDeprovisionIds = new List<Id>();
        deprovisionUserConfiguration = Deprovision_User_Configuration__c.getAll();

        for (User userToDeprovision : newUsers) {
            if (userToDeprovision.Deprovision_User__c && !oldUsersMap.get(userToDeprovision.Id).Deprovision_User__c) {
                userToDeprovisionIds.add(userToDeprovision.Id);
                UserDeprovisioner userDeprovisioner = new UserDeprovisioner();
                userDeprovisioner.setUserToDeprovision(userToDeprovision);
                userDeprovisionersList.add(userDeprovisioner);
            }
        }

        if (!userDeprovisionersList.isEmpty()) {
            populateUserToDeprovisionCaseMap();
            populateUserToDeprovisionGroupMembershipMap();
            populateUserToDeprovisionChatterGroupMembershipMap();
            populateUserToDeprovisionPermissionSetMap();
            populateUserToDeprovisionPackageLicenseMap();

            List<Case> updatedUserCases = new List<Case>();
            Map<Id, Id> caseToUserMap = new Map<Id, Id>();

            for (UserDeprovisioner userDeprovisioner : userDeprovisionersList) {
                Id userId = userDeprovisioner.getUserToDeprovision().Id;
                userDeprovisioner.setDeprovisionUserConfiguration(deprovisionUserConfiguration);
                userDeprovisioner.setUserCases(userToDeprovisionCaseMap.get(userId));
                userDeprovisioner.setGroupMemberships(userToDeprovisionGroupMembershipMap.get(userId));
                userDeprovisioner.setChatterGroupMemberships(userToDeprovisionChatterGroupMembershipMap.get(userId));
                userDeprovisioner.setPermissionSets(userToDeprovisionPermissionSetMap.get(userId));
                userDeprovisioner.setPackageLicenses(userToDeprovisionPackageLicenseMap.get(userId));
                userDeprovisioner.deprovisionUser();
                updatedUserCases.addAll(userDeprovisioner.getUpdatedUserCases());
                caseToUserMap.putAll(userDeprovisioner.getCaseToUserMap());
                deprovisionedUsersWithProcessingNotes.add(userDeprovisioner.getDeprovisionedUserWithProcessingNotes());
            }

            if (!deprovisionedUsersWithProcessingNotes.isEmpty()) {
                updateSobjectRecords('Id', deprovisionedUsersWithProcessingNotes);
            }

            if (!allUserPublicGroupMemberships.isEmpty()) {
                deleteSobjectRecords('UserOrGroupId', allUserPublicGroupMemberships);
            }

            if (!allUserPermissionSetAssignments.isEmpty()) {
                deleteSobjectRecords('AssigneeId', allUserPermissionSetAssignments);
            }

            if (!allUserPackageLicenses.isEmpty()) {
                deleteSobjectRecords('UserId', allUserPackageLicenses);
            }

            if (!updatedUserCases.isEmpty() || !allUserChatterGroupMemberships.isEmpty()) {
                UserDeprovisionQueue userDeprovisionQueue = new UserDeprovisionQueue();
                userDeprovisionQueue.setUpdatedUserCases(updatedUserCases);
                userDeprovisionQueue.setCaseToUserMap(caseToUserMap);
                userDeprovisionQueue.setAllUserChatterGroupMemberships(allUserChatterGroupMemberships);
                System.enqueueJob(userDeprovisionQueue);
            }
        }
    }

    private void populateUserToDeprovisionCaseMap() {
        allUserCases = [
            SELECT
                Id,
                OwnerId,
                CC_Functional_Group__c,
                CC_Functional_Group__r.Name,
                CC_Functional_Group__r.Queue_Id__c,
                CC_Functional_Group__r.Is_Functional_Group_Private__c
            FROM Case
            WHERE OwnerId IN :userToDeprovisionIds
        ];

        userToDeprovisionCaseMap = new Map<Id, List<Case>>();
        for (Case userCase : allUserCases) {
            if (userToDeprovisionCaseMap.containsKey(userCase.OwnerId)) {
                userToDeprovisionCaseMap.get(userCase.OwnerId).add(userCase);
            } else {
                List<Case> userCases = new List<Case>();
                userCases.add(userCase);
                userToDeprovisionCaseMap.put(userCase.OwnerId, userCases);
            }
        }
    }

    private void populateUserToDeprovisionGroupMembershipMap() {
        allUserPublicGroupMemberships = [
            SELECT UserOrGroupId, Group.Name
            FROM GroupMember
            WHERE UserOrGroupId IN :userToDeprovisionIds
        ];

        userToDeprovisionGroupMembershipMap = new Map<Id, String>();
        for (GroupMember groupMember : allUserPublicGroupMemberships) {
            if (userToDeprovisionGroupMembershipMap.containsKey(groupMember.UserOrGroupId)) {
                String groupMemberships = userToDeprovisionGroupMembershipMap.get(groupMember.UserOrGroupId);
                groupMemberships += ', ' + groupMember.Group.Name;
                userToDeprovisionGroupMembershipMap.put(groupMember.UserOrGroupId, groupMemberships);
            } else {
                String groupMemberships = '' + groupMember.Group.Name;
                userToDeprovisionGroupMembershipMap.put(groupMember.UserOrGroupId, groupMemberships);
            }
        }
    }

    private void populateUserToDeprovisionChatterGroupMembershipMap() {
        allUserChatterGroupMemberships = [
            SELECT MemberId, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE MemberId IN :userToDeprovisionIds
        ];

        userToDeprovisionChatterGroupMembershipMap = new Map<Id, String>();
        for (CollaborationGroupMember collaborationGroupMember : allUserChatterGroupMemberships) {
            if (userToDeprovisionChatterGroupMembershipMap.containsKey(collaborationGroupMember.MemberId)) {
                String chatterGroupMemberships = userToDeprovisionChatterGroupMembershipMap.get(
                    collaborationGroupMember.MemberId
                );
                chatterGroupMemberships += ', ' + collaborationGroupMember.CollaborationGroup.Name;
                userToDeprovisionChatterGroupMembershipMap.put(
                    collaborationGroupMember.MemberId,
                    chatterGroupMemberships
                );
            } else {
                String chatterGroupMemberships = '' + collaborationGroupMember.CollaborationGroup.Name;
                userToDeprovisionChatterGroupMembershipMap.put(
                    collaborationGroupMember.MemberId,
                    chatterGroupMemberships
                );
            }
        }
    }

    private void populateUserToDeprovisionPermissionSetMap() {
        allUserPermissionSetAssignments = [
            SELECT AssigneeId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userToDeprovisionIds AND PermissionSet.IsOwnedByProfile = FALSE
        ];

        userToDeprovisionPermissionSetMap = new Map<Id, String>();
        for (PermissionSetAssignment permissionSetAssignment : allUserPermissionSetAssignments) {
            if (userToDeprovisionPermissionSetMap.containsKey(permissionSetAssignment.AssigneeId)) {
                String permissionSets = userToDeprovisionPermissionSetMap.get(permissionSetAssignment.AssigneeId);
                permissionSets += ', ' + permissionSetAssignment.PermissionSet.Name;
                userToDeprovisionPermissionSetMap.put(permissionSetAssignment.AssigneeId, permissionSets);
            } else {
                String permissionSets = permissionSetAssignment.PermissionSet.Name;
                userToDeprovisionPermissionSetMap.put(permissionSetAssignment.AssigneeId, permissionSets);
            }
        }
    }

    private void populateUserToDeprovisionPackageLicenseMap() {
        allUserPackageLicenses = [
            SELECT UserId, PackageLicense.NamespacePrefix
            FROM UserPackageLicense
            WHERE
                UserId IN :userToDeprovisionIds
                AND PackageLicenseId IN :getDeprovisionConfigurationPackageLicenseIds()
        ];

        userToDeprovisionPackageLicenseMap = new Map<Id, String>();
        for (UserPackageLicense userPackageLicense : allUserPackageLicenses) {
            if (userToDeprovisionPackageLicenseMap.containsKey(userPackageLicense.UserId)) {
                String packageLicenses = userToDeprovisionPackageLicenseMap.get(userPackageLicense.UserId);
                packageLicenses += userPackageLicense.PackageLicense.NamespacePrefix;
                userToDeprovisionPackageLicenseMap.put(userPackageLicense.UserId, packageLicenses);
            } else {
                String packageLicenses = userPackageLicense.PackageLicense.NamespacePrefix;
                userToDeprovisionPackageLicenseMap.put(userPackageLicense.UserId, packageLicenses);
            }
        }
    }

    private List<Id> getDeprovisionConfigurationPackageLicenseIds() {
        List<Id> packageLicenseIds = new List<Id>();
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('RemovePackageLicense')) {
                packageLicenseIds.add(Id.valueOf(deprovisionUserConfiguration.get(deprovisionConfigurationName).Id__c));
            }
        }
        return packageLicenseIds;
    }

    public void updateSobjectRecords(String userIdField, List<SObject> recordListToOperate) {
        List<User> usersWithErrors = new List<User>();

        Database.SaveResult[] saveResult = Database.update(recordListToOperate, false);

        for (Integer i = 0; i < saveResult.size(); i++) {
            if (!saveResult[i].isSuccess()) {
                String processingNotes = 'The following errors have occurred:';
                for (Database.Error err : saveResult[i].getErrors()) {
                    processingNotes += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    processingNotes += '\nUser fields that affected this error: ' + err.getFields();
                }
                usersWithErrors.add(
                    new User(Id = (Id) recordListToOperate[i].get(userIdField), Processing_Notes__c = processingNotes)
                );
            }
        }
        update usersWithErrors;
    }

    public static void deleteSobjectRecords(String userIdField, List<SObject> recordListToOperate) {
        List<User> usersWithErrors = new List<User>();

        Database.DeleteResult[] deleteResult = Database.delete(recordListToOperate, false);

        for (Integer i = 0; i < deleteResult.size(); i++) {
            if (!deleteResult[i].isSuccess()) {
                String processingNotes = 'The following errors have occurred:';
                for (Database.Error err : deleteResult[i].getErrors()) {
                    processingNotes += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    processingNotes += '\nUser fields that affected this error: ' + err.getFields();
                }
                usersWithErrors.add(
                    new User(Id = (Id) recordListToOperate[i].get(userIdField), Processing_Notes__c = processingNotes)
                );
            }
        }
        update usersWithErrors;
    }
}
