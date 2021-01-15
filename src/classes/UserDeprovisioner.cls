public without sharing class UserDeprovisioner {
    private String processingNotes;
    private User deprovisionedUser;
    private User userToDeprovision;
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;
    private List<Case> userCases;
    private List<Case> updatedUserCases;
    private UserLogin userLogin;
    private UserLogin updatedUserLogin;
    private Map<Id, Id> caseToUserMap;
    private String groupMemberships;
    private String chatterGroupMemberships;
    private String permissionSets;
    private String packageLicenses;
    private String oldUserProcessingNotes;

    private static Boolean debug = false;

    public UserDeprovisioner() {
        processingNotes = '';
        deprovisionedUser = new User();
    }

    public void setUserToDeprovision(User userToDeprovision) {
        this.userToDeprovision = userToDeprovision;
    }

    public void setDeprovisionUserConfiguration(
        Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration
    ) {
        this.deprovisionUserConfiguration = deprovisionUserConfiguration;
    }

    public User getUserToDeprovision() {
        return userToDeprovision;
    }

    public void setUserCases(List<Case> userCases) {
        this.userCases = userCases;
    }

    public String getProcessingNotes() {
        return processingNotes;
    }

    public User getDeprovisionedUserWithProcessingNotes() {
        deprovisionedUser.Processing_Notes__c = getProcessingNotes();
        return deprovisionedUser;
    }

    public List<Case> getUpdatedUserCases() {
        if (updatedUserCases == null) {
            updatedUserCases = new List<Case>();
        }
        return updatedUserCases;
    }

    public UserLogin getUpdatedUserLogin() {
        if (updatedUserLogin == null) {
            updatedUserLogin = userLogin;
        }
        return updatedUserLogin;
    }

    public void setGroupMemberships(String groupMemberships) {
        this.groupMemberships = groupMemberships;
    }

    public void setChatterGroupMemberships(String chatterGroupMemberships) {
        this.chatterGroupMemberships = chatterGroupMemberships;
    }

    public void setPermissionSets(String permissionSets) {
        this.permissionSets = permissionSets;
    }

    public void setPackageLicenses(String packageLicenses) {
        this.packageLicenses = packageLicenses;
    }

    public void setOldProcessingNotes(String oldUserProcessingNotes) {
        if (oldUserProcessingNotes != null && oldUserProcessingNotes.length() > 0) {
            this.oldUserProcessingNotes = oldUserProcessingNotes;
        } else {
            this.oldUserProcessingNotes = '';
        }
    }

    public void setUserLogin(UserLogin userLogin) {
        this.userLogin = userLogin;
    }

    public Map<Id, Id> getCaseToUserMap() {
        if (caseToUserMap == null) {
            caseToUserMap = new Map<Id, Id>();
        }
        return caseToUserMap;
    }

    public void deprovisionUser() {
        try {
            System.debug(userToDeprovision);
            deprovisionedUser.Id = userToDeprovision.Id;
            addToProcessingNotes(this.oldUserProcessingNotes + '\n---');
            addToProcessingNotes(initialUserTimeStamp());
            if (matchProfileToIgnore() || matchSFAdminOrDeveloper()) {
                deprovisionedUser.Deprovision_User__c = false;
                return;
            }
            changeUserField('ProfileId');
            changeUserField('UserRoleId');
            transferPrivateCasesToFunctionalGroup();
            updateUserFields();
            updateUserLogin();
            logRemovedGroupMemberships();
            logRemovedPermissionSets();
            logRemovedChatterGroupMemberships();
            logRemovedPackageLicenses();
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

            ErrorLogger.logFuture(e.getTypeName(), e.getMessage(), e.getStackTraceString(), vars, debug);
        }
    }

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
        return System.now() + ' UserId: ' + UserInfo.getUserId() + ', UserName: ' + UserInfo.getName();
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

    private void changeUserField(String fieldName) {
        Deprovision_User_Configuration__c changeFieldTo = deprovisionUserConfiguration.get(
            'Change ' +
            fieldName +
            ' To'
        );
        addToProcessingNotes(
            'Changed ' +
            fieldName +
            ' from: ' +
            userToDeprovision.get(fieldName) +
            ' to ' +
            changeFieldTo.Name__c
        );
        deprovisionedUser.put(fieldName, Id.valueOf(changeFieldTo.Id__c));
    }

    private void transferPrivateCasesToFunctionalGroup() {
        Integer countTransferred = 0;
        updatedUserCases = new List<Case>();
        caseToUserMap = new Map<Id, Id>();
        if (userCases != null) {
            for (Case userCase : userCases) {
                if (userCase.CC_Functional_Group__r.Is_Functional_Group_Private__c) {
                    userCase.OwnerId = userCase.CC_Functional_Group__r.Queue_Id__c;
                    caseToUserMap.put(userCase.Id, userToDeprovision.Id);
                    updatedUserCases.add(userCase);

                    countTransferred++;
                }
            }

            addToProcessingNotes('Transferred ' + countTransferred + ' private cases to queue.');
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

    private void logRemovedGroupMemberships() {
        if (groupMemberships != null) {
            addToProcessingNotes('Removed user from Public Groups: ' + groupMemberships);
        }
    }

    private void logRemovedChatterGroupMemberships() {
        if (chatterGroupMemberships != null) {
            addToProcessingNotes('Removed user from Chatter Groups: ' + chatterGroupMemberships);
        }
    }

    private void logRemovedPermissionSets() {
        if (permissionSets != null) {
            addToProcessingNotes('Removed user from permissionSets: ' + permissionSets);
        }
    }

    private void logRemovedPackageLicenses() {
        if (packageLicenses != null) {
            addToProcessingNotes('Removed user from Package Licenses: ' + packageLicenses);
        }
    }

    private void updateUserLogin() {
        if (userLogin.IsFrozen) {
            addToProcessingNotes('Unfroze related UserLogin (' + userLogin.Id + ')');
        }
        updatedUserLogin = userLogin;
        updatedUserLogin.IsFrozen = false;
    }
}
