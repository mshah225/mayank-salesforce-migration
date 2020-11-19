public without sharing class UserDeprovisioner {
    private String processingNotes;
    private User deprovisionedUser;
    private User userToDeprovision;
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;
    private List<Case> userCases;
    private List<Case> updatedUserCases;
    private Map<Id, Id> caseToUserMap;
    private String groupMemberships;
    private String chatterGroupMemberships;
    private String permissionSets;
    private String packageLicenses;

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
            addToProcessingNotes(initialUserTimeStamp());
            if (matchProfileToIgnore()) {
                return;
            }
            changeUserField('ProfileId');
            changeUserField('UserRoleId');
            transferPrivateCasesToFunctionalGroup();
            updateUserFields();
            logRemovedGroupMemberships();
            logRemovedPermissionSets();
            logRemovedChatterGroupMemberships();
            logRemovedPackageLicenses();
            deprovisionedUser.Deprovision_User__c = false;
            deprovisionedUser.IsActive = false;
        } catch (Exception e) {
            addToProcessingNotes('Exception Thrown: ' + e.getMessage());
            addToProcessingNotes('' + e.getStackTraceString());
        }
    }

    private void addToProcessingNotes(String message) {
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
        updatedUserCases = new List<Case>();
        caseToUserMap = new Map<Id, Id>();
        if (userCases != null) {
            for (Case userCase : userCases) {
                if (userCase.CC_Functional_Group__r.Is_Functional_Group_Private__c) {
                    userCase.OwnerId = userCase.CC_Functional_Group__r.Queue_Id__c;
                    caseToUserMap.put(userCase.Id, userToDeprovision.Id);
                    updatedUserCases.add(userCase);
                    addToProcessingNotes(
                        'Transferred case: ' +
                        userCase.Id +
                        ' to Functional Group queue: ' +
                        userCase.CC_Functional_Group__r.Name
                    );
                }
            }
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
}
