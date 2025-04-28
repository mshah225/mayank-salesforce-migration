/**
 * The UserDeprovisioner is used to do the main job of figuring out WHAT to deprovision for each user.
 *
 * You setup the object and then call `deprovisionUser`, which logs the necessary changes on the user, and figures out
 * which records of each related records need to be updated/removed.
 *
 * Then the caller needs use the getter functions to actually get those updated/remove-ready records and apply those changes
 * to the database, ideally batching them so that you don't hit DML limits when deprovisioning multiple users at once.
 *
 * For the deprovisioning process, these records are created initially in the UserTrigger context, where it launches the deprovisioning
 * process and logs all necessary changes on the user. Then it is passed along to each Queueable and Batch apex instance in order to keep
 * track of the record throughout the process. d
 */
public without sharing class UserDeprovisioner {
    // The user to deprovision
    private User deprovisionUser;
    private User updatedUser; // updated version with changes since this is launched from after trigger context

    // Metadata used to determine how to deprovision users
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;
    private Map<String, Deprovision_User_Campaign_Reassignment__mdt> deprovisionUserReassignmentMetadata;

    // Flag indicating is deprovisioning has been called yet or not
    private Boolean doDeprovision = false;

    // All related records
    private List<GroupMember> groupMemberships;
    private List<PermissionSetAssignment> permissionSetAssignments;
    private List<UserPackageLicense> userPackageLicenses;
    private List<CronTrigger> cronJobs;
    private List<CollaborationGroupMember> chatterGroupMemberships;
    private UserLogin userLogin;
    private List<smagicinteract__SMS_SenderId__c> smsSenderIds;
    private List<smagicinteract__SenderId_Profile_Map__c> smsSenderIdAssignments;
    private List<smagicinteract__License__c> smsLicenses;
    private List<Campaign> campaigns;

    // Flag to lock records objects after initial deprovisioning - this allows us to force errors to check what happens during DML error
    @TestVisible
    private static Boolean FORCE_LOCK = false;
    private Boolean locked = false;

    public UserDeprovisioner(
        User deprovisionUser,
        Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration,
        Map<String, Deprovision_User_Campaign_Reassignment__mdt> deprovisionUserReassignmentMetadata
    ) {
        this.deprovisionUser = deprovisionUser;
        this.updatedUser = new User(Id = deprovisionUser.Id);

        this.deprovisionUserConfiguration = deprovisionUserConfiguration;
        this.deprovisionUserReassignmentMetadata = deprovisionUserReassignmentMetadata;
    }

    // Wraps together all the logic
    public Boolean deprovisionUser() {
        try {
            // Separator if there are already notes
            if (String.isNotBlank(deprovisionUser.Processing_Notes__c)) {
                addToProcessingNotes('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            }

            // Start timestamp
            addToProcessingNotes(
                System.now().format('YYYY-MM-dd HH:mm:ss') +
                    ' UserId: ' +
                    UserInfo.getUserId() +
                    ', UserName: ' +
                    UserInfo.getName()
            );

            if (matchProfileToIgnore())
                throw new DeprovisionUserException('Could not deprovision user. Matched profile.');
            if (matchSFAdminOrDeveloper())
                throw new DeprovisionUserException('Could not deprovision user. Matched SF Admin/Developer.');
            if (matchDelegatedAdmin())
                throw new DeprovisionUserException('Could not deprovision user. Matched Delegated Adminstrator.');
            if (matchPermSetToIgnore())
                throw new DeprovisionUserException('Could not deprovision user. Matched Permission Set.');

            changeUserField('ProfileId');
            changeUserField('UserRoleId');
            updateUserFields();
            removeGroupMemberships(true);
            removePermissionSetAssignments(true);
            removeUserPackageLicenses(true);
            abortCronJobs(true);
            removeChatterGroupMemberships(true);
            updateUserLogin(true);
            updateSmsSenderIds(true);
            removeSmsSenderIdAssignments(true);
            deactivateSmsLicenses(true);
            reassignCampaigns(true);
            updatedUser.Deprovision_User__c = false;
            updatedUser.IsActive = false;
            doDeprovision = true;

            if (Test.isRunningTest() && FORCE_LOCK)
                locked = true;

            return true; // User is allowed to be deprovisioned
        } catch (Exception e) {
            if (e.getTypeName().equals('System.SObjectException')) {
                // If this is the type - one of the custom setting details might be wrong - add which to check
                e.setMessage(
                    e.getMessage() +
                        '\nSuspected incorrect setting detail: ' +
                        whichSettingDetailIsResponsible(e.getMessage())
                );
            }

            addToProcessingNotes('Exception Thrown: ' + e.getMessage());
            addToProcessingNotes('' + e.getStackTraceString());

            updatedUser.Deprovision_User__c = false;

            return false; // user not allowed to be deprovisioned
        }
    }

    // Toggle fields to false and clear any fields that should be removed
    private void updateUserFields() {
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('SwitchToFalse')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(
                    deprovisionConfigurationName
                );
                if (deprovisionUser.get(configuration.Name__c) == true) {
                    updatedUser.put(configuration.Name__c, false);
                    addToProcessingNotes('Switched ' + configuration.Name__c + ' to false');
                }
            } else if (deprovisionConfigurationName.contains('RemoveValue')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(
                    deprovisionConfigurationName
                );
                if (deprovisionUser.get(configuration.Name__c) != null) {
                    addToProcessingNotes(
                        'Removed value ' + deprovisionUser.get(configuration.Name__c) + ' for ' + configuration.Name__c
                    );
                    updatedUser.put(configuration.Name__c, null);
                }
            }
        }
    }

    // Remove user from all groups
    private void removeGroupMemberships(Boolean logIt) {
        if (groupMemberships != null && !groupMemberships.isEmpty()) {
            if (logIt) {
                List<String> nameList = new List<String>();
                for (GroupMember membership : groupMemberships)
                    nameList.add(membership?.Group?.Name);
                addToProcessingNotes('Removed user from Public Groups: ' + String.join(nameList, ', '));
            }
        } else {
            groupMemberships = null;
        }
    }

    // Remove user from all permission set assignments
    private void removePermissionSetAssignments(Boolean logIt) {
        if (permissionSetAssignments != null && !permissionSetAssignments.isEmpty()) {
            if (logIt) {
                List<String> nameList = new List<String>();
                for (PermissionSetAssignment permSet : permissionSetAssignments)
                    nameList.add(permSet?.PermissionSet?.Name);
                addToProcessingNotes('Removed user from Permission Sets: ' + String.join(nameList, ', '));
            }
        } else {
            permissionSetAssignments = null;
        }
    }

    // Remove any user package licenses
    private void removeUserPackageLicenses(Boolean logIt) {
        if (userPackageLicenses != null && !userPackageLicenses.isEmpty()) {
            if (logIt) {
                List<String> nameList = new List<String>();
                for (UserPackageLicense license : userPackageLicenses)
                    nameList.add(license?.PackageLicense?.NamespacePrefix);
                addToProcessingNotes('Removed user from Package Licenses: ' + String.join(nameList, ', '));
            }
        } else {
            userPackageLicenses = null;
        }
    }

    // Abort any cron jobs
    private void abortCronJobs(Boolean logIt) {
        // Get a set of all types of cron jobs we need to abort
        Set<String> abortTypesSet = new Set<String>();
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('AbortCronJob')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(
                    deprovisionConfigurationName
                );
                abortTypesSet.add(configuration.Name__c);
            }
        }

        List<CronTrigger> dontAbortList = new List<CronTrigger>();

        if (cronJobs != null && !cronJobs.isEmpty()) {
            List<String> removedJobStrs = new List<String>();

            // Filter to only abort types from the configuration settings
            for (CronTrigger job : cronJobs)
                if (!abortTypesSet.contains(job.CronJobDetail.JobType))
                    dontAbortList.add(job);
            for (CronTrigger job : dontAbortList)
                cronJobs.remove(cronJobs.indexOf(job));

            // Note either list of aborted jobs or lack of jobs to abort
            if (logIt) {
                if (!cronJobs.isEmpty()) {
                    List<String> nameList = new List<String>();
                    for (CronTrigger job : cronJobs)
                        nameList.add(
                            job?.CronJobDetail?.Name +
                                ' (type: ' +
                                getCronTypeNameFromType(job?.CronJobDetail?.JobType) +
                                ')'
                        );
                    addToProcessingNotes('Aborting scheduled jobs: ' + String.join(nameList, ', '));
                } else {
                    addToProcessingNotes('Aborting scheduled jobs: No jobs to abort');
                }
            }
        } else {
            cronJobs = null;
        }
    }

    // Remove user from all chatter groups
    private void removeChatterGroupMemberships(Boolean logIt) {
        if (chatterGroupMemberships != null && !chatterGroupMemberships.isEmpty()) {
            if (logIt) {
                List<String> nameList = new List<String>();
                for (CollaborationGroupMember chatterMembership : chatterGroupMemberships)
                    nameList.add(chatterMembership?.CollaborationGroup?.Name);
                addToProcessingNotes('Removed user from Chatter Groups: ' + String.join(nameList, ', '));
            }
        } else {
            chatterGroupMemberships = null;
        }
    }

    // Update user login
    private void updateUserLogin(Boolean logIt) {
        if (userLogin != null && userLogin.IsFrozen) {
            if (logIt) {
                addToProcessingNotes('Unfroze related UserLogin (' + userLogin.Id + ')');
            }
            userLogin.IsFrozen = false;
        } else {
            userLogin = null;
        }
    }

    // Update SMS Sender Ids labels
    private void updateSmsSenderIds(Boolean logIt) {
        if (smsSenderIds != null && !smsSenderIds.isEmpty()) {
            for (smagicinteract__SMS_SenderId__c smsSenderId : smsSenderIds) {
                String newLabel = smsSenderId.smagicinteract__label__c
                    ?.replaceAll(deprovisionUser.FirstName + ' ' + deprovisionUser.LastName, '')
                    ?.trim();
                smsSenderId.smagicinteract__label__c = newLabel;
            }
        } else {
            smsSenderIds = null;
        }
    }

    // Remove SMS Sender Id Assignments
    private void removeSmsSenderIdAssignments(Boolean logIt) {
        if (smsSenderIdAssignments != null && !smsSenderIdAssignments.isEmpty()) {
            if (logIt) {
                addToProcessingNotes('Unassigned ' + smsSenderIdAssignments.size() + ' Sender Ids');
            }
        } else {
            smsSenderIdAssignments = null;
        }
    }

    // Remove SMS licenses
    private void deactivateSmsLicenses(Boolean logIt) {
        if (smsLicenses != null && !smsLicenses.isEmpty()) {
            for (smagicinteract__License__c smsLicense : smsLicenses) {
                smsLicense.smagicinteract__Status__c = false;
            }
            if (logIt) {
                addToProcessingNotes('Removed ' + smsLicenses.size() + ' SMS Licenses');
            }
        } else {
            smsLicenses = null;
        }
    }

    // Reassign campaigns
    private void reassignCampaigns(Boolean logIt) {
        // Find relevant metadatum for this user's role
        Deprovision_User_Campaign_Reassignment__mdt reassignmentRuleForUser;
        for (Deprovision_User_Campaign_Reassignment__mdt metadatum : deprovisionUserReassignmentMetadata.values()) {
            if (metadatum.Role_Id__c == deprovisionUser.UserRoleId) {
                reassignmentRuleForUser = metadatum;
                break;
            }
        }

        // Reassign campaigns
        if (campaigns != null && !campaigns.isEmpty() && reassignmentRuleForUser != null) {
            for (Campaign cam : campaigns) {
                cam.OwnerId = reassignmentRuleForUser.Default_Owner__c;
            }

            // Log changes
            if (logIt) {
                List<String> campaignIds = new List<String>();
                for (Campaign cam : campaigns)
                    campaignIds.add(cam.Id);
                addToProcessingNotes(
                    'Reassigned campaigns: ' +
                        String.join(campaignIds, ', ') +
                        ' to ' +
                        reassignmentRuleForUser.Default_Owner__c
                );
            }
        } else {
            campaigns = null;
        }
    }

    // Helper functionality
    @TestVisible
    private String whichSettingDetailIsResponsible(String errorMessage) {
        if (!errorMessage.contains('Invalid field') || !errorMessage.contains(' for User')) {
            // No field name to check for
            return '';
        }

        String fieldName = errorMessage.substring(
            errorMessage.indexOf('Invalid field ') + 14,
            errorMessage.indexOf(' for User')
        );
        String suspectedBrokenConfigOption = '';

        for (String key : deprovisionUserConfiguration.keySet()) {
            Deprovision_User_Configuration__c config = deprovisionUserConfiguration.get(key);
            if (config.Name__c.equals(fieldName)) {
                suspectedBrokenConfigOption += ', ' + key;
            }
        }

        if (suspectedBrokenConfigOption.length() < 2) {
            return '';
        } else {
            return suspectedBrokenConfigOption.substring(2);
        }
    }

    // Add message to the end of the processing notes for this user
    public void addToProcessingNotes(String message) {
        if (updatedUser.Processing_Notes__c == null)
            updatedUser.Processing_Notes__c = String.isNotBlank(deprovisionUser.Processing_Notes__c)
                ? deprovisionUser.Processing_Notes__c
                : '';
        updatedUser.Processing_Notes__c += message + '\n';
    }

    // Check if user has an unpermitted profile
    private Boolean matchProfileToIgnore() {
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('ProfileToIgnore')) {
                Id profileIdToMatch = Id.valueOf(deprovisionUserConfiguration.get(deprovisionConfigurationName).Id__c);
                if (deprovisionUser.ProfileId == profileIdToMatch) {
                    addToProcessingNotes(
                        'Profile matched to: ' +
                            deprovisionUserConfiguration.get(deprovisionConfigurationName).Name__c +
                            ', Stopping User Deprovision'
                    );
                    return true;
                }
            }
        }
        return false;
    }

    // Check if user has Admin/Developer role
    private Boolean matchSFAdminOrDeveloper() {
        if (deprovisionUser.Role_Administrator_Developer__c) {
            addToProcessingNotes(
                'Detected SF Developer or Admin based on PeopleSoft Roles Administrator/Developer. Stopping User Deprovision'
            );
            return true;
        }
        return false;
    }

    // Check if user is a delegated admin
    private Boolean matchDelegatedAdmin() {
        if (deprovisionUser.Sandbox_Delagated_Administrator__c) {
            addToProcessingNotes('Detected Delegated Administrator. Stopping User Deprovision');
            return true;
        } else {
            return false;
        }
    }

    // Check if user has an unpermitted permission set
    private Boolean matchPermSetToIgnore() {
        Boolean hasPermSet = false;

        // Get a map of all the perm sets that should cause abort
        Map<Id, String> permSetToIgnoreIdToName = new Map<Id, String>();
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            Deprovision_User_Configuration__c customSetting = deprovisionUserConfiguration.get(
                deprovisionConfigurationName
            );
            if (customSetting.Name.contains('PermissionSetToIgnore')) {
                permSetToIgnoreIdToName.put(customSetting.Id__c, customSetting.Name__c);
            }
        }

        // Check if this user has at least one of these
        if (permissionSetAssignments != null && !permissionSetAssignments.isEmpty()) {
            for (PermissionSetAssignment permSet : permissionSetAssignments) {
                // this perm set is one of the abort-causing perm sets
                if (permSetToIgnoreIdToName.keySet().contains(permSet.PermissionSetId)) {
                    hasPermSet = true;
                    // record this in the notes
                    addToProcessingNotes(
                        'Permission set matched to: ' +
                            permSetToIgnoreIdToName.get(permSet.PermissionSetId) +
                            ', Stopping User Deprovision'
                    );
                    break;
                }
            }
        }

        return hasPermSet;
    }

    // Change a single field according to metadata
    private void changeUserField(String fieldName) {
        Deprovision_User_Configuration__c changeFieldTo = deprovisionUserConfiguration.get(
            'Change ' + fieldName + ' To'
        );

        String fieldValue = (String) (deprovisionUser.get(fieldName));

        addToProcessingNotes('Changed ' + fieldName + ' from: ' + fieldValue + ' to ' + changeFieldTo.Name__c);

        updatedUser.put(fieldName, Id.valueOf(changeFieldTo.Id__c));
    }

    // Set fields before deprovisioning - if you change these after deprovisioning it'll rerun the portion to
    // deprovision those records
    public void setGroupMemberships(List<GroupMember> groupMemberships) {
        if (locked)
            return;
        this.groupMemberships = groupMemberships;
        if (doDeprovision)
            removeGroupMemberships(false);
    }
    public void setPermissionSetAssignments(List<PermissionSetAssignment> permissionSetAssignments) {
        if (locked)
            return;
        this.permissionSetAssignments = permissionSetAssignments;
        if (doDeprovision)
            removePermissionSetAssignments(false);
    }
    public void setUserPackageLicenses(List<UserPackageLicense> userPackageLicenses) {
        if (locked)
            return;
        this.userPackageLicenses = userPackageLicenses;
        if (doDeprovision)
            removeUserPackageLicenses(false);
    }
    public void setCronJobs(List<CronTrigger> cronJobs) {
        if (locked)
            return;
        this.cronJobs = cronJobs;
        if (doDeprovision)
            abortCronJobs(false);
    }
    public void setChatterGroupMemberships(List<CollaborationGroupMember> chatterGroupMemberships) {
        if (locked)
            return;
        this.chatterGroupMemberships = chatterGroupMemberships;
        if (doDeprovision)
            removeChatterGroupMemberships(false);
    }
    public void setUserLogin(UserLogin userLogin) {
        if (locked)
            return;
        this.userLogin = userLogin;
        if (doDeprovision)
            updateUserLogin(false);
    }
    public void setSmsSenderIdAssignments(List<smagicinteract__SenderId_Profile_Map__c> smsSenderIdAssignments) {
        if (locked)
            return;
        this.smsSenderIdAssignments = smsSenderIdAssignments;
        this.smsSenderIds = new List<smagicinteract__SMS_SenderId__c>();

        for (smagicinteract__SenderId_Profile_Map__c smsSenderIdAssignment : smsSenderIdAssignments)
            this.smsSenderIds.add(smsSenderIdAssignment.smagicinteract__senderid_lookup__r);

        if (doDeprovision) {
            updateSmsSenderIds(false);
            removeSmsSenderIdAssignments(false);
        }
    }
    public void setSmsLicenses(List<smagicinteract__License__c> smsLicenses) {
        if (locked)
            return;
        this.smsLicenses = smsLicenses;

        if (doDeprovision)
            deactivateSmsLicenses(false);
    }
    public void setCampaigns(List<Campaign> campaigns) {
        if (locked)
            return;
        this.campaigns = campaigns;

        if (doDeprovision)
            reassignCampaigns(false);
    }

    // Get lists of modified records after deprovisioning
    public User getUser() {
        return updatedUser;
    }
    public List<GroupMember> getGroupMemberships() {
        return groupMemberships;
    }
    public List<PermissionSetAssignment> getPermissionSetAssignments() {
        return permissionSetAssignments;
    }
    public List<UserPackageLicense> getUserPackageLicenses() {
        return userPackageLicenses;
    }
    public List<CronTrigger> getCronJobs() {
        return cronJobs;
    }
    public List<CollaborationGroupMember> getChatterGroupMemberships() {
        return chatterGroupMemberships;
    }
    public UserLogin getUserLogin() {
        return userLogin;
    }
    public List<smagicinteract__SMS_SenderId__c> getSmsSenderIds() {
        return smsSenderIds;
    }
    public List<smagicinteract__SenderId_Profile_Map__c> getSmsSenderIdAssignments() {
        return smsSenderIdAssignments;
    }
    public List<smagicinteract__License__c> getSmsLicenses() {
        return smsLicenses;
    }
    public List<Campaign> getCampaigns() {
        return campaigns;
    }

    public class DeprovisionUserException extends Exception {
    }

    private static Map<String, String> cronTypeNameMap;
    private static String getCronTypeNameFromType(String key) {
        if (cronTypeNameMap == null) {
            cronTypeNameMap = new Map<String, String>();

            // Get from picklist
            Map<String, String> nameToKey = ObjectService.getPicklistChoicesMap('CronJobDetail', 'JobType');
            for (String name : nameToKey.keySet()) {
                cronTypeNameMap.put(nameToKey.get(name), name);
            }
            // Add any others that we know from experience
            if (!cronTypeNameMap.containsKey('E'))
                cronTypeNameMap.put('E', 'Sitemap SEO Generation Job');
            if (!cronTypeNameMap.containsKey('G'))
                cronTypeNameMap.put('G', 'Sitemap SEO Incremental Job');
            if (!cronTypeNameMap.containsKey('K'))
                cronTypeNameMap.put('K', 'Autonomous Data Loader Job');
            if (!cronTypeNameMap.containsKey('T'))
                cronTypeNameMap.put('T', 'Report Type Metadata for Search');
            if (!cronTypeNameMap.containsKey('X'))
                cronTypeNameMap.put('X', 'Standard Report Type Metadata for Search');
        }

        if (cronTypeNameMap.containsKey(key))
            return cronTypeNameMap.get(key);
        return 'UNKNOWN';
    }
}