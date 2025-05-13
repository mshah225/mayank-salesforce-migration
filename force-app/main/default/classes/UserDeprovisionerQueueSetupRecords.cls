/**
 * Update all [setup](https://developer.salesforce.com/docs/atlas.en-us.230.0.apexcode.meta/apexcode/apex_dml_non_mix_sobjects.htm) objects as part of user deprovisioning.
 *
 * We've already updated the log on the relevant user with these changes, so we need to actually do them now and log it there are errors
 *
 * This includes
 * 1. Removing group memberships (`GroupMember`).
 * 2. Removing permission set assignments (`PermissionSetAssignment`).
 * 3. Removing user package licenses (`UserPackageLicense`).
 * 4. Aborting cron jobs (`CronTrigger`).
 */
public without sharing class UserDeprovisionerQueueSetupRecords implements Queueable, Nextable {
    private List<UserDeprovisioner> userDeprovisioners;
    Set<User> updatedUsers = new Set<User>();

    public UserDeprovisionerQueueSetupRecords(List<UserDeprovisioner> userDeprovisioners) {
        this.userDeprovisioners = userDeprovisioners;
    }

    public void execute(QueueableContext context) {
        UserDeprovisionOrganizer.isDeprovisoning = true;
        try {
            refreshUserDeprovisioners();

            Map<Id, UserDeprovisioner> userDeprovisionersMp = new Map<Id, UserDeprovisioner>();
            List<GroupMember> groupMemberships = new List<GroupMember>();
            List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
            List<UserPackageLicense> upls = new List<UserPackageLicense>();
            List<CronTrigger> cronJobs = new List<CronTrigger>();

            for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
                userDeprovisionersMp.put(userDeprovisioner.getUser().Id, userDeprovisioner);

                List<GroupMember> userGroupMemberships = userDeprovisioner.getGroupMemberships();
                if (userGroupMemberships != null)
                    groupMemberships.addAll(userGroupMemberships);

                List<PermissionSetAssignment> userPsas = userDeprovisioner.getPermissionSetAssignments();
                if (userPsas != null)
                    psas.addAll(userPsas);

                List<UserPackageLicense> userUpls = userDeprovisioner.getUserPackageLicenses();
                if (userUpls != null)
                    upls.addAll(userUpls);

                List<CronTrigger> userCronJobs = userDeprovisioner.getCronJobs();
                if (userCronJobs != null)
                    cronJobs.addAll(userCronJobs);
            }

            // Remove group memberships and error log if any failures - to do this we build
            if (!groupMemberships.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.deleteSobjectRecords(
                    'UserOrGroupId',
                    groupMemberships
                );
                handleResponse(resultWrapper);
            }

            // Remove permission set assignments and error log if any failures
            if (!psas.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.deleteSobjectRecords(
                    'AssigneeId',
                    psas
                );
                handleResponse(resultWrapper);
            }

            // Remove group memberships and error log if any failures
            if (!upls.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.deleteSobjectRecords(
                    'UserId',
                    upls
                );
                handleResponse(resultWrapper);
            }

            // Remove group memberships and error log if any failures
            if (!cronJobs.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.abortCronJobs(cronJobs);
                handleResponse(resultWrapper);
            }

            // Lastly update users
            if (!updatedUsers.isEmpty()) {
                update new List<User>(updatedUsers);
            }

            enqueueNext(new UserDeprovisionCaseTransferBatch(userDeprovisioners));
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            List<Id> userIds = new List<Id>();
            for (UserDeprovisioner userDeprovisioner : userDeprovisioners)
                userIds.add(userDeprovisioner.getUser().Id);
            vars.add(ErrorLogger.convertListToJSON('userIds', userIds));

            enqueueNext(new ErrorLogger.ErrorLoggerQueue(ex, vars, false));
        }
        launchNext();
        UserDeprovisionOrganizer.isDeprovisoning = false;
    }

    /**
     * Refresh records in the UserDeprovisioner objects (just in case they changed between when
     * these objects were created and when this asynchronously runs)
     */
    private void refreshUserDeprovisioners() {
        List<Id> userIds = new List<Id>();

        for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
            userIds.add(userDeprovisioner.getUser().Id);
        }

        // Get refreshed data
        Map<Id, List<GroupMember>> groupMembershipPerUser = UserDeprovisionOrganizer.getGroupMemberships(userIds);
        Map<Id, List<PermissionSetAssignment>> psasPerUser = UserDeprovisionOrganizer.getPermissionSetAssignments(
            userIds
        );
        Map<Id, List<UserPackageLicense>> uplsPerUser = UserDeprovisionOrganizer.getUserPackageLicenses(userIds);
        Map<Id, List<CronTrigger>> cronJobsPerUser = UserDeprovisionOrganizer.getCronJobs(userIds);

        // Refresh details in user deprovisioners
        for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
            Id userId = userDeprovisioner.getUser().Id;
            if (groupMembershipPerUser.containsKey(userId))
                userDeprovisioner.setGroupMemberships(groupMembershipPerUser.get(userId));
            if (psasPerUser.containsKey(userId))
                userDeprovisioner.setPermissionSetAssignments(psasPerUser.get(userId));
            if (uplsPerUser.containsKey(userId))
                userDeprovisioner.setUserPackageLicenses(uplsPerUser.get(userId));
            if (cronJobsPerUser.containsKey(userId))
                userDeprovisioner.setCronJobs(cronJobsPerUser.get(userId));
        }
    }

    /**
     * Handle the response from updating or deleting records
     * Add to the user's processing notes if needed
     * Mark the user as needing to be updated
     * And setup error logger queueables
     */
    private void handleResponse(UserDeprovisionOrganizer.ResultWrapper resultWrapper) {
        // Map user id to user deprovisioner
        Map<Id, UserDeprovisioner> userDeprovisionersMp = new Map<Id, UserDeprovisioner>();
        for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
            userDeprovisionersMp.put(userDeprovisioner.getUser().Id, userDeprovisioner);
        }

        // Log any error
        if (resultWrapper.ex != null) {
            enqueueNext(new ErrorLogger.ErrorLoggerQueue(resultWrapper.ex, resultWrapper.vars, false));
        }

        // Add processing notes to user
        for (Id userId : resultWrapper.userIdToProcessingNotes.keySet()) {
            userDeprovisionersMp.get(userId).addToProcessingNotes(resultWrapper.userIdToProcessingNotes.get(userId));
            updatedUsers.add(userDeprovisionersMp.get(userId).getUser());
        }
    }

    /**
     * Nextable implementation
     */
    private NextableDefaultImplementation nextImpl = new NextableDefaultImplementation();
    public void launchNext() {
        nextImpl.launchNext();
    }
    public void enqueueNext(Nextable next) {
        nextImpl.enqueueNext(next);
    }
}