/**
 * Update all [non-setup](https://developer.salesforce.com/docs/atlas.en-us.230.0.apexcode.meta/apexcode/apex_dml_non_mix_sobjects.htm) objects as part of user deprovisioning.
 *
 * We've already updated the log on the relevant user with these changes, so we need to actually do them now and log it there are errors
 *
 * This includes
 * 1. Removing chatter group memberships (`CollaborationGroupMember`).
 * 2. Unfreezing user login records (`UserLogin`)
 * 3. SMS Sender Ids (`smagicinteract__SMS_SenderId__c`)
 * 4. SMS Sender Ids Assignments (`smagicinteract__SenderId_Profile_Map__c`)
 * 5. SMS Licenses (`smagicinteract__License__c`)
 */
public without sharing class UserDeprovisionerQueueNonSetupRecords implements Queueable, Nextable {
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
            List<smagicinteract__SMS_SenderId__c> smsSenderIds = new List<smagicinteract__SMS_SenderId__c>();
            List<smagicinteract__SenderId_Profile_Map__c> smsSenderIdAssignmnents = new List<smagicinteract__SenderId_Profile_Map__c>();
            List<smagicinteract__License__c> smsLicenses = new List<smagicinteract__License__c>();
            List<Campaign> campaigns = new List<Campaign>();

            // Collect all non-setup records that need to be removed or changed
            for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
                userDeprovisionersMp.put(userDeprovisioner.getUser().Id, userDeprovisioner);

                List<CollaborationGroupMember> userChatterMemberships = userDeprovisioner.getChatterGroupMemberships();
                if (userChatterMemberships != null)
                    chatterMemberships.addAll(userChatterMemberships);

                UserLogin userLogin = userDeprovisioner.getUserLogin();
                if (userLogin != null)
                    userLogins.add(userLogin);

                List<smagicinteract__SMS_SenderId__c> userSmsSenderIds = userDeprovisioner.getSmsSenderIds();
                if (userSmsSenderIds != null)
                    smsSenderIds.addAll(userSmsSenderIds);

                List<smagicinteract__SenderId_Profile_Map__c> userSmsSenderIdAssignmnents = userDeprovisioner.getSmsSenderIdAssignments();
                if (userSmsSenderIdAssignmnents != null)
                    smsSenderIdAssignmnents.addAll(userSmsSenderIdAssignmnents);

                List<smagicinteract__License__c> userSmsLicenses = userDeprovisioner.getSmsLicenses();
                if (userSmsLicenses != null)
                    smsLicenses.addAll(userSmsLicenses);

                List<Campaign> userCampaigns = userDeprovisioner.getCampaigns();
                if (userCampaigns != null)
                    campaigns.addAll(userCampaigns);
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

            // Update SMS Sender Id labels
            if (!smsSenderIds.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.updateSobjectRecords(
                    'Id',
                    smsSenderIds
                );

                // Since these don't look up directly to user resultWrapper.userIdToProcessingNotes actually point record Id -> notes rather than userId,
                // We must fix this before passing to handleResponse
                if (!resultWrapper.userIdToProcessingNotes.isEmpty()) {
                    // Build map from sender id to user
                    Map<Id, Id> senderIdToUserIdMp = new Map<Id, Id>();
                    for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
                        Id userId = userDeprovisioner.getUser().Id;
                        List<smagicinteract__SMS_SenderId__c> userSmsSenderIds = userDeprovisioner.getSmsSenderIds();
                        if (userSmsSenderIds != null)
                            for (smagicinteract__SMS_SenderId__c senderId : userSmsSenderIds)
                                senderIdToUserIdMp.put(senderId.Id, userId);
                    }

                    // Build new processing notes mapping
                    Map<Id, String> newProcessingNotes = new Map<Id, String>();
                    for (Id senderId : resultWrapper.userIdToProcessingNotes.keySet())
                        newProcessingNotes.put(
                            senderIdToUserIdMp.get(senderId),
                            resultWrapper.userIdToProcessingNotes.get(senderId)
                        );

                    resultWrapper.userIdToProcessingNotes = newProcessingNotes;
                }

                handleResponse(resultWrapper);
            }

            // Remove SMS Sender Id assignments
            if (!smsSenderIdAssignmnents.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.deleteSobjectRecords(
                    'smagicinteract__User__c',
                    smsSenderIdAssignmnents
                );
                handleResponse(resultWrapper);
            }

            // Remove SMS Licenses
            if (!smsLicenses.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.deleteSobjectRecords(
                    'smagicinteract__User__c',
                    smsLicenses
                );
                handleResponse(resultWrapper);
            }

            // Reassign campaigns
            if (!campaigns.isEmpty()) {
                UserDeprovisionOrganizer.ResultWrapper resultWrapper = UserDeprovisionOrganizer.updateSobjectRecords(
                    'Id',
                    campaigns
                );

                // Since these are being updated to reassign the owner, we can't use OwnerId map Campaign to
                // relevant user, instead we need to take record id and cross reference it to get corresponding
                // user
                if (!resultWrapper.userIdToProcessingNotes.isEmpty()) {
                    // Build map from campaign id to user id
                    Map<Id, Id> campaignIdToUserIdMp = new Map<Id, Id>();
                    for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
                        Id userId = userDeprovisioner.getUser().Id;
                        List<Campaign> userCampaigns = userDeprovisioner.getCampaigns();
                        if (userCampaigns != null)
                            for (Campaign cam : userCampaigns)
                                campaignIdToUserIdMp.put(cam.Id, userId);
                    }

                    // Build new processing notes mapping
                    Map<Id, String> newProcessingNotes = new Map<Id, String>();
                    for (Id campaignId : resultWrapper.userIdToProcessingNotes.keySet())
                        newProcessingNotes.put(
                            campaignIdToUserIdMp.get(campaignId),
                            resultWrapper.userIdToProcessingNotes.get(campaignId)
                        );
                    resultWrapper.userIdToProcessingNotes = newProcessingNotes;
                }

                handleResponse(resultWrapper);
            }

            // Launch next stage of user deprovisioning
            if (!updatedUsers.isEmpty())
                enqueueNext(new UpdateUsersQueueable(new List<User>(updatedUsers)));
            enqueueNext(new UserDeprovisionerQueueSetupRecords(userDeprovisioners));
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            List<Id> userIds = new List<Id>();
            for (UserDeprovisioner userDeprovisioner : userDeprovisioners)
                userIds.add(userDeprovisioner.getUser().Id);
            vars.add(ErrorLogger.convertListToJSON('userIds', userIds));
            ErrorLogger.log(ex, vars, false);
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
        Map<Id, List<CollaborationGroupMember>> chatterGroupsPerUser = UserDeprovisionOrganizer.getChatterGroupMembership(
            userIds
        );
        Map<Id, UserLogin> userLoginPerUser = UserDeprovisionOrganizer.getUserLogins(userIds);
        Map<Id, List<smagicinteract__SenderId_Profile_Map__c>> smsSenderIdAssignmentsPerUser = UserDeprovisionOrganizer.getSMSMagicSenderIdsAssignments(
            userIds
        );
        Map<Id, List<smagicinteract__License__c>> smsMagicLicensesPerUser = UserDeprovisionOrganizer.getSMSMagicLicenses(
            userIds
        );
        Map<Id, List<Campaign>> campaignsPerUser = UserDeprovisionOrganizer.getCampaigns(userIds);

        // Refresh details in user deprovisioners
        for (UserDeprovisioner userDeprovisioner : userDeprovisioners) {
            Id userId = userDeprovisioner.getUser().Id;
            if (chatterGroupsPerUser.containsKey(userId))
                userDeprovisioner.setChatterGroupMemberships(chatterGroupsPerUser.get(userId));
            if (userLoginPerUser.containsKey(userId))
                userDeprovisioner.setUserLogin(userLoginPerUser.get(userId));
            if (smsSenderIdAssignmentsPerUser.containsKey(userId))
                userDeprovisioner.setSmsSenderIdAssignments(smsSenderIdAssignmentsPerUser.get(userId));
            if (smsMagicLicensesPerUser.containsKey(userId))
                userDeprovisioner.setSmsLicenses(smsMagicLicensesPerUser.get(userId));
            if (campaignsPerUser.containsKey(userId))
                userDeprovisioner.setCampaigns(campaignsPerUser.get(userId));
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
     * Nextable implementation
     */
    private NextableDefaultImplementation nextImpl = new NextableDefaultImplementation();
    public void launchNext() {
        nextImpl.launchNext();
    }
    public void enqueueNext(Nextable next) {
        nextImpl.enqueueNext(next);
    }

    /**
     * Users are a setup object so this needs to be updated separately
     */
    private class UpdateUsersQueueable implements Queueable, Nextable {
        private List<User> users;
        public UpdateUsersQueueable(List<User> users) {
            this.users = users;
        }

        public void execute(QueueableContext context) {
            try {
                if (!users.isEmpty())
                    update users;
            } catch (Exception ex) {
                List<String> vars = new List<String>();
                vars.add(
                    ErrorLogger.convertStringToJSON('message', 'Failed to update users\' processing notes after error')
                );

                Set<Id> userIds;
                if (users != null)
                    userIds = new Map<Id, User>(users).keySet();
                vars.add(ErrorLogger.convertSetToJSON('userIds', userIds));

                ErrorLogger.log(ex, vars, false);
            }

            launchNext();
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
}