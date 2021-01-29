public without sharing class UserDeprovisionQueue implements Queueable {
    /** All non-setup objects should be updated through here.  And setup objects in the UserDeprovisionerOrganizer
     * https://developer.salesforce.com/docs/atlas.en-us.230.0.apexcode.meta/apexcode/apex_dml_non_mix_sobjects.htm
     * contains a list of setup objects, but it is incomplete so you should perform a quick test via the developer
     * console if you are unsure if an object is a setup object or not.
     */
    private List<Case> updatedUserCases;
    private List<CollaborationGroupMember> allUserChatterGroupMemberships;
    private List<UserLogin> updatedUserLogins;
    private Map<Id, String> userToProcessingNotes;
    private List<Id> usersToUncheckAsynchronously;

    private static Boolean debug = false;

    public UserDeprovisionQueue() {
        updatedUserCases = new List<Case>();
        allUserChatterGroupMemberships = new List<CollaborationGroupMember>();
        updatedUserLogins = new List<UserLogin>();
        userToProcessingNotes = new Map<Id, String>();
        usersToUncheckAsynchronously = new List<Id>();
    }

    public void setUpdatedUserCases(List<Case> updatedUserCases) {
        this.updatedUserCases = updatedUserCases;
    }

    public void setAllUserChatterGroupMemberships(List<CollaborationGroupMember> allUserChatterGroupMemberships) {
        this.allUserChatterGroupMemberships = allUserChatterGroupMemberships;
    }

    public void setUserToProcessingNotesMap(Map<Id, String> userToProcessingNotes) {
        this.userToProcessingNotes = userToProcessingNotes;
    }

    public void setUpdatedUserLogins(List<UserLogin> updatedUserLogins) {
        this.updatedUserLogins = updatedUserLogins;
    }

    public void setUsersToUncheckAsynchronously(List<Id> usersToUncheckAsynchronously) {
        this.usersToUncheckAsynchronously = usersToUncheckAsynchronously;
    }

    public void execute(QueueableContext context) {
        if (!updatedUserCases.isEmpty()) {
            UserDeprovisionOrganizer.updateSobjectRecords('OwnerId', updatedUserCases, userToProcessingNotes);
        }
        if (!allUserChatterGroupMemberships.isEmpty()) {
            UserDeprovisionOrganizer.deleteSobjectRecords(
                'MemberId',
                allUserChatterGroupMemberships,
                userToProcessingNotes
            );
        }
        if (!updatedUserLogins.isEmpty()) {
            UserDeprovisionOrganizer.updateSobjectRecords('UserId', updatedUserLogins, userToProcessingNotes);
        }

        // Set all these user's User_Deprovision__c to FALSE now that we are done.
        if (!usersToUncheckAsynchronously.isEmpty()) {
            futureDecheckmarkDeprovisionUser(usersToUncheckAsynchronously);
        }
    }

    @future
    private static void futureDecheckmarkDeprovisionUser(List<Id> uids) {
        List<User> updatedUsers = new List<User>();
        for (Id uid : uids) {
            User u = new User(Id = uid, Deprovision_User__c = false);
            updatedUsers.add(u);
        }
        update updatedUsers;
    }
}
