/**
 * The `UserDeprovisionOrganizer` is primarily used to launch the user deprovisioning process and to provide several common
 * utilities to each stage of the deprovisioner.
 *
 * It creates the initial `UserDeprovisioner` objects, updates the users as needed, and then launches the first of several stages.
 * The main stages are:
 * 1. Document all changes on user and modify User fields
 * 2. Update most non-setup objects
 * 3. Setup setup objects
 * 4. Reassign cases
 *
 * At each stage it is wide to re-get the objects about to be updated and re-run them through the `UserDeprovisioner` objects, since
 * each stage runs asynchronously and the records could change from one stage to another.
 */
public without sharing class UserDeprovisionOrganizer {
    private static Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration {
        get {
            if (deprovisionUserConfiguration == null) {
                deprovisionUserConfiguration = Deprovision_User_Configuration__c.getAll();
            }
            return deprovisionUserConfiguration;
        }
        set;
    }

    @TestVisible
    private static Map<String, Deprovision_User_Campaign_Reassignment__mdt> deprovisionUserReassignmentMetadata {
        get {
            if (deprovisionUserReassignmentMetadata == null) {
                deprovisionUserReassignmentMetadata = Deprovision_User_Campaign_Reassignment__mdt.getAll();
            }
            return deprovisionUserReassignmentMetadata;
        }
        set;
    }

    public static Boolean isDeprovisoning = false;

    /**
     * This is the primary interface for launching with the user deporvisioner.
     * This should be called from the user trigger in a after-update context.
     *
     * @param newList Trigger.new of updated Users
     * @param oldMap Trigger.oldMap of updated Users
     */
    public static void handleDeprovisioning(List<User> newList, Map<Id, User> oldMap) {
        try {
            Map<Id, User> usersToDeprovision = new Map<Id, User>();

            for (User newUser : newList) {
                // If Deprovision_User__c is now true and previously was false
                if (newUser.Deprovision_User__c && !oldMap.get(newUser.Id).Deprovision_User__c) {
                    usersToDeprovision.put(newUser.Id, newUser);
                }
            }

            // Quit early if no users need to be deprovisioned
            if (usersToDeprovision.isEmpty())
                return;

            // Get list of all records for these users
            List<Id> potentialDeprovisionUserIds = new List<Id>(usersToDeprovision.keySet());
            Map<Id, List<GroupMember>> groupMembershipPerUser = getGroupMemberships(potentialDeprovisionUserIds);
            Map<Id, List<PermissionSetAssignment>> psasPerUser = getPermissionSetAssignments(
                potentialDeprovisionUserIds
            );
            Map<Id, List<UserPackageLicense>> uplsPerUser = getUserPackageLicenses(potentialDeprovisionUserIds);
            Map<Id, List<CronTrigger>> cronJobsPerUser = getCronJobs(potentialDeprovisionUserIds);
            Map<Id, List<CollaborationGroupMember>> chatterGroupsPerUser = getChatterGroupMembership(
                potentialDeprovisionUserIds
            );
            Map<Id, UserLogin> userLoginPerUser = getUserLogins(potentialDeprovisionUserIds);
            Map<Id, List<smagicinteract__SenderId_Profile_Map__c>> smsSenderIdAssignmentsPerUser = getSMSMagicSenderIdsAssignments(
                potentialDeprovisionUserIds
            );
            Map<Id, List<smagicinteract__Sender_Visibility__c>> smsSenderVisbilitiesPerUser = getSMSMagicSenderVisbilities(
                potentialDeprovisionUserIds
            );
            Map<Id, List<smagicinteract__License__c>> smsMagicLicensesPerUser = getSMSMagicLicenses(
                potentialDeprovisionUserIds
            );
            Map<Id, List<Campaign>> campaignsPerUser = getCampaigns(potentialDeprovisionUserIds);

            List<UserDeprovisioner> userDeprovisioners = new List<UserDeprovisioner>();
            List<User> updatedUsers = new List<User>();

            for (User deproUser : usersToDeprovision.values()) {
                Id userId = deproUser.Id;
                UserDeprovisioner userDeprovisioner = new UserDeprovisioner(
                    deproUser,
                    deprovisionUserConfiguration,
                    deprovisionUserReassignmentMetadata
                );
                userDeprovisioner.setGroupMemberships(groupMembershipPerUser.get(userId));
                userDeprovisioner.setPermissionSetAssignments(psasPerUser.get(userId));
                userDeprovisioner.setUserPackageLicenses(uplsPerUser.get(userId));
                userDeprovisioner.setCronJobs(cronJobsPerUser.get(userId));
                userDeprovisioner.setChatterGroupMemberships(chatterGroupsPerUser.get(userId));
                userDeprovisioner.setUserLogin(userLoginPerUser.get(userId));
                userDeprovisioner.setSmsSenderIdAssignments(smsSenderIdAssignmentsPerUser.get(userId));
                userDeprovisioner.setSmsSenderVisibilities(smsSenderVisbilitiesPerUser.get(userId));
                userDeprovisioner.setSmsLicenses(smsMagicLicensesPerUser.get(userId));
                userDeprovisioner.setCampaigns(campaignsPerUser.get(userId));

                // Figure out what we need to do for each user and mark it on the user
                // If user is meant to deprovision enqueue for further actions
                Boolean doDeprovision = userDeprovisioner.deprovisionUser();
                updatedUsers.add(userDeprovisioner.getUser());
                if (doDeprovision)
                    userDeprovisioners.add(userDeprovisioner);
            }

            // Deprovisioning will require us to update the user record
            GovernorLimitPreemptException.assertCanDML(
                updatedUsers.size(),
                'Could not deprovision users - too close to DML limit'
            );
            update updatedUsers;

            // Now enqueue a job to do the real work
            GovernorLimitPreemptException.assertCanEnqueueJobs(
                1,
                'Could not enqueue stage 2 of user deprovisioning - reached queueable limit'
            );

            // Need to set this large enough for all stages of deprovisioning (including error logging queues)
            // we need to explicitly set this or the limit will be too low in our test class
            AsyncOptions asyncOptions = new AsyncOptions();
            asyncOptions.maximumQueueableStackDepth = 20;

            System.enqueueJob(new UserDeprovisionerQueueNonSetupRecords(userDeprovisioners), asyncOptions);
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertSetToJSON('userIds', new Map<Id, User>(newList).keySet()));
            ErrorLogger.log(ex, vars, false);
        }
    }

    /** Get a list of all groups each user is a member of */
    public static Map<Id, List<GroupMember>> getGroupMemberships(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query group memberships for deprovisioning - reached SOQL governor limit'
        );

        List<GroupMember> allUserPublicGroupMemberships = [
            SELECT UserOrGroupId, Group.Name
            FROM GroupMember
            WHERE UserOrGroupId IN :userIds
        ];

        Map<Id, List<GroupMember>> userIdToGroupMemberships = new Map<Id, List<GroupMember>>();

        for (Id uId : userIds)
            userIdToGroupMemberships.put(uId, new List<GroupMember>());

        for (GroupMember groupMember : allUserPublicGroupMemberships)
            userIdToGroupMemberships.get(groupMember.UserOrGroupId).add(groupMember);

        return userIdToGroupMemberships;
    }

    /** Get a list of all permission set assignments each user has */
    public static Map<Id, List<PermissionSetAssignment>> getPermissionSetAssignments(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query permission set assignments for deprovisioning - reached SOQL governor limit'
        );

        List<PermissionSetAssignment> allUserPermissionSetAssignments = [
            SELECT AssigneeId, PermissionSetId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId IN :userIds AND PermissionSet.IsOwnedByProfile = FALSE
        ];

        Map<Id, List<PermissionSetAssignment>> userToPermissionSetAssignments = new Map<Id, List<PermissionSetAssignment>>();

        for (Id uId : userIds)
            userToPermissionSetAssignments.put(uId, new List<PermissionSetAssignment>());

        for (PermissionSetAssignment psa : allUserPermissionSetAssignments)
            userToPermissionSetAssignments.get(psa.AssigneeId).add(psa);

        return userToPermissionSetAssignments;
    }

    /** Get a list of all user package licenses for each user */
    public static Map<Id, List<UserPackageLicense>> getUserPackageLicenses(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query user package licenses for deprovisioning - reached SOQL governor limit'
        );

        // Get which to remove based on custom setting
        List<Id> packageLicenseIds = new List<Id>();
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('RemovePackageLicense')) {
                packageLicenseIds.add(Id.valueOf(deprovisionUserConfiguration.get(deprovisionConfigurationName).Id__c));
            }
        }

        // Get records and map to each user
        List<UserPackageLicense> allUserPackageLicenses = [
            SELECT UserId, PackageLicense.NamespacePrefix
            FROM UserPackageLicense
            WHERE UserId IN :userIds AND PackageLicenseId IN :packageLicenseIds
        ];

        Map<Id, List<UserPackageLicense>> userToPackageLicenses = new Map<Id, List<UserPackageLicense>>();

        for (Id uId : userIds)
            userToPackageLicenses.put(uId, new List<UserPackageLicense>());

        for (UserPackageLicense upl : allUserPackageLicenses)
            userToPackageLicenses.get(upl.UserId).add(upl);

        return userToPackageLicenses;
    }

    /** Get a list of all cron jobs for each user */
    public static Map<Id, List<CronTrigger>> getCronJobs(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query cron jobs for deprovisioning - reached SOQL governor limit'
        );

        List<CronTrigger> allCronJobs = [
            SELECT Id, CronJobDetail.Name, CronJobDetail.JobType, OwnerId
            FROM CronTrigger
            WHERE OwnerId IN :userIds
        ];

        Map<Id, List<CronTrigger>> userToCronJobs = new Map<Id, List<CronTrigger>>();

        for (Id uId : userIds)
            userToCronJobs.put(uId, new List<CronTrigger>());

        for (CronTrigger upl : allCronJobs)
            userToCronJobs.get(upl.OwnerId).add(upl);

        return userToCronJobs;
    }

    /** Get a list of all chatter groups for each user */
    public static Map<Id, List<CollaborationGroupMember>> getChatterGroupMembership(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query chatter group memberships for deprovisioning - reached SOQL governor limit'
        );

        List<CollaborationGroupMember> allUserChatterGroupMemberships = [
            SELECT MemberId, CollaborationGroup.Name
            FROM CollaborationGroupMember
            WHERE MemberId IN :userIds AND NetworkId = ''
        ];

        Map<Id, List<CollaborationGroupMember>> userToChatterGroupMembers = new Map<Id, List<CollaborationGroupMember>>();

        for (Id uId : userIds)
            userToChatterGroupMembers.put(uId, new List<CollaborationGroupMember>());

        for (CollaborationGroupMember cgm : allUserChatterGroupMemberships)
            userToChatterGroupMembers.get(cgm.MemberId).add(cgm);

        return userToChatterGroupMembers;
    }

    /** Get a list of all user logins for each user */
    public static Map<Id, UserLogin> getUserLogins(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query user logins for deprovisioning - reached SOQL governor limit'
        );

        List<UserLogin> allUserLogins = [
            SELECT Id, UserId, IsFrozen
            FROM UserLogin
            WHERE UserId IN :userIds
        ];

        Map<Id, UserLogin> userToUserLogin = new Map<Id, UserLogin>();

        for (UserLogin cgm : allUserLogins)
            userToUserLogin.put(cgm.UserId, cgm);

        return userToUserLogin;
    }

    /** Get a list of all SMS Magic Sender Ids Assignments for each user */
    public static Map<Id, List<smagicinteract__SenderId_Profile_Map__c>> getSMSMagicSenderIdsAssignments(
        List<Id> userIds
    ) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query SMS Magic Sender Id Assignments for deprovisioning - reached SOQL governor limit'
        );

        List<smagicinteract__SenderId_Profile_Map__c> allSmsProfileIdAssignments = [
            SELECT
                Id,
                smagicinteract__User__c,
                smagicinteract__senderid_lookup__c,
                smagicinteract__senderid_lookup__r.Id,
                smagicinteract__senderid_lookup__r.smagicinteract__label__c,
                smagicinteract__senderid_lookup__r.smagicinteract__senderId__c
            FROM smagicinteract__SenderId_Profile_Map__c
            WHERE smagicinteract__User__c IN :userIds
        ];

        Map<Id, List<smagicinteract__SenderId_Profile_Map__c>> userToSenderIdAssignments = new Map<Id, List<smagicinteract__SenderId_Profile_Map__c>>();

        for (Id uId : userIds)
            userToSenderIdAssignments.put(uId, new List<smagicinteract__SenderId_Profile_Map__c>());

        for (smagicinteract__SenderId_Profile_Map__c smsProfileIdAssignment : allSmsProfileIdAssignments)
            userToSenderIdAssignments.get(smsProfileIdAssignment.smagicinteract__User__c).add(smsProfileIdAssignment);

        return userToSenderIdAssignments;
    }

    /** Get a list of all SMS Magic Sender Visbilities for each user */
    public static Map<Id, List<smagicinteract__Sender_Visibility__c>> getSMSMagicSenderVisbilities(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query SMS Sender Visibilities for deprovisioning - reached SOQL governor limit'
        );

        List<smagicinteract__Sender_Visibility__c> allSenderVisibilities = [
            SELECT Id, smagicinteract__User__c
            FROM smagicinteract__Sender_Visibility__c
            WHERE smagicinteract__User__c IN :userIds
        ];

        Map<Id, List<smagicinteract__Sender_Visibility__c>> userToSenderVisibilities = new Map<Id, List<smagicinteract__Sender_Visibility__c>>();

        for (Id uId : userIds)
            userToSenderVisibilities.put(uId, new List<smagicinteract__Sender_Visibility__c>());

        for (smagicinteract__Sender_Visibility__c senderVisibility : allSenderVisibilities)
            userToSenderVisibilities.get(senderVisibility.smagicinteract__User__c).add(senderVisibility);

        return userToSenderVisibilities;
    }

    /** Get a list of all SMS License Assignments for each user */
    public static Map<Id, List<smagicinteract__License__c>> getSMSMagicLicenses(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query SMS Magic licenses for deprovisioning - reached SOQL governor limit'
        );

        List<smagicinteract__License__c> allSmsLicenses = [
            SELECT Id, smagicinteract__User__c
            FROM smagicinteract__License__c
            WHERE smagicinteract__User__c IN :userIds
        ];

        Map<Id, List<smagicinteract__License__c>> userToLicenses = new Map<Id, List<smagicinteract__License__c>>();

        for (Id uId : userIds)
            userToLicenses.put(uId, new List<smagicinteract__License__c>());

        for (smagicinteract__License__c smsLicense : allSmsLicenses)
            userToLicenses.get(smsLicense.smagicinteract__User__c).add(smsLicense);

        return userToLicenses;
    }

    /** Get a list of all campaigns for each user */
    public static Map<Id, List<Campaign>> getCampaigns(List<Id> userIds) {
        GovernorLimitPreemptException.assertCanQueryN(
            1,
            'Could not query campaigns for deprovisioning - reached SOQL governor limit'
        );

        // Get records and map to each user
        List<Campaign> allCampaigns = [
            SELECT Id, OwnerId
            FROM Campaign
            WHERE OwnerId IN :userIds
        ];

        Map<Id, List<Campaign>> userToCampaigns = new Map<Id, List<Campaign>>();

        for (Id uId : userIds)
            userToCampaigns.put(uId, new List<Campaign>());

        for (Campaign cam : allCampaigns)
            userToCampaigns.get(cam.OwnerId).add(cam);

        return userToCampaigns;
    }

    /**
     * Update a list of SObjects related to users
     *
     * @param userIdField Name of the field which maps this object back to the corresponding user
     * @param recordList List of records to update
     * @return ResultWrapper describing any errors or processing notes to add to corresponding users
     */
    public static ResultWrapper updateSobjectRecords(String userIdField, List<SObject> recordList) {
        // Update the records
        Database.SaveResult[] saveResults = Database.update(recordList, false);

        // Response details
        Map<Id, List<String>> userIdToProcessingNotes = new Map<Id, List<String>>();
        List<String> errorLoggerVars = new List<String>();

        // Error prefix and whether there are any errors at all?
        Boolean thereWasAnError = false;
        String errorPrefix =
            'Error while updating the ' +
            recordList.getSObjectType() +
            ' objects during user deprovisioning';

        // Collect error details on a per-user and in-total basis
        for (Integer i = 0; i < saveResults.size(); i++) {
            SObject updatedRecord = recordList[i];
            Database.SaveResult saveResult = saveResults[i];
            Id userId = (Id) updatedRecord.get(userIdField);

            // Build description about this record update
            Map<String, String> resultDescription = new Map<String, String>();
            resultDescription.put('recordId', updatedRecord.Id);
            resultDescription.put(userIdField, userId);

            if (saveResult.isSuccess()) {
                resultDescription.put('Status', 'Successful');
            } else {
                thereWasAnError = true;
                resultDescription.put('Status', 'Failure');

                // Collect all errors for this record
                List<Map<String, String>> errorDetails = new List<Map<String, String>>();
                for (Database.Error err : saveResult.getErrors()) {
                    errorDetails.add(
                        new Map<String, String>{
                            'statusCode' => err.getStatusCode().toString(),
                            'message' => err.getMessage(),
                            'fields' => err.getFields().toString()
                        }
                    );
                }
                resultDescription.put('Errors', JSON.serialize(errorDetails));

                // Add description to the user notes
                if (!userIdToProcessingNotes.containsKey(userId))
                    userIdToProcessingNotes.put(userId, new List<String>());
                userIdToProcessingNotes.get(userId).add(errorPrefix + '\n' + JSON.serialize(resultDescription));
            }

            // Add description to error logger
            errorLoggerVars.add(ErrorLogger.convertMapToJSON('saveResults[' + i + ']', resultDescription));
        }

        // Flatten processing notes for each user
        Map<Id, String> userIdToProcessingNotesSimplified = new Map<Id, String>();
        for (Id userId : userIdToProcessingNotes.keySet()) {
            userIdToProcessingNotesSimplified.put(userId, String.join(userIdToProcessingNotes.get(userId), '\n'));
        }

        return new ResultWrapper(
            thereWasAnError ? new DatabaseErrorException(errorPrefix) : null,
            userIdToProcessingNotesSimplified,
            errorLoggerVars
        );
    }

    /**
     * Delete a list of SObjects related to users
     *
     * @param userIdField Name of the field which maps this object back to the corresponding user
     * @param recordList List of records to delete
     * @return ResultWrapper describing any errors or processing notes to add to corresponding users
     */
    public static ResultWrapper deleteSobjectRecords(String userIdField, List<SObject> recordList) {
        // Update the records
        Database.DeleteResult[] deleteResults = Database.delete(recordList, false);

        // Response details
        Map<Id, List<String>> userIdToProcessingNotes = new Map<Id, List<String>>();
        List<String> errorLoggerVars = new List<String>();

        // Error prefix and whether there are any errors at all?
        Boolean thereWasAnError = false;
        String errorPrefix =
            'Error while deleting the ' +
            recordList.getSObjectType() +
            ' objects during user deprovisioning';

        // Collect error details on a per-user and in-total basis
        for (Integer i = 0; i < deleteResults.size(); i++) {
            SObject deletedRecord = recordList[i];
            Database.DeleteResult deleteResult = deleteResults[i];
            Id userId = (Id) deletedRecord.get(userIdField);

            // Build description about this record deletion
            Map<String, String> resultDescription = new Map<String, String>();
            resultDescription.put('recordId', deletedRecord.Id);
            resultDescription.put(userIdField, userId);

            if (deleteResult.isSuccess()) {
                resultDescription.put('Status', 'Successful');
            } else {
                thereWasAnError = true;
                resultDescription.put('Status', 'Failure');

                // Collect all errors for this record
                List<Map<String, String>> errorDetails = new List<Map<String, String>>();
                for (Database.Error err : deleteResult.getErrors()) {
                    errorDetails.add(
                        new Map<String, String>{
                            'statusCode' => err.getStatusCode().toString(),
                            'message' => err.getMessage(),
                            'fields' => err.getFields().toString()
                        }
                    );
                }
                resultDescription.put('Errors', JSON.serialize(errorDetails));

                // Add description to the user notes
                if (!userIdToProcessingNotes.containsKey(userId))
                    userIdToProcessingNotes.put(userId, new List<String>());
                userIdToProcessingNotes.get(userId).add(errorPrefix + '\n' + JSON.serialize(resultDescription));
            }

            // Add description to error logger
            errorLoggerVars.add(ErrorLogger.convertMapToJSON('deleteResults[' + i + ']', resultDescription));
        }

        // Flatten processing notes for each user
        Map<Id, String> userIdToProcessingNotesSimplified = new Map<Id, String>();
        for (Id userId : userIdToProcessingNotes.keySet()) {
            userIdToProcessingNotesSimplified.put(userId, String.join(userIdToProcessingNotes.get(userId), '\n'));
        }

        return new ResultWrapper(
            thereWasAnError ? new DatabaseErrorException(errorPrefix) : null,
            userIdToProcessingNotesSimplified,
            errorLoggerVars
        );
    }

    /**
     * Abort a list of cron jobs
     *
     * @param cronJobs A list of all jobs that need to be aborted
     * @return ResultWrapper describing any errors or processing notes to add to corresponding users
     */
    public static ResultWrapper abortCronJobs(List<CronTrigger> cronJobs) {
        // Response details
        Map<Id, List<String>> userIdToProcessingNotes = new Map<Id, List<String>>();
        List<String> errorLoggerVars = new List<String>();
        Exception ex = null;

        // Abort each job and collect error details on a per-user and in-total basis
        for (Integer i = 0; i < cronJobs.size(); i++) {
            CronTrigger job = cronJobs[i];
            Id userId = job.OwnerId;

            Map<String, String> resultDescription = new Map<String, String>();
            resultDescription.put('recordId', job.Id);
            resultDescription.put('OwnerId', userId);

            try {
                System.abortJob(job.Id);
                resultDescription.put('Status', 'Successful');
            } catch (Exception e) {
                if (ex == null)
                    ex = e;

                resultDescription.put('Status', 'Failure');
                resultDescription.put('Error', e.getMessage());

                // Add description to the user notes
                if (!userIdToProcessingNotes.containsKey(userId))
                    userIdToProcessingNotes.put(userId, new List<String>());
                userIdToProcessingNotes.get(userId).add(JSON.serialize(resultDescription));
            }

            // Add description to error logger
            errorLoggerVars.add(ErrorLogger.convertMapToJSON('cronJob[' + i + ']', resultDescription));
        }

        // Flatten processing notes for each user
        Map<Id, String> userIdToProcessingNotesSimplified = new Map<Id, String>();
        for (Id userId : userIdToProcessingNotes.keySet()) {
            userIdToProcessingNotesSimplified.put(
                userId,
                'Error while aborting the cron jobs during user deprovisioning\n' +
                String.join(userIdToProcessingNotes.get(userId), '\n')
            );
        }

        return new ResultWrapper(ex, userIdToProcessingNotesSimplified, errorLoggerVars);
    }

    /**
     * Description of WHAT happened while trying to update/delete sObjects or abort cron jobs
     * This can then be used to actually apply those changes
     * `ex` is set if there was an error that needs to be error logged (the error log variables are in `vars`),
     * `userIdToProcessingNotes` is a map of each user id to any new processing notes that need to be added on that user.
     */
    public class ResultWrapper {
        /**
         * Per-user processing notes that should be appended to each user's current processing notes
         */
        public Map<Id, String> userIdToProcessingNotes;

        /**
         * Exception to use for error logger if there was any
         */
        public Exception ex;
        /**
         * Variables to use for error logger
         */
        public List<String> vars;

        public ResultWrapper(Exception ex, Map<Id, String> userIdToProcessingNotes, List<String> vars) {
            this.ex = ex;
            this.userIdToProcessingNotes = userIdToProcessingNotes;
            this.vars = vars;
        }
    }

    private class DatabaseErrorException extends Exception {
    }
}