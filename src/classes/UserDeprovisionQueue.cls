public without sharing class UserDeprovisionQueue implements Queueable {
    private List<Case> updatedUserCases;
    private List<CollaborationGroupMember> allUserChatterGroupMemberships;
    private List<UserPackageLicense> allUserPackageLicenses;
    private Map<Id, Id> caseToUserMap;
    private Map<Id, String> userToProcessingNotes;

    private static Boolean debug = false;

    public void setUpdatedUserCases(List<Case> updatedUserCases) {
        this.updatedUserCases = updatedUserCases;
    }

    public void setAllUserChatterGroupMemberships(List<CollaborationGroupMember> allUserChatterGroupMemberships) {
        this.allUserChatterGroupMemberships = allUserChatterGroupMemberships;
    }

    public void setCaseToUserMap(Map<Id, Id> caseToUserMap) {
        this.caseToUserMap = caseToUserMap;
    }

    public void setUserToProcessingNotesMap(Map<Id, String> userToProcessingNotes) {
        this.userToProcessingNotes = userToProcessingNotes;
    }

    public void setAllUserPackageLicenses(List<UserPackageLicense> allUserPackageLicenses) {
        this.allUserPackageLicenses = allUserPackageLicenses;
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
        if (!allUserPackageLicenses.isEmpty()) {
            UserDeprovisionOrganizer.deleteSobjectRecords('UserId', allUserPackageLicenses, userToProcessingNotes);
        }
    }

    private class DatabaseErrorException extends Exception {
    }
}
