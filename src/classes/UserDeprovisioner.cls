public without sharing class UserDeprovisioner {

    private String processingNotes;
    private User userToDeprovision;
    private Map<String, Deprovision_User_Configuration__c> deprovisionUserConfiguration;
    private List<Case> userCases;
    private List<Case> updatedUserCases;
    private String groupMemberships;

    public UserDeprovisioner() {
        processingNotes = '';
    }

    public void setUserToDeprovision(User userToDeprovision) {
        this.userToDeprovision = userToDeprovision;
        deprovisionUserConfiguration = Deprovision_User_Configuration__c.getAll();
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

    public User getDeprovisionedUserIdWithProcessingNotes() {
        User deprovisionedUserIdWithProcessingNotes = new User(Id = userToDeprovision.Id, Processing_Notes__c = processingNotes);
        return deprovisionedUserIdWithProcessingNotes;
    }

    public List<Case> getUpdatedUserCases() {
        return updatedUserCases;
    }

    public void setGroupMemberships(String groupMemberships) {
        this.groupMemberships = groupMemberships;
    }

    public void deprovisionUser() {
        try {
            addToProcessingNotes(initialUserTimeStamp());
            if (matchProfileToIgnore()) {
                return;
            }
            changeUserProfile();
            changeUserRole();
            transferPrivateCasesToFunctionalGroup();
            updateUserFields();
            logRemovedGroupMemberships();

        } catch (Exception e) {
            addToProcessingNotes(e.getMessage());
        }
    }

    private void addToProcessingNotes(String message) {
        processingNotes += message + '\n';
    }

    public String initialUserTimeStamp() {
        return System.now() + ' UserId: ' + UserInfo.getUserId() + ', UserName: ' +UserInfo.getName();
    }

    private Boolean matchProfileToIgnore() {
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('ProfileToIgnore')) {
                Id profileIdToMatch = Id.valueOf(deprovisionUserConfiguration.get(deprovisionConfigurationName).Id__c);
                if (userToDeprovision.ProfileId == profileIdToMatch) {
                    addToProcessingNotes('Profile matched to: ' + deprovisionUserConfiguration.get(deprovisionConfigurationName).Name__c + ', Stopping User Deprovision');
                    return true;
                }
            }
        }
        return false;
    }

    private void changeUserProfile() {
        Deprovision_User_Configuration__c changeProfileTo = deprovisionUserConfiguration.get('Change Profile To');
        addToProcessingNotes('Changed User Profile from: ' + userToDeprovision.ProfileId + ' to ' + changeProfileTo.Name__c);
        userToDeprovision.ProfileId = Id.valueOf(changeProfileTo.Id__c);
    }

    private void changeUserRole() {
        Deprovision_User_Configuration__c changeRoleTo = deprovisionUserConfiguration.get('Change Role To');
        addToProcessingNotes('Changed User Role from: ' + userToDeprovision.UserRoleId + ' to ' + changeRoleTo.Name__c);
        userToDeprovision.UserRoleId = Id.valueOf(changeRoleTo.Id__c);
    }

    private void transferPrivateCasesToFunctionalGroup() {
        updatedUserCases = new List<Case>();
        for (Case userCase : userCases) {
            if (userCase.CC_Functional_Group__r.Is_Functional_Group_Private__c) {
                userCase.OwnerId = userCase.CC_Functional_Group__r.Queue_Id__c;
                updatedUserCases.add(userCase);
                addToProcessingNotes('Transferred case: ' + userCase.Id + ' to Functional Group queue: ' + userCase.CC_Functional_Group__r.Name);
            }
        }
    }

    private void updateUserFields() {
        for (String deprovisionConfigurationName : deprovisionUserConfiguration.keySet()) {
            if (deprovisionConfigurationName.contains('SwitchToFalse')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(deprovisionConfigurationName);
                if (userToDeprovision.get(configuration.Name__c) == true) {
                    userToDeprovision.put(configuration.Name__c, false);
                    addToProcessingNotes('Switched ' + configuration.Name__c + ' to false');
                }
            } else if (deprovisionConfigurationName.contains('RemoveValue')) {
                Deprovision_User_Configuration__c configuration = deprovisionUserConfiguration.get(deprovisionConfigurationName);
                if (userToDeprovision.get(configuration.Name__c) != null) {
                    addToProcessingNotes('Removed value '+ userToDeprovision.get(configuration.Name__c) + ' for ' + configuration.Name__c);
                    userToDeprovision.put(configuration.Name__c, null);
                }
            }
        }
    }

    private void logRemovedGroupMemberships() {
        addToProcessingNotes('Removed user from Public Groups: ' + groupMemberships);
    }
}
