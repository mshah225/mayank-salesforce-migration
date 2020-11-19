public without sharing class UserDeprovisionQueue implements Queueable {
    private List<Case> updatedUserCases;
    private List<CollaborationGroupMember> allUserChatterGroupMemberships;
    private Map<Id, Id> caseToUserMap;

    public void setUpdatedUserCases(List<Case> updatedUserCases) {
        this.updatedUserCases = updatedUserCases;
    }

    public void setAllUserChatterGroupMemberships(List<CollaborationGroupMember> allUserChatterGroupMemberships) {
        this.allUserChatterGroupMemberships = allUserChatterGroupMemberships;
    }

    public void setCaseToUserMap(Map<Id, Id> caseToUserMap) {
        this.caseToUserMap = caseToUserMap;
    }

    public void execute(QueueableContext context) {
        if (!updatedUserCases.isEmpty()) {
            updateCases();
        }
        if (!allUserChatterGroupMemberships.isEmpty()) {
            UserDeprovisionOrganizer.deleteSobjectRecords('MemberId', allUserChatterGroupMemberships);
        }
    }

    private void updateCases() {
        List<User> usersWithErrors = new List<User>();

        Database.SaveResult[] saveResult = Database.update(updatedUserCases, false);

        for (Integer i = 0; i < saveResult.size(); i++) {
            if (!saveResult[i].isSuccess()) {
                String processingNotes = 'The following errors have occurred:';
                for (Database.Error err : saveResult[i].getErrors()) {
                    processingNotes += '\n' + err.getStatusCode() + ': ' + err.getMessage();
                    processingNotes += '\nUser fields that affected this error: ' + err.getFields();
                }
                usersWithErrors.add(
                    new User(Id = caseToUserMap.get(updatedUserCases[i].Id), Processing_Notes__c = processingNotes)
                );
            }
        }
        update usersWithErrors;
    }
}
