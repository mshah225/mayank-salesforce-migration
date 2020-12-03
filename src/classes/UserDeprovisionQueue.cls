public without sharing class UserDeprovisionQueue implements Queueable {
    private List<Case> updatedUserCases;
    private List<CollaborationGroupMember> allUserChatterGroupMemberships;
    private List<UserPackageLicense> allUserPackageLicenses;
    private Map<Id, Id> caseToUserMap;
    private Map<Id, String> userToOldProcessingNotes;

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

    public void setUserToOldProcessingNotes(Map<Id, String> userToOldProcessingNotes) {
        this.userToOldProcessingNotes = userToOldProcessingNotes;
    }

    public void setAllUserPackageLicenses(List<UserPackageLicense> allUserPackageLicenses) {
        this.allUserPackageLicenses = allUserPackageLicenses;
    }

    public void execute(QueueableContext context) {
        if (!updatedUserCases.isEmpty()) {
            UserDeprovisionOrganizer.updateSobjectRecords('OwnerId', updatedUserCases, userToOldProcessingNotes);
        }
        if (!allUserChatterGroupMemberships.isEmpty()) {
            UserDeprovisionOrganizer.deleteSobjectRecords(
                'MemberId',
                allUserChatterGroupMemberships,
                userToOldProcessingNotes
            );
        }
        if (!allUserPackageLicenses.isEmpty()) {
            UserDeprovisionOrganizer.deleteSobjectRecords('UserId', allUserPackageLicenses, userToOldProcessingNotes);
        }
    }

    private class DatabaseErrorException extends Exception {
    }
}
