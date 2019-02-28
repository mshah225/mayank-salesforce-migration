public without sharing class UserDeprovisionOrganizer {

    private List<UserDeprovisioner> userDeprovisionersList;
    private List<User> newUsers;
    private Map<Id, User> oldUsersMap;
    private List<User> deprovisionedUsersWithProcessingNotes;

    public UserDeprovisionOrganizer() {
        userDeprovisionersList = new List<UserDeprovisioner>();
        deprovisionedUsersWithProcessingNotes = new List<User>();
    }

    public void setOldUsersMap(Map<Id, SObject> oldUsersMap) {
        this.oldUsersMap = (Map<Id, User>) oldUsersMap;
    }

    public void setNewUsers(List<SObject> newUsers) {
        this.newUsers = (List<User>) newUsers;
    }

    public void deprovisionUsersBeforeUpdate() {
        List<Id> userToDeprovisionIds = new List<Id>();

        for (User userToDeprovision : newUsers) {
            if (userToDeprovision.Deprovision_User__c && !oldUsersMap.get(userToDeprovision.Id).Deprovision_User__c) {
                userToDeprovisionIds.add(userToDeprovision.Id);
                UserDeprovisioner userDeprovisioner = new UserDeprovisioner();
                userDeprovisioner.setUserToDeprovision(userToDeprovision);
                userDeprovisionersList.add(userDeprovisioner);
            }
        }

        List<Case> allUserCases = [
            SELECT Id, OwnerId, CC_Functional_Group__c, CC_Functional_Group__r.Name, CC_Functional_Group__r.Queue_Id__c, CC_Functional_Group__r.Is_Functional_Group_Private__c
            FROM Case
            WHERE OwnerId IN :userToDeprovisionIds
        ];
        List<GroupMember> allUserPublicGroupMemberships = [
            SELECT UserOrGroupId
            FROM GroupMember
            WHERE UserOrGroupId IN :userToDeprovisionIds
        ];

        Map<Id, List<Case>> userToDeprovisionCaseMap = new Map<Id, List<Case>>();
        for (Case userCase : allUserCases) {
            if (userToDeprovisionCaseMap.containsKey(userCase.OwnerId)) {
                userToDeprovisionCaseMap.get(userCase.OwnerId).add(userCase);
            } else {
                List<Case> userCases = new List<Case>();
                userCases.add(userCase);
                userToDeprovisionCaseMap.put(userCase.OwnerId, userCases);
            }
        }

        Map<Id, String> userToDeprovisionGroupMembershipMap = new Map<Id, String>();
        for (GroupMember groupMember : allUserPublicGroupMemberships) {
            if (userToDeprovisionGroupMembershipMap.containsKey(groupMember.UserOrGroupId)) {
                String groupMemberships = userToDeprovisionGroupMembershipMap.get(groupMember.UserOrGroupId);
                groupMemberships += ', ' + groupMember.UserOrGroupId;
            } else {
                String groupMemberships = '' + groupMember.UserOrGroupId;
                userToDeprovisionGroupMembershipMap.put(groupMember.UserOrGroupId, groupMemberships);
            }
        }

        List<Case> updatedUserCases = new List<Case>();

        for (UserDeprovisioner userDeprovisioner : userDeprovisionersList) {
            userDeprovisioner.setUserCases(userToDeprovisionCaseMap.get(userDeprovisioner.getUserToDeprovision().Id));
            userDeprovisioner.setGroupMemberships(userToDeprovisionGroupMembershipMap.get(userDeprovisioner.getUserToDeprovision().Id));
            userDeprovisioner.deprovisionUser();
            updatedUserCases.addAll(userDeprovisioner.getUpdatedUserCases());
            deprovisionedUsersWithProcessingNotes.add(userDeprovisioner.getDeprovisionedUserIdWithProcessingNotes());
        }

        update updatedUserCases;
        delete allUserPublicGroupMemberships;

    }

    public List<UserDeprovisioner> getUserDeprovisionersList() {
       return userDeprovisionersList;
   }

   public List<User> getDeprovisionedUsersWithProcessingNotes() {
       return deprovisionedUsersWithProcessingNotes;
   }

}
