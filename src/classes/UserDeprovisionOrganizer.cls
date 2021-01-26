public without sharing class UserDeprovisionOrganizer {
    /** All setup objects should be updated through here.  And non-setup objects in the UserDeprovisionerOrganizer
     * https://developer.salesforce.com/docs/atlas.en-us.230.0.apexcode.meta/apexcode/apex_dml_non_mix_sobjects.htm
     * contains a list of setup objects, but it is incomplete so you should perform a quick test via the developer
     * console if you are unsure if an object is a setup object or not.
     */

    private List<User> newUsers;
    private Map<Id, User> oldUsersMap;
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;

    List<UserDeprovisioner> userDeprovisionersList;

    private List<Id> userToDeprovisionIds;
    private List<Case> allUserCases;
    private List<GroupMember> allUserPublicGroupMemberships;
    private List<CollaborationGroupMember> allUserChatterGroupMemberships;
    private List<PermissionSetAssignment> allUserPermissionSetAssignments;
    private List<UserPackageLicense> allUserPackageLicenses;
    private List<UserLogin> allUserLogins;

    private Map<Id, List<Case>> userToCaseMap;
    private Map<Id, UserLogin> userToUserLoginMap;
    private Map<Id, String> userToGroupMembershipMap;
    private Map<Id, String> userToChatterGroupMembershipMap;
    private Map<Id, String> userToPermissionSetMap;
    private Map<Id, String> userToPackageLicenseMap;
    private Map<Id, String> userToProcessingNotesMap;

    private static Boolean debug = false;

    public UserDeprovisionOrganizer(Map<Id, User> oldUsersMap, List<User> newUsers) {
        this.newUsers = newUsers;
        this.oldUsersMap = oldUsersMap;
        this.deprovisionUserConfiguration = Deprovision_User_Configuration__c.getAll();

        this.userToDeprovisionIds = new List<Id>();
        this.userDeprovisionersList = new List<UserDeprovisioner>();

        this.userToCaseMap = new Map<Id, List<Case>>();
        this.userToUserLoginMap = new Map<Id, UserLogin>();
        this.userToGroupMembershipMap = new Map<Id, String>();
        this.userToChatterGroupMembershipMap = new Map<Id, String>();
        this.userToPermissionSetMap = new Map<Id, String>();
        this.userToPackageLicenseMap = new Map<Id, String>();
        this.userToProcessingNotesMap = new Map<Id, String>();

        // Make list of user's that need deprovisioning
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
            populateUserToUserLoginMap();
        }
    }

    public void deprovisionUsersAfterUpdate() {
        if (!userDeprovisionersList.isEmpty()) {
            List<Case> updatedUserCases = new List<Case>();
            Map<Id, Id> caseToUserMap = new Map<Id, Id>();
            List<UserLogin> updatedUserLogins = new List<UserLogin>();
            List<User> deprovisionedUsersWithProcessingNotes = new List<User>();

            for (UserDeprovisioner userDeprovisioner : userDeprovisionersList) {
                Id userId = userDeprovisioner.getUserToDeprovision().Id;
                userDeprovisioner.setDeprovisionUserConfiguration(deprovisionUserConfiguration);
                userDeprovisioner.setUserCases(userToCaseMap.get(userId));
                userDeprovisioner.setGroupMemberships(userToGroupMembershipMap.get(userId));
                userDeprovisioner.setChatterGroupMemberships(userToChatterGroupMembershipMap.get(userId));
                userDeprovisioner.setPermissionSets(userToPermissionSetMap.get(userId));
                userDeprovisioner.setPackageLicenses(userToPackageLicenseMap.get(userId));
                userDeprovisioner.setUserLogin(userToUserLoginMap.get(userId));
                userDeprovisioner.deprovisionUser();
                updatedUserCases.addAll(userDeprovisioner.getUpdatedUserCases());
                updatedUserLogins.add(userDeprovisioner.getUpdatedUserLogin());
                caseToUserMap.putAll(userDeprovisioner.getCaseToUserMap());
                User userWithProcessingNotes = userDeprovisioner.getDeprovisionedUserWithProcessingNotes();
                deprovisionedUsersWithProcessingNotes.add(userWithProcessingNotes);
                userToProcessingNotesMap.put(userId, userWithProcessingNotes.Processing_Notes__c);
            }

            if (!allUserPublicGroupMemberships.isEmpty()) {
                deleteSobjectRecords('UserOrGroupId', allUserPublicGroupMemberships, userToProcessingNotesMap);
            }

            if (!allUserPermissionSetAssignments.isEmpty()) {
                deleteSobjectRecords('AssigneeId', allUserPermissionSetAssignments, userToProcessingNotesMap);
            }

            if (!allUserPackageLicenses.isEmpty()) {
                deleteSobjectRecords('UserId', allUserPackageLicenses, userToProcessingNotesMap);
            }

            if (!deprovisionedUsersWithProcessingNotes.isEmpty()) {
                updateSobjectRecords('Id', deprovisionedUsersWithProcessingNotes, userToProcessingNotesMap);
            }

            // And handle all non-setup objects here
            if (!updatedUserCases.isEmpty() || !allUserChatterGroupMemberships.isEmpty() || !allUserLogins.isEmpty()) {
                UserDeprovisionQueue userDeprovisionQueue = new UserDeprovisionQueue();
                userDeprovisionQueue.setUpdatedUserCases(updatedUserCases);
                userDeprovisionQueue.setCaseToUserMap(caseToUserMap);
                userDeprovisionQueue.setAllUserChatterGroupMemberships(allUserChatterGroupMemberships);
                userDeprovisionQueue.setUserToProcessingNotesMap(userToProcessingNotesMap);
                userDeprovisionQueue.setUpdatedUserLogins(updatedUserLogins);
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

        for (Case userCase : allUserCases) {
            if (userToCaseMap.containsKey(userCase.OwnerId)) {
                userToCaseMap.get(userCase.OwnerId).add(userCase);
            } else {
                List<Case> userCases = new List<Case>();
                userCases.add(userCase);
                userToCaseMap.put(userCase.OwnerId, userCases);
            }
        }
    }

    private void populateUserToDeprovisionGroupMembershipMap() {
        allUserPublicGroupMemberships = [
            SELECT UserOrGroupId, Group.Name
            FROM GroupMember
            WHERE UserOrGroupId IN :userToDeprovisionIds
        ];

        for (GroupMember groupMember : allUserPublicGroupMemberships) {
            if (userToGroupMembershipMap.containsKey(groupMember.UserOrGroupId)) {
                String groupMemberships = userToGroupMembershipMap.get(groupMember.UserOrGroupId);
                groupMemberships += ', ' + groupMember.Group.Name;
                userToGroupMembershipMap.put(groupMember.UserOrGroupId, groupMemberships);
            } else {
                String groupMemberships = '' + groupMember.Group.Name;
                userToGroupMembershipMap.put(groupMember.UserOrGroupId, groupMemberships);
            }
        }
    }

    private void populateUserToDeprovisionChatterGroupMembershipMap() {
        allUserChatterGroupMemberships = [
            SELECT MemberId, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE MemberId IN :userToDeprovisionIds
        ];

        for (CollaborationGroupMember collaborationGroupMember : allUserChatterGroupMemberships) {
            if (userToChatterGroupMembershipMap.containsKey(collaborationGroupMember.MemberId)) {
                String chatterGroupMemberships = userToChatterGroupMembershipMap.get(collaborationGroupMember.MemberId);
                chatterGroupMemberships += ', ' + collaborationGroupMember.CollaborationGroup.Name;
                userToChatterGroupMembershipMap.put(collaborationGroupMember.MemberId, chatterGroupMemberships);
            } else {
                String chatterGroupMemberships = '' + collaborationGroupMember.CollaborationGroup.Name;
                userToChatterGroupMembershipMap.put(collaborationGroupMember.MemberId, chatterGroupMemberships);
            }
        }
    }

    private void populateUserToDeprovisionPermissionSetMap() {
        allUserPermissionSetAssignments = [
            SELECT AssigneeId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userToDeprovisionIds AND PermissionSet.IsOwnedByProfile = FALSE
        ];

        for (PermissionSetAssignment permissionSetAssignment : allUserPermissionSetAssignments) {
            if (userToPermissionSetMap.containsKey(permissionSetAssignment.AssigneeId)) {
                String permissionSets = userToPermissionSetMap.get(permissionSetAssignment.AssigneeId);
                permissionSets += ', ' + permissionSetAssignment.PermissionSet.Name;
                userToPermissionSetMap.put(permissionSetAssignment.AssigneeId, permissionSets);
            } else {
                String permissionSets = permissionSetAssignment.PermissionSet.Name;
                userToPermissionSetMap.put(permissionSetAssignment.AssigneeId, permissionSets);
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

        for (UserPackageLicense userPackageLicense : allUserPackageLicenses) {
            if (userToPackageLicenseMap.containsKey(userPackageLicense.UserId)) {
                String packageLicenses = userToPackageLicenseMap.get(userPackageLicense.UserId);
                packageLicenses += userPackageLicense.PackageLicense.NamespacePrefix;
                userToPackageLicenseMap.put(userPackageLicense.UserId, packageLicenses);
            } else {
                String packageLicenses = userPackageLicense.PackageLicense.NamespacePrefix;
                userToPackageLicenseMap.put(userPackageLicense.UserId, packageLicenses);
            }
        }
    }

    private void populateUserToUserLoginMap() {
        allUserLogins = [SELECT Id, UserId, IsFrozen FROM UserLogin WHERE UserId IN :userToDeprovisionIds];

        userToUserLoginMap = new Map<Id, UserLogin>();
        for (UserLogin ul : allUserLogins) {
            userToUserLoginMap.put(ul.UserId, ul);
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

    public static void updateSobjectRecords(
        String userIdField,
        List<SObject> recordListToOperate,
        Map<Id, String> userToProcessingNotes
    ) {
        List<User> usersWithErrors = new List<User>();
        Boolean updatingUser = recordListToOperate[0] instanceof User;

        Database.SaveResult[] saveResult = Database.update(recordListToOperate, false);

        for (Integer i = 0; i < saveResult.size(); i++) {
            if (!saveResult[i].isSuccess()) {
                String processingNotes;
                String errorNote = 'The following errors have occurred:';
                for (Database.Error err : saveResult[i].getErrors()) {
                    errorNote += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    errorNote += '\nUser fields that affected this error: ' + err.getFields();
                }

                Id userId = (Id) recordListToOperate[i].get(userIdField);
                if (userToProcessingNotes != null && userToProcessingNotes.get(userId) != null) {
                    processingNotes = userToProcessingNotes.get(userId) + '---\n' + errorNote;
                } else {
                    processingNotes = errorNote;
                }

                if (
                    updatingUser &&
                    errorNote.contains('FIELD_INTEGRITY_EXCEPTION: This user is a delegated administrator')
                ) {
                    processingNotes += '\n---\nPlease remove this user from being a delegated administrator before deprovisioning.';
                }

                usersWithErrors.add(
                    new User(Id = userId, Processing_Notes__c = processingNotes, Deprovision_User__c = false)
                );

                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertIdToJSON('userId', userId));
                if (saveResult[i] != null) {
                    vars.add(ErrorLogger.convertIdToJSON('saveResult[i].getId()', saveResult[i].getId()));
                }
                if (saveResult[i].getId() != null) {
                    vars.add(
                        ErrorLogger.convertStringToJSON(
                            'saveResult[i].getId().getSObjectType()',
                            '' + saveResult[i].getId().getSObjectType()
                        )
                    );
                }
                vars.add(ErrorLogger.convertStringToJSON('processingNotes', processingNotes));

                DatabaseErrorException dbException = new DatabaseErrorException(errorNote);
                ErrorLogger.logFuture(
                    dbException.getTypeName(),
                    dbException.getMessage(),
                    dbException.getStackTraceString(),
                    vars,
                    debug
                );
            }
        }

        if (usersWithErrors.size() > 0) {
            update usersWithErrors;
        }
    }

    public static void deleteSobjectRecords(
        String userIdField,
        List<SObject> recordListToOperate,
        Map<Id, String> userToProcessingNotes
    ) {
        List<User> usersWithErrors = new List<User>();

        Database.DeleteResult[] deleteResult = Database.delete(recordListToOperate, false);

        for (Integer i = 0; i < deleteResult.size(); i++) {
            if (!deleteResult[i].isSuccess()) {
                String processingNotes;
                String errorNote = 'The following errors have occurred:';
                for (Database.Error err : deleteResult[i].getErrors()) {
                    errorNote += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    errorNote += '\nUser fields that affected this error: ' + err.getFields();
                }

                Id userId = (Id) recordListToOperate[i].get(userIdField);
                if (userToProcessingNotes != null && userToProcessingNotes.get(userId) != null) {
                    processingNotes = userToProcessingNotes.get(userId) + '\n---\n' + errorNote;
                } else {
                    processingNotes = errorNote;
                }

                usersWithErrors.add(
                    new User(Id = userId, Processing_Notes__c = processingNotes, Deprovision_User__c = false)
                );

                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertIdToJSON('userId', userId));
                if (deleteResult[i] != null) {
                    vars.add(ErrorLogger.convertIdToJSON('deleteResult[i].getId()', deleteResult[i].getId()));
                }
                if (deleteResult[i].getId() != null) {
                    vars.add(
                        ErrorLogger.convertStringToJSON(
                            'deleteResult[i].getId().getSObjectType()',
                            '' + deleteResult[i].getId().getSObjectType()
                        )
                    );
                }
                vars.add(ErrorLogger.convertStringToJSON('processingNotes', processingNotes));

                DatabaseErrorException dbException = new DatabaseErrorException(errorNote);
                ErrorLogger.logFuture(
                    dbException.getTypeName(),
                    dbException.getMessage(),
                    dbException.getStackTraceString(),
                    vars,
                    debug
                );
            }
        }

        if (usersWithErrors.size() > 0) {
            update usersWithErrors;
        }
    }

    private class DatabaseErrorException extends Exception {
    }
}
