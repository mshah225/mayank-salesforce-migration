public without sharing class UserDeprovisionQueue2 implements Queueable {
    private static Boolean debug = false;
    private List<PermissionSetAssignment> toDeletePermissionSetAssignments;
    private Map<Id, String> userToProcessingNotes;

    public UserDeprovisionQueue2() {
        toDeletePermissionSetAssignments = new List<PermissionSetAssignment>();
        userToProcessingNotes = new Map<Id, String>();
    }

    public void setPermissionSetAssignments(List<PermissionSetAssignment> toDeletePermissionSetAssignments) {
        this.toDeletePermissionSetAssignments = toDeletePermissionSetAssignments;
    }

    public void setUserToProcessingNotesMap(Map<Id, String> userToProcessingNotes) {
        this.userToProcessingNotes = userToProcessingNotes;
    }

    public void execute(QueueableContext context) {
        if (!toDeletePermissionSetAssignments.isEmpty()) {
            UserDeprovisionOrganizer.deleteSobjectRecords('AssigneeId', toDeletePermissionSetAssignments, userToProcessingNotes);
        }
    }
}
