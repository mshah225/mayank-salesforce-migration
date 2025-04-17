/**
 * Update all [non-setup](https://developer.salesforce.com/docs/atlas.en-us.230.0.apexcode.meta/apexcode/apex_dml_non_mix_sobjects.htm) objects as part of user deprovisioning.
 *
 * We've already updated the log on the relevant user with these changes, so we need to actually do them now and log it there are errors
 *
 * This includes
 * 1. Removing chatter group memberships (`CollaborationGroupMember`).
 * 2. Unfreezing user login records (`UserLogin`)
 */
public without sharing class UserDeprovisionerQueueNonSetupRecords implements Queueable {
    private List<UserDeprovisioner> userDeprovisioners;
    Set<User> updatedUsers = new Set<User>();

    public UserDeprovisionerQueueNonSetupRecords(List<UserDeprovisioner> userDeprovisioners) {
        this.userDeprovisioners = userDeprovisioners;
    }

    public void execute(QueueableContext context) {
        UserDeprovisionOrganizer.isDeprovisoning = true;
        try {
            refreshUserDeprovisioners();

            Map<Id, UserDeprovisioner> userDeprovisionersMp = new Map<Id, UserDeprovisioner>();
            List<CollaborationGroupMember> chatterMemberships = new List<CollaborationGroupMember>();
            List<UserLogin> userLogins = new List<UserLogin>();

            // Collect all non-setup records that need to be removed or changed
            for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
                userDeprovisionersMp.put(userDeprovisioner.getUser().Id, userDeprovisioner);

                List<CollaborationGroupMember> userChatterMemberships = userDeprovisioner.getChatterGroupMemberships();
                if (userChatterMemberships != null)
                    chatterMemberships.addAll(userChatterMemberships);

                UserLogin userLogin = userDeprovisioner.getUserLogin();
                if (userLogin != null)
                    userLogins.add(userLogin);
            }

            // Update chatter memberships and error log if any failures
            if (!chatterMemberships.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.deleteSobjectRecords(
                    'MemberId',
                    chatterMemberships
                );
                handleResponse(resultWrapper);
            }

            // Update UserLogins and error log if any failures
            if (!userLogins.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.updateSobjectRecords(
                    'UserId',
                    userLogins
                );
                handleResponse(resultWrapper);
            }

            // Lastly update users with any changed logs
            if (!updatedUsers.isEmpty())
                update new List<User>(updatedUsers);

            launchNextStage();
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            List<Id> userIds = new List<Id>();
            for (UserDeprovisioner userDeprovisioner : userDeprovisioners)
                userIds.add(userDeprovisioner.getUser().Id);
            vars.add(ErrorLogger.convertListToJSON('userIds', userIds));
            ErrorLogger.log(ex, vars, false);
        }
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
        Map<Id, List<CollaborationGroupMember>> chatterGroupsPerUser = UserDeprovisionOrganizer.getChatterGroupMembership(
            userIds
        );
        Map<Id, UserLogin> userLoginPerUser = UserDeprovisionOrganizer.getUserLogins(userIds);

        // Refresh details in user deprovisioners
        for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
            Id userId = userDeprovisioner.getUser().Id;
            if (chatterGroupsPerUser.containsKey(userId))
                userDeprovisioner.setChatterGroupMemberships(chatterGroupsPerUser.get(userId));
            if (userLoginPerUser.containsKey(userId))
                userDeprovisioner.setUserLogin(userLoginPerUser.get(userId));
        }
    }

    /**
     * Handle the response from updating or deleting records
     * Add to the user's processing notes if needed
     * Mark the user as needing to be updated
     * And error log
     */
    private void handleResponse(UserDeprovisionOrganizer.ResultWrapper resultWrapper) {
        // Map user id to user deprovisioner
        Map<Id, UserDeprovisioner> userDeprovisionersMp = new Map<Id, UserDeprovisioner>();
        for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
            userDeprovisionersMp.put(userDeprovisioner.getUser().Id, userDeprovisioner);
        }

        // Log any error
        if (resultWrapper.ex != null) {
            ErrorLogger.log(resultWrapper.ex, resultWrapper.vars, false);
        }

        // Add processing notes to user
        for (Id userId : resultWrapper.userIdToProcessingNotes.keySet()) {
            userDeprovisionersMp.get(userId).addToProcessingNotes(resultWrapper.userIdToProcessingNotes.get(userId));
            updatedUsers.add(userDeprovisionersMp.get(userId).getUser());
        }
    }

    /**
     * Launch the next stage of the User Deprovisioning process
     */
    private void launchNextStage() {
        // Now enqueue a job to do the next stage
        GovernorLimitPreemptException.assertCanEnqueueJobs(
            1,
            'Could not enqueue stage 3 of user deprovisioning - reached queueable limit'
        );
        GovernorLimitPreemptException.assertCanEnqueueJobsDepth(
            1,
            'Could not enqueue stage 3 of user deprovisioning - reached stack depth limit'
        );
        System.enqueueJob(new UserDeprovisionerQueueSetupRecords(userDeprovisioners));
    }
}