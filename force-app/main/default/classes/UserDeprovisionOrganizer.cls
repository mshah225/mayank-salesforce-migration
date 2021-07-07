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
    private Map<Id, List<GroupMember>> userToGroupMembershipMap;
    private Map<Id, List<CollaborationGroupMember>> userToChatterGroupMembershipMap;
    private Map<Id, List<PermissionSetAssignment>> userToPermissionSetMap;
    private Map<Id, List<UserPackageLicense>> userToPackageLicenseMap;
    private Map<Id, String> userToProcessingNotesMap;
    private Map<Id, String> fieldIdToNameMap;

    private static Boolean debug = false;
    private static Boolean allowRepeatCases = true;

    public UserDeprovisionOrganizer(Map<Id, User> oldUsersMap, List<User> newUsers) {
        this.newUsers = newUsers;
        this.oldUsersMap = oldUsersMap;
        this.deprovisionUserConfiguration = Deprovision_User_Configuration__c.getAll();

        this.userToDeprovisionIds = new List<Id>();
        this.userDeprovisionersList = new List<UserDeprovisioner>();

        this.userToCaseMap = new Map<Id, List<Case>>();
        this.userToUserLoginMap = new Map<Id, UserLogin>();
        this.userToGroupMembershipMap = new Map<Id, List<GroupMember>>();
        this.userToChatterGroupMembershipMap = new Map<Id, List<CollaborationGroupMember>>();
        this.userToPermissionSetMap = new Map<Id, List<PermissionSetAssignment>>();
        this.userToPackageLicenseMap = new Map<Id, List<UserPackageLicense>>();
        this.userToProcessingNotesMap = new Map<Id, String>();
        this.fieldIdToNameMap = new Map<Id, String>();

        // Make list of user's that need deprovisioning
        for (User userToDeprovision : newUsers) {
            if (userToDeprovision.Deprovision_User__c && !oldUsersMap.get(userToDeprovision.Id).Deprovision_User__c) {
                userToDeprovisionIds.add(userToDeprovision.Id);
                userDeprovisionersList.add(new UserDeprovisioner(deprovisionUserConfiguration, userToDeprovision));
            }
        }

        if (!userDeprovisionersList.isEmpty()) {
            populateUserToDeprovisionCaseMap();
            populateUserToDeprovisionGroupMembershipMap();
            populateUserToDeprovisionChatterGroupMembershipMap();
            populateUserToDeprovisionPermissionSetMap();
            populateUserToDeprovisionPackageLicenseMap();
            populateUserToUserLoginMap();
            populateFieldIdToNameMap();
        }
    }

    public void deprovisionUsersAfterUpdate() {
        if (!userDeprovisionersList.isEmpty()) {
            List<User> toUpdateUsers = new List<User>();
            List<Case> toUpdateUserCases = new List<Case>();
            List<UserLogin> toUpdateUserLogins = new List<UserLogin>();
            List<GroupMember> toDeletePublicGroupMemberships = new List<GroupMember>();
            List<CollaborationGroupMember> toDeleteChatterGroupMemberships = new List<CollaborationGroupMember>();
            List<PermissionSetAssignment> toDeletePermissionSetAssignments = new List<PermissionSetAssignment>();
            List<UserPackageLicense> toDeleteUserPackageLicense = new List<UserPackageLicense>();

            for (UserDeprovisioner userDeprovisioner : userDeprovisionersList) {
                // Setup deprovision
                Id userId = userDeprovisioner.getUserToDeprovision().Id;
                userDeprovisioner.setCases(userToCaseMap.get(userId));
                userDeprovisioner.setGroupMemberships(userToGroupMembershipMap.get(userId));
                userDeprovisioner.setChatterGroupMemberships(userToChatterGroupMembershipMap.get(userId));
                userDeprovisioner.setPermissionSetAssignments(userToPermissionSetMap.get(userId));
                userDeprovisioner.setUserPackageLicenses(userToPackageLicenseMap.get(userId));
                userDeprovisioner.setUserLogin(userToUserLoginMap.get(userId));
                userDeprovisioner.setFieldIdToNameMap(fieldIdToNameMap);
                // Deprovision
                userDeprovisioner.deprovisionUser();
                // Get all updated and deleted data
                toUpdateUserCases.addAll(userDeprovisioner.getToUpdateUserCases());
                UserLogin needToUpdateUserLogin = userDeprovisioner.getToUpdateUserLogin();
                if (needToUpdateUserLogin != null) {
                    toUpdateUserLogins.add(needToUpdateUserLogin);
                }
                toDeletePublicGroupMemberships.addAll(userDeprovisioner.getToDeleteGroupMemberships());
                toDeleteChatterGroupMemberships.addAll(userDeprovisioner.getToDeleteChatterGroupMemberships());
                toDeletePermissionSetAssignments.addAll(userDeprovisioner.getToDeletePermissionSetAssignments());
                toDeleteUserPackageLicense.addAll(userDeprovisioner.getToDeleteUserPackageLicenses());

                User userWithProcessingNotes = userDeprovisioner.getDeprovisionedUserWithProcessingNotes();
                toUpdateUsers.add(userWithProcessingNotes);
                userToProcessingNotesMap.put(userId, userWithProcessingNotes.Processing_Notes__c);
            }

            if (!toDeletePublicGroupMemberships.isEmpty()) {
                deleteSobjectRecords('UserOrGroupId', toDeletePublicGroupMemberships, userToProcessingNotesMap);
            }

            if (!toDeletePermissionSetAssignments.isEmpty()) {
                deleteSobjectRecords('AssigneeId', toDeletePermissionSetAssignments, userToProcessingNotesMap);
            }

            if (!toDeleteUserPackageLicense.isEmpty()) {
                deleteSobjectRecords('UserId', toDeleteUserPackageLicense, userToProcessingNotesMap);
            }

            if (!toUpdateUsers.isEmpty()) {
                updateSobjectRecords('Id', toUpdateUsers, userToProcessingNotesMap);
            }

            // And handle all non-setup objects here
            if (
                !toUpdateUserCases.isEmpty() ||
                !toDeleteChatterGroupMemberships.isEmpty() ||
                !toUpdateUserLogins.isEmpty()
            ) {
                UserDeprovisionQueue userDeprovisionQueue = new UserDeprovisionQueue();
                userDeprovisionQueue.setUpdatedUserCases(toUpdateUserCases);
                userDeprovisionQueue.setAllUserChatterGroupMemberships(toDeleteChatterGroupMemberships);
                userDeprovisionQueue.setUpdatedUserLogins(toUpdateUserLogins);

                userDeprovisionQueue.setUserToProcessingNotesMap(userToProcessingNotesMap);
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
            if (!userToCaseMap.containsKey(userCase.OwnerId)) {
                userToCaseMap.put(userCase.OwnerId, new List<Case>());
            }
            userToCaseMap.get(userCase.OwnerId).add(userCase);
        }
    }

    private void populateUserToDeprovisionGroupMembershipMap() {
        allUserPublicGroupMemberships = [
            SELECT UserOrGroupId, Group.Name
            FROM GroupMember
            WHERE UserOrGroupId IN :userToDeprovisionIds
        ];

        for (GroupMember groupMember : allUserPublicGroupMemberships) {
            if (!userToGroupMembershipMap.containsKey(groupMember.UserOrGroupId)) {
                userToGroupMembershipMap.put(groupMember.UserOrGroupId, new List<GroupMember>());
            }
            userToGroupMembershipMap.get(groupMember.UserOrGroupId).add(groupMember);
        }
    }

    private void populateUserToDeprovisionChatterGroupMembershipMap() {
        allUserChatterGroupMemberships = [
            SELECT MemberId, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE MemberId IN :userToDeprovisionIds AND NetworkId = ''
        ];

        for (CollaborationGroupMember collaborationGroupMember : allUserChatterGroupMemberships) {
            if (!userToChatterGroupMembershipMap.containsKey(collaborationGroupMember.MemberId)) {
                userToChatterGroupMembershipMap.put(
                    collaborationGroupMember.MemberId,
                    new List<CollaborationGroupMember>()
                );
            }
            userToChatterGroupMembershipMap.get(collaborationGroupMember.MemberId).add(collaborationGroupMember);
        }
    }

    private void populateUserToDeprovisionPermissionSetMap() {
        allUserPermissionSetAssignments = [
            SELECT AssigneeId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userToDeprovisionIds AND PermissionSet.IsOwnedByProfile = FALSE
        ];

        for (PermissionSetAssignment permissionSetAssignment : allUserPermissionSetAssignments) {
            if (!userToPermissionSetMap.containsKey(permissionSetAssignment.AssigneeId)) {
                userToPermissionSetMap.put(permissionSetAssignment.AssigneeId, new List<PermissionSetAssignment>());
            }
            userToPermissionSetMap.get(permissionSetAssignment.AssigneeId).add(permissionSetAssignment);
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
            if (!userToPackageLicenseMap.containsKey(userPackageLicense.UserId)) {
                userToPackageLicenseMap.put(userPackageLicense.UserId, new List<UserPackageLicense>());
            }
            userToPackageLicenseMap.get(userPackageLicense.UserId).add(userPackageLicense);
        }
    }

    private void populateUserToUserLoginMap() {
        allUserLogins = [SELECT Id, UserId, IsFrozen FROM UserLogin WHERE UserId IN :userToDeprovisionIds];

        userToUserLoginMap = new Map<Id, UserLogin>();
        for (UserLogin ul : allUserLogins) {
            userToUserLoginMap.put(ul.UserId, ul);
        }
    }

    private void populateFieldIdToNameMap() {
        Set<Id> profileIds = new Set<Id>();
        Set<Id> userRoleIds = new Set<Id>();
        for (UserDeprovisioner toDepro : userDeprovisionersList) {
            User toDeproUser = toDepro.getUserToDeprovision();
            if ((toDeproUser.get('ProfileId')) != null) {
                profileIds.add(Id.valueOf((String) (toDeproUser.get('ProfileId'))));
            }
            if ((toDeproUser.get('UserRoleId')) != null) {
                userRoleIds.add(Id.valueOf((String) (toDeproUser.get('UserRoleId'))));
            }
        }

        for (UserRole ur : [SELECT Id, Name FROM UserRole WHERE Id IN :userRoleIds]) {
            fieldIdToNameMap.put(ur.Id, ur.Name);
        }

        for (Profile pro : [SELECT Id, Name FROM Profile WHERE Id IN :profileIds]) {
            fieldIdToNameMap.put(pro.Id, pro.Name);
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
        Map<Id, String> usersWithErrors = new Map<Id, String>();

        Database.SaveResult[] saveResult = Database.update(recordListToOperate, false);

        for (Integer i = 0; i < saveResult.size(); i++) {
            if (!saveResult[i].isSuccess()) {
                String processingNotes = '';
                String errorNote = 'The following errors have occurred:';
                for (Database.Error err : saveResult[i].getErrors()) {
                    errorNote += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    errorNote += '\nUser fields that affected this error: ' + err.getFields();
                }

                Id userId = (Id) recordListToOperate[i].get(userIdField);

                errorNote +=
                    'Failed Update: Error while updating the ' +
                    String.valueOf(recordListToOperate[0]).split(':')[0] +
                    ' objects.';

                // Append to exisiting processing notes / other errors for this user
                if (usersWithErrors.keySet().contains(userId)) {
                    processingNotes = usersWithErrors.get(userId) + '---\n';
                } else if (userToProcessingNotes != null && userToProcessingNotes.get(userId) != null) {
                    processingNotes = userToProcessingNotes.get(userId) + '---\n';
                }
                processingNotes += errorNote + '\n';

                usersWithErrors.put(userId, processingNotes);

                // Error log it
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
                try {
                    ErrorLogger.log(dbException, vars, debug, allowRepeatCases);
                } catch (System.DmlException dmle) {
                    if (dmle.getMessage().contains('MIXED_DML_OPERATION')) {
                        ErrorLogger.ErrorLoggerQueue logQueue = new ErrorLogger.ErrorLoggerQueue(
                            dbException,
                            vars,
                            debug,
                            allowRepeatCases
                        );
                        System.enqueueJob(logQueue);
                    } else {
                        throw dmle;
                    }
                }
            }
        }

        if (!usersWithErrors.isEmpty()) {
            updateUsersProcessingNotes(usersWithErrors);
        }
    }

    public static void deleteSobjectRecords(
        String userIdField,
        List<SObject> recordListToOperate,
        Map<Id, String> userToProcessingNotes
    ) {
        Map<Id, String> usersWithErrors = new Map<Id, String>();

        Database.DeleteResult[] deleteResult = Database.delete(recordListToOperate, false);

        for (Integer i = 0; i < deleteResult.size(); i++) {
            if (!deleteResult[i].isSuccess()) {
                String processingNotes = '';
                String errorNote = 'The following errors have occurred:';
                for (Database.Error err : deleteResult[i].getErrors()) {
                    errorNote += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    errorNote += '\nUser fields that affected this error: ' + err.getFields();
                }

                Id userId = (Id) recordListToOperate[i].get(userIdField);

                errorNote +=
                    'Failed Deletion: Error while updating the ' +
                    String.valueOf(recordListToOperate[0]).split(':')[0] +
                    ' objects.';

                // Append to exisiting processing notes / other errors for this user
                if (usersWithErrors.keySet().contains(userId)) {
                    processingNotes = usersWithErrors.get(userId) + '---\n';
                } else if (userToProcessingNotes != null && userToProcessingNotes.get(userId) != null) {
                    processingNotes = userToProcessingNotes.get(userId) + '---\n';
                }
                processingNotes += errorNote + '\n';

                // Error log it
                usersWithErrors.put(userId, processingNotes);
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
                try {
                    ErrorLogger.log(dbException, vars, debug, allowRepeatCases);
                } catch (System.DmlException dmle) {
                    if (dmle.getMessage().contains('MIXED_DML_OPERATION')) {
                        ErrorLogger.ErrorLoggerQueue logQueue = new ErrorLogger.ErrorLoggerQueue(
                            dbException,
                            vars,
                            debug,
                            allowRepeatCases
                        );
                        System.enqueueJob(logQueue);
                    } else {
                        throw dmle;
                    }
                }
            }
        }

        if (!usersWithErrors.isEmpty()) {
            updateUsersProcessingNotes(usersWithErrors);
        }
    }

    @future
    public static void updateUsersProcessingNotes(Map<Id, String> uidToNewNotesMap) {
        List<User> users = new List<User>();
        for (Id uid : uidToNewNotesMap.keySet()) {
            users.add(new User(Id = uid, Processing_Notes__c = uidToNewNotesMap.get(uid), Deprovision_User__c = false));
        }
        update users;
    }

    private class DatabaseErrorException extends Exception {
    }
}
