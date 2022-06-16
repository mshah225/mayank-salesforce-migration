public without sharing class UserDeprovisioner {
    private String processingNotes;
    private User deprovisionedUser;
    private User userToDeprovision;
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;
    private Map<Id, String> fieldIdToNameMap;

    // original data
    private List<Case> cases;
    private UserLogin userLogin;
    private List<GroupMember> groupMemberships;
    private List<CollaborationGroupMember> chatterGroupMemberships;
    private List<PermissionSetAssignment> permissionSetAssignments;
    private List<UserPackageLicense> userPackageLicenses;
    private List<CronTrigger> cronJobs;
    // Data to delete/update data
    private List<Case> toUpdateCases;
    private UserLogin toUpdateUserLogin;
    private List<GroupMember> toDeleteGroupMemberships;
    private List<CollaborationGroupMember> toDeleteChatterGroupMemberships;
    private List<PermissionSetAssignment> toDeletePermissionSetAssignments;
    private List<UserPackageLicense> toDeleteUserPackageLicenses;
    private List<CronTrigger> toAbortCronJobs;

    private static Boolean debug = false;
    private static Boolean allowRepeatCases = true;

    public UserDeprovisioner(
        Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration,
        User userToDeprovision
    ) {
        processingNotes = '';
        this.userToDeprovision = userToDeprovision;
        this.deprovisionedUser = new User(Id = userToDeprovision.Id);
        this.deprovisionUserConfiguration = deprovisionUserConfiguration;
        this.fieldIdToNameMap = new Map<Id, String>();

        toUpdateCases = new List<Case>();
        toUpdateUserLogin = null;
        toDeleteGroupMemberships = new List<GroupMember>();
        toDeleteChatterGroupMemberships = new List<CollaborationGroupMember>();
        toDeletePermissionSetAssignments = new List<PermissionSetAssignment>();
        toDeleteUserPackageLicenses = new List<UserPackageLicense>();
        toAbortCronJobs = new List<CronTrigger>();
    }

    // Wraps together all the logic
    public void deprovisionUser() {
        try {
            if (userToDeprovision.Processing_Notes__c != null) {
                addToProcessingNotes(
                    userToDeprovision.Processing_Notes__c + '\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
                );
            }
            addToProcessingNotes(initialUserTimeStamp());
            if (matchProfileToIgnore()) {
                throw new DeprovisionUserException('Could not deprovision user. Matched profile.');
            }
            if (matchSFAdminOrDeveloper()) {
                throw new DeprovisionUserException('Could not deprovision user. Matched SF Admin/Developer.');
            }
            if (matchDelegatedAdmin()) {
                throw new DeprovisionUserException('Could not deprovision user. Matched Delegated Adminstrator.');
            }
            if (matchPermSetToIgnore()) {
                throw new DeprovisionUserException('Could not deprovision user. Matched Permission Set.');
            }
            changeUserField('ProfileId');
            changeUserField('UserRoleId');
            transferCases();
            updateUserFields();
            updateUserLogin();
            removeGroupMemberships();
            removePermissionSetAssignments();
            removeChatterGroupMemberships();
            removeUserPackageLicenses();
            abortCronJobs();
            deprovisionedUser.Deprovision_User__c = false;
            deprovisionedUser.IsActive = false;
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

            List<String> vars = new List<String>();

            if (deprovisionedUser != null) {
                vars.add(ErrorLogger.convertIdToJSON('deprovisionedUser.Id', deprovisionedUser.Id));
                deprovisionedUser.Deprovision_User__c = false;
            }

            ErrorLogger.ErrorLoggerQueue logQueue = new ErrorLogger.ErrorLoggerQueue(e, vars, debug, allowRepeatCases);
            System.enqueueJob(logQueue);
        }
    }

    // Do the logic for each object type
    private void transferCases() {
        Integer countTransferred = 0;
        try {
            if (cases != null && !cases.isEmpty()) {
                for (Case userCase : cases) {
                    if (userCase.CC_Functional_Group__r.Is_Functional_Group_Private__c) {
                        userCase.OwnerId = userCase.CC_Functional_Group__r.Queue_Id__c;
                        toUpdateCases.add(userCase);

                        countTransferred++;
                    }
                }

                addToProcessingNotes('Transferred ' + countTransferred + ' private cases to queue.');
            }
        } catch (Exception e) {
            addToProcessingNotes('Stopping transfer of cases.');
            throw new DeprovisionUserException(
                'Could not transfer cases. QueueId on case\'s functional group may be invalid.'
            );
        }
    }
    private void updateUserFields() {
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('SwitchToFalse')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(
                    deprovisionConfigurationName
                );
                if (userToDeprovision.get(configuration.Name__c) == true) {
                    deprovisionedUser.put(configuration.Name__c, false);
                    addToProcessingNotes('Switched ' + configuration.Name__c + ' to false');
                }
            } else if (deprovisionConfigurationName.contains('RemoveValue')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(
                    deprovisionConfigurationName
                );
                if (userToDeprovision.get(configuration.Name__c) != null) {
                    addToProcessingNotes(
                        'Removed value ' +
                        userToDeprovision.get(configuration.Name__c) +
                        ' for ' +
                        configuration.Name__c
                    );
                    deprovisionedUser.put(configuration.Name__c, null);
                }
            }
        }
    }
    private void removeGroupMemberships() {
        if (groupMemberships != null && !groupMemberships.isEmpty()) {
            String removedStr = 'Removed user from Public Groups: ';
            for (GroupMember membership : groupMemberships) {
                toDeleteGroupMemberships.add(membership);
                removedStr += membership.Group.Name + ', ';
            }
            addToProcessingNotes(removedStr.substring(0, removedStr.length() - 2));
        }
    }
    private void removeChatterGroupMemberships() {
        if (chatterGroupMemberships != null && !chatterGroupMemberships.isEmpty()) {
            String removedStr = 'Removed user from Chatter Groups: ';
            for (CollaborationGroupMember chatterMembership : chatterGroupMemberships) {
                toDeleteChatterGroupMemberships.add(chatterMembership);
                removedStr += chatterMembership.CollaborationGroup.Name + ', ';
            }
            addToProcessingNotes(removedStr.substring(0, removedStr.length() - 2));
        }
    }
    private void removePermissionSetAssignments() {
        if (permissionSetAssignments != null && !permissionSetAssignments.isEmpty()) {
            String removedStr = 'Removed user from permissionSets: ';
            for (PermissionSetAssignment permSet : permissionSetAssignments) {
                toDeletePermissionSetAssignments.add(permSet);
                removedStr += permSet.PermissionSet.Name + ', ';
            }
            addToProcessingNotes(removedStr.substring(0, removedStr.length() - 2));
        }
    }
    private void removeUserPackageLicenses() {
        if (userPackageLicenses != null && !userPackageLicenses.isEmpty()) {
            String removedStr = 'Removed user from Package Licenses: ';
            for (UserPackageLicense license : userPackageLicenses) {
                toDeleteUserPackageLicenses.add(license);
                removedStr += license.PackageLicense.NamespacePrefix + ', ';
            }
            addToProcessingNotes(removedStr.substring(0, removedStr.length() - 2));
        }
    }
    private void abortCronJobs() {
        Set<String> abortTypesSet = new Set<String>();
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('AbortCronJob')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(
                    deprovisionConfigurationName
                );
                abortTypesSet.add(configuration.Name__c);
            }
        }

        if (cronJobs != null && !cronJobs.isEmpty()) {
            String removedStr = 'Aborting scheduled jobs: ';
            List<String> removedJobStrs = new List<String>();
            for (CronTrigger job : cronJobs) {
                // Abort types form the configuration settings
                if (abortTypesSet.contains(job.CronJobDetail.JobType)) {
                    toAbortCronJobs.add(job);
                    String name = job.CronJobDetail.Name;

                    // if type 8 (a Report Run) - then the name is actually an id, and we need to get the name of the Report from fieldIdToNameMap
                    if (job.CronJobDetail.JobType == '8') {
                        name = fieldIdToNameMap.get(name);
                    }

                    removedJobStrs.add(name + ' (type: ' + getCronTypeNameFromType(job.CronJobDetail.JobType) + ')');
                }
            }

            // only note if there were aborted jobs
            if (!toAbortCronJobs.isEmpty()) {
                removedStr += String.join(removedJobStrs, ', ');
            } else {
                removedStr += 'No jobs to abort';
            }

            addToProcessingNotes(removedStr);
        }
    }
    private void updateUserLogin() {
        if (userLogin != null && userLogin.IsFrozen) {
            addToProcessingNotes('Unfroze related UserLogin (' + userLogin.Id + ')');
            toUpdateUserLogin = new UserLogin(Id = userLogin.Id, IsFrozen = false);
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
    public void addToProcessingNotes(String message) {
        processingNotes += message + '\n';
    }
    private String initialUserTimeStamp() {
        return System.now().format('YYYY-MM-dd HH:mm:ss') +
            ' UserId: ' +
            UserInfo.getUserId() +
            ', UserName: ' +
            UserInfo.getName();
    }
    private Boolean matchProfileToIgnore() {
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('ProfileToIgnore')) {
                Id profileIdToMatch = Id.valueOf(deprovisionUserConfiguration.get(deprovisionConfigurationName).Id__c);
                if (userToDeprovision.ProfileId == profileIdToMatch) {
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
    private Boolean matchSFAdminOrDeveloper() {
        if (userToDeprovision.Role_Administrator_Developer__c) {
            addToProcessingNotes(
                'Detected SF Developer or Admin based on PeopleSoft Roles Administrator/Developer. Stopping User Deprovision'
            );
            return true;
        }
        return false;
    }
    private Boolean matchDelegatedAdmin() {
        if (userToDeprovision.Sandbox_Delagated_Administrator__c) {
            addToProcessingNotes('Detected Delegated Administrator. Stopping User Deprovision');
            return true;
        } else {
            return false;
        }
    }
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
    private void changeUserField(String fieldName) {
        Deprovision_User_Configuration__c changeFieldTo = deprovisionUserConfiguration.get(
            'Change ' +
            fieldName +
            ' To'
        );

        String fieldValue = (String) (userToDeprovision.get(fieldName));

        // Get name of field (instead of id) if possible
        if (fieldValue != null && fieldIdToNameMap.containsKey(Id.valueOf(fieldValue))) {
            fieldValue = fieldIdToNameMap.get(Id.valueOf(fieldValue));
        }

        addToProcessingNotes('Changed ' + fieldName + ' from: ' + fieldValue + ' to ' + changeFieldTo.Name__c);

        deprovisionedUser.put(fieldName, Id.valueOf(changeFieldTo.Id__c));
    }

    // Set optional attributes
    public void setCases(List<Case> cases) {
        this.cases = cases;
    }
    public void setGroupMemberships(List<GroupMember> groupMemberships) {
        this.groupMemberships = groupMemberships;
    }
    public void setChatterGroupMemberships(List<CollaborationGroupMember> chatterGroupMemberships) {
        this.chatterGroupMemberships = chatterGroupMemberships;
    }
    public void setPermissionSetAssignments(List<PermissionSetAssignment> permissionSetAssignments) {
        this.permissionSetAssignments = permissionSetAssignments;
    }
    public void setUserPackageLicenses(List<UserPackageLicense> userPackageLicenses) {
        this.userPackageLicenses = userPackageLicenses;
    }
    public void setCronJobs(List<CronTrigger> cronJobs) {
        this.cronJobs = cronJobs;
    }
    public void setUserLogin(UserLogin userLogin) {
        this.userLogin = userLogin;
    }
    public void setFieldIdToNameMap(Map<Id, String> fieldIdToNameMap) {
        this.fieldIdToNameMap = fieldIdToNameMap;
    }

    // Access values that are ready for alteration/deletion
    public User getUserToDeprovision() {
        return userToDeprovision;
    }
    public User getDeprovisionedUserWithProcessingNotes() {
        deprovisionedUser.Processing_Notes__c = processingNotes;
        return deprovisionedUser;
    }
    public List<Case> getToUpdateUserCases() {
        return toUpdateCases;
    }
    public UserLogin getToUpdateUserLogin() {
        return toUpdateUserLogin;
    }
    public List<GroupMember> getToDeleteGroupMemberships() {
        return toDeleteGroupMemberships;
    }
    public List<CollaborationGroupMember> getToDeleteChatterGroupMemberships() {
        return toDeleteChatterGroupMemberships;
    }
    public List<PermissionSetAssignment> getToDeletePermissionSetAssignments() {
        return toDeletePermissionSetAssignments;
    }
    public List<CronTrigger> getToAbortCronJobs() {
        return toAbortCronJobs;
    }
    public List<UserPackageLicense> getToDeleteUserPackageLicenses() {
        return toDeleteUserPackageLicenses;
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
        }

        if (cronTypeNameMap.containsKey(key))
            return cronTypeNameMap.get(key);
        return 'UNKNOWN';
    }
}
