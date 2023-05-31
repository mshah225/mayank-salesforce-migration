public without sharing class UserDeprovisioner {
    private String processingNotes;
    private User deprovisionedUser;
    private User userToDeprovision;
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;
    private Map<Id, String> fieldIdToNameMap;

    // original data
    private UserLogin userLogin;
    private List<GroupMember> groupMemberships;
    private List<CollaborationGroupMember> chatterGroupMemberships;
    private List<PermissionSetAssignment> permissionSetAssignments;
    private List<UserPackageLicense> userPackageLicenses;
    // Data to delete/update data
    private UserLogin toUpdateUserLogin;
    private List<GroupMember> toDeleteGroupMemberships;
    private List<CollaborationGroupMember> toDeleteChatterGroupMemberships;
    private List<PermissionSetAssignment> toDeletePermissionSetAssignments;
    private List<UserPackageLicense> toDeleteUserPackageLicenses;

    private static Boolean debug = false;
    private static Boolean allowRepeatCases = true;
    private Integer countTransferred = 0;

    public UserDeprovisioner(
        Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration,
        User userToDeprovision
    ) {
        processingNotes = '';
        this.userToDeprovision = userToDeprovision;
        this.deprovisionedUser = new User(Id = userToDeprovision.Id);
        this.deprovisionUserConfiguration = deprovisionUserConfiguration;
        this.fieldIdToNameMap = new Map<Id, String>();

        toUpdateUserLogin = null;
        toDeleteGroupMemberships = new List<GroupMember>();
        toDeleteChatterGroupMemberships = new List<CollaborationGroupMember>();
        toDeletePermissionSetAssignments = new List<PermissionSetAssignment>();
        toDeleteUserPackageLicenses = new List<UserPackageLicense>();
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
            changeUserField('ProfileId');
            changeUserField('UserRoleId');
            updateUserFields();
            updateUserLogin();
            removeGroupMemberships();
            removePermissionSetAssignments();
            removeChatterGroupMemberships();
            removeUserPackageLicenses();
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
        Boolean hasPermSet = false;
        if (permissionSetAssignments != null && !permissionSetAssignments.isEmpty()) {
            for (PermissionSetAssignment permSet : permissionSetAssignments) {
                if (permSet.PermissionSetId == Id.valueOf('0PSd0000000qzf4GAA')) {
                    hasPermSet = true;
                    break;
                }
            }
        }

        if (userToDeprovision.Sandbox_Delagated_Administrator__c || hasPermSet) {
            addToProcessingNotes('Detected Delegated Administrator. Stopping User Deprovision');
            return true;
        } else {
            return false;
        }
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
    public List<UserPackageLicense> getToDeleteUserPackageLicenses() {
        return toDeleteUserPackageLicenses;
    }

    public class DeprovisionUserException extends Exception {
    }
}
